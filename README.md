# RUI-Library-Framework

Pure Luau UI library for Roblox executors. Single file, no dependencies, no build step. Built for scripts that need tabs, sections, elements, themes, configs, notifications, dialogs and a key gate without shipping a framework folder.

## Features

- Single-file `rui.lua`
- Side tabs with icons, active fill and PC key hint
- Sections, labels, dividers, buttons, inputs, keybinds, toggles, sliders and dropdowns
- Table-style element calls plus positional calls
- Returned element handles with `Get()` / `Set()`
- Synced controls: multiple elements can share one `Flag`
- Themes, 316 Lucide icons and custom icon injection
- Config save/load/delete with window layout and flag persistence
- Notifications, long notifications and six variants
- Modal, Confirm, Alert and paginated Onboarding
- Optional key gate with pluggable services
- Mobile FAB, phone/tablet sizing and drag handling
- Strict teardown through `Unload()`

## Install

Raw:

```lua
local RUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/rennbytes/RUI-Library-Framework/main/rui.lua"))()
```

Executor file:

```lua
local RUI = loadstring(readfile("rui.lua"))()
```

## Quick start

```lua
local RUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/rennbytes/RUI-Library-Framework/main/rui.lua"))()

local Window = RUI:CreateWindow({
    Title = "My Script"
})

local Tab = Window:CreateTab("Main", 10, nil, "home")
local Settings = Tab:CreateSection("Settings", "settings-2")

Settings:CreateButton({
    Name = "Click me",
    Desc = "Runs a callback",
    Icon = "mouse-pointer-click",
    Callback = function()
        RUI:Notify("Button", "Clicked.", 3)
    end
})

local Toggle = Settings:CreateToggle({
    Name = "Example toggle",
    Default = false,
    Flag = "example.toggle",
    Icon = "zap",
    Callback = function(value)
        print("toggle:", value)
    end
})

Settings:CreateButton({
    Name = "Flip toggle",
    Callback = function()
        Toggle:Set(not Toggle:Get())
    end
})
```

## Elements

```lua
Section:CreateButton(opts)
Section:CreateLabel(opts)
Section:CreateDivider()
Section:CreateInput(opts)
Section:CreateKeybind(opts)
Section:CreateToggle(opts)
Section:CreateSlider(opts)
Section:CreateDropdown(opts)
```

Table form is preferred. Positional form still works.

```lua
Section:CreateToggle("Name", false, callback, "flag", "icon")
Section:CreateSlider("Name", 0, 100, 50, callback, "flag", "icon")
Section:CreateDropdown("Name", {"A", "B"}, "A", callback, "flag")
```

Stateful elements return a handle:

```lua
local handle = Section:CreateToggle({Name = "Flag", Flag = "my.flag"})
handle:Get()
handle:Set(true)
```

Two elements using the same `Flag` stay visually synced and fire the callback once per change.

## Window tabs

```lua
local Tab = Window:CreateTab("Name", order, customBuild, iconName)
```

- `order` controls sidebar position.
- `customBuild(tabObj, container)` can supply a custom `tabObj.ContentRoot`.
- `iconName` accepts a registered Lucide icon name or `rbxassetid://...`.

## Themes and icons

```lua
RUI:SetTheme("Midnight")
RUI:GetThemes()
RUI:GetCurrentTheme()
RUI:AddTheme("MyTheme", colors)

RUI:SetIcon("name", "rbxassetid://...")
RUI:AddIcons({["my-icon"] = "rbxassetid://..."})
RUI:GetIcon("home")
RUI:GetIcons()
```

Built-in themes: Midnight, Dark, Light, Forest, Ruby, Ocean.

## Notifications

```lua
RUI:Notify("Title", "Description", 5)
RUI:Notify({Title = "Title", Content = "Desc", Duration = 5, Type = "info", Icon = "bell"})

RUI:NotifyLong("Title", "Description", 5, "info", "bell")
RUI:NotifyInfo("Title", "Description", 5)
RUI:NotifyEvent("Title", "Description", 5)
RUI:NotifyWarning("Title", "Description", 5)
RUI:NotifyError("Title", "Description", 5)
RUI:NotifySuccess("Title", "Description", 5)
```

## Dialogs

```lua
RUI:Modal({
    Title = "Notice",
    Content = "Body text",
    Confirm = "Okay",
    OnConfirm = function() end
})

RUI:Confirm("Sure?", "Do this?", function() end)
RUI:Alert("Done", "Finished.")

RUI:Onboarding("Welcome", {
    {Title = "First", Content = "Intro", Icon = "house"},
    {Title = "Second", Bullets = {"One", "Two"}}
}, function()
    print("finished")
end)
```

## Configs

```lua
RUI:SaveConfig("main")
RUI:LoadConfig("main")
RUI:DeleteConfig("main")
RUI:GetConfigs()
RUI:ResetAll()
```

Config files live under `RUI/Configs`. Window size, position, opacity, current tab and flags are stored.

## Key gate

```lua
RUI.Services.myservice = {
    Name = "My Service",
    Args = {"ServiceId"},
    New = function()
        return {
            Verify = function(key)
                return key == "abc", "Key accepted."
            end,
            Copy = function()
                return "https://example.com/get-key"
            end
        }
    end
}

RUI:CreateWindow({
    Title = "Protected",
    KeySystem = {
        Title = "Protected",
        Note = "Enter your key.",
        API = {{Title = "Get key", Type = "myservice"}}
    }
})
```

Additional helpers:

```lua
RUI:HasKey()
RUI:WaitForKey(10)
```

## Utility API

```lua
RUI:GetWindow()
RUI:SetTheme(name)
RUI:Debug(true)
RUI:Unload()
```

`Unload()` clears connections, GUIs, flags, themes, notifications, modal refs and gate state.

## Files

- `rui.lua` — library
- `demo.lua` — feature demo and API examples

## Notes

- Desktop uses a sidebar key hint. Touch devices use a floating open button.
- The active tab uses a neutral fill with accent icon and label.
- Theme preset and variant icons keep fixed colors through theme changes.
- Notification widths clamp to the viewport.
- `Create*` methods accept tables and keep positional compatibility.

## License

MIT.
```
MIT — see LICENSE.
