--[==[
===============================================================================
 RUI - LIBRARY GUIDE (read this first, human or agent)
===============================================================================

 RUI is a single-file Roblox UI library. No dependencies, everything is built
 with Instance.new. Load it from a local file, then talk to it through the
 tables it hands back.

 1) LOAD
 --------------------------------------------------------------------------
 local RUI = loadstring(readfile("rui.lua"))()
 -- the lib also sets _G.RUI and getgenv().RUI, so a second script can reuse it
 local RUI = _G.RUI or loadstring(readfile("rui.lua"))()

 2) CREATE A WINDOW
 --------------------------------------------------------------------------
 local Win = RUI:CreateWindow({
     Title = "My Script",                -- top bar text, default "RUI"
     Size = UDim2.new(0, 600, 0, 400),   -- optional, phones get smaller defaults
     Resizable = true,                   -- default true, bottom-right grip
     Config = "MySetup",                 -- optional config to auto-load on start
     KeySystem = { ... },                -- optional key gate, see section 10
 })

 Four tabs always exist and are pinned by layout order:
     Home (1) | Servers (100) | Customize (101) | Settings (102)
 Your own tabs fill the gap between Home and Servers (orders start at 10)
 unless you pass an explicit layoutOrder to CreateTab.

 3) TABS
 --------------------------------------------------------------------------
 local Tab = Win:CreateTab("Aimbot")            -- order 10, 11, 12...
 local Tab = Win:CreateTab("Aimbot", 5)         -- explicit order
 local Tab = Win:CreateTab("Raw", nil, function(tabObj, container) ... end)

 Tabs are LAZY. CreateSection only records definitions; the real Instances
 appear the first time that tab is opened. So never try to grab instances
 right after creating a tab, and don't expect callbacks to fire before then.

 4) SECTIONS AND ELEMENTS
 --------------------------------------------------------------------------
 local Sec = Tab:CreateSection("Main")

 Sec:CreateButton(name, callback[, variant])   -- nil/"Default", "Accent", "Danger"
 Sec:CreateLabel(title[, description])
 Sec:CreateDivider()
 Sec:CreateToggle(name, default, callback[, flagName])
 Sec:CreateSlider(name, min, max, default, callback[, flagName])
 Sec:CreateDropdown(name, itemsTable, default, callback[, flagName])
 Sec:CreateInput(name, default, placeholder, callback[, flagName])
 Sec:CreateKeybind(name, Enum.KeyCode.X, callback[, flagName])

 Callbacks receive the new value:
     toggle -> boolean   slider -> number   dropdown -> string
     input  -> string    keybind -> Enum.KeyCode
 They are wrapped in pcall/spawn, so an error in one won't kill the UI.
 Set RUI.Debug = true to see those errors as notifications.

 Create* returns a handle for stateful elements: handle:Get() / handle:Set(value).

 5) FLAGS AND CONFIGS
 --------------------------------------------------------------------------
 Every stateful element gets a flag automatically; that is what configs save.
 Auto names are positional, so pass your own flag to keep a config stable
 when you reorder things:
     Sec:CreateToggle("ESP", false, cb, "esp.enabled")

     RUI:SaveConfig("main")
     RUI:LoadConfig("main")
     RUI:DeleteConfig("main")
     RUI:GetConfigs()      -- array of names
     RUI:ResetAll()        -- every flag back to its default

 Files go to RUI/Configs/<name>.cfg through the executor filesystem
 (the contents are JSON).

 6) THEMES
 --------------------------------------------------------------------------
     RUI:GetThemes()       -> {"Dark","Light","Midnight","Forest","Ruby","Ocean"}
     RUI:GetCurrentTheme() -> name string (default "Midnight")
     RUI:SetTheme("Ruby")  -> name on success, false if unknown
     RUI:AddTheme("Mine", { Accent = Color3.fromRGB(0,255,170) })

 AddTheme merges over the current theme, so a partial table is fine. It only
 accepts Color3 values and rejects the name "Default".
 Keys: Background, Container, Section, Border, Accent, Text, SubText, Hover,
       Click, Notification, Shadow.

 7) NOTIFICATIONS
 --------------------------------------------------------------------------
 RUI:Notify(title, description[, seconds])   -- default 5s
 Up to 3 on screen, the rest queue automatically.

 8) MODALS
 --------------------------------------------------------------------------
 RUI:Alert(title, content)
 RUI:Confirm(title, content, function() end)
 RUI:Modal({
     Title = "...", Content = "...",
     Confirm = "Yes", Cancel = "No",    -- Cancel is optional
     Danger = true,                     -- red confirm button
     OnConfirm = function() end
 })
 Clicking outside the card cancels. There is no OnCancel callback.

 9) WINDOW METHODS AND FIELDS
 --------------------------------------------------------------------------
     Win:SetTitle("New")        Win:Toggle()          -- show/hide
     Win:Lock()                 Win:Unlock()          -- freeze close/drag/min/max/escape
     Win:SelectTab("Name")      -- returns true/false
     Win:SetKeybind(Enum.KeyCode.RightShift)
     Win:SetScriptInfo(text)    -- body text shown on the Home tab
     Win:CollectConfig()        -- {Tab, Size={w,h}, Pos={x,y}}
     Win:ApplyConfig(data)      -- apply a CollectConfig snapshot

 Fields you can read/write:
     Win.Tabs, Win.CurrentTab, Win.Hidden, Win.Minimized, Win.Maximized,
     Win.Locked, Win.Keybind, Win.UserOpacity  (0 = opaque, 1 = invisible)

     RUI:GetWindow()   -- first window
     RUI.Windows       -- every window ever made
     RUI:Unload()      -- destroy all GUIs and connections

 10) KEY SYSTEM (optional)
 --------------------------------------------------------------------------
 Register a service BEFORE CreateWindow:

     RUI.Services.demo = {                   -- or RUI:RegisterService("demo", def)
         Name = "Demo",
         New = function()
             return {
                 Verify = function(key)
                     if key == "letmein" then
                         getgenv().SCRIPT_KEY = key    -- your script waits on this
                         return true, "Key valid"      -- passed, message
                     end
                     return false, "Wrong key"         -- failed, message
                 end,
                 Copy = function() return "https://example.com/key" end
             }
         end
     }

 then:

     KeySystem = {
         Title = "My Key System",            -- defaults to the window Title
         Note = "Grab a key from the link.", -- optional body text
         SaveKey = true,                     -- default true, saves to RUI/key.txt
         API = {
             { Title = "Demo", Desc = "Click to copy link", Type = "demo" }
         }
     }

 The gate blocks ALL input (movement, window keybinds, other UI) until a key
 passes. It tries every API entry in order, auto-fills a saved key, and closes
 on success. Only entries whose Type is registered are listed. With 2+ entries
 it becomes a dropdown; with 1 it is a copy button.

 To make the rest of your script wait:
     while not RUI:HasKey() do task.wait(0.1) end
 HasKey only checks getgenv().SCRIPT_KEY, so your Verify must set it.

 11) GOTCHAS
 --------------------------------------------------------------------------
 - Lazy tabs: elements exist only after the tab is first opened.
 - Create* returns a handle with Get/Set for toggles, sliders, dropdowns, inputs and keybinds.
 - Callback errors are swallowed unless RUI.Debug = true.
 - The floating FAB is touch-device only. Tap toggles the UI. It is draggable
   and its position persists in RUI/fab.cfg.
 - RightShift toggles the window, Escape hides it, both respect Lock.
 - Custom tabs must set tabObj.ContentRoot to a CanvasGroup, otherwise the
   tab can never be shown.
 - AddTheme keys are Color3 only; partial tables are merged.
 - The key gate owns the screen for its window. One window, one gate; don't
   stack a second gate on top unless the first one has closed.

 12) MINIMAL BOILERPLATE
 --------------------------------------------------------------------------
 local RUI = loadstring(readfile("rui.lua"))()
 local W = RUI:CreateWindow({ Title = "My Script" })
 local S = W:CreateTab("Main"):CreateSection("Main")
 S:CreateToggle("Enabled", false, function(v) print(v) end, "enabled")
 S:CreateButton("Run", function() print("ran") end, "Accent")
