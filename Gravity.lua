--[[
	--	GNU General Public License v3.0	--
	Permissions of this strong copyleft license are conditioned on making available complete source code 
	of licensed works and modifications, which include larger works using a licensed work, under the same 
	license. Copyright and license notices must be preserved. Contributors provide an express grant of 
	patent rights.
  
  A module to simulate accurate gravity and planets in Roblox.

  https://github.com/Sublivion/Useful-Scripts
  
  To create a planet, add a module named Gravity like this into your model:
    return {
      Mass = 5.972E+24,
      ExtraRadius = 1425000,
      Flat = true,
    }
    
   Call init at server start and update each frame in a server script.
   
   I have added this here as I have removed it from my Rocket System (at v2).
   
   Written by Sublivion.
--]]

-- Constants
local G = 6.67408E-11
local SCALE = 3.28084

-- Variables
local DeltaTime = 0
local LastTick = tick()
local GravityParts = {}
local Planets = {}

-- Functions
local V3 = Vector3.new

-- Module
local M = {}

-- local functions


-- Setup gravity for part
local function SetGravity(Part)
	for i, Planet in pairs(Planets) do
		if Part and Part:IsA('BasePart') and not Part.Anchored and not Part.Massless and Part.CanCollide then
			local VectorForce = Instance.new('VectorForce')
			local Attachment = Instance.new('Attachment')
			VectorForce.Force = V3(0, 0, 0)
			VectorForce.Attachment0 = Attachment
			VectorForce.Name = 'Gravity-' .. Planet.Name
			Attachment.Name = 'GravityAttachment-' .. Planet.Name
			VectorForce.Parent = Part
			Attachment.Parent = Part
			table.insert(GravityParts, Part)
		end
	end
end

function M.Init()
	-- Get planets
	for i, v in pairs(workspace:GetDescendants()) do
		if v:IsA('Model') and v:FindFirstChild('Gravity') then
			if v.Gravity:IsA('ModuleScript') then
				table.insert(Planets, {Name = v.Name, Stats = require(v.Gravity), Model = v})
			end
		end
	end
	
	-- Set gravity
	if #Planets > 0 then
		workspace.Gravity = 0
	end
	
	-- Existing parts
	for i, v in pairs(workspace:GetDescendants()) do
		SetGravity(v)
	end
	
	-- New parts
	workspace.DescendantAdded:Connect(function(v)
		SetGravity(v)
	end)
end

function M.Update()
	DeltaTime = tick() - LastTick
		
	for PartIndex, Part in pairs(GravityParts) do
		-- Calculate gravity with each planet
		for PlanetIndex, Planet in pairs(Planets) do
			local VectorForce = Part:FindFirstChild('Gravity-' .. Planet.Name)
			local Attachment = Part:FindFirstChild('GravityAttachment-' .. Planet.Name)
			
			if VectorForce and Attachment then
				-- Calculate gravity
				local Difference = Planet.Model:GetModelCFrame().p - Part.CFrame.p
				local Gravity = (G * Planet.Stats.Mass * Part:GetMass())
						---------------------------------------------------------------
						/ ((Difference.Magnitude / SCALE) + Planet.Stats.ExtraRadius)^2
				
				if Planet.Stats.Flat then
					VectorForce.Force = Vector3.new(0, -Gravity, 0)
				else
					warn('SPHERICAL PLANETS ARE NOT YET SUPPORTED')
				end
			end
		end
	end
	
	LastTick = tick()
end

return M
