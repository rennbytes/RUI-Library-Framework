-- ren ui by ren (@wtf_renn)
-- simple ui lib, kinda like rayfield but lighter
-- v2 cleaned 10/14, lmk if something breaks

local plr = game.Players.LocalPlayer
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local UIS = game:GetService("UserInputService")
local Http = game:GetService("HttpService")
local TextService = game:GetService("TextService")
local Teleport = game:GetService("TeleportService")

local gethui = gethui or function() return CoreGui end
local protect = protectgui or (syn and syn.protect_gui) or function() end

-- cleanup last run
if _G.__renui_cleanup then pcall(_G.__renui_cleanup) end
if _G.__PremiumUI_Cleanup then pcall(_G.__PremiumUI_Cleanup) end -- old version

local isMobile = UIS.TouchEnabled

-- themes, keep it small
local themes = {
	Midnight = {
		Background = Color3.fromRGB(10, 12, 22),
		Main = Color3.fromRGB(18, 20, 32),
		Sec = Color3.fromRGB(14, 16, 28),
		Border = Color3.fromRGB(35, 40, 60),
		Accent = Color3.fromRGB(70, 150, 255),
		Text = Color3.fromRGB(255, 255, 255),
		Sub = Color3.fromRGB(170, 185, 210),
		Hover = Color3.fromRGB(26, 28, 42),
		Click = Color3.fromRGB(12, 14, 24),
	},
	Dark = {
		Background = Color3.fromRGB(15, 15, 20),
		Main = Color3.fromRGB(24, 24, 32),
		Sec = Color3.fromRGB(20, 20, 28),
		Border = Color3.fromRGB(40, 40, 50),
		Accent = Color3.fromRGB(220, 220, 230),
		Text = Color3.fromRGB(255, 255, 255),
		Sub = Color3.fromRGB(170, 170, 185),
		Hover = Color3.fromRGB(32, 32, 42),
		Click = Color3.fromRGB(18, 18, 24),
	},
	Light = {
		Background = Color3.fromRGB(235, 235, 240),
		Main = Color3.fromRGB(220, 220, 228),
		Sec = Color3.fromRGB(225, 225, 232),
		Border = Color3.fromRGB(200, 200, 210),
		Accent = Color3.fromRGB(40, 60, 100),
		Text = Color3.fromRGB(20, 20, 30),
		Sub = Color3.fromRGB(100, 100, 115),
		Hover = Color3.fromRGB(210, 210, 218),
		Click = Color3.fromRGB(200, 200, 208),
	},
	Ocean = {
		Background = Color3.fromRGB(8, 18, 26),
		Main = Color3.fromRGB(14, 28, 38),
		Sec = Color3.fromRGB(10, 22, 32),
		Border = Color3.fromRGB(28, 50, 65),
		Accent = Color3.fromRGB(90, 215, 235),
		Text = Color3.fromRGB(235, 250, 255),
		Sub = Color3.fromRGB(165, 210, 220),
		Hover = Color3.fromRGB(20, 38, 50),
		Click = Color3.fromRGB(8, 20, 30),
	},
	Ruby = {
		Background = Color3.fromRGB(20, 12, 12),
		Main = Color3.fromRGB(32, 18, 18),
		Sec = Color3.fromRGB(28, 14, 14),
		Border = Color3.fromRGB(55, 35, 35),
		Accent = Color3.fromRGB(255, 85, 85),
		Text = Color3.fromRGB(255, 255, 255),
		Sub = Color3.fromRGB(205, 170, 170),
		Hover = Color3.fromRGB(42, 26, 26),
		Click = Color3.fromRGB(24, 12, 12),
	},
	Forest = {
		Background = Color3.fromRGB(12, 20, 14),
		Main = Color3.fromRGB(20, 30, 22),
		Sec = Color3.fromRGB(16, 24, 18),
		Border = Color3.fromRGB(38, 50, 40),
		Accent = Color3.fromRGB(90, 215, 110),
		Text = Color3.fromRGB(255, 255, 255),
		Sub = Color3.fromRGB(175, 195, 180),
		Hover = Color3.fromRGB(28, 40, 30),
		Click = Color3.fromRGB(14, 22, 16),
	},
}

local curTheme = "Midnight"
local T = themes[curTheme]