===============================================================================
]==]

-- RUI demo - exercises every bit of the lib so u can see whats broken
-- run it in an executor with rui.lua saved next to it. everything here is a
-- no-op unless u click it, so its safe to poke around in a live game. nothing
-- gets written to disk til u hit save on the configs tab.

-- local file only, no url: the cached raw github build lags way behind the
-- real file, so testing off a path keeps this on whatever u just saved
local RUI_PATH = "rui.lua"
local RUI = nil
if isfile and readfile then
    pcall(function()
        if isfile(RUI_PATH) then
            RUI = loadstring(readfile(RUI_PATH))()
        end
    end)
end
if not RUI then
    error("[demo] cant read " .. RUI_PATH .. ", put it in ur executor workspace", 0)
end

-- the lib also drops itself into _G and getgenv as RUI, so this line is optional
assert(RUI ~= nil, "rui.lua failed to load")

-- published build doesnt have Onboarding yet. keep the demo usable against
-- older copies by chaining plain modals until the repo catches up. the old
-- modal has no back button, so pages are one way on that fallback.
if type(RUI.Onboarding) ~= "function" then
    RUI.Onboarding = function(_, title, pages, onFinish)
        local function show(i)
            if i > #pages then
                if onFinish then pcall(onFinish) end
                return
            end
            local p = pages[i] or {}
            local lines = {p.Content}
            if type(p.Bullets) == "table" then
                for _, b in ipairs(p.Bullets) do
                    table.insert(lines, "- " .. tostring(b))
                end
            end
            if p.Footer then
                table.insert(lines, p.Footer)
            end
            RUI:Modal({
                Title = p.Title or title or "Welcome",
                Content = table.concat(lines, "\n"),
                Confirm = i == #pages and "Done" or "Next",
                OnConfirm = function()
                    show(i + 1)
                end
            })
        end
        show(1)
    end
end

-- errors used to vanish, this makes em pop up so u can see em
RUI.Debug = true

-- ============ key system ============
-- flip this to true to try the key gate. the fake service below accepts
-- "letmein", sets getgenv().SCRIPT_KEY, and the gate closes. the rest of this
-- demo does not wait on the key, so u can see the gate without losing the ui.
local USE_KEY_GATE = false

-- services have to be registered before CreateWindow because the gate only
-- lists entries whose Type exists at build time
RUI.Services.demo = {
    Name = "Demo",
    New = function()
        return {
            Verify = function(key)
                if key == "letmein" then
                    getgenv().SCRIPT_KEY = key
                    return true, "Key valid"
                end
                return false, "Wrong key, try letmein"
            end,
            Copy = function()
                return "https://example.com/get-key"
            end
        }
    end
}

