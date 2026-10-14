-- ren ui by ren (@wtf_renn)
-- my ui lib, dm if it breaks
-- v2.1 10/14, added servers tab + more themes

local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local TextService = game:GetService("TextService")
local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local GuiService = game:GetService("GuiService")
local Workspace = game:GetService("Workspace")
local VirtualUser = game:GetService("VirtualUser")

-- kill last ui if we re-execute
if _G.__PremiumUI_Cleanup then
    pcall(_G.__PremiumUI_Cleanup)
end

local LocalPlayer = Players.LocalPlayer

-- phone check (window recomputes its own sizes later too)
local _isConsole = GuiService:IsTenFootInterface()
local _isTouch = UserInputService.TouchEnabled
local isMobile = _isTouch and not _isConsole

local ProtectGui = protectgui or (syn and syn.protect_gui) or function() end
local GetHui = gethui or function() return CoreGui end

-- janitor, tracks connections n stuff so unload actually cleans up
local Janitor = {}
Janitor.__index = Janitor

function Janitor.new()
    return setmetatable({ _tasks = {} }, Janitor)
end

function Janitor:Add(task, methodName)
    table.insert(self._tasks, { task = task, method = methodName })
    return task
end

function Janitor:Cleanup()
    for _, item in ipairs(self._tasks) do
        local t = item.task
        local m = item.method
        if typeof(t) == "RBXScriptConnection" then
            t:Disconnect()
        elseif typeof(t) == "thread" then
            task.cancel(t)
        elseif typeof(t) == "Instance" then
            t:Destroy()
        elseif type(t) == "function" then
            t()
        elseif type(t) == "table" and m and type(t[m]) == "function" then
            t[m](t)
        elseif type(t) == "table" and type(t.Destroy) == "function" then
            t:Destroy()
        end
    end
    table.clear(self._tasks)
end

-- helpers (make instances + tween + http)
local Utility = {}
function Utility:Create(className, properties)
    local instance = Instance.new(className)
    for k, v in pairs(properties or {}) do
        instance[k] = v
    end
    if instance:IsA("TextLabel") or instance:IsA("TextButton") then
        instance.TextStrokeTransparency = 1
    end
    return instance
end

function Utility:AddShadow(parent, transparency, radius)
    transparency = transparency or 0.5
    radius = radius or 15
    local shadow = self:Create("ImageLabel", {
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
    return shadow
end

local Animator = {}
function Animator:Tween(instance, properties, duration, style, direction)
    duration = duration or 0.2
    style = style or Enum.EasingStyle.Quad
    direction = direction or Enum.EasingDirection.Out
    local tween = TweenService:Create(instance, TweenInfo.new(duration, style, direction), properties)
    tween:Play()
    return tween
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
local ThemeManager = {
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
        Sunset = {
            Background = Color3.fromRGB(24, 16, 12),
            Container = Color3.fromRGB(36, 24, 18),
            Section = Color3.fromRGB(30, 20, 14),
            Border = Color3.fromRGB(62, 42, 30),
            Accent = Color3.fromRGB(255, 165, 90),
            Text = Color3.fromRGB(255, 245, 235),
            SubText = Color3.fromRGB(220, 185, 160),
            Hover = Color3.fromRGB(48, 32, 22),
            Click = Color3.fromRGB(26, 18, 12),
            Notification = Color3.fromRGB(40, 26, 18),
            Shadow = Color3.fromRGB(0, 0, 0)
        },
        PurpleHaze = {
            Background = Color3.fromRGB(18, 12, 24),
            Container = Color3.fromRGB(28, 18, 36),
            Section = Color3.fromRGB(22, 14, 30),
            Border = Color3.fromRGB(50, 35, 62),
            Accent = Color3.fromRGB(190, 110, 235),
            Text = Color3.fromRGB(250, 240, 255),
            SubText = Color3.fromRGB(210, 190, 225),
            Hover = Color3.fromRGB(38, 26, 48),
            Click = Color3.fromRGB(20, 14, 26),
            Notification = Color3.fromRGB(32, 22, 40),
            Shadow = Color3.fromRGB(0, 0, 0)
        },
        Mint = {
            Background = Color3.fromRGB(14, 24, 20),
            Container = Color3.fromRGB(22, 36, 30),
            Section = Color3.fromRGB(18, 28, 24),
            Border = Color3.fromRGB(40, 60, 50),
            Accent = Color3.fromRGB(130, 235, 185),
            Text = Color3.fromRGB(240, 255, 248),
            SubText = Color3.fromRGB(190, 225, 205),
            Hover = Color3.fromRGB(30, 46, 38),
            Click = Color3.fromRGB(16, 26, 22),
            Notification = Color3.fromRGB(24, 38, 32),
            Shadow = Color3.fromRGB(0, 0, 0)
        },
        Crimson = {
            Background = Color3.fromRGB(22, 10, 14),
            Container = Color3.fromRGB(34, 16, 22),
            Section = Color3.fromRGB(28, 12, 18),
            Border = Color3.fromRGB(58, 30, 38),
            Accent = Color3.fromRGB(220, 60, 90),
            Text = Color3.fromRGB(255, 240, 245),
            SubText = Color3.fromRGB(215, 180, 190),
            Hover = Color3.fromRGB(46, 22, 30),
            Click = Color3.fromRGB(24, 10, 16),
            Notification = Color3.fromRGB(38, 18, 24),
            Shadow = Color3.fromRGB(0, 0, 0)
        },
        Slate = {
            Background = Color3.fromRGB(20, 22, 26),
            Container = Color3.fromRGB(30, 32, 38),
            Section = Color3.fromRGB(24, 26, 32),
            Border = Color3.fromRGB(50, 52, 60),
            Accent = Color3.fromRGB(170, 180, 200),
            Text = Color3.fromRGB(240, 242, 245),
            SubText = Color3.fromRGB(190, 195, 205),
            Hover = Color3.fromRGB(38, 40, 48),
            Click = Color3.fromRGB(22, 24, 28),
            Notification = Color3.fromRGB(32, 34, 40),
            Shadow = Color3.fromRGB(0, 0, 0)
        },
        Neon = {
            Background = Color3.fromRGB(18, 8, 22),
            Container = Color3.fromRGB(28, 14, 36),
            Section = Color3.fromRGB(22, 10, 30),
            Border = Color3.fromRGB(55, 30, 65),
            Accent = Color3.fromRGB(255, 90, 210),
            Text = Color3.fromRGB(255, 240, 250),
            SubText = Color3.fromRGB(225, 190, 220),
            Hover = Color3.fromRGB(42, 22, 52),
            Click = Color3.fromRGB(20, 10, 26),
            Notification = Color3.fromRGB(34, 18, 44),
            Shadow = Color3.fromRGB(0, 0, 0)
        },
        CottonCandy = {
            Background = Color3.fromRGB(248, 240, 248),
            Container = Color3.fromRGB(238, 228, 242),
            Section = Color3.fromRGB(242, 232, 245),
            Border = Color3.fromRGB(220, 205, 225),
            Accent = Color3.fromRGB(210, 70, 130),
            Text = Color3.fromRGB(50, 35, 60),
            SubText = Color3.fromRGB(140, 110, 150),
            Hover = Color3.fromRGB(228, 218, 232),
            Click = Color3.fromRGB(218, 208, 222),
            Notification = Color3.fromRGB(232, 222, 236),
            Shadow = Color3.fromRGB(190, 170, 200)
        },
        Sunrise = {
            Background = Color3.fromRGB(26, 22, 12),
            Container = Color3.fromRGB(38, 32, 18),
            Section = Color3.fromRGB(32, 26, 14),
            Border = Color3.fromRGB(62, 52, 30),
            Accent = Color3.fromRGB(255, 210, 90),
            Text = Color3.fromRGB(255, 250, 235),
            SubText = Color3.fromRGB(220, 205, 170),
            Hover = Color3.fromRGB(48, 42, 24),
            Click = Color3.fromRGB(28, 24, 14),
            Notification = Color3.fromRGB(40, 34, 20),
            Shadow = Color3.fromRGB(0, 0, 0)
        },
        Noir = {
            Background = Color3.fromRGB(5, 5, 8),
            Container = Color3.fromRGB(12, 12, 16),
            Section = Color3.fromRGB(8, 8, 12),
            Border = Color3.fromRGB(28, 28, 34),
            Accent = Color3.fromRGB(255, 255, 255),
            Text = Color3.fromRGB(245, 245, 250),
            SubText = Color3.fromRGB(155, 155, 165),
            Hover = Color3.fromRGB(22, 22, 28),
            Click = Color3.fromRGB(6, 6, 10),
            Notification = Color3.fromRGB(15, 15, 20),
            Shadow = Color3.fromRGB(0, 0, 0)
        },
        Cyber = {
            Background = Color3.fromRGB(5, 10, 8),
            Container = Color3.fromRGB(10, 20, 14),
            Section = Color3.fromRGB(8, 15, 11),
            Border = Color3.fromRGB(20, 45, 30),
            Accent = Color3.fromRGB(0, 255, 140),
            Text = Color3.fromRGB(220, 255, 230),
            SubText = Color3.fromRGB(120, 200, 150),
            Hover = Color3.fromRGB(15, 30, 22),
            Click = Color3.fromRGB(6, 12, 9),
            Notification = Color3.fromRGB(12, 24, 18),
            Shadow = Color3.fromRGB(0, 0, 0)
        },
        Espresso = {
            Background = Color3.fromRGB(18, 12, 8),
            Container = Color3.fromRGB(28, 20, 14),
            Section = Color3.fromRGB(22, 15, 10),
            Border = Color3.fromRGB(50, 35, 22),
            Accent = Color3.fromRGB(245, 180, 100),
            Text = Color3.fromRGB(255, 240, 220),
            SubText = Color3.fromRGB(200, 165, 130),
            Hover = Color3.fromRGB(38, 28, 18),
            Click = Color3.fromRGB(20, 14, 9),
            Notification = Color3.fromRGB(30, 22, 14),
            Shadow = Color3.fromRGB(0, 0, 0)
        },
        Vapor = {
            Background = Color3.fromRGB(22, 18, 32),
            Container = Color3.fromRGB(34, 26, 50),
            Section = Color3.fromRGB(28, 22, 42),
            Border = Color3.fromRGB(60, 45, 80),
            Accent = Color3.fromRGB(100, 220, 255),
            Text = Color3.fromRGB(240, 230, 255),
            SubText = Color3.fromRGB(180, 170, 210),
            Hover = Color3.fromRGB(44, 34, 64),
            Click = Color3.fromRGB(24, 20, 36),
            Notification = Color3.fromRGB(36, 28, 54),
            Shadow = Color3.fromRGB(0, 0, 0)
        }
    },
    CurrentTheme = "Midnight",
    _objects = {}
}
ThemeManager.Themes.Default = ThemeManager.Themes[ThemeManager.CurrentTheme]

function ThemeManager:Register(instance, property, themeKey)
    local count = #self._objects
    for i = count, 1, -1 do
        local obj = self._objects[i]
        if not obj.Instance or not obj.Instance.Parent then
            table.remove(self._objects, i)
        elseif obj.Instance == instance and obj.Property == property then
            obj.Key = themeKey
            instance[property] = self.Themes[self.CurrentTheme][themeKey]
            return
        end
    end
    table.insert(self._objects, { Instance = instance, Property = property, Key = themeKey })
    if instance and instance.Parent then
        instance[property] = self.Themes[self.CurrentTheme][themeKey]
    end
end

function ThemeManager:UpdateTheme()
    local theme = self.Themes[self.CurrentTheme]
    local count = #self._objects
    local i = 1
    while i <= count do
        local obj = self._objects[i]
        if obj.Instance and obj.Instance.Parent then
            obj.Instance[obj.Property] = theme[obj.Key]
            i = i + 1
        else
            table.remove(self._objects, i)
        end
    end
end

function ThemeManager:SetTheme(name)
    if not self.Themes[name] or self.CurrentTheme == name then return end
    self.CurrentTheme = name
    self.Themes.Default = self.Themes[name]
    self:UpdateTheme()
    for _, tglUpdate in ipairs(Library.Toggles or {}) do
        tglUpdate(false)
    end
end

-- dragging
local InputManager = {}
function InputManager:MakeDraggable(topbar, window, janitor)
    local dragging, dragInput, dragStart, startPos
    
    janitor:Add(topbar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = window.Position
        end
    end))
    
    janitor:Add(UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end))
    
    janitor:Add(topbar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end))
    
    janitor:Add(UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            Animator:Tween(window, {
                Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            }, 0.08, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
        end
    end))
end

-- notifs
local NotificationManager = {
    Enabled = true,
    Gui = nil,
    Container = nil,
    Janitor = Janitor.new(),
    Active = {},
    Queue = {},
    _busy = false
}

