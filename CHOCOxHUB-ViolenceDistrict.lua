-- ====================================================================
--                    VIOLENCE DISTRICT - CLEAN UI
--                    Space Theme UI (No Rayfield)
-- ====================================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")
local StarterPlayer = game:GetService("StarterPlayer")
local VirtualUser = game:GetService("VirtualUser")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local LP = Players.LocalPlayer

-- ========= SPACE THEME COLORS =========
local Theme = {
    Background = Color3.fromRGB(16, 15, 28),
    Surface = Color3.fromRGB(33, 31, 51),
    SurfaceAlt = Color3.fromRGB(45, 43, 69),
    TextPrimary = Color3.fromRGB(234, 234, 234),
    TextMuted = Color3.fromRGB(138, 136, 153),
    Accent = Color3.fromRGB(159, 93, 255),
    AccentSecondary = Color3.fromRGB(190, 41, 236),
    AccentSoft = Color3.fromRGB(108, 76, 158),
    Stroke = Color3.fromRGB(59, 56, 85),
    Success = Color3.fromRGB(0, 255, 100),
    Warning = Color3.fromRGB(255, 165, 0),
    Error = Color3.fromRGB(220, 50, 50)
}

-- ========= CLEANUP SYSTEM =========
local cleanupConnections = {}
local cleanupTasks = {}

local function addCleanupConnection(conn)
    table.insert(cleanupConnections, conn)
end

local function addCleanupTask(task)
    if task and (typeof(task) == "RBXScriptConnection" or typeof(task) == "thread" or task.cancel) then
        table.insert(cleanupTasks, task)
    else
        -- Invalid task type - convert to nil or skip
        warn("Attempted to add invalid task to cleanup tasks: " .. tostring(task))
    end
end

local function cleanupAll()
    -- Disconnect all connections
    for _, conn in ipairs(cleanupConnections) do
        if conn and conn.Disconnect then
            pcall(function() conn:Disconnect() end)
        end
    end
    
    -- Cancel all tasks (with safe type checking)
    for _, task in ipairs(cleanupTasks) do
        if task then
            pcall(function()
                local taskType = typeof(task)
                
                -- Handle different types of tasks
                if taskType == "RBXScriptConnection" then
                    -- This is a connection, disconnect it
                    if task.Disconnect then
                        task:Disconnect()
                    end
                elseif taskType == "thread" then
                    -- This is a Roblox task/coroutine
                    -- Only try to cancel if it has a cancel method
                    if task.cancel and typeof(task.cancel) == "function" then
                        task:cancel()
                    end
                elseif task.cancel then
                    -- Try to cancel for other types
                    if typeof(task.cancel) == "function" then
                        task:cancel()
                    end
                end
            end)
        end
    end
    
    -- Clear arrays
    cleanupConnections = {}
    cleanupTasks = {}
    
    -- Clear other data
    worldReg = {Generator={},Hook={},Gate={},Window={},Palletwrong={}}
    playerConns = {}
    remoteHooks = {}
    
    -- Reset states
    speedEnforced = false
    noclipEnabled = false
    fullbrightEnabled = false
    noSkillEnabled = false
    autoRepairEnabled = false
    
    showNotification("Cleanup", "All connections and tasks cleaned!", 3, Theme.Success)
end

-- ========= UTILS =========
local function alive(i)
    if not i then return false end
    local ok = pcall(function() return i.Parent end)
    return ok and i.Parent ~= nil
end

local function validPart(p) return p and alive(p) and p:IsA("BasePart") end
local function clamp(n,lo,hi) if n<lo then return lo elseif n>hi then return hi else return n end end
local function now() return os.clock() end
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

local function makeBillboard(text, color3)
    local g = Instance.new("BillboardGui")
    g.Name = "VD_Tag"
    g.AlwaysOnTop = true
    g.Size = UDim2.new(0, 200, 0, 36)
    g.StudsOffset = Vector3.new(0, 3, 0)
    local l = Instance.new("TextLabel")
    l.Name = "Label"
    l.BackgroundTransparency = 1
    l.Size = UDim2.new(1, 0, 1, 0)
    l.Font = Enum.Font.GothamBold
    l.Text = text
    l.TextSize = 14
    l.TextColor3 = color3 or Color3.new(1,1,1)
    l.TextStrokeTransparency = 0
    l.TextStrokeColor3 = Color3.new(0,0,0)
    l.Parent = g
    return g
end

local function ensureBoxESP(part, name, color)
    if not validPart(part) then return end
    local a = part:FindFirstChild(name)
    if not a then
        local ok, obj = pcall(function()
            local b = Instance.new("BoxHandleAdornment")
            b.Name = name
            b.Adornee = part
            b.ZIndex = 10
            b.AlwaysOnTop = true
            b.Transparency = 0.5
            b.Size = part.Size + Vector3.new(0.2,0.2,0.2)
            b.Color3 = color
            b.Parent = part
            return b
        end)
        if ok then a = obj end
    else
        a.Color3 = color
        a.Size = part.Size + Vector3.new(0.2,0.2,0.2)
    end
end

local function clearChild(o, n)
    if o and alive(o) then
        local c = o:FindFirstChild(n)
        if c then pcall(function() c:Destroy() end) end
    end
end

local function ensureHighlight(model, fill)
    if not (model and model:IsA("Model") and alive(model)) then return end
    local hl = model:FindFirstChild("VD_HL")
    if not hl then
        local ok, obj = pcall(function()
            local h = Instance.new("Highlight")
            h.Name = "VD_HL"
            h.Adornee = model
            h.FillTransparency = 0.5
            h.OutlineTransparency = 0
            h.Parent = model
            return h
        end)
        if ok then hl = obj else return end
    end
    hl.FillColor = fill
    hl.OutlineColor = fill
    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
end

local function clearHighlight(model)
    if model and model:FindFirstChild("VD_HL") then
        pcall(function() model.VD_HL:Destroy() end)
    end
end

-- ========= UI HELPERS =========
local function AddCorner(target, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius or 8)
    c.Parent = target
end

local function AddStroke(target, color, thickness)
    local ok, s = pcall(function() return Instance.new("UIStroke") end)
    if ok and s then
        s.Color = color or Theme.Stroke
        s.Thickness = thickness or 1
        s.Transparency = 0.3
        s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        s.Parent = target
    end
end

local function showNotification(title, content, duration, color)
    local notification = Instance.new("Frame")
    notification.Name = "Notification"
    notification.Size = UDim2.new(0, 300, 0, 60)
    notification.Position = UDim2.new(1, -320, 0, 20)
    notification.BackgroundColor3 = Theme.Surface
    notification.BorderSizePixel = 0
    notification.Parent = game:GetService("CoreGui")
    AddCorner(notification, 8)
    AddStroke(notification, color or Theme.Accent, 2)
    
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Text = title
    titleLabel.Size = UDim2.new(1, -16, 0, 20)
    titleLabel.Position = UDim2.new(0, 8, 0, 5)
    titleLabel.BackgroundTransparency = 1
    titleLabel.TextColor3 = color or Theme.Accent
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextSize = 14
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = notification
    
    local contentLabel = Instance.new("TextLabel")
    contentLabel.Text = content
    contentLabel.Size = UDim2.new(1, -16, 0, 20)
    contentLabel.Position = UDim2.new(0, 8, 0, 25)
    contentLabel.BackgroundTransparency = 1
    contentLabel.TextColor3 = Theme.TextPrimary
    contentLabel.Font = Enum.Font.Gotham
    contentLabel.TextSize = 12
    contentLabel.TextXAlignment = Enum.TextXAlignment.Left
    contentLabel.Parent = notification
    
    notification.Position = UDim2.new(1, 0, 0, 20)
    TweenService:Create(notification, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Position = UDim2.new(1, -320, 0, 20)
    }):Play()
    
    task.delay(duration or 3, function()
        if notification and notification.Parent then
            TweenService:Create(notification, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
                Position = UDim2.new(1, 0, 0, 20),
                BackgroundTransparency = 1
            }):Play()
            task.wait(0.3)
            notification:Destroy()
        end
    end)
end

-- ========= ROLE DETECTION =========
local function getRole(p)
    local tn = p.Team and p.Team.Name and p.Team.Name:lower() or ""
    if tn:find("killer") then return "Killer" end
    if tn:find("survivor") then return "Survivor" end
    return "Survivor"
end

local killerTypeName = "Killer"
local killerColors = {
    Jason = Color3.fromRGB(255, 60, 60),
    Stalker = Color3.fromRGB(255, 120, 60),
    Masked = Color3.fromRGB(255, 160, 60),
    Hidden = Color3.fromRGB(255, 60, 160),
    Abysswalker = Color3.fromRGB(120, 60, 255),
    Killer = Color3.fromRGB(255, 0, 0),
}

local function currentKillerColor()
    return killerColors[killerTypeName] or killerColors.Killer
end

local knownKillers = {Jason=true, Stalker=true, Masked=true, Hidden=true, Abysswalker=true}
do
    local r = ReplicatedStorage:FindFirstChild("Remotes")
    if r then
        local k = r:FindFirstChild("Killers")
        if k then
            for _,ch in ipairs(k:GetChildren()) do
                if ch:IsA("Folder") then knownKillers[ch.Name] = true end
            end
        end
    end
end

local function setKillerType(name)
    if name and knownKillers[name] and killerTypeName ~= name then
        killerTypeName = name
    end
end

-- ========= PLAYER ESP =========
local survivorColor = Color3.fromRGB(0,255,0)
local killerBaseColor = killerColors.Killer
local nametagsEnabled, playerESPEnabled = false, false
local playerConns = {}

