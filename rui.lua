-- RUI by ren (@wtf_renn)
-- my ui lib, dm if it breaks
-- v2.1 10/14, added servers tab + more themes

-- some execs remap the globals so GetService can get fiddled with, grab em up front
local cloneref = cloneref or clonereference or function(x)
    return x
end

local CoreGui = cloneref(game:GetService("CoreGui"))
local UserInputService = cloneref(game:GetService("UserInputService"))
local TweenService = cloneref(game:GetService("TweenService"))
local RunService = cloneref(game:GetService("RunService"))
local HttpService = cloneref(game:GetService("HttpService"))
local TextService = cloneref(game:GetService("TextService"))
local Players = cloneref(game:GetService("Players"))
local TeleportService = cloneref(game:GetService("TeleportService"))
local GuiService = cloneref(game:GetService("GuiService"))
local Workspace = cloneref(game:GetService("Workspace"))
local VirtualUser = cloneref(game:GetService("VirtualUser"))

-- kill last ui if we re-execute
if _G.__RUI_Cleanup then
    pcall(_G.__RUI_Cleanup)
end
if _G.__PremiumUI_Cleanup then -- old name, keep checking so old execs still cleanup
    pcall(_G.__PremiumUI_Cleanup)
end

local LocalPlayer = Players.LocalPlayer

-- phone check, sizes get fixed later too
local isConsole = GuiService:IsTenFootInterface()
local isTouch = UserInputService.TouchEnabled
local isMobile = isTouch and not isConsole

local ProtectGui = protectgui or (syn and syn.protect_gui) or function() end
local GetHui = gethui or function() return CoreGui end

-- tracks connections + guis so unload actually cleans up
local cons = {}
local function track(x)
    table.insert(cons, x)
    return x
end

-- destructive actions look the same on every theme so they read as destructive
local DANGER = Color3.fromRGB(235, 90, 90)

-- toggle paint fns, so SetTheme can refresh them (declared up here
-- cause Theme is defined before Library)
local toggleRefresh = {}

-- helpers (make stuff, tween, http)
local function mk(className, props)
    local i = Instance.new(className)
    for k, v in pairs(props or {}) do
        i[k] = v
    end
    if i:IsA("TextLabel") or i:IsA("TextButton") then
        i.TextStrokeTransparency = 1
    end
    return i
end

local function addShadow(parent, transparency, radius)
    transparency = transparency or 0.5
    radius = radius or 15
    local s = mk("ImageLabel", {
        Name = "Shadow",
        Parent = parent,
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundTransparency = 1,
        Position = UDim2.new(0.5, 0, 0.5, 2),
        Size = UDim2.new(1, radius * 2, 1, radius * 2),
        ZIndex = parent.ZIndex - 1,
        Image = "rbxassetid://13192868549",
        ImageColor3 = Color3.new(0, 0, 0),
        ImageTransparency = transparency,
        ScaleType = Enum.ScaleType.Slice,
        SliceCenter = Rect.new(256, 256, 256, 256)
    })
    return s
end

local function tween(obj, props, time, style, dir)
    time = time or 0.2
    style = style or Enum.EasingStyle.Quad
    dir = dir or Enum.EasingDirection.Out
    local tw = TweenService:Create(obj, TweenInfo.new(time, style, dir), props)
    tw:Play()
    return tw
end

local function httpGet(url)
    if request then
        local r = request({Url = url, Method = "GET"})
        if r and (r.Body or r.body) then return r.Body or r.body end
    elseif http_request then
        local r = http_request({Url = url, Method = "GET"})
        if r and (r.Body or r.body) then return r.Body or r.body end
    elseif syn and syn.request then
        local r = syn.request({Url = url, Method = "GET"})
        if r and (r.Body or r.body) then return r.Body or r.body end
    end
    return HttpService:GetAsync(url)
end

-- themes, add more if u want
local Theme = {
    Themes = {
        Dark = {
            Background = Color3.fromRGB(15, 15, 20),
            Container = Color3.fromRGB(24, 24, 32),
            Section = Color3.fromRGB(20, 20, 28),
            Border = Color3.fromRGB(40, 40, 50),
            Accent = Color3.fromRGB(220, 220, 230),
            Text = Color3.fromRGB(255, 255, 255),
            SubText = Color3.fromRGB(170, 170, 185),
            Hover = Color3.fromRGB(32, 32, 42),
            Click = Color3.fromRGB(18, 18, 24),
            Notification = Color3.fromRGB(25, 25, 35),
            Shadow = Color3.fromRGB(0, 0, 0)
        },
        Light = {
            Background = Color3.fromRGB(235, 235, 240),
            Container = Color3.fromRGB(220, 220, 228),
            Section = Color3.fromRGB(225, 225, 232),
            Border = Color3.fromRGB(200, 200, 210),
            Accent = Color3.fromRGB(40, 60, 100),
            Text = Color3.fromRGB(20, 20, 30),
            SubText = Color3.fromRGB(100, 100, 115),
            Hover = Color3.fromRGB(210, 210, 218),
            Click = Color3.fromRGB(200, 200, 208),
            Notification = Color3.fromRGB(215, 215, 222),
            Shadow = Color3.fromRGB(0, 0, 0)
        },
        Midnight = {
            Background = Color3.fromRGB(10, 12, 22),
            Container = Color3.fromRGB(18, 20, 32),
            Section = Color3.fromRGB(14, 16, 28),
            Border = Color3.fromRGB(35, 40, 60),
            Accent = Color3.fromRGB(70, 150, 255),
            Text = Color3.fromRGB(255, 255, 255),
            SubText = Color3.fromRGB(170, 185, 210),
            Hover = Color3.fromRGB(26, 28, 42),
            Click = Color3.fromRGB(12, 14, 24),
            Notification = Color3.fromRGB(20, 22, 35),
            Shadow = Color3.fromRGB(0, 0, 0)
        },
        Forest = {
            Background = Color3.fromRGB(12, 20, 14),
            Container = Color3.fromRGB(20, 30, 22),
            Section = Color3.fromRGB(16, 24, 18),
            Border = Color3.fromRGB(38, 50, 40),
            Accent = Color3.fromRGB(90, 215, 110),
            Text = Color3.fromRGB(255, 255, 255),
            SubText = Color3.fromRGB(175, 195, 180),
            Hover = Color3.fromRGB(28, 40, 30),
            Click = Color3.fromRGB(14, 22, 16),
            Notification = Color3.fromRGB(22, 32, 24),
            Shadow = Color3.fromRGB(0, 0, 0)
        },
        Ruby = {
            Background = Color3.fromRGB(20, 12, 12),
            Container = Color3.fromRGB(32, 18, 18),
            Section = Color3.fromRGB(28, 14, 14),
            Border = Color3.fromRGB(55, 35, 35),
            Accent = Color3.fromRGB(255, 85, 85),
            Text = Color3.fromRGB(255, 255, 255),
            SubText = Color3.fromRGB(205, 170, 170),
            Hover = Color3.fromRGB(42, 26, 26),
            Click = Color3.fromRGB(24, 12, 12),
            Notification = Color3.fromRGB(35, 20, 20),
            Shadow = Color3.fromRGB(0, 0, 0)
        },
        Ocean = {
            Background = Color3.fromRGB(8, 18, 26),
            Container = Color3.fromRGB(14, 28, 38),
            Section = Color3.fromRGB(10, 22, 32),
            Border = Color3.fromRGB(28, 50, 65),
            Accent = Color3.fromRGB(90, 215, 235),
            Text = Color3.fromRGB(235, 250, 255),
            SubText = Color3.fromRGB(165, 210, 220),
            Hover = Color3.fromRGB(20, 38, 50),
            Click = Color3.fromRGB(8, 20, 30),
            Notification = Color3.fromRGB(16, 32, 44),
            Shadow = Color3.fromRGB(0, 0, 0)
        },
    },
    CurrentTheme = "Midnight",
    themed = {}
}
Theme.Themes.Default = Theme.Themes[Theme.CurrentTheme]

function Theme:Register(instance, property, themeKey)
    local count = #self.themed
    for i = count, 1, -1 do
        local obj = self.themed[i]
        if not obj.Instance or not obj.Instance.Parent then
            table.remove(self.themed, i)
        elseif obj.Instance == instance and obj.Property == property then
            obj.Key = themeKey
            instance[property] = self.Themes[self.CurrentTheme][themeKey]
            return
        end
    end
    table.insert(self.themed, { Instance = instance, Property = property, Key = themeKey })
    if instance and instance.Parent then
        instance[property] = self.Themes[self.CurrentTheme][themeKey]
    end
end

function Theme:UpdateTheme()
    local theme = self.Themes[self.CurrentTheme]
    local i = 1
    while i <= #self.themed do
        local obj = self.themed[i]
        if obj and obj.Instance and obj.Instance.Parent then
            obj.Instance[obj.Property] = theme[obj.Key]
            i = i + 1
        else
            table.remove(self.themed, i)
        end
    end
end

function Theme:SetTheme(name)
    if not self.Themes[name] or self.CurrentTheme == name then return end
    self.CurrentTheme = name
    self.Themes.Default = self.Themes[name]
    self:UpdateTheme()
    for _, fn in ipairs(toggleRefresh) do
        pcall(fn, false)
    end
end

-- only one thing drags at a time, the topbar and the bottom bar both move the
-- window so without this they fight each other
local activeDrag = nil

-- most recently clicked window sits on top of the others
local topOrder = 0
local function bringToFront(g)
    topOrder = topOrder + 1
    g.DisplayOrder = topOrder
end

-- set while a keybind element is waiting for a key, so escape closes the window
-- instead of cancelling the bind
local listeningKeybind = false

-- drag windows around by the top bar
local function drag(topbar, window)
    local token = {}
    local dragging, dragInput, dragStart, startPos
    
    track(topbar.InputBegan:Connect(function(input)
        if activeDrag and activeDrag ~= token then return end
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            activeDrag = token
            dragging = true
            dragStart = input.Position
            startPos = window.Position
        end
    end))
    
    track(UserInputService.InputEnded:Connect(function(input)
        if activeDrag ~= token then return end
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            activeDrag = nil
            dragging = false
        end
    end))
    
    track(topbar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end))
    
    track(UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            tween(window, {
                Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            }, 0.08, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
        end
    end))
end

-- notifs
local notifs = {
    Enabled = true,
    Gui = nil,
    Container = nil,
    Active = {},
    Queue = {},
    busy = false
}

function notifs:Init(parent)
    if self.Gui and self.Gui.Parent and self.Container and self.Container.Parent then
        return -- already got one, reuse it
    end
    self.Gui = mk("ScreenGui", {
        Name = "RUI_Notifs",
        Parent = parent,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    })
    ProtectGui(self.Gui)
    
    self.Container = mk("Frame", {
        Name = "Container",
        Parent = self.Gui,
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -20, 1, -20),
        Size = UDim2.new(0, 300, 1, -40),
        AnchorPoint = Vector2.new(1, 1)
    })
    
    mk("UIListLayout", {
        Parent = self.Container,
        SortOrder = Enum.SortOrder.LayoutOrder,
        VerticalAlignment = Enum.VerticalAlignment.Bottom,
        Padding = UDim.new(0, 10)
    })
end

function notifs:dismiss(notifData)
    local notif = notifData.Frame
    if not notif or not notif.Parent then
        for i, d in ipairs(self.Active) do
            if d == notifData then table.remove(self.Active, i) break end
        end
        return
    end
    
    if notifData.dead then return end
    notifData.dead = true
    
    for i, d in ipairs(self.Active) do
        if d == notifData then table.remove(self.Active, i) break end
    end
    
    tween(notifData.TitleLbl, {TextTransparency = 1}, 0.2)
    tween(notifData.DescLbl, {TextTransparency = 1}, 0.2)
    tween(notifData.BarBg, {BackgroundTransparency = 1}, 0.2)
    tween(notifData.Bar, {BackgroundTransparency = 1}, 0.2)
    tween(notifData.AccentBar, {BackgroundTransparency = 1}, 0.2)
    tween(notifData.CloseBtn, {TextTransparency = 1, BackgroundTransparency = 1}, 0.2)
    tween(notif, {BackgroundTransparency = 1}, 0.2)
    local stroke = notif:FindFirstChildOfClass("UIStroke")
    if stroke then tween(stroke, {Transparency = 1}, 0.2) end
    
    task.wait(0.2)
    
    if notif and notif.Parent then
        tween(notif, {Position = UDim2.new(1, 50, notif.Position.Y.Scale, notif.Position.Y.Offset)}, 0.2)
        task.wait(0.2)
        if notif and notif.Parent then
            notif:Destroy()
        end
    end
end

function notifs:Notify(title, desc, duration)
    if not self.Enabled then return end
    duration = duration or 5
    
    if self.busy then
        table.insert(self.Queue, {title, desc, duration})
        return
    end
    
    self.busy = true
    
    if #self.Active >= 3 then
        local oldest = self.Active[1]
        task.spawn(function()
            pcall(function() self:dismiss(oldest) end)
            task.wait(0.2)
            local ok, err = pcall(function() self:showNotif(title, desc, duration) end)
            if not ok then warn("notif broke: " .. tostring(err)) end
            self.busy = false
            if #self.Queue > 0 then
                local q = table.remove(self.Queue, 1)
                self:Notify(q[1], q[2], q[3])
            end
        end)
    else
        task.spawn(function()
            local ok, err = pcall(function() self:showNotif(title, desc, duration) end)
            if not ok then warn("notif broke: " .. tostring(err)) end
            self.busy = false
            if #self.Queue > 0 then
                local q = table.remove(self.Queue, 1)
                self:Notify(q[1], q[2], q[3])
            end
        end)
    end
end

function notifs:showNotif(title, desc, duration)
    local notif = mk("Frame", {
        Parent = self.Container,
        Size = UDim2.new(1, 0, 0, 0),
        BackgroundTransparency = 1,
        ClipsDescendants = true,
        Position = UDim2.new(1, 50, 0, 0)
    })
    Theme:Register(notif, "BackgroundColor3", "Notification")
    mk("UICorner", { Parent = notif, CornerRadius = UDim.new(0, 12) })
    local stroke = mk("UIStroke", { Parent = notif, Thickness = 1, Color = Theme.Themes.Default.Border, Transparency = 0.5 })
    Theme:Register(stroke, "Color", "Border")
    
    addShadow(notif, 0.4, 15)
    
    local dot = mk("Frame", {
        Parent = notif,
        Position = UDim2.new(0, 12, 0, 15),
        Size = UDim2.new(0, 8, 0, 8),
        BackgroundTransparency = 1,
        BorderSizePixel = 0
    })
    Theme:Register(dot, "BackgroundColor3", "Accent")
    mk("UICorner", {Parent = dot, CornerRadius = UDim.new(1, 0)})
    
    local titleLbl = mk("TextLabel", {
        Parent = notif,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 26, 0, 10),
        Size = UDim2.new(1, -60, 0, 18),
        Font = Enum.Font.GothamBold,
        Text = title,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTransparency = 1
    })
    Theme:Register(titleLbl, "TextColor3", "Text")
    
    local descLbl = mk("TextLabel", {
        Parent = notif,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 26, 0, 30),
        Size = UDim2.new(1, -42, 0, 14),
        Font = Enum.Font.GothamMedium,
        Text = desc,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextWrapped = true,
        TextTransparency = 1
    })
    Theme:Register(descLbl, "TextColor3", "SubText")
    
    local closeBtn = mk("TextButton", {
        Parent = notif,
        Position = UDim2.new(1, -26, 0, 8),
        Size = UDim2.new(0, 20, 0, 20),
        BackgroundTransparency = 1,
        Text = "x",
        Font = Enum.Font.GothamBold,
        TextSize = 14,
        TextTransparency = 1,
        AutoButtonColor = false
    })
    Theme:Register(closeBtn, "TextColor3", "SubText")
    
    local bounds = TextService:GetTextSize(desc, 12, Enum.Font.Gotham, Vector2.new(258, math.huge))
    local descHeight = math.max(14, bounds.Y)
    local totalHeight = 30 + descHeight + 14
    
    local barBg = mk("Frame", {
        Parent = notif,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 12, 1, -8),
        Size = UDim2.new(1, -24, 0, 3),
        BackgroundTransparency = 1
    })
    Theme:Register(barBg, "BackgroundColor3", "Border")
    mk("UICorner", {Parent = barBg, CornerRadius = UDim.new(1, 0)})
    
    local bar = mk("Frame", {
        Parent = barBg,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1
    })
    Theme:Register(bar, "BackgroundColor3", "Accent")
    mk("UICorner", {Parent = bar, CornerRadius = UDim.new(1, 0)})
    
    local notifData = {
        Frame = notif,
        TitleLbl = titleLbl,
        DescLbl = descLbl,
        BarBg = barBg,
        Bar = bar,
        AccentBar = dot,
        CloseBtn = closeBtn,
        dead = false
    }
    table.insert(self.Active, notifData)
    
    track(closeBtn.MouseEnter:Connect(function()
        if notifData.dead then return end
        closeBtn.TextColor3 = Theme.Themes.Default.Text
    end))
    track(closeBtn.MouseLeave:Connect(function()
        if notifData.dead then return end
        closeBtn.TextColor3 = Theme.Themes.Default.SubText
    end))
    track(closeBtn.MouseButton1Down:Connect(function()
        if notifData.dead then return end
        closeBtn.TextColor3 = Theme.Themes.Default.Click
    end))
    track(closeBtn.MouseButton1Up:Connect(function()
        if notifData.dead then return end
        closeBtn.TextColor3 = Theme.Themes.Default.Text
    end))
    track(closeBtn.MouseButton1Click:Connect(function()
        if notifData.dead then return end
        self:dismiss(notifData)
    end))
    
    tween(notif, {Size = UDim2.new(1, 0, 0, totalHeight), Position = UDim2.new(0, 0, 0, 0), BackgroundTransparency = 0}, 0.35, Enum.EasingStyle.Back)
    tween(titleLbl, {TextTransparency = 0}, 0.3)
    tween(descLbl, {TextTransparency = 0}, 0.3)
    tween(barBg, {BackgroundTransparency = 0.5}, 0.3)
    tween(bar, {BackgroundTransparency = 0}, 0.3)
    tween(dot, {BackgroundTransparency = 0}, 0.3)
    tween(closeBtn, {TextTransparency = 0}, 0.3)
    tween(stroke, {Transparency = 0.5}, 0.3)
    
    task.spawn(function()
        local t = tween(bar, {Size = UDim2.new(0, 0, 1, 0)}, duration, Enum.EasingStyle.Linear)
        t.Completed:Wait()
        
        if notifData.dead then return end
        self:dismiss(notifData)
    end)
end

-- saved flags for reset button n stuff
-- flagDefs and flagValues get filled the second someone calls CreateToggle and not
-- when the tab actually builds, otherwise reset + configs do nothing if they never
-- opened that tab. savedFlags holds the Set() closures once the element exists.
local savedFlags = {}
local flagDefs = {}
local flagValues = {}
local flagCount = 0

local function nextFlag()
    flagCount = flagCount + 1
    return "__flag_" .. flagCount
end

local function registerFlag(name, default, kind)
    if not name then return end
    if not flagDefs[name] then
        flagDefs[name] = {Default = default, Kind = kind}
    end
    if flagValues[name] == nil then
        flagValues[name] = default
    end
end

-- saved key for the gate, tied to the hwid so a key pasted onto another
-- machine dont just quietly work
local KEY_FOLDER = "RUI"
local keyFileName = KEY_FOLDER .. "/key.txt"