-- ============ window ============
-- every option rui reads, all at once
local Window = RUI:CreateWindow({
    Title = "RUI Demo",
    Size = UDim2.new(0, 620, 0, 440),

    -- bottom right corner grip, defaults to true anyway
    Resizable = true,

    -- drop a name in here and it loads that config on startup
    -- Config = "Demo",

    -- the optional key gate. off by default so the demo opens instantly
    KeySystem = USE_KEY_GATE and {
        Title = "RUI Key System",
        Note = "Demo gate. The key is letmein.",
        SaveKey = true,
        API = {
            { Title = "Demo", Desc = "Click to copy link", Type = "demo" }
        }
    } or nil,
})

-- a bit of info on the home tab
Window:SetScriptInfo(
    "RUI Demo\n\n" ..
    "Every element type, every library method, the themes, the config system, " ..
    "modals, custom tabs and the key gate.\n\n" ..
    "Tabs are lazy - a tab is only built the first time u open it, so if " ..
    "something looks empty just click the tab and give it a sec.\n\n" ..
    "Guide tab = the cheat sheet. Elements tab = every Create* call."
)

-- ============ guide tab ============
-- a condensed cheat sheet in the ui. the long version is the comment block at
-- the top of this file, which is what an agent should read first.
local guide = Window:CreateTab("Guide", nil, nil, "file-text")

local loadSec = guide:CreateSection("Load", "download")
loadSec:CreateLabel('RUI = loadstring(readfile("rui.lua"))()')
loadSec:CreateLabel("Reuse: _G.RUI or getgenv().RUI")
loadSec:CreateLabel("RUI.Debug = true", "callback errors become notifications")

local winGuide = guide:CreateSection("Window", "monitor")
winGuide:CreateLabel("RUI:CreateWindow({ Title, Size, Resizable, Config, KeySystem })")
winGuide:CreateLabel("Win:CreateTab(name[, order[, customBuild]])")
winGuide:CreateLabel("Pinned: Home 1, Servers 100, Customize 101, Settings 102")
winGuide:CreateLabel("Your tabs start at order 10 (between Home and Servers)")

local elGuide = guide:CreateSection("Elements", "boxes")
elGuide:CreateLabel("Sec:CreateButton(name, cb[, 'Accent' | 'Danger'])")
elGuide:CreateLabel("Sec:CreateLabel(title[, desc])   Sec:CreateDivider()")
elGuide:CreateLabel("Sec:CreateToggle(name, default, cb[, flag])")
elGuide:CreateLabel("Sec:CreateSlider(name, min, max, default, cb[, flag])")
elGuide:CreateLabel("Sec:CreateDropdown(name, items, default, cb[, flag])")
elGuide:CreateLabel("Sec:CreateInput(name, default, placeholder, cb[, flag])")
elGuide:CreateLabel("Sec:CreateKeybind(name, Enum.KeyCode.X, cb[, flag])")
elGuide:CreateLabel("Create* returns a handle", "handle:Get() / handle:Set(value)", "star")

local libGuide = guide:CreateSection("Library", "library")
libGuide:CreateLabel("RUI:Notify(title, desc[, seconds])")
libGuide:CreateLabel("Notify{..., Icon = name}", "any of the 316 names", "bell")
libGuide:CreateLabel("RUI:Modal{Icon, ConfirmIcon, CancelIcon}", "dialog icons", "info")
libGuide:CreateLabel("RUI:Alert / Confirm / Modal")
libGuide:CreateLabel("RUI:SetTheme / GetThemes / GetCurrentTheme / AddTheme")
libGuide:CreateLabel("RUI:SaveConfig / LoadConfig / DeleteConfig / GetConfigs")
libGuide:CreateLabel("RUI:ResetAll() / Unload() / GetWindow() / HasKey()")
libGuide:CreateLabel("RUI:WaitForKey(timeout)", "0 = check once and return bool", "timer")
libGuide:CreateLabel("RUI:GetIcons() / GetIcon(name)", "311 lucide names, sorted", "image")
libGuide:CreateLabel("RUI:SetIcon(name, id) / AddIcons{}", "swap any icon id at runtime", "wand-sparkles")
libGuide:CreateLabel("CreateX(..., iconName)", "all elements take a trailing icon", "sparkles")
libGuide:CreateLabel("RUI:Modal{Icon, ...Icon}", "icons on dialogs and onboarding pages", "info")

local ruleSec = guide:CreateSection("Rules", "shield-check")
ruleSec:CreateLabel("Tabs build on first open", "lazy, dont poke instances early")
ruleSec:CreateLabel("Pass a flag if configs matter", "auto flags are positional")
ruleSec:CreateLabel("Callbacks run through pcall", "RUI.Debug shows the errors")
ruleSec:CreateLabel("FAB is touch-only", "tap toggles, drag moves, position saved")
ruleSec:CreateLabel("RightShift toggles, Escape hides")
ruleSec:CreateLabel("Custom tabs need a CanvasGroup", "tabObj.ContentRoot = canvas")

-- ============ elements ============
local el = Window:CreateTab("Elements", nil, nil, "list")

local basics = el:CreateSection("Buttons", "bolt")
basics:CreateLabel("Button Variants", "three flavours, hover em", "info")
basics:CreateButton("Default", function()
    RUI:Notify("Button", "Default button fired.", 2)
end, "Default", "star")
basics:CreateButton("Accent", function()
    RUI:Notify("Button", "Accent button fired.", 2)
end, "Accent", "check")
basics:CreateButton("Danger", function()
    RUI:Confirm("Danger button?", "This one is wired to a confirm so u can see the modal work.", function()
        RUI:Notify("Button", "Danger confirmed.", 2)
    end)
end, "Danger", "warning")

