local _version = "3.0.0"
local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/download/1.6.64-fix/main.lua"))()

-- =========================================================
-- GRADIENT FUNCTION
-- =========================================================
local function gradient(text, startColor, endColor, timeOffset)
    if type(text) ~= "string" or text == "" then return "" end
    local chars, result = {}, {}
    for _, c in utf8.codes(text) do chars[#chars+1] = utf8.char(c) end
    local len = #chars
    local div = math.max(len-1, 1)
    timeOffset = tonumber(timeOffset) or 0
    for i = 1, len do
        local t = math.abs((((i-1)/div)+timeOffset)%2-1)
        local color = startColor:Lerp(endColor, t)
        result[i] = string.format('<font color="#%s">%s</font>', color:ToHex(), chars[i])
    end
    return table.concat(result)
end

-- =========================================================
-- ADD THEME
-- =========================================================
WindUI:AddTheme({
    Name = "FayintX",
    Accent = "#FF3131",
    Dialog = "#1e0a0a",
    Outline = "#FF6061",
    Text = "#f8fafc",
    Placeholder = "#94a3b8",
    Background = "#0f0505",
    Button = "#2d0a0a",
    Icon = "#f8fafc"
})

WindUI:SetTheme("FayintX")

-- =========================================================
-- EXECUTOR DETECTION
-- =========================================================
local executorName = "Unknown"
if identifyexecutor then executorName = identifyexecutor()
elseif getexecutorname then executorName = getexecutorname()
elseif executor then executorName = executor end

-- =========================================================
-- SERVICES
-- =========================================================
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")
local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local HttpService = game:GetService("HttpService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- =========================================================
-- FPS UNLOCK
-- =========================================================
if setfpscap then
    setfpscap(1000000)
    print("FPS Unlocked!")
end

-- =========================================================
-- WINDOW UTAMA (STYLE FAYINT)
-- =========================================================
local Window = WindUI:CreateWindow({
    Title = "<b>" .. gradient("FayintXCode", Color3.fromHex("#FF3131"), Color3.fromHex("#FF6061")) .. "</b>", 
    Author = gradient("Violence District", Color3.fromHex("#E0E0E0"), Color3.fromHex("#A1A1A1")),
    Icon = "rbxassetid://120300880947393",
    Theme = "FayintX", 
    Size = UDim2.fromOffset(550, 450), 
    Resizable = true,
    MinSize = Vector2.new(450, 350),
    MaxSize = Vector2.new(650, 550),
    Transparent = true,
    IgnoreAlerts = true,
    HideSearchBar = false,
    SideBarWidth = 180, 
    TopBarButtonIconSize = 18,
    Folder = "FayintXCode",
    ToggleKey = Enum.KeyCode.V,
    User = {
        Enabled = true,
        Anonymous = false,
        Callback = function()
            -- Nothing
        end,
    },
    OpenButton = {
        Title = gradient("FayintXCode", Color3.fromHex("#FF3131"), Color3.fromHex("#FF6061")),
        Icon = "rbxassetid://120300880947393",
        CornerRadius = UDim.new(1, 0), 
        StrokeThickness = 2.2,
        Draggable = true,
        Enabled = true,
        OnlyMobile = false,
        Scale = 0.85,
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0.00, Color3.fromHex("#FF3131")),
            ColorSequenceKeypoint.new(0.50, Color3.fromHex("#FF6061")),
            ColorSequenceKeypoint.new(1.00, Color3.fromHex("#8B0000"))
        })
    },
    Topbar = { Height = 45, ButtonsType = "Default" },
})

local PingTag = Window:Tag({ Title = "Ping: 0ms", Color = Color3.fromRGB(100,200,255) })
task.spawn(function()
    while true do
        local ok, ping = pcall(function()
            return math.floor(game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue())
        end)
        if ok and ping then
            PingTag:SetTitle("Ping: "..ping.."ms")
            if ping <= 50 then PingTag:SetColor(Color3.fromRGB(0,255,0))
            elseif ping <= 100 then PingTag:SetColor(Color3.fromRGB(255,200,0))
            elseif ping <= 200 then PingTag:SetColor(Color3.fromRGB(255,150,0))
            else PingTag:SetColor(Color3.fromRGB(255,0,0)) end
        end
        task.wait(2)
    end
end)

pcall(function()
    Window:CreateTopbarButton("TransparencyToggle", "eye", function()
        if getgenv().TransparencyEnabled then
            getgenv().TransparencyEnabled = false
            pcall(function() Window:ToggleTransparency(false) end)
        else
            getgenv().TransparencyEnabled = true
            pcall(function() Window:ToggleTransparency(true) end)
        end
    end, 990)
end)

Window:Tag({ 
    Title = "<b>" .. gradient("@FayintX", Color3.fromHex("#FF3131"), Color3.fromHex("#FF6061")) .. "</b>", 
    Icon = "rbxassetid://101132151462030", 
    Border = true, 
    Color = Color3.fromHex("#1a0a0a") 
})
Window:Divider()

---------------------------------------------------
--== CREATE TABS ==--
---------------------------------------------------
local InfoTab = Window:Tab({ Title = "Information", Icon = "info" })
local PlayerTab = Window:Tab({ Title = "Player", Icon = "user" })
local SurvivorTab = Window:Tab({ Title = "Survivor", Icon = "user-check" })
local KillerTab = Window:Tab({ Title = "Killer", Icon = "swords" })
local ESPTab = Window:Tab({ Title = "ESP", Icon = "eye" })
local VisualTab = Window:Tab({ Title = "Visual", Icon = "sun" })
local TeleportTab = Window:Tab({ Title = "Teleport", Icon = "navigation" })
local ConfigTab = Window:Tab({ Title = "Config", Icon = "folder" })

--// ================= INFO TAB =================
local InviteCode = "qC7DN73VZe"
local DiscordAPI = ("https://discord.com/api/v10/invites/%s?with_counts=true&with_expiration=true"):format(InviteCode)

local Dialog = Window:Dialog({
    Icon = "circle-plus",
    Title = "Join Discord",
    Content = "For Update",
    Buttons = {
        {
            Title = "Copy Discord",
            Callback = function()
                if setclipboard then
                    setclipboard("https://discord.gg/qC7DN73VZe")
                    WindUI:Notify({
                        Title = "Copied Successfully!",
                        Content = "The Discord link has been copied to the clipboard.",
                        Duration = 3,
                        Icon = "check"
                    })
                else
                    WindUI:Notify({
                        Title = "Fail!",
                        Content = "Your executor does not support the auto-copy command.",
                        Duration = 3,
                        Icon = "x"
                    })
                end
            end,
        },
        {
            Title = "No",
            Callback = function()
                WindUI:Notify({
                    Title = "Canceled",
                    Content = "You cancel the action.",
                    Duration = 3,
                    Icon = "x"
                })
            end,
        },
    },
})

local function GetDiscordData()
    local success, result = pcall(function()
        local requestFunc = WindUI.Request and function(opt)
            return WindUI:Request(opt)
        end or (WindUI.Creator and WindUI.Creator.Request)

        if not requestFunc then return false end

        local response = requestFunc({
            Url = DiscordAPI,
            Method = "GET",
            Headers = {
                ["User-Agent"] = "RobloxBot/1.0",
                ["Accept"] = "application/json"
            }
        })

        if not response or not response.Body then return false end
        return HttpService:JSONDecode(response.Body)
    end)

    return success, result
end

local DiscordInfo
local success, result = GetDiscordData()

if success and result and result.guild then
    local icon = "square-user"
    if result.guild.icon then
        icon = string.format(
            "https://cdn.discordapp.com/icons/%s/%s.png?size=1024",
            result.guild.id,
            result.guild.icon
        )
    end

    DiscordInfo = InfoTab:Paragraph({
        Title = result.guild.name or "Unknown Server",
        Desc = string.format(
            '• Member : %d\n• Online : %d',
            result.approximate_member_count or 0,
            result.approximate_presence_count or 0
        ),
        Image = icon,
        ImageSize = 42,
    })

    InfoTab:Button({
        Title = "Update Info",
        Icon = "refresh-cw",
        Desc = "Update Discord server information\n(member count & online status)",
        Callback = function()
            local ok, data = GetDiscordData()
            if ok and data and data.guild then
                DiscordInfo:SetTitle(data.guild.name or "Unknown Server")
                DiscordInfo:SetDesc(string.format(
                    '• Member : %d\n• Online : %d',
                    data.approximate_member_count or 0,
                    data.approximate_presence_count or 0
                ))

                if data.guild.icon then
                    DiscordInfo:SetImage(string.format(
                        "https://cdn.discordapp.com/icons/%s/%s.png?size=1024",
                        data.guild.id,
                        data.guild.icon
                    ))
                end
            else
                WindUI:Notify({
                    Title = "Discord",
                    Content = "Failed to update Discord info",
                    Duration = 2
                })
            end
        end
    })

    InfoTab:Button({
        Title = "Copy Invite Discord",
        Desc = "Copy Discord invite link to clipboard to share",
        Callback = function()
            if setclipboard then
                setclipboard("https://discord.gg/" .. InviteCode)
                WindUI:Notify({
                    Title = "Discord",
                    Content = "Invite copied to clipboard",
                    Duration = 2
                })
            else
                warn("Clipboard not available")
            end
        end
    })
else
    InfoTab:Paragraph({
        Title = "Discord Error",
        Desc = "Failed to retrieve Discord data\n(API Down / Rate Limit)",
        Image = "triangle-alert",
        ImageSize = 26,
        Color = "Red",
    })
end

InfoTab:Divider()

-- Developer Information Section
local DevSection = InfoTab:Section({
    Title = "Developer Information",
    Box = true,
    BoxBorder = true,
    Icon = "code",
    Opened = true
})

DevSection:Paragraph({
    Title = "FayintXCode | Dev Ai",
    Desc = "• Developer of FayintXCode\n• Script Creator since 2024\n• Focus on Quality & Free Scripts\n• Trusted by 10,000+ Users Worldwide",
    Image = "rbxassetid://120300880947393",
    ImageSize = 50,
})

-- Social Media Section
local ListFeature = InfoTab:Section({
    Title = "List Feature",
    Box = true,
    BoxBorder = true,
    Icon = "users",
    Opened = false
})

ListFeature:Paragraph({
    Title = "Complete Features List",
    Desc = "━━━━━━━━━━━━━━━━━━━━━━\n" ..
           "【 SURVIVOR FEATURES 】\n" ..
           "• No Skillcheck - Auto perfect skillcheck\n" ..
           "• Bypass Gate - Walk through gates\n" ..
           "• Auto Lever - Auto pull exit lever\n" ..
           "• Auto Heal (Perfect/Neutral) - Auto healing\n" ..
           "• Auto Generator (Perfect/Neutral) - Auto repair\n" ..
           "• Auto Parry - Auto parry killer attacks\n" ..
           "• Auto Shoot - Auto shoot with ranged weapons\n" ..
           "━━━━━━━━━━━━━━━━━━━━━━\n" ..
           "【 KILLER FEATURES 】\n" ..
           "• Kill All - Kill all survivors (Risk ban!)\n" ..
           "• Auto Attack - Auto attack nearby survivors\n" ..
           "• No Flashlight - Remove blind effect\n" ..
           "• The Veil Aimbot (Normal/Charge)\n" ..
           "━━━━━━━━━━━━━━━━━━━━━━\n" ..
           "【 OTHER FEATURES 】\n" ..
           "• Walk Speed + Noclip + God Mode\n" ..
           "• No Fall + Anti Stun + MoonWalk\n" ..
           "• Anti AFK + ESP System\n" ..
           "• Fullbright + Time of Day + Custom FOV\n" ..
           "• Teleport System",
})

