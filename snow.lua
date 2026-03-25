print("[ClassicSnow] ✔ Textura clásica de nieve aplicada correctamente.")
end
 
-- ----------------------------------------------------------------
-- También podemos parchear partes individuales en el workspace
-- por si el servidor no usa Terrain Snow sino Parts con Material Snow
-- ----------------------------------------------------------------
local function patchPartMaterials(root)
	for _, obj in ipairs(root:GetDescendants()) do
		if obj:IsA("BasePart") and obj.Material == Enum.Material.Snow then
			-- Asignamos el mismo MaterialVariant por nombre
			-- Nota: MaterialVariant en parts se asigna vía MaterialVariant property (string)
			obj.MaterialVariant = "ClassicSnowVariant"
		end
	end
end
 
-- ----------------------------------------------------------------
-- Ejecución
-- ----------------------------------------------------------------
 
-- 1) Aplicar el variant primero
applyClassicSnow()
 
-- 2) Parchear partes existentes en el workspace
patchPartMaterials(workspace)
 
-- 3) Escuchar nuevas partes que se añadan (útil en mapas dinámicos)
workspace.DescendantAdded:Connect(function(obj)
	if obj:IsA("BasePart") and obj.Material == Enum.Material.Snow then
		-- Pequeño delay para que la parte se inicialice
		task.defer(function()
			if obj.Material == Enum.Material.Snow then
				obj.MaterialVariant = "ClassicSnowVariant"
			end
		end)
	end
end)
 
-- 4) Si el jugador hace respawn, re-aplicar (por si MaterialService se resetea)
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
 
localPlayer.CharacterAdded:Connect(function()
	task.wait(0.1)  -- esperar que el personaje cargue
	applyClassicSnow()
	patchPartMaterials(workspace)
end)