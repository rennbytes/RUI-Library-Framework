-- RUI by ren (@wtf_renn)
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

-- drag windows around by the top bar
local function drag(topbar, window)
    local dragging, dragInput, dragStart, startPos
    
    track(topbar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = window.Position
        end
    end))
    
    track(UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
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
local savedFlags = {}
local flagCount = 0

local function nextFlag()
    flagCount = flagCount + 1
    return "__flag_" .. flagCount
end

-- main lib
local Library = {
    Windows = {},
    Unloaded = false,
    ToggleKeybind = Enum.KeyCode.RightShift,
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
    return notifs:Notify(title, desc, duration)
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
    table.clear(toggleRefresh)
    table.clear(Library.Toggles)
    table.clear(Library.Windows)
end

function Library:ResetAll()
    for _, flag in pairs(savedFlags) do
        if flag and flag.Default ~= nil and type(flag.Set) == "function" then
            flag:Set(flag.Default)
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
        nextOrder = 2,
        switching = false
    }

    track(closeBtn.MouseButton1Click:Connect(function()
        windowObj.Hidden = true
        tween(canvasGroup, {GroupTransparency = 1}, 0.3)
        tween(stroke, {Transparency = 1}, 0.3)
        local sh = shadowFrame:FindFirstChild("Shadow")
        if sh then tween(sh, {ImageTransparency = 1}, 0.3) end
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
    
    -- little floating open btn for phone
    if isMobile then
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
    
    track(UserInputService.InputBegan:Connect(function(input, processed)
        if processed then return end
        if input.KeyCode == self.ToggleKeybind then
            windowObj.Hidden = not windowObj.Hidden
            if windowObj.Hidden then
                tween(canvasGroup, {GroupTransparency = 1}, 0.3)
                tween(stroke, {Transparency = 1}, 0.3)
                local sh = shadowFrame:FindFirstChild("Shadow")
                if sh then tween(sh, {ImageTransparency = 1}, 0.3) end
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
                tween(canvasGroup, {GroupTransparency = windowObj.UserOpacity}, 0.3)
                tween(stroke, {Transparency = 0.5}, 0.3)
                local sh2 = shadowFrame:FindFirstChild("Shadow")
                if sh2 then tween(sh2, {ImageTransparency = 0.4 + 0.6 * windowObj.UserOpacity}, 0.3) end
                if not windowObj.Minimized then
                    dragBar.Visible = true
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
            Font = Enum.Font.GothamSemibold,
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
                    if compDef.Type == "Button" then
                        local btn = mk("TextButton", {
                            Parent = secFrame,
                            Size = UDim2.new(1, 0, 0, 32),
                            AutoButtonColor = false,
                            Text = compDef.Name,
                            Font = Enum.Font.GothamSemibold,
                            TextSize = 13
                        })
                        Theme:Register(btn, "BackgroundColor3", "Container")
                        Theme:Register(btn, "TextColor3", "Text")
                        mk("UICorner", {Parent = btn, CornerRadius = UDim.new(0, 6)})
                        local stroke = mk("UIStroke", {Parent = btn, Thickness = 1, Color = Theme.Themes.Default.Border, Transparency = 0.5})
                        Theme:Register(stroke, "Color", "Border")
                        
                        track(btn.MouseEnter:Connect(function()
                            tween(btn, {BackgroundColor3 = Theme.Themes.Default.Hover}, 0.2)
                            tween(stroke, {Transparency = 0}, 0.2)
                        end))
                        track(btn.MouseLeave:Connect(function()
                            tween(btn, {BackgroundColor3 = Theme.Themes.Default.Container}, 0.2)
                            tween(stroke, {Transparency = 0.5}, 0.2)
                        end))
                        track(btn.MouseButton1Down:Connect(function()
                            tween(btn, {BackgroundColor3 = Theme.Themes.Default.Click}, 0.1)
                        end))
                        track(btn.MouseButton1Up:Connect(function()
                            tween(btn, {BackgroundColor3 = Theme.Themes.Default.Hover}, 0.1)
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

                         local state = compDef.Default or false
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
                          table.insert(Library.Toggles, updateState)
                          table.insert(toggleRefresh, updateState)

                         local function toggle()
                             state = not state
                             updateState(true)
                             tween(indicator, {Size = UDim2.new(0, indSize + 4, 0, indSize + 4)}, 0.08, Enum.EasingStyle.Quad)
                             task.delay(0.08, function()
                                 tween(indicator, {Size = UDim2.new(0, indSize, 0, indSize)}, 0.18, Enum.EasingStyle.Back)
                             end)
                          Library:SafeCallback(compDef.Callback, state)
                              if compDef.Flag and savedFlags[compDef.Flag] then
                                  savedFlags[compDef.Flag].Value = state
                              end
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
                        local value = compDef.Default or compDef.Min
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
                            if compDef.Flag and savedFlags[compDef.Flag] then
                                savedFlags[compDef.Flag].Value = value
                            end
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
                            Text = " " .. tostring(compDef.Default or "Select..."),
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
                            Text = "▼",
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
                        local dValue = compDef.Default
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
                                Text = "✓",
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
                                if compDef.Flag and savedFlags[compDef.Flag] then
                                    savedFlags[compDef.Flag].Value = dValue
                                end

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
                if not flagName then flagName = nextFlag() end
                table.insert(secDef.Components, {Type = "Toggle", Name = tglName, Default = default, Callback = callback, Flag = flagName})
            end

            function secMethods:CreateSlider(sldName, min, max, default, callback, flagName)
                if not flagName then flagName = nextFlag() end
                table.insert(secDef.Components, {Type = "Slider", Name = sldName, Min = min, Max = max, Default = default, Callback = callback, Flag = flagName})
            end

            function secMethods:CreateDropdown(dpName, items, default, callback, flagName)
                if not flagName then flagName = nextFlag() end
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
            Font = Enum.Font.GothamSemibold, TextSize = 13, AutoButtonColor = false
        })
        Theme:Register(rejoinBtn, "BackgroundColor3", "Container")
        Theme:Register(rejoinBtn, "TextColor3", "Text")
        mk("UICorner", {Parent = rejoinBtn, CornerRadius = UDim.new(0, 6)})
        local rejoinStroke = mk("UIStroke", {Parent = rejoinBtn, Thickness = 1, Color = Theme.Themes.Default.Border, Transparency = 0.5})
        Theme:Register(rejoinStroke, "Color", "Border")
        
        local hopBtn = mk("TextButton", {
            Parent = btnRow, Size = UDim2.new(0.5, -4, 1, 0), Text = "Server Hop",
            Font = Enum.Font.GothamSemibold, TextSize = 13, AutoButtonColor = false
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
            Text = "  Sort: Players ↓", Font = Enum.Font.GothamMedium, TextSize = 12,
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
            Text = "Refresh", Font = Enum.Font.GothamSemibold, TextSize = 13,
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
                        Font = Enum.Font.GothamSemibold, TextSize = 11, AutoButtonColor = false
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
                sortDropdown.Text = "  Sort: Players ↑"
            else
                sortOrder = "Desc"
                sortDropdown.Text = "  Sort: Players ↓"
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
    uiSec:CreateButton("Destroy UI", function()
        Library:Unload()
    end)
    local keybindSec = settingsTab:CreateSection("Keybind")
    keybindSec:CreateButton("Toggle Keybind: RightShift", function()
        notifs:Notify("Keybind", "Toggle UI with Right Shift.", 3)
    end)
    
    -- for SetScriptInfo
    function windowObj:SetScriptInfo(text)
        if windowObj.infoBox then
            windowObj.infoBox.Text = text
        end
    end

    -- open home first
    homeTab.Select()

    return windowObj
end

return Library