function NotificationManager:Init(parent)
    self.Gui = Utility:Create("ScreenGui", {
        Name = "renui_notifs",
        Parent = parent,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    })
    ProtectGui(self.Gui)
    
    self.Container = Utility:Create("Frame", {
        Name = "Container",
        Parent = self.Gui,
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -20, 1, -20),
        Size = UDim2.new(0, 300, 1, -40),
        AnchorPoint = Vector2.new(1, 1)
    })
    
    Utility:Create("UIListLayout", {
        Parent = self.Container,
        SortOrder = Enum.SortOrder.LayoutOrder,
        VerticalAlignment = Enum.VerticalAlignment.Bottom,
        Padding = UDim.new(0, 10)
    })
end

function NotificationManager:_dismiss(notifData)
    local notif = notifData.Frame
    if not notif or not notif.Parent then
        for i, d in ipairs(self.Active) do
            if d == notifData then table.remove(self.Active, i) break end
        end
        return
    end
    
    if notifData._dismissing then return end
    notifData._dismissing = true
    
    for i, d in ipairs(self.Active) do
        if d == notifData then table.remove(self.Active, i) break end
    end
    
    Animator:Tween(notifData.TitleLbl, {TextTransparency = 1}, 0.2)
    Animator:Tween(notifData.DescLbl, {TextTransparency = 1}, 0.2)
    Animator:Tween(notifData.BarBg, {BackgroundTransparency = 1}, 0.2)
    Animator:Tween(notifData.Bar, {BackgroundTransparency = 1}, 0.2)
    Animator:Tween(notifData.AccentBar, {BackgroundTransparency = 1}, 0.2)
    Animator:Tween(notifData.CloseBtn, {TextTransparency = 1, BackgroundTransparency = 1}, 0.2)
    Animator:Tween(notif, {BackgroundTransparency = 1}, 0.2)
    local stroke = notif:FindFirstChildOfClass("UIStroke")
    if stroke then Animator:Tween(stroke, {Transparency = 1}, 0.2) end
    
    task.wait(0.2)
    
    if notif and notif.Parent then
        Animator:Tween(notif, {Position = UDim2.new(1, 50, notif.Position.Y.Scale, notif.Position.Y.Offset)}, 0.2)
        task.wait(0.2)
        if notif and notif.Parent then
            notif:Destroy()
        end
    end
end

function NotificationManager:Notify(title, desc, duration)
    if not self.Enabled then return end
    duration = duration or 5
    
    if self._busy then
        self.Queue = {title, desc, duration}
        return
    end
    
    self._busy = true
    
    if #self.Active >= 3 then
        local oldest = self.Active[1]
        task.spawn(function()
            self:_dismiss(oldest)
            task.wait(0.2)
            self:_buildAndShow(title, desc, duration)
            self._busy = false
            if #self.Queue > 0 then
                local q = self.Queue
                self.Queue = {}
                self:Notify(q[1], q[2], q[3])
            end
        end)
    else
        task.spawn(function()
            self:_buildAndShow(title, desc, duration)
            self._busy = false
            if #self.Queue > 0 then
                local q = self.Queue
                self.Queue = {}
                self:Notify(q[1], q[2], q[3])
            end
        end)
    end
end

function NotificationManager:_buildAndShow(title, desc, duration)
    local notif = Utility:Create("Frame", {
        Parent = self.Container,
        Size = UDim2.new(1, 0, 0, 0),
        BackgroundTransparency = 1,
        ClipsDescendants = true,
        Position = UDim2.new(1, 50, 0, 0)
    })
    ThemeManager:Register(notif, "BackgroundColor3", "Notification")
    Utility:Create("UICorner", { Parent = notif, CornerRadius = UDim.new(0, 8) })
    local stroke = Utility:Create("UIStroke", { Parent = notif, Thickness = 1, Color = ThemeManager.Themes.Default.Border, Transparency = 0.5 })
    ThemeManager:Register(stroke, "Color", "Border")
    
    Utility:AddShadow(notif, 0.4, 15)
    
    local accentBar = Utility:Create("Frame", {
        Parent = notif,
        Position = UDim2.new(0, 0, 0, 0),
        Size = UDim2.new(0, 4, 1, 0),
        BackgroundTransparency = 1,
        BorderSizePixel = 0
    })
    ThemeManager:Register(accentBar, "BackgroundColor3", "Accent")
    Utility:Create("UICorner", {Parent = accentBar, CornerRadius = UDim.new(0, 2)})
    
    local titleLbl = Utility:Create("TextLabel", {
        Parent = notif,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 16, 0, 10),
        Size = UDim2.new(1, -50, 0, 18),
        Font = Enum.Font.GothamBold,
        Text = title,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTransparency = 1
    })
    ThemeManager:Register(titleLbl, "TextColor3", "Text")
    
    local descLbl = Utility:Create("TextLabel", {
        Parent = notif,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 16, 0, 30),
        Size = UDim2.new(1, -32, 0, 14),
        Font = Enum.Font.GothamMedium,
        Text = desc,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextWrapped = true,
        TextTransparency = 1
    })
    ThemeManager:Register(descLbl, "TextColor3", "SubText")
    
    local closeBtn = Utility:Create("TextButton", {
        Parent = notif,
        Position = UDim2.new(1, -26, 0, 8),
        Size = UDim2.new(0, 20, 0, 20),
        BackgroundTransparency = 1,
        Text = "×",
        Font = Enum.Font.GothamBold,
        TextSize = 18,
        TextTransparency = 1,
        AutoButtonColor = false
    })
    ThemeManager:Register(closeBtn, "TextColor3", "SubText")
    
    local bounds = TextService:GetTextSize(desc, 12, Enum.Font.Gotham, Vector2.new(268, math.huge))
    local descHeight = math.max(14, bounds.Y)
    local totalHeight = 30 + descHeight + 14
    
    local barBg = Utility:Create("Frame", {
        Parent = notif,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 10, 1, -8),
        Size = UDim2.new(1, -20, 0, 3),
        BackgroundTransparency = 1
    })
    ThemeManager:Register(barBg, "BackgroundColor3", "Border")
    Utility:Create("UICorner", {Parent = barBg, CornerRadius = UDim.new(1, 0)})
    
    local bar = Utility:Create("Frame", {
        Parent = barBg,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1
    })
    ThemeManager:Register(bar, "BackgroundColor3", "Accent")
    Utility:Create("UICorner", {Parent = bar, CornerRadius = UDim.new(1, 0)})
    
    local notifData = {
        Frame = notif,
        TitleLbl = titleLbl,
        DescLbl = descLbl,
        BarBg = barBg,
        Bar = bar,
        AccentBar = accentBar,
        CloseBtn = closeBtn,
        _dismissing = false
    }
    table.insert(self.Active, notifData)
    
    self.Janitor:Add(closeBtn.MouseEnter:Connect(function()
        if notifData._dismissing then return end
        closeBtn.TextColor3 = ThemeManager.Themes.Default.Text
    end))
    self.Janitor:Add(closeBtn.MouseLeave:Connect(function()
        if notifData._dismissing then return end
        closeBtn.TextColor3 = ThemeManager.Themes.Default.SubText
    end))
    self.Janitor:Add(closeBtn.MouseButton1Down:Connect(function()
        if notifData._dismissing then return end
        closeBtn.TextColor3 = ThemeManager.Themes.Default.Click
    end))
    self.Janitor:Add(closeBtn.MouseButton1Up:Connect(function()
        if notifData._dismissing then return end
        closeBtn.TextColor3 = ThemeManager.Themes.Default.Text
    end))
    self.Janitor:Add(closeBtn.MouseButton1Click:Connect(function()
        if notifData._dismissing then return end
        self:_dismiss(notifData)
    end))
    
    Animator:Tween(notif, {Size = UDim2.new(1, 0, 0, totalHeight), Position = UDim2.new(0, 0, 0, 0), BackgroundTransparency = 0}, 0.35, Enum.EasingStyle.Back)
    Animator:Tween(titleLbl, {TextTransparency = 0}, 0.3)
    Animator:Tween(descLbl, {TextTransparency = 0}, 0.3)
    Animator:Tween(barBg, {BackgroundTransparency = 0.5}, 0.3)
    Animator:Tween(bar, {BackgroundTransparency = 0}, 0.3)
    Animator:Tween(accentBar, {BackgroundTransparency = 0}, 0.3)
    Animator:Tween(closeBtn, {TextTransparency = 0}, 0.3)
    Animator:Tween(stroke, {Transparency = 0.5}, 0.3)
    
    task.spawn(function()
        local t = Animator:Tween(bar, {Size = UDim2.new(0, 0, 1, 0)}, duration, Enum.EasingStyle.Linear)
        t.Completed:Wait()
        
        if notifData._dismissing then return end
        self:_dismiss(notifData)
    end)
end

-- saved flags for reset button n stuff
local ConfigManager = {
    Flags = {},
    _nextAutoFlagId = 0
}

function ConfigManager:NextAutoFlag()
    self._nextAutoFlagId = self._nextAutoFlagId + 1
    return "__AutoFlag_" .. self._nextAutoFlagId
end

-- main lib
local Library = {
    Windows = {},
    Unloaded = false,
    ToggleKeybind = Enum.KeyCode.RightShift,
    Janitor = Janitor.new(),
    Toggles = {}
}

function Library:SafeCallback(callback, ...)
    if not callback then return end
    local args = {...}
    task.spawn(function()
        pcall(function()
            callback(unpack(args))
        end)
    end)
end

function Library:Notify(title, desc, duration)
    return NotificationManager:Notify(title, desc, duration)
end

function Library:Unload()
    if self.Unloaded then return end
    self.Unloaded = true
    self.Janitor:Cleanup()
    NotificationManager.Janitor:Cleanup()
    if NotificationManager.Gui then
        NotificationManager.Gui:Destroy()
    end
    table.clear(ThemeManager._objects)
    table.clear(ConfigManager.Flags)
    table.clear(Library.Windows)
end

function Library:ResetAll()
    for _, flag in pairs(ConfigManager.Flags) do
        if flag and flag.Default ~= nil and type(flag.Set) == "function" then
            flag:Set(flag.Default)
        end
    end
end

-- so re-executing doesnt stack guis
_G.__PremiumUI_Cleanup = function() -- keep old key so old versions still cleanup
    if Library and Library.Unload then
        Library:Unload()
    end
end