local function getHwid()
    if gethwid then
        local ok, id = pcall(gethwid)
        if ok and id then
            return tostring(id)
        end
    end
    return "nohwid"
end

local function readKey()
    if not isfile or not readfile then return nil end
    local ok, raw = pcall(function()
        if not isfile(keyFileName) then return nil end
        return readfile(keyFileName)
    end)
    if not ok or not raw then return nil end
    local key, hwid = tostring(raw):match("^(.-)|(.*)$")
    if not key or key == "" or hwid ~= getHwid() then return nil end
    return key
end

local function writeKey(key)
    if not writefile then return end
    pcall(function()
        if isfolder and not isfolder(KEY_FOLDER) then makefolder(KEY_FOLDER) end
        writefile(keyFileName, key .. "|" .. getHwid())
    end)
end

local function clearKey()
    local del = delfile or deletefile
    if not del or not isfile then return end
    pcall(function()
        if isfile(keyFileName) then del(keyFileName) end
    end)
end

-- ============ configs ============
local function storeFlag(name, val)
    if not name then return end
    flagValues[name] = val
    local obj = savedFlags[name]
    if obj then obj.Value = val end
end

-- elements build lazy so they have to start from whatever the loaded config says,
-- otherwise opening a tab for the first time after a load stomps the saved value
local function flagStart(compDef, fallback)
    if compDef.Flag then
        local v = flagValues[compDef.Flag]
        if v ~= nil then return v end
    end
    return fallback
end

-- saved ui setups, name to json in RUI/Configs
local CONFIG_FOLDER = "RUI/Configs"

local function cleanCfgName(name)
    name = tostring(name or ""):gsub("[^%w%-_]", "")
    if #name == 0 then return nil end
    if #name > 40 then name = name:sub(1, 40) end
    return name
end

local function cfgPath(name)
    return CONFIG_FOLDER .. "/" .. name .. ".cfg"
end

local function ensureFolder()
    if not isfolder or not makefolder then return end
    if not isfolder(KEY_FOLDER) then makefolder(KEY_FOLDER) end
    if not isfolder(CONFIG_FOLDER) then makefolder(CONFIG_FOLDER) end
end

local function writeJson(path, data)
    if not writefile then return false end
    local ok = pcall(function()
        ensureFolder()
        writefile(path, HttpService:JSONEncode(data))
    end)
    return ok
end

local function readJson(path)
    if not isfile or not readfile then return nil end
    local ok, raw = pcall(function()
        if not isfile(path) then return nil end
        return readfile(path)
    end)
    if not ok or not raw then return nil end
    local ok2, data = pcall(function()
        return HttpService:JSONDecode(raw)
    end)
    if not ok2 or type(data) ~= "table" then return nil end
    return data
end

-- main lib
local Library = {
    Windows = {},
    Unloaded = false,
    ToggleKeybind = Enum.KeyCode.RightShift,
    -- key services, plug one in before CreateWindow and the gate just works
    Services = {},
    -- flip on if u want errors popping up instead of vanishing
    Debug = false,
    Gate = nil
}

function Library:SafeCallback(callback, ...)
    if not callback then return end
    local args = {...}
    task.spawn(function()
        local ok, err = pcall(function()
            callback(unpack(args))
        end)
        if not ok and Library.Debug then
            notifs:Notify("Error", tostring(err), 8)
        end
    end)
end

function Library:Notify(title, desc, duration)
    return notifs:Notify(title, desc, duration)
end

-- ---- theme stuff, was only reachable from the customize tab before ----

function Library:SetTheme(name)
    Theme:SetTheme(name)
    return self:GetCurrentTheme()
end

function Library:GetThemes()
    local names = {}
    for name in pairs(Theme.Themes) do
        if name ~= "Default" then
            table.insert(names, name)
        end
    end
    table.sort(names)
    return names
end

function Library:GetCurrentTheme()
    return Theme.CurrentTheme
end

-- lets people drop in their own presets without editing the table
function Library:AddTheme(name, colors)
    if type(name) ~= "string" or type(colors) ~= "table" then return false end
    local full = {}
    local base = Theme.Themes[Theme.CurrentTheme] or Theme.Themes.Midnight
    for key, val in pairs(base) do
        full[key] = val
    end
    for key, val in pairs(colors) do
        full[key] = val
    end
    Theme.Themes[name] = full
    return true
end

-- ---- key services ----

function Library:RegisterService(name, def)
    if type(name) ~= "string" or type(def) ~= "table" then return false end
    self.Services[name] = def
    return true
end

function Library:HasKey()
    local e = (getgenv and getgenv()) or _G
    return e.SCRIPT_KEY ~= nil
end

function Library:WaitForKey(timeout)
    local deadline = timeout and (os.clock() + timeout) or nil
    while not self:HasKey() do
        if deadline and os.clock() > deadline then
            return false
        end
        task.wait(0.1)
    end
    return true
end

function Library:Unload()
    if self.Unloaded then return end
    self.Unloaded = true
    for _, c in pairs(cons) do
        pcall(function()
            if typeof(c) == "RBXScriptConnection" then
                c:Disconnect()
            elseif typeof(c) == "Instance" then
                c:Destroy()
            end
        end)
    end
    table.clear(cons)
    if notifs.Gui then
        notifs.Gui:Destroy()
    end
    table.clear(Theme.themed)
    table.clear(savedFlags)
    table.clear(flagValues)
    table.clear(toggleRefresh)
    table.clear(Library.Windows)
end

function Library:GetWindow()
    return self.Windows[1]
end

-- ============ configs ============
-- flags go in as plain values, a keybind gets stored by its name since json
-- has no idea what an Enum is

local function packFlags()
    local out = {}
    for name, def in pairs(flagDefs) do
        local val = flagValues[name]
        if val == nil then
            val = def.Default
        end
        if typeof(val) == "EnumItem" then
            val = val.Name
        elseif type(val) == "boolean" or type(val) == "number" or type(val) == "string" then
            -- already json friendly
        else
            val = tostring(val)
        end
        out[name] = val
    end
    return out
end

local function unpackFlags(packed)
    if type(packed) ~= "table" then return end
    for name, raw in pairs(packed) do
        local def = flagDefs[name]
        if def then
            local val = raw
            if def.Kind == "Keybind" and type(raw) == "string" then
                val = Enum.KeyCode[raw] or nil
            elseif def.Kind == "Slider" and type(raw) == "number" then
                val = math.clamp(math.floor(raw), def.Min, def.Max)
            elseif def.Kind == "Toggle" then
                val = raw == true
            end
            flagValues[name] = val
            -- only push into the ui if that element happens to be built already,
            -- otherwise it picks this up when the tab builds
            local obj = savedFlags[name]
            if obj and type(obj.Set) == "function" then
                pcall(function() obj:Set(val) end)
            end
        end
    end
end

function Library:SaveConfig(name)
    local clean = cleanCfgName(name)
    if not clean then
        self:Notify("Config", "That name has nothing usable in it.", 3)
        return false
    end

    local payload = {
        Theme = Theme.CurrentTheme,
        Flags = packFlags()
    }

    local win = self:GetWindow()
    if win and win.CollectConfig then
        local extra = win:CollectConfig()
        if type(extra) == "table" then
            for k, v in pairs(extra) do
                payload[k] = v
            end
        end
    end

    local ok = writeJson(cfgPath(clean), payload)
    if ok then
        self:Notify("Config", "Saved \"" .. clean .. "\".", 3)
    else
        self:Notify("Config", "Cant write to disk here.", 4)
    end
    return ok
end

function Library:LoadConfig(name)
    local clean = cleanCfgName(name)
    if not clean then
        self:Notify("Config", "That name has nothing usable in it.", 3)
        return false
    end

    local data = readJson(cfgPath(clean))
    if not data then
        self:Notify("Config", "No config called \"" .. clean .. "\".", 4)
        return false
    end

    if data.Theme and Theme.Themes[data.Theme] then
        Theme:SetTheme(data.Theme)
    end

    unpackFlags(data.Flags)

    local win = self:GetWindow()
    if win and win.ApplyConfig then
        pcall(function() win:ApplyConfig(data) end)
    end

    self:Notify("Config", "Loaded \"" .. clean .. "\".", 3)
    return true
end

function Library:DeleteConfig(name)
    local clean = cleanCfgName(name)
    local del = delfile or deletefile
    if not clean or not del or not isfile then return false end
    local ok = pcall(function()
        if isfile(cfgPath(clean)) then del(cfgPath(clean)) end
    end)
    if ok then
        self:Notify("Config", "Deleted \"" .. clean .. "\".", 3)
    end
    return ok
end

function Library:GetConfigs()
    local out = {}
    if not isfolder or not isfile then return out end
    local ok = pcall(function()
        if not isfolder(CONFIG_FOLDER) then return end
        -- isfolder gives back false or the listing, so only read it once we know
        local listing = isfolder(CONFIG_FOLDER)
        if type(listing) ~= "table" then return end
        for _, file in ipairs(listing) do
            local name = tostring(file):gsub("%.cfg$", "")
            if name ~= "" then
                table.insert(out, name)
            end
        end
    end)
    if not ok then return {} end
    table.sort(out)
    return out
end

-- ============ modals ============
local modalGui = nil

local function getModalGui()
    if modalGui and modalGui.Parent then return modalGui end
    modalGui = mk("ScreenGui", {
        Name = "RUI_Modal",
        Parent = GetHui(),
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        DisplayOrder = 999
    })
    ProtectGui(modalGui)
    track(modalGui)
    return modalGui
end

-- opts: Title, Content, Confirm, Cancel, Danger, OnConfirm
function Library:Modal(opts)
    opts = opts or {}
    local parent = getModalGui()

    local overlay = mk("Frame", {
        Parent = parent,
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundColor3 = Color3.new(0, 0, 0),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ZIndex = 100
    })
    track(overlay)

    local card = mk("CanvasGroup", {
        Parent = overlay,
        Size = UDim2.new(0, 380, 0, 40),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = Theme.Themes.Default.Container,
        BorderSizePixel = 0,
        GroupTransparency = 1,
        ClipsDescendants = true
    })
    track(card)
    Theme:Register(card, "BackgroundColor3", "Container")
    mk("UICorner", {Parent = card, CornerRadius = UDim.new(0, 12)})
    Theme:Register(mk("UIStroke", {Parent = card, Thickness = 1, Color = Theme.Themes.Default.Border, Transparency = 0.5}), "Color", "Border")

    local body = mk("Frame", { Parent = card, Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1 })
    local bodyLayout = mk("UIListLayout", { Parent = body, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 12) })
    mk("UIPadding", {
        Parent = body,
        PaddingTop = UDim.new(0, 20),
        PaddingBottom = UDim.new(0, 20),
        PaddingLeft = UDim.new(0, 20),
        PaddingRight = UDim.new(0, 20)
    })

    local bodyTitle = mk("TextLabel", {
        Parent = body,
        Size = UDim2.new(1, 0, 0, 22),
        BackgroundTransparency = 1,
        Text = opts.Title or "Are you sure?",
        Font = Enum.Font.GothamBold,
        TextSize = 17,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextWrapped = true,
        LayoutOrder = 1
    })
    Theme:Register(bodyTitle, "TextColor3", "Text")

    if opts.Content then
        local bodyText = mk("TextLabel", {
            Parent = body,
            Size = UDim2.new(1, 0, 0, 34),
            BackgroundTransparency = 1,
            Text = opts.Content,
            Font = Enum.Font.GothamMedium,
            TextSize = 13,
            TextWrapped = true,
            TextXAlignment = Enum.TextXAlignment.Left,
            LayoutOrder = 2
        })
        Theme:Register(bodyText, "TextColor3", "SubText")
    end

    local btnRow = mk("Frame", {
        Parent = body,
        Size = UDim2.new(1, 0, 0, 32),
        BackgroundTransparency = 1,
        LayoutOrder = 3
    })
    mk("UIListLayout", {
        Parent = btnRow,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 10),
        FillDirection = Enum.FillDirection.Horizontal,
        HorizontalAlignment = Enum.HorizontalAlignment.Right
    })

    local closed = false
    local function shut()
        if closed then return end
        closed = true
        tween(overlay, {BackgroundTransparency = 1}, 0.2)
        tween(card, {GroupTransparency = 1}, 0.2)
        task.delay(0.2, function()
            if overlay.Parent then overlay:Destroy() end
        end)
    end

    local function makeBtn(text, order, tint, cb)
        local b = mk("TextButton", {
            Parent = btnRow,
            Size = UDim2.new(0, tint and 96 or 84, 1, 0),
            LayoutOrder = order,
            BackgroundColor3 = tint or Theme.Themes.Default.Container,
            BorderSizePixel = 0,
            Text = text,
            Font = Enum.Font.GothamMedium,
            TextSize = 13,
            TextColor3 = tint and Theme.Themes.Default.Background or Theme.Themes.Default.Text,
            AutoButtonColor = false
        })
        mk("UICorner", {Parent = b, CornerRadius = UDim.new(0, 6)})
        local hover = tint and tint:Lerp(Color3.new(1, 1, 1), 0.15) or Theme.Themes.Default.Hover
        local click = tint and tint:Lerp(Color3.new(0, 0, 0), 0.15) or Theme.Themes.Default.Click
        b.MouseEnter:Connect(function() tween(b, {BackgroundColor3 = hover}, 0.15) end)
        b.MouseLeave:Connect(function() tween(b, {BackgroundColor3 = tint or Theme.Themes.Default.Container}, 0.15) end)
        b.MouseButton1Down:Connect(function() tween(b, {BackgroundColor3 = click}, 0.1) end)
        b.MouseButton1Up:Connect(function() tween(b, {BackgroundColor3 = hover}, 0.1) end)
        b.MouseButton1Click:Connect(function()
            shut()
            if cb then pcall(cb) end
        end)
        track(b)
        return b
    end

    if opts.Cancel then
        makeBtn(opts.Cancel, 1, nil, nil)
    end
    makeBtn(opts.Confirm or "Confirm", 2, opts.Danger and DANGER or Theme.Themes.Default.Accent, opts.OnConfirm)

    -- clicking the dark bit counts as cancel, way less annoying than a forced choice
    track(overlay.InputBegan:Connect(function(input)
        if input.Target == overlay then
            shut()
        end
    end))

    local function sizeCard()
        if card.Parent then
            card.Size = UDim2.new(0, 380, 0, bodyLayout.AbsoluteContentSize.Y + 40)
        end
    end
    track(bodyLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(sizeCard))
    sizeCard()

    tween(overlay, {BackgroundTransparency = 0.5}, 0.25)
    tween(card, {GroupTransparency = 0}, 0.3, Enum.EasingStyle.Quint)
end

function Library:Confirm(title, content, onConfirm)
    return self:Modal({
        Title = title,
        Content = content,
        Confirm = "Yes",
        Cancel = "Cancel",
        OnConfirm = onConfirm
    })
end

function Library:Alert(title, content)
    return self:Modal({
        Title = title,
        Content = content,
        Confirm = "Ok"
    })
end

function Library:ResetAll()
    for name, def in pairs(flagDefs) do
        local obj = savedFlags[name]
        -- element isnt built yet, just remember the default for when it is
        flagValues[name] = def.Default
        if obj and obj.Default ~= nil and type(obj.Set) == "function" then
            pcall(function() obj:Set(obj.Default) end)
        end
    end
end

-- so re-executing doesnt stack guis
_G.__RUI_Cleanup = function() -- cleanup for next exec
    if Library and Library.Unload then
        Library:Unload()
    end
end

