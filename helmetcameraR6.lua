--R6
local camera = game.Workspace.Camera

local Players = game:GetService("Players")

local Rs = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local CS = game:GetService("ContextActionService")

local Player = Players.LocalPlayer
local Charecter:Model = Player.Character
local Head:Part = Charecter:WaitForChild("Head")
local Torso:Part = Charecter:WaitForChild("Torso")
local Neck:Motor6D = Torso:WaitForChild("Neck")
local Humanoid:Humanoid = Charecter:WaitForChild("Humanoid")
local HumanoidRootPart:Part = Charecter:WaitForChild("HumanoidRootPart")
local Mouse = Player:GetMouse()

Humanoid.AutoRotate = false

local Dead = false


camera.CameraType = Enum.CameraType.Scriptable
camera.FieldOfView = 120



local Offfset = 1.2 --Juega con este valor, cuanto más agregues a este número, se orienta a la derecha; si es negativo, se orienta a la izquierda
local currentxoffset = Offfset

local HelmetPositonLoop
local InputConnection
local MouseConneciton

HelmetPositonLoop = Rs.RenderStepped:Connect(function()
	
	camera.CFrame = (Head.CFrame * CFrame.new(Vector3.new(currentxoffset, 0.5, 0.6)))
	UIS.MouseBehavior = Enum.MouseBehavior.LockCenter

	
end)

local CurrentXDelta = 0
local CurrentYDelta = 0
local NeckCahce = Neck.C0
function MouseMoved(actionName:string, inputState, inputObject:InputObject)
	
	local Neckc0Store:CFrame = Neck.C0

	local CompressedDelta:Vector2 = Vector2.new(inputObject.Delta.X,inputObject.Delta.Y)
	
	CurrentXDelta = CompressedDelta.X
	CurrentYDelta = CompressedDelta.Y

	HumanoidRootPart.CFrame = HumanoidRootPart.CFrame:Lerp(HumanoidRootPart.CFrame * CFrame.Angles(0, -math.rad(CurrentXDelta/2), 0),1) 	
	
	local RotationX, RotationY, RotationZ = Neckc0Store:ToEulerAnglesXYZ()
	
	local NewRotX =    math.deg(RotationX+ -CurrentYDelta/200)
	
	
	
	NewRotX = math.clamp(NewRotX,-160,-10)
	
	Neck.C0 = Neck.C0:Lerp(CFrame.new(Neckc0Store.Position)*CFrame.Angles(math.rad(NewRotX),RotationY,RotationZ),1) 
	
	

	
end

MouseConneciton = CS:BindAction("MouseMoved",MouseMoved,false,Enum.UserInputType.MouseMovement)
	
InputConnection = UIS.InputBegan:Connect(function(input:InputObject,GPE:boolean)
	
	if GPE then return end
	
	local Keycode = input.KeyCode
	
	
	if Keycode == Enum.KeyCode.Q and currentxoffset ~= -Offfset then
		
		currentxoffset = -Offfset
	end
	if Keycode == Enum.KeyCode.E and currentxoffset ~= math.abs(Offfset) then
		currentxoffset = math.abs(Offfset)

	end
	--print(currentxoffset)
	
end)

Humanoid.Died:Connect(function()
	if Dead == true then return end
	
	Dead = true
	InputConnection:Disconnect()

	CS:UnbindAction("MouseMoved")

	task.wait(Players.RespawnTime)
	
	HelmetPositonLoop:Disconnect()
	
end)