local themed = {} -- {obj, prop, key}
local function reg(obj, prop, key)
	table.insert(themed, {o = obj, p = prop, k = key})
	pcall(function() obj[prop] = themes[curTheme][key] end)
end

local toggleRefreshers = {} -- fns to fix toggle colors on theme switch
local allFlags = {} -- for reset button

local function refreshTheme()
	T = themes[curTheme]
	for _, v in pairs(themed) do
		if v.o and v.o.Parent then
			pcall(function() v.o[v.p] = T[v.k] end)
		end
	end
	for _, fn in pairs(toggleRefreshers) do
		pcall(fn)
	end
end

local function setTheme(name)
	if not themes[name] then return end
	if name == curTheme then return end
	curTheme = name
	T = themes[name]
	refreshTheme()
end

-- helpers

local function mk(class, props)
	local i = Instance.new(class)
	for k, v in pairs(props or {}) do
		if k ~= "Parent" then
			pcall(function() i[k] = v end)
		end
	end
	if props and props.Parent then i.Parent = props.Parent end
	return i
end

local function tween(obj, props, t)
	t = t or 0.2
	local tw = TweenService:Create(obj, TweenInfo.new(t, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), props)
	tw:Play()
	return tw
end

local function corner(p, r)
	return mk("UICorner", {Parent = p, CornerRadius = UDim.new(0, r or 6)})
end

local function stroke(p, thick)
	local s = mk("UIStroke", {Parent = p, Thickness = thick or 1, Transparency = 0.5})
	reg(s, "Color", "Border")
	return s
end

local function drag(handle, win)
	local held = false
	local start, startPos
	handle.InputBegan:Connect(function(inp)
		if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
			held = true
			start = inp.Position
			startPos = win.Position
		end
	end)
	UIS.InputEnded:Connect(function(inp)
		if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
			held = false
		end
	end)
	UIS.InputChanged:Connect(function(inp)
		if held and (inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch) then
			local d = inp.Position - start
			win.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
		end
	end)
end

local function httpget(url)
	if syn and syn.request then
		local r = syn.request({Url = url, Method = "GET"})
		if r and (r.Body or r.body) then return r.Body or r.body end
	elseif http_request then
		local r = http_request({Url = url, Method = "GET"})
		if r and (r.Body or r.body) then return r.Body or r.body end
	elseif request then
		local r = request({Url = url, Method = "GET"})
		if r and (r.Body or r.body) then return r.Body or r.body end
	end
	return Http:GetAsync(url)
end

-- library

local Library = {
	Windows = {},
	ToggleKeybind = Enum.KeyCode.RightShift,
	Unloaded = false,
}
local cons = {}

function Library:Notify(title, desc, dur)
	dur = dur or 5
	if self._notifOff then return end
	local holder = self._notifGui
	if not holder or not holder.Parent then return end

	-- only 3 at a time, kill oldest
	local kids = {}
	for _, v in pairs(holder:GetChildren()) do
		if v:IsA("Frame") then table.insert(kids, v) end
	end
	if #kids >= 3 then
		pcall(function() kids[1]:Destroy() end)
	end

	local f = mk("Frame", {
		Parent = holder,
		Size = UDim2.new(1, 0, 0, 70),
		BackgroundColor3 = T.Main,
		BorderSizePixel = 0,
	})
	reg(f, "BackgroundColor3", "Main")
	corner(f, 8)
	stroke(f)

	local tl = mk("TextLabel", {
		Parent = f, BackgroundTransparency = 1,
		Position = UDim2.new(0, 12, 0, 8), Size = UDim2.new(1, -40, 0, 18),
		Font = Enum.Font.GothamBold, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left,
		Text = title, TextTruncate = Enum.TextTruncate.AtEnd,
	})
	reg(tl, "TextColor3", "Text")

	local dl = mk("TextLabel", {
		Parent = f, BackgroundTransparency = 1,
		Position = UDim2.new(0, 12, 0, 28), Size = UDim2.new(1, -24, 0, 28),
		Font = Enum.Font.Gotham, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left,
		Text = desc, TextWrapped = true,
	})
	reg(dl, "TextColor3", "Sub")

	local x = mk("TextButton", {
		Parent = f, BackgroundTransparency = 1,
		Position = UDim2.new(1, -26, 0, 6), Size = UDim2.new(0, 20, 0, 20),
		Text = "x", Font = Enum.Font.GothamBold, TextSize = 14, AutoButtonColor = false,
	})
	reg(x, "TextColor3", "Sub")

	local bar = mk("Frame", {
		Parent = f, BorderSizePixel = 0,
		Position = UDim2.new(0, 10, 1, -8), Size = UDim2.new(1, -20, 0, 3),
	})
	reg(bar, "BackgroundColor3", "Accent")
	corner(bar, 99)

	local dead = false
	x.MouseButton1Click:Connect(function()
		dead = true
		pcall(function() f:Destroy() end)
	end)

	task.spawn(function()
		tween(bar, {Size = UDim2.new(0, 0, 1, 0)}, dur, Enum.EasingStyle.Linear)
		task.wait(dur)
		if not dead and f and f.Parent then f:Destroy() end
	end)