local function applyPlayerESP(p)
    if p == LP then return end
    local c = p.Character
    if not (c and alive(c)) then return end
    local col = (getRole(p)=="Killer") and currentKillerColor() or survivorColor

    if playerESPEnabled then
        if c:IsDescendantOf(Workspace) then ensureHighlight(c, col) end
        local head = c:FindFirstChild("Head")
        if nametagsEnabled and validPart(head) then
            local tag = head:FindFirstChild("VD_Tag") or makeBillboard(p.Name, col)
            tag.Name = "VD_Tag"
            tag.Parent = head
            local l = tag:FindFirstChild("Label")
            if l then
                if getRole(p)=="Killer" then l.Text = p.Name.." ["..tostring(killerTypeName).."]" else l.Text = p.Name end
                l.TextColor3 = col
            end
        else
            local t = head and head:FindFirstChild("VD_Tag")
            if t then pcall(function() t:Destroy() end) end
        end
    else
        clearHighlight(c)
        local head = c:FindFirstChild("Head")
        local t = head and head:FindFirstChild("VD_Tag")
        if t then pcall(function() t:Destroy() end) end
    end
end

local function watchPlayer(p)
    if playerConns[p] then for _,cn in ipairs(playerConns[p]) do cn:Disconnect() end end
    playerConns[p] = {}
    table.insert(playerConns[p], p.CharacterAdded:Connect(function()
        task.delay(0.15, function() applyPlayerESP(p) end)
    end))
    table.insert(playerConns[p], p:GetPropertyChangedSignal("Team"):Connect(function() applyPlayerESP(p) end))
    if p.Character then applyPlayerESP(p) end
end

local function unwatchPlayer(p)
    if p.Character then
        clearHighlight(p.Character)
        local head = p.Character:FindFirstChild("Head")
        if head and head:FindFirstChild("VD_Tag") then pcall(function() head.VD_Tag:Destroy() end) end
    end
    if playerConns[p] then for _,cn in ipairs(playerConns[p]) do cn:Disconnect() end end
    playerConns[p] = nil
end

-- ========= WORLD ESP =========
local worldColors = {
    Generator = Color3.fromRGB(0,170,255),
    Hook = Color3.fromRGB(255,0,0),
    Gate = Color3.fromRGB(255,225,0),
    Window = Color3.fromRGB(255,255,255),
    Palletwrong = Color3.fromRGB(255,140,0)
}
local worldEnabled = {Generator=false,Hook=false,Gate=false,Window=false,Palletwrong=false}
local validCats = {Generator=true,Hook=true,Gate=true,Window=true,Palletwrong=true}
local worldReg = {Generator={},Hook={},Gate={},Window={},Palletwrong={}}
local mapAdd, mapRem = {}, {}

local palletState = setmetatable({}, {__mode="k"})
local windowState = setmetatable({}, {__mode="k"})

-- Safe pallet state management
local function safeSetPalletState(model, state)
    if not model or not alive(model) then return false end
    
    local ok, result = pcall(function()
        palletState[model] = state
        return true
    end)
    
    if not ok then
        -- Clean up invalid model reference
        palletState[model] = nil
        return false
    end
    
    return true
end

local function safeGetPalletState(model)
    if not model or not alive(model) then return "DEST" end
    
    local ok, state = pcall(function()
        return palletState[model] or "UP"
    end)
    
    if not ok then
        palletState[model] = nil
        return "DEST"
    end
    
    return state
end

local function labelForPallet(model)
    local st = safeGetPalletState(model)
    if st=="DOWN" then return "Pallet (down)" end
    if st=="DEST" then return "Pallet (destroyed)" end
    if st=="SLIDE" then return "Pallet (slide)" end
    return "Pallet"
end

local function labelForWindow(model)
    local st=windowState[model] or "READY"
    return st=="BUSY" and "Window (busy)" or "Window"
end

local function pickRep(model, cat)
    if not (model and alive(model)) then return nil end
    if cat == "Generator" then
        local hb = model:FindFirstChild("HitBox", true)
        if validPart(hb) then return hb end
    elseif cat == "Palletwrong" then
        local a = model:FindFirstChild("HumanoidRootPart", true); if validPart(a) then return a end
        local b = model:FindFirstChild("PrimaryPartPallet", true); if validPart(b) then return b end
        local c = model:FindFirstChild("Primary1", true); if validPart(c) then return c end
        local d = model:FindFirstChild("Primary2", true); if validPart(d) then return d end
    end
    return firstBasePart(model)
end

