local Gui = game.Players.LocalPlayer:WaitForChild("PlayerGui")
 
local screenGui = Instance.new("ScreenGui")
screenGui.ResetOnSpawn = false
screenGui.Parent = Gui
 
local Button = Instance.new("TextButton")
Button.BackgroundTransparency = 1
Button.Size = UDim2.new(0, 0, 0, 0)
Button.Position = UDim2.new(0, 0, 0, 0)
Button.Text = ""
Button.Modal = false
Button.Parent = screenGui
 
local UserInputService = game:GetService("UserInputService")
 
local mouseLocked = false
UserInputService.MouseIconEnabled = false
 
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if input.KeyCode == Enum.KeyCode.Q and not gameProcessed then
        mouseLocked = not mouseLocked
        Button.Modal = mouseLocked
        UserInputService.MouseIconEnabled = mouseLocked
    end
end)