end

function Library:Unload()
	if self.Unloaded then return end
	self.Unloaded = true
	for _, c in pairs(cons) do pcall(function() c:Disconnect() end) end
	pcall(function() if self._gui then self._gui:Destroy() end end)
	pcall(function() if self._notifGui then self._notifGui:Destroy() end end)
	pcall(function() if self._notifGuiObj then self._notifGuiObj:Destroy() end end)
	table.clear(themed)
	table.clear(self.Windows)
end

function Library:ResetAll()
	for _, fl in pairs(allFlags) do
		if fl and fl.Default ~= nil and fl.Set then
			pcall(function() fl:Set(fl.Default) end)
		end
	end
end

_G.__renui_cleanup = function()
	pcall(function() Library:Unload() end)
end

function Library:CreateWindow(opt)
	opt = opt or {}
	local title = opt.Title or "ren ui"
	local size = opt.Size or UDim2.new(0, 600, 0, 400)
	if isMobile and not opt.Size then
		size = UDim2.new(0, 420, 0, 320)
	end

	local gui = mk("ScreenGui", {Name = "renui", ResetOnSpawn = false, ZIndexBehavior = Enum.ZIndexBehavior.Sibling, Parent = gethui()})
	pcall(protect, gui)
	self._gui = gui

	-- notifs
	if not self._notifGui then
		local ng = mk("ScreenGui", {Name = "renui_notifs", ResetOnSpawn = false, ZIndexBehavior = Enum.ZIndexBehavior.Sibling, Parent = gethui()})
		pcall(protect, ng)
		local hold = mk("Frame", {
			Parent = ng, BackgroundTransparency = 1,
			AnchorPoint = Vector2.new(1, 1), Position = UDim2.new(1, -16, 1, -16),
			Size = UDim2.new(0, 280, 1, -32),
		})
		mk("UIListLayout", {Parent = hold, SortOrder = Enum.SortOrder.LayoutOrder, VerticalAlignment = Enum.VerticalAlignment.Bottom, Padding = UDim.new(0, 8)})
		self._notifGui = hold
		self._notifGuiObj = ng
		table.insert(self.Windows, ng)
	end

	local main = mk("Frame", {
		Parent = gui, Size = size,
		Position = UDim2.new(0.5, -size.X.Offset / 2, 0.5, -size.Y.Offset / 2),
		BorderSizePixel = 0,
	})
	reg(main, "BackgroundColor3", "Background")
	corner(main, 10)
	stroke(main)
	table.insert(self.Windows, gui)

	-- intro lol
	main.Size = UDim2.new(0, 0, 0, 40)
	tween(main, {Size = size}, 0.4)

	local top = mk("TextButton", {
		Parent = main, Size = UDim2.new(1, 0, 0, 38),
		BackgroundTransparency = 1, Text = "", AutoButtonColor = false,
	})
	drag(top, main)

	local name = mk("TextLabel", {
		Parent = top, BackgroundTransparency = 1,
		Position = UDim2.new(0, 14, 0, 0), Size = UDim2.new(1, -100, 1, 0),
		Font = Enum.Font.GothamBold, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left,
		Text = title, TextTruncate = Enum.TextTruncate.AtEnd,
	})
	reg(name, "TextColor3", "Text")

	-- close + minimize, no max btn nobody used it
	local close = mk("TextButton", {
		Parent = top, BackgroundTransparency = 1,
		Position = UDim2.new(1, -34, 0, 0), Size = UDim2.new(0, 30, 1, 0),
		Text = "x", Font = Enum.Font.GothamBold, TextSize = 16, AutoButtonColor = false,
	})
	reg(close, "TextColor3", "Sub")
	local min = mk("TextButton", {
		Parent = top, BackgroundTransparency = 1,
		Position = UDim2.new(1, -62, 0, 0), Size = UDim2.new(0, 30, 1, 0),
		Text = "-", Font = Enum.Font.GothamBold, TextSize = 16, AutoButtonColor = false,
	})
	reg(min, "TextColor3", "Sub")

	local win = {
		Tabs = {},
		Current = nil,
		Main = main,
		Minimized = false,
		Hidden = false,
		DefaultSize = size,
	}

	close.MouseButton1Click:Connect(function()
		win.Hidden = true
		main.Visible = false
		if isMobile and win._fab then win._fab.Visible = true end
	end)
	min.MouseButton1Click:Connect(function()
		win.Minimized = not win.Minimized
		if win.Minimized then
			main.Size = UDim2.new(0, size.X.Offset, 0, 38)
		else
			tween(main, {Size = size}, 0.3)
		end
	end)

	-- left tab list + right content
	local left = mk("Frame", {
		Parent = main, BackgroundTransparency = 1,
		Position = UDim2.new(0, 0, 0, 38), Size = UDim2.new(0, 130, 1, -38),
	})
	local tabList = mk("ScrollingFrame", {
		Parent = left, Size = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1, ScrollBarThickness = 0,
		AutomaticCanvasSize = Enum.AutomaticSize.Y, CanvasSize = UDim2.new(0, 0, 0, 0),
	})
	mk("UIListLayout", {Parent = tabList, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 4), HorizontalAlignment = Enum.HorizontalAlignment.Center})
	mk("UIPadding", {Parent = tabList, PaddingTop = UDim.new(0, 6), PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8)})

	local right = mk("Frame", {
		Parent = main, BackgroundTransparency = 1, ClipsDescendants = true,
		Position = UDim2.new(0, 130, 0, 38), Size = UDim2.new(1, -130, 1, -38),
	})

	-- mobile open btn
	if isMobile then
		local fab = mk("TextButton", {
			Parent = gui, Size = UDim2.new(0, 70, 0, 32),
			Position = UDim2.new(0, 10, 0.5, 0),
			Text = "REN", Font = Enum.Font.GothamBold, TextSize = 13, AutoButtonColor = false,
		})
		reg(fab, "BackgroundColor3", "Main")
		reg(fab, "TextColor3", "Accent")
		corner(fab, 8)
		stroke(fab)
		fab.Visible = false
		win._fab = fab
		drag(fab, fab)
		fab.MouseButton1Click:Connect(function()
			-- only toggle if it wasnt a drag (eh, good enough)
			win.Hidden = false
			main.Visible = true
			fab.Visible = false
		end)
	end

	-- rightshift toggle
	table.insert(cons, UIS.InputBegan:Connect(function(inp, gpe)
		if gpe then return end
		if inp.KeyCode == self.ToggleKeybind then
			win.Hidden = not win.Hidden
			main.Visible = not win.Hidden
			if isMobile and win._fab then
				win._fab.Visible = win.Hidden
			end
		end
	end))

	function win:CreateTab(tabName, order)
		local btn = mk("TextButton", {
			Parent = tabList, Size = UDim2.new(1, 0, 0, 30),
			Text = "  " .. tabName, Font = Enum.Font.GothamSemibold, TextSize = 13,
			TextXAlignment = Enum.TextXAlignment.Left, AutoButtonColor = false,
			BackgroundTransparency = 1, LayoutOrder = order or (#self.Tabs + 2),
		})
		reg(btn, "TextColor3", "Sub")
		corner(btn, 6)

		local page = mk("ScrollingFrame", {
			Parent = right, Size = UDim2.new(1, 0, 1, 0),
			BackgroundTransparency = 1, ScrollBarThickness = 2, Visible = false,
			AutomaticCanvasSize = Enum.AutomaticSize.Y, CanvasSize = UDim2.new(0, 0, 0, 0),
		})
		reg(page, "ScrollBarImageColor3", "Accent")
		mk("UIListLayout", {Parent = page, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 10), HorizontalAlignment = Enum.HorizontalAlignment.Center})
		mk("UIPadding", {Parent = page, PaddingTop = UDim.new(0, 6), PaddingBottom = UDim.new(0, 16)})

		local tab = {Name = tabName, Btn = btn, Page = page}

		local function select()
			if win.Current == tab then return end
			win.Current = tab
			for _, t in pairs(win.Tabs) do
				t.Page.Visible = (t == tab)
				if t == tab then
					t.Btn.BackgroundTransparency = 0
					reg(t.Btn, "BackgroundColor3", "Hover")
					t.Btn.BackgroundColor3 = T.Hover
					t.Btn.TextColor3 = T.Text
				else
					t.Btn.BackgroundTransparency = 1
					t.Btn.TextColor3 = T.Sub
				end
			end
		end
		btn.MouseButton1Click:Connect(select)
		tab.Select = select
		table.insert(win.Tabs, tab)

		function tab:CreateSection(secName)
			local box = mk("Frame", {
				Parent = page, Size = UDim2.new(1, -16, 0, 0),
				AutomaticSize = Enum.AutomaticSize.Y, BorderSizePixel = 0,
			})
			reg(box, "BackgroundColor3", "Sec")
			corner(box, 6)
			stroke(box)
			mk("UIListLayout", {Parent = box, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 8)})
			mk("UIPadding", {Parent = box, PaddingTop = UDim.new(0, 12), PaddingBottom = UDim.new(0, 12), PaddingLeft = UDim.new(0, 12), PaddingRight = UDim.new(0, 12)})

			local secTitle = mk("TextLabel", {
				Parent = box, BackgroundTransparency = 1,
				Size = UDim2.new(1, 0, 0, 20),
				Font = Enum.Font.GothamBold, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left,
				Text = secName,
			})
			reg(secTitle, "TextColor3", "Text")

			local div = mk("Frame", {Parent = box, Size = UDim2.new(1, 0, 0, 1), BorderSizePixel = 0, BackgroundTransparency = 0.5})
			reg(div, "BackgroundColor3", "Border")

			local sec = {}

			function sec:CreateButton(bname, cb)
				local b = mk("TextButton", {
					Parent = box, Size = UDim2.new(1, 0, 0, 30),
					Text = bname, Font = Enum.Font.GothamSemibold, TextSize = 13, AutoButtonColor = false,
				})
				reg(b, "BackgroundColor3", "Main")
				reg(b, "TextColor3", "Text")
				corner(b, 6)
				local st = stroke(b)
				b.MouseEnter:Connect(function() b.BackgroundColor3 = T.Hover end)
				b.MouseLeave:Connect(function() b.BackgroundColor3 = T.Main end)
				b.MouseButton1Click:Connect(function()
					task.spawn(function() pcall(cb) end)
				end)
			end

			function sec:CreateToggle(tname, def, cb)
				def = def or false
				local row = mk("Frame", {Parent = box, Size = UDim2.new(1, 0, 0, 28), BackgroundTransparency = 1})
				local lbl = mk("TextLabel", {
					Parent = row, BackgroundTransparency = 1,
					Size = UDim2.new(1, -50, 1, 0),
					Font = Enum.Font.Gotham, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left,
					Text = tname,
				})
				local pill = mk("TextButton", {
					Parent = row, Size = UDim2.new(0, 40, 0, 20),
					Position = UDim2.new(1, -40, 0.5, -10),
					Text = "", AutoButtonColor = false,
				})
				corner(pill, 99)
				local dot = mk("Frame", {
					Parent = pill, Size = UDim2.new(0, 16, 0, 16),
					Position = def and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8),
					BorderSizePixel = 0, BackgroundColor3 = Color3.new(1, 1, 1),
				})
				corner(dot, 99)

				local on = def
				local function paint(anim)
					if on then
						pill.BackgroundColor3 = T.Accent
						lbl.TextColor3 = T.Text
					else
						pill.BackgroundColor3 = T.Main
						lbl.TextColor3 = T.Sub
					end
					dot.Position = on and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
					if anim then tween(dot, {Position = dot.Position}, 0.15) end
				end
				paint(false)
				table.insert(toggleRefreshers, function() paint(false) end)
				reg(lbl, "TextColor3", on and "Text" or "Sub")

				local function set(v, silent)
					on = v
					paint(true)
					if not silent then
						task.spawn(function() pcall(cb, on) end)
					end
				end

				pill.MouseButton1Click:Connect(function()
					set(not on)
				end)

				local flag = {Value = on, Default = def, Set = function(_, v) set(v) end}
				table.insert(allFlags, flag)
				-- fire default? nah, rayfield doesnt either
			end

			function sec:CreateSlider(sname, min, max, def, cb)
				min = min or 0
				max = max or 100
				def = def or min
				local wrap = mk("Frame", {Parent = box, Size = UDim2.new(1, 0, 0, 44), BackgroundTransparency = 1})
				local topRow = mk("Frame", {Parent = wrap, Size = UDim2.new(1, 0, 0, 18), BackgroundTransparency = 1})
				local lbl = mk("TextLabel", {
					Parent = topRow, BackgroundTransparency = 1,
					Size = UDim2.new(1, -50, 1, 0),
					Font = Enum.Font.Gotham, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left, Text = sname,
				})
				reg(lbl, "TextColor3", "Text")
				local val = mk("TextLabel", {
					Parent = topRow, BackgroundTransparency = 1,
					Position = UDim2.new(1, -50, 0, 0), Size = UDim2.new(0, 50, 1, 0),
					Font = Enum.Font.Gotham, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Right, Text = tostring(math.floor(def)),
				})
				reg(val, "TextColor3", "Sub")

				local track = mk("TextButton", {
					Parent = wrap, Position = UDim2.new(0, 0, 0, 24),
					Size = UDim2.new(1, 0, 0, 6), Text = "", AutoButtonColor = false,
				})
				reg(track, "BackgroundColor3", "Main")
				corner(track, 99)
				local fill = mk("Frame", {
					Parent = track, BorderSizePixel = 0,
					Size = UDim2.new((def - min) / math.max(1, (max - min)), 0, 1, 0),
				})
				reg(fill, "BackgroundColor3", "Accent")
				corner(fill, 99)

				local cur = def
				local held = false
				local function apply(x)
					local absP = track.AbsolutePosition.X
					local absS = track.AbsoluteSize.X
					if absS <= 0 then return end
					local p = math.clamp((x - absP) / absS, 0, 1)
					cur = min + (max - min) * p
					-- keep decimals if small range? just round if ints
					if max <= 200 then cur = math.floor(cur + 0.5) end
					fill.Size = UDim2.new(p, 0, 1, 0)
					val.Text = tostring(cur)
					task.spawn(function() pcall(cb, cur) end)
				end
				track.InputBegan:Connect(function(inp)
					if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
						held = true
						apply(inp.Position.X)
					end
				end)
				UIS.InputEnded:Connect(function(inp)
					if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
						held = false
					end
				end)
				UIS.InputChanged:Connect(function(inp)
					if held and (inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch) then
						apply(inp.Position.X)
					end
				end)

				local flag = {Value = cur, Default = def, Set = function(self, v)
					v = math.clamp(v, min, max)
					cur = v
					local p = (v - min) / math.max(1, (max - min))
					fill.Size = UDim2.new(p, 0, 1, 0)
					val.Text = tostring(v)
					pcall(cb, v)
				end}
				table.insert(allFlags, flag)
			end

			function sec:CreateDropdown(dname, items, def, cb)
				items = items or {}
				local wrap = mk("Frame", {Parent = box, Size = UDim2.new(1, 0, 0, 50), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1})
				mk("TextLabel", {
					Parent = wrap, BackgroundTransparency = 1,
					Size = UDim2.new(1, 0, 0, 18),
					Font = Enum.Font.Gotham, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left, Text = dname,
				}).TextColor3 = T.Text
				local btn = mk("TextButton", {
					Parent = wrap, Size = UDim2.new(1, 0, 0, 28),
					Position = UDim2.new(0, 0, 0, 20),
					Text = "  " .. tostring(def or items[1] or "..."),
					Font = Enum.Font.Gotham, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left, AutoButtonColor = false,
				})
				reg(btn, "BackgroundColor3", "Main")
				reg(btn, "TextColor3", "Sub")
				corner(btn, 6)
				stroke(btn)

				local list = mk("Frame", {
					Parent = wrap, Position = UDim2.new(0, 0, 0, 50),
					Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
					Visible = false, BorderSizePixel = 0,
				})
				reg(list, "BackgroundColor3", "Background")
				corner(list, 6)
				stroke(list)
				mk("UIListLayout", {Parent = list, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 2)})
				mk("UIPadding", {Parent = list, PaddingTop = UDim.new(0, 4), PaddingBottom = UDim.new(0, 4), PaddingLeft = UDim.new(0, 4), PaddingRight = UDim.new(0, 4)})

				local cur = def or items[1]
				local function rebuild()
					for _, v in pairs(list:GetChildren()) do
						if v:IsA("TextButton") then v:Destroy() end
					end
					for _, item in pairs(items) do
						local o = mk("TextButton", {
							Parent = list, Size = UDim2.new(1, 0, 0, 24),
							Text = "  " .. tostring(item), Font = Enum.Font.Gotham, TextSize = 13,
							TextXAlignment = Enum.TextXAlignment.Left, BackgroundTransparency = 1, AutoButtonColor = false,
						})
						reg(o, "TextColor3", "Sub")
						corner(o, 4)
						o.MouseEnter:Connect(function() o.BackgroundTransparency = 0 o.BackgroundColor3 = T.Hover end)
						o.MouseLeave:Connect(function() o.BackgroundTransparency = 1 end)
						o.MouseButton1Click:Connect(function()
							cur = item
							btn.Text = "  " .. tostring(item)
							list.Visible = false
							task.spawn(function() pcall(cb, cur) end)
						end)
					end
				end
				rebuild()
				btn.MouseButton1Click:Connect(function()
					list.Visible = not list.Visible
				end)

				local flag = {Value = cur, Default = def, Set = function(self, v)
					cur = v
					btn.Text = "  " .. tostring(v)
					pcall(cb, v)
				end}
				table.insert(allFlags, flag)
			end

			return sec
		end

		return tab
	end

	-- builtin tabs, keep em simple

	local home = win:CreateTab("Home", 1)

	local welcomeBox = mk("Frame", {Parent = home.Page, Size = UDim2.new(1, -16, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BorderSizePixel = 0})
	reg(welcomeBox, "BackgroundColor3", "Sec")
	corner(welcomeBox, 6)
	stroke(welcomeBox)
	mk("UIListLayout", {Parent = welcomeBox, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 4)})
	mk("UIPadding", {Parent = welcomeBox, PaddingTop = UDim.new(0, 14), PaddingBottom = UDim.new(0, 14), PaddingLeft = UDim.new(0, 14), PaddingRight = UDim.new(0, 14)})

	local avRow = mk("Frame", {Parent = welcomeBox, Size = UDim2.new(1, 0, 0, 60), BackgroundTransparency = 1})
	local av = mk("ImageLabel", {Parent = avRow, Size = UDim2.new(0, 50, 0, 50), Position = UDim2.new(0, 0, 0, 5), BackgroundTransparency = 1, Image = "rbxasset://textures/ui/GuiImagePlaceholder.png"})
	corner(av, 99)
	task.spawn(function()
		local ok, img = pcall(function()
			return game.Players:GetUserThumbnailAsync(plr.UserId, Enum.ThumbnailType.AvatarBust, Enum.ThumbnailSize.Size100x100)
		end)
		if ok and img and av.Parent then av.Image = img end
	end)
	local hello = mk("TextLabel", {Parent = avRow, BackgroundTransparency = 1, Position = UDim2.new(0, 60, 0, 4), Size = UDim2.new(1, -60, 0, 24), Font = Enum.Font.GothamBold, TextSize = 16, TextXAlignment = Enum.TextXAlignment.Left, Text = "hi, " .. plr.DisplayName, TextTruncate = Enum.TextTruncate.AtEnd})
	reg(hello, "TextColor3", "Text")
	local sub = mk("TextLabel", {Parent = avRow, BackgroundTransparency = 1, Position = UDim2.new(0, 60, 0, 28), Size = UDim2.new(1, -60, 0, 18), Font = Enum.Font.Gotham, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left, Text = "@" .. plr.Name .. " • " .. plr.AccountAge .. " days"})
	reg(sub, "TextColor3", "Sub")

	local infoBox = mk("Frame", {Parent = home.Page, Size = UDim2.new(1, -16, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BorderSizePixel = 0})
	reg(infoBox, "BackgroundColor3", "Sec")
	corner(infoBox, 6)
	stroke(infoBox)
	mk("UIListLayout", {Parent = infoBox, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 8)})
	mk("UIPadding", {Parent = infoBox, PaddingTop = UDim.new(0, 12), PaddingBottom = UDim.new(0, 12), PaddingLeft = UDim.new(0, 12), PaddingRight = UDim.new(0, 12)})
	local infoTitle = mk("TextLabel", {Parent = infoBox, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 18), Font = Enum.Font.GothamBold, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left, Text = "Script Info"})
	reg(infoTitle, "TextColor3", "Text")
	local infoTxt = mk("TextBox", {Parent = infoBox, Size = UDim2.new(1, 0, 0, 70), Text = "No info yet.", Font = Enum.Font.Code, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Top, TextWrapped = true, MultiLine = true, ClearTextOnFocus = false})
	reg(infoTxt, "BackgroundColor3", "Main")
	reg(infoTxt, "TextColor3", "Sub")
	corner(infoTxt, 6)
	win._infoBox = infoTxt

	function win:SetScriptInfo(t)
		if self._infoBox then self._infoBox.Text = t end
	end

	-- servers tab, minimal (rejoin/hop). todo: full server list later idk
	local srv = win:CreateTab("Servers", 9990)
	do
		local sec = srv:CreateSection("Current")
		sec:CreateButton("Copy JobId", function()
			if setclipboard then setclipboard(game.JobId) end
			Library:Notify("servers", "jobid copied", 2)
		end)
		local sec2 = srv:CreateSection("Hop")
		sec2:CreateButton("Rejoin", function() Teleport:Teleport(game.PlaceId, plr) end)
		sec2:CreateButton("Server Hop", function()
			local ok, res = pcall(function()
				return Http:JSONDecode(httpget(("https://games.roblox.com/v1/games/%d/servers/Public?limit=100"):format(game.PlaceId)))
			end)
			if ok and res and res.data and #res.data > 0 then
				local ids = {}
				for _, sv in pairs(res.data) do
					if sv.id ~= game.JobId then table.insert(ids, sv.id) end
				end
				if #ids > 0 then
					Teleport:TeleportToPlaceInstance(game.PlaceId, ids[math.random(1, #ids)], plr)
				else
					Library:Notify("hop", "no other servers", 3)
				end
			else
				Library:Notify("hop", "failed to fetch", 3)
			end
		end)
	end

	-- customize tab
	local cus = win:CreateTab("Customize", 9991)
	do
		local d = cus:CreateSection("Look")
		d:CreateSlider("UI Opacity", 20, 100, 80, function(v)
			main.BackgroundTransparency = 1 - (v / 100) * 0.9
		end)
		d:CreateButton("Reset UI", function()
			setTheme("Midnight")
			Library:ResetAll()
			main.Position = UDim2.new(0.5, -win.DefaultSize.X.Offset / 2, 0.5, -win.DefaultSize.Y.Offset / 2)
			tween(main, {Size = win.DefaultSize}, 0.3)
			Library:Notify("ren ui", "reset done", 2)
		end)
		local t = cus:CreateSection("Themes")
		for name, _ in pairs(themes) do
			t:CreateButton(name, function()
				setTheme(name)
				Library:Notify("theme", "now using " .. name, 2)
			end)
		end
	end

	-- settings tab
	local set = win:CreateTab("Settings", 9992)
	do
		local s = set:CreateSection("Misc")
		-- anti afk
		local VirtualUser = game:GetService("VirtualUser")
		local afkConn = nil
		local function afk(on)
			if afkConn then afkConn:Disconnect() afkConn = nil end
			if on then
				afkConn = plr.Idled:Connect(function()
					pcall(function()
						VirtualUser:CaptureController()
						VirtualUser:ClickButton1(Vector2.new(0, 0))
					end)
				end)
			end
		end
		afk(true)
		s:CreateToggle("Anti-AFK", true, function(v) afk(v) end)
		s:CreateToggle("Notifications", true, function(v) Library._notifOff = not v end)
		s:CreateButton("Destroy UI", function() Library:Unload() end)
	end

	-- show home first
	if #win.Tabs > 0 then
		local first = nil
		for _, t in pairs(win.Tabs) do
			if t.Name == "Home" then first = t break end
		end
		first = first or win.Tabs[1]
		win.Current = first
		for _, t in pairs(win.Tabs) do
			t.Page.Visible = (t == first)
			if t == first then
				t.Btn.BackgroundTransparency = 0
				t.Btn.BackgroundColor3 = T.Hover
				t.Btn.TextColor3 = T.Text
			else
				t.Btn.BackgroundTransparency = 1
				t.Btn.TextColor3 = T.Sub
			end
		end
	end

	return win
end

return Library