local function genLabelData(model)
    local pct = tonumber(model:GetAttribute("RepairProgress")) or 0
    if pct>=0 and pct<=1.001 then pct = pct*100 end
    pct = clamp(pct,0,100)
    local repairers = tonumber(model:GetAttribute("PlayersRepairingCount")) or 0
    local paused = (model:GetAttribute("ProgressPaused")==true)
    local kickcount = tonumber(model:GetAttribute("kickcount")) or 0
    local abyss50 = (model:GetAttribute("Abyss50Triggered")==true)
    local parts = {"Gen "..tostring(math.floor(pct+0.5)).."%" }
    if repairers>0 then parts[#parts+1]="("..repairers.."p)" end
    if paused then parts[#parts+1]="⏸" end
    if abyss50 then parts[#parts+1]="⚠" end
    if kickcount and kickcount>0 then parts[#parts+1]="K:"..kickcount end
    local text = table.concat(parts," ")
    local hue = clamp((pct/100)*0.33,0,0.33)
    local labelColor = Color3.fromHSV(hue,1,1)
    return text, labelColor
end

local function hasAnyBasePart(m)
    if not (m and alive(m)) then return false end
    local bp = m:FindFirstChildWhichIsA("BasePart", true)
    return bp ~= nil
end

local function isPalletGone(m)
    if not alive(m) then return true end
    if not m:IsDescendantOf(Workspace) then return true end
    if safeGetPalletState(m)=="DEST" then return true end
    
    -- Safe attribute check with better error handling
    local ok, val = pcall(function() 
        if m and m.Parent then
            return m:GetAttribute("Destroyed")
        end
        return false
    end)
    if ok and val == true then return true end
    
    -- Check if pallet has any valid parts
    if not hasAnyBasePart(m) then return true end
    
    -- Additional safety check for pallet integrity
    local ok2, hasParts = pcall(function()
        return m:FindFirstChildWhichIsA("BasePart", true) ~= nil
    end)
    if not ok2 or not hasParts then return true end
    
    return false
end

local function ensureWorldEntry(cat, model)
    if not alive(model) or worldReg[cat][model] then return end
    if cat=="Palletwrong" and isPalletGone(model) then return end
    local rep = pickRep(model, cat)
    if not validPart(rep) then return end
    worldReg[cat][model] = {part = rep}
end

local function removeWorldEntry(cat, model)
    local e = worldReg[cat][model]
    if not e then return end
    clearChild(e.part, "VD_"..cat)
    clearChild(e.part, "VD_Text_"..cat)
    worldReg[cat][model] = nil
end

local function registerFromDescendant(obj)
    if not alive(obj) then return end
    if obj:IsA("Model") and validCats[obj.Name] then
        ensureWorldEntry(obj.Name, obj)
        return
    end
    if obj:IsA("BasePart") and obj.Parent and obj.Parent:IsA("Model") and validCats[obj.Parent.Name] then
        ensureWorldEntry(obj.Parent.Name, obj.Parent)
    end
end

local function unregisterFromDescendant(obj)
    if not obj then return end
    if obj:IsA("Model") and validCats[obj.Name] then
        removeWorldEntry(obj.Name, obj)
        return
    end
    if obj:IsA("BasePart") and obj.Parent and obj.Parent:IsA("Model") and validCats[obj.Parent.Name] then
        local e = worldReg[obj.Parent.Name][obj.Parent]
        if e and e.part == obj then removeWorldEntry(obj.Parent.Name, obj.Parent) end
    end
end

local function attachRoot(root)
    if not root or mapAdd[root] then return end
    mapAdd[root] = root.DescendantAdded:Connect(registerFromDescendant)
    mapRem[root] = root.DescendantRemoving:Connect(unregisterFromDescendant)
    for _,d in ipairs(root:GetDescendants()) do registerFromDescendant(d) end
end

local function refreshRoots()
    for _,cn in pairs(mapAdd) do if cn then cn:Disconnect() end end
    for _,cn in pairs(mapRem) do if cn then cn:Disconnect() end end
    mapAdd, mapRem = {}, {}
    local r1 = Workspace:FindFirstChild("Map")
    local r2 = Workspace:FindFirstChild("Map1")
    if r1 then attachRoot(r1) end
    if r2 then attachRoot(r2) end
end

refreshRoots()
local workspaceConn = Workspace.ChildAdded:Connect(function(ch) if ch.Name=="Map" or ch.Name=="Map1" then attachRoot(ch) end end)
addCleanupConnection(workspaceConn)

local worldLoopThread=nil
local function anyWorldEnabled() for _,v in pairs(worldEnabled) do if v then return true end end return false end

local function startWorldLoop()
    if worldLoopThread then return end
    worldLoopThread = task.spawn(function()
        while anyWorldEnabled() do
            for cat,models in pairs(worldReg) do
                if worldEnabled[cat] then
                    local col, tagName, textName = worldColors[cat], "VD_"..cat, "VD_Text_"..cat
                    local n = 0
                    for model,entry in pairs(models) do
                        if cat=="Palletwrong" and isPalletGone(model) then
                            removeWorldEntry(cat, model)
                        else
                            local part = entry.part
                            if model and alive(model) then
                                if not validPart(part) or (model:IsA("Model") and not part:IsDescendantOf(model)) then
                                    entry.part = pickRep(model, cat); part = entry.part
                                end
                                if validPart(part) then
                                    ensureBoxESP(part, tagName, col)
                                    local bb = part:FindFirstChild(textName)
                                    if not bb then
                                        local newbb = makeBillboard((cat=="Palletwrong" and "Pallet") or cat, col)
                                        newbb.Name = textName
                                        newbb.Parent = part
                                        bb = newbb
                                    end
                                    local lbl = bb:FindFirstChild("Label")
                                    if lbl then
                                        if cat=="Generator" then local txt,lblCol=genLabelData(model) lbl.Text=txt lbl.TextColor3=lblCol
                                        elseif cat=="Palletwrong" then lbl.Text=labelForPallet(model) lbl.TextColor3=col
                                        elseif cat=="Window" then lbl.Text=labelForWindow(model) lbl.TextColor3=col
                                        else lbl.Text=cat lbl.TextColor3=col end
                                    end
                                end
                            else
                                removeWorldEntry(cat, model)
                            end
                        end
                        n = n + 1
                        if n % 60 == 0 then task.wait() end
                    end
                end
            end
            task.wait(0.25)
        end
        worldLoopThread=nil
    end)
end

local function setWorldToggle(cat, state)
    worldEnabled[cat] = state
    if state then
        if not worldLoopThread then startWorldLoop() end
    else
        for _,entry in pairs(worldReg[cat]) do
            if entry and entry.part then
                clearChild(entry.part,"VD_"..cat); clearChild(entry.part,"VD_Text_"..cat)
            end
        end
    end
end

-- ========= VISUAL EFFECTS =========
local initLighting = {
    Brightness = Lighting.Brightness,
    ClockTime = Lighting.ClockTime,
    FogStart = Lighting.FogStart,
    FogEnd = Lighting.FogEnd,
    GlobalShadows = Lighting.GlobalShadows,
    OutdoorAmbient = Lighting.OutdoorAmbient,
    ExposureCompensation = Lighting.ExposureCompensation,
    ShadowSoftness = Lighting:FindFirstChild("ShadowSoftness") and Lighting.ShadowSoftness or nil,
    EnvironmentDiffuseScale = Lighting:FindFirstChild("EnvironmentDiffuseScale") and Lighting.EnvironmentDiffuseScale or nil,
    EnvironmentSpecularScale = Lighting:FindFirstChild("EnvironmentSpecularScale") and Lighting.EnvironmentSpecularScale or nil,
    Technology = Lighting.Technology
}
local fullbrightEnabled = false
local fbLoop
local desiredClockTime = Lighting.ClockTime
local timeLockActive = false

local function bindTimeLock()
    if timeLockActive then return end
    timeLockActive = true
    RunService:BindToRenderStep("VD_TimeLock", 299, function()
        if Lighting.ClockTime ~= desiredClockTime then Lighting.ClockTime = desiredClockTime end
    end)
end

-- ========= SPEED LOCK =========
local speedCurrent, speedHumanoid = 16, nil
local speedEnforced, speedPaused = false, false
local speedStunUntil, speedSlowUntil = 0, 0
local speedTickConn, wsConn, stConn, pfConn, anConn = nil, nil, nil, nil, nil
local speedLastTick, speedTickInterval = 0, 0.12
local serverBaseline = nil

local function canonicalDefault()
    local ok,val = pcall(function() return StarterPlayer.CharacterWalkSpeed end)
    if ok and typeof(val)=="number" and val>0 then return val end
    return 16
end

local function setWalkSpeed(h,v) if h and h.Parent then pcall(function() h.WalkSpeed=v end) end end

local function fixRunAnim()
    local h = speedHumanoid
    if not h or not h.Parent then return end
    local animator = h:FindFirstChildOfClass("Animator")
    if not animator then
        local ac = h:FindFirstChildOfClass("AnimationController")
        if ac then animator = ac:FindFirstChildOfClass("Animator") end
    end
    if not animator then return end
    for _, track in ipairs(animator:GetPlayingAnimationTracks()) do
        local name = (track.Name or ""):lower()
        if name:find("run") or name:find("walk") or name:find("sprint") then
            pcall(function() track:AdjustSpeed(1) end)
        end
    end
end

local function canEnforce()
    local h = speedHumanoid
    if not speedEnforced then return false end
    if not h or not h.Parent then return false end
    if speedPaused then return false end
    if now()<speedStunUntil or now()<speedSlowUntil then return false end
    if h.Health<=0 then return false end
    if h.PlatformStand or h.Sit then return false end
    local st = h:GetState()
    if st==Enum.HumanoidStateType.Ragdoll or st==Enum.HumanoidStateType.FallingDown or st==Enum.HumanoidStateType.Physics or st==Enum.HumanoidStateType.GettingUp or st==Enum.HumanoidStateType.Seated then return false end
    local hrp = h.Parent:FindFirstChild("HumanoidRootPart")
    if hrp and hrp.Anchored then return false end
    return true
end

local function heartbeat()
    if not speedHumanoid then return end
    local t = now()
    if t - speedLastTick < speedTickInterval then return end
    speedLastTick = t
    if not canEnforce() then return end
    if speedHumanoid.WalkSpeed ~= speedCurrent then setWalkSpeed(speedHumanoid, speedCurrent) end
end

local function disconnectAll()
    if speedTickConn then speedTickConn:Disconnect() speedTickConn=nil end
    if wsConn then wsConn:Disconnect() wsConn=nil end
    if stConn then stConn:Disconnect() stConn=nil end
    if pfConn then pfConn:Disconnect() pfConn=nil end
    if anConn then anConn:Disconnect() anConn=nil end
end

local function captureServerBaseline()
    task.spawn(function()
        local h = speedHumanoid
        if not h or not h.Parent then return end
        local start = now()
        local last = h.WalkSpeed
        while now() - start < 0.6 do
            last = h.WalkSpeed
            task.wait(0.1)
        end
        if typeof(last)=="number" and last > 0 then serverBaseline = last end
    end)
end

local function applyDisabledState()
    local h = speedHumanoid
    if not h or not h.Parent then return end
    local target = serverBaseline or canonicalDefault()
    setWalkSpeed(h, target)
    fixRunAnim()
    captureServerBaseline()
end

local function bindHumanoid(h)
    speedHumanoid = h

    if wsConn then wsConn:Disconnect() end
    wsConn = h:GetPropertyChangedSignal("WalkSpeed"):Connect(function()
        if speedEnforced and canEnforce() and h.WalkSpeed ~= speedCurrent then
            setWalkSpeed(h, speedCurrent)
        end
    end)

    if stConn then stConn:Disconnect() end
    stConn = h.StateChanged:Connect(function(_, new)
        if new==Enum.HumanoidStateType.Ragdoll
        or new==Enum.HumanoidStateType.FallingDown
        or new==Enum.HumanoidStateType.Physics
        or new==Enum.HumanoidStateType.GettingUp
        or new==Enum.HumanoidStateType.Seated then
            speedPaused=true
            speedStunUntil = math.max(speedStunUntil, now()+0.9)
            task.delay(1.0,function() speedPaused=false end)
        end
    end)

    if pfConn then pfConn:Disconnect() end
    pfConn = h:GetPropertyChangedSignal("PlatformStand"):Connect(function() speedPaused = h.PlatformStand end)

    if anConn then anConn:Disconnect() end
    anConn = h.AncestryChanged:Connect(function(_, parent)
        if not parent then disconnectAll() end
    end)

    if speedEnforced then
        if not speedTickConn then
            speedLastTick = 0
            speedTickConn = RunService.Heartbeat:Connect(heartbeat)
        end
        if canEnforce() then setWalkSpeed(h, speedCurrent) end
    else
        applyDisabledState()
    end
end

-- ========= NOCLIP =========
local noclipEnabled, noclipConn, noclipTouched = false, nil, {}
local function setNoclip(state)
    if state and not noclipConn then
        noclipEnabled = true
        noclipConn = RunService.Stepped:Connect(function()
            local c = LP.Character
            if not c then return end
            for _,part in ipairs(c:GetDescendants()) do
                if part:IsA("BasePart") then
                    if part.CanCollide and not noclipTouched[part] then noclipTouched[part] = true end
                    part.CanCollide = false
                end
            end
        end)
    elseif not state and noclipConn then
        noclipEnabled=false
        noclipConn:Disconnect(); noclipConn=nil
        for part,_ in pairs(noclipTouched) do if part and part.Parent then part.CanCollide=true end end
        noclipTouched={}
    end
end

-- ========= TELEPORT =========
local function tpCFrame(cf)
    local char=LP.Character
    if not (char and char.Parent) then return end
    local hrp = char:FindFirstChild("HumanoidRootPart"); if not hrp then return end
    local was=noclipEnabled
    setNoclip(true)
    hrp.CFrame = cf
    task.delay(0.7,function() if not was then setNoclip(false) end end)
end

local function teleportToNearest(role)
    local hrp=LP.Character and LP.Character:FindFirstChild("HumanoidRootPart"); if not hrp then return end
    local best,bp,bd=nil,nil,1e9
    for _,pl in ipairs(Players:GetPlayers()) do
        if pl~=LP and getRole(pl)==role then
            local ch=pl.Character; local h=ch and ch:FindFirstChild("HumanoidRootPart")
            if h then local d=dist(h.Position,hrp.Position) if d<bd then bd=d best=pl bp=h end end
        end
    end
    if best and bp then
        local cf = bp.CFrame * CFrame.new(0,0,-3)
        cf = cf + Vector3.new(0,3,0)
        tpCFrame(cf)
        showNotification("Teleport", "To "..role..": "..best.Name, 4, Theme.Success)
    else
        showNotification("Teleport", "No "..role.." found.", 4, Theme.Warning)
    end
end

-- ========= AUTO REPAIR =========
local autoRepairEnabled = false
do
    local SCAN_INTERVAL = 1.0
    local REPAIR_TICK   = 0.25
    local AVOID_RADIUS  = 80
    local MOVE_DIST     = 35
    local UP_OFFSET     = Vector3.new(0, 3, 0)
    local gens = {}
    local current = nil
    local lastScan = 0

    local function findRemotes()
        local r = ReplicatedStorage:FindFirstChild("Remotes")
        if not r then return nil,nil end
        local g = r:FindFirstChild("Generator")
        if not g then return nil,nil end
        local repair = g:FindFirstChild("RepairEvent")
        local anim   = g:FindFirstChild("RepairAnim")
        return repair, anim
    end
    local RepairEvent, RepairAnim = findRemotes()

    local function ensureRemotes()
        if RepairEvent and RepairEvent.Parent then return end
        RepairEvent, RepairAnim = findRemotes()
    end

    local function getGenPartFromModel(m)
        if not (m and alive(m)) then return nil end
        local hb = m:FindFirstChild("HitBox", true)
        if validPart(hb) then return hb end
        return firstBasePart(m)
    end

    local function genProgress(m)
        local p = tonumber(m:GetAttribute("RepairProgress")) or 0
        if p <= 1.001 then p = p * 100 end
        return clamp(p,0,100)
    end

    local function genPaused(m)
        return (m:GetAttribute("ProgressPaused")==true)
    end

    local function rescanGenerators()
        gens = {}
        local function scanRoot(root)
            if not root then return end
            for _,d in ipairs(root:GetDescendants()) do
                if d:IsA("Model") and d.Name=="Generator" then
                    local part = getGenPartFromModel(d)
                    if validPart(part) then
                        table.insert(gens, {model=d, part=part})
                    end
                end
            end
        end
        scanRoot(Workspace:FindFirstChild("Map"))
        scanRoot(Workspace:FindFirstChild("Map1"))
    end

    local function nearestKillerDistanceTo(pos)
        local bd = 1e9
        for _,pl in ipairs(Players:GetPlayers()) do
            if pl ~= LP and getRole(pl)=="Killer" then
                local ch = pl.Character
                local hrp = ch and ch:FindFirstChild("HumanoidRootPart")
                if hrp then
                    local d = (hrp.Position - pos).Magnitude
                    if d < bd then bd = d end
                end
            end
        end
        return bd
    end

    local function lpHRP()
        return LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
    end

    local function chooseTarget()
        local best = nil
        local bestScore = -1
        for _,g in ipairs(gens) do
            local m = g.model
            if alive(m) then
                local prog = genProgress(m)
                if prog < 100 and not genPaused(m) then
                    local pos = g.part.Position
                    local kd = nearestKillerDistanceTo(pos)
                    local score = (kd >= AVOID_RADIUS and 1000 or 0) + prog
                    if score > bestScore then
                        bestScore = score
                        best = g
                    end
                end
            end
        end
        return best
    end

    local function safeFromKiller(target)
        if not target or not target.part then return false end
        local kd = nearestKillerDistanceTo(target.part.Position)
        return kd >= AVOID_RADIUS
    end

    local function closeEnough(target)
        local hrp = lpHRP(); if not hrp then return false end
        return (hrp.Position - target.part.Position).Magnitude <= MOVE_DIST
    end

    local function tpNear(part)
        local cf = part.CFrame * CFrame.new(0,0,-3)
        tpCFrame((cf + UP_OFFSET))
    end

    local function doRepair(target)
        ensureRemotes()
        if RepairAnim and RepairAnim.FireServer then pcall(function() RepairAnim:FireServer(target.model) end) end
        if RepairEvent and RepairEvent.FireServer then pcall(function() RepairEvent:FireServer(target.model) end) end
    end

    local scanTask = task.spawn(function()
        while true do
            local t = now()
            if t - lastScan >= SCAN_INTERVAL then
                lastScan = t
                rescanGenerators()
            end
            task.wait(0.2)
        end
    end)
    addCleanupTask(scanTask)

    local repairTask = task.spawn(function()
        while true do
            if autoRepairEnabled then
                if (not current) or (not alive(current.model)) or genProgress(current.model) >= 100 or genPaused(current.model) or (not safeFromKiller(current)) then
                    current = chooseTarget()
                end

                if current and alive(current.model) and genProgress(current.model) < 100 then
                    local me = lpHRP()
                    if me and nearestKillerDistanceTo(me.Position) < AVOID_RADIUS then
                        local alt = chooseTarget()
                        if alt and alt ~= current then current = alt end
                    end

                    if not closeEnough(current) then
                        tpNear(current.part)
                    end

                    doRepair(current)
                end
            end
            task.wait(REPAIR_TICK)
        end
    end)
    addCleanupTask(repairTask)

    function setAutoRepair(state)
        autoRepairEnabled = state
        showNotification("Auto-Repair", state and "enabled" or "disabled", 4, state and Theme.Success or Theme.Warning)
    end

    ReplicatedStorage.DescendantAdded:Connect(function(d)
        if d:IsA("RemoteEvent") and d.Name=="RepairEvent" then RepairEvent=d end
        if d:IsA("RemoteEvent") and d.Name=="RepairAnim"  then RepairAnim=d end
    end)
end

-- ========= ANTI AFK =========
local antiAFKConn=nil
local function setAntiAFK(state)
    if state and not antiAFKConn then
        antiAFKConn = LP.Idled:Connect(function()
            local cam = Workspace.CurrentCamera and Workspace.CurrentCamera.CFrame or CFrame.new()
            VirtualUser:Button2Down(Vector2.new(0,0), cam); task.wait(1); VirtualUser:Button2Up(Vector2.new(0,0), cam)
        end)
    elseif not state and antiAFKConn then
        antiAFKConn:Disconnect(); antiAFKConn=nil
    end
end

-- ========= SKILLCHECK REMOVAL =========
local function isKillerTeam() local tn=LP.Team and LP.Team.Name and LP.Team.Name:lower() or "" return tn:find("killer",1,true)~=nil end
local guiWhitelist = {Rayfield=true,DevConsoleMaster=true,RobloxGui=true,PlayerList=true,Chat=true,BubbleChat=true,Backpack=true}
local skillExactNames = {SkillCheckPromptGui=true,["SkillCheckPromptGui-con"]=true,SkillCheckEvent=true,SkillCheckFailEvent=true,SkillCheckResultEvent=true}
local function isExactSkill(inst) local n=inst and inst.Name if not n then return false end if skillExactNames[n] then return true end return n:lower():find("skillcheck",1,true)~=nil end

local function hardDelete(obj)
    pcall(function()
        if obj:IsA("ProximityPrompt") then obj.Enabled=false obj.HoldDuration=1e9 end
        if obj:IsA("ScreenGui") or obj:IsA("BillboardGui") or obj:IsA("SurfaceGui") then
            if obj:IsA("ScreenGui") and guiWhitelist[obj.Name] then return end
            obj.Enabled=false obj.Visible=false obj.ResetOnSpawn=false obj:Destroy()
        else
            obj:Destroy()
        end
    end)
end

local function nukeSkillExactOnce()
    local pg=LP:FindFirstChild("PlayerGui")
    if pg then
        for _,g in ipairs(pg:GetChildren()) do if isExactSkill(g) then hardDelete(g) end end
        for _,d in ipairs(pg:GetDescendants()) do if isExactSkill(d) then hardDelete(d) end end
    end
    for _,g in ipairs(StarterGui:GetChildren()) do if isExactSkill(g) then hardDelete(g) end end
    local rem=ReplicatedStorage:FindFirstChild("Remotes")
    if rem then for _,d in ipairs(rem:GetDescendants()) do if isExactSkill(d) then hardDelete(d) end end end
end

local noSkillEnabled=false
local noSkillToggleUser=false
local hookSkillInstalled=false
local pursuitBypassEnabled=true
local currentCharacter = LP.Character
local rsAddConn, pgAddConn, pgDescConn, sgAddConn, remAddConn, wsAddConn
local charAddConns={}

local function installSkillBlock()
    if hookSkillInstalled then return end
    if typeof(hookmetamethod)=="function" and typeof(getnamecallmethod)=="function" then
        local old
        old = hookmetamethod(game,"__namecall",function(self,...)
            local m=getnamecallmethod()
            if pursuitBypassEnabled and m=="GetAttribute" then
                local attr = ...
                if attr=="Pursuit" then
                    local char = currentCharacter or LP.Character
                    if char and self==char then
                        return false
                    end
                end
            end
            if noSkillEnabled and typeof(self)=="Instance" and isExactSkill(self) and (m=="FireServer" or m=="InvokeServer") then
                return nil
            end
            return old(self,...)
        end)
        hookSkillInstalled=true
    end
end

installSkillBlock()

local function startNoSkill()
    installSkillBlock()
    nukeSkillExactOnce()
    local pg=LP:FindFirstChild("PlayerGui")
    if pg then
        if pgAddConn then pgAddConn:Disconnect() end
        pgAddConn = pg.ChildAdded:Connect(function(ch) if noSkillEnabled and isExactSkill(ch) then hardDelete(ch) end end)
        if pgDescConn then pgDescConn:Disconnect() end
        pgDescConn = pg.DescendantAdded:Connect(function(d) if noSkillEnabled and isExactSkill(d) then hardDelete(d) end end)
    end
    if sgAddConn then sgAddConn:Disconnect() end
    sgAddConn = StarterGui.ChildAdded:Connect(function(ch) if noSkillEnabled and isExactSkill(ch) then hardDelete(ch) end end)
    local rem=ReplicatedStorage:FindFirstChild("Remotes")
    if rem then
        if remAddConn then remAddConn:Disconnect() end
        remAddConn = rem.DescendantAdded:Connect(function(d) if noSkillEnabled and isExactSkill(d) then hardDelete(d) end end)
    end
    if rsAddConn then rsAddConn:Disconnect() end
    rsAddConn = ReplicatedStorage.DescendantAdded:Connect(function(d)
        if not noSkillEnabled then return end
        if d:IsA("ScreenGui") or d:IsA("BillboardGui") or d:IsA("SurfaceGui") or d:IsA("RemoteEvent") or d:IsA("RemoteFunction") or d:IsA("BindableEvent") then
            if isExactSkill(d) then hardDelete(d) end
        end
    end)
    for _,pl in ipairs(Players:GetPlayers()) do
        if charAddConns[pl] then charAddConns[pl]:Disconnect() end
        charAddConns[pl] = pl.CharacterAdded:Connect(function(ch)
            if not noSkillEnabled then return end
            task.wait(0.1)
            for _,d in ipairs(ch:GetDescendants()) do if isExactSkill(d) then hardDelete(d) end end
        end)
        if pl.Character then for _,d in ipairs(pl.Character:GetDescendants()) do if isExactSkill(d) then hardDelete(d) end end end
    end
    if wsAddConn then wsAddConn:Disconnect() end
    wsAddConn = Workspace.DescendantAdded:Connect(function(d) if noSkillEnabled and isExactSkill(d) then hardDelete(d) end end)
end

local function stopNoSkill()
    if pgAddConn then pgAddConn:Disconnect() pgAddConn=nil end
    if pgDescConn then pgDescConn:Disconnect() pgDescConn=nil end
    if sgAddConn then sgAddConn:Disconnect() sgAddConn=nil end
    if remAddConn then remAddConn:Disconnect() remAddConn=nil end
    if rsAddConn then rsAddConn:Disconnect() rsAddConn=nil end
    if wsAddConn then wsAddConn:Disconnect() wsAddConn=nil end
    for pl,cn in pairs(charAddConns) do if cn then cn:Disconnect() end charAddConns[pl]=nil end
end

local function evalNoSkill()
    if noSkillToggleUser and not isKillerTeam() then
        if not noSkillEnabled then noSkillEnabled=true startNoSkill() end
    else
        if noSkillEnabled then noSkillEnabled=false stopNoSkill() end
    end
end

LP:GetPropertyChangedSignal("Team"):Connect(evalNoSkill)

-- ========= REMOTE HOOKS =========
local remoteHooks=setmetatable({},{__mode="k"})
local abilityNotifyEnabled = true

-- ========= DEBOUNCING SYSTEM =========
local eventDebounce = {}
local function debounceEvent(eventName, callback, delay)
    delay = delay or 0.1
    local key = eventName .. "_" .. tostring(math.floor(now() * 10))
    
    if eventDebounce[key] then return end
    eventDebounce[key] = true
    
    callback()
    
    task.delay(delay, function()
        eventDebounce[key] = nil
    end)
end
local abilityAllow = {
    ["Killer.ActivatePower"]      = "Ability Activated",
    ["Jason.Instinct"]            = "Instinct",
    ["Masked.Activatepower"]      = "Dash",
    ["Hidden.M2"]                 = "M2",
    ["Stalker.StartStalking"]     = "Stalk",
    ["Abysswalker.corrupt"]       = "Corrupt",
}

local function connectRemote(inst)
    if remoteHooks[inst] then return end
    local isRE,isBE=inst:IsA("RemoteEvent"),inst:IsA("BindableEvent")
    if not(isRE or isBE) then return end
    local full = inst:GetFullName()
    local underKillers    = full:find("ReplicatedStorage.Remotes.Killers",1,true)~=nil
    local underMechanics  = full:find("ReplicatedStorage.Remotes.Mechanics",1,true)~=nil
    local underPallet     = full:find("ReplicatedStorage.Remotes.Pallet",1,true)~=nil
    local underWindow     = full:find("ReplicatedStorage.Remotes.Window",1,true)~=nil

    local function hook(fn)
        local conn
        if isRE then conn=inst.OnClientEvent:Connect(fn) else conn=inst.Event:Connect(fn) end
        remoteHooks[inst]=conn
    end

    if underKillers then
        local seg = string.split(full,".")
        for i=#seg,1,-1 do
            if seg[i]=="Killers" then
                local kn = seg[i+1]
                if kn and knownKillers[kn] then
                    hook(function(...)
                        setKillerType(kn)
                        local key = kn.."."..inst.Name
                        local label = abilityAllow[key]
                        if label and abilityNotifyEnabled then
                            showNotification("Killer Ability", kn..": "..label, 4, Theme.Accent)
                        end
                    end)
                else
                    local key = (kn or "Killer").."."..inst.Name
                    if abilityAllow[key] then
                        hook(function(...)
                            if abilityNotifyEnabled then
                                local who = knownKillers[kn or ""] and kn or killerTypeName
                                showNotification("Killer Ability", tostring(who)..": "..abilityAllow[key], 4, Theme.Accent)
                            end
                        end)
                    end
                end
                break
            end
        end
    end

    if underMechanics then
        if inst.Name=="PalletStun" then 
            hook(function() 
                speedStunUntil = math.max(speedStunUntil, now()+3.5) 
            end)
        elseif inst.Name=="Slow" then 
            hook(function() 
                speedSlowUntil = math.max(speedSlowUntil, now()+3.0) 
            end)
        elseif inst.Name=="Slowserver" and isRE then
            hook(function(_,_,dur)
                local d = (typeof(dur)=="number") and math.clamp(dur,1,10) or 3.0
                speedSlowUntil = math.max(speedSlowUntil, now()+d)
            end)
        end
    end

    if underPallet then
        if inst.Name=="PalletDropEvent" then hook(function()
            debounceEvent("PalletDrop", function()
                local character = LP.Character
                if not character then return end
                
                local hrp = character:FindFirstChild("HumanoidRootPart")
                if not hrp then return end
                
                local best, bd = nil, 1e9
                for m, e in pairs(worldReg.Palletwrong) do 
                    if e and e.part and alive(m) and alive(e.part) then
                        local d = dist(e.part.Position, hrp.Position)
                        if d < bd then bd = d best = m end 
                    end 
                end
                
                if best then 
                    if isKillerTeam() then
                        -- Killer under pallet - handle stun mechanics
                        if safeSetPalletState(best, "DOWN") then
                            speedStunUntil = math.max(speedStunUntil, now() + 3.5)
                            showNotification("Pallet", "Stunned by pallet!", 3, Theme.Warning)
                        end
                    else
                        -- Survivor dropped pallet - don't immediately update state
                        -- Allow player to vault over it first, then update state after delay
                        -- This prevents interference with vault mechanics
                        task.delay(1.5, function()
                            if best and alive(best) and safeGetPalletState(best) ~= "DEST" then
                                -- Check if pallet is still valid before updating state
                                local currentState = safeGetPalletState(best)
                                if currentState ~= "DEST" and currentState ~= "DOWN" then
                                    safeSetPalletState(best, "DOWN")
                                end
                            end
                        end)
                    end
                end
            end, 0.2)
        end)
        elseif inst.Name=="Destroy" or inst.Name=="Destroy-Global" then hook(function()
            debounceEvent("PalletDestroy", function()
                local character = LP.Character
                if not character then return end
                
                local hrp = character:FindFirstChild("HumanoidRootPart")
                if not hrp then return end
                
                local best, bd = nil, 1e9
                for m, e in pairs(worldReg.Palletwrong) do 
                    if e and e.part and alive(m) and alive(e.part) then
                        local d = dist(e.part.Position, hrp.Position)
                        if d < bd then bd = d best = m end 
                    end 
                end
                
                if best then 
                    safeSetPalletState(best, "DEST")
                    if isKillerTeam() then
                        showNotification("Pallet", "Pallet destroyed!", 3, Theme.Success)
                    end
                end
            end, 0.2)
        end)
        elseif inst.Name=="PalletSlideEvent" then hook(function()
            debounceEvent("PalletSlide", function()
                local character = LP.Character
                if not character then return end
                
                local hrp = character:FindFirstChild("HumanoidRootPart")
                if not hrp then return end
                
                local best, bd = nil, 1e9
                for m, e in pairs(worldReg.Palletwrong) do 
                    if e and e.part and alive(m) and alive(e.part) then
                        local d = dist(e.part.Position, hrp.Position)
                        if d < bd then bd = d best = m end 
                    end 
                end
                
                if best then 
                    safeSetPalletState(best, "SLIDE")
                    task.delay(1.4, function() 
                        if safeGetPalletState(best) == "SLIDE" then 
                            safeSetPalletState(best, "UP")
                        end 
                    end)
                end
            end, 0.2)
        end)
        elseif inst.Name=="PalletSlideCompleteEvent" then hook(function()
            debounceEvent("PalletSlideComplete", function()
                local character = LP.Character
                if not character then return end
                
                local hrp = character:FindFirstChild("HumanoidRootPart")
                if not hrp then return end
                
                local best, bd = nil, 1e9
                for m, e in pairs(worldReg.Palletwrong) do 
                    if e and e.part and alive(m) and alive(e.part) then
                        local d = dist(e.part.Position, hrp.Position)
                        if d < bd then bd = d best = m end 
                    end 
                end
                
                if best and safeGetPalletState(best) ~= "DEST" then 
                    safeSetPalletState(best, "UP")
                end
            end, 0.2)
        end)
        elseif inst.Name=="Stun" or inst.Name=="Stunover" then hook(function()
            debounceEvent("PalletStun", function()
                if isKillerTeam() then
                    speedStunUntil = math.max(speedStunUntil, now() + 3.5)
                    showNotification("Pallet", "Stunned!", 3, Theme.Warning)
                end
            end, 0.2)
        end)
        end
    end
    if underWindow then
        if inst.Name=="VaultEvent" or inst.Name=="VaultAnim" or inst.Name=="fastvault" then hook(function()
            debounceEvent("VaultEvent", function()
                if isKillerTeam() then return end
                
                local character = LP.Character
                if not character then return end
                
                local hrp = character:FindFirstChild("HumanoidRootPart")
                if not hrp then return end
                
                local best, bd = nil, 1e9
                for m, e in pairs(worldReg.Window) do 
                    if e and e.part and alive(m) and alive(e.part) then
                        local d = dist(e.part.Position, hrp.Position)
                        if d < bd then bd = d best = m end 
                    end 
                end
                if best then 
                    windowState[best] = "BUSY"
                    task.delay(1.2, function() 
                        if windowState[best] == "BUSY" then 
                            windowState[best] = "READY" 
                        end 
                    end)
                end
            end, 0.2)
        end)
        elseif inst.Name=="VaultCompleteEvent" then hook(function()
            debounceEvent("VaultComplete", function()
                if isKillerTeam() then return end
                
                local character = LP.Character
                if not character then return end
                
                local hrp = character:FindFirstChild("HumanoidRootPart")
                if not hrp then return end
                
                local best, bd = nil, 1e9
                for m, e in pairs(worldReg.Window) do 
                    if e and e.part and alive(m) and alive(e.part) then
                        local d = dist(e.part.Position, hrp.Position)
                        if d < bd then bd = d best = m end 
                    end 
                end
                if best then 
                    windowState[best] = "READY"
                end
            end, 0.2)
        end)
        end
    end
end

for _,d in ipairs(ReplicatedStorage:GetDescendants()) do if d:IsA("RemoteEvent") or d:IsA("BindableEvent") then connectRemote(d) end end
local remoteConn = ReplicatedStorage.DescendantAdded:Connect(function(d) if d:IsA("RemoteEvent") or d:IsA("BindableEvent") then connectRemote(d) end end)
addCleanupConnection(remoteConn)

-- ========= CHARACTER HOOK =========
local function onCharacterAdded(char)
    currentCharacter = char
    local h = char:WaitForChild("Humanoid", 10) or char:FindFirstChildOfClass("Humanoid")
    if h then bindHumanoid(h) end
    char.ChildAdded:Connect(function(ch) if ch:IsA("Humanoid") then bindHumanoid(ch) end end)
end
if LP.Character then onCharacterAdded(LP.Character) end
local charConn = LP.CharacterAdded:Connect(onCharacterAdded)
addCleanupConnection(charConn)

-- ========= PLAYER WATCHING =========
for _,p in ipairs(Players:GetPlayers()) do if p~=LP then watchPlayer(p) end end
local playerAddedConn = Players.PlayerAdded:Connect(watchPlayer)
local playerRemovingConn = Players.PlayerRemoving:Connect(unwatchPlayer)
addCleanupConnection(playerAddedConn)
addCleanupConnection(playerRemovingConn)

-- ========= GUI CREATION =========
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ViolenceDistrict_CleanUI"
screenGui.ResetOnSpawn = false
screenGui.DisplayOrder = 0
screenGui.Parent = game:GetService("CoreGui")

local mainBox = Instance.new("Frame")
mainBox.Name = "MainBox"
mainBox.Size = UDim2.new(0, 320, 0, 480)
mainBox.Position = UDim2.new(0.5, -160, 0.5, -240)
mainBox.BackgroundColor3 = Theme.Background
mainBox.BorderSizePixel = 0
mainBox.Parent = screenGui
AddCorner(mainBox, 12)
AddStroke(mainBox, Theme.Stroke, 2)

local titleBar = Instance.new("Frame")
titleBar.Name = "TitleBar"
titleBar.Size = UDim2.new(1, 0, 0, 40)
titleBar.BackgroundColor3 = Theme.Surface
titleBar.BorderSizePixel = 0
titleBar.Parent = mainBox
AddCorner(titleBar, 12)

local titleText = Instance.new("TextLabel")
titleText.Text = "🎮 Violence District"
titleText.Size = UDim2.new(1, -90, 1, 0)
titleText.Position = UDim2.new(0, 10, 0, 0)
titleText.BackgroundTransparency = 1
titleText.TextColor3 = Theme.Accent
titleText.Font = Enum.Font.GothamBold
titleText.TextSize = 16
titleText.TextXAlignment = Enum.TextXAlignment.Left
titleText.Parent = titleBar

local minimizeBtn = Instance.new("TextButton")
minimizeBtn.Name = "MinimizeBtn"
minimizeBtn.Text = "−"
minimizeBtn.Size = UDim2.new(0, 40, 0, 40)
minimizeBtn.Position = UDim2.new(1, -85, 0, 0)
minimizeBtn.BackgroundColor3 = Theme.SurfaceAlt
minimizeBtn.TextColor3 = Theme.TextPrimary
minimizeBtn.Font = Enum.Font.GothamBold
minimizeBtn.TextSize = 20
minimizeBtn.BorderSizePixel = 0
minimizeBtn.AutoButtonColor = false
minimizeBtn.Parent = titleBar
AddCorner(minimizeBtn, 8)
AddStroke(minimizeBtn, Theme.Stroke, 1)

local closeBtn = Instance.new("TextButton")
closeBtn.Name = "CloseBtn"
closeBtn.Text = "×"
closeBtn.Size = UDim2.new(0, 40, 0, 40)
closeBtn.Position = UDim2.new(1, -40, 0, 0)
closeBtn.BackgroundColor3 = Theme.SurfaceAlt
closeBtn.TextColor3 = Theme.TextPrimary
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 16
closeBtn.BorderSizePixel = 0
closeBtn.AutoButtonColor = false
closeBtn.Parent = titleBar
AddCorner(closeBtn, 8)
AddStroke(closeBtn, Theme.Stroke, 1)

local contentFrame = Instance.new("Frame")
contentFrame.Name = "Content"
contentFrame.Size = UDim2.new(1, 0, 1, -40)
contentFrame.Position = UDim2.new(0, 0, 0, 40)
contentFrame.BackgroundTransparency = 1
contentFrame.Parent = mainBox

local scrollFrame = Instance.new("ScrollingFrame")
scrollFrame.Name = "ScrollFrame"
scrollFrame.Size = UDim2.new(1, -16, 1, -16)
scrollFrame.Position = UDim2.new(0, 8, 0, 8)
scrollFrame.BackgroundTransparency = 1
scrollFrame.BorderSizePixel = 0
scrollFrame.ScrollBarThickness = 8
scrollFrame.ScrollBarImageColor3 = Theme.Accent
scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 1200)
scrollFrame.Parent = contentFrame

-- ========= GUI HELPERS =========
local function createToggle(name, yPos, callback, currentValue)
    local frame = Instance.new("Frame")
    frame.Name = name.."_Toggle"
    frame.Size = UDim2.new(1, -32, 0, 50)
    frame.Position = UDim2.new(0, 8, 0, yPos)
    frame.BackgroundColor3 = Theme.Surface
    frame.BorderSizePixel = 0
    frame.Parent = scrollFrame
    AddCorner(frame, 10)
    AddStroke(frame, Theme.Stroke, 1)
    
    local label = Instance.new("TextLabel")
    label.Text = name
    label.Size = UDim2.new(0.6, 0, 1, 0)
    label.Position = UDim2.new(0, 12, 0, 0)
    label.BackgroundTransparency = 1
    label.TextColor3 = Theme.TextPrimary
    label.Font = Enum.Font.GothamBold
    label.TextSize = 14
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame
    
    local toggle = Instance.new("TextButton")
    toggle.Text = currentValue and "ON" or "OFF"
    toggle.Size = UDim2.new(0, 70, 0, 34)
    toggle.Position = UDim2.new(1, -80, 0.5, -17)
    toggle.BackgroundColor3 = currentValue and Theme.Accent or Theme.SurfaceAlt
    toggle.TextColor3 = Theme.TextPrimary
    toggle.Font = Enum.Font.GothamBold
    toggle.TextSize = 13
    toggle.BorderSizePixel = 0
    toggle.AutoButtonColor = false
    toggle.Parent = frame
    AddCorner(toggle, 8)
    AddStroke(toggle, currentValue and Theme.AccentSecondary or Theme.Stroke, currentValue and 2 or 1)
    
    local state = currentValue or false
    toggle.MouseButton1Click:Connect(function()
        state = not state
        toggle.Text = state and "ON" or "OFF"
        
        if state then
            TweenService:Create(toggle, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                BackgroundColor3 = Theme.Accent
            }):Play()
            if toggle:FindFirstChildOfClass("UIStroke") then
                TweenService:Create(toggle:FindFirstChildOfClass("UIStroke"), TweenInfo.new(0.2), {
                    Color = Theme.AccentSecondary,
                    Thickness = 2
                }):Play()
            end
        else
            TweenService:Create(toggle, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                BackgroundColor3 = Theme.SurfaceAlt
            }):Play()
            if toggle:FindFirstChildOfClass("UIStroke") then
                TweenService:Create(toggle:FindFirstChildOfClass("UIStroke"), TweenInfo.new(0.2), {
                    Color = Theme.Stroke,
                    Thickness = 1
                }):Play()
            end
        end
        
        callback(state)
    end)
    
    return frame, toggle
end

local function createSection(name, yPos)
    local section = Instance.new("Frame")
    section.Name = name.."_Section"
    section.Size = UDim2.new(1, -32, 0, 35)
    section.Position = UDim2.new(0, 8, 0, yPos)
    section.BackgroundColor3 = Theme.SurfaceAlt
    section.BorderSizePixel = 0
    section.Parent = scrollFrame
    AddCorner(section, 8)
    AddStroke(section, Theme.Accent, 2)
    
    local label = Instance.new("TextLabel")
    label.Text = "🔹 " .. name
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.TextColor3 = Theme.Accent
    label.Font = Enum.Font.GothamBold
    label.TextSize = 15
    label.TextXAlignment = Enum.TextXAlignment.Center
    label.Parent = section
    
    return section
end

local function createSlider(name, yPos, minValue, maxValue, defaultValue, callback)
    local frame = Instance.new("Frame")
    frame.Name = name.."_Slider"
    frame.Size = UDim2.new(1, -32, 0, 55)
    frame.Position = UDim2.new(0, 8, 0, yPos)
    frame.BackgroundColor3 = Theme.Surface
    frame.BorderSizePixel = 0
    frame.Parent = scrollFrame
    AddCorner(frame, 10)
    AddStroke(frame, Theme.Stroke, 1)
    
    local label = Instance.new("TextLabel")
    label.Text = name .. ": " .. tostring(defaultValue)
    label.Size = UDim2.new(1, -20, 0, 20)
    label.Position = UDim2.new(0, 10, 0, 5)
    label.BackgroundTransparency = 1
    label.TextColor3 = Theme.TextPrimary
    label.Font = Enum.Font.GothamBold
    label.TextSize = 12
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame
    
    local sliderBg = Instance.new("Frame")
    sliderBg.Size = UDim2.new(1, -20, 0, 6)
    sliderBg.Position = UDim2.new(0, 10, 1, -16)
    sliderBg.BackgroundColor3 = Theme.SurfaceAlt
    sliderBg.BorderSizePixel = 0
    sliderBg.Parent = frame
    AddCorner(sliderBg, 3)
    
    local sliderFill = Instance.new("Frame")
    sliderFill.Name = "Fill"
    local percent = (defaultValue - minValue) / (maxValue - minValue)
    sliderFill.Size = UDim2.new(percent, 0, 1, 0)
    sliderFill.BackgroundColor3 = Theme.Accent
    sliderFill.BorderSizePixel = 0
    sliderFill.Parent = sliderBg
    AddCorner(sliderFill, 3)
    
    local sliderButton = Instance.new("TextButton")
    sliderButton.Text = ""
    sliderButton.Size = UDim2.new(0, 16, 0, 16)
    sliderButton.Position = UDim2.new(percent, -8, 0.5, -8)
    sliderButton.BackgroundColor3 = Theme.Accent
    sliderButton.BorderSizePixel = 0
    sliderButton.AutoButtonColor = false
    sliderButton.Parent = sliderBg
    AddCorner(sliderButton, 8)
    AddStroke(sliderButton, Theme.AccentSecondary, 2)
    
    local dragging = false
    sliderButton.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
        end
    end)
    
    sliderButton.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local relativeX = input.Position.X - sliderBg.AbsolutePosition.X
            local percent = math.clamp(relativeX / sliderBg.AbsoluteSize.X, 0, 1)
            
            sliderFill.Size = UDim2.new(percent, 0, 1, 0)
            sliderButton.Position = UDim2.new(percent, -8, 0.5, -8)
            
            local value = minValue + (percent * (maxValue - minValue))
            value = math.floor(value * 10 + 0.5) / 10
            
            label.Text = name .. ": " .. tostring(value)
            callback(value)
        end
    end)
    
    return frame, sliderButton, label
