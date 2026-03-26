-- SnowToSand | Executor Edition
-- Compatible con Xeno, Solara, Wave y similares
-- Pegar y ejecutar directamente en el executor

-- ============================================================
-- MAPA DE TEXTURAS: Snow 2022 -> Sand pre-2022
-- ============================================================
local TEXTURE_MAP = {
    ["rbxassetid://7547619700"] = "rbxassetid://5765946693",
    ["rbxassetid://7547619809"] = "rbxassetid://5765946693",
    ["rbxassetid://7547619982"] = "rbxassetid://5765946693",
    ["rbxassetid://6372233220"] = "rbxassetid://5765946693",
    ["rbxassetid://6372231020"] = "rbxassetid://5765946693",
    ["rbxassetid://7547620299"] = "rbxassetid://1414214413",
    ["rbxassetid://7547620441"] = "rbxassetid://1414214413",
}

-- ============================================================
-- CONFIG
-- ============================================================
local DEBUG        = true   -- true = muestra reemplazos en consola del executor
local REALTIME     = true   -- true = monitorea partes nuevas que aparezcan
local CHANGE_MAT   = true   -- true = cambia Material.Snow -> Material.Sand en BaseParts

-- ============================================================
-- UTILIDADES
-- ============================================================
local function log(msg)
    if DEBUG then
        print("[SnowToSand] " .. tostring(msg))
    end
end

local function normalizeId(raw)
    if not raw or raw == "" then return nil end
    raw = tostring(raw):lower():gsub("%s", "")
    local num = raw:match("(%d+)$") or raw:match("id=(%d+)")
    if num then
        return "rbxassetid://" .. num
    end
    return nil
end

local function getReplacement(id)
    local norm = normalizeId(id)
    if not norm then return nil end
    return TEXTURE_MAP[norm]
end

-- ============================================================
-- PROCESAR UNA INSTANCIA
-- ============================================================
local function process(obj)
    -- Texture / Decal
    if obj:IsA("Texture") or obj:IsA("Decal") then
        local r = getReplacement(obj.Texture)
        if r then
            log("Texture en " .. obj.Parent.Name .. ": " .. obj.Texture .. " -> " .. r)
            obj.Texture = r
        end

    -- SpecialMesh
    elseif obj:IsA("SpecialMesh") then
        local r = getReplacement(obj.TextureId)
        if r then
            log("SpecialMesh en " .. obj.Parent.Name .. ": " .. obj.TextureId .. " -> " .. r)
            obj.TextureId = r
        end

    -- MeshPart
    elseif obj:IsA("MeshPart") then
        local r = getReplacement(obj.TextureID)
        if r then
            log("MeshPart " .. obj.Name .. ": " .. obj.TextureID .. " -> " .. r)
            obj.TextureID = r
        end

    -- BasePart Material
    elseif CHANGE_MAT and obj:IsA("BasePart") then
        if obj.Material == Enum.Material.Snow then
            log("Material Snow -> Sand en " .. obj.Name)
            obj.Material = Enum.Material.Sand
        end
    end
end

-- ============================================================
-- SCAN INICIAL
-- ============================================================
log("Escaneando workspace...")
for _, obj in ipairs(workspace:GetDescendants()) do
    pcall(process, obj)
end
log("Scan inicial completado.")

-- ============================================================
-- MONITOR EN TIEMPO REAL
-- ============================================================
if REALTIME then
    workspace.DescendantAdded:Connect(function(obj)
        task.defer(function()
            pcall(process, obj)
        end)
    end)
    log("Monitor en tiempo real activado.")
end

log("Listo!")