function Library:CreateWindow(options)
    local title = options.Title or "RUI"

    -- viewport wasnt ready up top so check again lol
    local curViewport = (Workspace.CurrentCamera and Workspace.CurrentCamera.ViewportSize) or Vector2.new(1920, 1080)
    local curIsMobile = isTouch and not isConsole
    local curIsPhone = curIsMobile and (math.min(curViewport.X, curViewport.Y) < 700)
    local curIsTablet = curIsMobile and not curIsPhone

    local size = options.Size or (curIsPhone and UDim2.new(0, 400, 0, 300))
                                  or (curIsTablet and UDim2.new(0, 550, 0, 350)
                                  or UDim2.new(0, 600, 0, 400))

    -- fab gets made later but the close btn uses it so declare up here
    local fab = nil
    local fabStoredPos = UDim2.new(0, 0, 0.5, 0) -- left middle

    local gui = mk("ScreenGui", {
        Name = "RUI",
        Parent = GetHui(),
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    })
    ProtectGui(gui)
    track(gui)
    bringToFront(gui)

    notifs:Init(GetHui())

    local canvasGroup = mk("CanvasGroup", {
        Parent = gui,
        Size = UDim2.new(0, 0, 0, 40), -- starts tiny for the anim
        Position = UDim2.new(0.5, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        ClipsDescendants = true,
        GroupTransparency = 1
    })
    Theme:Register(canvasGroup, "BackgroundColor3", "Background")
    mk("UICorner", { Parent = canvasGroup, CornerRadius = UDim.new(0, 12) })
    local stroke = mk("UIStroke", { Parent = canvasGroup, Thickness = 1, Color = Theme.Themes.Default.Border, Transparency = 0.5 })
    Theme:Register(stroke, "Color", "Border")

    -- clicking anywhere in the window pops it above the other ones
    track(canvasGroup.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            bringToFront(gui)
        end
    end))

    -- canvas clips stuff so shadow has to live on its own frame next to it
    local shadowFrame = mk("Frame", {
        Parent = gui,
        Size = size,
        Position = UDim2.new(0.5, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundTransparency = 1,
        Visible = false
    })
    addShadow(shadowFrame, 0.4, 25)

    -- little pop-in
    tween(canvasGroup, {GroupTransparency = 0.2, Size = size}, 0.6, Enum.EasingStyle.Quint)
    task.delay(0.6, function()
        if shadowFrame and shadowFrame.Parent then
            shadowFrame.Visible = true
        end
    end)

    -- keep shadow glued to the window
    track(canvasGroup:GetPropertyChangedSignal("Position"):Connect(function()
        if shadowFrame and shadowFrame.Parent then
            shadowFrame.Position = canvasGroup.Position
        end
    end))
    track(canvasGroup:GetPropertyChangedSignal("Size"):Connect(function()
        if shadowFrame and shadowFrame.Parent then
            shadowFrame.Size = canvasGroup.Size
        end
    end))
    
    if isMobile then
        track(UserInputService:GetPropertyChangedSignal("OnScreenKeyboardVisible"):Connect(function()
            if UserInputService.OnScreenKeyboardVisible then
                local kbSize = UserInputService.OnScreenKeyboardSize
                local yOffset = kbSize.Y > 0 and -(kbSize.Y / 2.5) or -100
                tween(canvasGroup, {Position = UDim2.new(0.5, 0, 0.5, yOffset)}, 0.3, Enum.EasingStyle.Quint)
            else
                tween(canvasGroup, {Position = UDim2.new(0.5, 0, 0.5, 0)}, 0.3, Enum.EasingStyle.Quint)
            end
        end))
    end
    
    local dragBarGui = mk("ScreenGui", {
        Name = "DragBarGui",
        Parent = GetHui(),
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        IgnoreGuiInset = true,
        DisplayOrder = 999
    })
    track(dragBarGui)

    local dragBar = mk("TextButton", {
        Name = "BottomDragBar",
        Parent = dragBarGui,
        Size = UDim2.new(0, 120, 0, 24),
        AnchorPoint = Vector2.new(0.5, 0),
        Position = UDim2.new(0.5, 0, 0.5, 270),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Text = "",
        AutoButtonColor = false,
        Visible = true
    })

    local dragBarVisual = mk("Frame", {
        Name = "Visual",
        Parent = dragBar,
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 0, 0.5, -10),
        Size = UDim2.new(0, 100, 0, 4),
        BackgroundColor3 = Theme.Themes.Default.Accent,
        BackgroundTransparency = 0.35,
        BorderSizePixel = 0
    })
    mk("UICorner", {Parent = dragBarVisual, CornerRadius = UDim.new(1, 0)})
    Theme:Register(dragBarVisual, "BackgroundColor3", "Accent")

    local smoothX = dragBar.Position.X.Offset
    local smoothY = dragBar.Position.Y.Offset
    local snapped = false

    -- declared first then assigned, otherwise the closure below grabs the global
    -- one and the self-disconnect never fires
    local renderConn
    renderConn = RunService.RenderStepped:Connect(function()
        if not dragBar or not dragBar.Parent then
            if renderConn then renderConn:Disconnect() end
            return
        end
        if dragBar.Visible then
            local canvasAbs = canvasGroup.AbsolutePosition
            local canvasSize = canvasGroup.AbsoluteSize
            local targetX = canvasAbs.X + canvasSize.X/2
            local targetY = canvasAbs.Y + canvasSize.Y + 65

            if not snapped then
                -- first frame: start at the target instead of flying in from 0,0
                smoothX, smoothY = targetX, targetY
                snapped = true
            end
            local snap = 0.6
            if math.abs(targetX - smoothX) < 0.5 and math.abs(targetY - smoothY) < 0.5 then
                smoothX, smoothY = targetX, targetY
            else
                smoothX = smoothX + (targetX - smoothX) * snap
                smoothY = smoothY + (targetY - smoothY) * snap
                dragBar.Position = UDim2.new(0, smoothX, 0, smoothY)
            end
        end
    end)
    track(renderConn)

    local isDraggingBar = false

    track(dragBar.MouseEnter:Connect(function()
        if isDraggingBar then return end
        tween(dragBarVisual, {Size = UDim2.new(0, 120, 0, 4), BackgroundTransparency = 0.15}, 0.2, Enum.EasingStyle.Quint)
    end))

    track(dragBar.MouseLeave:Connect(function()
        if isDraggingBar then return end
        tween(dragBarVisual, {Size = UDim2.new(0, 100, 0, 4), BackgroundTransparency = 0.35}, 0.2, Enum.EasingStyle.Quint)
    end))

    track(dragBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            isDraggingBar = true
            tween(dragBarVisual, {Size = UDim2.new(0, 130, 0, 5), BackgroundTransparency = 0}, 0.15, Enum.EasingStyle.Back)
        end
    end))

    track(dragBar.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            isDraggingBar = false
            tween(dragBarVisual, {Size = UDim2.new(0, 100, 0, 4), BackgroundTransparency = 0.35}, 0.2, Enum.EasingStyle.Quint)
        end
    end))

    drag(dragBar, canvasGroup)
    
    local topbar = mk("TextButton", {
        Parent = canvasGroup,
        Size = UDim2.new(1, 0, 0, 40),
        BackgroundTransparency = 1,
        Text = "",
        AutoButtonColor = false
    })
    drag(topbar, canvasGroup)
    
    local trafficContainer = mk("Frame", {
        Parent = topbar,
        Size = UDim2.new(0, 54, 1, 0),
        Position = UDim2.new(0, 12, 0, 0),
        BackgroundTransparency = 1
    })

    -- mac dots, 18px click area with a 12px dot
    local function makeTrafficLight(parent, color, visualX)
        local hitbox = mk("TextButton", {
            Parent = parent,
            Size = UDim2.new(0, 18, 0, 18),
            Position = UDim2.new(0, visualX - 3, 0.5, -9),
            BackgroundTransparency = 1,
            Text = "",
            AutoButtonColor = false
        })
        local visual = mk("Frame", {
            Parent = hitbox,
            Size = UDim2.new(0, 12, 0, 12),
            Position = UDim2.new(0.5, -6, 0.5, -6),
            BackgroundColor3 = color
        })
        mk("UICorner", {Parent = visual, CornerRadius = UDim.new(1, 0)})
        return hitbox, visual
    end

    local closeBtn, closeVisual = makeTrafficLight(trafficContainer, Color3.fromRGB(255, 95, 86), 0)
    local minBtn, minVisual = makeTrafficLight(trafficContainer, Color3.fromRGB(255, 189, 46), 20)
    local maxBtn, maxVisual = makeTrafficLight(trafficContainer, Color3.fromRGB(39, 201, 63), 40)

    local titleLbl = mk("TextLabel", {
        Parent = topbar,
        Size = UDim2.new(1, -84, 1, 0),
        Position = UDim2.new(0, 74, 0, -1),
        BackgroundTransparency = 1,
        Text = title,
        Font = Enum.Font.GothamBold,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left
    })
    Theme:Register(titleLbl, "TextColor3", "Text")

    -- darken the circle on hover
    local function addTrafficHover(visual, color)
        local h, s, v = color:ToHSV()
        local hoverColor = Color3.fromHSV(h, s, math.clamp(v - 0.2, 0, 1))
        track(visual.Parent.MouseEnter:Connect(function()
            tween(visual, {BackgroundColor3 = hoverColor}, 0.2)
        end))
        track(visual.Parent.MouseLeave:Connect(function()
            tween(visual, {BackgroundColor3 = color}, 0.2)
        end))
    end
    addTrafficHover(closeVisual, Color3.fromRGB(255, 95, 86))
    addTrafficHover(minVisual, Color3.fromRGB(255, 189, 46))
    addTrafficHover(maxVisual, Color3.fromRGB(39, 201, 63))
    
    local windowObj = {
        Tabs = {},
        CurrentTab = nil,
        CanvasGroup = canvasGroup,
        Minimized = false,
        Hidden = false,
        Maximized = false,
        UserOpacity = 0.2,
        DefaultSize = size,
        DefaultPosition = UDim2.new(0.5, 0, 0.5, 0),
        DefaultMaximized = false,
        Keybind = Library.ToggleKeybind,
        Locked = false,
        nextOrder = 2,
        switching = false
    }

    -- these live up here because the settings tab below wires em up, and a
    -- callback that only runs later still has to see the key exist

    function windowObj:SetKeybind(keyCode)
        windowObj.Keybind = keyCode or windowObj.Keybind
    end

    function windowObj:Lock()
        windowObj.Locked = true
        canvasGroup.GroupTransparency = 1
    end

    function windowObj:Unlock()
        windowObj.Locked = false
        canvasGroup.GroupTransparency = windowObj.UserOpacity
    end

    track(closeBtn.MouseButton1Click:Connect(function()
        windowObj.Hidden = true
        tween(canvasGroup, {GroupTransparency = 1}, 0.3)
        tween(stroke, {Transparency = 1}, 0.3)
        local sh = shadowFrame:FindFirstChild("Shadow")
        if sh then tween(sh, {ImageTransparency = 1}, 0.3) end
        if fab then
            fab.Position = fabStoredPos
            fab.Visible = true
        end
        dragBar.Visible = false
        task.delay(0.3, function()
            if windowObj.Hidden then
                canvasGroup.Visible = false
                shadowFrame.Visible = false
            end
        end)
    end))

    track(minBtn.MouseButton1Click:Connect(function()
        windowObj.Minimized = not windowObj.Minimized
        if windowObj.Minimized then
            tween(canvasGroup, {Size = UDim2.new(0, canvasGroup.Size.X.Offset, 0, 40)}, 0.4, Enum.EasingStyle.Quint)
            dragBar.Visible = false
        else
            local restoreMax = curIsPhone and UDim2.new(0, 500, 0, 400)
                                   or (curIsTablet and UDim2.new(0, 600, 0, 400)
                                   or UDim2.new(0, 800, 0, 600))
            tween(canvasGroup, {Size = windowObj.Maximized and restoreMax or size}, 0.4, Enum.EasingStyle.Quint)
            dragBar.Visible = true
        end
    end))

    track(maxBtn.MouseButton1Click:Connect(function()
        if windowObj.Minimized then return end
        windowObj.Maximized = not windowObj.Maximized
        if windowObj.Maximized then
            local maxSize = curIsPhone and UDim2.new(0, 500, 0, 400)
                                or (curIsTablet and UDim2.new(0, 600, 0, 400)
                                or UDim2.new(0, 800, 0, 600))
            tween(canvasGroup, {Size = maxSize, Position = UDim2.new(0.5, 0, 0.5, 0)}, 0.4, Enum.EasingStyle.Quint)
        else
            tween(canvasGroup, {Size = size}, 0.4, Enum.EasingStyle.Quint)
        end
    end))
    
    local tabContainer
    local tabList
    local tabLayout
    local contentContainer

    tabContainer = mk("Frame", {
        Parent = canvasGroup,
        Size = UDim2.new(0, 150, 1, -40),
        Position = UDim2.new(0, 0, 0, 40),
        BackgroundTransparency = 1
    })

    tabList = mk("ScrollingFrame", {
        Parent = tabContainer,
        Size = UDim2.new(1, 0, 1, -10),
        Position = UDim2.new(0, 0, 0, 5),
        BackgroundTransparency = 1,
        ScrollBarThickness = 0,
        CanvasSize = UDim2.new(0, 0, 0, 0)
    })
    tabLayout = mk("UIListLayout", {
        Parent = tabList,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 5),
        HorizontalAlignment = Enum.HorizontalAlignment.Center
    })
    mk("UIPadding", {
        Parent = tabList,
        PaddingBottom = UDim.new(0, 10)
    })

    track(tabLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        tabList.CanvasSize = UDim2.new(0, 0, 0, tabLayout.AbsoluteContentSize.Y + 10)
    end))

    contentContainer = mk("Frame", {
        Parent = canvasGroup,
        Size = UDim2.new(1, -150, 1, -40),
        Position = UDim2.new(0, 150, 0, 40),
        BackgroundTransparency = 1,
        ClipsDescendants = true
    })

    -- where tabs show up
    local contentArea = mk("Frame", {
        Parent = contentContainer,
        Size = UDim2.new(1, 0, 1, -10),
        Position = UDim2.new(0, 0, 0, 5),
        BackgroundTransparency = 1,
        ClipsDescendants = true
    })

    -- stash for hidden tabs so layout doesnt break
    local hiddenContainer = mk("CanvasGroup", {
        Parent = contentContainer,
        Size = UDim2.new(1, 0, 1, -10),
        Position = UDim2.new(0, 0, 0, 5),
        BackgroundTransparency = 1,
        GroupTransparency = 1,
        Visible = true
    })
    
    -- little floating open btn, phones always get one, desktop only if they ask
    if isMobile or options.OpenButton then
        local fabWidth = 90
        local fabHeight = 36

        fab = mk("TextButton", {
            Parent = gui,
            Size = UDim2.new(0, fabWidth, 0, fabHeight),
            Position = fabStoredPos,
            AnchorPoint = Vector2.new(0, 0.5),
            Text = "",
            AutoButtonColor = false,
            Visible = true,
            ClipsDescendants = false,
            BackgroundTransparency = windowObj.UserOpacity
        })
        mk("UICorner", {Parent = fab, CornerRadius = UDim.new(0, 12)})

        -- outline
        local fabStroke = mk("UIStroke", {
            Parent = fab,
            Thickness = 2,
            Color = Theme.Themes.Default.Accent,
            Transparency = 0
        })
        Theme:Register(fabStroke, "Color", "Accent")

        -- same bg as the window
        Theme:Register(fab, "BackgroundColor3", "Background")

        addShadow(fab, 0.3, 14)

        -- split label, REN + UI
        local fabRenLabel = mk("TextLabel", {
            Parent = fab,
            Size = UDim2.new(0.5, 0, 1, 0),
            Position = UDim2.new(0, 0, 0, 0),
            BackgroundTransparency = 1,
            Text = "REN",
            Font = Enum.Font.GothamBold,
            TextSize = 13,
            TextXAlignment = Enum.TextXAlignment.Right,
            TextYAlignment = Enum.TextYAlignment.Center,
            TextTransparency = windowObj.UserOpacity
        })
        Theme:Register(fabRenLabel, "TextColor3", "Text")

        local fabUiLabel = mk("TextLabel", {
            Parent = fab,
            Size = UDim2.new(0.5, 0, 1, 0),
            Position = UDim2.new(0.6, 0, 0, 0),
            BackgroundTransparency = 1,
            Text = "UI",
            Font = Enum.Font.GothamBold,
            TextSize = 13,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextYAlignment = Enum.TextYAlignment.Center,
            TextTransparency = windowObj.UserOpacity
        })
        Theme:Register(fabUiLabel, "TextColor3", "Accent")

        -- drag vs tap tracking
        local fabDragging = false
        local fabDragMoved = false
        local fabStartInputPos = nil
        local fabStartObjPos = nil
        local fabTargetPos = fabStoredPos
        local fabCurrentPos = fabStoredPos
        local dragInput = nil
        local DRAG_THRESHOLD = 5

        -- smooth follow while dragging
        track(RunService.RenderStepped:Connect(function()
            if not fab or not fab.Parent then return end
            if fabDragging and fabDragMoved then
                local alpha = 0.35
                fabCurrentPos = UDim2.new(
                    fabCurrentPos.X.Scale,
                    fabCurrentPos.X.Offset + (fabTargetPos.X.Offset - fabCurrentPos.X.Offset) * alpha,
                    fabCurrentPos.Y.Scale,
                    fabCurrentPos.Y.Offset + (fabTargetPos.Y.Offset - fabCurrentPos.Y.Offset) * alpha
                )
                fab.Position = fabCurrentPos
            end
        end))

        -- press down
        track(fab.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1
               or input.UserInputType == Enum.UserInputType.Touch then
                fabDragging = true
                fabDragMoved = false
                dragInput = input
                fabStartInputPos = input.Position
                fabStartObjPos = fab.Position
                fabCurrentPos = fab.Position
                -- little press-in
                tween(fab, {Size = UDim2.new(0, fabWidth - 4, 0, fabHeight - 2)}, 0.08, Enum.EasingStyle.Quad)
            end
        end))

        -- track finger even if it slides off the btn
        track(UserInputService.InputChanged:Connect(function(input, processed)
            if fabDragging and input == dragInput and (input.UserInputType == Enum.UserInputType.MouseMovement
               or input.UserInputType == Enum.UserInputType.Touch) then
                if fabStartInputPos and (input.Position - fabStartInputPos).Magnitude > DRAG_THRESHOLD then
                    fabDragMoved = true
                end
                if fabDragMoved and fabStartObjPos then
                    local delta = input.Position - fabStartInputPos
                    fabTargetPos = UDim2.new(
                        fabStartObjPos.X.Scale, fabStartObjPos.X.Offset + delta.X,
                        fabStartObjPos.Y.Scale, fabStartObjPos.Y.Offset + delta.Y
                    )
                end
            end
        end))

        -- release (works even off the btn)
        track(UserInputService.InputEnded:Connect(function(input, processed)
            if fabDragging and input == dragInput then
                local wasDrag = fabDragMoved
                fabDragging = false
                dragInput = nil
                fabStartInputPos = nil
                fabStartObjPos = nil
                -- pop back
                tween(fab, {Size = UDim2.new(0, fabWidth, 0, fabHeight)}, 0.2, Enum.EasingStyle.Back)
                -- btn is there to OPEN the window so it gets out of the way once its open
                fab.Visible = windowObj.Hidden
                if not wasDrag then
                    -- tapped, toggle ui same as rightshift
                    if windowObj.Hidden then
                        windowObj.Hidden = false
                        canvasGroup.Visible = true
                        shadowFrame.Visible = true
                        tween(canvasGroup, {GroupTransparency = windowObj.UserOpacity}, 0.3)
                        tween(stroke, {Transparency = 0.5}, 0.3)
                        local shadow = shadowFrame:FindFirstChild("Shadow")
                        if shadow then
                            tween(shadow, {ImageTransparency = 0.4 + 0.6 * windowObj.UserOpacity}, 0.3)
                        end
                        if not windowObj.Minimized then
                            dragBar.Visible = true
                        end
                    else
                        windowObj.Hidden = true
                        tween(canvasGroup, {GroupTransparency = 1}, 0.3)
                        tween(stroke, {Transparency = 1}, 0.3)
                        local shadow = shadowFrame:FindFirstChild("Shadow")
                        if shadow then
                            tween(shadow, {ImageTransparency = 1}, 0.3)
                        end
                        dragBar.Visible = false
                        task.delay(0.3, function()
                            if windowObj.Hidden then
                                canvasGroup.Visible = false
                                shadowFrame.Visible = false
                            end
                        end)
                    end
                else
                    -- dragged, save where it ended up
                    fabStoredPos = fab.Position
                end
            end
        end))
    end
    
    -- resize grip, has to live inside the canvas because canvas clips its children
    if options.Resizable ~= false then
        local grip = mk("TextButton", {
            Parent = canvasGroup,
            Size = UDim2.new(0, 18, 0, 18),
            Position = UDim2.new(1, -18, 1, -18),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Text = "",
            AutoButtonColor = false
        })
        local gripDot = mk("Frame", {
            Parent = grip,
            Size = UDim2.new(0, 7, 0, 7),
            Position = UDim2.new(1, -5, 1, -5),
            BackgroundColor3 = Theme.Themes.Default.SubText,
            BackgroundTransparency = 0.55,
            BorderSizePixel = 0
        })
        mk("UICorner", {Parent = gripDot, CornerRadius = UDim.new(1, 0)})
        Theme:Register(gripDot, "BackgroundColor3", "SubText")

        local resizing = false
        local grabStart, grabSize

        track(grip.InputBegan:Connect(function(input)
            if windowObj.Maximized or windowObj.Minimized then return end
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                resizing = true
                grabStart = input.Position
                grabSize = canvasGroup.AbsoluteSize
                tween(gripDot, {BackgroundTransparency = 0}, 0.15)
            end
        end))

        track(UserInputService.InputChanged:Connect(function(input)
            if not resizing then return end
            if input.UserInputType ~= Enum.UserInputType.MouseMovement and input.UserInputType ~= Enum.UserInputType.Touch then return end
            local curViewport = (Workspace.CurrentCamera and Workspace.CurrentCamera.ViewportSize) or Vector2.new(1920, 1080)
            local delta = input.Position - grabStart
            local w = math.clamp(grabSize.X + delta.X, 400, math.max(400, curViewport.X - 20))
            local h = math.clamp(grabSize.Y + delta.Y, 260, math.max(260, curViewport.Y - 20))
            canvasGroup.Size = UDim2.new(0, w, 0, h)
        end))

        track(UserInputService.InputEnded:Connect(function(input)
            if not resizing then return end
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                resizing = false
                tween(gripDot, {BackgroundTransparency = 0.55}, 0.2)
            end
        end))
    end

    track(UserInputService.InputBegan:Connect(function(input, processed)
        if processed then return end
        -- escape closes it unless a keybind element is waiting on a key
        if input.KeyCode == Enum.KeyCode.Escape and not windowObj.Locked and not windowObj.Hidden and not listeningKeybind then
            windowObj.Hidden = true
            tween(canvasGroup, {GroupTransparency = 1}, 0.3)
            tween(stroke, {Transparency = 1}, 0.3)
            local escSh = shadowFrame:FindFirstChild("Shadow")
            if escSh then tween(escSh, {ImageTransparency = 1}, 0.3) end
            if fab then
                fab.Position = fabStoredPos
                fab.Visible = true
            end
            dragBar.Visible = false
            task.delay(0.3, function()
                if windowObj.Hidden then
                    canvasGroup.Visible = false
                    shadowFrame.Visible = false
                end
            end)
            return
        end
        if input.KeyCode == windowObj.Keybind then
            windowObj.Hidden = not windowObj.Hidden
            if windowObj.Hidden then
                tween(canvasGroup, {GroupTransparency = 1}, 0.3)
                tween(stroke, {Transparency = 1}, 0.3)
                local sh = shadowFrame:FindFirstChild("Shadow")
                if sh then tween(sh, {ImageTransparency = 1}, 0.3) end
                if fab then
                    fab.Position = fabStoredPos
                    fab.Visible = true
                end
                dragBar.Visible = false
                task.delay(0.3, function()
                    if windowObj.Hidden then
                        canvasGroup.Visible = false
                        shadowFrame.Visible = false
                    end
                end)
            else
                canvasGroup.Visible = true
                shadowFrame.Visible = true
                tween(canvasGroup, {GroupTransparency = windowObj.UserOpacity}, 0.3)
                tween(stroke, {Transparency = 0.5}, 0.3)
                local sh2 = shadowFrame:FindFirstChild("Shadow")
                if sh2 then tween(sh2, {ImageTransparency = 0.4 + 0.6 * windowObj.UserOpacity}, 0.3) end
                if not windowObj.Minimized then
                    dragBar.Visible = true
                end
                if fab then
                    fab.Visible = false
                end
            end
        end
    end))
    
    function windowObj:CreateTab(name, layoutOrder, customBuild)
        local tabBtn = mk("TextButton", {
            Parent = tabList,
            Size = UDim2.new(1, -20, 0, 32),
            BackgroundTransparency = 1,
            Text = name,
            Font = Enum.Font.GothamMedium,
            TextSize = 13,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextTruncate = Enum.TextTruncate.AtEnd,
            LayoutOrder = layoutOrder or windowObj.nextOrder,
            AutoButtonColor = false
        })
        if not layoutOrder then
            windowObj.nextOrder = windowObj.nextOrder + 1
        end
        mk("UIPadding", {Parent = tabBtn, PaddingLeft = UDim.new(0, 15)})
        mk("UICorner", {Parent = tabBtn, CornerRadius = UDim.new(0, 6)})
        Theme:Register(tabBtn, "TextColor3", "SubText")

        local activeIndicator = mk("Frame", {
            Parent = tabBtn,
            Size = UDim2.new(0, 3, 0, 0),
            Position = UDim2.new(0, -10, 0.5, 0),
            AnchorPoint = Vector2.new(0, 0.5),
            BackgroundTransparency = 0
        })
        Theme:Register(activeIndicator, "BackgroundColor3", "Accent")
        mk("UICorner", {Parent = activeIndicator, CornerRadius = UDim.new(1, 0)})
        addShadow(activeIndicator, 0.6, 6)
        
        local tabObj = {
            Name = name,
            Button = tabBtn,
            Indicator = activeIndicator,
            SectionDefs = {},
            ContentRoot = nil,
            ContentLayout = nil,
            SectionRefs = nil,
            Loaded = false
        }

        local container = contentArea

        -- builds the tab's stuff on first open
        local function BuildTabContent()
        local canvasGroup = mk("CanvasGroup", {
            Parent = container,
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundColor3 = Theme.Themes.Default.Background,
            GroupTransparency = 0
        })
        Theme:Register(canvasGroup, "BackgroundColor3", "Background")
        local scroll = mk("ScrollingFrame", {
            Parent = canvasGroup,
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundColor3 = Theme.Themes.Default.Background,
            BackgroundTransparency = 0,
            ScrollBarThickness = 0,
            CanvasSize = UDim2.new(0, 0, 0, 0)
        })
        Theme:Register(scroll, "BackgroundColor3", "Background")
        Theme:Register(scroll, "ScrollBarImageColor3", "Accent")
        local layout = mk("UIListLayout", {
                Parent = scroll,
                SortOrder = Enum.SortOrder.LayoutOrder,
                Padding = UDim.new(0, 10),
                HorizontalAlignment = Enum.HorizontalAlignment.Center
            })
            mk("UIPadding", {Parent = scroll, PaddingTop = UDim.new(0, 6), PaddingBottom = UDim.new(0, 20)})
            
            local sectionRefs = {}
            local function RefreshLayout()
                for _, sec in ipairs(sectionRefs) do
                    sec.Frame.Size = UDim2.new(1, -20, 0, sec.Layout.AbsoluteContentSize.Y + 28)
                end
                scroll.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 20)
            end
            tabObj.RefreshLayout = RefreshLayout
            
            for i, secDef in ipairs(tabObj.SectionDefs) do
                if i > 1 then
                    local sep = mk("Frame", {
                        Parent = scroll,
                        Size = UDim2.new(1, -20, 0, 4),
                        BackgroundTransparency = 0,
                        BorderSizePixel = 0,
                        LayoutOrder = (i - 1) * 2
                    })
                    Theme:Register(sep, "BackgroundColor3", "Accent")
                    mk("UICorner", {Parent = sep, CornerRadius = UDim.new(1, 0)})
                    addShadow(sep, 0.5, 4)
                end
                local secFrame = mk("Frame", {
                    Parent = scroll,
                    Size = UDim2.new(1, -20, 0, 0),
                    BackgroundTransparency = 0,
                    LayoutOrder = (i - 1) * 2 + 1
                })
                Theme:Register(secFrame, "BackgroundColor3", "Section")
                mk("UICorner", {Parent = secFrame, CornerRadius = UDim.new(0, 6)})
                Theme:Register(mk("UIStroke", {Parent = secFrame, Thickness = 1, Color = Theme.Themes.Default.Border, Transparency = 0.5}), "Color", "Border")
                
                local secLayout = mk("UIListLayout", {
                    Parent = secFrame,
                    SortOrder = Enum.SortOrder.LayoutOrder,
                    Padding = UDim.new(0, 10)
                })
                local secPadding = mk("UIPadding", {
                    Parent = secFrame,
                    PaddingTop = UDim.new(0, 14),
                    PaddingBottom = UDim.new(0, 14),
                    PaddingLeft = UDim.new(0, 14),
                    PaddingRight = UDim.new(0, 14)
                })
                
                local secTitle = mk("TextLabel", {
                    Parent = secFrame,
                    Size = UDim2.new(1, 0, 0, 24),
                    BackgroundTransparency = 1,
                    Text = secDef.Name,
                    Font = Enum.Font.GothamBold,
                    TextSize = 14,
                    TextStrokeTransparency = 1,
                    TextXAlignment = Enum.TextXAlignment.Left
                })
                Theme:Register(secTitle, "TextColor3", "Text")
                
                local divider = mk("Frame", {
                    Parent = secFrame,
                    Size = UDim2.new(1, 0, 0, 1),
                    BackgroundTransparency = 0.5,
                    BorderSizePixel = 0
                })
                Theme:Register(divider, "BackgroundColor3", "Border")
                
                for _, compDef in ipairs(secDef.Components) do
                    if compDef.Type == "Label" then
                        local lblFrame = mk("Frame", {
                            Parent = secFrame,
                            Size = UDim2.new(1, 0, 0, compDef.Desc and 38 or 20),
                            BackgroundTransparency = 1
                        })
                        local lbl = mk("TextLabel", {
                            Parent = lblFrame,
                            Size = UDim2.new(1, 0, 0, 18),
                            BackgroundTransparency = 1,
                            Text = compDef.Name,
                            Font = Enum.Font.GothamMedium,
                            TextSize = 13,
                            TextXAlignment = Enum.TextXAlignment.Left,
                            TextTruncate = Enum.TextTruncate.AtEnd
                        })
                        Theme:Register(lbl, "TextColor3", "Text")
                        if compDef.Desc then
                            local desc = mk("TextLabel", {
                                Parent = lblFrame,
                                Size = UDim2.new(1, 0, 0, 16),
                                Position = UDim2.new(0, 0, 0, 20),
                                BackgroundTransparency = 1,
                                Text = compDef.Desc,
                                Font = Enum.Font.GothamMedium,
                                TextSize = 12,
                                TextXAlignment = Enum.TextXAlignment.Left,
                                TextTruncate = Enum.TextTruncate.AtEnd
                            })
                            Theme:Register(desc, "TextColor3", "SubText")
                        end

                    elseif compDef.Type == "Divider" then
                        local line = mk("Frame", {
                            Parent = secFrame,
                            Size = UDim2.new(1, 0, 0, 1),
                            BackgroundTransparency = 0.5,
                            BorderSizePixel = 0
                        })
                        Theme:Register(line, "BackgroundColor3", "Border")

                    elseif compDef.Type == "Button" then
                        local variant = compDef.Variant or "Default"
                        local baseCol, hoverCol, clickCol
                        if variant == "Danger" then
                            baseCol = DANGER
                            hoverCol = DANGER:Lerp(Color3.new(0, 0, 0), 0.12)
                            clickCol = DANGER:Lerp(Color3.new(0, 0, 0), 0.24)
                        elseif variant == "Accent" then
                            baseCol = Theme.Themes.Default.Accent
                            hoverCol = Theme.Themes.Default.Accent:Lerp(Color3.new(1, 1, 1), 0.15)
                            clickCol = Theme.Themes.Default.Accent:Lerp(Color3.new(0, 0, 0), 0.15)
                        else
                            baseCol = Theme.Themes.Default.Container
                            hoverCol = Theme.Themes.Default.Hover
                            clickCol = Theme.Themes.Default.Click
                        end
                        local btn = mk("TextButton", {
                            Parent = secFrame,
                            Size = UDim2.new(1, 0, 0, 32),
                            BackgroundColor3 = baseCol,
                            AutoButtonColor = false,
                            Text = compDef.Name,
                            Font = Enum.Font.GothamMedium,
                            TextSize = 13,
                            TextColor3 = variant == "Accent" and Theme.Themes.Default.Background or Theme.Themes.Default.Text
                        })
                        if variant == "Accent" then
                            Theme:Register(btn, "BackgroundColor3", "Accent")
                            Theme:Register(btn, "TextColor3", "Background")
                        else
                            Theme:Register(btn, "BackgroundColor3", "Container")
                            Theme:Register(btn, "TextColor3", "Text")
                        end
                        mk("UICorner", {Parent = btn, CornerRadius = UDim.new(0, 6)})
                        local stroke = mk("UIStroke", {Parent = btn, Thickness = 1, Color = Theme.Themes.Default.Border, Transparency = 0.5})
                        Theme:Register(stroke, "Color", "Border")

                        track(btn.MouseEnter:Connect(function()
                            tween(btn, {BackgroundColor3 = hoverCol}, 0.2)
                            tween(stroke, {Transparency = 0}, 0.2)
                        end))
                        track(btn.MouseLeave:Connect(function()
                            tween(btn, {BackgroundColor3 = baseCol}, 0.2)
                            tween(stroke, {Transparency = 0.5}, 0.2)
                        end))
                        track(btn.MouseButton1Down:Connect(function()
                            tween(btn, {BackgroundColor3 = clickCol}, 0.1)
                        end))
                        track(btn.MouseButton1Up:Connect(function()
                            tween(btn, {BackgroundColor3 = hoverCol}, 0.1)
                        end))
                        track(btn.MouseButton1Click:Connect(function()
                            Library:SafeCallback(compDef.Callback)
                        end))
                        
                     elseif compDef.Type == "Toggle" then
                         local tglFrame = mk("Frame", {
                             Parent = secFrame,
                             Size = UDim2.new(1, 0, 0, 32),
                             BackgroundTransparency = 1
                         })
                         local lbl = mk("TextLabel", {
                             Parent = tglFrame,
                             Size = UDim2.new(1, -60, 1, 0),
                             BackgroundTransparency = 1,
                             Text = compDef.Name,
                             Font = Enum.Font.GothamMedium,
                             TextSize = 13,
                             TextXAlignment = Enum.TextXAlignment.Left
                         })
                         Theme:Register(lbl, "TextColor3", "SubText")

                         local boxHeight = 22
                         local boxWidth = 42
                         local box = mk("TextButton", {
                             Parent = tglFrame,
                             Size = UDim2.new(0, boxWidth, 0, boxHeight),
                             Position = UDim2.new(1, -boxWidth, 0.5, -boxHeight/2),
                             Text = "",
                             AutoButtonColor = false
                         })
                         Theme:Register(box, "BackgroundColor3", "Container")
                         mk("UICorner", {Parent = box, CornerRadius = UDim.new(1, 0)})
                         local boxStroke = mk("UIStroke", {Parent = box, Thickness = 1, Color = Theme.Themes.Default.Border, Transparency = 0.5})
                         Theme:Register(boxStroke, "Color", "Border")

                         local indSize = 18
                         local indOff = 2
                         local indicator = mk("Frame", {
                             Parent = box,
                             Size = UDim2.new(0, indSize, 0, indSize),
                             Position = UDim2.new(0, indOff, 0.5, -indSize/2)
                         })
                         Theme:Register(indicator, "BackgroundColor3", "SubText")
                         mk("UICorner", {Parent = indicator, CornerRadius = UDim.new(1, 0)})
                         mk("UIGradient", {
                             Parent = indicator,
                             Color = ColorSequence.new({
                                 ColorSequenceKeypoint.new(0, Color3.fromRGB(220, 220, 220)),
                                 ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255))
                             }),
                             Rotation = 45
                         })

                         local state = flagStart(compDef, compDef.Default or false)
                         local function updateState(anim)
                             local onPos = UDim2.new(1, -indSize - indOff, 0.5, -indSize/2)
                             local offPos = UDim2.new(0, indOff, 0.5, -indSize/2)
                             if state then
                                 Theme:Register(indicator, "BackgroundColor3", "Background")
                                 Theme:Register(lbl, "TextColor3", "Text")
                                 Theme:Register(box, "BackgroundColor3", "Accent")
                                 if anim then
                                     tween(indicator, {Position = onPos}, 0.25, Enum.EasingStyle.Back)
                                     tween(box, {BackgroundColor3 = Theme.Themes.Default.Accent}, 0.2)
                                     tween(boxStroke, {Color = Theme.Themes.Default.Accent, Transparency = 1}, 0.2)
                                 else
                                     indicator.Position = onPos
                                     box.BackgroundColor3 = Theme.Themes.Default.Accent
                                     boxStroke.Color = Theme.Themes.Default.Accent
                                     boxStroke.Transparency = 1
                                 end
                             else
                                 Theme:Register(indicator, "BackgroundColor3", "SubText")
                                 Theme:Register(lbl, "TextColor3", "SubText")
                                 Theme:Register(box, "BackgroundColor3", "Container")
                                 if anim then
                                     tween(indicator, {Position = offPos}, 0.25, Enum.EasingStyle.Back)
                                     tween(box, {BackgroundColor3 = Theme.Themes.Default.Container}, 0.2)
                                     tween(boxStroke, {Color = Theme.Themes.Default.Border, Transparency = 0.5}, 0.2)
                                 else
                                     indicator.Position = offPos
                                     box.BackgroundColor3 = Theme.Themes.Default.Container
                                     boxStroke.Color = Theme.Themes.Default.Border
                                     boxStroke.Transparency = 0.5
                                 end
                             end
                         end

                          updateState(false)
                          table.insert(toggleRefresh, updateState)

                         local function toggle()
                             state = not state
                             updateState(true)
                             tween(indicator, {Size = UDim2.new(0, indSize + 4, 0, indSize + 4)}, 0.08, Enum.EasingStyle.Quad)
                             task.delay(0.08, function()
                                 tween(indicator, {Size = UDim2.new(0, indSize, 0, indSize)}, 0.18, Enum.EasingStyle.Back)
                             end)
                          Library:SafeCallback(compDef.Callback, state)
                              storeFlag(compDef.Flag, state)
                         end

                         track(box.MouseButton1Click:Connect(toggle))

                         local flagObj = {
                             Value = state,
                             Default = compDef.Default,
                              Set = function(self, val)
                                  state = val
                                  self.Value = val
                                  updateState(true)
                                  Library:SafeCallback(compDef.Callback, state)
                              end
                         }
                         if compDef.Flag then savedFlags[compDef.Flag] = flagObj end
                        
                    elseif compDef.Type == "Slider" then
                        local sldFrame = mk("Frame", {
                            Parent = secFrame,
                            Size = UDim2.new(1, 0, 0, 48),
                            BackgroundTransparency = 1,
                            ClipsDescendants = false
                        })
                        local lbl = mk("TextLabel", {
                            Parent = sldFrame,
                            Size = UDim2.new(1, -50, 0, 20),
                            Position = UDim2.new(0, 0, 0, 0),
                            BackgroundTransparency = 1,
                            Text = compDef.Name,
                            Font = Enum.Font.GothamMedium,
                            TextSize = 13,
                            TextXAlignment = Enum.TextXAlignment.Left
                        })
                        Theme:Register(lbl, "TextColor3", "Text")

                        local valLbl = mk("TextLabel", {
                            Parent = sldFrame,
                            Size = UDim2.new(0, 50, 0, 20),
                            Position = UDim2.new(1, -50, 0, 0),
                            BackgroundTransparency = 1,
                            Text = tostring(compDef.Default),
                            Font = Enum.Font.GothamMedium,
                            TextSize = 13,
                            TextXAlignment = Enum.TextXAlignment.Right
                        })
                        Theme:Register(valLbl, "TextColor3", "SubText")

                        local trackHeight = 6
                        local knobSize = 16
                        local trackY = 21

                        local trackBar = mk("Frame", {
                            Parent = sldFrame,
                            Size = UDim2.new(1, 0, 0, trackHeight),
                            Position = UDim2.new(0, 0, 0, trackY),
                            BackgroundColor3 = Theme.Themes.Default.Container,
                            ZIndex = 1
                        })
                        Theme:Register(trackBar, "BackgroundColor3", "Container")
                        mk("UICorner", {Parent = trackBar, CornerRadius = UDim.new(1, 0)})
                        Theme:Register(mk("UIStroke", {Parent = trackBar, Thickness = 1, Color = Theme.Themes.Default.Border, Transparency = 0.5}), "Color", "Border")

                        local fill = mk("Frame", {
                            Parent = trackBar,
                            Size = UDim2.new(0, 0, 1, 0),
                            BackgroundColor3 = Theme.Themes.Default.Accent,
                            ZIndex = 2
                        })
                        Theme:Register(fill, "BackgroundColor3", "Accent")
                        mk("UICorner", {Parent = fill, CornerRadius = UDim.new(1, 0)})
                        mk("UIGradient", {
                            Parent = fill,
                            Transparency = NumberSequence.new({
                                NumberSequenceKeypoint.new(0, 0),
                                NumberSequenceKeypoint.new(1, 0.25)
                            }),
                            Rotation = 90
                        })

                        local knobHitboxSize = 24
                        local knobHitbox = mk("TextButton", {
                            Parent = fill,
                            Size = UDim2.new(0, knobHitboxSize, 0, knobHitboxSize),
                            Position = UDim2.new(1, -knobHitboxSize/2, 0.5, -knobHitboxSize/2),
                            BackgroundTransparency = 1,
                            Text = "",
                            AutoButtonColor = false,
                            ZIndex = 4
                        })
                        local knob = mk("Frame", {
                            Parent = knobHitbox,
                            Size = UDim2.new(0, knobSize, 0, knobSize),
                            Position = UDim2.new(0.5, -knobSize/2, 0.5, -knobSize/2),
                            BackgroundColor3 = Theme.Themes.Default.Text,
                            ZIndex = 3
                        })
                        Theme:Register(knob, "BackgroundColor3", "Text")
                        mk("UICorner", {Parent = knob, CornerRadius = UDim.new(1, 0)})
                        local knobStroke = mk("UIStroke", {Parent = knob, Thickness = 2, Color = Theme.Themes.Default.Accent, Transparency = 0})
                        Theme:Register(knobStroke, "Color", "Accent")
                        addShadow(knob, 0.5, 6)

                        local tooltip = mk("Frame", {
                            Parent = knob,
                            Size = UDim2.new(0, 40, 0, 22),
                            Position = UDim2.new(0.5, 0, 0, -28),
                            AnchorPoint = Vector2.new(0.5, 0),
                            BackgroundColor3 = Theme.Themes.Default.Container,
                            ZIndex = 10,
                            Visible = false,
                            ClipsDescendants = false
                        })
                        Theme:Register(tooltip, "BackgroundColor3", "Container")
                        mk("UICorner", {Parent = tooltip, CornerRadius = UDim.new(0, 6)})
                        Theme:Register(mk("UIStroke", {Parent = tooltip, Thickness = 1, Color = Theme.Themes.Default.Accent, Transparency = 0.3}), "Color", "Accent")
                        local tooltipText = mk("TextLabel", {
                            Parent = tooltip,
                            Size = UDim2.new(1, 0, 1, 0),
                            BackgroundTransparency = 1,
                            Text = "",
                            Font = Enum.Font.GothamBold,
                            TextSize = 11,
                            TextXAlignment = Enum.TextXAlignment.Center,
                            TextColor3 = Theme.Themes.Default.Accent,
                            ZIndex = 11
                        })
                        Theme:Register(tooltipText, "TextColor3", "Accent")

                        local dragging = false
                        local hover = false
                        local dragInput = nil
                        local value = flagStart(compDef, compDef.Default or compDef.Min)
                        tooltipText.Text = tostring(value)

                        local function setKnobSize(size)
                            tween(knob, {Size = UDim2.new(0, size, 0, size), Position = UDim2.new(0.5, -size/2, 0.5, -size/2)}, 0.2, Enum.EasingStyle.Back)
                        end

                        local function setFill(percent)
                            fill.Size = UDim2.new(percent, 0, 1, 0)
                        end

                        local function update(input)
                            local w = trackBar.AbsoluteSize.X
                            if w == 0 then return end
                            local percent = math.clamp((input.Position.X - trackBar.AbsolutePosition.X) / w, 0, 1)
                            value = math.floor(compDef.Min + (compDef.Max - compDef.Min) * percent)
                            valLbl.Text = tostring(value)
                            tooltipText.Text = tostring(value)
                            setFill(percent)
                            Library:SafeCallback(compDef.Callback, value)
                            storeFlag(compDef.Flag, value)
                        end

                        local function startDrag(input)
                            dragging = true
                            dragInput = input
                            tooltip.Visible = true
                            tooltipText.TextTransparency = 1
                            tooltip.Size = UDim2.new(0, 40, 0, 0)
                            tween(tooltip, {Size = UDim2.new(0, 40, 0, 22)}, 0.15, Enum.EasingStyle.Back)
                            tween(tooltipText, {TextTransparency = 0}, 0.15, Enum.EasingStyle.Back)
                            setKnobSize(knobSize + 4)
                            tween(knobStroke, {Thickness = 2.5, Transparency = 0}, 0.2)
                            update(input)
                        end

                        local function endDrag()
                            dragging = false
                            dragInput = nil
                            tween(tooltipText, {TextTransparency = 1}, 0.1)
                            tween(tooltip, {Size = UDim2.new(0, 40, 0, 0)}, 0.15, Enum.EasingStyle.Quad)
                            task.delay(0.15, function()
                                if not dragging then
                                    tooltip.Visible = false
                                    tooltipText.TextTransparency = 1
                                end
                            end)
                            if hover then
                                setKnobSize(knobSize + 2)
                                tween(knobStroke, {Thickness = 2, Transparency = 0.15}, 0.2)
                            else
                                setKnobSize(knobSize)
                                tween(knobStroke, {Thickness = 2, Transparency = 0.3}, 0.2)
                            end
                        end

                        track(knobHitbox.MouseEnter:Connect(function()
                            hover = true
                            if not dragging then
                                setKnobSize(knobSize + 2)
                                tween(knobStroke, {Thickness = 2, Transparency = 0.15}, 0.2)
                            end
                        end))
                        track(knobHitbox.MouseLeave:Connect(function()
                            hover = false
                            if not dragging then
                                setKnobSize(knobSize)
                                tween(knobStroke, {Thickness = 2, Transparency = 0.3}, 0.2)
                            end
                        end))
                        track(knobHitbox.InputBegan:Connect(function(input)
                            if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) and not dragInput then
                                startDrag(input)
                            end
                        end))
                        track(UserInputService.InputChanged:Connect(function(input)
                            if not dragging then return end
                            -- touch is weird u gotta check which finger or sliders break
                            if input.UserInputType == Enum.UserInputType.Touch and input ~= dragInput then return end
                            if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
                                update(input)
                            end
                        end))
                        track(UserInputService.InputEnded:Connect(function(input)
                            if not dragging then return end
                            if input.UserInputType == Enum.UserInputType.Touch and input ~= dragInput then return end
                            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                                endDrag()
                            end
                        end))

                        local span = math.max(1, compDef.Max - compDef.Min)
                        local percent = math.clamp((value - compDef.Min) / span, 0, 1)
                        setFill(percent)

                        local flagObj = {
                            Value = value,
                            Default = compDef.Default,
                             Set = function(self, val)
                                 value = math.clamp(val, compDef.Min, compDef.Max)
                                 self.Value = value
                                 valLbl.Text = tostring(value)
                                 tooltipText.Text = tostring(value)
                                 local span = math.max(1, compDef.Max - compDef.Min)
                                 local p = math.clamp((value - compDef.Min) / span, 0, 1)
                                tween(fill, {Size = UDim2.new(p, 0, 1, 0)}, 0.1)
                                Library:SafeCallback(compDef.Callback, value)
                            end
                        }
                        if compDef.Flag then savedFlags[compDef.Flag] = flagObj end
                        
                    elseif compDef.Type == "Dropdown" then
                        local dpHeight = 52
                        local dpExpanded = 160
                        local dValue = flagStart(compDef, compDef.Default)
                        local dpFrame = mk("Frame", {
                            Parent = secFrame,
                            Size = UDim2.new(1, 0, 0, dpHeight),
                            BackgroundTransparency = 1,
                            ClipsDescendants = true
                        })
                        track(dpFrame:GetPropertyChangedSignal("Size"):Connect(function()
                            RefreshLayout()
                        end))
                        local lbl = mk("TextLabel", {
                            Parent = dpFrame,
                            Size = UDim2.new(1, 0, 0, 20),
                            BackgroundTransparency = 1,
                            Text = compDef.Name,
                            Font = Enum.Font.GothamMedium,
                            TextSize = 13,
                            TextXAlignment = Enum.TextXAlignment.Left
                        })
                        Theme:Register(lbl, "TextColor3", "Text")

                        local boxHeight = 28
                        local box = mk("TextButton", {
                            Parent = dpFrame,
                            Size = UDim2.new(1, 0, 0, boxHeight),
                            Position = UDim2.new(0, 0, 0, 24),
                            Text = " " .. tostring(dValue or "Select..."),
                            Font = Enum.Font.GothamMedium,
                            TextSize = 13,
                            TextXAlignment = Enum.TextXAlignment.Left,
                            AutoButtonColor = false
                        })
                        Theme:Register(box, "BackgroundColor3", "Container")
                        Theme:Register(box, "TextColor3", "SubText")
                        mk("UICorner", {Parent = box, CornerRadius = UDim.new(0, 6)})
                        local boxStroke = mk("UIStroke", {Parent = box, Thickness = 1, Color = Theme.Themes.Default.Border, Transparency = 0.5})
                        Theme:Register(boxStroke, "Color", "Border")
                        
                        local icon = mk("TextLabel", {
                            Parent = box,
                            Size = UDim2.new(0, 20, 1, 0),
                            Position = UDim2.new(1, -25, 0, 0),
                            BackgroundTransparency = 1,
                            Text = "â–¼",
                            Font = Enum.Font.Gotham,
                            TextSize = 10
                        })
                        Theme:Register(icon, "TextColor3", "SubText")
                        
                        local dpItems = compDef.Items or {}
                        local listPos = 56
                        local optHeight = 26
                        local listFrame = mk("ScrollingFrame", {
                            Parent = dpFrame,
                            Size = UDim2.new(1, 0, 0, 100),
                            Position = UDim2.new(0, 0, 0, listPos),
                            BackgroundTransparency = 0,
                            BorderSizePixel = 0,
                            ScrollBarThickness = 0,
                            CanvasSize = UDim2.new(0, 0, 0, #dpItems * (optHeight + 2))
                        })
                        Theme:Register(listFrame, "BackgroundColor3", "Background")
                        Theme:Register(listFrame, "ScrollBarImageColor3", "Accent")
                        mk("UICorner", {Parent = listFrame, CornerRadius = UDim.new(0, 6)})
                        Theme:Register(mk("UIStroke", {Parent = listFrame, Thickness = 1, Color = Theme.Themes.Default.Border, Transparency = 0.5}), "Color", "Border")
                        mk("UIPadding", {
                            Parent = listFrame,
                            PaddingTop = UDim.new(0, 4),
                            PaddingBottom = UDim.new(0, 4),
                            PaddingLeft = UDim.new(0, 4),
                            PaddingRight = UDim.new(0, 4)
                        })
                        
                        local listLayout = mk("UIListLayout", {
                            Parent = listFrame,
                            SortOrder = Enum.SortOrder.LayoutOrder,
                            Padding = UDim.new(0, 2)
                        })
                        
                        local expanded = false
                        local optionBtns = {}
                        
                        for i, item in ipairs(dpItems) do
                            local opt = mk("TextButton", {
                                Parent = listFrame,
                                Size = UDim2.new(1, -4, 0, optHeight),
                                BackgroundTransparency = 1,
                                Text = "  " .. item,
                                Font = Enum.Font.GothamMedium,
                                TextSize = 13,
                                TextXAlignment = Enum.TextXAlignment.Left,
                                TextTruncate = Enum.TextTruncate.AtEnd,
                                AutoButtonColor = false
                            })
                            mk("UICorner", {Parent = opt, CornerRadius = UDim.new(0, 4)})
                            Theme:Register(opt, "TextColor3", "SubText")

                            local optCheck = mk("TextLabel", {
                                Parent = opt,
                                Size = UDim2.new(0, 16, 1, 0),
                                Position = UDim2.new(1, -18, 0, 0),
                                BackgroundTransparency = 1,
                                Text = "âœ“",
                                Font = Enum.Font.GothamBold,
                                TextSize = 12,
                                TextXAlignment = Enum.TextXAlignment.Center,
                                Visible = false,
                                ZIndex = 2
                            })
                            Theme:Register(optCheck, "TextColor3", "Accent")
                            if dValue == item then
                                optCheck.Visible = true
                                opt.TextColor3 = Theme.Themes.Default.Text
                            end

                            track(opt.MouseEnter:Connect(function()
                                opt.TextColor3 = Theme.Themes.Default.Text
                                opt.BackgroundColor3 = Theme.Themes.Default.Hover
                                tween(opt, {BackgroundTransparency = 0}, 0.2)
                            end))
                            track(opt.MouseLeave:Connect(function()
                                if dValue ~= item then
                                    opt.TextColor3 = Theme.Themes.Default.SubText
                                end
                                tween(opt, {BackgroundTransparency = 1}, 0.2)
                            end))

                            track(opt.MouseButton1Click:Connect(function()
                                dValue = item
                                box.Text = " " .. item
                                 for _, data in ipairs(optionBtns) do
                                     data.Btn.TextColor3 = Theme.Themes.Default.SubText
                                     Theme:Register(data.Btn, "TextColor3", "SubText")
                                     data.Check.Visible = false
                                 end
                                 opt.TextColor3 = Theme.Themes.Default.Text
                                 Theme:Register(opt, "TextColor3", "Text")
                                 optCheck.Visible = true
                                Library:SafeCallback(compDef.Callback, dValue)
                                storeFlag(compDef.Flag, dValue)

                                expanded = false
                                tween(dpFrame, {Size = UDim2.new(1, 0, 0, dpHeight)}, 0.25, Enum.EasingStyle.Quint)
                                tween(icon, {Rotation = 0}, 0.2)
                                tween(boxStroke, {Transparency = 0.5}, 0.2)
                            end))
                            table.insert(optionBtns, {Btn = opt, Check = optCheck, Item = item})
                        end
                        
                        track(box.MouseButton1Click:Connect(function()
                            expanded = not expanded
                            if expanded then
                                tween(dpFrame, {Size = UDim2.new(1, 0, 0, dpExpanded)}, 0.25, Enum.EasingStyle.Quint)
                                tween(icon, {Rotation = 180}, 0.2)
                                tween(boxStroke, {Transparency = 0}, 0.2)
                            else
                                tween(dpFrame, {Size = UDim2.new(1, 0, 0, dpHeight)}, 0.25, Enum.EasingStyle.Quint)
                                tween(icon, {Rotation = 0}, 0.2)
                                tween(boxStroke, {Transparency = 0.5}, 0.2)
                            end
                        end))
                        
                        local flagObj = {
                            Value = dValue,
                            Default = compDef.Default,
                             Set = function(self, val)
                                 dValue = val
                                 self.Value = val
                                 box.Text = " " .. tostring(val)
                                 for _, data in ipairs(optionBtns) do
                                     local on = data.Item == val
                                     data.Check.Visible = on
                                     data.Btn.TextColor3 = on and Theme.Themes.Default.Text or Theme.Themes.Default.SubText
                                     Theme:Register(data.Btn, "TextColor3", on and "Text" or "SubText")
                                 end
                                 Library:SafeCallback(compDef.Callback, val)
                             end
                        }
                        if compDef.Flag then savedFlags[compDef.Flag] = flagObj end

                    elseif compDef.Type == "Input" then
                        local inpFrame = mk("Frame", {
                            Parent = secFrame,
                            Size = UDim2.new(1, 0, 0, 54),
                            BackgroundTransparency = 1
                        })
                        local lbl = mk("TextLabel", {
                            Parent = inpFrame,
                            Size = UDim2.new(1, 0, 0, 18),
                            BackgroundTransparency = 1,
                            Text = compDef.Name,
                            Font = Enum.Font.GothamMedium,
                            TextSize = 13,
                            TextXAlignment = Enum.TextXAlignment.Left
                        })
                        Theme:Register(lbl, "TextColor3", "Text")

                        local iValue = flagStart(compDef, compDef.Default or "")
                        local inp = mk("TextBox", {
                            Parent = inpFrame,
                            Size = UDim2.new(1, 0, 0, 32),
                            Position = UDim2.new(0, 0, 0, 22),
                            BackgroundColor3 = Theme.Themes.Default.Container,
                            BorderSizePixel = 0,
                            Text = iValue,
                            PlaceholderText = compDef.Placeholder or "",
                            TextSize = 13,
                            TextXAlignment = Enum.TextXAlignment.Left,
                            ClearTextOnFocus = false
                        })
                        Theme:Register(inp, "BackgroundColor3", "Container")
                        Theme:Register(inp, "TextColor3", "Text")
                        Theme:Register(inp, "PlaceholderColor3", "SubText")
                        mk("UICorner", {Parent = inp, CornerRadius = UDim.new(0, 6)})
                        local inpStroke = mk("UIStroke", {Parent = inp, Thickness = 1, Color = Theme.Themes.Default.Border, Transparency = 0.5})
                        Theme:Register(inpStroke, "Color", "Border")

                        track(inp.Focused:Connect(function()
                            tween(inpStroke, {Color = Theme.Themes.Default.Accent, Transparency = 0}, 0.15)
                        end))
                        track(inp.FocusLost:Connect(function()
                            tween(inpStroke, {Color = Theme.Themes.Default.Border, Transparency = 0.5}, 0.2)
                            local newVal = inp.Text
                            if newVal ~= iValue then
                                iValue = newVal
                                Library:SafeCallback(compDef.Callback, iValue)
                                storeFlag(compDef.Flag, iValue)
                            end
                        end))

                        local inpFlag = {
                            Value = iValue,
                            Default = compDef.Default,
                            Set = function(self, val)
                                iValue = tostring(val or "")
                                self.Value = iValue
                                inp.Text = iValue
                                Library:SafeCallback(compDef.Callback, iValue)
                            end
                        }
                        if compDef.Flag then savedFlags[compDef.Flag] = inpFlag end

                    elseif compDef.Type == "Keybind" then
                        local kbFrame = mk("Frame", {
                            Parent = secFrame,
                            Size = UDim2.new(1, 0, 0, 32),
                            BackgroundTransparency = 1
                        })
                        local lbl = mk("TextLabel", {
                            Parent = kbFrame,
                            Size = UDim2.new(1, -100, 1, 0),
                            BackgroundTransparency = 1,
                            Text = compDef.Name,
                            Font = Enum.Font.GothamMedium,
                            TextSize = 13,
                            TextXAlignment = Enum.TextXAlignment.Left,
                            TextTruncate = Enum.TextTruncate.AtEnd
                        })
                        Theme:Register(lbl, "TextColor3", "SubText")

                        local kbValue = flagStart(compDef, compDef.Default)
                        local listening = false
                        local box = mk("TextButton", {
                            Parent = kbFrame,
                            Size = UDim2.new(0, 90, 0, 24),
                            Position = UDim2.new(1, -90, 0.5, -12),
                            BackgroundColor3 = Theme.Themes.Default.Container,
                            BorderSizePixel = 0,
                            Text = kbValue and kbValue.Name or "None",
                            Font = Enum.Font.GothamMedium,
                            TextSize = 12,
                            AutoButtonColor = false
                        })
                        Theme:Register(box, "BackgroundColor3", "Container")
                        mk("UICorner", {Parent = box, CornerRadius = UDim.new(0, 6)})
                        local boxStroke = mk("UIStroke", {Parent = box, Thickness = 1, Color = Theme.Themes.Default.Border, Transparency = 0.5})
                        Theme:Register(boxStroke, "Color", "Border")

                        local function setListening(on)
                            listening = on
                            listeningKeybind = on
                            box.Text = on and "..." or (kbValue and kbValue.Name or "None")
                            tween(box, {BackgroundColor3 = on and Theme.Themes.Default.Accent or Theme.Themes.Default.Container}, 0.2)
                            tween(boxStroke, {Color = on and Theme.Themes.Default.Accent or Theme.Themes.Default.Border, Transparency = on and 0 or 0.5}, 0.2)
                            Theme:Register(box, "BackgroundColor3", on and "Accent" or "Container")
                            Theme:Register(boxStroke, "Color", on and "Accent" or "Border")
                        end

                        track(box.MouseButton1Click:Connect(function()
                            if listening then
                                setListening(false)
                                return
                            end
                            setListening(true)
                        end))

                        -- grab the next key they press, escape lets em bail
                        local kbConn = nil
                        kbConn = UserInputService.InputBegan:Connect(function(input, processed)
                            if not listening then return end
                            if processed and input.UserInputType ~= Enum.UserInputType.Keyboard then return end

                            if input.KeyCode == Enum.KeyCode.Escape then
                                -- cancelled, put it back how it was
                                setListening(false)
                                return
                            end

                            kbValue = input.KeyCode
                            setListening(false)
                            box.Text = kbValue.Name
                            Library:SafeCallback(compDef.Callback, kbValue)
                            storeFlag(compDef.Flag, kbValue)
                        end)
                        track(kbConn)

                        local kbFlag = {
                            Value = kbValue,
                            Default = compDef.Default,
                            Set = function(self, val)
                                kbValue = val
                                self.Value = val
                                listening = false
                                box.Text = val and val.Name or "None"
                                Library:SafeCallback(compDef.Callback, val)
                            end
                        }
                        if compDef.Flag then savedFlags[compDef.Flag] = kbFlag end
                    end
                end
                
                secFrame.Size = UDim2.new(1, -20, 0, secLayout.AbsoluteContentSize.Y + 28)
                table.insert(sectionRefs, {Frame = secFrame, Layout = secLayout})
            end
            
            scroll.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 20)
            
            tabObj.ContentRoot = canvasGroup
            tabObj.ContentLayout = layout
            tabObj.SectionRefs = sectionRefs
        end
        
        -- sections just save what to build, tab builds on first click
        function tabObj:CreateSection(secName)
            local secDef = {Name = secName, Components = {}}
            table.insert(tabObj.SectionDefs, secDef)
            
            local secMethods = {}
            
            function secMethods:CreateButton(btnName, callback, variant)
                table.insert(secDef.Components, {Type = "Button", Name = btnName, Callback = callback, Variant = variant or "Default"})
            end

            -- just text, no state, nothing to save
            function secMethods:CreateLabel(lblText, desc)
                table.insert(secDef.Components, {Type = "Label", Name = lblText, Desc = desc})
            end

            function secMethods:CreateDivider()
                table.insert(secDef.Components, {Type = "Divider"})
            end

            function secMethods:CreateInput(inpName, default, placeholder, callback, flagName)
                if not flagName then flagName = nextFlag() end
                registerFlag(flagName, default or "", "Input")
                table.insert(secDef.Components, {Type = "Input", Name = inpName, Default = default or "", Placeholder = placeholder, Callback = callback, Flag = flagName})
            end

            function secMethods:CreateKeybind(kbName, default, callback, flagName)
                if not flagName then flagName = nextFlag() end
                registerFlag(flagName, default, "Keybind")
                table.insert(secDef.Components, {Type = "Keybind", Name = kbName, Default = default, Callback = callback, Flag = flagName})
            end

            function secMethods:CreateToggle(tglName, default, callback, flagName)
                if not flagName then flagName = nextFlag() end
                registerFlag(flagName, default, "Toggle")
                table.insert(secDef.Components, {Type = "Toggle", Name = tglName, Default = default, Callback = callback, Flag = flagName})
            end

            function secMethods:CreateSlider(sldName, min, max, default, callback, flagName)
                if not flagName then flagName = nextFlag() end
                registerFlag(flagName, default, "Slider")
                flagDefs[flagName].Min = min
                flagDefs[flagName].Max = max
                table.insert(secDef.Components, {Type = "Slider", Name = sldName, Min = min, Max = max, Default = default, Callback = callback, Flag = flagName})
            end

            function secMethods:CreateDropdown(dpName, items, default, callback, flagName)
                if not flagName then flagName = nextFlag() end
                registerFlag(flagName, default, "Dropdown")
                table.insert(secDef.Components, {Type = "Dropdown", Name = dpName, Items = items, Default = default, Callback = callback, Flag = flagName})
            end
            
            return secMethods
        end
        
        -- switching tabs
        local function SelectTab()
            if windowObj.switching then return end
            if windowObj.CurrentTab == tabObj then return end

            windowObj.switching = true

            local oldTab = windowObj.CurrentTab

            if oldTab and oldTab.ContentRoot and oldTab.ContentRoot.Parent == contentArea then
    tween(oldTab.ContentRoot, {GroupTransparency = 1}, 0.2, Enum.EasingStyle.Quint)
    task.delay(0.2, function()
        if oldTab.ContentRoot and oldTab.ContentRoot.Parent == contentArea then
            oldTab.ContentRoot.Parent = hiddenContainer
            oldTab.ContentRoot.Visible = false
        end
    end)
                Theme:Register(oldTab.Button, "TextColor3", "SubText")
                tween(oldTab.Button, {BackgroundTransparency = 1}, 0.2)
                local oldIndicatorTarget = UDim2.new(0, 3, 0, 0)
                tween(oldTab.Indicator, {Size = oldIndicatorTarget}, 0.2)
            end

            windowObj.CurrentTab = tabObj

            if not tabObj.ContentRoot then
                if customBuild then
                    customBuild(tabObj, hiddenContainer)
                else
                    BuildTabContent()
                end
            end

            if not tabObj.ContentRoot then
                windowObj.switching = false
                return
            end

            tabObj.ContentRoot.GroupTransparency = 1
            tabObj.ContentRoot.Visible = true
            tabObj.ContentRoot.Parent = contentArea

            tween(tabObj.ContentRoot, {GroupTransparency = 0}, 0.2, Enum.EasingStyle.Quint)

            task.delay(0.2, function()
                if tabObj.ContentRoot and tabObj.ContentRoot.Parent then
                    tabObj.ContentRoot.GroupTransparency = 0
                end
            end)

            Theme:Register(tabBtn, "TextColor3", "Text")
            Theme:Register(tabBtn, "BackgroundColor3", "Hover")
            tween(tabBtn, {BackgroundTransparency = 0}, 0.2)
            local activeIndicatorTarget = UDim2.new(0, 3, 0, 18)
            tween(activeIndicator, {Size = activeIndicatorTarget}, 0.2, Enum.EasingStyle.Back)

            task.delay(0.2, function()
                windowObj.switching = false
            end)

            task.defer(function()
                if tabObj.RefreshLayout then
                    tabObj.RefreshLayout()
                end
            end)

            tabObj.Loaded = true
        end
        
        tabObj.Select = SelectTab
        track(tabBtn.MouseButton1Click:Connect(SelectTab))
        
        table.insert(self.Tabs, tabObj)
        return tabObj
    end
    
    -- default tabs (home / servers / customize / settings)
    local function BuildHomeTab(tabObj, container)
        local canvasGroup = mk("CanvasGroup", {
            Parent = container,
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundColor3 = Theme.Themes.Default.Background,
            GroupTransparency = 0
        })
        Theme:Register(canvasGroup, "BackgroundColor3", "Background")
        local scroll = mk("ScrollingFrame", {
            Parent = canvasGroup,
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundColor3 = Theme.Themes.Default.Background,
            BackgroundTransparency = 0,
            ScrollBarThickness = 0,
            CanvasSize = UDim2.new(0, 0, 0, 0)
        })
        Theme:Register(scroll, "BackgroundColor3", "Background")
        Theme:Register(scroll, "ScrollBarImageColor3", "Accent")

        local layout = mk("UIListLayout", {
            Parent = scroll,
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 10),
            HorizontalAlignment = Enum.HorizontalAlignment.Center
        })
        mk("UIPadding", {Parent = scroll, PaddingTop = UDim.new(0, 6), PaddingBottom = UDim.new(0, 20)})

        local welcomeFrame = mk("Frame", {
            Parent = scroll,
            Size = UDim2.new(1, -20, 0, 0),
            BackgroundTransparency = 0
        })
        welcomeFrame.LayoutOrder = 1
        Theme:Register(welcomeFrame, "BackgroundColor3", "Section")
        mk("UICorner", {Parent = welcomeFrame, CornerRadius = UDim.new(0, 12)})
        Theme:Register(mk("UIStroke", {Parent = welcomeFrame, Thickness = 1, Color = Theme.Themes.Default.Border, Transparency = 0.5}), "Color", "Border")

        local welcomeLayout = mk("UIListLayout", {
            Parent = welcomeFrame,
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 8)
        })
        mk("UIPadding", {
            Parent = welcomeFrame,
            PaddingTop = UDim.new(0, 20),
            PaddingBottom = UDim.new(0, 20),
            PaddingLeft = UDim.new(0, 20),
            PaddingRight = UDim.new(0, 20)
        })

        -- pfp + name row
        local avatarRow = mk("Frame", {
            Parent = welcomeFrame,
            Size = UDim2.new(1, 0, 0, 100),
            BackgroundTransparency = 1
        })
        avatarRow.LayoutOrder = 1

        local avatarImg = mk("ImageLabel", {
            Parent = avatarRow,
            Size = UDim2.new(0, 70, 0, 70),
            Position = UDim2.new(0, 0, 0.5, -35),
            BackgroundTransparency = 1,
            Image = "rbxasset://textures/ui/GuiImagePlaceholder.png"
        })
        mk("UICorner", {Parent = avatarImg, CornerRadius = UDim.new(1, 0)})
        local avatarStroke = mk("UIStroke", {Parent = avatarImg, Thickness = 2, Color = Theme.Themes.Default.Accent, Transparency = 0})
        Theme:Register(avatarStroke, "Color", "Accent")

        local function updateAvatar()
            local thumbType = Enum.ThumbnailType.AvatarBust
            local thumbSize = Enum.ThumbnailSize.Size420x420
            local ok, content, isReady = pcall(function()
                return Players:GetUserThumbnailAsync(LocalPlayer.UserId, thumbType, thumbSize)
            end)
            if not ok then return end
            local tries = 0
            while not isReady and tries < 10 do
                task.wait(0.5)
                local ok2, c, r = pcall(function()
                    return Players:GetUserThumbnailAsync(LocalPlayer.UserId, thumbType, thumbSize)
                end)
                if ok2 then content, isReady = c, r end
                tries = tries + 1
            end
            if avatarImg and avatarImg.Parent then
                avatarImg.Image = content
            end
        end

        task.spawn(updateAvatar)

        local nameStack = mk("Frame", {
            Parent = avatarRow,
            Size = UDim2.new(1, -85, 1, 0),
            Position = UDim2.new(0, 85, 0, 0),
            BackgroundTransparency = 1
        })
        local nameLayout = mk("UIListLayout", {
            Parent = nameStack,
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 4),
            VerticalAlignment = Enum.VerticalAlignment.Center
        })

        -- hi row (+ premium tag if they got it)
        local isPremium = LocalPlayer.MembershipType == Enum.MembershipType.Premium
        local badgeOffset = isPremium and 74 or 0

        local greetRow = mk("Frame", {
            Parent = nameStack,
            Size = UDim2.new(1, 0, 0, 26),
            BackgroundTransparency = 1
        })
        greetRow.LayoutOrder = 1

        if isPremium then
            local premiumBadge = mk("Frame", {
                Parent = greetRow,
                Size = UDim2.new(0, 0, 0, 18),
                Position = UDim2.new(0, 0, 0.5, -9),
                AutomaticSize = Enum.AutomaticSize.X,
                BackgroundTransparency = 0
            })
            Theme:Register(premiumBadge, "BackgroundColor3", "Accent")
            mk("UICorner", {Parent = premiumBadge, CornerRadius = UDim.new(0, 4)})
            mk("UIPadding", {Parent = premiumBadge, PaddingLeft = UDim.new(0, 6), PaddingRight = UDim.new(0, 6)})
            local premiumLbl = mk("TextLabel", {
                Parent = premiumBadge,
                AutomaticSize = Enum.AutomaticSize.X,
                Size = UDim2.new(1, 0, 1, 0),
                BackgroundTransparency = 1,
                Text = "PREMIUM",
                Font = Enum.Font.GothamBold,
                TextSize = 10,
                TextXAlignment = Enum.TextXAlignment.Left
            })
            Theme:Register(premiumLbl, "TextColor3", "Background")
        end

        local greetLbl = mk("TextLabel", {
            Parent = greetRow,
            Size = UDim2.new(1, -badgeOffset, 1, 0),
            Position = UDim2.new(0, badgeOffset, 0, 0),
            BackgroundTransparency = 1,
            Text = "Welcome, " .. LocalPlayer.DisplayName,
            Font = Enum.Font.GothamBold,
            TextSize = 20,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextTruncate = Enum.TextTruncate.AtEnd
        })
        Theme:Register(greetLbl, "TextColor3", "Text")

        local thanksLbl = mk("TextLabel", {
            Parent = nameStack,
            Size = UDim2.new(1, 0, 0, 18),
            BackgroundTransparency = 1,
            Text = "Thanks for using my script!",
            Font = Enum.Font.GothamMedium,
            TextSize = 13,
            TextXAlignment = Enum.TextXAlignment.Left
        })
        Theme:Register(thanksLbl, "TextColor3", "SubText")
        thanksLbl.LayoutOrder = 2

        local userLbl = mk("TextLabel", {
            Parent = nameStack,
            Size = UDim2.new(1, 0, 0, 18),
            BackgroundTransparency = 1,
            Text = "@" .. LocalPlayer.Name,
            Font = Enum.Font.GothamMedium,
            TextSize = 13,
            TextXAlignment = Enum.TextXAlignment.Left
        })
        Theme:Register(userLbl, "TextColor3", "SubText")
        userLbl.LayoutOrder = 3

        local metaRow = mk("Frame", {
            Parent = nameStack,
            Size = UDim2.new(1, 0, 0, 18),
            BackgroundTransparency = 1
        })
        metaRow.LayoutOrder = 4

        local ageLbl = mk("TextLabel", {
            Parent = metaRow,
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            Text = tostring(LocalPlayer.AccountAge) .. " days old",
            Font = Enum.Font.GothamMedium,
            TextSize = 12,
            TextXAlignment = Enum.TextXAlignment.Left
        })
        Theme:Register(ageLbl, "TextColor3", "SubText")

        local infoFrame = mk("Frame", {
            Parent = scroll,
            Size = UDim2.new(1, -20, 0, 0),
            BackgroundTransparency = 0
        })
        infoFrame.LayoutOrder = 2
        Theme:Register(infoFrame, "BackgroundColor3", "Section")
        mk("UICorner", {Parent = infoFrame, CornerRadius = UDim.new(0, 6)})
        Theme:Register(mk("UIStroke", {Parent = infoFrame, Thickness = 1, Color = Theme.Themes.Default.Border, Transparency = 0.5}), "Color", "Border")

        local infoLayout = mk("UIListLayout", {
            Parent = infoFrame,
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 10)
        })
        mk("UIPadding", {
            Parent = infoFrame,
            PaddingTop = UDim.new(0, 14),
            PaddingBottom = UDim.new(0, 14),
            PaddingLeft = UDim.new(0, 14),
            PaddingRight = UDim.new(0, 14)
        })

        local infoTitle = mk("TextLabel", {
            Parent = infoFrame,
            Size = UDim2.new(1, 0, 0, 24),
            BackgroundTransparency = 1,
            Text = "RUI",
            Font = Enum.Font.GothamBold,
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left
        })
        Theme:Register(infoTitle, "TextColor3", "Text")
        infoTitle.LayoutOrder = 1

        local infoDivider = mk("Frame", {
            Parent = infoFrame,
            Size = UDim2.new(1, 0, 0, 1),
            BackgroundTransparency = 0.5,
            BorderSizePixel = 0
        })
        Theme:Register(infoDivider, "BackgroundColor3", "Border")
        infoDivider.LayoutOrder = 2

        local scriptInfoBox = mk("TextBox", {
            Parent = infoFrame,
            Size = UDim2.new(1, 0, 0, 80),
            BackgroundTransparency = 0,
            Text = "No script info provided.",
            Font = Enum.Font.GothamMedium,
            TextSize = 12,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextYAlignment = Enum.TextYAlignment.Top,
            TextWrapped = true,
            ClearTextOnFocus = false,
            MultiLine = true,
            PlaceholderText = "Script information will appear here..."
        })
        scriptInfoBox.LayoutOrder = 3
        Theme:Register(scriptInfoBox, "BackgroundColor3", "Container")
        Theme:Register(scriptInfoBox, "TextColor3", "SubText")
        mk("UICorner", {Parent = scriptInfoBox, CornerRadius = UDim.new(0, 6)})
        Theme:Register(mk("UIStroke", {Parent = scriptInfoBox, Thickness = 1, Color = Theme.Themes.Default.Border, Transparency = 0.5}), "Color", "Border")
        mk("UIPadding", {Parent = scriptInfoBox, PaddingTop = UDim.new(0, 8), PaddingBottom = UDim.new(0, 8), PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8)})

        windowObj.infoBox = scriptInfoBox

        local function RefreshHomeLayout()
            welcomeFrame.Size = UDim2.new(1, -20, 0, welcomeLayout.AbsoluteContentSize.Y + 40)
            infoFrame.Size = UDim2.new(1, -20, 0, infoLayout.AbsoluteContentSize.Y + 28)
            scroll.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 20)
        end
        tabObj.RefreshLayout = RefreshHomeLayout

        tabObj.ContentRoot = canvasGroup
        tabObj.ContentLayout = layout

        RefreshHomeLayout()
    end
    
    -- servers tab
    local function BuildServersTab(tabObj, container)
            local canvasGroup = mk("CanvasGroup", {
                Parent = hiddenContainer,
                Size = UDim2.new(1, 0, 1, 0),
                BackgroundColor3 = Theme.Themes.Default.Background,
                GroupTransparency = 0
            })
            Theme:Register(canvasGroup, "BackgroundColor3", "Background")
            local scroll = mk("ScrollingFrame", {
                Parent = canvasGroup,
                Size = UDim2.new(1, 0, 1, 0),
                BackgroundColor3 = Theme.Themes.Default.Background,
                BackgroundTransparency = 0,
                ScrollBarThickness = 0,
                CanvasSize = UDim2.new(0, 0, 0, 0)
            })
            Theme:Register(scroll, "BackgroundColor3", "Background")
            Theme:Register(scroll, "ScrollBarImageColor3", "Accent")
        
        local layout = mk("UIListLayout", {
            Parent = scroll,
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 10),
            HorizontalAlignment = Enum.HorizontalAlignment.Center
        })
        mk("UIPadding", {Parent = scroll, PaddingTop = UDim.new(0, 6), PaddingBottom = UDim.new(0, 20)})
        
        local curFrame = mk("Frame", {
            Parent = scroll,
            Size = UDim2.new(1, -20, 0, 0),
            BackgroundTransparency = 0
        })
        Theme:Register(curFrame, "BackgroundColor3", "Section")
        mk("UICorner", {Parent = curFrame, CornerRadius = UDim.new(0, 6)})
        Theme:Register(mk("UIStroke", {Parent = curFrame, Thickness = 1, Color = Theme.Themes.Default.Border, Transparency = 0.5}), "Color", "Border")
        
        local curLayout = mk("UIListLayout", {
            Parent = curFrame,
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 8)
        })
        mk("UIPadding", {
            Parent = curFrame, PaddingTop = UDim.new(0, 14), PaddingBottom = UDim.new(0, 14),
            PaddingLeft = UDim.new(0, 14), PaddingRight = UDim.new(0, 14)
        })
        
        local curTitle = mk("TextLabel", {
            Parent = curFrame, Size = UDim2.new(1, 0, 0, 24), BackgroundTransparency = 1,
            Text = "Current Server", Font = Enum.Font.GothamBold, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left
        })
        Theme:Register(curTitle, "TextColor3", "Text")
        
        local jobIdLbl = mk("TextLabel", {
            Parent = curFrame, Size = UDim2.new(1, 0, 0, 16), BackgroundTransparency = 1,
            Text = "Job ID: " .. game.JobId, Font = Enum.Font.GothamMedium, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left
        })
        Theme:Register(jobIdLbl, "TextColor3", "SubText")
        
        local placeIdLbl = mk("TextLabel", {
            Parent = curFrame, Size = UDim2.new(1, 0, 0, 16), BackgroundTransparency = 1,
            Text = "Place ID: " .. game.PlaceId, Font = Enum.Font.GothamMedium, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left
        })
        Theme:Register(placeIdLbl, "TextColor3", "SubText")
        
        local playerCountLbl = mk("TextLabel", {
            Parent = curFrame, Size = UDim2.new(1, 0, 0, 16), BackgroundTransparency = 1,
            Text = "Players: " .. #Players:GetPlayers() .. " / " .. Players.MaxPlayers,
            Font = Enum.Font.GothamMedium, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left
        })
        Theme:Register(playerCountLbl, "TextColor3", "SubText")
        
        -- server browser
        local browserFrame = mk("Frame", {
            Parent = scroll,
            Size = UDim2.new(1, -20, 0, 0),
            BackgroundTransparency = 0
        })
        Theme:Register(browserFrame, "BackgroundColor3", "Section")
        mk("UICorner", {Parent = browserFrame, CornerRadius = UDim.new(0, 6)})
        Theme:Register(mk("UIStroke", {Parent = browserFrame, Thickness = 1, Color = Theme.Themes.Default.Border, Transparency = 0.5}), "Color", "Border")
        
        local browserLayout = mk("UIListLayout", {
            Parent = browserFrame,
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 8)
        })
        mk("UIPadding", {
            Parent = browserFrame, PaddingTop = UDim.new(0, 14), PaddingBottom = UDim.new(0, 14),
            PaddingLeft = UDim.new(0, 14), PaddingRight = UDim.new(0, 14)
        })
        
        local browserTitle = mk("TextLabel", {
            Parent = browserFrame, Size = UDim2.new(1, 0, 0, 24), BackgroundTransparency = 1,
            Text = "Server Browser", Font = Enum.Font.GothamBold, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left
        })
        Theme:Register(browserTitle, "TextColor3", "Text")
        
        -- search
        local searchBox = mk("TextBox", {
            Parent = browserFrame, Size = UDim2.new(1, 0, 0, 28), BackgroundTransparency = 0,
            Text = "", Font = Enum.Font.GothamMedium, TextSize = 12,
            PlaceholderText = "Search Server ID...",
            ClearTextOnFocus = false, TextXAlignment = Enum.TextXAlignment.Left
        })
        Theme:Register(searchBox, "BackgroundColor3", "Container")
        Theme:Register(searchBox, "TextColor3", "SubText")
        mk("UICorner", {Parent = searchBox, CornerRadius = UDim.new(0, 6)})
        Theme:Register(mk("UIStroke", {Parent = searchBox, Thickness = 1, Color = Theme.Themes.Default.Border, Transparency = 0.5}), "Color", "Border")
        
        -- rejoin + hop next to each other
        local btnRow = mk("Frame", {
            Parent = browserFrame, Size = UDim2.new(1, 0, 0, 28), BackgroundTransparency = 1
        })
        local btnRowLayout = mk("UIListLayout", {
            Parent = btnRow, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 8), FillDirection = Enum.FillDirection.Horizontal, HorizontalAlignment = Enum.HorizontalAlignment.Center
        })
        
        local rejoinBtn = mk("TextButton", {
            Parent = btnRow, Size = UDim2.new(0.5, -4, 1, 0), Text = "Rejoin",
            Font = Enum.Font.GothamMedium, TextSize = 13, AutoButtonColor = false
        })
        Theme:Register(rejoinBtn, "BackgroundColor3", "Container")
        Theme:Register(rejoinBtn, "TextColor3", "Text")
        mk("UICorner", {Parent = rejoinBtn, CornerRadius = UDim.new(0, 6)})
        local rejoinStroke = mk("UIStroke", {Parent = rejoinBtn, Thickness = 1, Color = Theme.Themes.Default.Border, Transparency = 0.5})
        Theme:Register(rejoinStroke, "Color", "Border")
        
        local hopBtn = mk("TextButton", {
            Parent = btnRow, Size = UDim2.new(0.5, -4, 1, 0), Text = "Server Hop",
            Font = Enum.Font.GothamMedium, TextSize = 13, AutoButtonColor = false
        })
        Theme:Register(hopBtn, "BackgroundColor3", "Container")
        Theme:Register(hopBtn, "TextColor3", "Text")
        mk("UICorner", {Parent = hopBtn, CornerRadius = UDim.new(0, 6)})
        local hopStroke = mk("UIStroke", {Parent = hopBtn, Thickness = 1, Color = Theme.Themes.Default.Border, Transparency = 0.5})
        Theme:Register(hopStroke, "Color", "Border")
        
        -- hover for those btns
        local function setupBtnHover(btn, stroke)
            track(btn.MouseEnter:Connect(function()
                btn.BackgroundColor3 = Theme.Themes.Default.Hover
                tween(stroke, {Transparency = 0}, 0.2)
            end))
            track(btn.MouseLeave:Connect(function()
                btn.BackgroundColor3 = Theme.Themes.Default.Container
                tween(stroke, {Transparency = 0.5}, 0.2)
            end))
            track(btn.MouseButton1Down:Connect(function()
                btn.BackgroundColor3 = Theme.Themes.Default.Click
            end))
            track(btn.MouseButton1Up:Connect(function()
                btn.BackgroundColor3 = Theme.Themes.Default.Hover
            end))
        end
        setupBtnHover(rejoinBtn, rejoinStroke)
        setupBtnHover(hopBtn, hopStroke)
        
        track(rejoinBtn.MouseButton1Click:Connect(function()
            TeleportService:Teleport(game.PlaceId, LocalPlayer)
        end))
        track(hopBtn.MouseButton1Click:Connect(function()
            local s, result = pcall(function()
                return HttpService:JSONDecode(httpGet(string.format("https://games.roblox.com/v1/games/%d/servers/Public?limit=100&sortOrder=Ascending", game.PlaceId)))
            end)
            if s and result and result.data and #result.data > 0 then
                local servers = result.data
                local filtered = {}
                for _, sv in ipairs(servers) do
                    if sv.id ~= game.JobId then
                        table.insert(filtered, sv.id)
                    end
                end
                if #filtered > 0 then
                    local target = filtered[math.random(1, #filtered)]
                    TeleportService:TeleportToPlaceInstance(game.PlaceId, target, LocalPlayer)
                else
                    notifs:Notify("Server Hop", "No other servers found.", 3)
                end
            else
                notifs:Notify("Server Hop", "Could not fetch servers.", 3)
            end
        end))
        
        -- sort + refresh row
        local sortOrder = "Desc"
        local sortRow = mk("Frame", {
            Parent = browserFrame, Size = UDim2.new(1, 0, 0, 28), BackgroundTransparency = 1
        })

        local sortDropdown = mk("TextButton", {
            Parent = sortRow, Size = UDim2.new(1, -80, 1, 0), Position = UDim2.new(0, 0, 0, 0),
            Text = "  Sort: Players â†“", Font = Enum.Font.GothamMedium, TextSize = 12,
            TextXAlignment = Enum.TextXAlignment.Left, AutoButtonColor = false
        })
        Theme:Register(sortDropdown, "BackgroundColor3", "Container")
        Theme:Register(sortDropdown, "TextColor3", "Text")
        mk("UICorner", {Parent = sortDropdown, CornerRadius = UDim.new(0, 6)})
        local sortStroke = mk("UIStroke", {Parent = sortDropdown, Thickness = 1, Color = Theme.Themes.Default.Border, Transparency = 0.5})
        Theme:Register(sortStroke, "Color", "Border")
        setupBtnHover(sortDropdown, sortStroke)

        local refreshBtn = mk("TextButton", {
            Parent = sortRow, Size = UDim2.new(0, 72, 1, 0), Position = UDim2.new(1, -72, 0, 0),
            Text = "Refresh", Font = Enum.Font.GothamMedium, TextSize = 13,
            AutoButtonColor = false
        })
        Theme:Register(refreshBtn, "BackgroundColor3", "Container")
        Theme:Register(refreshBtn, "TextColor3", "Text")
        mk("UICorner", {Parent = refreshBtn, CornerRadius = UDim.new(0, 6)})
        local refreshStroke = mk("UIStroke", {Parent = refreshBtn, Thickness = 1, Color = Theme.Themes.Default.Border, Transparency = 0.5})
        Theme:Register(refreshStroke, "Color", "Border")
        setupBtnHover(refreshBtn, refreshStroke)

        local serverListFrame = mk("ScrollingFrame", {
            Parent = browserFrame, Size = UDim2.new(1, 0, 0, 200), BackgroundTransparency = 0,
            ScrollBarThickness = 0, CanvasSize = UDim2.new(0, 0, 0, 0), BorderSizePixel = 0
        })
        Theme:Register(serverListFrame, "BackgroundColor3", "Background")
        Theme:Register(serverListFrame, "ScrollBarImageColor3", "Accent")
        mk("UICorner", {Parent = serverListFrame, CornerRadius = UDim.new(0, 6)})
        Theme:Register(mk("UIStroke", {Parent = serverListFrame, Thickness = 1, Color = Theme.Themes.Default.Border, Transparency = 0.5}), "Color", "Border")
        mk("UIPadding", {Parent = serverListFrame, PaddingTop = UDim.new(0, 4), PaddingBottom = UDim.new(0, 4), PaddingLeft = UDim.new(0, 4), PaddingRight = UDim.new(0, 4)})

        local serverListLayout = mk("UIListLayout", {
            Parent = serverListFrame, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 4)
        })

        local function RefreshServers()
            for _, child in ipairs(serverListFrame:GetChildren()) do
                if child:IsA("Frame") or child:IsA("TextLabel") then child:Destroy() end
            end
            local loadingLbl2 = mk("TextLabel", {
                Parent = serverListFrame, Size = UDim2.new(1, -8, 0, 28), BackgroundTransparency = 1,
                Text = "Loading servers...", Font = Enum.Font.GothamMedium, TextSize = 12,
                TextXAlignment = Enum.TextXAlignment.Left
            })
            Theme:Register(loadingLbl2, "TextColor3", "SubText")

            task.spawn(function()
                local servers = {}
                local fetchError = nil
                local apiSort = sortOrder == "Asc" and "Asc" or "Desc"
                local s, result = pcall(function()
                    return HttpService:JSONDecode(httpGet(string.format("https://games.roblox.com/v1/games/%d/servers/Public?limit=100&sortOrder=%s", game.PlaceId, apiSort)))
                end)
                if s and result and result.data then
                    servers = result.data
                else
                    fetchError = result or "Unknown error"
                end

                if loadingLbl2 and loadingLbl2.Parent then
                    loadingLbl2:Destroy()
                end

                local query = searchBox.Text:lower()
                for _, server in ipairs(servers) do
                    local sid = tostring(server.id or "")
                    if query ~= "" and not sid:lower():find(query, 1, true) then
                        continue
                    end
                    local isCurrent = sid == game.JobId
                    local entry = mk("Frame", {
                        Parent = serverListFrame, Size = UDim2.new(1, -4, 0, 32), BackgroundTransparency = 0
                    })
                    Theme:Register(entry, "BackgroundColor3", "Container")
                    mk("UICorner", {Parent = entry, CornerRadius = UDim.new(0, 6)})

                    if isCurrent then
                        Theme:Register(mk("UIStroke", {Parent = entry, Thickness = 1, Color = Theme.Themes.Default.Accent, Transparency = 0, ApplyStrokeMode = Enum.ApplyStrokeMode.Border}), "Color", "Accent")
                    end

                    local idLbl = mk("TextLabel", {
                        Parent = entry, Size = UDim2.new(0.5, -8, 1, 0), Position = UDim2.new(0, 8, 0, 0),
                        BackgroundTransparency = 1, Text = (sid ~= "" and sid or "N/A"),
                        Font = Enum.Font.GothamMedium, TextSize = 11,
                        TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd
                    })
                    Theme:Register(idLbl, "TextColor3", "Text")

                    local pCount = server.playing or 0
                    local pMax = server.maxPlayers or 50
                    local pLbl = mk("TextLabel", {
                        Parent = entry, Size = UDim2.new(0.2, 0, 1, 0), Position = UDim2.new(0.5, 0, 0, 0),
                        BackgroundTransparency = 1, Text = string.format("%d/%d", pCount, pMax),
                        Font = Enum.Font.GothamMedium, TextSize = 11, TextXAlignment = Enum.TextXAlignment.Right
                    })
                    Theme:Register(pLbl, "TextColor3", pCount >= pMax and "Accent" or "SubText")

                    local joinBtn = mk("TextButton", {
                        Parent = entry, Size = UDim2.new(0, 55, 0, 20), Position = UDim2.new(1, -63, 0.5, -10),
                        Text = isCurrent and "Current" or "Join",
                        Font = Enum.Font.GothamMedium, TextSize = 11, AutoButtonColor = false
                    })
                    if isCurrent then
                        Theme:Register(joinBtn, "BackgroundColor3", "Accent")
                        Theme:Register(joinBtn, "TextColor3", "Background")
                    else
                        Theme:Register(joinBtn, "BackgroundColor3", "Container")
                        Theme:Register(joinBtn, "TextColor3", "Text")
                    end
                    mk("UICorner", {Parent = joinBtn, CornerRadius = UDim.new(0, 4)})
                    local joinStroke = mk("UIStroke", {Parent = joinBtn, Thickness = 1, Color = Theme.Themes.Default.Border, Transparency = 0.5})
                    Theme:Register(joinStroke, "Color", "Border")

                    if not isCurrent then
                        track(joinBtn.MouseEnter:Connect(function()
                            tween(joinBtn, {BackgroundColor3 = Theme.Themes.Default.Hover}, 0.2)
                            tween(joinStroke, {Transparency = 0}, 0.2)
                        end))
                        track(joinBtn.MouseLeave:Connect(function()
                            tween(joinBtn, {BackgroundColor3 = Theme.Themes.Default.Container}, 0.2)
                            tween(joinStroke, {Transparency = 0.5}, 0.2)
                        end))
                        track(joinBtn.MouseButton1Click:Connect(function()
                            if sid ~= "" then
                                TeleportService:TeleportToPlaceInstance(game.PlaceId, sid, LocalPlayer)
                            end
                        end))
                    end
                end

                if #servers == 0 then
                    local emptyText = fetchError and ("Failed: " .. tostring(fetchError):sub(1, 80)) or "No servers found."
                    local emptyLbl = mk("TextLabel", {
                        Parent = serverListFrame, Size = UDim2.new(1, -8, 0, 28), BackgroundTransparency = 1,
                        Text = emptyText, Font = Enum.Font.GothamMedium, TextSize = 12,
                        TextWrapped = true, TextXAlignment = Enum.TextXAlignment.Left
                    })
                    Theme:Register(emptyLbl, "TextColor3", "SubText")
                end
                serverListFrame.CanvasSize = UDim2.new(0, 0, 0, serverListLayout.AbsoluteContentSize.Y + 8)
            end)
        end

        track(sortDropdown.MouseButton1Click:Connect(function()
            if sortOrder == "Desc" then
                sortOrder = "Asc"
                sortDropdown.Text = "  Sort: Players â†‘"
            else
                sortOrder = "Desc"
                sortDropdown.Text = "  Sort: Players â†“"
            end
            RefreshServers()
        end))

        track(refreshBtn.MouseButton1Click:Connect(function()
            RefreshServers()
        end))
        
        track(searchBox.FocusLost:Connect(function()
            RefreshServers()
        end))
        
        local function RefreshServersLayout()
            curFrame.Size = UDim2.new(1, -20, 0, curLayout.AbsoluteContentSize.Y + 28)
            browserFrame.Size = UDim2.new(1, -20, 0, browserLayout.AbsoluteContentSize.Y + 28)
            scroll.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 20)
        end
        tabObj.RefreshLayout = RefreshServersLayout

        tabObj.ContentRoot = canvasGroup
        tabObj.ContentLayout = layout
        
        RefreshServers()
        task.delay(0.5, RefreshServersLayout)
    end
    
    -- key gate, only made when options.KeySystem is set. sits over the window
    -- until a key goes through, the script sits behind `while not
    -- getgenv().SCRIPT_KEY do task.wait(0.1) end` til then
    local gateOverlay, gateCard = nil, nil

    local function closeGate()
        if not gateOverlay then return end
        local ov = gateOverlay
        gateOverlay, gateCard = nil, nil
        tween(ov, {BackgroundTransparency = 1}, 0.3)
        task.delay(0.3, function()
            if ov.Parent then ov:Destroy() end
        end)
    end

    local function buildKeyGate(keyOpts)
        local apiList = keyOpts.API or {}
        local saveKey = keyOpts.SaveKey ~= false
        -- the api rows talk to this before its defined below so it has to be local first
        local sayGate = nil

        local overlay = mk("Frame", {
            Parent = gui,
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundColor3 = Color3.new(0, 0, 0),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            ZIndex = 60
        })
        gateOverlay = overlay
        track(overlay)

        local card = mk("CanvasGroup", {
            Parent = overlay,
            Size = UDim2.new(0, 420, 0, 40),
            Position = UDim2.new(0.5, 0, 0.5, 0),
            AnchorPoint = Vector2.new(0.5, 0.5),
            BackgroundColor3 = Theme.Themes.Default.Container,
            BorderSizePixel = 0,
            GroupTransparency = 1,
            ClipsDescendants = true
        })
        gateCard = card
        Theme:Register(card, "BackgroundColor3", "Container")
        mk("UICorner", { Parent = card, CornerRadius = UDim.new(0, 12) })
        local cardStroke = mk("UIStroke", { Parent = card, Thickness = 1, Color = Theme.Themes.Default.Border, Transparency = 0.5 })
        Theme:Register(cardStroke, "Color", "Border")

        local body = mk("Frame", {
            Parent = card,
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1
        })
        local bodyLayout = mk("UIListLayout", {
            Parent = body,
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 12)
        })
        mk("UIPadding", {
            Parent = body,
            PaddingTop = UDim.new(0, 20),
            PaddingBottom = UDim.new(0, 20),
            PaddingLeft = UDim.new(0, 20),
            PaddingRight = UDim.new(0, 20)
        })

        local head = mk("TextLabel", {
            Parent = body,
            Size = UDim2.new(1, 0, 0, 22),
            BackgroundTransparency = 1,
            Text = title,
            Font = Enum.Font.GothamBold,
            TextSize = 18,
            TextXAlignment = Enum.TextXAlignment.Left,
            LayoutOrder = 1
        })
        Theme:Register(head, "TextColor3", "Text")

        local note = mk("TextLabel", {
            Parent = body,
            Size = UDim2.new(1, 0, 0, 18),
            BackgroundTransparency = 1,
            Text = keyOpts.Note or "Enter your key to continue.",
            Font = Enum.Font.GothamMedium,
            TextSize = 13,
            TextXAlignment = Enum.TextXAlignment.Left,
            LayoutOrder = 2
        })
        Theme:Register(note, "TextColor3", "SubText")

        -- api rows, clicking one copies its link
        for i, entry in ipairs(apiList) do
            local svc = Library.Services[entry.Type]
            if svc then
                local row = mk("TextButton", {
                    Parent = body,
                    Size = UDim2.new(1, 0, 0, 46),
                    BackgroundColor3 = Theme.Themes.Default.Section,
                    BorderSizePixel = 0,
                    Text = "",
                    AutoButtonColor = false,
                    LayoutOrder = 2 + i
                })
                Theme:Register(row, "BackgroundColor3", "Section")
                mk("UICorner", { Parent = row, CornerRadius = UDim.new(0, 8) })
                local rowStroke = mk("UIStroke", { Parent = row, Thickness = 1, Color = Theme.Themes.Default.Border, Transparency = 0.5 })
                Theme:Register(rowStroke, "Color", "Border")

                local rowStack = mk("Frame", {
                    Parent = row,
                    Size = UDim2.new(1, -24, 1, 0),
                    Position = UDim2.new(0, 12, 0, 0),
                    BackgroundTransparency = 1
                })
                local rowLayout = mk("UIListLayout", {
                    Parent = rowStack,
                    SortOrder = Enum.SortOrder.LayoutOrder,
                    Padding = UDim.new(0, 2),
                    VerticalAlignment = Enum.VerticalAlignment.Center
                })

                local rowTitle = mk("TextLabel", {
                    Parent = rowStack,
                    Size = UDim2.new(1, 0, 0, 18),
                    BackgroundTransparency = 1,
                    Text = entry.Title or svc.Name or "Get Key",
                    Font = Enum.Font.GothamMedium,
                    TextSize = 13,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    LayoutOrder = 1
                })
                Theme:Register(rowTitle, "TextColor3", "Text")

                local desc = mk("TextLabel", {
                    Parent = rowStack,
                    Size = UDim2.new(1, 0, 0, 16),
                    BackgroundTransparency = 1,
                    Text = entry.Desc or "Click to copy link",
                    Font = Enum.Font.GothamMedium,
                    TextSize = 12,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    TextTruncate = Enum.TextTruncate.AtEnd,
                    LayoutOrder = 2
                })
                Theme:Register(desc, "TextColor3", "SubText")

                local rowCopy = nil
                track(row.MouseEnter:Connect(function()
                    tween(row, {BackgroundColor3 = Theme.Themes.Default.Hover}, 0.2)
                    tween(rowStroke, {Transparency = 0}, 0.2)
                end))
                track(row.MouseLeave:Connect(function()
                    tween(row, {BackgroundColor3 = Theme.Themes.Default.Section}, 0.2)
                    tween(rowStroke, {Transparency = 0.5}, 0.2)
                end))
                track(row.MouseButton1Down:Connect(function()
                    tween(row, {BackgroundColor3 = Theme.Themes.Default.Click}, 0.1)
                end))
                track(row.MouseButton1Up:Connect(function()
                    tween(row, {BackgroundColor3 = Theme.Themes.Default.Hover}, 0.1)
                end))
                track(row.MouseButton1Click:Connect(function()
                    if not rowCopy then
                        local made = pcall(function()
                            rowCopy = svc.New()
                        end)
                        if not made or type(rowCopy) ~= "table" or type(rowCopy.Copy) ~= "function" then
                            rowCopy = nil
                        end
                    end
                    if rowCopy then
                        local ok, link = pcall(function()
                            return rowCopy.Copy()
                        end)
                        if ok and link then
                            sayGate("Link copied to clipboard.", "Accent")
                        else
                            sayGate("Cant reach that right now.", "SubText")
                        end
                    end
                end))
            end
        end

        -- key box
        local box = mk("TextBox", {
            Parent = body,
            Size = UDim2.new(1, 0, 0, 38),
            BackgroundColor3 = Theme.Themes.Default.Section,
            BorderSizePixel = 0,
            Text = "",
            PlaceholderText = "Paste your key...",
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left,
            ClearTextOnFocus = false,
            LayoutOrder = 20
        })
        Theme:Register(box, "BackgroundColor3", "Section")
        Theme:Register(box, "TextColor3", "Text")
        Theme:Register(box, "PlaceholderColor3", "SubText")
        mk("UICorner", { Parent = box, CornerRadius = UDim.new(0, 8) })
        local boxStroke = mk("UIStroke", { Parent = box, Thickness = 1, Color = Theme.Themes.Default.Border, Transparency = 0.5 })
        Theme:Register(boxStroke, "Color", "Border")

        track(box.Focused:Connect(function()
            tween(boxStroke, {Color = Theme.Themes.Default.Accent, Transparency = 0}, 0.15)
        end))
        track(box.FocusLost:Connect(function()
            tween(boxStroke, {Color = Theme.Themes.Default.Border, Transparency = 0.5}, 0.2)
        end))

        -- save key row, saveCheck gets read again down in verifyKey so it has to live out here
        local saveRow = nil
        local saveCheck = nil
        if saveKey then
            saveRow = mk("Frame", {
                Parent = body,
                Size = UDim2.new(1, 0, 0, 18),
                BackgroundTransparency = 1,
                LayoutOrder = 21
            })
            local saveBox = mk("TextButton", {
                Parent = saveRow,
                Size = UDim2.new(0, 16, 0, 16),
                Position = UDim2.new(0, 0, 0.5, -8),
                BackgroundColor3 = Theme.Themes.Default.Container,
                Text = "",
                AutoButtonColor = false
            })
            Theme:Register(saveBox, "BackgroundColor3", "Container")
            mk("UICorner", { Parent = saveBox, CornerRadius = UDim.new(1, 0) })
            saveCheck = mk("TextLabel", {
                Parent = saveBox,
                Size = UDim2.new(1, 0, 1, 0),
                BackgroundTransparency = 1,
                Text = "âœ“",
                Font = Enum.Font.GothamBold,
                TextSize = 11,
                TextColor3 = Theme.Themes.Default.Background,
                TextXAlignment = Enum.TextXAlignment.Center,
                Visible = false
            })
            Theme:Register(saveCheck, "TextColor3", "Background")

            local saveLbl = mk("TextLabel", {
                Parent = saveRow,
                Size = UDim2.new(1, -24, 1, 0),
                Position = UDim2.new(0, 24, 0, 0),
                BackgroundTransparency = 1,
                Text = "Save my key",
                Font = Enum.Font.GothamMedium,
                TextSize = 13,
                TextXAlignment = Enum.TextXAlignment.Left
            })
            Theme:Register(saveLbl, "TextColor3", "SubText")

            track(saveBox.MouseButton1Click:Connect(function()
                local on = not saveCheck.Visible
                saveCheck.Visible = on
                tween(saveBox, {BackgroundColor3 = on and Theme.Themes.Default.Accent or Theme.Themes.Default.Container}, 0.2)
            end))
        end

        local checkBtn = mk("TextButton", {
            Parent = body,
            Size = UDim2.new(1, 0, 0, 36),
            BackgroundColor3 = Theme.Themes.Default.Accent,
            BorderSizePixel = 0,
            Text = "Check Key",
            Font = Enum.Font.GothamBold,
            TextSize = 14,
            TextColor3 = Theme.Themes.Default.Background,
            AutoButtonColor = false,
            LayoutOrder = 22
        })
        Theme:Register(checkBtn, "BackgroundColor3", "Accent")
        Theme:Register(checkBtn, "TextColor3", "Background")
        mk("UICorner", { Parent = checkBtn, CornerRadius = UDim.new(0, 8) })

        local status = mk("TextLabel", {
            Parent = body,
            Size = UDim2.new(1, 0, 0, 18),
            BackgroundTransparency = 1,
            Text = "",
            Font = Enum.Font.GothamMedium,
            TextSize = 12,
            TextWrapped = true,
            TextXAlignment = Enum.TextXAlignment.Left,
            LayoutOrder = 23
        })
        Theme:Register(status, "TextColor3", "SubText")

        sayGate = function(text, tone)
            if not status or not status.Parent then return end
            status.Text = tostring(text or "")
            Theme:Register(status, "TextColor3", tone == "Bad" and "SubText" or (tone or "SubText"))
            status.TextColor3 = tone == "Bad" and Color3.fromRGB(255, 99, 99)
                or (tone == "Accent" and Theme.Themes.Default.Accent or Theme.Themes.Default.SubText)
            status.TextTransparency = 1
            tween(status, {TextTransparency = 0}, 0.2)
        end

        local function sizeCard()
            if card and card.Parent then
                card.Size = UDim2.new(0, 420, 0, bodyLayout.AbsoluteContentSize.Y + 40)
            end
        end
        track(bodyLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(sizeCard))
        sizeCard()

        local checking = false

        local function verifyKey(key)
            if checking then return end
            key = tostring(key or ""):gsub("%s", "")
            if key == "" then
                sayGate("Put a key in first.", "Bad")
                return
            end

            local def = apiList[1] and Library.Services[apiList[1].Type]
            if not def then
                sayGate("No key service registered.", "Bad")
                return
            end

            checking = true
            checkBtn.Text = "Checking..."
            sayGate("Talking to the key server...", "SubText")

            -- verification can block on http so keep it off the ui thread
            task.spawn(function()
                local ok, made = pcall(function()
                    return def.New()
                end)
                if not ok or type(made) ~= "table" or type(made.Verify) ~= "function" then
                    checking = false
                    checkBtn.Text = "Check Key"
                    sayGate("That key service is broken.", "Bad")
                    return
                end

                local passed, msg = false, nil
                local called, res, resMsg = pcall(function()
                    return made.Verify(key)
                end)
                if called then
                    passed, msg = res, resMsg
                else
                    msg = tostring(res)
                end

                checking = false
                if checkBtn.Parent then
                    checkBtn.Text = "Check Key"
                end

                if passed then
                    if saveCheck and saveCheck.Visible then
                        writeKey(key)
                    end
                    sayGate("Key good.", "Accent")
                    task.delay(0.4, function()
                        closeGate()
                    end)
                    notifs:Notify("Access Granted", msg or "Key valid.", 3)
                else
                    sayGate(msg or "Invalid key.", "Bad")
                end
            end)
        end

        track(checkBtn.MouseButton1Click:Connect(function()
            if checking then return end
            verifyKey(box.Text)
        end))
        track(box.FocusLost:Connect(function(enterPressed)
            if enterPressed then verifyKey(box.Text) end
        end))

        -- already saved one, fill it in and go
        local cached = readKey()
        if cached then
            box.Text = cached
            if saveCheck then saveCheck.Visible = true end
            task.delay(0.3, function()
                verifyKey(cached)
            end)
        end

        tween(overlay, {BackgroundTransparency = 0.45}, 0.3)
        tween(card, {GroupTransparency = 0}, 0.35, Enum.EasingStyle.Quint)
    end

    -- make the default tabs
    local homeTab = windowObj:CreateTab("Home", 1, BuildHomeTab)
    local serversTab = windowObj:CreateTab("Servers", 9990, BuildServersTab)

    -- customize tab
    local customizeTab = windowObj:CreateTab("Customize", 9991)
    local displaySec = customizeTab:CreateSection("Display")
    displaySec:CreateSlider("UI Opacity", 20, 100, 80, function(val)
        windowObj.UserOpacity = 1 - (val / 100)
        canvasGroup.GroupTransparency = windowObj.UserOpacity
        local shadow = shadowFrame:FindFirstChild("Shadow")
        if shadow then
            shadow.ImageTransparency = 1 - (0.6 * (val / 100))
        end
    end)
    displaySec:CreateButton("Reset to Default", function()
        -- back to midnight
        Theme:SetTheme("Midnight")

        -- reset toggles/sliders
        Library:ResetAll()

        -- put window back
        if windowObj.Maximized then
            windowObj.Maximized = false
        end
        if windowObj.Minimized then
            windowObj.Minimized = false
        end
        tween(canvasGroup, {Size = windowObj.DefaultSize, Position = windowObj.DefaultPosition}, 0.4, Enum.EasingStyle.Quint)
        if shadowFrame and shadowFrame.Parent then
            tween(shadowFrame, {Size = windowObj.DefaultSize, Position = windowObj.DefaultPosition}, 0.4, Enum.EasingStyle.Quint)
        end

        -- go home
        if windowObj.Tabs and windowObj.Tabs[1] and windowObj.Tabs[1].Select then
            windowObj.Tabs[1].Select()
        end

        -- fab back to the left
        if fab then
            fabStoredPos = UDim2.new(0, 0, 0.5, 0)
            fab.Position = fabStoredPos
        end

        -- unhide if hidden
        if windowObj.Hidden then
            windowObj.Hidden = false
            canvasGroup.GroupTransparency = windowObj.UserOpacity
            canvasGroup.Visible = true
            shadowFrame.Visible = true
            if dragBar then dragBar.Visible = true end
        end

        notifs:Notify("Reset", "UI reset to default.", 3)
    end)
    local themeSec = customizeTab:CreateSection("Theme Presets")
    local presetNames = {"Midnight", "Dark", "Light", "Forest", "Ruby", "Ocean"}
    for _, name in ipairs(presetNames) do
        themeSec:CreateButton(name, function()
            Theme:SetTheme(name)
            notifs:Notify("Theme", "Switched to " .. name .. " theme.", 2)
        end)
    end

    -- settings tab
    local settingsTab = windowObj:CreateTab("Settings", 9992)
    local uiSec = settingsTab:CreateSection("Settings")

    -- anti afk, clicks when idle so u dont get kicked
    local antiAfkConn = nil
    local function setAntiAfk(on)
        if antiAfkConn then
            antiAfkConn:Disconnect()
            antiAfkConn = nil
        end
        if on then
            antiAfkConn = Players.LocalPlayer.Idled:Connect(function()
                pcall(function()
                    VirtualUser:CaptureController()
                    VirtualUser:ClickButton1(Vector2.new(0, 0))
                end)
            end)
            track(antiAfkConn)
        end
    end
    setAntiAfk(true)

    uiSec:CreateToggle("Anti-AFK", true, function(val)
        setAntiAfk(val)
    end)
    uiSec:CreateToggle("Enable Notifications", true, function(val)
        notifs.Enabled = val
    end)
    uiSec:CreateDivider()
    uiSec:CreateLabel("Destroy UI", "Tears everything down, re-execute to get it back.")
    uiSec:CreateButton("Destroy UI", function()
        Library:Confirm("Destroy UI?", "Everything gets torn down. Re-execute the script to get it back.", function()
            Library:Unload()
        end)
    end, "Danger")

    local keybindSec = settingsTab:CreateSection("Keybind")
    keybindSec:CreateKeybind("Toggle UI", windowObj.Keybind, function(keyCode)
        windowObj:SetKeybind(keyCode)
        notifs:Notify("Keybind", "Now toggling with " .. keyCode.Name .. ".", 3)
    end)
    keybindSec:CreateLabel("Locked", "Stops anyone closing or dragging the window")
    keybindSec:CreateToggle("Lock Window", false, function(val)
        if val then
            windowObj:Lock()
        else
            windowObj:Unlock()
        end
    end)

    local cfgSec = settingsTab:CreateSection("Configs")
    cfgSec:CreateLabel("Configs", "Theme, layout and every toggle in here. Files go to RUI/Configs.")
    local cfgName = ""
    cfgSec:CreateInput("Name", "", "MySetup", function(val)
        cfgName = val
    end)
    cfgSec:CreateButton("Save Config", function()
        Library:SaveConfig(cfgName)
    end, "Accent")
    cfgSec:CreateButton("Load Config", function()
        Library:LoadConfig(cfgName)
    end)
    cfgSec:CreateButton("Delete Config", function()
        Library:Confirm("Delete Config?", "\"" .. tostring(cfgName) .. "\" gets removed for good.", function()
            Library:DeleteConfig(cfgName)
        end)
    end, "Danger")

    local savedConfigs = Library:GetConfigs()
    if #savedConfigs > 0 then
        cfgSec:CreateLabel("Quick Load")
        cfgSec:CreateDropdown("Saved", savedConfigs, savedConfigs[1], function(val)
            Library:LoadConfig(val)
        end)
    end
    
    -- for SetScriptInfo
    function windowObj:SetScriptInfo(text)
        if windowObj.infoBox then
            windowObj.infoBox.Text = text
        end
    end

    function windowObj:SetTitle(newTitle)
        if titleLbl then
            titleLbl.Text = newTitle
        end
    end

    function windowObj:Toggle()
        canvasGroup.Visible = not canvasGroup.Visible
        windowObj.Hidden = not canvasGroup.Visible
    end

    function windowObj:SelectTab(name)
        for _, t in ipairs(self.Tabs) do
            if t.Name == name and t.Select then
                t.Select()
                return true
            end
        end
        return false
    end

    -- configs grab the bits that arent flags. position is saved in pixels then
    -- turned back into an offset because the canvas is center anchored
    local function viewport()
        return (Workspace.CurrentCamera and Workspace.CurrentCamera.ViewportSize) or Vector2.new(1920, 1080)
    end

    function windowObj:CollectConfig()
        return {
            Tab = windowObj.CurrentTab and windowObj.CurrentTab.Name or nil,
            Size = {math.floor(canvasGroup.Size.X.Offset), math.floor(canvasGroup.Size.Y.Offset)},
            Pos = {math.floor(canvasGroup.AbsolutePosition.X), math.floor(canvasGroup.AbsolutePosition.Y)}
        }
    end

    function windowObj:ApplyConfig(data)
        local vp = viewport()

        if data.Size and type(data.Size) == "table" then
            local w = tonumber(data.Size[1]) or size.X.Offset
            local h = tonumber(data.Size[2]) or size.Y.Offset
            w = math.clamp(w, 400, math.max(400, vp.X - 20))
            h = math.clamp(h, 260, math.max(260, vp.Y - 20))
            windowObj.Maximized = false
            windowObj.Minimized = false
            tween(canvasGroup, {Size = UDim2.new(0, w, 0, h)}, 0.3)
            if shadowFrame and shadowFrame.Parent then
                shadowFrame.Size = UDim2.new(0, w, 0, h)
            end
        end

        if data.Pos and type(data.Pos) == "table" then
            local w = canvasGroup.Size.X.Offset
            local h = canvasGroup.Size.Y.Offset
            local ax = tonumber(data.Pos[1]) or (vp.X - w) / 2
            local ay = tonumber(data.Pos[2]) or (vp.Y - h) / 2
            ax = math.clamp(ax, 0, math.max(0, vp.X - w))
            ay = math.clamp(ay, 0, math.max(0, vp.Y - h))
            local ox = ax - vp.X * canvasGroup.Position.X.Scale + w / 2
            local oy = ay - vp.Y * canvasGroup.Position.Y.Scale + h / 2
            canvasGroup.Position = UDim2.new(canvasGroup.Position.X.Scale, math.floor(ox), canvasGroup.Position.Y.Scale, math.floor(oy))
        end

        if data.Tab then
            task.defer(function()
                windowObj:SelectTab(data.Tab)
            end)
        end
    end

    -- open home first
    homeTab.Select()

    table.insert(self.Windows, windowObj)

    if options.Config then
        -- give the tabs a beat to build first so flags land on real elements
        task.spawn(function()
            task.wait(0.6)
            if not self.Unloaded then
                self:LoadConfig(options.Config)
            end
        end)
    end

    -- gate goes up last so it covers everything, stays til the key checks out
    if options.KeySystem then
        if self.Gate then
            -- someone else already owns the gate, wait on em then pop ours
            task.spawn(function()
                while not self.Gate() do task.wait(0.1) end
                if not self.Unloaded then
                    buildKeyGate(options.KeySystem)
                end
            end)
        else
            buildKeyGate(options.KeySystem)
        end
    end

    return windowObj
end

-- globals so u can just do RUI:CreateWindow after loading it, and so
-- keysystem.lua has somewhere to register its service
-- NOTE: has to sit BEFORE the return, a return has to be the last line of a
-- block or the whole file is a syntax error
_G.RUI = Library
local genv = getgenv and getgenv() or nil
if genv then
    genv.RUI = Library
end

return Library
