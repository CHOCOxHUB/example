if not game:IsLoaded() then
    game.Loaded:Wait()
end

local gameVibeDungeonID = 93978595733734

local function MuatScript()
    if game.PlaceId == gameVibeDungeonID then
        --load script khusus VD
        loadstring(game:HttpGet("https://raw.githubusercontent.com/CHOCOxHUB/example/refs/heads/main/CHOCOxHUB-ViolenceDistrict.lua"))()
    else
        -- script universal
        loadstring(game:HttpGet("https://raw.githubusercontent.com/CHOCOxHUB/example/refs/heads/main/CHOCO-X-HUB-Auto-Walk.lua"))()
    end
end


pcall(MuatScript)
