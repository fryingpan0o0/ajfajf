-- ============================================================
--  ClassicSnow_LocalScript
--  Reemplaza visualmente la textura de nieve 2022+ en BaseParts
--  inyectando un SurfaceAppearance con textura clásica (pre-2022).
--
--  UBICACIÓN: StarterPlayerScripts
--  TIPO: LocalScript (solo visual, solo para vos)
-- ============================================================

-- Textura clásica de arena/nieve pre-2022
-- (Son los asset IDs de las texturas originales de Sand que Roblox
--  usaba para Snow antes de MaterialsV2)
local COLOR_MAP     = "rbxassetid://6372755229"  -- Sand color clásico
local NORMAL_MAP    = "rbxassetid://6372755751"  -- Sand normal clásico
local ROUGHNESS_MAP = "rbxassetid://6372755562"  -- Sand roughness clásico
local METALNESS_MAP = "rbxassetid://6372755562"  -- Sand metalness clásico

-- ----------------------------------------------------------------
-- Inyecta un SurfaceAppearance en una parte con material Snow
-- ----------------------------------------------------------------
local function applyTopart(part)
	-- Solo actuar en BaseParts con material Snow
	if not part:IsA("BasePart") then return end
	if part.Material ~= Enum.Material.Snow then return end

	-- Evitar duplicados
	if part:FindFirstChildOfClass("SurfaceAppearance") then return end

	local sa = Instance.new("SurfaceAppearance")
	sa.ColorMap     = COLOR_MAP
	sa.NormalMap    = NORMAL_MAP
	sa.RoughnessMap = ROUGHNESS_MAP
	sa.MetalnessMap = METALNESS_MAP
	sa.AlphaMode    = Enum.AlphaMode.Overlay
	sa.Parent       = part
end

-- ----------------------------------------------------------------
-- Aplicar a todas las partes existentes
-- ----------------------------------------------------------------
local function scanWorkspace()
	for _, obj in ipairs(workspace:GetDescendants()) do
		applyTopart(obj)
	end
end

-- ----------------------------------------------------------------
-- Ejecución
-- ----------------------------------------------------------------

-- Esperar a que el workspace cargue
game:GetService("ContentProvider"):PreloadAsync({workspace})
task.wait(1)

-- Escaneo inicial
scanWorkspace()
print("[ClassicSnow] ✔ Escaneo inicial completado.")

-- Detectar partes nuevas que aparezcan dinámicamente
workspace.DescendantAdded:Connect(function(obj)
	task.defer(function()
		applyTopart(obj)
	end)
end)

-- Re-aplicar si el material de alguna parte cambia a Snow en runtime
workspace.DescendantAdded:Connect(function(obj)
	if obj:IsA("BasePart") then
		obj:GetPropertyChangedSignal("Material"):Connect(function()
			applyTopart(obj)
		end)
	end
end)
