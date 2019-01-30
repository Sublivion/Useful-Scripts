--[[
	--	GNU General Public License v3.0	--
	Permissions of this strong copyleft license are conditioned on making available complete source code 
	of licensed works and modifications, which include larger works using a licensed work, under the same 
	license. Copyright and license notices must be preserved. Contributors provide an express grant of 
	patent rights.
	
	https://github.com/Sublivion/Useful-Scripts
	
	Written by Sublivion 27/1/19.
--]]

-- Services
local Rand = Random.new()

-- Configuration
local V1, V2 = Vector3.new(-3750, 73, -1500), Vector3.new(3250, 74, 5000)
local ORIENTATION_BOUNDS = Vector3.new(20, 360, 20)
local AMOUNT = 500
local SELECTION = script['_VEGETATION']:GetChildren()
local TARGET_SURFACE = workspace.Grass
local PARENT = workspace.Vegetation

-- Local functions
local function GetPositionWithinBounds()
	return Vector3.new(
		Rand:NextNumber(V1.X, V2.X),
		Rand:NextNumber(V1.Y, V2.Y),
		Rand:NextNumber(V1.Z, V2.Z))
end

-- Start message
print('Procedurally placing', AMOUNT, 'items from', SELECTION[1].Parent.Name, 
	'between the position', V1, 'and', V2, 'on the surface named', TARGET_SURFACE.Name, 
	'inside of the', PARENT.ClassName, PARENT.Name)

-- Generate procedurally
for i = 1, AMOUNT do
	-- Select randoms
	local Position
	local ToPlace = SELECTION[Rand:NextInteger(1, #SELECTION)]
	local Orientation = Vector3.new(
		Rand:NextNumber(-ORIENTATION_BOUNDS.X, ORIENTATION_BOUNDS.X),
		Rand:NextNumber(-ORIENTATION_BOUNDS.Y, ORIENTATION_BOUNDS.Y),
		Rand:NextNumber(-ORIENTATION_BOUNDS.Z, ORIENTATION_BOUNDS.Z))
	
	-- Select position
	repeat
		Position = GetPositionWithinBounds()
		GroundRay = Ray.new(Position, Vector3.new(0, -5000, 0))
	until not workspace:FindPartOnRay(GroundRay, TARGET_SURFACE)
	
	-- Place item
	local Item = ToPlace:Clone()
	local Cf = CFrame.new(Position, Vector3.new(0, 0, 0)) * CFrame.fromOrientation(Orientation.X, Orientation.Y, Orientation.Z)
	if Item:IsA('Model') then
		if Item.PrimaryPart then
			Item:SetPrimaryPartCFrame(Cf)
		else
			warn('No primary part set for', ToPlace.Name)
		end
	else
		Item.CFrame = Cf
	end
	Item.Parent = PARENT
	
	
	-- Print
	print(ToPlace, Position, Orientation)
end

-- End message
print('COMPLETED PLACING: procedurally placed', AMOUNT, 'items from', SELECTION[1].Parent.Name, 
	'between', V1, 'and', V2, 'on the surface named', TARGET_SURFACE.Name, 
	'inside of the', PARENT.ClassName, PARENT.Name)