end

local function createButton(name, yPos, callback)
    local button = Instance.new("TextButton")
    button.Name = name.."_Button"
    button.Text = name
    button.Size = UDim2.new(1, -32, 0, 45)
    button.Position = UDim2.new(0, 8, 0, yPos)
    button.BackgroundColor3 = Theme.Surface
    button.TextColor3 = Theme.TextPrimary
    button.BorderSizePixel = 0
    button.Font = Enum.Font.GothamBold
    button.TextSize = 13
    button.AutoButtonColor = false
    button.Parent = scrollFrame
    AddCorner(button, 10)
    AddStroke(button, Theme.Stroke, 1)
    
    button.MouseEnter:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            BackgroundColor3 = Theme.SurfaceAlt
        }):Play()
        if button:FindFirstChildOfClass("UIStroke") then
            TweenService:Create(button:FindFirstChildOfClass("UIStroke"), TweenInfo.new(0.15), {
                Color = Theme.Accent,
                Thickness = 2
            }):Play()
        end
    end)
    
    button.MouseLeave:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            BackgroundColor3 = Theme.Surface
        }):Play()
        if button:FindFirstChildOfClass("UIStroke") then
            TweenService:Create(button:FindFirstChildOfClass("UIStroke"), TweenInfo.new(0.15), {
                Color = Theme.Stroke,
                Thickness = 1
            }):Play()
        end
    end)
    
    button.MouseButton1Click:Connect(callback)
    
    return button
