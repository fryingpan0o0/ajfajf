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
 
local currentxoffset = 1.2
 
local HelmetPositonLoop
local InputConnection
local MouseConneciton
 
-- FIX: variable propia para el pitch de la cámara, independiente del arma
local cameraPitch = 0
 
local CurrentXDelta = 0
local CurrentYDelta = 0
local NeckCahce = Neck.C0
 
-- FIX: la cámara usa cameraPitch propio en lugar de Head.CFrame directo
HelmetPositonLoop = Rs.RenderStepped:Connect(function()
 
	local headPos = Head.Position
	local _, headYaw, _ = HumanoidRootPart.CFrame:ToEulerAnglesYXZ()
 
	camera.CFrame = CFrame.new(headPos)
		* CFrame.Angles(0, headYaw, 0)          -- Yaw del cuerpo
		* CFrame.new(currentxoffset, 0.5, 0.6)  -- Offset de casco
		* CFrame.Angles(cameraPitch, 0, 0)       -- Pitch propio, sin interferencia del arma
 
	UIS.MouseBehavior = Enum.MouseBehavior.LockCenter
 
end)
 
function MouseMoved(actionName:string, inputState, inputObject:InputObject)
 
	local Neckc0Store:CFrame = Neck.C0
 
	local CompressedDelta:Vector2 = Vector2.new(inputObject.Delta.X, inputObject.Delta.Y)
 
	CurrentXDelta = CompressedDelta.X
	CurrentYDelta = CompressedDelta.Y
 
	-- Rotar el cuerpo horizontalmente
	HumanoidRootPart.CFrame = HumanoidRootPart.CFrame:Lerp(HumanoidRootPart.CFrame * CFrame.Angles(0, -math.rad(CurrentXDelta/2), 0), 1)
 
	-- FIX: acumular pitch en variable propia (no depende del Neck ni del Head)
	cameraPitch = math.clamp(cameraPitch - CurrentYDelta / 200, math.rad(-70), math.rad(10))
 
	-- Sincronizar el cuello con el pitch (solo para la visual del personaje)
	local RotationX, RotationY, RotationZ = Neckc0Store:ToEulerAnglesXYZ()
	local NewRotX = math.deg(RotationX + -CurrentYDelta/200)
	NewRotX = math.clamp(NewRotX, -160, -10)
	Neck.C0 = Neck.C0:Lerp(CFrame.new(Neckc0Store.Position) * CFrame.Angles(math.rad(NewRotX), RotationY, RotationZ), 1)
 
end
 
MouseConneciton = CS:BindAction("MouseMoved", MouseMoved, false, Enum.UserInputType.MouseMovement)
 
InputConnection = UIS.InputBegan:Connect(function(input:InputObject, GPE:boolean)
 
	if GPE then return end
 
	local Keycode = input.KeyCode
 
	if Keycode == Enum.KeyCode.Q then
		currentxoffset = -currentxoffset
	elseif Keycode == Enum.KeyCode.E then
		currentxoffset = math.abs(currentxoffset)
	end
 
end)
 
Humanoid.Died:Connect(function()
	if Dead == true then return end
 
	Dead = true
	InputConnection:Disconnect()
 
	CS:UnbindAction("MouseMoved")
 
	task.wait(Players.RespawnTime)
 
	HelmetPositonLoop:Disconnect()
 
end)