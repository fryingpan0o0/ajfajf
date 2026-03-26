-- SnowToSandTexture LocalScript
-- Reemplaza texturas de snow (post-2022) por texturas de arena (pre-2022)
-- Colocar en: StarterPlayerScripts o StarterCharacterScripts

local RunService = game:GetService("RunService")

-- ============================================================
-- MAPA DE TEXTURAS: Snow 2022 -> Sand pre-2022
-- ============================================================
-- Agrega o modifica los IDs según los assets de tu juego.
-- Formato: ["ID_snow_nuevo"] = "ID_arena_viejo"
-- ============================================================
local TEXTURE_MAP = {
    -- Snow terrain textures (Material 2022 update)
    ["rbxassetid://7547619700"] = "rbxassetid://5765946693", -- Snow top
    ["rbxassetid://7547619809"] = "rbxassetid://5765946693", -- Snow side
    ["rbxassetid://7547619982"] = "rbxassetid://5765946693", -- Snow overlay
    ["rbxassetid://6372233220"] = "rbxassetid://5765946693", -- Snow variant
    ["rbxassetid://6372231020"] = "rbxassetid://5765946693", -- Snow alt
    -- Sand terrain textures (Material 2022 update -> rollback a pre-2022)
    ["rbxassetid://7547620299"] = "rbxassetid://1414214413", -- Sand 2022
    ["rbxassetid://7547620441"] = "rbxassetid://1414214413", -- Sand 2022 variant
    -- Agrega más IDs aquí según necesites
}

-- ============================================================
-- CONFIGURACIÓN
-- ============================================================
local CONFIG = {
    -- Si es true, también revisa y remplaza en modelos dentro de workspace
    CHECK_WORKSPACE     = true,
    -- Si es true, monitorea cambios en tiempo real (DescendantAdded)
    MONITOR_REALTIME    = true,
    -- Si es true, imprime en output cada reemplazo realizado
    DEBUG_LOG           = true,
    -- Delay inicial antes de correr (útil para esperar que cargue el mapa)
    INIT_DELAY          = 1,
}

-- ============================================================
-- UTILIDADES
-- ============================================================
local function log(msg)
    if CONFIG.DEBUG_LOG then
        print("[SnowToSand] " .. tostring(msg))
    end
end

-- Normaliza un ID de textura para comparación:
-- Acepta "rbxassetid://12345", "12345", "http://...?id=12345"
local function normalizeId(raw)
    if not raw or raw == "" then return nil end
    raw = tostring(raw):lower():gsub("%s", "")
    -- Extraer solo los dígitos del asset id
    local num = raw:match("(%d+)$") or raw:match("id=(%d+)")
    if num then
        return "rbxassetid://" .. num
    end
    return nil
end

-- Devuelve la textura de reemplazo si existe en el mapa, o nil
local function getMappedTexture(originalId)
    local norm = normalizeId(originalId)
    if not norm then return nil end
    return TEXTURE_MAP[norm]
end

-- ============================================================
-- PROCESAMIENTO DE INSTANCIAS
-- ============================================================
local function processTexture(obj)
    -- Clase: Texture o Decal dentro de Parts/MeshParts
    if obj:IsA("Texture") or obj:IsA("Decal") then
        local replacement = getMappedTexture(obj.Texture)
        if replacement then
            log(("Reemplazando Texture en %s: %s -> %s"):format(
                obj.Parent and obj.Parent:GetFullName() or "?",
                obj.Texture, replacement))
            obj.Texture = replacement
        end
        return
    end

    -- Clase: SpecialMesh con TextureId
    if obj:IsA("SpecialMesh") then
        local replacement = getMappedTexture(obj.TextureId)
        if replacement then
            log(("Reemplazando SpecialMesh.TextureId en %s: %s -> %s"):format(
                obj.Parent and obj.Parent:GetFullName() or "?",
                obj.TextureId, replacement))
            obj.TextureId = replacement
        end
        return
    end

    -- Clase: MeshPart con TextureID
    if obj:IsA("MeshPart") then
        local replacement = getMappedTexture(obj.TextureID)
        if replacement then
            log(("Reemplazando MeshPart.TextureID en %s: %s -> %s"):format(
                obj:GetFullName(),
                obj.TextureID, replacement))
            obj.TextureID = replacement
        end
        return
    end

    -- Clase: Part con Material == Snow (reemplazar Material a Sand)
    -- Esto sirve para partes que usan el material nativo de Roblox
    if obj:IsA("BasePart") then
        if obj.Material == Enum.Material.Snow then
            log(("Cambiando Material Snow -> Sand en %s"):format(obj:GetFullName()))
            obj.Material = Enum.Material.Sand
        end
    end
end

-- Recorre todos los descendientes de un contenedor y procesa
local function scanContainer(container)
    for _, obj in ipairs(container:GetDescendants()) do
        local ok, err = pcall(processTexture, obj)
        if not ok then
            warn("[SnowToSand] Error procesando " .. tostring(obj) .. ": " .. tostring(err))
        end
    end
end

-- ============================================================
-- TERRAIN: reemplazar el material Snow en el Terrain
-- (Solo afecta la visualización client-side del MaterialOverride)
-- ============================================================
local function applyTerrainOverride()
    local terrain = workspace:FindFirstChildOfClass("Terrain")
    if not terrain then return end

    -- MaterialOverride: si el juego tiene materialservice con overrides personalizados
    local MaterialService = game:GetService("MaterialService")
    if MaterialService then
        -- El MaterialService permite overrides de materiales en el cliente
        -- Intentamos aplicar override de snow -> sand si está disponible
        local ok, err = pcall(function()
            -- Esto funciona en experiencias que tienen MaterialVariants
            for _, variant in ipairs(MaterialService:GetDescendants()) do
                if variant:IsA("MaterialVariant") then
                    if variant.BaseMaterial == Enum.Material.Snow then
                        -- Cambiar el BaseMaterial del variant a Sand como override visual
                        -- (solo cambia la apariencia local)
                        local sandVariant = getMappedTexture(variant.ColorMapContent)
                        if sandVariant then
                            variant.ColorMapContent = sandVariant
                            log("MaterialVariant Snow overrideado: " .. variant.Name)
                        end
                    end
                end
            end
        end)
        if not ok then
            log("MaterialService override no disponible: " .. tostring(err))
        end
    end
end

-- ============================================================
-- MAIN
-- ============================================================
local function main()
    log("Iniciando reemplazo de texturas Snow -> Sand...")
    task.wait(CONFIG.INIT_DELAY)

    -- Escanear workspace
    if CONFIG.CHECK_WORKSPACE then
        log("Escaneando workspace...")
        scanContainer(workspace)
    end

    -- Intentar override de terrain
    applyTerrainOverride()

    -- Monitor en tiempo real
    if CONFIG.MONITOR_REALTIME then
        log("Activando monitor en tiempo real...")
        workspace.DescendantAdded:Connect(function(obj)
            task.defer(function()
                local ok, err = pcall(processTexture, obj)
                if not ok then
                    warn("[SnowToSand] Error en monitor: " .. tostring(err))
                end
            end)
        end)
    end

    log("Listo. Reemplazo completado.")
end

main()