end

local function createColorPicker(name, yPos, currentColor, callback)
    local frame = Instance.new("Frame")
    frame.Name = name.."_ColorPicker"
    frame.Size = UDim2.new(1, -32, 0, 50)
    frame.Position = UDim2.new(0, 8, 0, yPos)
    frame.BackgroundColor3 = Theme.Surface
    frame.BorderSizePixel = 0
    frame.Parent = scrollFrame
    AddCorner(frame, 10)
    AddStroke(frame, Theme.Stroke, 1)
    
    local label = Instance.new("TextLabel")
    label.Text = name
    label.Size = UDim2.new(0.6, 0, 1, 0)
    label.Position = UDim2.new(0, 12, 0, 0)
    label.BackgroundTransparency = 1
    label.TextColor3 = Theme.TextPrimary
    label.Font = Enum.Font.GothamBold
    label.TextSize = 14
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame
    
    local colorButton = Instance.new("TextButton")
    colorButton.Text = ""
    colorButton.Size = UDim2.new(0, 70, 0, 34)
    colorButton.Position = UDim2.new(1, -80, 0.5, -17)
    colorButton.BackgroundColor3 = currentColor
    colorButton.BorderSizePixel = 0
    colorButton.AutoButtonColor = false
    colorButton.Parent = frame
    AddCorner(colorButton, 8)
    AddStroke(colorButton, Theme.Stroke, 1)
    
    colorButton.MouseButton1Click:Connect(function()
        local colors = {
            Color3.fromRGB(255, 0, 0),
            Color3.fromRGB(0, 255, 0),
            Color3.fromRGB(0, 0, 255),
            Color3.fromRGB(255, 255, 0),
            Color3.fromRGB(255, 0, 255),
            Color3.fromRGB(0, 255, 255),
            Color3.fromRGB(255, 165, 0),
            Color3.fromRGB(128, 0, 128),
        }
        
        local currentIndex = 1
        for i, color in ipairs(colors) do
            if color == currentColor then
                currentIndex = i
                break
            end
        end
        
        currentIndex = currentIndex + 1
        if currentIndex > #colors then currentIndex = 1 end
        
        currentColor = colors[currentIndex]
        colorButton.BackgroundColor3 = currentColor
        callback(currentColor)
    end)
    
    return frame, colorButton