-- Social Media Section
local SocialSection = InfoTab:Section({
    Title = "Social Media & Support",
    Box = true,
    BoxBorder = true,
    Icon = "users",
    Opened = true
})

SocialSection:Paragraph({
    Title = "Follow & Support",
    Desc = "• Discord: discord.gg/qC7DN73VZe\n• WhatsApp Channel: https://whatsapp.com/channel/0029VbBxCmiKgsNvPi1k5j3C\n• WhatsApp Group: https://chat.whatsapp.com/LGyajryoaB5BIZaZyQMUzW\n• Website: fayintz.my.id\n• Contact: wa.me/6285138872456",
})

SocialSection:Button({
    Title = "Copy All Links",
    Icon = "copy",
    Desc = "Copy all social media links to clipboard",
    Callback = function()
        if setclipboard then
            local allLinks = "Discord: https://discord.gg/qC7DN73VZe\nWhatsApp Channel: https://whatsapp.com/channel/0029VbBxCmiKgsNvPi1k5j3C\nWhatsApp Group: https://chat.whatsapp.com/LGyajryoaB5BIZaZyQMUzW\nWebsite: fayintz.my.id\nContact: wa.me/6285138872456"
            setclipboard(allLinks)
            WindUI:Notify({
                Title = "Copied!",
                Content = "All social media links copied to clipboard",
                Duration = 3,
                Icon = "check"
            })
        end
    end
})

-- Credits Section
local CreditsSection = InfoTab:Section({
    Title = "Credits & Partnership",
    Box = true,
    BoxBorder = true,
    Icon = "heart",
    Opened = true
})

CreditsSection:Paragraph({
    Title = "Special Thanks",
    Desc = "• WindUI Library\n• Roblox Community\n• All Script Contributors\n• Beta Testers",
})

CreditsSection:Divider()

CreditsSection:Paragraph({
    Title = "Partnership",
    Desc = "• KuramaMods\n• ReyHub\n• MarV\n• MizuKage\n• Sixsense",
})

---------------------------------------------------
--== UTILITY FUNCTIONS ==--
---------------------------------------------------
local function safeNotify(title, content, duration)
    WindUI:Notify({
        Title = title,
        Content = content,
        Duration = duration or 2,
        Icon = "info",
    })
end

local function alive(i)
    if not i then return false end
    local ok = pcall(function() return i.Parent end)
    return ok and i.Parent ~= nil
end

local function validPart(p) return p and alive(p) and p:IsA("BasePart") end
local function clamp(n,lo,hi) if n<lo then return lo elseif n>hi then return hi else return n end end
local function dist(a,b) return (a-b).Magnitude end

local function firstBasePart(inst)
    if not alive(inst) then return nil end
    if inst:IsA("BasePart") then return inst end
    if inst:IsA("Model") then
        if inst.PrimaryPart and inst.PrimaryPart:IsA("BasePart") and alive(inst.PrimaryPart) then return inst.PrimaryPart end
        local p = inst:FindFirstChildWhichIsA("BasePart", true)
        if validPart(p) then return p end
    end
    if inst:IsA("Tool") then
        local h = inst:FindFirstChild("Handle") or inst:FindFirstChildWhichIsA("BasePart")
        if validPart(h) then return h end
    end
    return nil
end

---------------------------------------------------
--== FEATURE STATES (LENGKAP) ==--
---------------------------------------------------
local featureStates = {
    -- Player
    WalkSpeed = false,
    WalkSpeedValue = 16,
    Noclip = false,
    AntiAFK = false,
    GodMode = false,
    NoFall = false,
    AntiStun = false,
    MoonWalk = false,
    
    -- Survivor
    NoSkillcheck = false,
    BypassGate = false,
    AutoLever = false,
    AutoHealPerfect = false,
    AutoHealNeutral = false,
    AutoGeneratorPerfect = false,
    AutoGeneratorNeutral = false,
    AutoParry = false,
    AutoShoot = false,
    
    -- Killer
    KillAll = false,
    AutoAttack = false,
    NoFlashlight = false,
    
    -- The Veil Aimbot
    VeilAimbotEnabled = false,
    VeilAimbotChargeEnabled = false,
    VeilToughWall = true,
    VeilMinPitch = -1,
    VeilMaxPitch = 30,
    
    -- ESP Settings
    ESPFillTransparency = 0.7,
    ESPOutlineTransparency = 0,
    ESPTextSize = 14,
    
    -- Player ESP
    SurvivorESP = false,
    KillerESP = false,
    Nametags = false,
    DistanceESP = false,
    SurvivorColor = Color3.fromRGB(0, 255, 0),
    KillerColor = Color3.fromRGB(255, 0, 0),
    SurvivorItemsESP = false,
    SurvivorItemsColor = Color3.fromRGB(0, 170, 255),
    
    -- World ESP
    GeneratorESP = false,
    HookESP = false,
    GateESP = false,
    WindowESP = false,
    PalletESP = false,
    GeneratorColor = Color3.fromRGB(0, 170, 255),
    HookColor = Color3.fromRGB(255, 0, 0),
    GateColor = Color3.fromRGB(255, 225, 0),
    WindowColor = Color3.fromRGB(255, 255, 255),
    PalletColor = Color3.fromRGB(255, 140, 0),
    
    -- Visual
    FullBright = false,
    TimeOfDay = Lighting.ClockTime,
    FOVEnabled = false,
    FOVValue = 95,
    
    -- Aimbot
    AimbotEnabled = false,
    AimbotTeamCheck = false,
    AimbotShowFOV = false,
    AimbotFOVRadius = 50,
    AimbotPart = "Head",
    AimbotFOVThickness = 2,
    AimbotFOVTransparency = 0.4,
}

---------------------------------------------------
--== STORE ORIGINAL LIGHTING ==--
---------------------------------------------------
local originalLighting = {
    Brightness = Lighting.Brightness,
    FogEnd = Lighting.FogEnd,
    FogStart = Lighting.FogStart,
    GlobalShadows = Lighting.GlobalShadows,
    ClockTime = Lighting.ClockTime,
    Ambient = Lighting.Ambient,
    OutdoorAmbient = Lighting.OutdoorAmbient,
}

---------------------------------------------------
--== SPEED SYSTEM ==--
---------------------------------------------------
local speedHumanoid = nil
local speedConnChanged, speedConnAncestry = nil, nil
local speedBound = false

local function setWalkSpeed(h, v)
    if h and h.Parent then
        pcall(function() h.WalkSpeed = v end)
    end
end

local function bindSpeedLoop()
    if speedBound then return end
    speedBound = true
    RunService:BindToRenderStep("VD_SpeedEnforcer", 300, function()
        if not speedHumanoid or not speedHumanoid.Parent then return end
        if featureStates.WalkSpeed and speedHumanoid.WalkSpeed ~= featureStates.WalkSpeedValue then
            setWalkSpeed(speedHumanoid, featureStates.WalkSpeedValue)
        end
    end)
end

local function unbindSpeedLoop()
    if speedBound then
        speedBound = false
        pcall(function() RunService:UnbindFromRenderStep("VD_SpeedEnforcer") end)
    end
end

local function hookHumanoid(h)
    if speedConnChanged then speedConnChanged:Disconnect() speedConnChanged=nil end
    if speedConnAncestry then speedConnAncestry:Disconnect() speedConnAncestry=nil end
    speedHumanoid = h
    if featureStates.WalkSpeed then
        setWalkSpeed(h, featureStates.WalkSpeedValue)
        bindSpeedLoop()
    end
    speedConnChanged = h:GetPropertyChangedSignal("WalkSpeed"):Connect(function()
        if h.Parent and featureStates.WalkSpeed and h.WalkSpeed ~= featureStates.WalkSpeedValue then
            setWalkSpeed(h, featureStates.WalkSpeedValue)
        end
    end)
    speedConnAncestry = h.AncestryChanged:Connect(function(_, parent)
        if not parent then
            unbindSpeedLoop()
            speedHumanoid = nil
        end
    end)
end

local function onCharacterAdded(char)
    local h = char:WaitForChild("Humanoid", 10) or char:FindFirstChildOfClass("Humanoid")
    if h then hookHumanoid(h) end
    char.ChildAdded:Connect(function(ch) if ch:IsA("Humanoid") then hookHumanoid(ch) end end)
end

---------------------------------------------------
--== NOCLIP SYSTEM ==--
---------------------------------------------------
local noclipConn = nil

