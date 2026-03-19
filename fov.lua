local Camera = workspace.CurrentCamera

local fovLoop = game:GetService("RunService").RenderStepped:Connect(function()
    Camera.FieldOfView = 120
end)

-- y luego, si alguna vez quisieras detener el bucle, podrías hacer lo siguiente

fovLoop:Disconnect()