end

local function createInputField(name, yPos, defaultValue, callback)
    local frame = Instance.new("Frame")
    frame.Name = name.."_Input"
    frame.Size = UDim2.new(1, -32, 0, 50)
    frame.Position = UDim2.new(0, 8, 0, yPos)
    frame.BackgroundColor3 = Theme.Surface
    frame.BorderSizePixel = 0
    frame.Parent = scrollFrame
    AddCorner(frame, 10)
    AddStroke(frame, Theme.Stroke, 1)
    
    local label = Instance.new("TextLabel")
    label.Text = name
    label.Size = UDim2.new(0.4, 0, 1, 0)
    label.Position = UDim2.new(0, 12, 0, 0)
    label.BackgroundTransparency = 1
    label.TextColor3 = Theme.TextPrimary
    label.Font = Enum.Font.GothamBold
    label.TextSize = 14
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame
    
    local inputBox = Instance.new("TextBox")
    inputBox.Text = tostring(defaultValue)
    inputBox.Size = UDim2.new(0, 120, 0, 30)
    inputBox.Position = UDim2.new(1, -130, 0.5, -15)
    inputBox.BackgroundColor3 = Theme.SurfaceAlt
    inputBox.TextColor3 = Theme.TextPrimary
    inputBox.Font = Enum.Font.Gotham
    inputBox.TextSize = 13
    inputBox.TextXAlignment = Enum.TextXAlignment.Center
    inputBox.PlaceholderText = "Enter value..."
    inputBox.ClearTextOnFocus = false
    inputBox.Parent = frame
    AddCorner(inputBox, 6)
    AddStroke(inputBox, Theme.Stroke, 1)
    
    local lastValue = tostring(defaultValue)
    
    -- Auto-apply when user presses Enter or loses focus
    inputBox.FocusLost:Connect(function(enterPressed)
        local newValue = tonumber(inputBox.Text)
        if newValue and newValue >= 0 and newValue <= 500 then
            callback(newValue)
            lastValue = inputBox.Text
        else
            showNotification("Error", "Invalid value! Must be 0-500", 2, Theme.Error)
            inputBox.Text = lastValue
        end
    end)
    
    return frame, inputBox