local function setNoclip(state)
    if state and not noclipConn then
        featureStates.Noclip = true
        noclipConn = RunService.Stepped:Connect(function()
            local char = LocalPlayer.Character
            if char then
                for _, part in pairs(char:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
            end
        end)
    elseif not state and noclipConn then
        featureStates.Noclip = false
        noclipConn:Disconnect()
        noclipConn = nil
        local char = LocalPlayer.Character
        if char then
            for _, part in pairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = true
                end
            end
        end
    end
end

---------------------------------------------------
--== ANTI AFK SYSTEM ==--
---------------------------------------------------
local antiAFKConn = nil

local function startAntiAFK()
    antiAFKConn = LocalPlayer.Idled:Connect(function()
        VirtualUser:Button2Down(Vector2.new(0,0), Workspace.CurrentCamera.CFrame)
        task.wait(1)
        VirtualUser:Button2Up(Vector2.new(0,0), Workspace.CurrentCamera.CFrame)
    end)
end

local function stopAntiAFK()
    if antiAFKConn then
        antiAFKConn:Disconnect()
        antiAFKConn = nil
    end
end

---------------------------------------------------
--== GOD MODE SYSTEM ==--
---------------------------------------------------
local godModeEnabled = false
local godModeConnection = nil
local characterAddedConnection = nil

local function enableGodMode()
    godModeEnabled = true
    local function refreshGodMode()
        local char = LocalPlayer.Character
        if not char then return end
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.Health = hum.MaxHealth
            if hum.MaxHealth < 100 then hum.MaxHealth = 100 end
            hum.BreakJointsOnDeath = false
        end
    end
    
    refreshGodMode()
    characterAddedConnection = LocalPlayer.CharacterAdded:Connect(refreshGodMode)
    godModeConnection = RunService.Heartbeat:Connect(refreshGodMode)
end

local function disableGodMode()
    godModeEnabled = false
    if godModeConnection then godModeConnection:Disconnect() godModeConnection = nil end
    if characterAddedConnection then characterAddedConnection:Disconnect() characterAddedConnection = nil end
end

---------------------------------------------------
--== NO FALL SYSTEM (FIXED) ==--
---------------------------------------------------
local FallRemote = nil
pcall(function()
    FallRemote = ReplicatedStorage:FindFirstChild("Remotes") and 
                 ReplicatedStorage.Remotes:FindFirstChild("Mechanics") and 
                 ReplicatedStorage.Remotes.Mechanics:FindFirstChild("Fall")
end)

local NoFallEnabled = false
local NoFallMT = nil
local NoFallOriginalNamecall = nil

local function setupNoFall()
    if NoFallMT then return end
    if not FallRemote then return end
    
    local success, mt = pcall(getrawmetatable, game)
    if not success then return end
    
    NoFallMT = mt
    NoFallOriginalNamecall = NoFallMT.__namecall
    setreadonly(NoFallMT, false)
    
    NoFallMT.__namecall = newcclosure(function(self, ...)
        local method = getnamecallmethod()
        if NoFallEnabled and self == FallRemote and method == "FireServer" then
            return nil
        end
        return NoFallOriginalNamecall(self, ...)
    end)
    
    setreadonly(NoFallMT, true)
end

local function enableNoFall()
    NoFallEnabled = true
    featureStates.NoFall = true
    setupNoFall()
end

local function disableNoFall()
    NoFallEnabled = false
    featureStates.NoFall = false
end

-- =========================================================
-- NO SKILLCHECK SYSTEM (DIPERBAIKI)
-- =========================================================
local noSkillcheckEnabled = false
local originalNamecall = nil
local hookedMetatable = false

local function setupNoSkillcheck()
    if noSkillcheckEnabled then return end
    noSkillcheckEnabled = true
    
    local success, mt = pcall(getrawmetatable, game)
    if not success then
        safeNotify("No Skillcheck", "Failed to get metatable", 3)
        return
    end
    
    originalNamecall = mt.__namecall
    
    setreadonly(mt, false)
    mt.__namecall = newcclosure(function(self, ...)
        local args = {...}
        local method = getnamecallmethod()
        
        if noSkillcheckEnabled and method == "FireServer" then
            local selfName = tostring(self):lower()
            
            if selfName:find("skill") or selfName:find("check") or 
               selfName:find("healing") or selfName:find("generator") then
               
                if args[1] and type(args[1]) == "string" then
                    args[1] = "success"
                end
                if args[2] then
                    args[2] = 1 -- Perfect score
                end
            end
        end
        return originalNamecall(self, unpack(args))
    end)
    setreadonly(mt, true)
    hookedMetatable = true
end

local function disableNoSkillcheck()
    if not noSkillcheckEnabled then return end
    noSkillcheckEnabled = false
    if hookedMetatable then
        local success, mt = pcall(getrawmetatable, game)
        if success and mt and originalNamecall then
            setreadonly(mt, false)
            mt.__namecall = originalNamecall
            setreadonly(mt, true)
        end
        hookedMetatable = false
    end
end

---------------------------------------------------
--== BYPASS GATE SYSTEM ==--
---------------------------------------------------
local function getMapFolders()
    local folders = {}
    local mainMap = Workspace:FindFirstChild("Map")
    if not mainMap then return folders end
    table.insert(folders, mainMap)
    
    local rooftop = mainMap:FindFirstChild("Rooftop")
    if rooftop then 
        table.insert(folders, rooftop)
        local rooftopModel = rooftop:FindFirstChild("Model")
        if rooftopModel then table.insert(folders, rooftopModel) end
    end
    
    local maze2 = mainMap:FindFirstChild("Maze2")
    if maze2 then table.insert(folders, maze2) end
    
    local model = mainMap:FindFirstChild("Model")
    if model then table.insert(folders, model) end
    
    local hooks = mainMap:FindFirstChild("Hooks")
    if hooks then table.insert(folders, hooks) end
    
    local pallets = mainMap:FindFirstChild("Pallets")
    if pallets then table.insert(folders, pallets) end
    
    local vaults = mainMap:FindFirstChild("Vaults")
    if vaults then table.insert(folders, vaults) end
    
    local gens = mainMap:FindFirstChild("Gens")
    if gens then table.insert(folders, gens) end
    
    return folders
end

local function gatherGates()
    local gates = {}
    for _, folder in pairs(getMapFolders()) do
        for _, gate in pairs(folder:GetChildren()) do
            if gate.Name == "Gate" then table.insert(gates, gate) end
        end
    end
    return gates
end

local function setBypassGate(state)
    featureStates.BypassGate = state
    local gates = gatherGates()
    for _, gate in pairs(gates) do
        local leftGate = gate:FindFirstChild("LeftGate")
        local rightGate = gate:FindFirstChild("RightGate")
        local leftEnd = gate:FindFirstChild("LeftGate-end")
        local rightEnd = gate:FindFirstChild("RightGate-end")
        local box = gate:FindFirstChild("Box")
        
        if state then
            if leftGate then leftGate.Transparency = 1 leftGate.CanCollide = false end
            if rightGate then rightGate.Transparency = 1 rightGate.CanCollide = false end
            if leftEnd then leftEnd.Transparency = 0 leftEnd.CanCollide = true end
            if rightEnd then rightEnd.Transparency = 0 rightEnd.CanCollide = true end
            if box then box.CanCollide = false end
        else
            if leftGate then leftGate.Transparency = 0 leftGate.CanCollide = true end
            if rightGate then rightGate.Transparency = 0 rightGate.CanCollide = true end
            if leftEnd then leftEnd.Transparency = 1 leftEnd.CanCollide = true end
            if rightEnd then rightEnd.Transparency = 1 rightEnd.CanCollide = true end
            if box then box.CanCollide = true end
        end
    end
end

---------------------------------------------------
--== AUTO LEVER SYSTEM ==--
---------------------------------------------------
local autoLeverRunning = false

local function startAutoLever()
    autoLeverRunning = true
    
    local leverRemote = nil
    pcall(function()
        leverRemote = ReplicatedStorage:FindFirstChild("Remotes") and
                      ReplicatedStorage.Remotes:FindFirstChild("Exit") and
                      ReplicatedStorage.Remotes.Exit:FindFirstChild("LeverEvent")
    end)
    
    task.spawn(function()
        local isTouching = false
        local lastPosition = nil
        
        UserInputService.TouchStarted:Connect(function() isTouching = true end)
        UserInputService.TouchEnded:Connect(function() isTouching = false end)
        
        while autoLeverRunning and featureStates.AutoLever do
            task.wait(0.15)
            local char = LocalPlayer.Character
            local root = char and char:FindFirstChild("HumanoidRootPart")
            local humanoid = char and char:FindFirstChildOfClass("Humanoid")
            
            if root and humanoid then
                local nearestMain = nil
                local shortestDist = 20
                
                for _, folder in pairs(getMapFolders()) do
                    for _, gate in pairs(folder:GetChildren()) do
                        if gate.Name == "Gate" and gate:FindFirstChild("ExitLever") then
                            local main = gate.ExitLever:FindFirstChild("Main")
                            if main and main:IsA("BasePart") then
                                local d = (root.Position - main.Position).Magnitude
                                if d < shortestDist then
                                    shortestDist = d
                                    nearestMain = main
                                end
                            end
                        end
                    end
                end
                
                local moved = lastPosition and (root.Position - lastPosition).Magnitude > 0.5
                local tryingToMove = false
                
                if UserInputService.KeyboardEnabled then
                    local keys = {Enum.KeyCode.W, Enum.KeyCode.A, Enum.KeyCode.S, Enum.KeyCode.D, Enum.KeyCode.Space}
                    for _, key in ipairs(keys) do
                        if UserInputService:IsKeyDown(key) then
                            tryingToMove = true
                            break
                        end
                    end
                end
                if UserInputService.TouchEnabled and isTouching then tryingToMove = true end
                
                if (moved or tryingToMove) and nearestMain and leverRemote then
                    pcall(function() leverRemote:FireServer(nearestMain, false) end)
                elseif nearestMain and shortestDist <= 10 and leverRemote then
                    pcall(function() leverRemote:FireServer(nearestMain, true) end)
                end
                lastPosition = root.Position
            end
        end
    end)
end

local function stopAutoLever()
    autoLeverRunning = false
end

---------------------------------------------------
--== AUTO HEAL SYSTEM ==--
---------------------------------------------------
local autoHealPerfectRunning = false
local autoHealNeutralRunning = false

local function startAutoHealPerfect()
    autoHealPerfectRunning = true
    
    local healRemote = nil
    pcall(function()
        healRemote = ReplicatedStorage:FindFirstChild("Remotes") and
                     ReplicatedStorage.Remotes:FindFirstChild("Healing") and
                     ReplicatedStorage.Remotes.Healing:FindFirstChild("SkillCheckResultEvent")
    end)
    
    task.spawn(function()
        local playerGui = LocalPlayer:WaitForChild("PlayerGui")
        local lastHealTarget = nil
        
        local function getHealth(plr)
            if not plr.Character then return 100 end
            local hum = plr.Character:FindFirstChild("Humanoid")
            return hum and hum.Health or 100
        end
        
        while autoHealPerfectRunning and featureStates.AutoHealPerfect do
            task.wait(0.15)
            local char = LocalPlayer.Character
            local root = char and char:FindFirstChild("HumanoidRootPart")
            local hum = char and char:FindFirstChild("Humanoid")
            
            if root and hum then
                local closest = nil
                local closestDist = 8
                
                for _, plr in ipairs(Players:GetPlayers()) do
                    if plr ~= LocalPlayer and plr.Character then
                        local hrp = plr.Character:FindFirstChild("HumanoidRootPart")
                        if hrp and getHealth(plr) <= 60 and getHealth(plr) > 0 then
                            local d = (root.Position - hrp.Position).Magnitude
                            if d < closestDist then
                                closest = plr
                                closestDist = d
                            end
                        end
                    end
                end
                
                if not lastHealTarget and closest then lastHealTarget = closest end
                if hum.MoveDirection.Magnitude > 0.05 then lastHealTarget = nil end
                
                local gui = playerGui:FindFirstChild("SkillCheckPromptGui")
                if gui then
                    local check = gui:FindFirstChild("Check")
                    if check and check.Visible and lastHealTarget and healRemote then
                        if getHealth(lastHealTarget) <= 60 then
                            pcall(function() healRemote:FireServer("success", 1, lastHealTarget.Character) end)
                            check.Visible = false
                        end
                    end
                end
            end
        end
    end)
end

local function startAutoHealNeutral()
    autoHealNeutralRunning = true
    
    local healRemote = nil
    pcall(function()
        healRemote = ReplicatedStorage:FindFirstChild("Remotes") and
                     ReplicatedStorage.Remotes:FindFirstChild("Healing") and
                     ReplicatedStorage.Remotes.Healing:FindFirstChild("SkillCheckResultEvent")
    end)
    
    task.spawn(function()
        local playerGui = LocalPlayer:WaitForChild("PlayerGui")
        local lastHealTarget = nil
        
        local function getHealth(plr)
            if not plr.Character then return 100 end
            local hum = plr.Character:FindFirstChild("Humanoid")
            return hum and hum.Health or 100
        end
        
        while autoHealNeutralRunning and featureStates.AutoHealNeutral do
            task.wait(0.15)
            local char = LocalPlayer.Character
            local root = char and char:FindFirstChild("HumanoidRootPart")
            local hum = char and char:FindFirstChild("Humanoid")
            
            if root and hum then
                local closest = nil
                local closestDist = 8
                
                for _, plr in ipairs(Players:GetPlayers()) do
                    if plr ~= LocalPlayer and plr.Character then
                        local hrp = plr.Character:FindFirstChild("HumanoidRootPart")
                        if hrp and getHealth(plr) <= 60 and getHealth(plr) > 0 then
                            local d = (root.Position - hrp.Position).Magnitude
                            if d < closestDist then
                                closest = plr
                                closestDist = d
                            end
                        end
                    end
                end
                
                if not lastHealTarget and closest then lastHealTarget = closest end
                if hum.MoveDirection.Magnitude > 0.05 then lastHealTarget = nil end
                
                local gui = playerGui:FindFirstChild("SkillCheckPromptGui")
                if gui then
                    local check = gui:FindFirstChild("Check")
                    if check and check.Visible and lastHealTarget and healRemote then
                        if getHealth(lastHealTarget) <= 60 then
                            pcall(function() healRemote:FireServer("neutral", 0, lastHealTarget.Character) end)
                            check.Visible = false
                        end
                    end
                end
            end
        end
    end)
end

---------------------------------------------------
--== AUTO GENERATOR SYSTEM ==--
---------------------------------------------------
local autoGeneratorPerfectRunning = false
local autoGeneratorNeutralRunning = false

local function getFolderGenerator()
    local generators = {}
    local map = Workspace:FindFirstChild("Map")
    if map then
        local function scanFolders(parent)
            for _, child in ipairs(parent:GetChildren()) do
                if child.Name == "Generator" and child:IsA("Model") then
                    table.insert(generators, child)
                elseif child:IsA("Model") then
                    scanFolders(child)
                end
            end
        end
        scanFolders(map)
    end
    if #generators == 0 then
        for _, descendant in ipairs(Workspace:GetDescendants()) do
            if descendant.Name == "Generator" and descendant:IsA("Model") then
                table.insert(generators, descendant)
            end
        end
    end
    return generators
end

local function startAutoGeneratorPerfect()
    autoGeneratorPerfectRunning = true
    
    local skillRemote = nil
    local repairRemote = nil
    pcall(function()
        local gen = ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("Generator")
        if gen then
            skillRemote = gen:FindFirstChild("SkillCheckResultEvent")
            repairRemote = gen:FindFirstChild("RepairEvent")
        end
    end)
    
    task.spawn(function()
        local playerGui = LocalPlayer:WaitForChild("PlayerGui")
        local lastGenPoint = nil
        local lastGenModel = nil
        
        while autoGeneratorPerfectRunning and featureStates.AutoGeneratorPerfect do
            task.wait(0.15)
            local char = LocalPlayer.Character
            local root = char and char:FindFirstChild("HumanoidRootPart")
            local hum = char and char:FindFirstChild("Humanoid")
            
            if root and hum then
                local generators = getFolderGenerator()
                local closestGen, closestPoint, closestDist = nil, nil, 10
                
                for _, gen in ipairs(generators) do
                    for i = 1, 4 do
                        local point = gen:FindFirstChild("GeneratorPoint" .. i)
                        if point and point:IsA("BasePart") then
                            local d = (root.Position - point.Position).Magnitude
                            if d < closestDist then
                                closestDist = d
                                closestGen = gen
                                closestPoint = point
                            end
                        end
                    end
                end
                
                if not lastGenPoint and closestPoint and closestDist < 6 then
                    lastGenModel = closestGen
                    lastGenPoint = closestPoint
                end
                
                if hum.MoveDirection.Magnitude > 0.05 then
                    if lastGenPoint and repairRemote then
                        pcall(function() repairRemote:FireServer(lastGenPoint, false) end)
                        task.wait(0.2)
                        lastGenPoint = nil
                        lastGenModel = nil
                    end
                end
                
                local gui = playerGui:FindFirstChild("SkillCheckPromptGui")
                if gui then
                    local check = gui:FindFirstChild("Check")
                    if check and check.Visible and lastGenPoint and skillRemote then
                        local stillClose = false
                        if lastGenPoint and root then
                            local d = (root.Position - lastGenPoint.Position).Magnitude
                            if d < 6 then stillClose = true end
                        end
                        if stillClose and lastGenModel and lastGenPoint then
                            pcall(function() skillRemote:FireServer("success", 1, lastGenModel, lastGenPoint) end)
                            check.Visible = false
                        end
                    end
                end
            end
        end
    end)
end

local function startAutoGeneratorNeutral()
    autoGeneratorNeutralRunning = true
    
    local skillRemote = nil
    local repairRemote = nil
    pcall(function()
        local gen = ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("Generator")
        if gen then
            skillRemote = gen:FindFirstChild("SkillCheckResultEvent")
            repairRemote = gen:FindFirstChild("RepairEvent")
        end
    end)
    
    task.spawn(function()
        local playerGui = LocalPlayer:WaitForChild("PlayerGui")
        local lastGenPoint = nil
        local lastGenModel = nil
        
        while autoGeneratorNeutralRunning and featureStates.AutoGeneratorNeutral do
            task.wait(0.15)
            local char = LocalPlayer.Character
            local root = char and char:FindFirstChild("HumanoidRootPart")
            local hum = char and char:FindFirstChild("Humanoid")
            
            if root and hum then
                local generators = getFolderGenerator()
                local closestGen, closestPoint, closestDist = nil, nil, 10
                
                for _, gen in ipairs(generators) do
                    for i = 1, 4 do
                        local point = gen:FindFirstChild("GeneratorPoint" .. i)
                        if point and point:IsA("BasePart") then
                            local d = (root.Position - point.Position).Magnitude
                            if d < closestDist then
                                closestDist = d
                                closestGen = gen
                                closestPoint = point
                            end
                        end
                    end
                end
                
                if not lastGenPoint and closestPoint and closestDist < 6 then
                    lastGenModel = closestGen
                    lastGenPoint = closestPoint
                end
                
                if hum.MoveDirection.Magnitude > 0.05 then
                    if lastGenPoint and repairRemote then
                        pcall(function() repairRemote:FireServer(lastGenPoint, false) end)
                        task.wait(0.2)
                        lastGenPoint = nil
                        lastGenModel = nil
                    end
                end
                
                local gui = playerGui:FindFirstChild("SkillCheckPromptGui")
                if gui then
                    local check = gui:FindFirstChild("Check")
                    if check and check.Visible and lastGenPoint and skillRemote then
                        local stillClose = false
                        if lastGenPoint and root then
                            local d = (root.Position - lastGenPoint.Position).Magnitude
                            if d < 6 then stillClose = true end
                        end
                        if stillClose and lastGenModel and lastGenPoint then
                            pcall(function() skillRemote:FireServer("neutral", 0, lastGenModel, lastGenPoint) end)
                            check.Visible = false
                        end
                    end
                end
            end
        end
    end)
end

---------------------------------------------------
--== AUTO PARRY SYSTEM (FIXED) ==--
---------------------------------------------------
local autoParryRunning = false
local lastParryTime = 0
local PARRY_COOLDOWN = 0.5
local PARRY_RANGE = 20

local function isKiller(player)
    if not player.Character then return false end
    return player.Character:FindFirstChild("Weapon") ~= nil
end

local function getParryRemote()
    local success, remotes = pcall(function() return ReplicatedStorage:FindFirstChild("Remotes") end)
    if not success or not remotes then return nil end
    
    local items = remotes:FindFirstChild("Items")
    if items then
        local dagger = items:FindFirstChild("Parrying Dagger")
        if dagger then
            local parry = dagger:FindFirstChild("parry")
            if parry then return parry end
        end
    end
    
    local parryFolder = remotes:FindFirstChild("Parry")
    if parryFolder then
        local parryEvent = parryFolder:FindFirstChild("ParryEvent")
        if parryEvent then return parryEvent end
    end
    
    local combat = remotes:FindFirstChild("Combat")
    if combat then
        local parry = combat:FindFirstChild("Parry")
        if parry then return parry end
    end
    
    return nil
end

local function hasParryItem()
    local char = LocalPlayer.Character
    if not char then return false end
    for _, item in pairs(char:GetChildren()) do
        local name = item.Name:lower()
        if name:find("parry") or name:find("dagger") then
            return true
        end
    end
    return false
end

local function startAutoParry()
    autoParryRunning = true
    local parryRemote = getParryRemote()
    
    task.spawn(function()
        while autoParryRunning and featureStates.AutoParry do
            task.wait(0.05)
            local char = LocalPlayer.Character
            local root = char and char:FindFirstChild("HumanoidRootPart")
            
            if root and hasParryItem() then
                local now = tick()
                if now - lastParryTime >= PARRY_COOLDOWN then
                    for _, plr in ipairs(Players:GetPlayers()) do
                        if plr ~= LocalPlayer and isKiller(plr) then
                            local targetRoot = plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")
                            if targetRoot then
                                local d = (root.Position - targetRoot.Position).Magnitude
                                if d <= PARRY_RANGE then
                                    if parryRemote then
                                        pcall(function() parryRemote:FireServer() end)
                                        lastParryTime = now
                                    end
                                    break
                                end
                            end
                        end
                    end
                end
            end
        end
    end)
end

local function stopAutoParry()
    autoParryRunning = false
end

---------------------------------------------------
--== AUTO SHOOT SYSTEM ==--
---------------------------------------------------
local autoShootRunning = false
local lastShootTime = 0
local SHOOT_COOLDOWN = 0.3
local SHOOT_RANGE = 20

local function getShootRemote()
    local success, remotes = pcall(function() return ReplicatedStorage:FindFirstChild("Remotes") end)
    if not success or not remotes then return nil end
    
    local items = remotes:FindFirstChild("Items")
    if items then
        for _, item in ipairs(items:GetChildren()) do
            local name = item.Name:lower()
            if name:find("gun") or name:find("pistol") or name:find("ranged") then
                local shoot = item:FindFirstChild("shoot") or item:FindFirstChild("fire")
                if shoot then return shoot end
            end
        end
    end
    return nil
end

local function hasRangedWeapon()
    local char = LocalPlayer.Character
    if not char then return false end
    for _, item in pairs(char:GetChildren()) do
        local name = item.Name:lower()
        if name:find("gun") or name:find("pistol") or name:find("ranged") or name:find("shoot") then
            return true
        end
    end
    return false
end

local function startAutoShoot()
    autoShootRunning = true
    local shootRemote = getShootRemote()
    
    task.spawn(function()
        while autoShootRunning and featureStates.AutoShoot do
            task.wait(0.05)
            local char = LocalPlayer.Character
            local root = char and char:FindFirstChild("HumanoidRootPart")
            
            if root and hasRangedWeapon() then
                local now = tick()
                if now - lastShootTime >= SHOOT_COOLDOWN then
                    for _, plr in ipairs(Players:GetPlayers()) do
                        if plr ~= LocalPlayer and isKiller(plr) then
                            local targetRoot = plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")
                            if targetRoot then
                                local d = (root.Position - targetRoot.Position).Magnitude
                                if d <= SHOOT_RANGE then
                                    if shootRemote then
                                        pcall(function() shootRemote:FireServer() end)
                                        lastShootTime = now
                                    end
                                    break
                                end
                            end
                        end
                    end
                end
            end
        end
    end)
end

local function stopAutoShoot()
    autoShootRunning = false
end

---------------------------------------------------
--== KILLER SYSTEMS ==--
---------------------------------------------------
local killAllRunning = false
local autoAttackRunning = false
local noFlashlightRunning = false

local function startKillAll()
    killAllRunning = true
    
    local attackRemote = nil
    pcall(function()
        local attacks = ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("Attacks")
        if attacks then
            attackRemote = attacks:FindFirstChild("BasicAttack")
        end
    end)
    
    task.spawn(function()
        local startCFrame = nil
        
        while killAllRunning and featureStates.KillAll do
            local char = LocalPlayer.Character
            local root = char and char:FindFirstChild("HumanoidRootPart")
            if root then
                if not startCFrame then startCFrame = root.CFrame end
                
                for _, plr in ipairs(Players:GetPlayers()) do
                    if not killAllRunning then break end
                    if plr ~= LocalPlayer and plr.Character then
                        local targetRoot = plr.Character:FindFirstChild("HumanoidRootPart")
                        local humanoid = plr.Character:FindFirstChildOfClass("Humanoid")
                        
                        if targetRoot and humanoid and humanoid.Health > 20 then
                            root.CFrame = targetRoot.CFrame * CFrame.new(0, 0, 2)
                            if attackRemote then
                                pcall(function() attackRemote:FireServer() end)
                            end
                            task.wait(0.15)
                        end
                    end
                end
                task.wait(0.2)
            else
                task.wait(0.2)
            end
        end
    end)
end

local function stopKillAll()
    killAllRunning = false
end

local function startAutoAttack()
    autoAttackRunning = true
    
    local attackRemote = nil
    pcall(function()
        local attacks = ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("Attacks")
        if attacks then
            attackRemote = attacks:FindFirstChild("BasicAttack")
        end
    end)
    
    task.spawn(function()
        while autoAttackRunning and featureStates.AutoAttack do
            local char = LocalPlayer.Character
            local root = char and char:FindFirstChild("HumanoidRootPart")
            if root then
                for _, plr in ipairs(Players:GetPlayers()) do
                    if plr ~= LocalPlayer and plr.Character then
                        local targetRoot = plr.Character:FindFirstChild("HumanoidRootPart")
                        local distToTarget = targetRoot and (root.Position - targetRoot.Position).Magnitude
                        if distToTarget and distToTarget <= 10 and attackRemote then
                            pcall(function() attackRemote:FireServer() end)
                            break
                        end
                    end
                end
            end
            task.wait(0.1)
        end
    end)
end

local function stopAutoAttack()
    autoAttackRunning = false
end

local function startNoFlashlight()
    noFlashlightRunning = true
    task.spawn(function()
        while noFlashlightRunning and featureStates.NoFlashlight do
            local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
            if playerGui then
                for _, descendant in pairs(playerGui:GetDescendants()) do
                    if descendant:IsA("GuiObject") and descendant.Name == "Blind" then
                        pcall(function() descendant:Destroy() end)
                    end
                end
            end
            task.wait(0.5)
        end
    end)
end

local function stopNoFlashlight()
    noFlashlightRunning = false
end

---------------------------------------------------
--== ANTI STUN SYSTEM ==--
---------------------------------------------------
local antiStunConnection = nil

local function toggleAntiStun(enabled)
    featureStates.AntiStun = enabled
    if enabled then
        if antiStunConnection then antiStunConnection:Disconnect() end
        antiStunConnection = RunService.Heartbeat:Connect(function()
            if not featureStates.AntiStun then
                if antiStunConnection then antiStunConnection:Disconnect() end
                antiStunConnection = nil
                return
            end
            local character = LocalPlayer.Character
            if character then
                local humanoid = character:FindFirstChildOfClass("Humanoid")
                if humanoid then
                    if humanoid.PlatformStand then humanoid.PlatformStand = false end
                    if humanoid.Sit then humanoid.Sit = false end
                    if humanoid:GetState() == Enum.HumanoidStateType.FallingDown or
                       humanoid:GetState() == Enum.HumanoidStateType.Ragdoll then
                        humanoid:ChangeState(Enum.HumanoidStateType.Running)
                    end
                end
            end
        end)
        safeNotify("AntiStun", "AntiStun activated", 3)
    else
        if antiStunConnection then
            antiStunConnection:Disconnect()
            antiStunConnection = nil
        end
        safeNotify("AntiStun", "AntiStun deactivated", 3)
    end
end

---------------------------------------------------
--== MOONWALK SYSTEM ==--
---------------------------------------------------
local moonwalkConn = nil

local function toggleMoonwalk(enable)
    featureStates.MoonWalk = enable
    if enable then
        if moonwalkConn then return end
        moonwalkConn = RunService.RenderStepped:Connect(function()
            local char = LocalPlayer.Character
            if not char then return end
            local humanoid = char:FindFirstChildOfClass("Humanoid")
            local root = char:FindFirstChild("HumanoidRootPart")
            if humanoid and root then
                humanoid.AutoRotate = false
                if humanoid.MoveDirection.Magnitude > 0 then
                    local dir = humanoid.MoveDirection
                    local targetLook = Vector3.new(-dir.X, 0, -dir.Z)
                    if targetLook.Magnitude > 0 then
                        root.CFrame = CFrame.lookAt(root.Position, root.Position + targetLook.Unit)
                    end
                end
            end
        end)
        safeNotify("MoonWalk", "MoonWalk activated", 3)
    else
        if moonwalkConn then
            moonwalkConn:Disconnect()
            moonwalkConn = nil
            local char = LocalPlayer.Character
            if char then
                local humanoid = char:FindFirstChildOfClass("Humanoid")
                if humanoid then humanoid.AutoRotate = true end
            end
        end
        safeNotify("MoonWalk", "MoonWalk deactivated", 3)
    end
end

---------------------------------------------------
--== THE VEIL AIMBOT SYSTEM ==--
---------------------------------------------------
local VeilAimbotEnabled = false
local VeilAimbotChargeEnabled = false
local VeilPredictionTime = 0.14
local VeilMinDistance = 1
local VeilMaxDistance = 250
local VeilMinPitch = -1
local VeilMaxPitch = 30
local VeilLowHPIgnore = 20
local VeilToughWall = true

local function VeilGetLocalRoot()
    local c = LocalPlayer.Character
    return c and c:FindFirstChild("HumanoidRootPart")
end

local function VeilHPOK(plr)
    local hum = plr.Character and plr.Character:FindFirstChild("Humanoid")
    return hum and hum.Health > VeilLowHPIgnore
end

local function VeilGetClosestInScreen()
    local closest = nil
    local minDist = math.huge
    local mouse = UserInputService:GetMouseLocation()
    
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character and VeilHPOK(plr) then
            local head = plr.Character:FindFirstChild("Head")
            if head then
                local pos, onScreen = Camera:WorldToViewportPoint(head.Position)
                if onScreen then
                    local dist = (Vector2.new(pos.X, pos.Y) - mouse).Magnitude
                    if dist < minDist then
                        minDist = dist
                        closest = plr
                    end
                end
            end
        end
    end
    return closest
end

local function VeilGetClosestByDistance()
    local root = VeilGetLocalRoot()
    if not root then return nil end
    local closest, distMin = nil, math.huge
    
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character and VeilHPOK(plr) then
            local r = plr.Character:FindFirstChild("HumanoidRootPart")
            if r then
                local d = (root.Position - r.Position).Magnitude
                if d < distMin then
                    distMin = d
                    closest = plr
                end
            end
        end
    end
    return closest, distMin
end

local function VeilCanSeeTarget(target)
    if VeilToughWall then return true end
    local head = target.Character and target.Character:FindFirstChild("Head")
    local root = VeilGetLocalRoot()
    if not head or not root then return false end
    
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Blacklist
    params.FilterDescendantsInstances = { LocalPlayer.Character or {}, target.Character }
    local result = workspace:Raycast(root.Position + Vector3.new(0, 2, 0), head.Position - root.Position, params)
    return not result
end

local function VeilGetAutoPitchMax(distance)
    if distance >= 190 and distance <= 300 then return 45.5
    elseif distance >= 150 and distance <= 185 then return 40.5
    elseif distance >= 90 and distance <= 145 then return 36.5
    else return 30.5 end
end

local function VeilGetPitchByDistance(dist)
    if dist < 1 then return 0.09
    elseif dist < 10 then return 0.90
    elseif dist < 20 then return 1.9
    elseif dist < 30 then return 2.9
    elseif dist < 40 then return 3.9
    elseif dist < 50 then return 4.9
    elseif dist < 60 then return 5.9
    elseif dist < 70 then return 6.9
    elseif dist < 80 then return 7.9
    elseif dist < 90 then return 8.9
    elseif dist < 100 then return 10.9
    elseif dist < 110 then return 11.9
    elseif dist < 120 then return 12.9
    elseif dist < 130 then return 13.9
    elseif dist < 140 then return 14.9
    elseif dist < 150 then return 15.9
    elseif dist < 160 then return 16.9
    elseif dist < 170 then return 17.9
    elseif dist < 180 then return 18.9
    elseif dist < 190 then return 20.3
    elseif dist < 200 then return 22.3
    else return 23.3 end
end

local function VeilAimAtNormal(target)
    if not target.Character then return end
    local head = target.Character:FindFirstChild("Head")
    local hrp = target.Character:FindFirstChild("HumanoidRootPart")
    local localRoot = VeilGetLocalRoot()
    if not head or not hrp or not localRoot then return end
    
    local predictedPos = head.Position + (hrp.Velocity * VeilPredictionTime)
    local distance = (localRoot.Position - predictedPos).Magnitude
    local autoPitchMax = VeilGetAutoPitchMax(distance)
    local alpha = math.clamp((distance - VeilMinDistance) / (VeilMaxDistance - VeilMinDistance), 0, 1)
    local pitch = VeilMinPitch + (autoPitchMax - VeilMinPitch) * alpha
    
    local dir = (predictedPos - Camera.CFrame.Position).Unit
    local yaw = math.atan2(dir.X, dir.Z)
    local pitchRad = math.rad(pitch)
    local look = Vector3.new(math.sin(yaw) * math.cos(pitchRad), math.sin(pitchRad), math.cos(yaw) * math.cos(pitchRad))
    Camera.CFrame = CFrame.new(Camera.CFrame.Position, Camera.CFrame.Position + look)
end

local function VeilAimAtCharge(target)
    if not target.Character then return end
    local head = target.Character:FindFirstChild("Head")
    local hrp = target.Character:FindFirstChild("HumanoidRootPart")
    local localRoot = VeilGetLocalRoot()
    if not head or not hrp or not localRoot then return end
    
    local predictedPos = head.Position + (hrp.Velocity * VeilPredictionTime)
    local dist = (predictedPos - Camera.CFrame.Position).Magnitude
    local pitch = VeilGetPitchByDistance(dist)
    
    local dir = (predictedPos - Camera.CFrame.Position).Unit
    local yaw = math.atan2(dir.X, dir.Z)
    local pitchRad = math.rad(pitch)
    local look = Vector3.new(math.sin(yaw) * math.cos(pitchRad), math.sin(pitchRad), math.cos(yaw) * math.cos(pitchRad))
    Camera.CFrame = CFrame.new(Camera.CFrame.Position, Camera.CFrame.Position + look)
end

---------------------------------------------------
--== AIMBOT SYSTEM (REGULAR) ==--
---------------------------------------------------
local fovGui = nil
local fovCircleFrame = nil

local function getAimPart(character, partName)
    if partName == "Head" then return character:FindFirstChild("Head") end
    if partName == "Torso" then return character:FindFirstChild("Torso") or character:FindFirstChild("UpperTorso") end
    if partName == "Left Arm" then return character:FindFirstChild("Left Arm") or character:FindFirstChild("LeftUpperArm") end
    if partName == "Right Arm" then return character:FindFirstChild("Right Arm") or character:FindFirstChild("RightUpperArm") end
    if partName == "Left Leg" then return character:FindFirstChild("Left Leg") or character:FindFirstChild("LeftUpperLeg") end
    if partName == "Right Leg" then return character:FindFirstChild("Right Leg") or character:FindFirstChild("RightUpperLeg") end
    if partName == "HumanoidRootPart" then return character:FindFirstChild("HumanoidRootPart") end
    return character:FindFirstChild("Head")
end

local function findBestTarget()
    local screenCenter = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
    local radius = featureStates.AimbotShowFOV and featureStates.AimbotFOVRadius or 25
    local bestTarget = nil
    local bestDist = radius
    local myRole = getRole(LocalPlayer)

    for _, pl in ipairs(Players:GetPlayers()) do
        if pl ~= LocalPlayer and pl.Character then
            if featureStates.AimbotTeamCheck then
                local targetRole = getRole(pl)
                if targetRole == myRole then end
            end
            local part = getAimPart(pl.Character, featureStates.AimbotPart)
            if part then
                local pos, onScreen = Camera:WorldToViewportPoint(part.Position)
                if onScreen then
                    local dist = (Vector2.new(pos.X, pos.Y) - screenCenter).Magnitude
                    if dist <= radius and dist < bestDist then
                        bestDist = dist
                        bestTarget = pl
                    end
                end
            end
        end
    end
    return bestTarget
end

local function aimAtTarget(target)
    local part = getAimPart(target.Character, featureStates.AimbotPart)
    if part then
        local camPos = Camera.CFrame.Position
        local targetPos = part.Position
        local direction = (targetPos - camPos).Unit
        Camera.CFrame = CFrame.lookAt(camPos, camPos + direction)
    end
end

local function aimbotStep()
    if featureStates.AimbotEnabled then
        local target = findBestTarget()
        if target then aimAtTarget(target) end
    end
end

local function destroyFOVCircle()
    if fovGui then
        pcall(function() fovGui:Destroy() end)
        fovGui = nil
        fovCircleFrame = nil
    end
end

local function createFOVCircle()
    if fovGui then return end
    local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
    if not playerGui then return end
    
    fovGui = Instance.new("ScreenGui")
    fovGui.Name = "FayintXCode_FOV"
    fovGui.ResetOnSpawn = false
    fovGui.IgnoreGuiInset = true
    fovGui.Parent = playerGui
    
    fovCircleFrame = Instance.new("Frame")
    fovCircleFrame.Name = "FOVCircle"
    fovCircleFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    fovCircleFrame.BackgroundTransparency = 1
    fovCircleFrame.BorderSizePixel = 0
    fovCircleFrame.Parent = fovGui
    
    local stroke = Instance.new("UIStroke")
    stroke.Name = "Stroke"
    stroke.LineJoinMode = Enum.LineJoinMode.Round
    stroke.Parent = fovCircleFrame
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(1, 0)
    corner.Parent = fovCircleFrame
end

local function updateFOVCircle()
    if not featureStates.AimbotEnabled or not featureStates.AimbotShowFOV then
        destroyFOVCircle()
        return
    end
    if not fovGui then createFOVCircle() end
    if not fovCircleFrame then return end
    
    local radius = featureStates.AimbotFOVRadius
    local diameter = radius * 2
    local viewportSize = Camera.ViewportSize
    
    fovCircleFrame.Size = UDim2.new(0, diameter, 0, diameter)
    fovCircleFrame.Position = UDim2.new(0, viewportSize.X / 2, 0, viewportSize.Y / 2)
    
    local stroke = fovCircleFrame:FindFirstChild("Stroke")
    if stroke then
        stroke.Thickness = featureStates.AimbotFOVThickness
        stroke.Color = Color3.fromRGB(255, 255, 255)
        stroke.Transparency = featureStates.AimbotFOVTransparency
    end
end

---------------------------------------------------
--== GET ROLE FUNCTION ==--
---------------------------------------------------
local function getRole(p)
    local tn = p.Team and p.Team.Name and p.Team.Name:lower() or ""
    if tn:find("killer") then return "Killer" end
    if tn:find("survivor") then return "Survivor" end
    return "Survivor"
end

---------------------------------------------------
--== ESP SYSTEM ==--
---------------------------------------------------
local espObjects = {}

local function removeESP(obj)
    if espObjects[obj] then
        if espObjects[obj].highlight then espObjects[obj].highlight:Destroy() end
        espObjects[obj] = nil
    end
end

local function createESP(obj, baseColor)
    if not obj or obj.Name == "Lobby" then return end
    if espObjects[obj] then
        if espObjects[obj].highlight then
            espObjects[obj].highlight.FillColor = baseColor
            espObjects[obj].highlight.OutlineColor = baseColor
        end
        return
    end
    
    local highlight = Instance.new("Highlight")
    highlight.Adornee = obj
    highlight.FillColor = baseColor
    highlight.FillTransparency = 0.9
    highlight.OutlineColor = baseColor
    highlight.OutlineTransparency = 0.1
    highlight.Parent = obj
    
    espObjects[obj] = {highlight = highlight, color = baseColor}
end

local function updateESP()
    if not (featureStates.SurvivorESP or featureStates.KillerESP) then return end
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local role = getRole(player)
            
            if role == "Survivor" and featureStates.SurvivorESP then
                createESP(player.Character, featureStates.SurvivorColor)
            elseif role == "Killer" and featureStates.KillerESP then
                createESP(player.Character, featureStates.KillerColor)
            else
                removeESP(player.Character)
            end
        end
    end
end

---------------------------------------------------
--== LIGHTING SYSTEMS ==--
---------------------------------------------------
local fbConn = nil

local function updateFullBright()
    if featureStates.FullBright then
        if not fbConn then
            fbConn = RunService.RenderStepped:Connect(function()
                Lighting.GlobalShadows = false
                Lighting.FogEnd = 100000
                Lighting.Brightness = 2
                Lighting.Ambient = Color3.fromRGB(255, 255, 255)
                Lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
            end)
        end
    else
        if fbConn then
            fbConn:Disconnect()
            fbConn = nil
            Lighting.GlobalShadows = originalLighting.GlobalShadows
            Lighting.FogEnd = originalLighting.FogEnd
            Lighting.Brightness = originalLighting.Brightness
            Lighting.Ambient = originalLighting.Ambient
            Lighting.OutdoorAmbient = originalLighting.OutdoorAmbient
        end
    end
end

local todActive = false

local function bindTimeLock()
    if featureStates.TimeOfDay then
        if not todActive then
            todActive = true
            RunService:BindToRenderStep("VD_TimeLock", 200, function()
                Lighting.ClockTime = featureStates.TimeOfDay
            end)
        end
    else
        if todActive then
            todActive = false
            RunService:UnbindFromRenderStep("VD_TimeLock")
            Lighting.ClockTime = originalLighting.ClockTime
        end
    end
end

local function applyFOV()
    if featureStates.FOVEnabled and Camera and Camera.FieldOfView ~= featureStates.FOVValue then
        Camera.FieldOfView = featureStates.FOVValue
    end
end

---------------------------------------------------
--== TELEPORT FUNCTIONS ==--
---------------------------------------------------
local function tpCFrame(cf)
    local char = LocalPlayer.Character
    if not (char and char.Parent) then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local was = featureStates.Noclip
    setNoclip(true)
    hrp.CFrame = cf
    task.delay(0.7, function() if not was then setNoclip(false) end end)
end

local function teleportToRandomSurvivor()
    local survivors = {}
    for _, pl in ipairs(Players:GetPlayers()) do
        if pl ~= LocalPlayer and getRole(pl) == "Survivor" then
            table.insert(survivors, pl)
        end
    end
    if #survivors > 0 then
        local randomSurvivor = survivors[math.random(1, #survivors)]
        local hrp = randomSurvivor.Character and randomSurvivor.Character:FindFirstChild("HumanoidRootPart")
        if hrp then
            tpCFrame(hrp.CFrame * CFrame.new(0, 0, -3) + Vector3.new(0, 3, 0))
            safeNotify("Teleport", "Teleported to: " .. randomSurvivor.Name, 3)
        end
    else
        safeNotify("Teleport", "No survivors found", 3)
    end
end

local function teleportToKiller()
    for _, pl in ipairs(Players:GetPlayers()) do
        if pl ~= LocalPlayer and getRole(pl) == "Killer" then
            local hrp = pl.Character and pl.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                tpCFrame(hrp.CFrame * CFrame.new(0, 0, -3) + Vector3.new(0, 3, 0))
                safeNotify("Teleport", "Teleported to Killer: " .. pl.Name, 3)
                return
            end
        end
    end
    safeNotify("Teleport", "No killer found", 3)
end

---------------------------------------------------
--== FIX CAMERA ==--
---------------------------------------------------
local function fixCamera()
    local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if humanoid then
        Camera.CameraType = Enum.CameraType.Custom
        Camera.CameraSubject = humanoid
        LocalPlayer.CameraMinZoomDistance = 0.5
        LocalPlayer.CameraMaxZoomDistance = 400
        LocalPlayer.CameraMode = Enum.CameraMode.Classic
        local head = character:FindFirstChild("Head")
        if head then head.Anchored = false end
        safeNotify("Camera", "Camera fixed to 3rd person", 3)
    end
end

---------------------------------------------------
--== ESP UPDATE LOOP ==--
---------------------------------------------------
task.spawn(function()
    while true do
        updateESP()
        task.wait(0.25)
    end
end)

---------------------------------------------------
--== AIMBOT LOOP ==--
---------------------------------------------------
task.spawn(function()
    while true do
        if featureStates.VeilAimbotEnabled then
            local target = VeilGetClosestInScreen()
            if target and VeilCanSeeTarget(target) then
                VeilAimAtNormal(target)
            end
        elseif featureStates.VeilAimbotChargeEnabled then
            local target = VeilGetClosestByDistance()
            if target and VeilCanSeeTarget(target) then
                VeilAimAtCharge(target)
            end
        end
        task.wait()
    end
end)

---------------------------------------------------
--== INITIALIZE CHARACTER ==--
---------------------------------------------------
if LocalPlayer.Character then
    onCharacterAdded(LocalPlayer.Character)
end
LocalPlayer.CharacterAdded:Connect(onCharacterAdded)

---------------------------------------------------
--== CAMERA CHANGE HANDLER ==--
---------------------------------------------------
workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
    task.wait(0.1)
    Camera = workspace.CurrentCamera
    if featureStates.FOVEnabled then applyFOV() end
end)

---------------------------------------------------
--== RENDER LOOP ==--
---------------------------------------------------
RunService.RenderStepped:Connect(function()
    if featureStates.FOVEnabled then applyFOV() end
    if featureStates.FullBright then updateFullBright() end
    if featureStates.TimeOfDay then bindTimeLock() end
    aimbotStep()
    updateFOVCircle()
end)

---------------------------------------------------
--== CLEANUP ON SCRIPT REMOVAL ==--
---------------------------------------------------
game:GetService("ScriptContext").DescendantRemoving:Connect(function(descendant)
    if descendant == script then
        disableNoSkillcheck()
        stopKillAll()
        stopAutoAttack()
        stopAutoLever()
        stopAutoParry()
        stopAutoShoot()
        disableGodMode()
        setNoclip(false)
        stopAntiAFK()
        disableNoFall()
        destroyFOVCircle()
    end
end)

---------------------------------------------------
--== SETUP NO FALL ==--
---------------------------------------------------
setupNoFall()

---------------------------------------------------
--== WORLD ESP SYSTEM (SEDERHANA) ==--
---------------------------------------------------
local worldLoopThread = nil
local worldReg = {Generator = {}, Hook = {}, Gate = {}, Window = {}, Palletwrong = {}}

local function clearChild(o, n)
    if o and alive(o) then
        local c = o:FindFirstChild(n)
        if c then pcall(function() c:Destroy() end) end
    end
end

local function clearHighlight(model)
    if model and model:FindFirstChild("VD_HL") then
        pcall(function() model.VD_HL:Destroy() end)
    end
end

local function ensureHighlight(model, fill, isPlayer)
    if not (model and model:IsA("Model") and alive(model)) then return end
    local hl = model:FindFirstChild("VD_HL")
    if not hl then
        local ok, obj = pcall(function()
            local h = Instance.new("Highlight")
            h.Name = "VD_HL"
            h.Adornee = model
            h.FillTransparency = 0.95
            h.OutlineTransparency = 0.3
            h.Parent = model
            return h
        end)
        if ok then hl = obj else return end
    end
    hl.FillColor = fill
    hl.OutlineColor = fill
    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
end

local function makeBillboard(text, color3)
    local g = Instance.new("BillboardGui")
    g.Name = "VD_Tag"
    g.AlwaysOnTop = true
    g.Size = UDim2.new(0, 200, 0, 20)
    g.StudsOffset = Vector3.new(0, 2.5, 0)
    g.MaxDistance = 0
    local l = Instance.new("TextLabel")
    l.Name = "Label"
    l.BackgroundTransparency = 1
    l.Size = UDim2.new(1, 0, 1, 0)
    l.Font = Enum.Font.GothamBold
    l.Text = text
    l.TextSize = featureStates.ESPTextSize
    l.TextColor3 = color3
    l.TextStrokeTransparency = 0.3
    l.TextStrokeColor3 = Color3.new(0,0,0)
    l.BorderSizePixel = 0
    l.Parent = g
    return g
end

local function startWorldLoop()
    if worldLoopThread then return end
    worldLoopThread = task.spawn(function()
        while featureStates.GeneratorESP or featureStates.HookESP or featureStates.GateESP or 
              featureStates.WindowESP or featureStates.PalletESP do
            task.wait(0.25)
            
            -- Scan for world objects
            local map = Workspace:FindFirstChild("Map")
            if map then
                for _, obj in ipairs(map:GetDescendants()) do
                    if obj:IsA("Model") then
                        local color = nil
                        local enabled = false
                        
                        if obj.Name == "Generator" and featureStates.GeneratorESP then
                            color = featureStates.GeneratorColor
                            enabled = true
                        elseif obj.Name == "Hook" and featureStates.HookESP then
                            color = featureStates.HookColor
                            enabled = true
                        elseif obj.Name == "Gate" and featureStates.GateESP then
                            color = featureStates.GateColor
                            enabled = true
                        elseif obj.Name == "Window" and featureStates.WindowESP then
                            color = featureStates.WindowColor
                            enabled = true
                        elseif obj.Name == "Palletwrong" and featureStates.PalletESP then
                            color = featureStates.PalletColor
                            enabled = true
                        end
                        
                        if enabled and color then
                            ensureHighlight(obj, color, false)
                            local part = firstBasePart(obj)
                            if part then
                                local bb = part:FindFirstChild("VD_Text")
                                if not bb then
                                    bb = makeBillboard(obj.Name, color)
                                    bb.Name = "VD_Text"
                                    bb.Adornee = part
                                    bb.Parent = part
                                end
                                local lbl = bb:FindFirstChild("Label")
                                if lbl then
                                    lbl.TextSize = featureStates.ESPTextSize
                                    lbl.TextColor3 = color
                                end
                            end
                        elseif not enabled and obj:FindFirstChild("VD_HL") then
                            clearHighlight(obj)
                            local part = firstBasePart(obj)
                            if part then clearChild(part, "VD_Text") end
                        end
                    end
                end
            end
        end
        worldLoopThread = nil
    end)
end

---------------------------------------------------
--== PLAYER TAB ==--
---------------------------------------------------
local MovementSection = PlayerTab:Section({ Title = "Movement", Box = true, BoxBorder = true, Icon = "activity", Opened = true })

MovementSection:Toggle({
    Title = "Walk Speed",
    Desc = "Enable custom walk speed",
    Default = false,
    Callback = function(state)
        featureStates.WalkSpeed = state
        if state and speedHumanoid then
            setWalkSpeed(speedHumanoid, featureStates.WalkSpeedValue)
            bindSpeedLoop()
        elseif not state and speedHumanoid then
            unbindSpeedLoop()
            setWalkSpeed(speedHumanoid, 16)
        end
    end
})

MovementSection:Slider({
    Title = "Walk Speed Value",
    Desc = "Set walk speed value",
    Step = 1,
    Value = {Min = 0, Max = 200, Default = featureStates.WalkSpeedValue},
    Callback = function(value)
        featureStates.WalkSpeedValue = value
        if featureStates.WalkSpeed and speedHumanoid then
            setWalkSpeed(speedHumanoid, value)
        end
    end
})

MovementSection:Toggle({
    Title = "Noclip",
    Desc = "Enable noclip mode (Walk through walls)",
    Default = false,
    Callback = function(state) setNoclip(state) end
})

MovementSection:Toggle({
    Title = "God Mode",
    Desc = "Auto heal, anti death",
    Default = false,
    Callback = function(state)
        featureStates.GodMode = state
        if state then enableGodMode() else disableGodMode() end
    end
})

MovementSection:Toggle({
    Title = "MoonWalk",
    Desc = "Enable moonwalk effect",
    Default = false,
    Callback = function(state) toggleMoonwalk(state) end
})

local UtilitySection = PlayerTab:Section({ Title = "Utilities", Box = true, BoxBorder = true, Icon = "settings", Opened = true })

UtilitySection:Toggle({
    Title = "Anti AFK",
    Desc = "Prevent being kicked for AFK",
    Default = false,
    Callback = function(state)
        featureStates.AntiAFK = state
        if state then startAntiAFK() else stopAntiAFK() end
    end
})

UtilitySection:Toggle({
    Title = "No Fall",
    Desc = "Remove fall damage and stun",
    Default = false,
    Callback = function(state)
        if state then enableNoFall() else disableNoFall() end
    end
})

UtilitySection:Toggle({
    Title = "Anti Stun",
    Desc = "Prevent stun, ragdoll, and platform stand",
    Default = false,
    Callback = function(state) toggleAntiStun(state) end
})

-- Aimbot Section
local AimbotSection = PlayerTab:Section({ Title = "Aimbot", Box = true, BoxBorder = true, Icon = "crosshair", Opened = true })

AimbotSection:Toggle({
    Title = "Aimbot Enabled",
    Desc = "Enable aimbot",
    Default = false,
    Callback = function(state)
        featureStates.AimbotEnabled = state
        if not state then destroyFOVCircle() end
    end
})

AimbotSection:Toggle({
    Title = "Team Check",
    Desc = "Only target enemies",
    Default = false,
    Callback = function(state) featureStates.AimbotTeamCheck = state end
})

AimbotSection:Toggle({
    Title = "Show FOV",
    Desc = "Show aim FOV circle on screen",
    Default = false,
    Callback = function(state)
        featureStates.AimbotShowFOV = state
        if not state then destroyFOVCircle() end
    end
})

AimbotSection:Slider({
    Title = "FOV Radius",
    Desc = "Size of the FOV circle",
    Step = 1,
    Value = {Min = 10, Max = 500, Default = featureStates.AimbotFOVRadius},
    Callback = function(value) featureStates.AimbotFOVRadius = value end
})

AimbotSection:Dropdown({
    Title = "Aim Part",
    Desc = "Body part to aim at",
    Values = {"Head", "Torso", "Left Arm", "Right Arm", "Left Leg", "Right Leg", "HumanoidRootPart"},
    Value = "Head",
    Callback = function(value) featureStates.AimbotPart = value end
})

AimbotSection:Slider({
    Title = "FOV Thickness",
    Step = 1,
    Value = {Min = 1, Max = 10, Default = featureStates.AimbotFOVThickness},
    Callback = function(value) featureStates.AimbotFOVThickness = value end
})

AimbotSection:Slider({
    Title = "FOV Transparency",
    Step = 0.05,
    Value = {Min = 0, Max = 1, Default = featureStates.AimbotFOVTransparency},
    Callback = function(value) featureStates.AimbotFOVTransparency = value end
})

---------------------------------------------------
--== SURVIVOR TAB ==--
---------------------------------------------------
local SurvivorMainSection = SurvivorTab:Section({ Title = "Survivor Main", Box = true, BoxBorder = true, Icon = "user-check", Opened = true })

SurvivorMainSection:Toggle({
    Title = "No Skillcheck",
    Desc = "Auto perfect skillcheck for generator & healing",
    Default = false,
    Callback = function(state)
        featureStates.NoSkillcheck = state
        if state then setupNoSkillcheck() else disableNoSkillcheck() end
    end
})

SurvivorMainSection:Toggle({
    Title = "Bypass Gate",
    Desc = "Walk through gates without opening",
    Default = false,
    Callback = function(state) setBypassGate(state) end
})

SurvivorMainSection:Toggle({
    Title = "Auto Lever",
    Desc = "Automatically pull exit lever when nearby",
    Default = false,
    Callback = function(state)
        featureStates.AutoLever = state
        if state then startAutoLever() else stopAutoLever() end
    end
})

local HealSection = SurvivorTab:Section({ Title = "Healing System", Box = true, BoxBorder = true, Icon = "heart", Opened = true })

HealSection:Toggle({
    Title = "Auto Heal (Perfect)",
    Desc = "Perfect skillcheck when healing",
    Default = false,
    Callback = function(state)
        featureStates.AutoHealPerfect = state
        if state then startAutoHealPerfect() end
    end
})

HealSection:Toggle({
    Title = "Auto Heal (Neutral)",
    Desc = "Neutral skillcheck when healing",
    Default = false,
    Callback = function(state)
        featureStates.AutoHealNeutral = state
        if state then startAutoHealNeutral() end
    end
})

local GenSection = SurvivorTab:Section({ Title = "Generator System", Box = true, BoxBorder = true, Icon = "zap", Opened = true })

GenSection:Toggle({
    Title = "Auto Generator (Perfect)",
    Desc = "Perfect skillcheck on generators",
    Default = false,
    Callback = function(state)
        featureStates.AutoGeneratorPerfect = state
        if state then startAutoGeneratorPerfect() end
    end
})

GenSection:Toggle({
    Title = "Auto Generator (Neutral)",
    Desc = "Neutral skillcheck on generators",
    Default = false,
    Callback = function(state)
        featureStates.AutoGeneratorNeutral = state
        if state then startAutoGeneratorNeutral() end
    end
})

local CombatSection = SurvivorTab:Section({ Title = "Combat System", Box = true, BoxBorder = true, Icon = "swords", Opened = true })

CombatSection:Toggle({
    Title = "Auto Parry",
    Desc = "Automatically parry killer attacks (requires Parrying Dagger)",
    Default = false,
    Callback = function(state)
        featureStates.AutoParry = state
        if state then startAutoParry() else stopAutoParry() end
    end
})

CombatSection:Toggle({
    Title = "Auto Shoot",
    Desc = "Automatically shoot killer (requires ranged weapon)",
    Default = false,
    Callback = function(state)
        featureStates.AutoShoot = state
        if state then startAutoShoot() else stopAutoShoot() end
    end
})

---------------------------------------------------
--== KILLER TAB ==--
---------------------------------------------------
local KillerMainSection = KillerTab:Section({ Title = "Killer Main", Box = true, BoxBorder = true, Icon = "swords", Opened = true })

KillerMainSection:Toggle({
    Title = "Kill All",
    Desc = "⚠️ WARNING: May get you banned! ⚠️",
    Default = false,
    Callback = function(state)
        featureStates.KillAll = state
        if state then startKillAll() else stopKillAll() end
    end
})

KillerMainSection:Toggle({
    Title = "Auto Attack",
    Desc = "Automatically attack nearby survivors",
    Default = false,
    Callback = function(state)
        featureStates.AutoAttack = state
        if state then startAutoAttack() else stopAutoAttack() end
    end
})

KillerMainSection:Toggle({
    Title = "No Flashlight",
    Desc = "Remove flashlight blinding effect",
    Default = false,
    Callback = function(state)
        featureStates.NoFlashlight = state
        if state then startNoFlashlight() else stopNoFlashlight() end
    end
})

local VeilSection = KillerTab:Section({ Title = "The Veil Aimbot", Box = true, BoxBorder = true, Icon = "target", Opened = true })

VeilSection:Paragraph({
    Title = "Information",
    Desc = "• Aimbot for The Veil killer\n• Normal mode: Screen-based targeting\n• Charge mode: Distance-based targeting\n• Both modes cannot be active simultaneously",
})

VeilSection:Toggle({
    Title = "Enable Aimbot (Normal)",
    Desc = "Screen-based targeting",
    Default = false,
    Callback = function(state)
        featureStates.VeilAimbotEnabled = state
        if state and featureStates.VeilAimbotChargeEnabled then
            featureStates.VeilAimbotChargeEnabled = false
        end
    end
})

VeilSection:Toggle({
    Title = "Enable Aimbot (Charge)",
    Desc = "Distance-based targeting for charge attack",
    Default = false,
    Callback = function(state)
        featureStates.VeilAimbotChargeEnabled = state
        if state and featureStates.VeilAimbotEnabled then
            featureStates.VeilAimbotEnabled = false
        end
    end
})

VeilSection:Toggle({
    Title = "Tough Wall",
    Desc = "Ignore walls when aiming",
    Default = true,
    Callback = function(state)
        featureStates.VeilToughWall = state
        VeilToughWall = state
    end
})

VeilSection:Input({
    Title = "Min Pitch",
    Desc = "Minimum pitch angle (-90 to 90)",
    Default = tostring(VeilMinPitch),
    Callback = function(v) 
        local n = tonumber(v) 
        if n then 
            featureStates.VeilMinPitch = n
            VeilMinPitch = n
        end 
    end
})

VeilSection:Input({
    Title = "Max Pitch",
    Desc = "Maximum pitch angle (-90 to 90)",
    Default = tostring(VeilMaxPitch),
    Callback = function(v) 
        local n = tonumber(v) 
        if n then 
            featureStates.VeilMaxPitch = n
            VeilMaxPitch = n
        end 
    end
})

local KillerUtilitySection = KillerTab:Section({ Title = "Killer Utility", Box = true, BoxBorder = true, Icon = "settings", Opened = false })

KillerUtilitySection:Button({
    Title = "Fix Camera",
    Desc = "Reset camera to 3rd person",
    Callback = fixCamera
})

---------------------------------------------------
--== ESP TAB ==--
---------------------------------------------------
local PlayerESPSection = ESPTab:Section({ Title = "Player ESP", Box = true, BoxBorder = true, Icon = "users", Opened = true })

PlayerESPSection:Toggle({
    Title = "Survivor ESP",
    Default = false,
    Callback = function(state) featureStates.SurvivorESP = state end
})

PlayerESPSection:Toggle({
    Title = "Killer ESP",
    Default = false,
    Callback = function(state) featureStates.KillerESP = state end
})

PlayerESPSection:Colorpicker({
    Title = "Survivor Color",
    Default = featureStates.SurvivorColor,
    Callback = function(color) featureStates.SurvivorColor = color end
})

PlayerESPSection:Colorpicker({
    Title = "Killer Color",
    Default = featureStates.KillerColor,
    Callback = function(color) featureStates.KillerColor = color end
})

---------------------------------------------------
--== WORLD ESP ==--
---------------------------------------------------
local WorldTogglesSection = ESPTab:Section({ Title = "World ESP", Box = true, BoxBorder = true, Icon = "toggle-left", Opened = true })

WorldTogglesSection:Slider({
    Title = "ESP Text Size",
    Step = 1,
    Value = {Min = 8, Max = 20, Default = featureStates.ESPTextSize},
    Callback = function(value) featureStates.ESPTextSize = value end
})

WorldTogglesSection:Toggle({
    Title = "Generators",
    Default = false,
    Callback = function(state)
        featureStates.GeneratorESP = state
        if state then startWorldLoop() end
    end
})

WorldTogglesSection:Toggle({
    Title = "Hooks",
    Default = false,
    Callback = function(state)
        featureStates.HookESP = state
        if state then startWorldLoop() end
    end
})

WorldTogglesSection:Toggle({
    Title = "Gates",
    Default = false,
    Callback = function(state)
        featureStates.GateESP = state
        if state then startWorldLoop() end
    end
})

WorldTogglesSection:Toggle({
    Title = "Windows",
    Default = false,
    Callback = function(state)
        featureStates.WindowESP = state
        if state then startWorldLoop() end
    end
})

WorldTogglesSection:Toggle({
    Title = "Pallets",
    Default = false,
    Callback = function(state)
        featureStates.PalletESP = state
        if state then startWorldLoop() end
    end
})

WorldTogglesSection:Colorpicker({
    Title = "Generator Color",
    Default = featureStates.GeneratorColor,
    Callback = function(color) featureStates.GeneratorColor = color end
})

WorldTogglesSection:Colorpicker({
    Title = "Hook Color",
    Default = featureStates.HookColor,
    Callback = function(color) featureStates.HookColor = color end
})

WorldTogglesSection:Colorpicker({
    Title = "Gate Color",
    Default = featureStates.GateColor,
    Callback = function(color) featureStates.GateColor = color end
})

WorldTogglesSection:Colorpicker({
    Title = "Window Color",
    Default = featureStates.WindowColor,
    Callback = function(color) featureStates.WindowColor = color end
})

WorldTogglesSection:Colorpicker({
    Title = "Pallet Color",
    Default = featureStates.PalletColor,
    Callback = function(color) featureStates.PalletColor = color end
})

---------------------------------------------------
--== VISUAL TAB ==--
---------------------------------------------------
local LightingSection = VisualTab:Section({ Title = "Lighting", Box = true, BoxBorder = true, Icon = "sun", Opened = true })

LightingSection:Toggle({
    Title = "Fullbright",
    Default = false,
    Callback = function(state)
        featureStates.FullBright = state
        updateFullBright()
    end
})

LightingSection:Slider({
    Title = "Time of Day",
    Step = 1,
    Value = {Min = 0, Max = 24, Default = featureStates.TimeOfDay},
    Callback = function(value)
        featureStates.TimeOfDay = value
        Lighting.ClockTime = value
        bindTimeLock()
    end
})

local FOVSection = VisualTab:Section({ Title = "FOV", Box = true, BoxBorder = true, Icon = "maximize", Opened = false })

FOVSection:Toggle({
    Title = "Custom FOV",
    Default = false,
    Callback = function(state)
        featureStates.FOVEnabled = state
        if state then applyFOV() end
    end
})

FOVSection:Slider({
    Title = "FOV Value",
    Step = 1,
    Value = {Min = 70, Max = 120, Default = featureStates.FOVValue},
    Callback = function(value)
        featureStates.FOVValue = value
        if featureStates.FOVEnabled then applyFOV() end
    end
})

---------------------------------------------------
--== TELEPORT TAB ==--
---------------------------------------------------
local PlayerTeleportSection = TeleportTab:Section({ Title = "Player Teleport", Box = true, BoxBorder = true, Icon = "users", Opened = true })

PlayerTeleportSection:Button({
    Title = "Teleport to Random Survivor",
    Callback = teleportToRandomSurvivor
})

PlayerTeleportSection:Button({
    Title = "Teleport to Killer",
    Callback = teleportToKiller
})

local WorldTeleportSection = TeleportTab:Section({ Title = "World Teleport", Box = true, BoxBorder = true, Icon = "globe", Opened = true })

WorldTeleportSection:Button({
    Title = "Teleport to Random Generator",
    Callback = function()
        local generators = getFolderGenerator()
        if #generators > 0 then
            local randomGen = generators[math.random(1, #generators)]
            local part = firstBasePart(randomGen)
            if part then tpCFrame(part.CFrame + Vector3.new(0, 3, 0)) end
        end
    end
})

---------------------------------------------------
--== CONFIG TAB ==--
---------------------------------------------------
local ConfigSection = ConfigTab:Section({ Title = "Config System", Box = true, BoxBorder = true, Icon = "folder", Opened = true })

local ConfigManager = Window.ConfigManager
local ConfigName = "default"

local ConfigNameInput = ConfigSection:Input({
    Title = "Config Name",
    Callback = function(value) ConfigName = value end,
})

local AllConfigs = ConfigManager:AllConfigs()

local AllConfigsDropdown = ConfigSection:Dropdown({
    Title = "All Configs",
    Values = AllConfigs,
    Value = "default",
    Callback = function(value) ConfigName = value ConfigNameInput:Set(value) end,
})

ConfigSection:Divider()

local ActionGroup = ConfigSection:Group({})

ActionGroup:Button({
    Title = "Save",
    Icon = "save",
    Justify = "Center",
    Callback = function()
        Window.CurrentConfig = ConfigManager:Config(ConfigName)
        Window.CurrentConfig:Save()
        AllConfigsDropdown:Refresh(ConfigManager:AllConfigs())
        safeNotify("Config", "Saved: " .. ConfigName, 2)
    end,
})

ActionGroup:Button({
    Title = "Load",
    Icon = "download",
    Justify = "Center",
    Callback = function()
        Window.CurrentConfig = ConfigManager:CreateConfig(ConfigName)
        Window.CurrentConfig:Load()
        safeNotify("Config", "Loaded: " .. ConfigName, 2)
    end,
})

ConfigSection:Button({
    Title = "Delete",
    Icon = "trash",
    Callback = function()
        pcall(function() ConfigManager:DeleteConfig(ConfigName) end)
        ConfigName = "default"
        ConfigNameInput:Set("default")
        AllConfigsDropdown:Refresh(ConfigManager:AllConfigs())
        safeNotify("Config", "Deleted config", 2)
    end,
})

---------------------------------------------------
--== INITIALIZE WORLD LOOP ==--
---------------------------------------------------
if anyWorldEnabled then
    startWorldLoop()
end

---------------------------------------------------
--== FINAL INITIALIZATION ==--
---------------------------------------------------
WindUI:Notify({
    Title = "FayintXCode | Violence District",
    Content = "Script loaded! Press V to toggle UI.\nExecutor: " .. executorName,
    Duration = 5,
    Icon = "bell"
})

Window:SelectTab(1)
Window:UnlockAll()
Window:Open()