local labels = el:CreateSection("Labels", "info")
labels:CreateLabel("Just a label", "no state, nothing gets saved for these", "info")
labels:CreateDivider()
labels:CreateLabel("Another one", "dividers sit between sections", "minus")

local toggles = el:CreateSection("Toggles", "toggle-right")
local toggleState = {}
for _, name in ipairs({"Toggle A", "Toggle B", "Toggle C"}) do
    local key = name:gsub(" ", "")
    toggleState[key] = false
    -- explicit flags keep configs stable even if the order changes later
    toggles:CreateToggle(name, false, function(val)
        toggleState[key] = val
        RUI:Notify("Toggle", name .. " -> " .. tostring(val), 2)
    end, "demo.toggle." .. key, "toggle-right")
end

local sliders = el:CreateSection("Sliders", "sliders-horizontal")
local sliderState = {}
for _, def in ipairs({{"Integer", 0, 100, 50}, {"Negative", -50, 50, 0}, {"Small range", 1, 5, 1}}) do
    local name = def[1]
    sliderState[name] = def[4]
    sliders:CreateSlider(name, def[2], def[3], def[4], function(val)
        sliderState[name] = val
        RUI:Notify("Slider", name .. " -> " .. tostring(val), 2)
    end, "demo.slider." .. name:gsub(" ", ""), "sliders-horizontal")
end

local inputs = el:CreateSection("Inputs", "text")
local inputState = {}
inputs:CreateInput("Plain text", "hello", "type something", function(val)
    inputState.text = val
    RUI:Notify("Input", "text -> " .. tostring(val), 2)
end, "demo.input.text", "text")
inputs:CreateInput("Numbers only?", "123", "no actual filtering, its just a textbox", function(val)
    inputState.num = val
    RUI:Notify("Input", "num -> " .. tostring(val), 2)
end, "demo.input.num", "hash")

local drops = el:CreateSection("Dropdowns", "list")
local dropState = {}
drops:CreateDropdown("Pick one", {"Alpha", "Beta", "Gamma", "Delta"}, "Alpha", function(val)
    dropState.pick = val
    RUI:Notify("Dropdown", "pick -> " .. tostring(val), 2)
end, "demo.drop.pick", "list")
drops:CreateDropdown("Empty default", {"One", "Two", "Three"}, nil, function(val)
    dropState.empty = val
    RUI:Notify("Dropdown", "empty -> " .. tostring(val), 2)
end, "demo.drop.empty", "list")

local binds = el:CreateSection("Keybinds", "keyboard")
-- default is an Enum.KeyCode, click the box then press a key, escape cancels
local bindState = {}
binds:CreateKeybind("Demo bind", Enum.KeyCode.F5, function(key)
    bindState.bind = key
    RUI:Notify("Keybind", "demo bind -> " .. key.Name, 3)
end, "demo.bind", "keyboard")

-- ============ library api ============
local api = Window:CreateTab("API", nil, nil, "star")
local apiState = {}

local themeSec = api:CreateSection("Themes", "palette")
themeSec:CreateLabel("Theme List", "built in plus anything u add with AddTheme")
for _, name in ipairs(RUI:GetThemes()) do
    themeSec:CreateButton(name, function()
        local got = RUI:SetTheme(name)
        apiState.theme = got
        RUI:Notify("Theme", "now on " .. tostring(got), 2)
    end)
end

themeSec:CreateDivider()
themeSec:CreateButton("Add Custom Theme (Neon)", function()
    local added = RUI:AddTheme("Neon", {
        Background = Color3.fromRGB(8, 4, 24),
        Container = Color3.fromRGB(18, 8, 40),
        Section = Color3.fromRGB(13, 6, 32),
        Border = Color3.fromRGB(70, 30, 120),
        Accent = Color3.fromRGB(0, 255, 170),
        Text = Color3.fromRGB(240, 255, 250),
        SubText = Color3.fromRGB(150, 180, 175),
        Hover = Color3.fromRGB(28, 14, 56),
        Click = Color3.fromRGB(10, 4, 24),
        Notification = Color3.fromRGB(20, 10, 44),
        Shadow = Color3.new(0, 0, 0)
    })
    if added then
        RUI:SetTheme("Neon")
        RUI:Notify("Theme", "added Neon, check the themes tab", 3)
    else
        RUI:Notify("Theme", "AddTheme wanted a table", 3)
    end
end, "Accent")
themeSec:CreateButton("Add Partial Theme (only Accent)", function()
    -- partial tables merge over whatever theme is active right now
    local added = RUI:AddTheme("AccentOnly", { Accent = Color3.fromRGB(255, 120, 200) })
    if added then
        RUI:SetTheme("AccentOnly")
        RUI:Notify("Theme", "partial theme applied", 3)
    else
        RUI:Notify("Theme", "AddTheme rejected it", 3)
    end
end)
themeSec:CreateButton("Back to Midnight", function()
    RUI:SetTheme("Midnight")
    RUI:Notify("Theme", "back to Midnight", 2)
end)
themeSec:CreateButton("GetCurrentTheme", function()
    RUI:Notify("Theme", "current -> " .. tostring(RUI:GetCurrentTheme()), 2)
end)