end

-- ========= BUILD UI =========
local yPos = 8
local SECTION_GAP = 16

createSection("Movement", yPos)
yPos = yPos + 43

createToggle("Speed Lock", yPos, function(state)
    speedEnforced = state
    local h = speedHumanoid
    if not h or not h.Parent then return end
    if state then
        if not speedTickConn then
            speedLastTick = 0
            speedTickConn = RunService.Heartbeat:Connect(heartbeat)
        end
        if canEnforce() then setWalkSpeed(h, speedCurrent) end
        showNotification("Speed", "Speed Lock enabled", 3, Theme.Success)
    else
        disconnectAll()
        applyDisabledState()
        showNotification("Speed", "Speed Lock disabled", 3, Theme.Warning)
    end
end, speedEnforced)
yPos = yPos + 54

createInputField("Walk Speed", yPos, speedCurrent, function(value)
    speedCurrent = value
    if speedEnforced and canEnforce() then setWalkSpeed(speedHumanoid, speedCurrent) end
end)
yPos = yPos + 54

createButton("Reset Speed", yPos, function()
    speedCurrent = canonicalDefault()
    -- Update input field value
    local inputFrame = scrollFrame:FindFirstChild("Walk Speed_Input")
    if inputFrame then
        local inputBox = inputFrame:FindFirstChildOfClass("TextBox")
        if inputBox then
            inputBox.Text = tostring(speedCurrent)
            -- Trigger the callback to apply the value
            speedCurrent = canonicalDefault()
            callback = function(value)
                speedCurrent = value
                if speedEnforced and canEnforce() then setWalkSpeed(speedHumanoid, speedCurrent) end
            end
            callback(speedCurrent)
        end
    end
    if speedHumanoid and speedHumanoid.Parent then
        if speedEnforced and canEnforce() then setWalkSpeed(speedHumanoid, speedCurrent) else applyDisabledState() end
    end
end)
yPos = yPos + 49