function Library:CreateWindow(options)
    local title = options.Title or "ren ui"

    -- viewport might not be ready at the top of the file so check again here
    local _curViewport = (Workspace.CurrentCamera and Workspace.CurrentCamera.ViewportSize) or Vector2.new(1920, 1080)
    local _curIsMobile = _isTouch and not _isConsole
    local _curIsPhone = _curIsMobile and (math.min(_curViewport.X, _curViewport.Y) < 700)
    local _curIsTablet = _curIsMobile and not _curIsPhone

    local size = options.Size or (_curIsPhone and UDim2.new(0, 400, 0, 300))
                                  or (_curIsTablet and UDim2.new(0, 550, 0, 350)
                                  or UDim2.new(0, 600, 0, 400))

    -- fab gets made later but the close btn uses it so declare up here
    local fab = nil
    local fabStoredPos = UDim2.new(0, 0, 0.5, 0) -- left middle

    local gui = Utility:Create("ScreenGui", {
        Name = "renui",
        Parent = GetHui(),
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    })
    ProtectGui(gui)
    self.Janitor:Add(gui)

    NotificationManager:Init(GetHui())

    local canvasGroup = Utility:Create("CanvasGroup", {
        Parent = gui,
        Size = UDim2.new(0, 0, 0, 40), -- Intro start size
        Position = UDim2.new(0.5, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        ClipsDescendants = true,
        GroupTransparency = 1
    })
    ThemeManager:Register(canvasGroup, "BackgroundColor3", "Background")
    Utility:Create("UICorner", { Parent = canvasGroup, CornerRadius = UDim.new(0, 12) })
    local stroke = Utility:Create("UIStroke", { Parent = canvasGroup, Thickness = 1, Color = ThemeManager.Themes.Default.Border, Transparency = 0.5 })
    ThemeManager:Register(stroke, "Color", "Border")

    -- canvas clips stuff so shadow has to live on its own frame next to it
    local shadowFrame = Utility:Create("Frame", {
        Parent = gui,
        Size = size,
        Position = UDim2.new(0.5, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundTransparency = 1,
        Visible = false
    })
    Utility:AddShadow(shadowFrame, 0.4, 25)

    -- little pop-in
    Animator:Tween(canvasGroup, {GroupTransparency = 0.2, Size = size}, 0.6, Enum.EasingStyle.Quint)
    task.delay(0.6, function()
        if shadowFrame and shadowFrame.Parent then
            shadowFrame.Visible = true
        end
    end)

    -- keep shadow glued to the window
    self.Janitor:Add(canvasGroup:GetPropertyChangedSignal("Position"):Connect(function()
        if shadowFrame and shadowFrame.Parent then
            shadowFrame.Position = canvasGroup.Position
        end
    end))
    self.Janitor:Add(canvasGroup:GetPropertyChangedSignal("Size"):Connect(function()
        if shadowFrame and shadowFrame.Parent then
            shadowFrame.Size = canvasGroup.Size
        end
    end))
    
    if isMobile then
        self.Janitor:Add(UserInputService:GetPropertyChangedSignal("OnScreenKeyboardVisible"):Connect(function()
            if UserInputService.OnScreenKeyboardVisible then
                local kbSize = UserInputService.OnScreenKeyboardSize
                local yOffset = kbSize.Y > 0 and -(kbSize.Y / 2.5) or -100
                Animator:Tween(canvasGroup, {Position = UDim2.new(0.5, 0, 0.5, yOffset)}, 0.3, Enum.EasingStyle.Quint)
            else
                Animator:Tween(canvasGroup, {Position = UDim2.new(0.5, 0, 0.5, 0)}, 0.3, Enum.EasingStyle.Quint)
            end
        end))
    end
    
    local dragBarGui = Utility:Create("ScreenGui", {
        Name = "DragBarGui",
        Parent = GetHui(),
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        IgnoreGuiInset = true,
        DisplayOrder = 999
    })
    self.Janitor:Add(dragBarGui)

    local dragBar = Utility:Create("TextButton", {
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

    local dragBarVisual = Utility:Create("Frame", {
        Name = "Visual",
        Parent = dragBar,
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 0, 0.5, -10),
        Size = UDim2.new(0, 100, 0, 4),
        BackgroundColor3 = ThemeManager.Themes.Default.Accent,
        BackgroundTransparency = 0.35,
        BorderSizePixel = 0
    })
    Utility:Create("UICorner", {Parent = dragBarVisual, CornerRadius = UDim.new(1, 0)})
    ThemeManager:Register(dragBarVisual, "BackgroundColor3", "Accent")

    local smoothX = dragBar.Position.X.Offset
    local smoothY = dragBar.Position.Y.Offset

    local renderConn = RunService.RenderStepped:Connect(function()
        if not dragBar or not dragBar.Parent then
            if renderConn then renderConn:Disconnect() end
            return
        end
        if dragBar.Visible then
            local canvasAbs = canvasGroup.AbsolutePosition
            local canvasSize = canvasGroup.AbsoluteSize
            local targetX = canvasAbs.X + canvasSize.X/2
            local targetY = canvasAbs.Y + canvasSize.Y + 65

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
    self.Janitor:Add(renderConn)

    local isDraggingBar = false

    self.Janitor:Add(dragBar.MouseEnter:Connect(function()
        if isDraggingBar then return end
        Animator:Tween(dragBarVisual, {Size = UDim2.new(0, 120, 0, 4), BackgroundTransparency = 0.15}, 0.2, Enum.EasingStyle.Quint)
    end))

    self.Janitor:Add(dragBar.MouseLeave:Connect(function()
        if isDraggingBar then return end
        Animator:Tween(dragBarVisual, {Size = UDim2.new(0, 100, 0, 4), BackgroundTransparency = 0.35}, 0.2, Enum.EasingStyle.Quint)
    end))

    self.Janitor:Add(dragBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            isDraggingBar = true
            Animator:Tween(dragBarVisual, {Size = UDim2.new(0, 130, 0, 5), BackgroundTransparency = 0}, 0.15, Enum.EasingStyle.Back)
        end
    end))

    self.Janitor:Add(dragBar.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            isDraggingBar = false
            Animator:Tween(dragBarVisual, {Size = UDim2.new(0, 100, 0, 4), BackgroundTransparency = 0.35}, 0.2, Enum.EasingStyle.Quint)
        end
    end))

    InputManager:MakeDraggable(dragBar, canvasGroup, self.Janitor)
    
    local topbar = Utility:Create("TextButton", {
        Parent = canvasGroup,
        Size = UDim2.new(1, 0, 0, 40),
        BackgroundTransparency = 1,
        Text = "",
        AutoButtonColor = false
    })
    InputManager:MakeDraggable(topbar, canvasGroup, self.Janitor)
    
    local trafficContainer = Utility:Create("Frame", {
        Parent = topbar,
        Size = UDim2.new(0, 54, 1, 0),
        Position = UDim2.new(0, 12, 0, 0),
        BackgroundTransparency = 1
    })

    local HITBOX = 18
    local VISUAL = 12
    local VISUAL_GAP = 8
    local HALF = HITBOX / 2

    local function makeTrafficLight(parent, color, visualX)
        local hitbox = Utility:Create("TextButton", {
            Parent = parent,
            Size = UDim2.new(0, HITBOX, 0, HITBOX),
            Position = UDim2.new(0, visualX - HALF + VISUAL/2, 0.5, -HALF),
            BackgroundTransparency = 1,
            Text = "",
            AutoButtonColor = false
        })
        local visual = Utility:Create("Frame", {
            Parent = hitbox,
            Size = UDim2.new(0, VISUAL, 0, VISUAL),
            Position = UDim2.new(0.5, -VISUAL/2, 0.5, -VISUAL/2),
            BackgroundColor3 = color
        })
        Utility:Create("UICorner", {Parent = visual, CornerRadius = UDim.new(1, 0)})
        return hitbox, visual
    end

    local closeBtn, closeVisual = makeTrafficLight(trafficContainer, Color3.fromRGB(255, 95, 86), 0)
    local minBtn, minVisual = makeTrafficLight(trafficContainer, Color3.fromRGB(255, 189, 46), VISUAL + VISUAL_GAP)
    local maxBtn, maxVisual = makeTrafficLight(trafficContainer, Color3.fromRGB(39, 201, 63), 2 * (VISUAL + VISUAL_GAP))

    local titleLbl = Utility:Create("TextLabel", {
        Parent = topbar,
        Size = UDim2.new(1, -84, 1, 0),
        Position = UDim2.new(0, 74, 0, -1),
        BackgroundTransparency = 1,
        Text = title,
        Font = Enum.Font.GothamBold,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left
    })
    ThemeManager:Register(titleLbl, "TextColor3", "Text")

    -- darken the circle on hover
    local function addTrafficHover(visual, color)
        local h, s, v = color:ToHSV()
        local hoverColor = Color3.fromHSV(h, s, math.clamp(v - 0.2, 0, 1))
        self.Janitor:Add(visual.Parent.MouseEnter:Connect(function()
            Animator:Tween(visual, {BackgroundColor3 = hoverColor}, 0.2)
        end))
        self.Janitor:Add(visual.Parent.MouseLeave:Connect(function()
            Animator:Tween(visual, {BackgroundColor3 = color}, 0.2)
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
        _nextUserOrder = 2,
        _tabSwitching = false
    }

    self.Janitor:Add(closeBtn.MouseButton1Click:Connect(function()
        windowObj.Hidden = true
        Animator:Tween(canvasGroup, {GroupTransparency = 1}, 0.3)
        Animator:Tween(stroke, {Transparency = 1}, 0.3)
        Animator:Tween(shadowFrame:FindFirstChild("Shadow"), {ImageTransparency = 1}, 0.3)
        if isMobile and fab then
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

    self.Janitor:Add(minBtn.MouseButton1Click:Connect(function()
        windowObj.Minimized = not windowObj.Minimized
        if windowObj.Minimized then
            Animator:Tween(canvasGroup, {Size = UDim2.new(0, canvasGroup.Size.X.Offset, 0, 40)}, 0.4, Enum.EasingStyle.Quint)
            dragBar.Visible = false
        else
            local restoreMax = _curIsPhone and UDim2.new(0, 500, 0, 400)
                                   or (_curIsTablet and UDim2.new(0, 600, 0, 400)
                                   or UDim2.new(0, 800, 0, 600))
            Animator:Tween(canvasGroup, {Size = windowObj.Maximized and restoreMax or size}, 0.4, Enum.EasingStyle.Quint)
            dragBar.Visible = true
        end
    end))

    self.Janitor:Add(maxBtn.MouseButton1Click:Connect(function()
        if windowObj.Minimized then return end
        windowObj.Maximized = not windowObj.Maximized
        if windowObj.Maximized then
            local maxSize = _curIsPhone and UDim2.new(0, 500, 0, 400)
                                or (_curIsTablet and UDim2.new(0, 600, 0, 400)
                                or UDim2.new(0, 800, 0, 600))
            Animator:Tween(canvasGroup, {Size = maxSize, Position = UDim2.new(0.5, 0, 0.5, 0)}, 0.4, Enum.EasingStyle.Quint)
        else
            Animator:Tween(canvasGroup, {Size = size}, 0.4, Enum.EasingStyle.Quint)
        end
    end))
    
    local tabContainer
    local tabList
    local tabLayout
    local contentContainer

    tabContainer = Utility:Create("Frame", {
        Parent = canvasGroup,
        Size = UDim2.new(0, 150, 1, -40),
        Position = UDim2.new(0, 0, 0, 40),
        BackgroundTransparency = 1
    })

    tabList = Utility:Create("ScrollingFrame", {
        Parent = tabContainer,
        Size = UDim2.new(1, 0, 1, -10),
        Position = UDim2.new(0, 0, 0, 5),
        BackgroundTransparency = 1,
        ScrollBarThickness = 0,
        CanvasSize = UDim2.new(0, 0, 0, 0)
    })
    tabLayout = Utility:Create("UIListLayout", {
        Parent = tabList,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 5),
        HorizontalAlignment = Enum.HorizontalAlignment.Center
    })
    Utility:Create("UIPadding", {
        Parent = tabList,
        PaddingBottom = UDim.new(0, 10)
    })

    tabLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        tabList.CanvasSize = UDim2.new(0, 0, 0, tabLayout.AbsoluteContentSize.Y + 10)
    end)

    contentContainer = Utility:Create("Frame", {
        Parent = canvasGroup,
        Size = UDim2.new(1, -150, 1, -40),
        Position = UDim2.new(0, 150, 0, 40),
        BackgroundTransparency = 1,
        ClipsDescendants = true
    })

    -- where tabs show up
    local contentArea = Utility:Create("Frame", {
        Parent = contentContainer,
        Size = UDim2.new(1, 0, 1, -10),
        Position = UDim2.new(0, 0, 0, 5),
        BackgroundTransparency = 1,
        ClipsDescendants = true
    })

    -- stash for hidden tabs so layout doesnt break
    local hiddenContainer = Utility:Create("CanvasGroup", {
        Parent = contentContainer,
        Size = UDim2.new(1, 0, 1, -10),
        Position = UDim2.new(0, 0, 0, 5),
        BackgroundTransparency = 1,
        GroupTransparency = 1,
        Visible = true
    })
    
    -- little floating open btn for phone
    if isMobile then
        local fabWidth = 90
        local fabHeight = 36

        fab = Utility:Create("TextButton", {
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
        Utility:Create("UICorner", {Parent = fab, CornerRadius = UDim.new(0, 12)})

        -- outline
        local fabStroke = Utility:Create("UIStroke", {
            Parent = fab,
            Thickness = 2,
            Color = ThemeManager.Themes.Default.Accent,
            Transparency = 0
        })
        ThemeManager:Register(fabStroke, "Color", "Accent")

        -- same bg as the window
        ThemeManager:Register(fab, "BackgroundColor3", "Background")

        Utility:AddShadow(fab, 0.3, 14)

        -- split label, REN + UI
        local fabRenLabel = Utility:Create("TextLabel", {
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
        ThemeManager:Register(fabRenLabel, "TextColor3", "Text")

        local fabUiLabel = Utility:Create("TextLabel", {
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
        ThemeManager:Register(fabUiLabel, "TextColor3", "Accent")

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
        self.Janitor:Add(RunService.RenderStepped:Connect(function()
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
        self.Janitor:Add(fab.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1
               or input.UserInputType == Enum.UserInputType.Touch then
                fabDragging = true
                fabDragMoved = false
                dragInput = input
                fabStartInputPos = input.Position
                fabStartObjPos = fab.Position
                fabCurrentPos = fab.Position
                -- little press-in
                Animator:Tween(fab, {Size = UDim2.new(0, fabWidth - 4, 0, fabHeight - 2)}, 0.08, Enum.EasingStyle.Quad)
            end
        end))

        -- track finger even if it slides off the btn
        self.Janitor:Add(UserInputService.InputChanged:Connect(function(input, processed)
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
        self.Janitor:Add(UserInputService.InputEnded:Connect(function(input, processed)
            if fabDragging and input == dragInput then
                local wasDrag = fabDragMoved
                fabDragging = false
                dragInput = nil
                fabStartInputPos = nil
                fabStartObjPos = nil
                -- pop back
                Animator:Tween(fab, {Size = UDim2.new(0, fabWidth, 0, fabHeight)}, 0.2, Enum.EasingStyle.Back)
                if not wasDrag then
                    -- tapped, toggle ui same as rightshift
                    if windowObj.Hidden then
                        windowObj.Hidden = false
                        canvasGroup.Visible = true
                        shadowFrame.Visible = true
                        Animator:Tween(canvasGroup, {GroupTransparency = windowObj.UserOpacity}, 0.3)
                        Animator:Tween(stroke, {Transparency = 0.5}, 0.3)
                        local shadow = shadowFrame:FindFirstChild("Shadow")
                        if shadow then
                            Animator:Tween(shadow, {ImageTransparency = 0.4 + 0.6 * windowObj.UserOpacity}, 0.3)
                        end
                        if not windowObj.Minimized then
                            dragBar.Visible = true
                        end
                    else
                        windowObj.Hidden = true
                        Animator:Tween(canvasGroup, {GroupTransparency = 1}, 0.3)
                        Animator:Tween(stroke, {Transparency = 1}, 0.3)
                        local shadow = shadowFrame:FindFirstChild("Shadow")
                        if shadow then
                            Animator:Tween(shadow, {ImageTransparency = 1}, 0.3)
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
    
    self.Janitor:Add(UserInputService.InputBegan:Connect(function(input, processed)
        if processed then return end
        if input.KeyCode == self.ToggleKeybind then
            windowObj.Hidden = not windowObj.Hidden
            if windowObj.Hidden then
                Animator:Tween(canvasGroup, {GroupTransparency = 1}, 0.3)
                Animator:Tween(stroke, {Transparency = 1}, 0.3)
                Animator:Tween(shadowFrame:FindFirstChild("Shadow"), {ImageTransparency = 1}, 0.3)
                if isMobile and fab then
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
                Animator:Tween(canvasGroup, {GroupTransparency = windowObj.UserOpacity}, 0.3)
                Animator:Tween(stroke, {Transparency = 0.5}, 0.3)
                Animator:Tween(shadowFrame:FindFirstChild("Shadow"), {ImageTransparency = 0.4 + 0.6 * windowObj.UserOpacity}, 0.3)
                if not windowObj.Minimized then
                    dragBar.Visible = true
                end
            end
        end
    end))
    
    function windowObj:CreateTab(name, layoutOrder, customBuild)
        local tabBtn = Utility:Create("TextButton", {
            Parent = tabList,
            Size = UDim2.new(1, -20, 0, 32),
            BackgroundTransparency = 1,
            Text = name,
            Font = Enum.Font.GothamSemibold,
            TextSize = 13,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextTruncate = Enum.TextTruncate.AtEnd,
            LayoutOrder = layoutOrder or windowObj._nextUserOrder,
            AutoButtonColor = false
        })
        if not layoutOrder then
            windowObj._nextUserOrder = windowObj._nextUserOrder + 1
        end
        Utility:Create("UIPadding", {Parent = tabBtn, PaddingLeft = UDim.new(0, 15)})
        Utility:Create("UICorner", {Parent = tabBtn, CornerRadius = UDim.new(0, 6)})
        ThemeManager:Register(tabBtn, "TextColor3", "SubText")

        local activeIndicator = Utility:Create("Frame", {
            Parent = tabBtn,
            Size = UDim2.new(0, 3, 0, 0),
            Position = UDim2.new(0, -10, 0.5, 0),
            AnchorPoint = Vector2.new(0, 0.5),
            BackgroundTransparency = 0
        })
        ThemeManager:Register(activeIndicator, "BackgroundColor3", "Accent")
        Utility:Create("UICorner", {Parent = activeIndicator, CornerRadius = UDim.new(1, 0)})
        Utility:AddShadow(activeIndicator, 0.6, 6)
        
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
        local canvasGroup = Utility:Create("CanvasGroup", {
            Parent = container,
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundColor3 = ThemeManager.Themes.Default.Background,
            GroupTransparency = 0
        })
        ThemeManager:Register(canvasGroup, "BackgroundColor3", "Background")
        local scroll = Utility:Create("ScrollingFrame", {
            Parent = canvasGroup,
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundColor3 = ThemeManager.Themes.Default.Background,
            BackgroundTransparency = 0,
            ScrollBarThickness = 0,
            CanvasSize = UDim2.new(0, 0, 0, 0)
        })
        ThemeManager:Register(scroll, "BackgroundColor3", "Background")
        ThemeManager:Register(scroll, "ScrollBarImageColor3", "Accent")
        local layout = Utility:Create("UIListLayout", {
                Parent = scroll,
                SortOrder = Enum.SortOrder.LayoutOrder,
                Padding = UDim.new(0, 10),
                HorizontalAlignment = Enum.HorizontalAlignment.Center
            })
            Utility:Create("UIPadding", {Parent = scroll, PaddingTop = UDim.new(0, 6), PaddingBottom = UDim.new(0, 20)})
            
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
                    local sep = Utility:Create("Frame", {
                        Parent = scroll,
                        Size = UDim2.new(1, -20, 0, 4),
                        BackgroundTransparency = 0,
                        BorderSizePixel = 0,
                        LayoutOrder = (i - 1) * 2
                    })
                    ThemeManager:Register(sep, "BackgroundColor3", "Accent")
                    Utility:Create("UICorner", {Parent = sep, CornerRadius = UDim.new(1, 0)})
                    Utility:AddShadow(sep, 0.5, 4)
                end
                local secFrame = Utility:Create("Frame", {
                    Parent = scroll,
                    Size = UDim2.new(1, -20, 0, 0),
                    BackgroundTransparency = 0,
                    LayoutOrder = (i - 1) * 2 + 1
                })
                ThemeManager:Register(secFrame, "BackgroundColor3", "Section")
                Utility:Create("UICorner", {Parent = secFrame, CornerRadius = UDim.new(0, 6)})
                ThemeManager:Register(Utility:Create("UIStroke", {Parent = secFrame, Thickness = 1, Color = ThemeManager.Themes.Default.Border, Transparency = 0.5}), "Color", "Border")
                
                local secLayout = Utility:Create("UIListLayout", {
                    Parent = secFrame,
                    SortOrder = Enum.SortOrder.LayoutOrder,
                    Padding = UDim.new(0, 10)
                })
                local secPadding = Utility:Create("UIPadding", {
                    Parent = secFrame,
                    PaddingTop = UDim.new(0, 14),
                    PaddingBottom = UDim.new(0, 14),
                    PaddingLeft = UDim.new(0, 14),
                    PaddingRight = UDim.new(0, 14)
                })
                
                local secTitle = Utility:Create("TextLabel", {
                    Parent = secFrame,
                    Size = UDim2.new(1, 0, 0, 24),
                    BackgroundTransparency = 1,
                    Text = secDef.Name,
                    Font = Enum.Font.GothamBold,
                    TextSize = 14,
                    TextStrokeTransparency = 1,
                    TextXAlignment = Enum.TextXAlignment.Left
                })
                ThemeManager:Register(secTitle, "TextColor3", "Text")
                
                local divider = Utility:Create("Frame", {
                    Parent = secFrame,
                    Size = UDim2.new(1, 0, 0, 1),
                    BackgroundTransparency = 0.5,
                    BorderSizePixel = 0
                })
                ThemeManager:Register(divider, "BackgroundColor3", "Border")
                
                for _, compDef in ipairs(secDef.Components) do
                    if compDef.Type == "Button" then
                        local btn = Utility:Create("TextButton", {
                            Parent = secFrame,
                            Size = UDim2.new(1, 0, 0, 32),
                            AutoButtonColor = false,
                            Text = compDef.Name,
                            Font = Enum.Font.GothamSemibold,
                            TextSize = 13
                        })
                        ThemeManager:Register(btn, "BackgroundColor3", "Container")
                        ThemeManager:Register(btn, "TextColor3", "Text")
                        Utility:Create("UICorner", {Parent = btn, CornerRadius = UDim.new(0, 6)})
                        local stroke = Utility:Create("UIStroke", {Parent = btn, Thickness = 1, Color = ThemeManager.Themes.Default.Border, Transparency = 0.5})
                        ThemeManager:Register(stroke, "Color", "Border")
                        
                        Library.Janitor:Add(btn.MouseEnter:Connect(function()
                            Animator:Tween(btn, {BackgroundColor3 = ThemeManager.Themes.Default.Hover}, 0.2)
                            Animator:Tween(stroke, {Transparency = 0}, 0.2)
                        end))
                        Library.Janitor:Add(btn.MouseLeave:Connect(function()
                            Animator:Tween(btn, {BackgroundColor3 = ThemeManager.Themes.Default.Container}, 0.2)
                            Animator:Tween(stroke, {Transparency = 0.5}, 0.2)
                        end))
                        Library.Janitor:Add(btn.MouseButton1Down:Connect(function()
                            Animator:Tween(btn, {BackgroundColor3 = ThemeManager.Themes.Default.Click}, 0.1)
                        end))
                        Library.Janitor:Add(btn.MouseButton1Up:Connect(function()
                            Animator:Tween(btn, {BackgroundColor3 = ThemeManager.Themes.Default.Hover}, 0.1)
                        end))
                        Library.Janitor:Add(btn.MouseButton1Click:Connect(function()
                            Library:SafeCallback(compDef.Callback)
                        end))
                        
                     elseif compDef.Type == "Toggle" then
                         local tglFrame = Utility:Create("Frame", {
                             Parent = secFrame,
                             Size = UDim2.new(1, 0, 0, 32),
                             BackgroundTransparency = 1
                         })
                         local lbl = Utility:Create("TextLabel", {
                             Parent = tglFrame,
                             Size = UDim2.new(1, -60, 1, 0),
                             BackgroundTransparency = 1,
                             Text = compDef.Name,
                             Font = Enum.Font.GothamMedium,
                             TextSize = 13,
                             TextXAlignment = Enum.TextXAlignment.Left
                         })
                         ThemeManager:Register(lbl, "TextColor3", "SubText")

                         local boxHeight = 22
                         local boxWidth = 42
                         local box = Utility:Create("TextButton", {
                             Parent = tglFrame,
                             Size = UDim2.new(0, boxWidth, 0, boxHeight),
                             Position = UDim2.new(1, -boxWidth, 0.5, -boxHeight/2),
                             Text = "",
                             AutoButtonColor = false
                         })
                         ThemeManager:Register(box, "BackgroundColor3", "Container")
                         Utility:Create("UICorner", {Parent = box, CornerRadius = UDim.new(1, 0)})
                         local boxStroke = Utility:Create("UIStroke", {Parent = box, Thickness = 1, Color = ThemeManager.Themes.Default.Border, Transparency = 0.5})
                         ThemeManager:Register(boxStroke, "Color", "Border")

                         local indSize = 18
                         local indOff = 2
                         local indicator = Utility:Create("Frame", {
                             Parent = box,
                             Size = UDim2.new(0, indSize, 0, indSize),
                             Position = UDim2.new(0, indOff, 0.5, -indSize/2)
                         })
                         ThemeManager:Register(indicator, "BackgroundColor3", "SubText")
                         Utility:Create("UICorner", {Parent = indicator, CornerRadius = UDim.new(1, 0)})
                         Utility:Create("UIGradient", {
                             Parent = indicator,
                             Color = ColorSequence.new({
                                 ColorSequenceKeypoint.new(0, Color3.fromRGB(220, 220, 220)),
                                 ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255))
                             }),
                             Rotation = 45
                         })

                         local state = compDef.Default or false
                         local function updateState(anim)
                             local onPos = UDim2.new(1, -indSize - indOff, 0.5, -indSize/2)
                             local offPos = UDim2.new(0, indOff, 0.5, -indSize/2)
                             if state then
                                 ThemeManager:Register(indicator, "BackgroundColor3", "Background")
                                 ThemeManager:Register(lbl, "TextColor3", "Text")
                                 ThemeManager:Register(box, "BackgroundColor3", "Accent")
                                 if anim then
                                     Animator:Tween(indicator, {Position = onPos}, 0.25, Enum.EasingStyle.Back)
                                     Animator:Tween(box, {BackgroundColor3 = ThemeManager.Themes.Default.Accent}, 0.2)
                                     Animator:Tween(boxStroke, {Color = ThemeManager.Themes.Default.Accent, Transparency = 1}, 0.2)
                                 else
                                     indicator.Position = onPos
                                     box.BackgroundColor3 = ThemeManager.Themes.Default.Accent
                                     boxStroke.Color = ThemeManager.Themes.Default.Accent
                                     boxStroke.Transparency = 1
                                 end
                             else
                                 ThemeManager:Register(indicator, "BackgroundColor3", "SubText")
                                 ThemeManager:Register(lbl, "TextColor3", "SubText")
                                 ThemeManager:Register(box, "BackgroundColor3", "Container")
                                 if anim then
                                     Animator:Tween(indicator, {Position = offPos}, 0.25, Enum.EasingStyle.Back)
                                     Animator:Tween(box, {BackgroundColor3 = ThemeManager.Themes.Default.Container}, 0.2)
                                     Animator:Tween(boxStroke, {Color = ThemeManager.Themes.Default.Border, Transparency = 0.5}, 0.2)
                                 else
                                     indicator.Position = offPos
                                     box.BackgroundColor3 = ThemeManager.Themes.Default.Container
                                     boxStroke.Color = ThemeManager.Themes.Default.Border
                                     boxStroke.Transparency = 0.5
                                 end
                             end
                         end

                         updateState(false)
                         table.insert(Library.Toggles, updateState)

                         local function toggle()
                             state = not state
                             updateState(true)
                             Animator:Tween(indicator, {Size = UDim2.new(0, indSize + 4, 0, indSize + 4)}, 0.08, Enum.EasingStyle.Quad)
                             task.delay(0.08, function()
                                 Animator:Tween(indicator, {Size = UDim2.new(0, indSize, 0, indSize)}, 0.18, Enum.EasingStyle.Back)
                             end)
                          Library:SafeCallback(compDef.Callback, state)
                              if compDef.Flag and ConfigManager.Flags[compDef.Flag] then
                                  ConfigManager.Flags[compDef.Flag].Value = state
                              end
                         end

                         Library.Janitor:Add(box.MouseButton1Click:Connect(toggle))

                         local flagObj = {
                             Value = state,
                             Default = compDef.Default,
                             Set = function(self, val)
                                 state = val
                                 updateState(true)
                                 Library:SafeCallback(compDef.Callback, state)
                             end
                         }
                         if compDef.Flag then ConfigManager.Flags[compDef.Flag] = flagObj end
                        
                    elseif compDef.Type == "Slider" then
                        local sldFrame = Utility:Create("Frame", {
                            Parent = secFrame,
                            Size = UDim2.new(1, 0, 0, 48),
                            BackgroundTransparency = 1,
                            ClipsDescendants = false
                        })
                        local lbl = Utility:Create("TextLabel", {
                            Parent = sldFrame,
                            Size = UDim2.new(1, -50, 0, 20),
                            Position = UDim2.new(0, 0, 0, 0),
                            BackgroundTransparency = 1,
                            Text = compDef.Name,
                            Font = Enum.Font.GothamMedium,
                            TextSize = 13,
                            TextXAlignment = Enum.TextXAlignment.Left
                        })
                        ThemeManager:Register(lbl, "TextColor3", "Text")

                        local valLbl = Utility:Create("TextLabel", {
                            Parent = sldFrame,
                            Size = UDim2.new(0, 50, 0, 20),
                            Position = UDim2.new(1, -50, 0, 0),
                            BackgroundTransparency = 1,
                            Text = tostring(compDef.Default),
                            Font = Enum.Font.GothamMedium,
                            TextSize = 13,
                            TextXAlignment = Enum.TextXAlignment.Right
                        })
                        ThemeManager:Register(valLbl, "TextColor3", "SubText")

                        local trackHeight = 6
                        local knobSize = 16
                        local trackY = 21

                        local track = Utility:Create("Frame", {
                            Parent = sldFrame,
                            Size = UDim2.new(1, 0, 0, trackHeight),
                            Position = UDim2.new(0, 0, 0, trackY),
                            BackgroundColor3 = ThemeManager.Themes.Default.Container,
                            ZIndex = 1
                        })
                        ThemeManager:Register(track, "BackgroundColor3", "Container")
                        Utility:Create("UICorner", {Parent = track, CornerRadius = UDim.new(1, 0)})
                        ThemeManager:Register(Utility:Create("UIStroke", {Parent = track, Thickness = 1, Color = ThemeManager.Themes.Default.Border, Transparency = 0.5}), "Color", "Border")

                        local fill = Utility:Create("Frame", {
                            Parent = track,
                            Size = UDim2.new(0, 0, 1, 0),
                            BackgroundColor3 = ThemeManager.Themes.Default.Accent,
                            ZIndex = 2
                        })
                        ThemeManager:Register(fill, "BackgroundColor3", "Accent")
                        Utility:Create("UICorner", {Parent = fill, CornerRadius = UDim.new(1, 0)})
                        Utility:Create("UIGradient", {
                            Parent = fill,
                            Transparency = NumberSequence.new({
                                NumberSequenceKeypoint.new(0, 0),
                                NumberSequenceKeypoint.new(1, 0.25)
                            }),
                            Rotation = 90
                        })

                        local knobHitboxSize = 24
                        local knobHitbox = Utility:Create("TextButton", {
                            Parent = fill,
                            Size = UDim2.new(0, knobHitboxSize, 0, knobHitboxSize),
                            Position = UDim2.new(1, -knobHitboxSize/2, 0.5, -knobHitboxSize/2),
                            BackgroundTransparency = 1,
                            Text = "",
                            AutoButtonColor = false,
                            ZIndex = 4
                        })
                        local knob = Utility:Create("Frame", {
                            Parent = knobHitbox,
                            Size = UDim2.new(0, knobSize, 0, knobSize),
                            Position = UDim2.new(0.5, -knobSize/2, 0.5, -knobSize/2),
                            BackgroundColor3 = ThemeManager.Themes.Default.Text,
                            ZIndex = 3
                        })
                        ThemeManager:Register(knob, "BackgroundColor3", "Text")
                        Utility:Create("UICorner", {Parent = knob, CornerRadius = UDim.new(1, 0)})
                        local knobStroke = Utility:Create("UIStroke", {Parent = knob, Thickness = 2, Color = ThemeManager.Themes.Default.Accent, Transparency = 0})
                        ThemeManager:Register(knobStroke, "Color", "Accent")
                        Utility:AddShadow(knob, 0.5, 6)

                        local tooltip = Utility:Create("Frame", {
                            Parent = knob,
                            Size = UDim2.new(0, 40, 0, 22),
                            Position = UDim2.new(0.5, 0, 0, -28),
                            AnchorPoint = Vector2.new(0.5, 0),
                            BackgroundColor3 = ThemeManager.Themes.Default.Container,
                            ZIndex = 10,
                            Visible = false,
                            ClipsDescendants = false
                        })
                        ThemeManager:Register(tooltip, "BackgroundColor3", "Container")
                        Utility:Create("UICorner", {Parent = tooltip, CornerRadius = UDim.new(0, 6)})
                        ThemeManager:Register(Utility:Create("UIStroke", {Parent = tooltip, Thickness = 1, Color = ThemeManager.Themes.Default.Accent, Transparency = 0.3}), "Color", "Accent")
                        local tooltipText = Utility:Create("TextLabel", {
                            Parent = tooltip,
                            Size = UDim2.new(1, 0, 1, 0),
                            BackgroundTransparency = 1,
                            Text = "",
                            Font = Enum.Font.GothamBold,
                            TextSize = 11,
                            TextXAlignment = Enum.TextXAlignment.Center,
                            TextColor3 = ThemeManager.Themes.Default.Accent,
                            ZIndex = 11
                        })
                        ThemeManager:Register(tooltipText, "TextColor3", "Accent")

                        local dragging = false
                        local hover = false
                        local dragInput = nil
                        local value = compDef.Default or compDef.Min
                        tooltipText.Text = tostring(value)

                        local function setKnobSize(size)
                            Animator:Tween(knob, {Size = UDim2.new(0, size, 0, size), Position = UDim2.new(0.5, -size/2, 0.5, -size/2)}, 0.2, Enum.EasingStyle.Back)
                        end

                        local function setFill(percent)
                            fill.Size = UDim2.new(percent, 0, 1, 0)
                        end

                        local function update(input)
                            local w = track.AbsoluteSize.X
                            if w == 0 then return end
                            local percent = math.clamp((input.Position.X - track.AbsolutePosition.X) / w, 0, 1)
                            value = math.floor(compDef.Min + (compDef.Max - compDef.Min) * percent)
                            valLbl.Text = tostring(value)
                            tooltipText.Text = tostring(value)
                            setFill(percent)
                            Library:SafeCallback(compDef.Callback, value)
                            if compDef.Flag and ConfigManager.Flags[compDef.Flag] then
                                ConfigManager.Flags[compDef.Flag].Value = value
                            end
                        end

                        local function startDrag(input)
                            dragging = true
                            dragInput = input
                            tooltip.Visible = true
                            tooltipText.TextTransparency = 1
                            tooltip.Size = UDim2.new(0, 40, 0, 0)
                            Animator:Tween(tooltip, {Size = UDim2.new(0, 40, 0, 22)}, 0.15, Enum.EasingStyle.Back)
                            Animator:Tween(tooltipText, {TextTransparency = 0}, 0.15, Enum.EasingStyle.Back)
                            setKnobSize(knobSize + 4)
                            Animator:Tween(knobStroke, {Thickness = 2.5, Transparency = 0}, 0.2)
                            update(input)
                        end

                        local function endDrag()
                            dragging = false
                            dragInput = nil
                            Animator:Tween(tooltipText, {TextTransparency = 1}, 0.1)
                            Animator:Tween(tooltip, {Size = UDim2.new(0, 40, 0, 0)}, 0.15, Enum.EasingStyle.Quad)
                            task.delay(0.15, function()
                                if not dragging then
                                    tooltip.Visible = false
                                    tooltipText.TextTransparency = 1
                                end
                            end)
                            if hover then
                                setKnobSize(knobSize + 2)
                                Animator:Tween(knobStroke, {Thickness = 2, Transparency = 0.15}, 0.2)
                            else
                                setKnobSize(knobSize)
                                Animator:Tween(knobStroke, {Thickness = 2, Transparency = 0.3}, 0.2)
                            end
                        end

                        Library.Janitor:Add(knobHitbox.MouseEnter:Connect(function()
                            hover = true
                            if not dragging then
                                setKnobSize(knobSize + 2)
                                Animator:Tween(knobStroke, {Thickness = 2, Transparency = 0.15}, 0.2)
                            end
                        end))
                        Library.Janitor:Add(knobHitbox.MouseLeave:Connect(function()
                            hover = false
                            if not dragging then
                                setKnobSize(knobSize)
                                Animator:Tween(knobStroke, {Thickness = 2, Transparency = 0.3}, 0.2)
                            end
                        end))
                        Library.Janitor:Add(knobHitbox.InputBegan:Connect(function(input)
                            if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) and not dragInput then
                                startDrag(input)
                            end
                        end))
                        Library.Janitor:Add(UserInputService.InputChanged:Connect(function(input)
                            if not dragging then return end
                            -- Touch uses a single persistent input object (filter required for cross-slider safety).
                            -- Mouse uses separate objects (MouseButton1 click vs MouseMovement), so filter only by type.
                            if input.UserInputType == Enum.UserInputType.Touch and input ~= dragInput then return end
                            if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
                                update(input)
                            end
                        end))
                        Library.Janitor:Add(UserInputService.InputEnded:Connect(function(input)
                            if not dragging then return end
                            if input.UserInputType == Enum.UserInputType.Touch and input ~= dragInput then return end
                            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                                endDrag()
                            end
                        end))

                        local percent = math.clamp((value - compDef.Min) / (compDef.Max - compDef.Min), 0, 1)
                        setFill(percent)

                        local flagObj = {
                            Value = value,
                            Default = compDef.Default,
                            Set = function(self, val)
                                value = math.clamp(val, compDef.Min, compDef.Max)
                                valLbl.Text = tostring(value)
                                local p = math.clamp((value - compDef.Min) / (compDef.Max - compDef.Min), 0, 1)
                                Animator:Tween(fill, {Size = UDim2.new(p, 0, 1, 0)}, 0.1)
                                Library:SafeCallback(compDef.Callback, value)
                            end
                        }
                        if compDef.Flag then ConfigManager.Flags[compDef.Flag] = flagObj end
                        
                    elseif compDef.Type == "Dropdown" then
                        local dpHeight = 52
                        local dpExpanded = 160
                        local dpFrame = Utility:Create("Frame", {
                            Parent = secFrame,
                            Size = UDim2.new(1, 0, 0, dpHeight),
                            BackgroundTransparency = 1,
                            ClipsDescendants = true
                        })
                        Library.Janitor:Add(dpFrame:GetPropertyChangedSignal("Size"):Connect(function()
                            RefreshLayout()
                        end))
                        local lbl = Utility:Create("TextLabel", {
                            Parent = dpFrame,
                            Size = UDim2.new(1, 0, 0, 20),
                            BackgroundTransparency = 1,
                            Text = compDef.Name,
                            Font = Enum.Font.GothamMedium,
                            TextSize = 13,
                            TextXAlignment = Enum.TextXAlignment.Left
                        })
                        ThemeManager:Register(lbl, "TextColor3", "Text")

                        local boxHeight = 28
                        local box = Utility:Create("TextButton", {
                            Parent = dpFrame,
                            Size = UDim2.new(1, 0, 0, boxHeight),
                            Position = UDim2.new(0, 0, 0, 24),
                            Text = " " .. tostring(compDef.Default or "Select..."),
                            Font = Enum.Font.GothamMedium,
                            TextSize = 13,
                            TextXAlignment = Enum.TextXAlignment.Left,
                            AutoButtonColor = false
                        })
                        ThemeManager:Register(box, "BackgroundColor3", "Container")
                        ThemeManager:Register(box, "TextColor3", "SubText")
                        Utility:Create("UICorner", {Parent = box, CornerRadius = UDim.new(0, 6)})
                        local boxStroke = Utility:Create("UIStroke", {Parent = box, Thickness = 1, Color = ThemeManager.Themes.Default.Border, Transparency = 0.5})
                        ThemeManager:Register(boxStroke, "Color", "Border")
                        
                        local icon = Utility:Create("TextLabel", {
                            Parent = box,
                            Size = UDim2.new(0, 20, 1, 0),
                            Position = UDim2.new(1, -25, 0, 0),
                            BackgroundTransparency = 1,
                            Text = "▼",
                            Font = Enum.Font.Gotham,
                            TextSize = 10
                        })
                        ThemeManager:Register(icon, "TextColor3", "SubText")
                        
                        local listPos = 56
                        local optHeight = 26
                        local listFrame = Utility:Create("ScrollingFrame", {
                            Parent = dpFrame,
                            Size = UDim2.new(1, 0, 0, 100),
                            Position = UDim2.new(0, 0, 0, listPos),
                            BackgroundTransparency = 0,
                            BorderSizePixel = 0,
                            ScrollBarThickness = 0,
                            CanvasSize = UDim2.new(0, 0, 0, #compDef.Items * (optHeight + 2))
                        })
                        ThemeManager:Register(listFrame, "BackgroundColor3", "Background")
                        ThemeManager:Register(listFrame, "ScrollBarImageColor3", "Accent")
                        Utility:Create("UICorner", {Parent = listFrame, CornerRadius = UDim.new(0, 6)})
                        ThemeManager:Register(Utility:Create("UIStroke", {Parent = listFrame, Thickness = 1, Color = ThemeManager.Themes.Default.Border, Transparency = 0.5}), "Color", "Border")
                        Utility:Create("UIPadding", {
                            Parent = listFrame,
                            PaddingTop = UDim.new(0, 4),
                            PaddingBottom = UDim.new(0, 4),
                            PaddingLeft = UDim.new(0, 4),
                            PaddingRight = UDim.new(0, 4)
                        })
                        
                        local listLayout = Utility:Create("UIListLayout", {
                            Parent = listFrame,
                            SortOrder = Enum.SortOrder.LayoutOrder,
                            Padding = UDim.new(0, 2)
                        })
                        
                        local expanded = false
                        local dValue = compDef.Default
                        local optionBtns = {}
                        
                        for i, item in ipairs(compDef.Items) do
                            local opt = Utility:Create("TextButton", {
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
                            Utility:Create("UICorner", {Parent = opt, CornerRadius = UDim.new(0, 4)})
                            ThemeManager:Register(opt, "TextColor3", "SubText")

                            local optCheck = Utility:Create("TextLabel", {
                                Parent = opt,
                                Size = UDim2.new(0, 16, 1, 0),
                                Position = UDim2.new(1, -18, 0, 0),
                                BackgroundTransparency = 1,
                                Text = "✓",
                                Font = Enum.Font.GothamBold,
                                TextSize = 12,
                                TextXAlignment = Enum.TextXAlignment.Center,
                                Visible = false,
                                ZIndex = 2
                            })
                            ThemeManager:Register(optCheck, "TextColor3", "Accent")
                            if dValue == item then
                                optCheck.Visible = true
                                opt.TextColor3 = ThemeManager.Themes.Default.Text
                            end

                            Library.Janitor:Add(opt.MouseEnter:Connect(function()
                                opt.TextColor3 = ThemeManager.Themes.Default.Text
                                opt.BackgroundColor3 = ThemeManager.Themes.Default.Hover
                                Animator:Tween(opt, {BackgroundTransparency = 0}, 0.2)
                            end))
                            Library.Janitor:Add(opt.MouseLeave:Connect(function()
                                if dValue ~= item then
                                    opt.TextColor3 = ThemeManager.Themes.Default.SubText
                                end
                                Animator:Tween(opt, {BackgroundTransparency = 1}, 0.2)
                            end))

                            Library.Janitor:Add(opt.MouseButton1Click:Connect(function()
                                dValue = item
                                box.Text = " " .. item
                                for _, data in ipairs(optionBtns) do
                                    data.Btn.TextColor3 = ThemeManager.Themes.Default.SubText
                                    data.Check.Visible = false
                                end
                                opt.TextColor3 = ThemeManager.Themes.Default.Text
                                optCheck.Visible = true
                                Library:SafeCallback(compDef.Callback, dValue)
                                if compDef.Flag and ConfigManager.Flags[compDef.Flag] then
                                    ConfigManager.Flags[compDef.Flag].Value = dValue
                                end

                                expanded = false
                                Animator:Tween(dpFrame, {Size = UDim2.new(1, 0, 0, dpHeight)}, 0.25, Enum.EasingStyle.Quint)
                                Animator:Tween(icon, {Rotation = 0}, 0.2)
                                Animator:Tween(boxStroke, {Transparency = 0.5}, 0.2)
                            end))
                            table.insert(optionBtns, {Btn = opt, Check = optCheck})
                        end
                        
                        Library.Janitor:Add(box.MouseButton1Click:Connect(function()
                            expanded = not expanded
                            if expanded then
                                Animator:Tween(dpFrame, {Size = UDim2.new(1, 0, 0, dpExpanded)}, 0.25, Enum.EasingStyle.Quint)
                                Animator:Tween(icon, {Rotation = 180}, 0.2)
                                Animator:Tween(boxStroke, {Transparency = 0}, 0.2)
                            else
                                Animator:Tween(dpFrame, {Size = UDim2.new(1, 0, 0, dpHeight)}, 0.25, Enum.EasingStyle.Quint)
                                Animator:Tween(icon, {Rotation = 0}, 0.2)
                                Animator:Tween(boxStroke, {Transparency = 0.5}, 0.2)
                            end
                        end))
                        
                        local flagObj = {
                            Value = dValue,
                            Default = compDef.Default,
                            Set = function(self, val)
                                dValue = val
                                box.Text = " " .. tostring(val)
                                Library:SafeCallback(compDef.Callback, val)
                            end
                        }
                        if compDef.Flag then ConfigManager.Flags[compDef.Flag] = flagObj end
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
            
            function secMethods:CreateButton(btnName, callback)
                table.insert(secDef.Components, {Type = "Button", Name = btnName, Callback = callback})
            end
            
            function secMethods:CreateToggle(tglName, default, callback, flagName)
                if not flagName then flagName = ConfigManager:NextAutoFlag() end
                table.insert(secDef.Components, {Type = "Toggle", Name = tglName, Default = default, Callback = callback, Flag = flagName})
            end

            function secMethods:CreateSlider(sldName, min, max, default, callback, flagName)
                if not flagName then flagName = ConfigManager:NextAutoFlag() end
                table.insert(secDef.Components, {Type = "Slider", Name = sldName, Min = min, Max = max, Default = default, Callback = callback, Flag = flagName})
            end

            function secMethods:CreateDropdown(dpName, items, default, callback, flagName)
                if not flagName then flagName = ConfigManager:NextAutoFlag() end
                table.insert(secDef.Components, {Type = "Dropdown", Name = dpName, Items = items, Default = default, Callback = callback, Flag = flagName})
            end
            
            return secMethods
        end
        
        -- switching tabs
        local function SelectTab()
            if windowObj._tabSwitching then return end
            if windowObj.CurrentTab == tabObj then return end

            windowObj._tabSwitching = true

            local oldTab = windowObj.CurrentTab

            if oldTab and oldTab.ContentRoot and oldTab.ContentRoot.Parent == contentArea then
    Animator:Tween(oldTab.ContentRoot, {GroupTransparency = 1}, 0.2, Enum.EasingStyle.Quint)
    task.delay(0.2, function()
        if oldTab.ContentRoot and oldTab.ContentRoot.Parent == contentArea then
            oldTab.ContentRoot.Parent = hiddenContainer
            oldTab.ContentRoot.Visible = false
        end
    end)
                ThemeManager:Register(oldTab.Button, "TextColor3", "SubText")
                Animator:Tween(oldTab.Button, {BackgroundTransparency = 1}, 0.2)
                local oldIndicatorTarget = UDim2.new(0, 3, 0, 0)
                Animator:Tween(oldTab.Indicator, {Size = oldIndicatorTarget}, 0.2)
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
                windowObj._tabSwitching = false
                return
            end

            tabObj.ContentRoot.GroupTransparency = 1
            tabObj.ContentRoot.Visible = true
            tabObj.ContentRoot.Parent = contentArea

            Animator:Tween(tabObj.ContentRoot, {GroupTransparency = 0}, 0.2, Enum.EasingStyle.Quint)

            task.delay(0.2, function()
                if tabObj.ContentRoot and tabObj.ContentRoot.Parent then
                    tabObj.ContentRoot.GroupTransparency = 0
                end
            end)

            ThemeManager:Register(tabBtn, "TextColor3", "Text")
            ThemeManager:Register(tabBtn, "BackgroundColor3", "Hover")
            Animator:Tween(tabBtn, {BackgroundTransparency = 0}, 0.2)
            local activeIndicatorTarget = UDim2.new(0, 3, 0, 18)
            Animator:Tween(activeIndicator, {Size = activeIndicatorTarget}, 0.2, Enum.EasingStyle.Back)

            task.delay(0.2, function()
                windowObj._tabSwitching = false
            end)

            task.defer(function()
                if tabObj.RefreshLayout then
                    tabObj.RefreshLayout()
                end
            end)

            tabObj.Loaded = true
        end
        
        tabObj.Select = SelectTab
        Library.Janitor:Add(tabBtn.MouseButton1Click:Connect(SelectTab))
        
        table.insert(self.Tabs, tabObj)
        return tabObj
    end
    
    -- default tabs (home / servers / customize / settings)
    local function BuildHomeTab(tabObj, container)
        local canvasGroup = Utility:Create("CanvasGroup", {
            Parent = container,
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundColor3 = ThemeManager.Themes.Default.Background,
            GroupTransparency = 0
        })
        ThemeManager:Register(canvasGroup, "BackgroundColor3", "Background")
        local scroll = Utility:Create("ScrollingFrame", {
            Parent = canvasGroup,
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundColor3 = ThemeManager.Themes.Default.Background,
            BackgroundTransparency = 0,
            ScrollBarThickness = 0,
            CanvasSize = UDim2.new(0, 0, 0, 0)
        })
        ThemeManager:Register(scroll, "BackgroundColor3", "Background")
        ThemeManager:Register(scroll, "ScrollBarImageColor3", "Accent")

        local layout = Utility:Create("UIListLayout", {
            Parent = scroll,
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 10),
            HorizontalAlignment = Enum.HorizontalAlignment.Center
        })
        Utility:Create("UIPadding", {Parent = scroll, PaddingTop = UDim.new(0, 6), PaddingBottom = UDim.new(0, 20)})

        -- welcome card
        local welcomeFrame = Utility:Create("Frame", {
            Parent = scroll,
            Size = UDim2.new(1, -20, 0, 0),
            BackgroundTransparency = 0
        })
        welcomeFrame.LayoutOrder = 1
        ThemeManager:Register(welcomeFrame, "BackgroundColor3", "Section")
        Utility:Create("UICorner", {Parent = welcomeFrame, CornerRadius = UDim.new(0, 12)})
        ThemeManager:Register(Utility:Create("UIStroke", {Parent = welcomeFrame, Thickness = 1, Color = ThemeManager.Themes.Default.Border, Transparency = 0.5}), "Color", "Border")

        local welcomeLayout = Utility:Create("UIListLayout", {
            Parent = welcomeFrame,
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 8)
        })
        Utility:Create("UIPadding", {
            Parent = welcomeFrame,
            PaddingTop = UDim.new(0, 20),
            PaddingBottom = UDim.new(0, 20),
            PaddingLeft = UDim.new(0, 20),
            PaddingRight = UDim.new(0, 20)
        })

        -- pfp + name row
        local avatarRow = Utility:Create("Frame", {
            Parent = welcomeFrame,
            Size = UDim2.new(1, 0, 0, 100),
            BackgroundTransparency = 1
        })
        avatarRow.LayoutOrder = 1

        local avatarImg = Utility:Create("ImageLabel", {
            Parent = avatarRow,
            Size = UDim2.new(0, 70, 0, 70),
            Position = UDim2.new(0, 0, 0.5, -35),
            BackgroundTransparency = 1,
            Image = "rbxasset://textures/ui/GuiImagePlaceholder.png"
        })
        Utility:Create("UICorner", {Parent = avatarImg, CornerRadius = UDim.new(1, 0)})
        local avatarStroke = Utility:Create("UIStroke", {Parent = avatarImg, Thickness = 2, Color = ThemeManager.Themes.Default.Accent, Transparency = 0})
        ThemeManager:Register(avatarStroke, "Color", "Accent")

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

        local nameStack = Utility:Create("Frame", {
            Parent = avatarRow,
            Size = UDim2.new(1, -85, 1, 0),
            Position = UDim2.new(0, 85, 0, 0),
            BackgroundTransparency = 1
        })
        local nameLayout = Utility:Create("UIListLayout", {
            Parent = nameStack,
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 4),
            VerticalAlignment = Enum.VerticalAlignment.Center
        })

        -- hi row (+ premium tag if they got it)
        local isPremium = LocalPlayer.MembershipType == Enum.MembershipType.Premium
        local badgeOffset = isPremium and 74 or 0

        local greetRow = Utility:Create("Frame", {
            Parent = nameStack,
            Size = UDim2.new(1, 0, 0, 26),
            BackgroundTransparency = 1
        })
        greetRow.LayoutOrder = 1

        if isPremium then
            local premiumBadge = Utility:Create("Frame", {
                Parent = greetRow,
                Size = UDim2.new(0, 0, 0, 18),
                Position = UDim2.new(0, 0, 0.5, -9),
                AutomaticSize = Enum.AutomaticSize.X,
                BackgroundTransparency = 0
            })
            ThemeManager:Register(premiumBadge, "BackgroundColor3", "Accent")
            Utility:Create("UICorner", {Parent = premiumBadge, CornerRadius = UDim.new(0, 4)})
            Utility:Create("UIPadding", {Parent = premiumBadge, PaddingLeft = UDim.new(0, 6), PaddingRight = UDim.new(0, 6)})
            local premiumLbl = Utility:Create("TextLabel", {
                Parent = premiumBadge,
                AutomaticSize = Enum.AutomaticSize.X,
                Size = UDim2.new(1, 0, 1, 0),
                BackgroundTransparency = 1,
                Text = "PREMIUM",
                Font = Enum.Font.GothamBold,
                TextSize = 10,
                TextXAlignment = Enum.TextXAlignment.Left
            })
            ThemeManager:Register(premiumLbl, "TextColor3", "Background")
        end

        local greetLbl = Utility:Create("TextLabel", {
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
        ThemeManager:Register(greetLbl, "TextColor3", "Text")

        -- thanks row
        local thanksLbl = Utility:Create("TextLabel", {
            Parent = nameStack,
            Size = UDim2.new(1, 0, 0, 18),
            BackgroundTransparency = 1,
            Text = "Thanks for using my script!",
            Font = Enum.Font.GothamMedium,
            TextSize = 13,
            TextXAlignment = Enum.TextXAlignment.Left
        })
        ThemeManager:Register(thanksLbl, "TextColor3", "SubText")
        thanksLbl.LayoutOrder = 2

        -- @username
        local userLbl = Utility:Create("TextLabel", {
            Parent = nameStack,
            Size = UDim2.new(1, 0, 0, 18),
            BackgroundTransparency = 1,
            Text = "@" .. LocalPlayer.Name,
            Font = Enum.Font.GothamMedium,
            TextSize = 13,
            TextXAlignment = Enum.TextXAlignment.Left
        })
        ThemeManager:Register(userLbl, "TextColor3", "SubText")
        userLbl.LayoutOrder = 3

        -- age row
        local metaRow = Utility:Create("Frame", {
            Parent = nameStack,
            Size = UDim2.new(1, 0, 0, 18),
            BackgroundTransparency = 1
        })
        metaRow.LayoutOrder = 4

        local ageLbl = Utility:Create("TextLabel", {
            Parent = metaRow,
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            Text = tostring(LocalPlayer.AccountAge) .. " days old",
            Font = Enum.Font.GothamMedium,
            TextSize = 12,
            TextXAlignment = Enum.TextXAlignment.Left
        })
        ThemeManager:Register(ageLbl, "TextColor3", "SubText")

        -- script info box
        local infoFrame = Utility:Create("Frame", {
            Parent = scroll,
            Size = UDim2.new(1, -20, 0, 0),
            BackgroundTransparency = 0
        })
        infoFrame.LayoutOrder = 2
        ThemeManager:Register(infoFrame, "BackgroundColor3", "Section")
        Utility:Create("UICorner", {Parent = infoFrame, CornerRadius = UDim.new(0, 6)})
        ThemeManager:Register(Utility:Create("UIStroke", {Parent = infoFrame, Thickness = 1, Color = ThemeManager.Themes.Default.Border, Transparency = 0.5}), "Color", "Border")

        local infoLayout = Utility:Create("UIListLayout", {
            Parent = infoFrame,
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 10)
        })
        Utility:Create("UIPadding", {
            Parent = infoFrame,
            PaddingTop = UDim.new(0, 14),
            PaddingBottom = UDim.new(0, 14),
            PaddingLeft = UDim.new(0, 14),
            PaddingRight = UDim.new(0, 14)
        })

        local infoTitle = Utility:Create("TextLabel", {
            Parent = infoFrame,
            Size = UDim2.new(1, 0, 0, 24),
            BackgroundTransparency = 1,
            Text = "REN UI",
            Font = Enum.Font.GothamBold,
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left
        })
        ThemeManager:Register(infoTitle, "TextColor3", "Text")
        infoTitle.LayoutOrder = 1

        local infoDivider = Utility:Create("Frame", {
            Parent = infoFrame,
            Size = UDim2.new(1, 0, 0, 1),
            BackgroundTransparency = 0.5,
            BorderSizePixel = 0
        })
        ThemeManager:Register(infoDivider, "BackgroundColor3", "Border")
        infoDivider.LayoutOrder = 2

        local scriptInfoBox = Utility:Create("TextBox", {
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
        ThemeManager:Register(scriptInfoBox, "BackgroundColor3", "Container")
        ThemeManager:Register(scriptInfoBox, "TextColor3", "SubText")
        Utility:Create("UICorner", {Parent = scriptInfoBox, CornerRadius = UDim.new(0, 6)})
        ThemeManager:Register(Utility:Create("UIStroke", {Parent = scriptInfoBox, Thickness = 1, Color = ThemeManager.Themes.Default.Border, Transparency = 0.5}), "Color", "Border")
        Utility:Create("UIPadding", {Parent = scriptInfoBox, PaddingTop = UDim.new(0, 8), PaddingBottom = UDim.new(0, 8), PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8)})

        windowObj._scriptInfoBox = scriptInfoBox

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
            local canvasGroup = Utility:Create("CanvasGroup", {
                Parent = hiddenContainer,
                Size = UDim2.new(1, 0, 1, 0),
                BackgroundColor3 = ThemeManager.Themes.Default.Background,
                GroupTransparency = 0
            })
            ThemeManager:Register(canvasGroup, "BackgroundColor3", "Background")
            local scroll = Utility:Create("ScrollingFrame", {
                Parent = canvasGroup,
                Size = UDim2.new(1, 0, 1, 0),
                BackgroundColor3 = ThemeManager.Themes.Default.Background,
                BackgroundTransparency = 0,
                ScrollBarThickness = 0,
                CanvasSize = UDim2.new(0, 0, 0, 0)
            })
            ThemeManager:Register(scroll, "BackgroundColor3", "Background")
            ThemeManager:Register(scroll, "ScrollBarImageColor3", "Accent")
        
        local layout = Utility:Create("UIListLayout", {
            Parent = scroll,
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 10),
            HorizontalAlignment = Enum.HorizontalAlignment.Center
        })
        Utility:Create("UIPadding", {Parent = scroll, PaddingTop = UDim.new(0, 6), PaddingBottom = UDim.new(0, 20)})
        
        -- current server
        local curFrame = Utility:Create("Frame", {
            Parent = scroll,
            Size = UDim2.new(1, -20, 0, 0),
            BackgroundTransparency = 0
        })
        ThemeManager:Register(curFrame, "BackgroundColor3", "Section")
        Utility:Create("UICorner", {Parent = curFrame, CornerRadius = UDim.new(0, 6)})
        ThemeManager:Register(Utility:Create("UIStroke", {Parent = curFrame, Thickness = 1, Color = ThemeManager.Themes.Default.Border, Transparency = 0.5}), "Color", "Border")
        
        local curLayout = Utility:Create("UIListLayout", {
            Parent = curFrame,
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 8)
        })
        Utility:Create("UIPadding", {
            Parent = curFrame, PaddingTop = UDim.new(0, 14), PaddingBottom = UDim.new(0, 14),
            PaddingLeft = UDim.new(0, 14), PaddingRight = UDim.new(0, 14)
        })
        
        local curTitle = Utility:Create("TextLabel", {
            Parent = curFrame, Size = UDim2.new(1, 0, 0, 24), BackgroundTransparency = 1,
            Text = "Current Server", Font = Enum.Font.GothamBold, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left
        })
        ThemeManager:Register(curTitle, "TextColor3", "Text")
        
        local jobIdLbl = Utility:Create("TextLabel", {
            Parent = curFrame, Size = UDim2.new(1, 0, 0, 16), BackgroundTransparency = 1,
            Text = "Job ID: " .. game.JobId, Font = Enum.Font.GothamMedium, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left
        })
        ThemeManager:Register(jobIdLbl, "TextColor3", "SubText")
        
        local placeIdLbl = Utility:Create("TextLabel", {
            Parent = curFrame, Size = UDim2.new(1, 0, 0, 16), BackgroundTransparency = 1,
            Text = "Place ID: " .. game.PlaceId, Font = Enum.Font.GothamMedium, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left
        })
        ThemeManager:Register(placeIdLbl, "TextColor3", "SubText")
        
        local playerCountLbl = Utility:Create("TextLabel", {
            Parent = curFrame, Size = UDim2.new(1, 0, 0, 16), BackgroundTransparency = 1,
            Text = "Players: " .. #Players:GetPlayers() .. " / " .. Players.MaxPlayers,
            Font = Enum.Font.GothamMedium, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left
        })
        ThemeManager:Register(playerCountLbl, "TextColor3", "SubText")
        
        -- server browser
        local browserFrame = Utility:Create("Frame", {
            Parent = scroll,
            Size = UDim2.new(1, -20, 0, 0),
            BackgroundTransparency = 0
        })
        ThemeManager:Register(browserFrame, "BackgroundColor3", "Section")
        Utility:Create("UICorner", {Parent = browserFrame, CornerRadius = UDim.new(0, 6)})
        ThemeManager:Register(Utility:Create("UIStroke", {Parent = browserFrame, Thickness = 1, Color = ThemeManager.Themes.Default.Border, Transparency = 0.5}), "Color", "Border")
        
        local browserLayout = Utility:Create("UIListLayout", {
            Parent = browserFrame,
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 8)
        })
        Utility:Create("UIPadding", {
            Parent = browserFrame, PaddingTop = UDim.new(0, 14), PaddingBottom = UDim.new(0, 14),
            PaddingLeft = UDim.new(0, 14), PaddingRight = UDim.new(0, 14)
        })
        
        local browserTitle = Utility:Create("TextLabel", {
            Parent = browserFrame, Size = UDim2.new(1, 0, 0, 24), BackgroundTransparency = 1,
            Text = "Server Browser", Font = Enum.Font.GothamBold, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left
        })
        ThemeManager:Register(browserTitle, "TextColor3", "Text")
        
        -- Search bar
        local searchBox = Utility:Create("TextBox", {
            Parent = browserFrame, Size = UDim2.new(1, 0, 0, 28), BackgroundTransparency = 0,
            Text = "", Font = Enum.Font.GothamMedium, TextSize = 12,
            PlaceholderText = "Search Server ID...",
            ClearTextOnFocus = false, TextXAlignment = Enum.TextXAlignment.Left
        })
        ThemeManager:Register(searchBox, "BackgroundColor3", "Container")
        ThemeManager:Register(searchBox, "TextColor3", "SubText")
        Utility:Create("UICorner", {Parent = searchBox, CornerRadius = UDim.new(0, 6)})
        ThemeManager:Register(Utility:Create("UIStroke", {Parent = searchBox, Thickness = 1, Color = ThemeManager.Themes.Default.Border, Transparency = 0.5}), "Color", "Border")
        
        -- rejoin + hop next to each other
        local btnRow = Utility:Create("Frame", {
            Parent = browserFrame, Size = UDim2.new(1, 0, 0, 28), BackgroundTransparency = 1
        })
        local btnRowLayout = Utility:Create("UIListLayout", {
            Parent = btnRow, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 8), FillDirection = Enum.FillDirection.Horizontal, HorizontalAlignment = Enum.HorizontalAlignment.Center
        })
        
        local rejoinBtn = Utility:Create("TextButton", {
            Parent = btnRow, Size = UDim2.new(0.5, -4, 1, 0), Text = "Rejoin",
            Font = Enum.Font.GothamSemibold, TextSize = 13, AutoButtonColor = false
        })
        ThemeManager:Register(rejoinBtn, "BackgroundColor3", "Container")
        ThemeManager:Register(rejoinBtn, "TextColor3", "Text")
        Utility:Create("UICorner", {Parent = rejoinBtn, CornerRadius = UDim.new(0, 6)})
        local rejoinStroke = Utility:Create("UIStroke", {Parent = rejoinBtn, Thickness = 1, Color = ThemeManager.Themes.Default.Border, Transparency = 0.5})
        ThemeManager:Register(rejoinStroke, "Color", "Border")
        
        local hopBtn = Utility:Create("TextButton", {
            Parent = btnRow, Size = UDim2.new(0.5, -4, 1, 0), Text = "Server Hop",
            Font = Enum.Font.GothamSemibold, TextSize = 13, AutoButtonColor = false
        })
        ThemeManager:Register(hopBtn, "BackgroundColor3", "Container")
        ThemeManager:Register(hopBtn, "TextColor3", "Text")
        Utility:Create("UICorner", {Parent = hopBtn, CornerRadius = UDim.new(0, 6)})
        local hopStroke = Utility:Create("UIStroke", {Parent = hopBtn, Thickness = 1, Color = ThemeManager.Themes.Default.Border, Transparency = 0.5})
        ThemeManager:Register(hopStroke, "Color", "Border")
        
        -- hover for those btns
        local function setupBtnHover(btn, stroke)
            Library.Janitor:Add(btn.MouseEnter:Connect(function()
                btn.BackgroundColor3 = ThemeManager.Themes.Default.Hover
                Animator:Tween(stroke, {Transparency = 0}, 0.2)
            end))
            Library.Janitor:Add(btn.MouseLeave:Connect(function()
                btn.BackgroundColor3 = ThemeManager.Themes.Default.Container
                Animator:Tween(stroke, {Transparency = 0.5}, 0.2)
            end))
            Library.Janitor:Add(btn.MouseButton1Down:Connect(function()
                btn.BackgroundColor3 = ThemeManager.Themes.Default.Click
            end))
            Library.Janitor:Add(btn.MouseButton1Up:Connect(function()
                btn.BackgroundColor3 = ThemeManager.Themes.Default.Hover
            end))
        end
        setupBtnHover(rejoinBtn, rejoinStroke)
        setupBtnHover(hopBtn, hopStroke)
        
        Library.Janitor:Add(rejoinBtn.MouseButton1Click:Connect(function()
            TeleportService:Teleport(game.PlaceId, LocalPlayer)
        end))
        Library.Janitor:Add(hopBtn.MouseButton1Click:Connect(function()
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
                    NotificationManager:Notify("Server Hop", "No other servers found.", 3)
                end
            else
                NotificationManager:Notify("Server Hop", "Could not fetch servers.", 3)
            end
        end))
        
        -- sort + refresh row
        local sortOrder = "Desc"
        local sortRow = Utility:Create("Frame", {
            Parent = browserFrame, Size = UDim2.new(1, 0, 0, 28), BackgroundTransparency = 1
        })

        local sortDropdown = Utility:Create("TextButton", {
            Parent = sortRow, Size = UDim2.new(1, -80, 1, 0), Position = UDim2.new(0, 0, 0, 0),
            Text = "  Sort: Players ↓", Font = Enum.Font.GothamMedium, TextSize = 12,
            TextXAlignment = Enum.TextXAlignment.Left, AutoButtonColor = false
        })
        ThemeManager:Register(sortDropdown, "BackgroundColor3", "Container")
        ThemeManager:Register(sortDropdown, "TextColor3", "Text")
        Utility:Create("UICorner", {Parent = sortDropdown, CornerRadius = UDim.new(0, 6)})
        local sortStroke = Utility:Create("UIStroke", {Parent = sortDropdown, Thickness = 1, Color = ThemeManager.Themes.Default.Border, Transparency = 0.5})
        ThemeManager:Register(sortStroke, "Color", "Border")
        setupBtnHover(sortDropdown, sortStroke)

        local refreshBtn = Utility:Create("TextButton", {
            Parent = sortRow, Size = UDim2.new(0, 72, 1, 0), Position = UDim2.new(1, -72, 0, 0),
            Text = "Refresh", Font = Enum.Font.GothamSemibold, TextSize = 13,
            AutoButtonColor = false
        })
        ThemeManager:Register(refreshBtn, "BackgroundColor3", "Container")
        ThemeManager:Register(refreshBtn, "TextColor3", "Text")
        Utility:Create("UICorner", {Parent = refreshBtn, CornerRadius = UDim.new(0, 6)})
        local refreshStroke = Utility:Create("UIStroke", {Parent = refreshBtn, Thickness = 1, Color = ThemeManager.Themes.Default.Border, Transparency = 0.5})
        ThemeManager:Register(refreshStroke, "Color", "Border")
        setupBtnHover(refreshBtn, refreshStroke)

        -- the actual list
        local serverListFrame = Utility:Create("ScrollingFrame", {
            Parent = browserFrame, Size = UDim2.new(1, 0, 0, 200), BackgroundTransparency = 0,
            ScrollBarThickness = 0, CanvasSize = UDim2.new(0, 0, 0, 0), BorderSizePixel = 0
        })
        ThemeManager:Register(serverListFrame, "BackgroundColor3", "Background")
        ThemeManager:Register(serverListFrame, "ScrollBarImageColor3", "Accent")
        Utility:Create("UICorner", {Parent = serverListFrame, CornerRadius = UDim.new(0, 6)})
        ThemeManager:Register(Utility:Create("UIStroke", {Parent = serverListFrame, Thickness = 1, Color = ThemeManager.Themes.Default.Border, Transparency = 0.5}), "Color", "Border")
        Utility:Create("UIPadding", {Parent = serverListFrame, PaddingTop = UDim.new(0, 4), PaddingBottom = UDim.new(0, 4), PaddingLeft = UDim.new(0, 4), PaddingRight = UDim.new(0, 4)})

        local serverListLayout = Utility:Create("UIListLayout", {
            Parent = serverListFrame, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 4)
        })

        -- grab servers and fill the list
        local function RefreshServers()
            for _, child in ipairs(serverListFrame:GetChildren()) do
                if child:IsA("Frame") or child:IsA("TextLabel") then child:Destroy() end
            end
            local loadingLbl2 = Utility:Create("TextLabel", {
                Parent = serverListFrame, Size = UDim2.new(1, -8, 0, 28), BackgroundTransparency = 1,
                Text = "Loading servers...", Font = Enum.Font.GothamMedium, TextSize = 12,
                TextXAlignment = Enum.TextXAlignment.Left
            })
            ThemeManager:Register(loadingLbl2, "TextColor3", "SubText")

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
                    if query ~= "" and not server.id:lower():find(query, 1, true) then
                        continue
                    end
                    local isCurrent = server.id == game.JobId
                    local entry = Utility:Create("Frame", {
                        Parent = serverListFrame, Size = UDim2.new(1, -4, 0, 32), BackgroundTransparency = 0
                    })
                    ThemeManager:Register(entry, "BackgroundColor3", "Container")
                    Utility:Create("UICorner", {Parent = entry, CornerRadius = UDim.new(0, 6)})

                    if isCurrent then
                        ThemeManager:Register(Utility:Create("UIStroke", {Parent = entry, Thickness = 1, Color = ThemeManager.Themes.Default.Accent, Transparency = 0, ApplyStrokeMode = Enum.ApplyStrokeMode.Border}), "Color", "Accent")
                    end

                    local idLbl = Utility:Create("TextLabel", {
                        Parent = entry, Size = UDim2.new(0.5, -8, 1, 0), Position = UDim2.new(0, 8, 0, 0),
                        BackgroundTransparency = 1, Text = server.id or "N/A",
                        Font = Enum.Font.GothamMedium, TextSize = 11,
                        TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd
                    })
                    ThemeManager:Register(idLbl, "TextColor3", "Text")

                    local pCount = server.playing or 0
                    local pMax = server.maxPlayers or 50
                    local pLbl = Utility:Create("TextLabel", {
                        Parent = entry, Size = UDim2.new(0.2, 0, 1, 0), Position = UDim2.new(0.5, 0, 0, 0),
                        BackgroundTransparency = 1, Text = string.format("%d/%d", pCount, pMax),
                        Font = Enum.Font.GothamMedium, TextSize = 11, TextXAlignment = Enum.TextXAlignment.Right
                    })
                    ThemeManager:Register(pLbl, "TextColor3", pCount >= pMax and "Accent" or "SubText")

                    local joinBtn = Utility:Create("TextButton", {
                        Parent = entry, Size = UDim2.new(0, 55, 0, 20), Position = UDim2.new(1, -63, 0.5, -10),
                        Text = isCurrent and "Current" or "Join",
                        Font = Enum.Font.GothamSemibold, TextSize = 11, AutoButtonColor = false
                    })
                    if isCurrent then
                        ThemeManager:Register(joinBtn, "BackgroundColor3", "Accent")
                        ThemeManager:Register(joinBtn, "TextColor3", "Background")
                    else
                        ThemeManager:Register(joinBtn, "BackgroundColor3", "Container")
                        ThemeManager:Register(joinBtn, "TextColor3", "Text")
                    end
                    Utility:Create("UICorner", {Parent = joinBtn, CornerRadius = UDim.new(0, 4)})
                    local joinStroke = Utility:Create("UIStroke", {Parent = joinBtn, Thickness = 1, Color = ThemeManager.Themes.Default.Border, Transparency = 0.5})
                    ThemeManager:Register(joinStroke, "Color", "Border")

                    if not isCurrent then
                        Library.Janitor:Add(joinBtn.MouseEnter:Connect(function()
                            Animator:Tween(joinBtn, {BackgroundColor3 = ThemeManager.Themes.Default.Hover}, 0.2)
                            Animator:Tween(joinStroke, {Transparency = 0}, 0.2)
                        end))
                        Library.Janitor:Add(joinBtn.MouseLeave:Connect(function()
                            Animator:Tween(joinBtn, {BackgroundColor3 = ThemeManager.Themes.Default.Container}, 0.2)
                            Animator:Tween(joinStroke, {Transparency = 0.5}, 0.2)
                        end))
                        Library.Janitor:Add(joinBtn.MouseButton1Click:Connect(function()
                            TeleportService:TeleportToPlaceInstance(game.PlaceId, server.id, LocalPlayer)
                        end))
                    end
                end

                if #servers == 0 then
                    local emptyText = fetchError and ("Failed: " .. tostring(fetchError):sub(1, 80)) or "No servers found."
                    local emptyLbl = Utility:Create("TextLabel", {
                        Parent = serverListFrame, Size = UDim2.new(1, -8, 0, 28), BackgroundTransparency = 1,
                        Text = emptyText, Font = Enum.Font.GothamMedium, TextSize = 12,
                        TextWrapped = true, TextXAlignment = Enum.TextXAlignment.Left
                    })
                    ThemeManager:Register(emptyLbl, "TextColor3", "SubText")
                end
                serverListFrame.CanvasSize = UDim2.new(0, 0, 0, serverListLayout.AbsoluteContentSize.Y + 8)
            end)
        end

        Library.Janitor:Add(sortDropdown.MouseButton1Click:Connect(function()
            if sortOrder == "Desc" then
                sortOrder = "Asc"
                sortDropdown.Text = "  Sort: Players ↑"
            else
                sortOrder = "Desc"
                sortDropdown.Text = "  Sort: Players ↓"
            end
            RefreshServers()
        end))

        Library.Janitor:Add(refreshBtn.MouseButton1Click:Connect(function()
            RefreshServers()
        end))
        
        Library.Janitor:Add(searchBox.FocusLost:Connect(function()
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
        ThemeManager:SetTheme("Midnight")

        -- reset toggles/sliders
        Library:ResetAll()

        -- put window back
        if windowObj.Maximized then
            windowObj.Maximized = false
        end
        if windowObj.Minimized then
            windowObj.Minimized = false
        end
        Animator:Tween(canvasGroup, {Size = windowObj.DefaultSize, Position = windowObj.DefaultPosition}, 0.4, Enum.EasingStyle.Quint)
        if shadowFrame and shadowFrame.Parent then
            Animator:Tween(shadowFrame, {Size = windowObj.DefaultSize, Position = windowObj.DefaultPosition}, 0.4, Enum.EasingStyle.Quint)
        end

        -- go home
        if windowObj.Tabs and windowObj.Tabs[1] and windowObj.Tabs[1].Select then
            windowObj.Tabs[1].Select()
        end

        -- fab back to the left
        if isMobile and fab then
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

        NotificationManager:Notify("Reset", "UI reset to default.", 3)
    end)
    local themeSec = customizeTab:CreateSection("Theme Presets")
    local presetNames = {"Midnight", "Dark", "Light", "Noir", "Forest", "Ruby", "Ocean", "Cyber", "Sunset", "PurpleHaze", "Mint", "Crimson", "Slate", "Neon", "Espresso", "Vapor", "CottonCandy", "Sunrise"}
    for _, name in ipairs(presetNames) do
        themeSec:CreateButton(name, function()
            ThemeManager:SetTheme(name)
            NotificationManager:Notify("Theme", "Switched to " .. name .. " theme.", 2)
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
            self.Janitor:Add(antiAfkConn)
        end
    end
    setAntiAfk(true)

    uiSec:CreateToggle("Anti-AFK", true, function(val)
        setAntiAfk(val)
    end)
    uiSec:CreateToggle("Enable Notifications", true, function(val)
        NotificationManager.Enabled = val
    end)
    uiSec:CreateButton("Destroy UI", function()
        Library:Unload()
    end)
    local keybindSec = settingsTab:CreateSection("Keybind")
    keybindSec:CreateButton("Toggle Keybind: RightShift", function()
        NotificationManager:Notify("Keybind", "Toggle UI with Right Shift.", 3)
    end)
    
    -- for SetScriptInfo
    function windowObj:SetScriptInfo(text)
        if windowObj._scriptInfoBox then
            windowObj._scriptInfoBox.Text = text
        end
    end

    -- open home first
    homeTab.Select()

    return windowObj
end

return Library