local winSec = api:CreateSection("Window", "monitor")
winSec:CreateLabel("Window Methods", "these drive the window itself")
winSec:CreateButton("SetTitle", function()
    Window:SetTitle("RUI Demo " .. math.floor(os.clock() * 10) % 100)
end)
winSec:CreateButton("Toggle (hide/show)", function()
    Window:Toggle()
end)
winSec:CreateButton("Lock", function()
    Window:Lock()
    RUI:Notify("Window", "locked, use the Unlock button below", 3)
end)
winSec:CreateButton("Unlock", function()
    Window:Unlock()
    RUI:Notify("Window", "unlocked", 2)
end)
winSec:CreateButton("SelectTab('Elements')", function()
    local ok = Window:SelectTab("Elements")
    RUI:Notify("Window", "SelectTab returned " .. tostring(ok), 2)
end)
winSec:CreateButton("SelectTab('Nope')", function()
    local ok = Window:SelectTab("Nope")
    RUI:Notify("Window", "bad tab returned " .. tostring(ok), 2)
end)
winSec:CreateButton("SetKeybind(F6)", function()
    Window:SetKeybind(Enum.KeyCode.F6)
    RUI:Notify("Window", "toggle key is now F6", 3)
end)
winSec:CreateButton("SetKeybind(RightShift)", function()
    Window:SetKeybind(Enum.KeyCode.RightShift)
    RUI:Notify("Window", "toggle key is back on RightShift", 3)
end)

local layoutSec = api:CreateSection("Layout Snapshots", "move")
local snapshot = nil
layoutSec:CreateLabel("Collect / Apply", "saves size + position + current tab")
layoutSec:CreateButton("CollectConfig (snapshot)", function()
    snapshot = Window:CollectConfig()
    local w = snapshot.Size and snapshot.Size[1] or 0
    local h = snapshot.Size and snapshot.Size[2] or 0
    RUI:Notify("Layout", "snapshot " .. w .. " x " .. h, 3)
end)
layoutSec:CreateButton("ApplyConfig (snapshot)", function()
    if not snapshot then
        RUI:Notify("Layout", "take a snapshot first", 3)
        return
    end
    Window:ApplyConfig(snapshot)
    RUI:Notify("Layout", "snapshot applied", 2)
end, "Accent")