createToggle("Noclip", yPos, function(state)
    setNoclip(state)
end, noclipEnabled)
yPos = yPos + 54

yPos = yPos + SECTION_GAP
createSection("Teleports", yPos)
yPos = yPos + 43

createButton("Teleport to Killer", yPos, function()
    teleportToNearest("Killer")
end)
yPos = yPos + 49

createButton("Teleport to Teammate", yPos, function()
    teleportToNearest("Survivor")
end)
yPos = yPos + 49

yPos = yPos + SECTION_GAP
createSection("ESP", yPos)
yPos = yPos + 43

createToggle("Player ESP", yPos, function(state)
    playerESPEnabled = state
    for _, pl in ipairs(Players:GetPlayers()) do
        if pl ~= LP then applyPlayerESP(pl) end
    end
end, playerESPEnabled)
yPos = yPos + 54

createToggle("Nametags", yPos, function(state)
    nametagsEnabled = state
    for _, pl in ipairs(Players:GetPlayers()) do
        if pl ~= LP then applyPlayerESP(pl) end
    end
end, nametagsEnabled)
yPos = yPos + 54

createColorPicker("Survivor Color", yPos, survivorColor, function(color)
    survivorColor = color
    for _, pl in ipairs(Players:GetPlayers()) do
        if pl ~= LP then applyPlayerESP(pl) end
    end
end)
yPos = yPos + 54

createColorPicker("Killer Color", yPos, killerBaseColor, function(color)
    killerBaseColor = color
    killerColors.Killer = color
    for _, pl in ipairs(Players:GetPlayers()) do
        if pl ~= LP then applyPlayerESP(pl) end
    end
end)
yPos = yPos + 54

yPos = yPos + SECTION_GAP
createSection("World ESP", yPos)
yPos = yPos + 43

createToggle("Generators", yPos, function(state)
    setWorldToggle("Generator", state)
end, worldEnabled.Generator)
yPos = yPos + 54

createToggle("Hooks", yPos, function(state)
    setWorldToggle("Hook", state)
end, worldEnabled.Hook)
yPos = yPos + 54

createToggle("Gates", yPos, function(state)
    setWorldToggle("Gate", state)
end, worldEnabled.Gate)
yPos = yPos + 54

createToggle("Windows", yPos, function(state)
    setWorldToggle("Window", state)
end, worldEnabled.Window)
yPos = yPos + 54

createToggle("Pallets", yPos, function(state)
    setWorldToggle("Palletwrong", state)
end, worldEnabled.Palletwrong)
yPos = yPos + 54

yPos = yPos + SECTION_GAP
createSection("Auto Repair", yPos)
yPos = yPos + 43

createToggle("Repair All Generators", yPos, function(state)
    setAutoRepair(state)
end, false)
yPos = yPos + 54

createToggle("No Skillchecks", yPos, function(state)
    noSkillToggleUser = state
    evalNoSkill()
end, noSkillToggleUser)
yPos = yPos + 54

createToggle("Killer Ability Notify", yPos, function(state)
    abilityNotifyEnabled = state
end, abilityNotifyEnabled)
yPos = yPos + 54

yPos = yPos + SECTION_GAP
createSection("Visual Effects", yPos)
yPos = yPos + 43

createToggle("Fullbright", yPos, function(state)
    fullbrightEnabled = state
    if fbLoop then task.cancel(fbLoop) fbLoop = nil end
    if state then
        fbLoop = task.spawn(function()
            while fullbrightEnabled do
                Lighting.Brightness = 2
                Lighting.ClockTime = 14
                Lighting.FogStart = 0
                Lighting.FogEnd = 1e9
                Lighting.GlobalShadows = false
                Lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
                Lighting.ExposureCompensation = 0
                task.wait(0.5)
            end
        end)
    else
        for k, v in pairs(initLighting) do pcall(function() if v ~= nil then Lighting[k] = v end end) end
        desiredClockTime = Lighting.ClockTime
    end
end, fullbrightEnabled)
yPos = yPos + 54

createSlider("Time Of Day", yPos, 0, 24, Lighting.ClockTime, function(value)
    desiredClockTime = value
    Lighting.ClockTime = value
    bindTimeLock()
end)
yPos = yPos + 60

yPos = yPos + SECTION_GAP
createSection("Misc", yPos)
yPos = yPos + 43

createToggle("Bypass Pursuit Pallet Lock", yPos, function(state)
    pursuitBypassEnabled = state
    showNotification("Pallet Fix", state and "Bypass aktif" or "Bypass nonaktif", 3, state and Theme.Success or Theme.Warning)
end, pursuitBypassEnabled)
yPos = yPos + 54

createToggle("Anti AFK", yPos, function(state)
    setAntiAFK(state)
end, false)
yPos = yPos + 54

createButton("🧹 Cleanup All", yPos, function()
    cleanupAll()
end)
yPos = yPos + 49

scrollFrame.CanvasSize = UDim2.new(0, 0, 0, yPos + 50)

-- ========= BUTTON FUNCTIONALITY =========
local minimized = false
minimizeBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    contentFrame.Visible = not minimized
    
    if minimized then
        minimizeBtn.Text = "+"
        TweenService:Create(mainBox, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Size = UDim2.new(0, 320, 0, 40)
        }):Play()
    else
        minimizeBtn.Text = "−"
        TweenService:Create(mainBox, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Size = UDim2.new(0, 320, 0, 480)
        }):Play()
    end
end)

closeBtn.MouseButton1Click:Connect(function()
    if speedEnforced then speedEnforced = false end
    if noclipEnabled then setNoclip(false) end
    if fullbrightEnabled then fullbrightEnabled = false end
    
    TweenService:Create(mainBox, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
        Size = UDim2.new(0, 0, 0, 0),
        BackgroundTransparency = 1
    }):Play()
    task.wait(0.2)
    screenGui:Destroy()
    showNotification("Violence District", "GUI Closed", 4, Theme.Warning)
end)

-- ========= DRAG FUNCTIONALITY =========
local dragging = false
local dragStart
local boxStart

titleBar.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.UserInputType == Enum.UserInputType.MouseButton1 or 
       input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        boxStart = mainBox.Position
    end
end)

titleBar.InputEnded:Connect(function(input, gpe)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or 
       input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

UserInputService.InputChanged:Connect(function(input, gpe)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or 
                     input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        mainBox.Position = boxStart + UDim2.new(0, delta.X, 0, delta.Y)
    end
end)

-- ========= MEMORY CLEANUP =========
local function cleanupPalletStates()
    for model, state in pairs(palletState) do
        if not alive(model) then
            palletState[model] = nil
        end
    end
    for model, state in pairs(windowState) do
        if not alive(model) then
            windowState[model] = nil
        end
    end
end

-- Run cleanup every 10 seconds
local cleanupTask = task.spawn(function()
    while true do
        task.wait(10)
        cleanupPalletStates()
    end
end)
addCleanupTask(cleanupTask)

-- Auto cleanup on game leave
game:BindToClose(function()
    cleanupAll()
end)

-- ========= INITIALIZATION =========
task.wait(0.5)
showNotification("Violence District", "Clean UI loaded successfully!", 4, Theme.Success)
showNotification("Crash Fix", "Pallet crash issues fixed!", 4, Theme.Success)
showNotification("Error Fix", "CoreGui nil value error fixed!", 4, Theme.Success)
showNotification("Pallet Fix", "Killer pallet crash protection active!", 4, Theme.Success)