local libSec = api:CreateSection("Library", "library")
libSec:CreateLabel("Library Methods", "the top level ones")
libSec:CreateButton("GetCurrentTheme", function()
    RUI:Notify("Library", "theme is " .. tostring(RUI:GetCurrentTheme()), 2)
end)
libSec:CreateButton("GetWindow ~= nil", function()
    RUI:Notify("Library", RUI:GetWindow() ~= nil and "got a window" or "nil", 2)
end)
libSec:CreateButton("HasKey()", function()
    RUI:Notify("Library", "HasKey -> " .. tostring(RUI:HasKey()), 3)
end)
libSec:CreateButton("WaitForKey(0)", function()
    -- timeout of 0 means dont wait, just tell em the answer
    local ok = RUI:WaitForKey(0)
    RUI:Notify("Library", "WaitForKey(0) -> " .. tostring(ok), 3)
end)
libSec:CreateButton("Tabs in order", function()
    local names = {}
    for _, t in ipairs(Window.Tabs) do
        table.insert(names, t.Name)
    end
    RUI:Notify("Library", table.concat(names, " | "), 5)
end)
libSec:CreateButton("Registered services", function()
    local names = {}
    for name in pairs(RUI.Services) do
        table.insert(names, name)
    end
    table.sort(names)
    RUI:Notify("Library", #names > 0 and table.concat(names, ", ") or "none", 4)
end)
libSec:CreateButton("RegisterService (demo2)", function()
    local ok = RUI:RegisterService("demo2", {
        Name = "Demo2",
        New = function()
            return {
                Verify = function() return false, "always denies" end,
                Copy = function() return "https://example.com" end
            }
        end
    })
    RUI:Notify("Library", "RegisterService -> " .. tostring(ok), 2)
end)

local notifSec = api:CreateSection("Notifications", "bell")
notifSec:CreateLabel("Notify", "3 on screen max, the rest queue")
notifSec:CreateButton("One (2s)", function()
    RUI:Notify("Notify", "short one", 2, nil, false, "bell")
end)
notifSec:CreateButton("One (8s)", function()
    RUI:Notify("Notify", "long one, 8 seconds", 8, nil, false, "timer")
end)
notifSec:CreateButton("Spam 6 (queue demo)", function()
    for i = 1, 6 do
        RUI:Notify("Queue", "notification " .. i, 3)
    end
end, "Accent", "refresh-cw")
notifSec:CreateButton("Info (blue)", function()
    RUI:NotifyInfo("Info", "heads up, this ones blue.", 4, "info")
end, "Default", "info")
notifSec:CreateButton("Event (violet)", function()
    RUI:NotifyEvent("Event", "something happened in game.", 4, "sparkles")
end, "Default", "sparkles")
notifSec:CreateButton("Warning (orange)", function()
    RUI:NotifyWarning("Warning", "watch out, this ones orange.", 4, "triangle-alert")
end, "Default", "triangle-alert")
notifSec:CreateButton("Error (red)", function()
    RUI:NotifyError("Error", "something broke, this ones red.", 4, "circle-x")
end, "Default", "circle-x")
notifSec:CreateButton("Success (green)", function()
    RUI:NotifySuccess("Success", "all good, this ones green.", 4, "circle-check-big")
end, "Default", "circle-check-big")
notifSec:CreateButton("Long (wide)", function()
    RUI:NotifyLong("Long Notification", "This one uses the wide lane so a paragraph actually fits. The card grows to the wrapped text height instead of clipping it, and the timer bar still runs along the bottom. Good for patch notes or error details.", 8)
end, "Accent", "file-text")
notifSec:CreateButton("Table form", function()
    RUI:Notify({
        Title = "Table Form",
        Content = "type and long can be passed as fields too.",
        Duration = 5,
        Type = "warning",
        Long = true,
        Icon = "star"
    })
end, "Default", "file")

local modSec = api:CreateSection("Modals", "sparkles")
modSec:CreateLabel("Modals", "all three styles the lib ships with")
modSec:CreateButton("Alert", function()
    RUI:Alert("Just so u know", "This is the alert style, one button and it goes away.")
end, "Default", "info")
modSec:CreateButton("Confirm", function()
    RUI:Confirm("Are u sure?", "Yes runs the callback, Cancel or clicking outside does not.", function()
        RUI:Notify("Modal", "confirmed", 2)
    end)
end, "Default", "check")
modSec:CreateButton("Danger Confirm", function()
    RUI:Modal({
        Title = "Danger style?",
        Content = "Same modal but the confirm button is red.",
        Confirm = "Do it",
        Cancel = "Nah",
        Danger = true,
        OnConfirm = function()
            RUI:Notify("Modal", "danger confirmed", 2)
        end
    })
end, "Danger", "triangle-alert")
modSec:CreateButton("Dialog Icons", function()
    RUI:Modal({
        Title = "Icons Everywhere",
        Icon = "gift",
        Content = "header icon, confirm icon and cancel icon all set separately.",
        Confirm = "Yes",
        ConfirmIcon = "check",
        Cancel = "Nah",
        CancelIcon = "x",
        OnConfirm = function()
            RUI:Notify("Modal", "icon dialog confirmed", 2)
        end
    })
end, "Default", "gift")
modSec:CreateButton("Long text", function()
    RUI:Alert("Wrapping", "This body is a lot longer so u can see the card grow with it and keep the buttons stuck to the bottom instead of letting them drift away. Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.")
end, "Default", "file-text")
modSec:CreateButton("No outside close", function()
    RUI:Modal({
        Title = "Forced choice",
        Content = "Clicking outside will not close this one. Only the button does.",
        Confirm = "Got it",
        CloseOnClickOutside = false,
        OnConfirm = function()
            RUI:Notify("Modal", "closed via button", 2)
        end
    })
end, "Default", "lock")
modSec:CreateButton("Onboarding (3 pages)", function()
    RUI:Onboarding("Welcome to RUI", {
        {
            Title = "Script Info",
            Icon = "file-text",
            Content = "page 1 of 3. this is where u'd put the script name, version and a short pitch.",
            Bullets = {"name, version, author", "one line on what it does", "support link if u have one"},
            Footer = "use Next, Back, the arrow keys or the dots"
        },
        {
            Title = "What's New",
            Icon = "sparkles",
            Content = "page 2 of 3. changelog goes here, newest first.",
            Bullets = {"paginated dialogs and onboarding", "configs, theme api and key gate", "resize grip + open button"},
            OnEnter = function()
                print("[demo] entered the whats new page")
            end
        },
        {
            Title = "Before U Go",
            Icon = "check",
            Content = "page 3 of 3. anything u want them to read last, then Finish runs the callback.",
            Footer = "settings tab has all the switches"
        }
    }, function()
        RUI:Notify("Onboarding", "finished all 3 pages", 3)
    end)
end, "Accent", "sparkles")
modSec:CreateButton("Paged Modal (custom)", function()
    RUI:Modal({
        Title = "Custom Pages",
        Icon = "list",
        Width = 400,
        Next = "Continue",
        Finish = "Ok cool",
        Cancel = false,
        Pages = {
            {Title = "First", Icon = "info", Content = "no close button on this one, u finish it or re-exec.", Footer = "Cancel = false removes it"},
            {Title = "Second", Icon = "check", Content = "last page renames the finish button via opts.Finish."}
        },
        OnConfirm = function()
            RUI:Notify("Modal", "custom paged modal done", 2)
        end
    })
end, "Default", "list")

local unloadSec = api:CreateSection("Unload", "log-out")
unloadSec:CreateLabel("Tear down", "destroys every gui and connection the lib owns")
unloadSec:CreateButton("Unload UI", function()
    RUI:Confirm("Unload?", "Everything the lib made gets destroyed. Re-execute the demo to get it back.", function()
        RUI:Unload()
    end)
end, "Danger", "log-out")

-- ============ configs ============
local cfg = Window:CreateTab("Configs", nil, nil, "folder")
local cfgName = "Demo"

local cfgSec = cfg:CreateSection("Save / Load", "save")
cfgSec:CreateLabel("Configs", "theme, layout and every toggle goes in here. files land in RUI/Configs", "folder")
cfgSec:CreateInput("Config name", "Demo", "Demo", function(val)
    cfgName = val
end, nil, "file-text")
cfgSec:CreateButton("Save", function()
    RUI:SaveConfig(cfgName)
end, "Accent", "save")
cfgSec:CreateButton("Load", function()
    RUI:LoadConfig(cfgName)
end, "Default", "rotate-cw")
cfgSec:CreateButton("Delete", function()
    RUI:Confirm("Delete \"" .. tostring(cfgName) .. "\"?", "Gone for good.", function()
        RUI:DeleteConfig(cfgName)
    end)
end, "Danger", "trash-2")

local listSec = cfg:CreateSection("On Disk", "hard-drive")
listSec:CreateLabel("Saved Configs", "GetConfigs reads the folder every call")
listSec:CreateButton("Refresh List", function()
    local found = RUI:GetConfigs()
    RUI:Notify("Configs", #found > 0 and (#found .. " found: " .. table.concat(found, ", ")) or "none", 5)
end, "Default", "search")
listSec:CreateButton("Reset All Flags", function()
    RUI:ResetAll()
    RUI:Notify("Configs", "every toggle/slider back to default", 3)
end, "Default", "rotate-cw")

-- ============ icons ============
local iconTab = Window:CreateTab("Icons", nil, nil, "image")
local iconSec = iconTab:CreateSection("Gallery", "palette")
iconSec:CreateLabel("RUI:GetIcons()", "311 lucide names, sorted. pass one as the last arg to any CreateX.", "sparkles")
iconSec:CreateButton("Print all names", function()
    local names = RUI:GetIcons()
    print("[RUI] icons: " .. #names .. " -> " .. table.concat(names, ", "))
    RUI:Notify("Icons", #names .. " names printed to console.", 3)
end, "Accent", "list")
iconSec:CreateButton("Show an icon notification", function()
    RUI:Notify("Icons", "picked from RUI:GetIcon", 4, nil, false, "gift")
end, "Default", "gift")

local famSec = iconTab:CreateSection("Samples", "boxes")
local samples = {
    {"Home", "home"}, {"Server", "server"}, {"Settings", "settings"},
    {"Search", "search"}, {"Refresh", "refresh"}, {"Lock", "lock"},
    {"Star", "star"}, {"Trophy", "trophy"}, {"Target", "target"},
    {"Rocket", "rocket"}, {"Gift", "gift"}, {"Crown", "crown"}
}
for i = 1, #samples, 3 do
    local a = samples[i]
    local b = samples[i + 1]
    local c = samples[i + 2]
    local label = a[1] .. (b and (" / " .. b[1]) or "") .. (c and (" / " .. c[1]) or "")
    famSec:CreateLabel(label, nil, a[2])
    if b then famSec:CreateLabel(b[1], nil, b[2]) end
    if c then famSec:CreateLabel(c[1], nil, c[2]) end
end

-- ============ custom tab (raw instances) ============
-- customBuild is the escape hatch for anything the lib doesn't ship. the only
-- contract is: parent your root to `container` and set tabObj.ContentRoot to a
-- CanvasGroup (SelectTab tweens its GroupTransparency). no theme helper here,
-- so this panel uses its own colours and won't follow theme switches.
local customTab = Window:CreateTab("Custom", nil, function(tabObj, container)
    local root = Instance.new("CanvasGroup")
    root.Name = "CustomRoot"
    root.Size = UDim2.new(1, 0, 1, 0)
    root.BackgroundTransparency = 1
    root.BorderSizePixel = 0
    root.Parent = container

    local panel = Instance.new("Frame")
    panel.Name = "Panel"
    panel.Size = UDim2.new(1, -20, 0, 120)
    panel.Position = UDim2.new(0, 10, 0, 6)
    panel.BackgroundColor3 = Color3.fromRGB(14, 16, 28)
    panel.BorderSizePixel = 0
    panel.Parent = root

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = panel

    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(35, 40, 60)
    stroke.Thickness = 1
    stroke.Transparency = 0.5
    stroke.Parent = panel

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -28, 0, 22)
    title.Position = UDim2.new(0, 14, 0, 14)
    title.BackgroundTransparency = 1
    title.Text = "Raw Instances"
    title.Font = Enum.Font.GothamBold
    title.TextSize = 14
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = panel

    local desc = Instance.new("TextLabel")
    desc.Size = UDim2.new(1, -28, 0, 16)
    desc.Position = UDim2.new(0, 14, 0, 40)
    desc.BackgroundTransparency = 1
    desc.Text = "Instance.new UI parented into this tab"
    desc.Font = Enum.Font.GothamMedium
    desc.TextSize = 12
    desc.TextColor3 = Color3.fromRGB(170, 185, 210)
    desc.TextXAlignment = Enum.TextXAlignment.Left
    desc.Parent = panel

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 140, 0, 32)
    btn.Position = UDim2.new(0, 14, 0, 68)
    btn.BackgroundColor3 = Color3.fromRGB(70, 150, 255)
    btn.BorderSizePixel = 0
    btn.Text = "Click me"
    btn.Font = Enum.Font.GothamMedium
    btn.TextSize = 13
    btn.TextColor3 = Color3.fromRGB(10, 12, 22)
    btn.AutoButtonColor = false
    btn.Parent = panel

    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 6)
    btnCorner.Parent = btn

    local clicks = 0
    btn.MouseButton1Click:Connect(function()
        clicks = clicks + 1
        btn.Text = "Clicked " .. clicks
        RUI:Notify("Custom", "raw instance button fired", 2)
    end)

    tabObj.ContentRoot = root
end, "wand-sparkles")

-- ============ state dump ============
-- handles exist now but this is still a handy way to see every callback value
-- in one notification
local state = Window:CreateTab("State", nil, nil, "activity")
local stateSec = state:CreateSection("Current Values")
stateSec:CreateLabel("State Dump", "values the demo callbacks have captured")
stateSec:CreateButton("Dump Everything", function()
    local parts = {}
    for k, v in pairs(toggleState) do
        table.insert(parts, k .. "=" .. tostring(v))
    end
    for k, v in pairs(sliderState) do
        table.insert(parts, k .. "=" .. tostring(v))
    end
    for k, v in pairs(inputState) do
        table.insert(parts, k .. "=" .. tostring(v))
    end
    for k, v in pairs(dropState) do
        table.insert(parts, k .. "=" .. tostring(v))
    end
    for k, v in pairs(bindState) do
        table.insert(parts, k .. "=" .. tostring(v))
    end
    table.sort(parts)
    local dump = table.concat(parts, "   ")
    RUI:Notify("State", dump ~= "" and dump or "nothing touched yet", 8)
end, "Accent")

-- ============ quick actions: two controls, one flag ============
local quickTab = Window:CreateTab("Quick Actions", nil, nil, "zap")
local quickSec = quickTab:CreateSection("Quick Actions", "zap")
local mirrorSec = quickTab:CreateSection("Mirror", "copy")

quickSec:CreateLabel("Synced controls", "Both toggles share one flag and one callback.")

local function onQuick(value)
    RUI:Notify("Quick actions", value and "enabled" or "disabled", 2)
end

local quickMain = quickSec:CreateToggle({
    Name = "Quick actions",
    Default = false,
    Flag = "demo.quick",
    Callback = onQuick,
    Icon = "zap"
})
mirrorSec:CreateToggle({
    Name = "Mirror control",
    Default = false,
    Flag = "demo.quick",
    Callback = onQuick,
    Icon = "copy"
})
quickSec:CreateButton({
    Name = "Set via handle",
    Icon = "refresh-cw",
    Callback = function()
        quickMain:Set(not quickMain:Get())
    end
})

-- ============ hub / game dialog ============
local hubDemo = Window:CreateTab("Hub Demo", nil, nil, "layout-grid")
local hubSec = hubDemo:CreateSection("Game Dialog", "gamepad-2")
hubSec:CreateLabel("GameModal", "Artwork, script info and load/join. No preview.", "info")
hubSec:CreateButton({
    Name = "RoChess",
    Desc = "Chess tools - 130878180532794",
    Icon = "crown",
    Callback = function()
        RUI:GameModal({
            Title = "RoChess",
            Name = "RoChess",
            Desc = "Play real players online. Ranked & free to play.",
            Info = "Play real players online. Bullet, Blitz and Rapid, ranked and free to play.",
            Icon = "crown",
            Image = "https://tr.rbxcdn.com/180DAY-ea2a118d31f4d70a43d63774e60c2e40/768/432/Image/Webp/noFilter",
            ScriptTitle = "RoChess - Move Overlay + Auto Play",
            Creator = "RoChess",
            PlaceId = 130878180532794,
            Url = "https://gist.githubusercontent.com/rennbytes/856bccd48f0b535015784a3f6349ee8f/raw/31ce73076243f02dc91735d5941fd00807e67e62/gistfile1.txt",
            Addons = {
                {Name = "Move Overlay", Icon = "wrench", Callback = function() RUI:Notify("Add-on", "Move Overlay is not configured in the demo.", 3) end},
                {Name = "Auto Play", Icon = "wrench", Callback = function() RUI:Notify("Add-on", "Auto Play is not configured in the demo.", 3) end}
            },
            OnLoad = function() RUI:Notify("Hub Demo", "Load would run the RoChess gist here.", 3) end
        })
    end
})
hubSec:CreateButton({
    Name = "Minesweeper Duels",
    Desc = "Duels tools - 99793886804887",
    Icon = "target",
    Callback = function()
        RUI:GameModal({
            Title = "Minesweeper Duels",
            Name = "Minesweeper Duels",
            Desc = "Competitive minesweeper duels.",
            Info = "Competitive minesweeper duels. Read the board, outplay the opponent.",
            Icon = "target",
            ScriptTitle = "Minesweeper Duels - Solver",
            Creator = "Renware",
            PlaceId = 99793886804887,
            Url = "https://gist.githubusercontent.com/rennbytes/e563425ca925a1614a7e391d1ae1089c/raw/2138a0e3c8cb67d221115ff36fc6a21e99b87278/gistfile1.txt",
            Addons = {
                {Name = "Board Reader", Icon = "wrench", Callback = function() RUI:Notify("Add-on", "Board Reader is not configured in the demo.", 3) end},
                {Name = "Quick Reveal", Icon = "wrench", Callback = function() RUI:Notify("Add-on", "Quick Reveal is not configured in the demo.", 3) end}
            },
            OnLoad = function() RUI:Notify("Hub Demo", "Load would run the Duels gist here.", 3) end
        })
    end
})

-- ============ startup ============
-- library state that doesnt need a click to check
RUI:Notify("RUI Demo", "Loaded. 4 built in tabs + 9 demo tabs.", 4)

print("[RUI Demo] ready")
print("  window:     " .. tostring(RUI:GetWindow() ~= nil))
print("  themes:     " .. table.concat(RUI:GetThemes(), ", "))
print("  tabs:       " .. tostring(#Window.Tabs))
print("  key gate:   " .. tostring(USE_KEY_GATE))
print("  key valid:  " .. tostring(RUI:HasKey()))
