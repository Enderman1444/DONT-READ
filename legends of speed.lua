local library = {
	windowcount = 0;
}

local dragger = {}; 
local resizer = {};

do
	local mouse = game:GetService("Players").LocalPlayer:GetMouse();
	local inputService = game:GetService('UserInputService');
	local heartbeat = game:GetService("RunService").Heartbeat;
	-- // credits to Ririchi / Inori for this cute drag function :)
	function dragger.new(frame)
	    local s, event = pcall(function()
	    	return frame.MouseEnter
	    end)

	    if s then
	    	frame.Active = true;

	    	event:connect(function()
	    		local input = frame.InputBegan:connect(function(key)
	    			if key.UserInputType == Enum.UserInputType.MouseButton1 then
	    				local objectPosition = Vector2.new(mouse.X - frame.AbsolutePosition.X, mouse.Y - frame.AbsolutePosition.Y);
	    				while heartbeat:wait() and inputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) do
	    					frame:TweenPosition(UDim2.new(0, mouse.X - objectPosition.X + (frame.Size.X.Offset * frame.AnchorPoint.X), 0, mouse.Y - objectPosition.Y + (frame.Size.Y.Offset * frame.AnchorPoint.Y)), 'Out', 'Quad', 0.1, true);
	    				end
	    			end
	    		end)

	    		local leave;
	    		leave = frame.MouseLeave:connect(function()
	    			input:disconnect();
	    			leave:disconnect();
	    		end)
	    	end)
	    end
	end
	
	function resizer.new(p, s)
		p:GetPropertyChangedSignal('AbsoluteSize'):connect(function()
			s.Size = UDim2.new(s.Size.X.Scale, s.Size.X.Offset, s.Size.Y.Scale, p.AbsoluteSize.Y);
		end)
	end
end


local defaults = {
	txtcolor = Color3.fromRGB(255, 255, 255),
	underline = Color3.fromRGB(0, 255, 140),
	barcolor = Color3.fromRGB(40, 40, 40),
	bgcolor = Color3.fromRGB(30, 30, 30),
}

function library:Create(class, props)
	local object = Instance.new(class);

	for i, prop in next, props do
		if i ~= "Parent" then
			object[i] = prop;
		end
	end

	object.Parent = props.Parent;
	return object;
end

function library:CreateWindow(options)
	assert(options.text, "no name");
	local window = {
		count = 0;
		toggles = {},
		closed = false;
	}

	local options = options or {};
	setmetatable(options, {__index = defaults})

	self.windowcount = self.windowcount + 1;

	library.gui = library.gui or self:Create("ScreenGui", {Name = "UILibrary", Parent = game:GetService("CoreGui")})
	window.frame = self:Create("Frame", {
		Name = options.text;
		Parent = self.gui,
		Active = true,
		BackgroundTransparency = 0,
		Size = UDim2.new(0, 190, 0, 30),
		Position = UDim2.new(0, (15 + ((200 * self.windowcount) - 200)), 0, 15),
		BackgroundColor3 = options.barcolor,
		BorderSizePixel = 0;
	})

	window.background = self:Create('Frame', {
		Name = 'Background';
		Parent = window.frame,
		BorderSizePixel = 0;
		BackgroundColor3 = options.bgcolor,
		Position = UDim2.new(0, 0, 1, 0),
		Size = UDim2.new(1, 0, 0, 25),
		ClipsDescendants = true;
	})
	
	window.container = self:Create('Frame', {
		Name = 'Container';
		Parent = window.frame,
		BorderSizePixel = 0;
		BackgroundColor3 = options.bgcolor,
		Position = UDim2.new(0, 0, 1, 0),
		Size = UDim2.new(1, 0, 0.3, 0),
		ClipsDescendants = true;
	})
	
	window.organizer = self:Create('UIListLayout', {
		Name = 'Sorter';
		Padding = UDim.new(0, 1);
		SortOrder = Enum.SortOrder.LayoutOrder;
		Parent = window.container;
	})
	
	window.padder = self:Create('UIPadding', {
		Name = 'Padding';
		PaddingLeft = UDim.new(0, 10);
		PaddingTop = UDim.new(0, 5);
		Parent = window.container;
	})

	self:Create("Frame", {
		Name = 'Underline';
		Size = UDim2.new(1, 0, 0, 1),
		Position = UDim2.new(0, 0, 1, -1),
		BorderSizePixel = 0;
		BackgroundColor3 = options.underline;
		Parent = window.frame
	})

	local togglebutton = self:Create("TextButton", {
		Name = 'Toggle';
		ZIndex = 2,
		BackgroundTransparency = 1;
		Position = UDim2.new(1, -25, 0, 0),
		Size = UDim2.new(0, 25, 1, 0),
		Text = "-",
		TextSize = 17,
		TextColor3 = options.txtcolor,
		Font = Enum.Font.SourceSans;
		Parent = window.frame,
	});

	togglebutton.MouseButton1Click:connect(function()
		window.closed = not window.closed
		togglebutton.Text = (window.closed and "+" or "-")
		if window.closed then
			window:Resize(true, UDim2.new(1, 0, 0, 0))
		else
			window:Resize(true)
		end
	end)

	self:Create("TextLabel", {
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1;
		BorderSizePixel = 0;
		TextColor3 = options.txtcolor,
		TextColor3 = (options.bartextcolor or Color3.fromRGB(255, 255, 255));
		TextSize = 17,
		Font = Enum.Font.SourceSansSemibold;
		Text = options.text or "window",
		Name = "Window",
		Parent = window.frame,
	})

	do
		dragger.new(window.frame)
		resizer.new(window.background, window.container);
	end

	local function getSize()
		local ySize = 0;
		for i, object in next, window.container:GetChildren() do
			if (not object:IsA('UIListLayout')) and (not object:IsA('UIPadding')) then
				ySize = ySize + object.AbsoluteSize.Y
			end
		end
		return UDim2.new(1, 0, 0, ySize + 10)
	end

	function window:Resize(tween, change)
		local size = change or getSize()
		self.container.ClipsDescendants = true;
		
		if tween then
			self.background:TweenSize(size, "Out", "Sine", 0.5, true)
		else
			self.background.Size = size
		end
	end

	function window:AddToggle(text, callback)
		self.count = self.count + 1

		callback = callback or function() end
		local label = library:Create("TextLabel", {
			Text =  text,
			Size = UDim2.new(1, -10, 0, 20);
			--Position = UDim2.new(0, 5, 0, ((20 * self.count) - 20) + 5),
			BackgroundTransparency = 1;
			TextColor3 = Color3.fromRGB(255, 255, 255);
			TextXAlignment = Enum.TextXAlignment.Left;
			LayoutOrder = self.Count;
			TextSize = 16,
			Font = Enum.Font.SourceSans,
			Parent = self.container;
		})

		local button = library:Create("TextButton", {
			Text = "OFF",
			TextColor3 = Color3.fromRGB(255, 25, 25),
			BackgroundTransparency = 1;
			Position = UDim2.new(1, -25, 0, 0),
			Size = UDim2.new(0, 25, 1, 0),
			TextSize = 17,
			Font = Enum.Font.SourceSansSemibold,
			Parent = label;
		})

		button.MouseButton1Click:connect(function()
			self.toggles[text] = (not self.toggles[text])
			button.TextColor3 = (self.toggles[text] and Color3.fromRGB(0, 255, 140) or Color3.fromRGB(255, 25, 25))
			button.Text =(self.toggles[text] and "ON" or "OFF")

			callback(self.toggles[text])
		end)

		self:Resize()
		return button
	end

	function window:AddBox(text, callback)
		self.count = self.count + 1
		callback = callback or function() end

		local box = library:Create("TextBox", {
			PlaceholderText = text,
			Size = UDim2.new(1, -10, 0, 20);
			--Position = UDim2.new(0, 5, 0, ((20 * self.count) - 20) + 5),
			BackgroundTransparency = 0.75;
			BackgroundColor3 = options.boxcolor,
			TextColor3 = Color3.fromRGB(255, 255, 255);
			TextXAlignment = Enum.TextXAlignment.Center;
			TextSize = 16,
			Text = "",
			Font = Enum.Font.SourceSans,
			LayoutOrder = self.Count;
			BorderSizePixel = 0;
			Parent = self.container;
		})

		box.FocusLost:connect(function(...)
			callback(box, ...)
		end)

		self:Resize()
		return box
	end

	function window:AddDestroy(text, callback)
		self.count = self.count + 1

		callback = callback or function() end
		local button = library:Create("TextButton", {
			Text =  text,
			Size = UDim2.new(1, -10, 0, 20);
			--Position = UDim2.new(0, 5, 0, ((20 * self.count) - 20) + 5),
			BackgroundTransparency = 0;
			BackgroundColor3 = Color3.fromRGB(50,50,50);
			BorderColor3 = Color3.fromRGB(150,150,150);
			TextColor3 = Color3.fromRGB(255, 255, 255);
			TextXAlignment = Enum.TextXAlignment.Center;
			TextSize = 16,
			Font = Enum.Font.SourceSans,
			LayoutOrder = self.Count;
			Parent = self.container;
		})

button.MouseButton1Click:connect(callback)
		self:Resize()
		return button
	end

function window:AddButton(text, callback)
		self.count = self.count + 1

		callback = callback or function() end
		local button = library:Create("TextButton", {
			Text =  text,
			Size = UDim2.new(1, -10, 0, 20);
			--Position = UDim2.new(0, 5, 0, ((20 * self.count) - 20) + 5),
			BackgroundTransparency = 0;
			BackgroundColor3 = Color3.fromRGB(65,65,65);
			BorderColor3 = Color3.fromRGB(150,150,150);
			BorderSizePixel = 0;
			TextColor3 = Color3.fromRGB(255, 255, 255);
			TextXAlignment = Enum.TextXAlignment.Center;
			TextSize = 16,
			Font = Enum.Font.SourceSans,
			LayoutOrder = self.Count;
			Parent = self.container;
		})

		button.MouseButton1Click:connect(callback)
		self:Resize()
		return button
	end
	
	function window:AddLabel(text)
		self.count = self.count + 1;
		
		local tSize = game:GetService('TextService'):GetTextSize(text, 16, Enum.Font.SourceSans, Vector2.new(math.huge, math.huge))

		local button = library:Create("TextLabel", {
			Text =  text,
			Size = UDim2.new(1, -10, 0, tSize.Y + 5);
			TextScaled = false;
			BackgroundTransparency = 1;
			TextColor3 = Color3.fromRGB(255, 255, 255);
			TextXAlignment = Enum.TextXAlignment.Left;
			TextSize = 16,
			Font = Enum.Font.SourceSans,
			LayoutOrder = self.Count;
			Parent = self.container;
		})

		self:Resize()
		return button
	end

function window:AddDropdown(options, callback)
		self.count = self.count + 1
		local default = options[1] or "";
		
		callback = callback or function() end
		local dropdown = library:Create("TextLabel", {
			Size = UDim2.new(1, -10, 0, 20);
			BackgroundTransparency = 0.75;
			BackgroundColor3 = options.boxcolor,
			TextColor3 = Color3.fromRGB(255, 255, 255);
			TextXAlignment = Enum.TextXAlignment.Center;
			TextSize = 16,
			Text = default,
			Font = Enum.Font.SourceSans,
			BorderSizePixel = 0;
			LayoutOrder = self.Count;
			Parent = self.container;
		})
		
		local button = library:Create("ImageButton",{
			BackgroundTransparency = 1;
			Image = 'rbxassetid://3234893186';
			Size = UDim2.new(0, 18, 1, 0);
			Position = UDim2.new(1, -20, 0, 0);
			Parent = dropdown;
		})
		
		local frame;
		
		local function isInGui(frame)
			local mloc = game:GetService('UserInputService'):GetMouseLocation();
			local mouse = Vector2.new(mloc.X, mloc.Y - 36);
			
			local x1, x2 = frame.AbsolutePosition.X, frame.AbsolutePosition.X + frame.AbsoluteSize.X;
			local y1, y2 = frame.AbsolutePosition.Y, frame.AbsolutePosition.Y + frame.AbsoluteSize.Y;
		
			return (mouse.X >= x1 and mouse.X <= x2) and (mouse.Y >= y1 and mouse.Y <= y2)
		end

		local function count(t)
			local c = 0;
			for i, v in next, t do
				c = c + 1
			end 
			return c;
		end
		
		button.MouseButton1Click:connect(function()
			if count(options) == 0 then
				return
			end

			if frame then
				frame:Destroy();
				frame = nil;
			end
			
			self.container.ClipsDescendants = false;

			frame = library:Create('Frame', {
				Position = UDim2.new(0, 0, 1, 0);
				BackgroundColor3 = Color3.fromRGB(40, 40, 40);
				Size = UDim2.new(0, dropdown.AbsoluteSize.X, 0, (count(options) * 21));
				BorderSizePixel = 0;
				Parent = dropdown;
				ClipsDescendants = true;
				ZIndex = 2;
			})
			
			library:Create('UIListLayout', {
				Name = 'Layout';
				Parent = frame;
			})

			for i, option in next, options do
				local selection = library:Create('TextButton', {
					Text = option;
					BackgroundColor3 = Color3.fromRGB(40, 40, 40);
					TextColor3 = Color3.fromRGB(255, 255, 255);
					BorderSizePixel = 0;
					TextSize = 16;
					Font = Enum.Font.SourceSans;
					Size = UDim2.new(1, 0, 0, 21);
					Parent = frame;
					ZIndex = 2;
				})
				
				selection.MouseButton1Click:connect(function()
					dropdown.Text = option;
					callback(option)
					frame.Size = UDim2.new(1, 0, 0, 0);
					game:GetService('Debris'):AddItem(frame, 0.1)
				end)
			end
		end);

		game:GetService('UserInputService').InputBegan:connect(function(m)
			if m.UserInputType == Enum.UserInputType.MouseButton1 then
				if frame and (not isInGui(frame)) then
					game:GetService('Debris'):AddItem(frame);
				end
			end
		end)
		
		callback(default);
		self:Resize()
		return {
			Refresh = function(self, array)
				game:GetService('Debris'):AddItem(frame);
				options = array
				dropdown.Text = options[1];
			end
		}
	end;
	
	
	return window
end

local example = library:CreateWindow({
  text = "Auto Stuff"
})

local island = library:CreateWindow({
  text = "Island TP"
})

local speed = library:CreateWindow({
  text = "Recommended Speed"
})

local eggs = library:CreateWindow({
  text = "Open Eggs"
})

local credits = library:CreateWindow({text='Credits'})
credits:AddLabel("Credits:ToxicParents#7542\nVersion 1.2\nwally: UI")

example:AddToggle("Auto Farm Orbs",function(state)
	_G.Farm = (state and true or false)
	wait()
	while _G.Farm == true do
		wait()
		game.ReplicatedStorage.rEvents.orbEvent:FireServer("collectOrb","Red Orb","Magma City")
		game.ReplicatedStorage.rEvents.orbEvent:FireServer("collectOrb","Red Orb","Magma City")
		game.ReplicatedStorage.rEvents.orbEvent:FireServer("collectOrb","Red Orb","Magma City")
		game.ReplicatedStorage.rEvents.orbEvent:FireServer("collectOrb","Red Orb","Magma City")
		game.ReplicatedStorage.rEvents.orbEvent:FireServer("collectOrb","Red Orb","Magma City")
		game.ReplicatedStorage.rEvents.orbEvent:FireServer("collectOrb","Red Orb","Magma City")
		game.ReplicatedStorage.rEvents.orbEvent:FireServer("collectOrb","Red Orb","Magma City")
		game.ReplicatedStorage.rEvents.orbEvent:FireServer("collectOrb","Red Orb","Magma City")
		game.ReplicatedStorage.rEvents.orbEvent:FireServer("collectOrb","Red Orb","Magma City")
		game.ReplicatedStorage.rEvents.orbEvent:FireServer("collectOrb","Red Orb","Magma City")
		game.ReplicatedStorage.rEvents.orbEvent:FireServer("collectOrb","Red Orb","Magma City")
		game.ReplicatedStorage.rEvents.orbEvent:FireServer("collectOrb","Red Orb","Magma City")
		game.ReplicatedStorage.rEvents.orbEvent:FireServer("collectOrb","Red Orb","Magma City")
		game.ReplicatedStorage.rEvents.orbEvent:FireServer("collectOrb","Red Orb","Magma City")
		game.ReplicatedStorage.rEvents.orbEvent:FireServer("collectOrb","Red Orb","Magma City")
		game.ReplicatedStorage.rEvents.orbEvent:FireServer("collectOrb","Red Orb","Magma City")
		game.ReplicatedStorage.rEvents.orbEvent:FireServer("collectOrb","Red Orb","Magma City")
		game.ReplicatedStorage.rEvents.orbEvent:FireServer("collectOrb","Red Orb","Magma City")
game.ReplicatedStorage.rEvents.orbEvent:FireServer("collectOrb","Red Orb","City")
		game.ReplicatedStorage.rEvents.orbEvent:FireServer("collectOrb","Red Orb","City")
		game.ReplicatedStorage.rEvents.orbEvent:FireServer("collectOrb","Red Orb","City")
		game.ReplicatedStorage.rEvents.orbEvent:FireServer("collectOrb","Red Orb","City")
		game.ReplicatedStorage.rEvents.orbEvent:FireServer("collectOrb","Red Orb","City")
		game.ReplicatedStorage.rEvents.orbEvent:FireServer("collectOrb","Red Orb","City")
		game.ReplicatedStorage.rEvents.orbEvent:FireServer("collectOrb","Red Orb","City")
		game.ReplicatedStorage.rEvents.orbEvent:FireServer("collectOrb","Red Orb","City")
		game.ReplicatedStorage.rEvents.orbEvent:FireServer("collectOrb","Red Orb","City")
		game.ReplicatedStorage.rEvents.orbEvent:FireServer("collectOrb","Red Orb","City")
		game.ReplicatedStorage.rEvents.orbEvent:FireServer("collectOrb","Red Orb","City")
		game.ReplicatedStorage.rEvents.orbEvent:FireServer("collectOrb","Red Orb","City")
		game.ReplicatedStorage.rEvents.orbEvent:FireServer("collectOrb","Red Orb","City")
		game.ReplicatedStorage.rEvents.orbEvent:FireServer("collectOrb","Red Orb","City")
		game.ReplicatedStorage.rEvents.orbEvent:FireServer("collectOrb","Red Orb","City")
		game.ReplicatedStorage.rEvents.orbEvent:FireServer("collectOrb","Red Orb","City")
		game.ReplicatedStorage.rEvents.orbEvent:FireServer("collectOrb","Red Orb","City")
		game.ReplicatedStorage.rEvents.orbEvent:FireServer("collectOrb","Red Orb","City")
game.ReplicatedStorage.rEvents.orbEvent:FireServer("collectOrb","Red Orb","Snow City")
		game.ReplicatedStorage.rEvents.orbEvent:FireServer("collectOrb","Red Orb","Snow City")
		game.ReplicatedStorage.rEvents.orbEvent:FireServer("collectOrb","Red Orb","Snow City")
		game.ReplicatedStorage.rEvents.orbEvent:FireServer("collectOrb","Red Orb","Snow City")
		game.ReplicatedStorage.rEvents.orbEvent:FireServer("collectOrb","Red Orb","Snow City")
		game.ReplicatedStorage.rEvents.orbEvent:FireServer("collectOrb","Red Orb","Snow City")
		game.ReplicatedStorage.rEvents.orbEvent:FireServer("collectOrb","Red Orb","Snow City")
		game.ReplicatedStorage.rEvents.orbEvent:FireServer("collectOrb","Red Orb","Snow City")
		game.ReplicatedStorage.rEvents.orbEvent:FireServer("collectOrb","Red Orb","Snow City")
		game.ReplicatedStorage.rEvents.orbEvent:FireServer("collectOrb","Red Orb","Snow City")
		game.ReplicatedStorage.rEvents.orbEvent:FireServer("collectOrb","Red Orb","Snow City")
		game.ReplicatedStorage.rEvents.orbEvent:FireServer("collectOrb","Red Orb","Snow City")
		game.ReplicatedStorage.rEvents.orbEvent:FireServer("collectOrb","Red Orb","Snow City")
		game.ReplicatedStorage.rEvents.orbEvent:FireServer("collectOrb","Red Orb","Snow City")
		game.ReplicatedStorage.rEvents.orbEvent:FireServer("collectOrb","Red Orb","Snow City")
		game.ReplicatedStorage.rEvents.orbEvent:FireServer("collectOrb","Red Orb","Snow City")
		game.ReplicatedStorage.rEvents.orbEvent:FireServer("collectOrb","Red Orb","Snow City")
		game.ReplicatedStorage.rEvents.orbEvent:FireServer("collectOrb","Red Orb","Snow City")
		end
		end)

example:AddToggle("Auto Farm Gems",function(state)
	_G.Gems = (state and true or false)
	wait()
	while _G.Gems == true do
		wait()
		game.ReplicatedStorage.rEvents.orbEvent:FireServer("collectOrb","Gem","City")
		game.ReplicatedStorage.rEvents.orbEvent:FireServer("collectOrb","Gem","City")
		game.ReplicatedStorage.rEvents.orbEvent:FireServer("collectOrb","Gem","City")
		game.ReplicatedStorage.rEvents.orbEvent:FireServer("collectOrb","Gem","City")
		game.ReplicatedStorage.rEvents.orbEvent:FireServer("collectOrb","Gem","City")
		game.ReplicatedStorage.rEvents.orbEvent:FireServer("collectOrb","Gem","City")
		game.ReplicatedStorage.rEvents.orbEvent:FireServer("collectOrb","Gem","City")
		game.ReplicatedStorage.rEvents.orbEvent:FireServer("collectOrb","Gem","City")
		game.ReplicatedStorage.rEvents.orbEvent:FireServer("collectOrb","Gem","City")
		game.ReplicatedStorage.rEvents.orbEvent:FireServer("collectOrb","Gem","City")
		game.ReplicatedStorage.rEvents.orbEvent:FireServer("collectOrb","Gem","City")
		game.ReplicatedStorage.rEvents.orbEvent:FireServer("collectOrb","Gem","City")
		game.ReplicatedStorage.rEvents.orbEvent:FireServer("collectOrb","Gem","City")
		game.ReplicatedStorage.rEvents.orbEvent:FireServer("collectOrb","Gem","City")
		game.ReplicatedStorage.rEvents.orbEvent:FireServer("collectOrb","Gem","City")
		game.ReplicatedStorage.rEvents.orbEvent:FireServer("collectOrb","Gem","City")
		game.ReplicatedStorage.rEvents.orbEvent:FireServer("collectOrb","Gem","City")
		game.ReplicatedStorage.rEvents.orbEvent:FireServer("collectOrb","Gem","City")
		game.ReplicatedStorage.rEvents.orbEvent:FireServer("collectOrb","Gem","City")
		game.ReplicatedStorage.rEvents.orbEvent:FireServer("collectOrb","Gem","City")
		game.ReplicatedStorage.rEvents.orbEvent:FireServer("collectOrb","Gem","City")
		game.ReplicatedStorage.rEvents.orbEvent:FireServer("collectOrb","Gem","City")
		game.ReplicatedStorage.rEvents.orbEvent:FireServer("collectOrb","Gem","City")
		game.ReplicatedStorage.rEvents.orbEvent:FireServer("collectOrb","Gem","City")
		game.ReplicatedStorage.rEvents.orbEvent:FireServer("collectOrb","Gem","City")
		game.ReplicatedStorage.rEvents.orbEvent:FireServer("collectOrb","Gem","City")
		game.ReplicatedStorage.rEvents.orbEvent:FireServer("collectOrb","Gem","City")
		game.ReplicatedStorage.rEvents.orbEvent:FireServer("collectOrb","Gem","City")
		end
		end)

		example:AddToggle("Auto Hoops",function(state)
	_G.Hoops = (state and true or false)
	wait()
	while _G.Hoops == true do
		wait()
    local children = workspace.Hoops:GetChildren()
    for i, child in ipairs(children) do
        if child.Name == "Hoop" then
            child.CFrame = game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame
        end
        end
        end
		end)


example:AddToggle("Auto Rebirth",function(state)
	_G.Rebirth = (state and true or false)
	wait()
	while _G.Rebirth == true do
		wait()
		game.ReplicatedStorage.rEvents.rebirthEvent:FireServer("rebirthRequest")
		end
		end)

		island:AddButton("Spawn", function()
game.Players.LocalPlayer.Character:MoveTo(Vector3.new(-559.2, -7.45058e-08, 417.4))
end)

island:AddButton("Snow City", function()
game.Players.LocalPlayer.Character:MoveTo(Vector3.new(-858.358, 0.5, 2170.35))
end)

island:AddButton("Magma City", function()
game.Players.LocalPlayer.Character:MoveTo(Vector3.new(1707.25, 0.550008, 4331.05))
end)

island:AddButton("Legends Highway", function()
game.Players.LocalPlayer.Character:MoveTo(Vector3.new(3594.68, 214.804, 7274.56))
end)

eggs:AddToggle("Best Egg",function(state)
	_G.BestEgg = (state and true or false)
	wait()
	while _G.BestEgg == true do
		wait()
		game.ReplicatedStorage.rEvents.openCrystalRemote:InvokeServer("openCrystal", "Electro Legends Crystal")
		end
		end)

		speed:AddButton("Speed 300", function()
		game.ReplicatedStorage.rEvents.changeSpeedJumpRemote:InvokeServer("changeSpeed", 300)
		end)

				speed:AddButton("Jump 200", function()
		game.ReplicatedStorage.rEvents.changeSpeedJumpRemote:InvokeServer("changeJump", 200)
		end)

		example:AddToggle("Auto Evolve (wip)",function(state)
	_G.Evolve = (state and true or false)
	wait()
	while _G.Evolve == true do
		wait()
		game.Replicatedstorage.rEvents.petEvolveEvent:FireServer("evolvePet", "all")
		end
		end)

example:AddDestroy("Destroy GUI",function()
	library.gui:Destroy()
	end)

--[[
    Synapse Xen v1.1.2 by Synapse GP
    VM Hash: 19373269317e1fd632a74ab620c0fac0880a9d673a5d724b5912e91c37462c91
]]

local SynapseXen_liiIiI=select;local SynapseXen_liiiiilIII=string.byte;local SynapseXen_illIli=string.sub;local SynapseXen_iliIIliiliillI=string.char;local SynapseXen_iIillII=type;local SynapseXen_lilillIl=table.concat;local unpack=unpack;local setmetatable=setmetatable;local pcall=pcall;local SynapseXen_IllIli,SynapseXen_iiIlillIIIiiiiliI,SynapseXen_IlIilllIl,SynapseXen_lIiIlIiIIlliilIlII;if bit and bit.bxor then SynapseXen_IllIli=bit.bxor;SynapseXen_iiIlillIIIiiiiliI=function(SynapseXen_ilIiiI,SynapseXen_IliIl)local SynapseXen_Iiliii=SynapseXen_IllIli(SynapseXen_ilIiiI,SynapseXen_IliIl)if SynapseXen_Iiliii<0 then SynapseXen_Iiliii=4294967296+SynapseXen_Iiliii end;return SynapseXen_Iiliii end else SynapseXen_IllIli=function(SynapseXen_ilIiiI,SynapseXen_IliIl)local SynapseXen_iiilIIiIilIlIi=function(SynapseXen_iIIIlllIiI,SynapseXen_lIIiIlIll)return SynapseXen_iIIIlllIiI%(SynapseXen_lIIiIlIll*2)>=SynapseXen_lIIiIlIll end;local SynapseXen_iIIIiIiIiIllliiliI=0;for SynapseXen_iiIlIlliliIIIlliIl=0,31 do SynapseXen_iIIIiIiIiIllliiliI=SynapseXen_iIIIiIiIiIllliiliI+(SynapseXen_iiilIIiIilIlIi(SynapseXen_ilIiiI,2^SynapseXen_iiIlIlliliIIIlliIl)~=SynapseXen_iiilIIiIilIlIi(SynapseXen_IliIl,2^SynapseXen_iiIlIlliliIIIlliIl)and 2^SynapseXen_iiIlIlliliIIIlliIl or 0)end;return SynapseXen_iIIIiIiIiIllliiliI end;SynapseXen_iiIlillIIIiiiiliI=SynapseXen_IllIli end;SynapseXen_IlIilllIl=function(SynapseXen_iiliiI,SynapseXen_iIIIl,SynapseXen_liiIliIIiIiliiliI)return(SynapseXen_iiliiI+SynapseXen_iIIIl)%SynapseXen_liiIliIIiIiliiliI end;SynapseXen_lIiIlIiIIlliilIlII=function(SynapseXen_iiliiI,SynapseXen_iIIIl,SynapseXen_liiIliIIiIiliiliI)return(SynapseXen_iiliiI-SynapseXen_iIIIl)%SynapseXen_liiIliIIiIiliiliI end;local function SynapseXen_iIllIlIlIiilil(SynapseXen_Iiliii)if SynapseXen_Iiliii<0 then SynapseXen_Iiliii=4294967296+SynapseXen_Iiliii end;return SynapseXen_Iiliii end;local getfenv=getfenv;if not getfenv then getfenv=function()return _ENV end end;local SynapseXen_IllIlIIllilIliiIiII={}local SynapseXen_IIlIiilIiil={}local SynapseXen_IlllllIIlIIlliIlI;local SynapseXen_llIIIIIilI;local SynapseXen_IiiiIilIiiIiIIilI={}local SynapseXen_IiIiiI={}for SynapseXen_iiIlIlliliIIIlliIl=0,255 do local SynapseXen_liiIIlliilillIIi,SynapseXen_ilIIlIlIiIlliilii=SynapseXen_iliIIliiliillI(SynapseXen_iiIlIlliliIIIlliIl),SynapseXen_iliIIliiliillI(SynapseXen_iiIlIlliliIIIlliIl,0)SynapseXen_IiiiIilIiiIiIIilI[SynapseXen_liiIIlliilillIIi]=SynapseXen_ilIIlIlIiIlliilii;SynapseXen_IiIiiI[SynapseXen_ilIIlIlIiIlliilii]=SynapseXen_liiIIlliilillIIi end;local function SynapseXen_IIIliiIIiiIIillIlIi(SynapseXen_IlIiillilIIlIlIiIiII,SynapseXen_lilIiiiiilIillI,SynapseXen_llIIIliIlIIliiI,SynapseXen_iilIiiliiili)if SynapseXen_llIIIliIlIIliiI>=256 then SynapseXen_llIIIliIlIIliiI,SynapseXen_iilIiiliiili=0,SynapseXen_iilIiiliiili+1;if SynapseXen_iilIiiliiili>=256 then SynapseXen_lilIiiiiilIillI={}SynapseXen_iilIiiliiili=1 end end;SynapseXen_lilIiiiiilIillI[SynapseXen_iliIIliiliillI(SynapseXen_llIIIliIlIIliiI,SynapseXen_iilIiiliiili)]=SynapseXen_IlIiillilIIlIlIiIiII;SynapseXen_llIIIliIlIIliiI=SynapseXen_llIIIliIlIIliiI+1;return SynapseXen_lilIiiiiilIillI,SynapseXen_llIIIliIlIIliiI,SynapseXen_iilIiiliiili end;local function SynapseXen_liiiIllliIillliI(SynapseXen_IllIIiII)local function SynapseXen_liiIlllIl(SynapseXen_IlliiIlIiIilIIlIii)local SynapseXen_iilIiiliiili='ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'SynapseXen_IlliiIlIiIilIIlIii=string.gsub(SynapseXen_IlliiIlIiIilIIlIii,'[^'..SynapseXen_iilIiiliiili..'=]','')return SynapseXen_IlliiIlIiIilIIlIii:gsub('.',function(SynapseXen_iiliiI)if SynapseXen_iiliiI=='='then return''end;local SynapseXen_iIliiIIlili,SynapseXen_IIiIIiIliili='',SynapseXen_iilIiiliiili:find(SynapseXen_iiliiI)-1;for SynapseXen_iiIlIlliliIIIlliIl=6,1,-1 do SynapseXen_iIliiIIlili=SynapseXen_iIliiIIlili..(SynapseXen_IIiIIiIliili%2^SynapseXen_iiIlIlliliIIIlliIl-SynapseXen_IIiIIiIliili%2^(SynapseXen_iiIlIlliliIIIlliIl-1)>0 and'1'or'0')end;return SynapseXen_iIliiIIlili end):gsub('%d%d%d?%d?%d?%d?%d?%d?',function(SynapseXen_iiliiI)if#SynapseXen_iiliiI~=8 then return''end;local SynapseXen_iilIlIllillIIlIlli=0;for SynapseXen_iiIlIlliliIIIlliIl=1,8 do SynapseXen_iilIlIllillIIlIlli=SynapseXen_iilIlIllillIIlIlli+(SynapseXen_iiliiI:sub(SynapseXen_iiIlIlliliIIIlliIl,SynapseXen_iiIlIlliliIIIlliIl)=='1'and 2^(8-SynapseXen_iiIlIlliliIIIlliIl)or 0)end;return string.char(SynapseXen_iilIlIllillIIlIlli)end)end;SynapseXen_IllIIiII=SynapseXen_liiIlllIl(SynapseXen_IllIIiII)local SynapseXen_llilllIIiiIIIIiI=SynapseXen_illIli(SynapseXen_IllIIiII,1,1)if SynapseXen_llilllIIiiIIIIiI=="u"then return SynapseXen_illIli(SynapseXen_IllIIiII,2)elseif SynapseXen_llilllIIiiIIIIiI~="c"then error("Synapse Xen - Failed to verify bytecode. Please make sure your Lua implementation supports non-null terminated strings.")end;SynapseXen_IllIIiII=SynapseXen_illIli(SynapseXen_IllIIiII,2)local SynapseXen_IlIiIII=#SynapseXen_IllIIiII;local SynapseXen_lilIiiiiilIillI={}local SynapseXen_llIIIliIlIIliiI,SynapseXen_iilIiiliiili=0,1;local SynapseXen_iiIlI={}local SynapseXen_Iiliii=1;local SynapseXen_llIilIiIi=SynapseXen_illIli(SynapseXen_IllIIiII,1,2)SynapseXen_iiIlI[SynapseXen_Iiliii]=SynapseXen_IiIiiI[SynapseXen_llIilIiIi]or SynapseXen_lilIiiiiilIillI[SynapseXen_llIilIiIi]SynapseXen_Iiliii=SynapseXen_Iiliii+1;for SynapseXen_iiIlIlliliIIIlliIl=3,SynapseXen_IlIiIII,2 do local SynapseXen_IliIililliiilI=SynapseXen_illIli(SynapseXen_IllIIiII,SynapseXen_iiIlIlliliIIIlliIl,SynapseXen_iiIlIlliliIIIlliIl+1)local SynapseXen_IIliIlllIiiliI=SynapseXen_IiIiiI[SynapseXen_llIilIiIi]or SynapseXen_lilIiiiiilIillI[SynapseXen_llIilIiIi]if not SynapseXen_IIliIlllIiiliI then error("Synapse Xen - Failed to verify bytecode. Please make sure your Lua implementation supports non-null terminated strings.")end;local SynapseXen_lIiIllil=SynapseXen_IiIiiI[SynapseXen_IliIililliiilI]or SynapseXen_lilIiiiiilIillI[SynapseXen_IliIililliiilI]if SynapseXen_lIiIllil then SynapseXen_iiIlI[SynapseXen_Iiliii]=SynapseXen_lIiIllil;SynapseXen_Iiliii=SynapseXen_Iiliii+1;SynapseXen_lilIiiiiilIillI,SynapseXen_llIIIliIlIIliiI,SynapseXen_iilIiiliiili=SynapseXen_IIIliiIIiiIIillIlIi(SynapseXen_IIliIlllIiiliI..SynapseXen_illIli(SynapseXen_lIiIllil,1,1),SynapseXen_lilIiiiiilIillI,SynapseXen_llIIIliIlIIliiI,SynapseXen_iilIiiliiili)else local SynapseXen_Iilii=SynapseXen_IIliIlllIiiliI..SynapseXen_illIli(SynapseXen_IIliIlllIiiliI,1,1)SynapseXen_iiIlI[SynapseXen_Iiliii]=SynapseXen_Iilii;SynapseXen_Iiliii=SynapseXen_Iiliii+1;SynapseXen_lilIiiiiilIillI,SynapseXen_llIIIliIlIIliiI,SynapseXen_iilIiiliiili=SynapseXen_IIIliiIIiiIIillIlIi(SynapseXen_Iilii,SynapseXen_lilIiiiiilIillI,SynapseXen_llIIIliIlIIliiI,SynapseXen_iilIiiliiili)end;SynapseXen_llIilIiIi=SynapseXen_IliIililliiilI end;return SynapseXen_lilillIl(SynapseXen_iiIlI)end;local function SynapseXen_iiIiIlIll(SynapseXen_IIiiIIIiiill,SynapseXen_iliIIlillliIiI,SynapseXen_iIllIliiIllIlIilIil)if SynapseXen_iIllIliiIllIlIilIil then local SynapseXen_IllliIlIiiiillIi=SynapseXen_IIiiIIIiiill/2^(SynapseXen_iliIIlillliIiI-1)%2^(SynapseXen_iIllIliiIllIlIilIil-1-(SynapseXen_iliIIlillliIiI-1)+1)return SynapseXen_IllliIlIiiiillIi-SynapseXen_IllliIlIiiiillIi%1 else local SynapseXen_IIIIiiillIIiIlllii=2^(SynapseXen_iliIIlillliIiI-1)if SynapseXen_IIiiIIIiiill%(SynapseXen_IIIIiiillIIiIlllii+SynapseXen_IIIIiiillIIiIlllii)>=SynapseXen_IIIIiiillIIiIlllii then return 1 else return 0 end end end;local function SynapseXen_IIlIIlIilIillliill()local SynapseXen_IiilIlIIIliIlIIi=SynapseXen_IllIli(1671622342,SynapseXen_llIIIIIilI)while true do if SynapseXen_IiilIlIIIliIlIIi==SynapseXen_IllIli(826716686,SynapseXen_llIIIIIilI)then return elseif SynapseXen_IiilIlIIIliIlIIi==SynapseXen_IllIli(826727543,SynapseXen_llIIIIIilI)then SynapseXen_IlllllIIlIIlliIlI=function(SynapseXen_iIliiiIIilliIillIiii,SynapseXen_iIliI)return SynapseXen_IllIli(SynapseXen_iIliiiIIilliIillIiii+49141,SynapseXen_iIliI+34887)-SynapseXen_IllIli(1675424607,SynapseXen_llIIIIIilI)end;SynapseXen_IiilIlIIIliIlIIi=SynapseXen_IiilIlIIIliIlIIi-SynapseXen_IllIli(1675407612,SynapseXen_llIIIIIilI)elseif SynapseXen_IiilIlIIIliIlIIi==SynapseXen_IllIli(1671561280,SynapseXen_llIIIIIilI)then SynapseXen_IlllllIIlIIlliIlI=function(SynapseXen_iIliiiIIilliIillIiii,SynapseXen_iIliI)return SynapseXen_IllIli(SynapseXen_iIliiiIIilliIillIiii+40847,SynapseXen_iIliI-43723)+SynapseXen_IllIli(1675405169,SynapseXen_llIIIIIilI)end;SynapseXen_IiilIlIIIliIlIIi=SynapseXen_IiilIlIIIliIlIIi-SynapseXen_IllIli(1797236543,SynapseXen_IIlIiilIiil[3])elseif SynapseXen_IiilIlIIIliIlIIi==SynapseXen_IllIli(2663701244,SynapseXen_IIlIiilIiil[7])then SynapseXen_IlllllIIlIIlliIlI=function(SynapseXen_iIliiiIIilliIillIiii,SynapseXen_iIliI)return SynapseXen_IllIli(SynapseXen_iIliiiIIilliIillIiii+41174,SynapseXen_iIliI+17948)-SynapseXen_IllIli(3252823933,SynapseXen_IIlIiilIiil[4])end;SynapseXen_IiilIlIIIliIlIIi=SynapseXen_IllIli(SynapseXen_IiilIlIIIliIlIIi,SynapseXen_IllIli(972718311,SynapseXen_IIlIiilIiil[3]))elseif SynapseXen_IiilIlIIIliIlIIi==SynapseXen_IllIli(1671587984,SynapseXen_llIIIIIilI)then SynapseXen_IlllllIIlIIlliIlI=function(SynapseXen_iIliiiIIilliIillIiii,SynapseXen_iIliI)return SynapseXen_IllIli(SynapseXen_iIliiiIIilliIillIiii+49063,SynapseXen_iIliI-8471)+SynapseXen_IllIli(2663115261,SynapseXen_IIlIiilIiil[7])end;SynapseXen_IiilIlIIIliIlIIi=SynapseXen_IiilIlIIIliIlIIi+SynapseXen_IllIli(1675410137,SynapseXen_llIIIIIilI)elseif SynapseXen_IiilIlIIIliIlIIi==SynapseXen_IllIli(825594940,SynapseXen_IIlIiilIiil[5])then SynapseXen_IlllllIIlIIlliIlI=function(SynapseXen_iIliiiIIilliIillIiii,SynapseXen_iIliI)return SynapseXen_IllIli(SynapseXen_iIliiiIIilliIillIiii-8799,SynapseXen_iIliI+36566)+SynapseXen_IllIli(925266618,SynapseXen_IIlIiilIiil[1])end;SynapseXen_IiilIlIIIliIlIIi=SynapseXen_IiilIlIIIliIlIIi+SynapseXen_IllIli(1675414148,SynapseXen_llIIIIIilI)elseif SynapseXen_IiilIlIIIliIlIIi==SynapseXen_IllIli(3248226877,SynapseXen_IIlIiilIiil[4])then SynapseXen_IlllllIIlIIlliIlI=function(SynapseXen_iIliiiIIilliIillIiii,SynapseXen_iIliI)return SynapseXen_IllIli(SynapseXen_iIliiiIIilliIillIiii+30477,SynapseXen_iIliI+25182)+SynapseXen_IllIli(925280846,SynapseXen_IIlIiilIiil[1])end;SynapseXen_IiilIlIIIliIlIIi=SynapseXen_IiilIlIIIliIlIIi-SynapseXen_IllIli(1675395705,SynapseXen_llIIIIIilI)elseif SynapseXen_IiilIlIIIliIlIIi==SynapseXen_IllIli(1227606541,SynapseXen_IIlIiilIiil[2])then SynapseXen_IlllllIIlIIlliIlI=function(SynapseXen_iIliiiIIilliIillIiii,SynapseXen_iIliI)return SynapseXen_IllIli(SynapseXen_iIliiiIIilliIillIiii+12325,SynapseXen_iIliI+16840)-SynapseXen_IllIli(1675373866,SynapseXen_llIIIIIilI)end;SynapseXen_IiilIlIIIliIlIIi=SynapseXen_IiilIlIIIliIlIIi+SynapseXen_IllIli(2663096859,SynapseXen_IIlIiilIiil[7])elseif SynapseXen_IiilIlIIIliIlIIi==SynapseXen_IllIli(1671622342,SynapseXen_llIIIIIilI)then SynapseXen_IlllllIIlIIlliIlI=function(SynapseXen_iIliiiIIilliIillIiii,SynapseXen_iIliI)return SynapseXen_IllIli(SynapseXen_iIliiiIIilliIillIiii+22253,SynapseXen_iIliI+9497)-SynapseXen_IllIli(827053567,SynapseXen_IIlIiilIiil[5])end;SynapseXen_IiilIlIIIliIlIIi=SynapseXen_IiilIlIIIliIlIIi+SynapseXen_IllIli(1675404795,SynapseXen_llIIIIIilI)end end end;local function SynapseXen_llilIil(SynapseXen_iiIIiliIlil)local SynapseXen_llIliiiiilliIl=1;local SynapseXen_IIliiiI;local SynapseXen_illilllIiiIililiili;local function SynapseXen_IliliillI()local SynapseXen_iIill=SynapseXen_liiiiilIII(SynapseXen_iiIIiliIlil,SynapseXen_llIliiiiilliIl,SynapseXen_llIliiiiilliIl)SynapseXen_llIliiiiilliIl=SynapseXen_llIliiiiilliIl+1;return SynapseXen_iIill end;local function SynapseXen_IlliIiilIliiI()local SynapseXen_iIIII,SynapseXen_iIliiiIIilliIillIiii,SynapseXen_iIliI,SynapseXen_llIiliii=SynapseXen_liiiiilIII(SynapseXen_iiIIiliIlil,SynapseXen_llIliiiiilliIl,SynapseXen_llIliiiiilliIl+3)SynapseXen_llIliiiiilliIl=SynapseXen_llIliiiiilliIl+4;return SynapseXen_llIiliii*16777216+SynapseXen_iIliI*65536+SynapseXen_iIliiiIIilliIillIiii*256+SynapseXen_iIIII end;local function SynapseXen_iiIiIilIlIIillill()return SynapseXen_IlliIiilIliiI()*4294967296+SynapseXen_IlliIiilIliiI()end;local function SynapseXen_IllIiIIllilI()local SynapseXen_iIIliiIiIilillll=SynapseXen_iiIlillIIIiiiiliI(SynapseXen_IlliIiilIliiI(),SynapseXen_IllIlIIllilIliiIiII[3618600061]or(function(...)local SynapseXen_iiliiI="wally bad bird"local SynapseXen_IiIiIIIIIIIl=SynapseXen_IlllllIIlIIlliIlI(1732910257,1526410628)local SynapseXen_IIiilIllliIili={...}for SynapseXen_iiIlIlliliIIIlliIl,SynapseXen_iIIiiillilIilIIIliI in pairs(SynapseXen_IIiilIllliIili)do local SynapseXen_IlIIiliiiiIliiilIii;local SynapseXen_IiIIlIillili=type(SynapseXen_iIIiiillilIilIIIliI)if SynapseXen_IiIIlIillili=="number"then SynapseXen_IlIIiliiiiIliiilIii=SynapseXen_iIIiiillilIilIIIliI elseif SynapseXen_IiIIlIillili=="string"then SynapseXen_IlIIiliiiiIliiilIii=SynapseXen_iIIiiillilIilIIIliI:len()elseif SynapseXen_IiIIlIillili=="table"then SynapseXen_IlIIiliiiiIliiilIii=SynapseXen_IlllllIIlIIlliIlI(767330537,767336171)end;SynapseXen_IiIiIIIIIIIl=SynapseXen_IiIiIIIIIIIl+SynapseXen_IlIIiliiiiIliiilIii end;SynapseXen_IllIlIIllilIliiIiII[3618600061]=SynapseXen_IllIli(SynapseXen_IllIli(1456567013,SynapseXen_IiIiIIIIIIIl),SynapseXen_IllIli(4110773629,SynapseXen_IIlIiilIiil[2]))-string.len(SynapseXen_iiliiI)-#{710076118,343112081,3404217900,1809398238,834314409,2478406879}return SynapseXen_IllIlIIllilIliiIiII[3618600061]end)({},{}))local SynapseXen_IIiliilIiIli=SynapseXen_iiIlillIIIiiiiliI(SynapseXen_IlliIiilIliiI(),SynapseXen_IllIlIIllilIliiIiII[532260197]or(function(...)local SynapseXen_iiliiI="xen doesn't come with instance caching, sorry superskater"local SynapseXen_IiIiIIIIIIIl=SynapseXen_IlllllIIlIIlliIlI(2051767910,1249963699)local SynapseXen_IIiilIllliIili={...}for SynapseXen_iiIlIlliliIIIlliIl,SynapseXen_iIIiiillilIilIIIliI in pairs(SynapseXen_IIiilIllliIili)do local SynapseXen_IlIIiliiiiIliiilIii;local SynapseXen_IiIIlIillili=type(SynapseXen_iIIiiillilIilIIIliI)if SynapseXen_IiIIlIillili=="number"then SynapseXen_IlIIiliiiiIliiilIii=SynapseXen_iIIiiillilIilIIIliI elseif SynapseXen_IiIIlIillili=="string"then SynapseXen_IlIIiliiiiIliiilIii=SynapseXen_iIIiiillilIilIIIliI:len()elseif SynapseXen_IiIIlIillili=="table"then SynapseXen_IlIIiliiiiIliiilIii=SynapseXen_IlllllIIlIIlliIlI(3494803833,3494850400)end;SynapseXen_IiIiIIIIIIIl=SynapseXen_IiIiIIIIIIIl+SynapseXen_IlIIiliiiiIliiilIii end;SynapseXen_IllIlIIllilIliiIiII[532260197]=SynapseXen_IllIli(SynapseXen_IllIli(169695518,SynapseXen_IiIiIIIIIIIl),SynapseXen_IllIli(3692448628,SynapseXen_IIlIiilIiil[4]))-string.len(SynapseXen_iiliiI)-#{155615887,3943325075}return SynapseXen_IllIlIIllilIliiIiII[532260197]end)("iilIilIIili",{},"lililliilllIIlllIi","lIIliiIlIiIlli","IIli","iiliIIlIIIIlIi",12850,7228,9468,"iIiiIi"))local SynapseXen_IIiIIliIIiIlillllI=1;local SynapseXen_liilIIIiiiiiIIil=SynapseXen_iiIiIlIll(SynapseXen_IIiliilIiIli,1,20)*2^32+SynapseXen_iIIliiIiIilillll;local SynapseXen_IliliIlIiliI=SynapseXen_iiIiIlIll(SynapseXen_IIiliilIiIli,21,31)local SynapseXen_iliIiliIiiiI=(-1)^SynapseXen_iiIiIlIll(SynapseXen_IIiliilIiIli,32)if SynapseXen_IliliIlIiliI==0 then if SynapseXen_liilIIIiiiiiIIil==0 then return SynapseXen_iliIiliIiiiI*0 else SynapseXen_IliliIlIiliI=1;SynapseXen_IIiIIliIIiIlillllI=0 end elseif SynapseXen_IliliIlIiliI==2047 then if SynapseXen_liilIIIiiiiiIIil==0 then return SynapseXen_iliIiliIiiiI*1/0 else return SynapseXen_iliIiliIiiiI*0/0 end end;return math.ldexp(SynapseXen_iliIiliIiiiI,SynapseXen_IliliIlIiliI-1023)*(SynapseXen_IIiIIliIIiIlillllI+SynapseXen_liilIIIiiiiiIIil/2^52)end;local function SynapseXen_liIIiiiiIIilli(SynapseXen_iIlIIlIlIililll)local SynapseXen_liIlllilillIIiIlliil;if SynapseXen_iIlIIlIlIililll then SynapseXen_liIlllilillIIiIlliil=SynapseXen_illIli(SynapseXen_iiIIiliIlil,SynapseXen_llIliiiiilliIl,SynapseXen_llIliiiiilliIl+SynapseXen_iIlIIlIlIililll-1)SynapseXen_llIliiiiilliIl=SynapseXen_llIliiiiilliIl+SynapseXen_iIlIIlIlIililll else SynapseXen_iIlIIlIlIililll=SynapseXen_IIliiiI()if SynapseXen_iIlIIlIlIililll==0 then return""end;SynapseXen_liIlllilillIIiIlliil=SynapseXen_illIli(SynapseXen_iiIIiliIlil,SynapseXen_llIliiiiilliIl,SynapseXen_llIliiiiilliIl+SynapseXen_iIlIIlIlIililll-1)SynapseXen_llIliiiiilliIl=SynapseXen_llIliiiiilliIl+SynapseXen_iIlIIlIlIililll end;return SynapseXen_liIlllilillIIiIlliil end;local function SynapseXen_IllIiIiIlliIilIIil(SynapseXen_liIlllilillIIiIlliil)local SynapseXen_IllliIlIiiiillIi={}for SynapseXen_iiIlIlliliIIIlliIl=1,#SynapseXen_liIlllilillIIiIlliil do local SynapseXen_IlIll=SynapseXen_liIlllilillIIiIlliil:sub(SynapseXen_iiIlIlliliIIIlliIl,SynapseXen_iiIlIlliliIIIlliIl)SynapseXen_IllliIlIiiiillIi[#SynapseXen_IllliIlIiiiillIi+1]=string.char(SynapseXen_IllIli(string.byte(SynapseXen_IlIll),SynapseXen_IllIlIIllilIliiIiII[3865984922]or(function(...)local SynapseXen_iiliiI="pain is gonna use the backspace method on xen"local SynapseXen_IiIiIIIIIIIl=SynapseXen_IlllllIIlIIlliIlI(793708669,372264904)local SynapseXen_IIiilIllliIili={...}for SynapseXen_iiIlIlliliIIIlliIl,SynapseXen_iIIiiillilIilIIIliI in pairs(SynapseXen_IIiilIllliIili)do local SynapseXen_IlIIiliiiiIliiilIii;local SynapseXen_IiIIlIillili=type(SynapseXen_iIIiiillilIilIIIliI)if SynapseXen_IiIIlIillili=="number"then SynapseXen_IlIIiliiiiIliiilIii=SynapseXen_iIIiiillilIilIIIliI elseif SynapseXen_IiIIlIillili=="string"then SynapseXen_IlIIiliiiiIliiilIii=SynapseXen_iIIiiillilIilIIIliI:len()elseif SynapseXen_IiIIlIillili=="table"then SynapseXen_IlIIiliiiiIliiilIii=SynapseXen_IlllllIIlIIlliIlI(3105945513,3105925123)end;SynapseXen_IiIiIIIIIIIl=SynapseXen_IiIiIIIIIIIl-SynapseXen_IlIIiliiiiIliiilIii end;SynapseXen_IllIlIIllilIliiIiII[3865984922]=SynapseXen_IllIli(SynapseXen_IllIli(1367425551,SynapseXen_IiIiIIIIIIIl),SynapseXen_IllIli(2870464392,SynapseXen_IIlIiilIiil[6]))-string.len(SynapseXen_iiliiI)-#{2852853707,1789560948,651462833,2591252867,1439171881}return SynapseXen_IllIlIIllilIliiIiII[3865984922]end)("iIllIlIiiI","il")))end;return table.concat(SynapseXen_IllliIlIiiiillIi)end;local function SynapseXen_IlIiIiIIlIl()local SynapseXen_iIliiiIll={}local SynapseXen_IlllilIlliIillIiiI={}local SynapseXen_lIIIlii={}local SynapseXen_ilIlIIlIIIIl={[SynapseXen_IllIlIIllilIliiIiII[815314593]or(function(...)local SynapseXen_iiliiI="hi xen crashes on my axon paste plz help"local SynapseXen_IiIiIIIIIIIl=SynapseXen_IlllllIIlIIlliIlI(1534436586,3282230814)local SynapseXen_IIiilIllliIili={...}for SynapseXen_iiIlIlliliIIIlliIl,SynapseXen_iIIiiillilIilIIIliI in pairs(SynapseXen_IIiilIllliIili)do local SynapseXen_IlIIiliiiiIliiilIii;local SynapseXen_IiIIlIillili=type(SynapseXen_iIIiiillilIilIIIliI)if SynapseXen_IiIIlIillili=="number"then SynapseXen_IlIIiliiiiIliiilIii=SynapseXen_iIIiiillilIilIIIliI elseif SynapseXen_IiIIlIillili=="string"then SynapseXen_IlIIiliiiiIliiilIii=SynapseXen_iIIiiillilIilIIIliI:len()elseif SynapseXen_IiIIlIillili=="table"then SynapseXen_IlIIiliiiiIliiilIii=SynapseXen_IlllllIIlIIlliIlI(3524312558,3524301298)end;SynapseXen_IiIiIIIIIIIl=SynapseXen_IiIiIIIIIIIl+SynapseXen_IlIIiliiiiIliiilIii end;SynapseXen_IllIlIIllilIliiIiII[815314593]=SynapseXen_IllIli(SynapseXen_IllIli(3620484567,SynapseXen_IiIiIIIIIIIl),SynapseXen_IllIli(1413427040,SynapseXen_llIIIIIilI))-string.len(SynapseXen_iiliiI)-#{3134201154}return SynapseXen_IllIlIIllilIliiIiII[815314593]end)("llIlliIl")]=SynapseXen_IlllilIlliIillIiiI,[SynapseXen_IllIlIIllilIliiIiII[2161003697]or(function(...)local SynapseXen_iiliiI="imagine using some lua minifier tool and thinking you are a badass"local SynapseXen_IiIiIIIIIIIl=SynapseXen_IlllllIIlIIlliIlI(3393598450,713426497)local SynapseXen_IIiilIllliIili={...}for SynapseXen_iiIlIlliliIIIlliIl,SynapseXen_iIIiiillilIilIIIliI in pairs(SynapseXen_IIiilIllliIili)do local SynapseXen_IlIIiliiiiIliiilIii;local SynapseXen_IiIIlIillili=type(SynapseXen_iIIiiillilIilIIIliI)if SynapseXen_IiIIlIillili=="number"then SynapseXen_IlIIiliiiiIliiilIii=SynapseXen_iIIiiillilIilIIIliI elseif SynapseXen_IiIIlIillili=="string"then SynapseXen_IlIIiliiiiIliiilIii=SynapseXen_iIIiiillilIilIIIliI:len()elseif SynapseXen_IiIIlIillili=="table"then SynapseXen_IlIIiliiiiIliiilIii=SynapseXen_IlllllIIlIIlliIlI(1392509732,1392522358)end;SynapseXen_IiIiIIIIIIIl=SynapseXen_IiIiIIIIIIIl-SynapseXen_IlIIiliiiiIliiilIii end;SynapseXen_IllIlIIllilIliiIiII[2161003697]=SynapseXen_IllIli(SynapseXen_IllIli(804123225,SynapseXen_IiIiIIIIIIIl),SynapseXen_IllIli(14074763,SynapseXen_IIlIiilIiil[7]))-string.len(SynapseXen_iiliiI)-#{3224146896,1798498547}return SynapseXen_IllIlIIllilIliiIiII[2161003697]end)({},2745)]=SynapseXen_iIliiiIll,[SynapseXen_IllIlIIllilIliiIiII[743785857]or(function(...)local SynapseXen_iiliiI="aspect network better obfuscator"local SynapseXen_IiIiIIIIIIIl=SynapseXen_IlllllIIlIIlliIlI(4244552250,4033071285)local SynapseXen_IIiilIllliIili={...}for SynapseXen_iiIlIlliliIIIlliIl,SynapseXen_iIIiiillilIilIIIliI in pairs(SynapseXen_IIiilIllliIili)do local SynapseXen_IlIIiliiiiIliiilIii;local SynapseXen_IiIIlIillili=type(SynapseXen_iIIiiillilIilIIIliI)if SynapseXen_IiIIlIillili=="number"then SynapseXen_IlIIiliiiiIliiilIii=SynapseXen_iIIiiillilIilIIIliI elseif SynapseXen_IiIIlIillili=="string"then SynapseXen_IlIIiliiiiIliiilIii=SynapseXen_iIIiiillilIilIIIliI:len()elseif SynapseXen_IiIIlIillili=="table"then SynapseXen_IlIIiliiiiIliiilIii=SynapseXen_IlllllIIlIIlliIlI(1506709454,1506752747)end;SynapseXen_IiIiIIIIIIIl=SynapseXen_IiIiIIIIIIIl+SynapseXen_IlIIiliiiiIliiilIii end;SynapseXen_IllIlIIllilIliiIiII[743785857]=SynapseXen_IllIli(SynapseXen_IllIli(375867710,SynapseXen_IiIiIIIIIIIl),SynapseXen_IllIli(1918538847,SynapseXen_llIIIIIilI))-string.len(SynapseXen_iiliiI)-#{182255234,374980832}return SynapseXen_IllIlIIllilIliiIiII[743785857]end)("IilIIIililIIli")]=SynapseXen_lIIIlii}SynapseXen_IliliillI()for SynapseXen_lliiiI=1,SynapseXen_IllIli(SynapseXen_illilllIiiIililiili(),SynapseXen_IllIlIIllilIliiIiII[1713937519]or(function()local SynapseXen_iiliiI="hi my 2.5mb script doesn't work with xen please help"SynapseXen_IllIlIIllilIliiIiII[1713937519]=SynapseXen_IllIli(SynapseXen_IlllllIIlIIlliIlI(3495631378,2082384155),SynapseXen_IllIli(4101989835,SynapseXen_IIlIiilIiil[5]))-string.len(SynapseXen_iiliiI)-#{3402349353,1047450155,3606204862,1343022384,2363759309,4161683020,2808482413,1929231710}return SynapseXen_IllIlIIllilIliiIiII[1713937519]end)())do local SynapseXen_IlIlIIiliiilIliiilll=SynapseXen_IllIli(SynapseXen_IlliIiilIliiI(),SynapseXen_IllIlIIllilIliiIiII[284240975]or(function(...)local SynapseXen_iiliiI="what are you trying to say? that fucking one dot + dot + dot + many dots is not adding adding 1 dot + dot and then adding all the dots together????"local SynapseXen_IiIiIIIIIIIl=SynapseXen_IlllllIIlIIlliIlI(118623194,2086771979)local SynapseXen_IIiilIllliIili={...}for SynapseXen_iiIlIlliliIIIlliIl,SynapseXen_iIIiiillilIilIIIliI in pairs(SynapseXen_IIiilIllliIili)do local SynapseXen_IlIIiliiiiIliiilIii;local SynapseXen_IiIIlIillili=type(SynapseXen_iIIiiillilIilIIIliI)if SynapseXen_IiIIlIillili=="number"then SynapseXen_IlIIiliiiiIliiilIii=SynapseXen_iIIiiillilIilIIIliI elseif SynapseXen_IiIIlIillili=="string"then SynapseXen_IlIIiliiiiIliiilIii=SynapseXen_iIIiiillilIilIIIliI:len()elseif SynapseXen_IiIIlIillili=="table"then SynapseXen_IlIIiliiiiIliiilIii=SynapseXen_IlllllIIlIIlliIlI(234967638,235014944)end;SynapseXen_IiIiIIIIIIIl=SynapseXen_IiIiIIIIIIIl+SynapseXen_IlIIiliiiiIliiilIii end;SynapseXen_IllIlIIllilIliiIiII[284240975]=SynapseXen_IllIli(SynapseXen_IllIli(3314452953,SynapseXen_IiIiIIIIIIIl),SynapseXen_IllIli(1709286138,SynapseXen_llIIIIIilI))-string.len(SynapseXen_iiliiI)-#{3195402035,3631068461,149233698,939884478}return SynapseXen_IllIlIIllilIliiIiII[284240975]end)(3778))local SynapseXen_iIIliil=SynapseXen_IliliillI()local SynapseXen_iIillII=SynapseXen_IliliillI()SynapseXen_IliliillI()local SynapseXen_IiiiIliiIliillliIllI={[896369354]=SynapseXen_IlIlIIiliiilIliiilll,[1832923908]=SynapseXen_iIIliil,[1021058956]=SynapseXen_iiIiIlIll(SynapseXen_IlIlIIiliiilIliiilll,1,6),[1657678270]=SynapseXen_iiIiIlIll(SynapseXen_IlIlIIiliiilIliiilll,7,14)}if SynapseXen_iIillII==(SynapseXen_IllIlIIllilIliiIiII[1922258975]or(function(...)local SynapseXen_iiliiI="luraph better then xen bros :pensive:"local SynapseXen_IiIiIIIIIIIl=SynapseXen_IlllllIIlIIlliIlI(305602499,1568105318)local SynapseXen_IIiilIllliIili={...}for SynapseXen_iiIlIlliliIIIlliIl,SynapseXen_iIIiiillilIilIIIliI in pairs(SynapseXen_IIiilIllliIili)do local SynapseXen_IlIIiliiiiIliiilIii;local SynapseXen_IiIIlIillili=type(SynapseXen_iIIiiillilIilIIIliI)if SynapseXen_IiIIlIillili=="number"then SynapseXen_IlIIiliiiiIliiilIii=SynapseXen_iIIiiillilIilIIIliI elseif SynapseXen_IiIIlIillili=="string"then SynapseXen_IlIIiliiiiIliiilIii=SynapseXen_iIIiiillilIilIIIliI:len()elseif SynapseXen_IiIIlIillili=="table"then SynapseXen_IlIIiliiiiIliiilIii=SynapseXen_IlllllIIlIIlliIlI(2651663998,2651655164)end;SynapseXen_IiIiIIIIIIIl=SynapseXen_IiIiIIIIIIIl-SynapseXen_IlIIiliiiiIliiilIii end;SynapseXen_IllIlIIllilIliiIiII[1922258975]=SynapseXen_IllIli(SynapseXen_IllIli(655765536,SynapseXen_IiIiIIIIIIIl),SynapseXen_IllIli(200613646,SynapseXen_llIIIIIilI))-string.len(SynapseXen_iiliiI)-#{2013284828,1987814077,983765032,2420385542,1943280478,4161013974,3897277447,319563315,2923637329}return SynapseXen_IllIlIIllilIliiIiII[1922258975]end)("llIliiilliliIllIi",{},"i","IiIlIlIll"))then SynapseXen_IiiiIliiIliillliIllI[1707011979]=SynapseXen_iiIiIlIll(SynapseXen_IlIlIIiliiilIliiilll,24,32)SynapseXen_IiiiIliiIliillliIllI[1220663036]=SynapseXen_iiIiIlIll(SynapseXen_IlIlIIiliiilIliiilll,15,23)elseif SynapseXen_iIillII==(SynapseXen_IllIlIIllilIliiIiII[67321931]or(function()local SynapseXen_iiliiI="so if you'we nyot awawe of expwoiting by this point, you've pwobabwy been wiving undew a wock that the pionyeews used to wide fow miwes. wobwox is often seen as an expwoit-infested gwound by most fwom the suwface, awthough this isn't the case."SynapseXen_IllIlIIllilIliiIiII[67321931]=SynapseXen_IllIli(SynapseXen_IlllllIIlIIlliIlI(3330826650,667886783),SynapseXen_IllIli(581828790,SynapseXen_IIlIiilIiil[6]))-string.len(SynapseXen_iiliiI)-#{3450645507,617904567,199703534,2886744237,1773717889}return SynapseXen_IllIlIIllilIliiIiII[67321931]end)())then SynapseXen_IiiiIliiIliillliIllI[1826411724]=SynapseXen_iiIiIlIll(SynapseXen_IlIlIIiliiilIliiilll,15,32)elseif SynapseXen_iIillII==(SynapseXen_IllIlIIllilIliiIiII[3505440227]or(function()local SynapseXen_iiliiI="inb4 posted on exploit reports section"SynapseXen_IllIlIIllilIliiIiII[3505440227]=SynapseXen_IllIli(SynapseXen_IlllllIIlIIlliIlI(3066116023,2064447913),SynapseXen_IllIli(2920318683,SynapseXen_llIIIIIilI))-string.len(SynapseXen_iiliiI)-#{2523747741}return SynapseXen_IllIlIIllilIliiIiII[3505440227]end)())then SynapseXen_IiiiIliiIliillliIllI[1522539826]=SynapseXen_iiIiIlIll(SynapseXen_IlIlIIiliiilIliiilll,15,32)-131071 end;SynapseXen_iIliiiIll[SynapseXen_lliiiI]=SynapseXen_IiiiIliiIliillliIllI end;SynapseXen_IlliIiilIliiI()SynapseXen_IliliillI()SynapseXen_IlliIiilIliiI()SynapseXen_ilIlIIlIIIIl[795665319]=SynapseXen_IllIli(SynapseXen_IliliillI(),SynapseXen_IllIlIIllilIliiIiII[3582630286]or(function()local SynapseXen_iiliiI="https://twitter.com/Ripull_RBLX/status/1059334518581145603"SynapseXen_IllIlIIllilIliiIiII[3582630286]=SynapseXen_IllIli(SynapseXen_IlllllIIlIIlliIlI(827505319,3111181350),SynapseXen_IllIli(1271504498,SynapseXen_IIlIiilIiil[6]))-string.len(SynapseXen_iiliiI)-#{3261679610,858908681,4137135969,3692522740,4141870632}return SynapseXen_IllIlIIllilIliiIiII[3582630286]end)())SynapseXen_IliliillI()SynapseXen_IlliIiilIliiI()SynapseXen_ilIlIIlIIIIl[1508668597]=SynapseXen_IllIli(SynapseXen_IliliillI(),SynapseXen_IllIlIIllilIliiIiII[621051702]or(function()local SynapseXen_iiliiI="this is a christian obfuscator, no cursing allowed in our scripts"SynapseXen_IllIlIIllilIliiIiII[621051702]=SynapseXen_IllIli(SynapseXen_IlllllIIlIIlliIlI(2153113964,3644235124),SynapseXen_IllIli(1850159164,SynapseXen_IIlIiilIiil[1]))-string.len(SynapseXen_iiliiI)-#{115702589,2553122324,4219349113,723093118,2529389717,853736501}return SynapseXen_IllIlIIllilIliiIiII[621051702]end)())SynapseXen_IliliillI()SynapseXen_IliliillI()for SynapseXen_lliiiI=1,SynapseXen_IllIli(SynapseXen_illilllIiiIililiili(),SynapseXen_IllIlIIllilIliiIiII[200536183]or(function()local SynapseXen_iiliiI="baby i just fell for uwu,,,,,, i wanna be with uwu!11!!"SynapseXen_IllIlIIllilIliiIiII[200536183]=SynapseXen_IllIli(SynapseXen_IlllllIIlIIlliIlI(504667171,1250257860),SynapseXen_IllIli(4242582840,SynapseXen_llIIIIIilI))-string.len(SynapseXen_iiliiI)-#{672889857,2880312835}return SynapseXen_IllIlIIllilIliiIiII[200536183]end)())do local SynapseXen_iIillII=SynapseXen_IliliillI()SynapseXen_IliliillI()local SynapseXen_iilIIliiIiiiiIili;if SynapseXen_iIillII==(SynapseXen_IllIlIIllilIliiIiII[348145892]or(function(...)local SynapseXen_iiliiI="i put more time into this shitty list of dead memes then i did into the obfuscator itself"local SynapseXen_IiIiIIIIIIIl=SynapseXen_IlllllIIlIIlliIlI(4168490082,3261284029)local SynapseXen_IIiilIllliIili={...}for SynapseXen_iiIlIlliliIIIlliIl,SynapseXen_iIIiiillilIilIIIliI in pairs(SynapseXen_IIiilIllliIili)do local SynapseXen_IlIIiliiiiIliiilIii;local SynapseXen_IiIIlIillili=type(SynapseXen_iIIiiillilIilIIIliI)if SynapseXen_IiIIlIillili=="number"then SynapseXen_IlIIiliiiiIliiilIii=SynapseXen_iIIiiillilIilIIIliI elseif SynapseXen_IiIIlIillili=="string"then SynapseXen_IlIIiliiiiIliiilIii=SynapseXen_iIIiiillilIilIIIliI:len()elseif SynapseXen_IiIIlIillili=="table"then SynapseXen_IlIIiliiiiIliiilIii=SynapseXen_IlllllIIlIIlliIlI(621910007,621953455)end;SynapseXen_IiIiIIIIIIIl=SynapseXen_IiIiIIIIIIIl+SynapseXen_IlIIiliiiiIliiilIii end;SynapseXen_IllIlIIllilIliiIiII[348145892]=SynapseXen_IllIli(SynapseXen_IllIli(715371696,SynapseXen_IiIiIIIIIIIl),SynapseXen_IllIli(3546166547,SynapseXen_IIlIiilIiil[6]))-string.len(SynapseXen_iiliiI)-#{3308769832}return SynapseXen_IllIlIIllilIliiIiII[348145892]end)({},"lilIIliIliiIiII",12074,{},6628,{}))then SynapseXen_iilIIliiIiiiiIili=SynapseXen_IliliillI()~=0 elseif SynapseXen_iIillII==(SynapseXen_IllIlIIllilIliiIiII[2163450136]or(function()local SynapseXen_iiliiI="print(bytecode)"SynapseXen_IllIlIIllilIliiIiII[2163450136]=SynapseXen_IllIli(SynapseXen_IlllllIIlIIlliIlI(4140956876,853717543),SynapseXen_IllIli(131663726,SynapseXen_IIlIiilIiil[6]))-string.len(SynapseXen_iiliiI)-#{1070758911,4077104176}return SynapseXen_IllIlIIllilIliiIiII[2163450136]end)())then SynapseXen_iilIIliiIiiiiIili=SynapseXen_IllIiIIllilI()elseif SynapseXen_iIillII==(SynapseXen_IllIlIIllilIliiIiII[3308064366]or(function()local SynapseXen_iiliiI="epic gamer vision"SynapseXen_IllIlIIllilIliiIiII[3308064366]=SynapseXen_IllIli(SynapseXen_IlllllIIlIIlliIlI(1124345372,252036780),SynapseXen_IllIli(89596613,SynapseXen_IIlIiilIiil[2]))-string.len(SynapseXen_iiliiI)-#{1757558097,3582407982,2547857239,1979170827,896351810,4240678416,2905949149,3233921805,3031112368}return SynapseXen_IllIlIIllilIliiIiII[3308064366]end)())then SynapseXen_iilIIliiIiiiiIili=SynapseXen_illIli(SynapseXen_IllIiIiIlliIilIIil(SynapseXen_liIIiiiiIIilli()),1,-2)end;SynapseXen_IlllilIlliIillIiiI[SynapseXen_lliiiI-1]=SynapseXen_iilIIliiIiiiiIili end;SynapseXen_IlliIiilIliiI()for SynapseXen_lliiiI=1,SynapseXen_IllIli(SynapseXen_illilllIiiIililiili(),SynapseXen_IllIlIIllilIliiIiII[790630080]or(function(...)local SynapseXen_iiliiI="wait for someone on devforum to say they are gonna deobfuscate this"local SynapseXen_IiIiIIIIIIIl=SynapseXen_IlllllIIlIIlliIlI(2678525737,1537754582)local SynapseXen_IIiilIllliIili={...}for SynapseXen_iiIlIlliliIIIlliIl,SynapseXen_iIIiiillilIilIIIliI in pairs(SynapseXen_IIiilIllliIili)do local SynapseXen_IlIIiliiiiIliiilIii;local SynapseXen_IiIIlIillili=type(SynapseXen_iIIiiillilIilIIIliI)if SynapseXen_IiIIlIillili=="number"then SynapseXen_IlIIiliiiiIliiilIii=SynapseXen_iIIiiillilIilIIIliI elseif SynapseXen_IiIIlIillili=="string"then SynapseXen_IlIIiliiiiIliiilIii=SynapseXen_iIIiiillilIilIIIliI:len()elseif SynapseXen_IiIIlIillili=="table"then SynapseXen_IlIIiliiiiIliiilIii=SynapseXen_IlllllIIlIIlliIlI(3133480152,3133479690)end;SynapseXen_IiIiIIIIIIIl=SynapseXen_IiIiIIIIIIIl+SynapseXen_IlIIiliiiiIliiilIii end;SynapseXen_IllIlIIllilIliiIiII[790630080]=SynapseXen_IllIli(SynapseXen_IllIli(2449967604,SynapseXen_IiIiIIIIIIIl),SynapseXen_IllIli(877358065,SynapseXen_IIlIiilIiil[8]))-string.len(SynapseXen_iiliiI)-#{202540427}return SynapseXen_IllIlIIllilIliiIiII[790630080]end)("lIIiIllillllIIl",{},{},{},"IliliiIlIIlIIl"))do SynapseXen_lIIIlii[SynapseXen_lliiiI-1]=SynapseXen_IlIiIiIIlIl()end;return SynapseXen_ilIlIIlIIIIl end;do assert(SynapseXen_liIIiiiiIIilli(4)=="\27Xen","Synapse Xen - Failed to verify bytecode. Please make sure your Lua implementation supports non-null terminated strings.")SynapseXen_illilllIiiIililiili=SynapseXen_IlliIiilIliiI;SynapseXen_IIliiiI=SynapseXen_IlliIiilIliiI;local SynapseXen_lIlllII=SynapseXen_liIIiiiiIIilli()SynapseXen_IlliIiilIliiI()SynapseXen_IliliillI()SynapseXen_llIIIIIilI=SynapseXen_iIllIlIlIiilil(SynapseXen_illilllIiiIililiili())local SynapseXen_IIIilililIiI=0;for SynapseXen_iiIlIlliliIIIlliIl=1,#SynapseXen_lIlllII do local SynapseXen_IlIll=SynapseXen_lIlllII:sub(SynapseXen_iiIlIlliliIIIlliIl,SynapseXen_iiIlIlliliIIIlliIl)SynapseXen_IIIilililIiI=SynapseXen_IIIilililIiI+string.byte(SynapseXen_IlIll)end;SynapseXen_IIIilililIiI=SynapseXen_IllIli(SynapseXen_IIIilililIiI,SynapseXen_llIIIIIilI)for SynapseXen_lliiiI=1,SynapseXen_IliliillI()do SynapseXen_IIlIiilIiil[SynapseXen_lliiiI]=SynapseXen_iiIlillIIIiiiiliI(SynapseXen_illilllIiiIililiili(),SynapseXen_IIIilililIiI)end;SynapseXen_IIlIIlIilIillliill()end;return SynapseXen_IlIiIiIIlIl()end;local function SynapseXen_iiIiIlIllIIilIiili(...)return SynapseXen_liiIiI('#',...),{...}end;local function SynapseXen_lIilIlillIlI(SynapseXen_ilIlIIlIIIIl,SynapseXen_lIIIi,SynapseXen_llIiiIl)local SynapseXen_lIIIlii=SynapseXen_ilIlIIlIIIIl[SynapseXen_IllIlIIllilIliiIiII[743785857]or(function(...)local SynapseXen_iiliiI="aspect network better obfuscator"local SynapseXen_IiIiIIIIIIIl=SynapseXen_IlllllIIlIIlliIlI(4244552250,4033071285)local SynapseXen_IIiilIllliIili={...}for SynapseXen_iiIlIlliliIIIlliIl,SynapseXen_iIIiiillilIilIIIliI in pairs(SynapseXen_IIiilIllliIili)do local SynapseXen_IlIIiliiiiIliiilIii;local SynapseXen_IiIIlIillili=type(SynapseXen_iIIiiillilIilIIIliI)if SynapseXen_IiIIlIillili=="number"then SynapseXen_IlIIiliiiiIliiilIii=SynapseXen_iIIiiillilIilIIIliI elseif SynapseXen_IiIIlIillili=="string"then SynapseXen_IlIIiliiiiIliiilIii=SynapseXen_iIIiiillilIilIIIliI:len()elseif SynapseXen_IiIIlIillili=="table"then SynapseXen_IlIIiliiiiIliiilIii=SynapseXen_IlllllIIlIIlliIlI(1506709454,1506752747)end;SynapseXen_IiIiIIIIIIIl=SynapseXen_IiIiIIIIIIIl+SynapseXen_IlIIiliiiiIliiilIii end;SynapseXen_IllIlIIllilIliiIiII[743785857]=SynapseXen_IllIli(SynapseXen_IllIli(375867710,SynapseXen_IiIiIIIIIIIl),SynapseXen_IllIli(1918538847,SynapseXen_llIIIIIilI))-string.len(SynapseXen_iiliiI)-#{182255234,374980832}return SynapseXen_IllIlIIllilIliiIiII[743785857]end)("IilIIIililIIli")]local SynapseXen_iIliiiIll=SynapseXen_ilIlIIlIIIIl[SynapseXen_IllIlIIllilIliiIiII[2161003697]or(function(...)local SynapseXen_iiliiI="imagine using some lua minifier tool and thinking you are a badass"local SynapseXen_IiIiIIIIIIIl=SynapseXen_IlllllIIlIIlliIlI(3393598450,713426497)local SynapseXen_IIiilIllliIili={...}for SynapseXen_iiIlIlliliIIIlliIl,SynapseXen_iIIiiillilIilIIIliI in pairs(SynapseXen_IIiilIllliIili)do local SynapseXen_IlIIiliiiiIliiilIii;local SynapseXen_IiIIlIillili=type(SynapseXen_iIIiiillilIilIIIliI)if SynapseXen_IiIIlIillili=="number"then SynapseXen_IlIIiliiiiIliiilIii=SynapseXen_iIIiiillilIilIIIliI elseif SynapseXen_IiIIlIillili=="string"then SynapseXen_IlIIiliiiiIliiilIii=SynapseXen_iIIiiillilIilIIIliI:len()elseif SynapseXen_IiIIlIillili=="table"then SynapseXen_IlIIiliiiiIliiilIii=SynapseXen_IlllllIIlIIlliIlI(1392509732,1392522358)end;SynapseXen_IiIiIIIIIIIl=SynapseXen_IiIiIIIIIIIl-SynapseXen_IlIIiliiiiIliiilIii end;SynapseXen_IllIlIIllilIliiIiII[2161003697]=SynapseXen_IllIli(SynapseXen_IllIli(804123225,SynapseXen_IiIiIIIIIIIl),SynapseXen_IllIli(14074763,SynapseXen_IIlIiilIiil[7]))-string.len(SynapseXen_iiliiI)-#{3224146896,1798498547}return SynapseXen_IllIlIIllilIliiIiII[2161003697]end)({},2745)]local SynapseXen_IlllilIlliIillIiiI=SynapseXen_ilIlIIlIIIIl[SynapseXen_IllIlIIllilIliiIiII[815314593]or(function(...)local SynapseXen_iiliiI="hi xen crashes on my axon paste plz help"local SynapseXen_IiIiIIIIIIIl=SynapseXen_IlllllIIlIIlliIlI(1534436586,3282230814)local SynapseXen_IIiilIllliIili={...}for SynapseXen_iiIlIlliliIIIlliIl,SynapseXen_iIIiiillilIilIIIliI in pairs(SynapseXen_IIiilIllliIili)do local SynapseXen_IlIIiliiiiIliiilIii;local SynapseXen_IiIIlIillili=type(SynapseXen_iIIiiillilIilIIIliI)if SynapseXen_IiIIlIillili=="number"then SynapseXen_IlIIiliiiiIliiilIii=SynapseXen_iIIiiillilIilIIIliI elseif SynapseXen_IiIIlIillili=="string"then SynapseXen_IlIIiliiiiIliiilIii=SynapseXen_iIIiiillilIilIIIliI:len()elseif SynapseXen_IiIIlIillili=="table"then SynapseXen_IlIIiliiiiIliiilIii=SynapseXen_IlllllIIlIIlliIlI(3524312558,3524301298)end;SynapseXen_IiIiIIIIIIIl=SynapseXen_IiIiIIIIIIIl+SynapseXen_IlIIiliiiiIliiilIii end;SynapseXen_IllIlIIllilIliiIiII[815314593]=SynapseXen_IllIli(SynapseXen_IllIli(3620484567,SynapseXen_IiIiIIIIIIIl),SynapseXen_IllIli(1413427040,SynapseXen_llIIIIIilI))-string.len(SynapseXen_iiliiI)-#{3134201154}return SynapseXen_IllIlIIllilIliiIiII[815314593]end)("llIlliIl")]return function(...)local SynapseXen_llIlIilIillii,SynapseXen_IIiiiillliiIlIlIiIil=1,-1;local SynapseXen_IliiI,SynapseXen_iIilII={},SynapseXen_liiIiI('#',...)-1;local SynapseXen_IilIiIiIIilli=0;local SynapseXen_liliIllil={}local SynapseXen_IlIIIliiillIiiiIiIi={}local SynapseXen_iIIIlIIiiilIIII=setmetatable({},{__index=SynapseXen_liliIllil,__newindex=function(SynapseXen_ilIiIiiiIililiIil,SynapseXen_IIIlllIliiIliIIlIlI,SynapseXen_IliIiilliIliIillll)if SynapseXen_IIIlllIliiIliIIlIlI>SynapseXen_IIiiiillliiIlIlIiIil then SynapseXen_IIiiiillliiIlIlIiIil=SynapseXen_IIIlllIliiIliIIlIlI end;SynapseXen_liliIllil[SynapseXen_IIIlllIliiIliIIlIlI]=SynapseXen_IliIiilliIliIillll end})local function SynapseXen_IliIliIiIlIlIIiiili()local SynapseXen_IiiiIliiIliillliIllI,SynapseXen_IIiIlI;while true do SynapseXen_IiiiIliiIliillliIllI=SynapseXen_iIliiiIll[SynapseXen_llIlIilIillii]SynapseXen_IIiIlI=SynapseXen_IiiiIliiIliillliIllI[1832923908]SynapseXen_llIlIilIillii=SynapseXen_llIlIilIillii+1;if SynapseXen_IIiIlI==35 then SynapseXen_iIIIlIIiiilIIII[SynapseXen_IllIli(SynapseXen_IiiiIliiIliillliIllI[1657678270],46)]=SynapseXen_llIiiIl[SynapseXen_IllIli(SynapseXen_IiiiIliiIliillliIllI[1707011979],38)]elseif SynapseXen_IIiIlI==183 then local SynapseXen_IllIlilIlilliIIIi=SynapseXen_lIIIlii[SynapseXen_IlIilllIl(SynapseXen_IiiiIliiIliillliIllI[1826411724],66435,262144)]local SynapseXen_IliIiliIlIiIill=SynapseXen_iIIIlIIiiilIIII;local SynapseXen_iiiIliIli;local SynapseXen_illIIii;if SynapseXen_IllIlilIlilliIIIi[795665319]~=0 then SynapseXen_iiiIliIli={}SynapseXen_illIIii=setmetatable({},{__index=function(SynapseXen_ilIiIiiiIililiIil,SynapseXen_IIIlllIliiIliIIlIlI)local SynapseXen_IIiIiiillIIiIiIIlIil=SynapseXen_iiiIliIli[SynapseXen_IIIlllIliiIliIIlIlI]return SynapseXen_IIiIiiillIIiIiIIlIil[1][SynapseXen_IIiIiiillIIiIiIIlIil[2]]end,__newindex=function(SynapseXen_ilIiIiiiIililiIil,SynapseXen_IIIlllIliiIliIIlIlI,SynapseXen_IliIiilliIliIillll)local SynapseXen_IIiIiiillIIiIiIIlIil=SynapseXen_iiiIliIli[SynapseXen_IIIlllIliiIliIIlIlI]SynapseXen_IIiIiiillIIiIiIIlIil[1][SynapseXen_IIiIiiillIIiIiIIlIil[2]]=SynapseXen_IliIiilliIliIillll end})for SynapseXen_lliiiI=1,SynapseXen_IllIlilIlilliIIIi[795665319]do local SynapseXen_IliiIIlIii=SynapseXen_iIliiiIll[SynapseXen_llIlIilIillii]if SynapseXen_IliiIIlIii[1832923908]==107 then SynapseXen_iiiIliIli[SynapseXen_lliiiI-1]={SynapseXen_IliIiliIlIiIill,SynapseXen_IllIli(SynapseXen_IliiIIlIii[1707011979],118)}elseif SynapseXen_IliiIIlIii[1832923908]==35 then SynapseXen_iiiIliIli[SynapseXen_lliiiI-1]={SynapseXen_llIiiIl,SynapseXen_IllIli(SynapseXen_IliiIIlIii[1707011979],38)}end;SynapseXen_llIlIilIillii=SynapseXen_llIlIilIillii+1 end;SynapseXen_IlIIIliiillIiiiIiIi[#SynapseXen_IlIIIliiillIiiiIiIi+1]=SynapseXen_iiiIliIli end;SynapseXen_IliIiliIlIiIill[SynapseXen_lIiIlIiIIlliilIlII(SynapseXen_IiiiIliiIliillliIllI[1657678270],80,256)]=SynapseXen_lIilIlillIlI(SynapseXen_IllIlilIlilliIIIi,SynapseXen_lIIIi,SynapseXen_illIIii)elseif SynapseXen_IIiIlI==128 then local SynapseXen_ilIIliIllii=SynapseXen_IlIilllIl(SynapseXen_IiiiIliiIliillliIllI[1707011979],126,512)local SynapseXen_IlIll=SynapseXen_IllIli(SynapseXen_IiiiIliiIliillliIllI[1220663036],25)local SynapseXen_IliIiliIlIiIill=SynapseXen_iIIIlIIiiilIIII;if SynapseXen_ilIIliIllii>255 then SynapseXen_ilIIliIllii=SynapseXen_IlllilIlliIillIiiI[SynapseXen_ilIIliIllii-256]else SynapseXen_ilIIliIllii=SynapseXen_IliIiliIlIiIill[SynapseXen_ilIIliIllii]end;if SynapseXen_IlIll>255 then SynapseXen_IlIll=SynapseXen_IlllilIlliIillIiiI[SynapseXen_IlIll-256]else SynapseXen_IlIll=SynapseXen_IliIiliIlIiIill[SynapseXen_IlIll]end;SynapseXen_IliIiliIlIiIill[SynapseXen_IllIli(SynapseXen_IiiiIliiIliillliIllI[1657678270],66)]=SynapseXen_ilIIliIllii/SynapseXen_IlIll elseif SynapseXen_IIiIlI==192 then if not not SynapseXen_iIIIlIIiiilIIII[SynapseXen_IlIilllIl(SynapseXen_lIiIlIiIIlliilIlII(SynapseXen_IiiiIliiIliillliIllI[1657678270],75,256),SynapseXen_IilIiIiIIilli,256)]==(SynapseXen_IlIilllIl(SynapseXen_IiiiIliiIliillliIllI[1220663036],50,512)==0)then SynapseXen_llIlIilIillii=SynapseXen_llIlIilIillii+1 end elseif SynapseXen_IIiIlI==146 then local SynapseXen_liiiliIilIiIIIlllil=SynapseXen_IlIilllIl(SynapseXen_IlIilllIl(SynapseXen_IiiiIliiIliillliIllI[1657678270],14,256),SynapseXen_IilIiIiIIilli,256)~=0;local SynapseXen_ilIIliIllii=SynapseXen_IlIilllIl(SynapseXen_IiiiIliiIliillliIllI[1707011979],57,512)local SynapseXen_IlIll=SynapseXen_IlIilllIl(SynapseXen_IiiiIliiIliillliIllI[1220663036],56,512)local SynapseXen_IliIiliIlIiIill=SynapseXen_iIIIlIIiiilIIII;if SynapseXen_ilIIliIllii>255 then SynapseXen_ilIIliIllii=SynapseXen_IlllilIlliIillIiiI[SynapseXen_ilIIliIllii-256]else SynapseXen_ilIIliIllii=SynapseXen_IliIiliIlIiIill[SynapseXen_ilIIliIllii]end;if SynapseXen_IlIll>255 then SynapseXen_IlIll=SynapseXen_IlllilIlliIillIiiI[SynapseXen_IlIll-256]else SynapseXen_IlIll=SynapseXen_IliIiliIlIiIill[SynapseXen_IlIll]end;if SynapseXen_ilIIliIllii<SynapseXen_IlIll~=SynapseXen_liiiliIilIiIIIlllil then SynapseXen_llIlIilIillii=SynapseXen_llIlIilIillii+1 end elseif SynapseXen_IIiIlI==124 then local SynapseXen_liiiliIilIiIIIlllil=SynapseXen_IlIilllIl(SynapseXen_IiiiIliiIliillliIllI[1657678270],80,256)local SynapseXen_ilIIliIllii=SynapseXen_IllIli(SynapseXen_IiiiIliiIliillliIllI[1707011979],122)local SynapseXen_IliIiliIlIiIill=SynapseXen_iIIIlIIiiilIIII;local SynapseXen_IlIIiIllIiIlliIIllI,SynapseXen_iIlIiliIliIl;local SynapseXen_iIliIIIlIIlIIlIIlIl;if SynapseXen_ilIIliIllii==1 then return elseif SynapseXen_ilIIliIllii==0 then SynapseXen_iIliIIIlIIlIIlIIlIl=SynapseXen_IIiiiillliiIlIlIiIil else SynapseXen_iIliIIIlIIlIIlIIlIl=SynapseXen_liiiliIilIiIIIlllil+SynapseXen_ilIIliIllii-2 end;SynapseXen_iIlIiliIliIl={}SynapseXen_IlIIiIllIiIlliIIllI=0;for SynapseXen_lliiiI=SynapseXen_liiiliIilIiIIIlllil,SynapseXen_iIliIIIlIIlIIlIIlIl do SynapseXen_IlIIiIllIiIlliIIllI=SynapseXen_IlIIiIllIiIlliIIllI+1;SynapseXen_iIlIiliIliIl[SynapseXen_IlIIiIllIiIlliIIllI]=SynapseXen_IliIiliIlIiIill[SynapseXen_lliiiI]end;return SynapseXen_iIlIiliIliIl,SynapseXen_IlIIiIllIiIlliIIllI elseif SynapseXen_IIiIlI==18 then SynapseXen_iIIIlIIiiilIIII[SynapseXen_IllIli(SynapseXen_IiiiIliiIliillliIllI[1657678270],5)]=SynapseXen_IllIli(SynapseXen_IiiiIliiIliillliIllI[1707011979],66)~=0;if SynapseXen_IllIli(SynapseXen_IiiiIliiIliillliIllI[1220663036],64)~=0 then SynapseXen_llIlIilIillii=SynapseXen_llIlIilIillii+1 end elseif SynapseXen_IIiIlI==22 then local SynapseXen_liiiliIilIiIIIlllil=SynapseXen_lIiIlIiIIlliilIlII(SynapseXen_IiiiIliiIliillliIllI[1657678270],61,256)local SynapseXen_IlIll=SynapseXen_IllIli(SynapseXen_IiiiIliiIliillliIllI[1220663036],120)local SynapseXen_IliIiliIlIiIill=SynapseXen_iIIIlIIiiilIIII;local SynapseXen_ililliliIIIlliiiIl=SynapseXen_liiiliIilIiIIIlllil+2;local SynapseXen_IiIliliIIilI={SynapseXen_IliIiliIlIiIill[SynapseXen_liiiliIilIiIIIlllil](SynapseXen_IliIiliIlIiIill[SynapseXen_liiiliIilIiIIIlllil+1],SynapseXen_IliIiliIlIiIill[SynapseXen_liiiliIilIiIIIlllil+2])}for SynapseXen_lliiiI=1,SynapseXen_IlIll do SynapseXen_iIIIlIIiiilIIII[SynapseXen_ililliliIIIlliiiIl+SynapseXen_lliiiI]=SynapseXen_IiIliliIIilI[SynapseXen_lliiiI]end;if SynapseXen_IliIiliIlIiIill[SynapseXen_liiiliIilIiIIIlllil+3]~=nil then SynapseXen_IliIiliIlIiIill[SynapseXen_liiiliIilIiIIIlllil+2]=SynapseXen_IliIiliIlIiIill[SynapseXen_liiiliIilIiIIIlllil+3]else SynapseXen_llIlIilIillii=SynapseXen_llIlIilIillii+1 end elseif SynapseXen_IIiIlI==139 then local SynapseXen_ilIIliIllii=SynapseXen_iIIIlIIiiilIIII[SynapseXen_IlIilllIl(SynapseXen_IiiiIliiIliillliIllI[1707011979],51,512)]if not not SynapseXen_ilIIliIllii==(SynapseXen_lIiIlIiIIlliilIlII(SynapseXen_IllIli(SynapseXen_IiiiIliiIliillliIllI[1220663036],73),SynapseXen_IilIiIiIIilli,512)==0)then SynapseXen_llIlIilIillii=SynapseXen_llIlIilIillii+1 else SynapseXen_iIIIlIIiiilIIII[SynapseXen_IllIli(SynapseXen_IiiiIliiIliillliIllI[1657678270],24)]=SynapseXen_ilIIliIllii end elseif SynapseXen_IIiIlI==107 then SynapseXen_iIIIlIIiiilIIII[SynapseXen_IllIli(SynapseXen_IiiiIliiIliillliIllI[1657678270],114)]=SynapseXen_iIIIlIIiiilIIII[SynapseXen_IllIli(SynapseXen_IiiiIliiIliillliIllI[1707011979],118)]elseif SynapseXen_IIiIlI==109 then local SynapseXen_liiiliIilIiIIIlllil=SynapseXen_lIiIlIiIIlliilIlII(SynapseXen_IiiiIliiIliillliIllI[1657678270],122,256)~=0;local SynapseXen_ilIIliIllii=SynapseXen_IllIli(SynapseXen_IiiiIliiIliillliIllI[1707011979],82)local SynapseXen_IlIll=SynapseXen_lIiIlIiIIlliilIlII(SynapseXen_IlIilllIl(SynapseXen_IiiiIliiIliillliIllI[1220663036],35,512),SynapseXen_IilIiIiIIilli,512)local SynapseXen_IliIiliIlIiIill=SynapseXen_iIIIlIIiiilIIII;if SynapseXen_ilIIliIllii>255 then SynapseXen_ilIIliIllii=SynapseXen_IlllilIlliIillIiiI[SynapseXen_ilIIliIllii-256]else SynapseXen_ilIIliIllii=SynapseXen_IliIiliIlIiIill[SynapseXen_ilIIliIllii]end;if SynapseXen_IlIll>255 then SynapseXen_IlIll=SynapseXen_IlllilIlliIillIiiI[SynapseXen_IlIll-256]else SynapseXen_IlIll=SynapseXen_IliIiliIlIiIill[SynapseXen_IlIll]end;if SynapseXen_ilIIliIllii<=SynapseXen_IlIll~=SynapseXen_liiiliIilIiIIIlllil then SynapseXen_llIlIilIillii=SynapseXen_llIlIilIillii+1 end elseif SynapseXen_IIiIlI==103 then local SynapseXen_liiiliIilIiIIIlllil=SynapseXen_IllIli(SynapseXen_lIiIlIiIIlliilIlII(SynapseXen_IiiiIliiIliillliIllI[1657678270],89,256),SynapseXen_IilIiIiIIilli)local SynapseXen_ilIIliIllii=SynapseXen_IllIli(SynapseXen_IiiiIliiIliillliIllI[1707011979],7)local SynapseXen_IliIiliIlIiIill,SynapseXen_IIiIlIllliliIlIlII=SynapseXen_iIIIlIIiiilIIII,SynapseXen_IliiI;SynapseXen_IIiiiillliiIlIlIiIil=SynapseXen_liiiliIilIiIIIlllil-1;for SynapseXen_lliiiI=SynapseXen_liiiliIilIiIIIlllil,SynapseXen_liiiliIilIiIIIlllil+(SynapseXen_ilIIliIllii>0 and SynapseXen_ilIIliIllii-1 or SynapseXen_iIilII)do SynapseXen_IliIiliIlIiIill[SynapseXen_lliiiI]=SynapseXen_IIiIlIllliliIlIlII[SynapseXen_lliiiI-SynapseXen_liiiliIilIiIIIlllil]end elseif SynapseXen_IIiIlI==134 then local SynapseXen_liiiliIilIiIIIlllil=SynapseXen_IlIilllIl(SynapseXen_IiiiIliiIliillliIllI[1657678270],37,256)local SynapseXen_IliIiliIlIiIill=SynapseXen_iIIIlIIiiilIIII;local SynapseXen_IllilllIliiIIlll=SynapseXen_IliIiliIlIiIill[SynapseXen_liiiliIilIiIIIlllil+2]local SynapseXen_IiillIiIiilIIIlII=SynapseXen_IliIiliIlIiIill[SynapseXen_liiiliIilIiIIIlllil]+SynapseXen_IllilllIliiIIlll;SynapseXen_IliIiliIlIiIill[SynapseXen_liiiliIilIiIIIlllil]=SynapseXen_IiillIiIiilIIIlII;if SynapseXen_IllilllIliiIIlll>0 then if SynapseXen_IiillIiIiilIIIlII<=SynapseXen_IliIiliIlIiIill[SynapseXen_liiiliIilIiIIIlllil+1]then SynapseXen_llIlIilIillii=SynapseXen_llIlIilIillii+SynapseXen_IiiiIliiIliillliIllI[1522539826]SynapseXen_IliIiliIlIiIill[SynapseXen_liiiliIilIiIIIlllil+3]=SynapseXen_IiillIiIiilIIIlII end else if SynapseXen_IiillIiIiilIIIlII>=SynapseXen_IliIiliIlIiIill[SynapseXen_liiiliIilIiIIIlllil+1]then SynapseXen_llIlIilIillii=SynapseXen_llIlIilIillii+SynapseXen_IiiiIliiIliillliIllI[1522539826]SynapseXen_IliIiliIlIiIill[SynapseXen_liiiliIilIiIIIlllil+3]=SynapseXen_IiillIiIiilIIIlII end end elseif SynapseXen_IIiIlI==78 then SynapseXen_llIiiIl[SynapseXen_IllIli(SynapseXen_IiiiIliiIliillliIllI[1707011979],33)]=SynapseXen_iIIIlIIiiilIIII[SynapseXen_IllIli(SynapseXen_IiiiIliiIliillliIllI[1657678270],60)]elseif SynapseXen_IIiIlI==0 then local SynapseXen_ilIIliIllii=SynapseXen_IllIli(SynapseXen_IiiiIliiIliillliIllI[1707011979],97)local SynapseXen_IlIll=SynapseXen_IlIilllIl(SynapseXen_IiiiIliiIliillliIllI[1220663036],106,512)local SynapseXen_IliIiliIlIiIill=SynapseXen_iIIIlIIiiilIIII;if SynapseXen_ilIIliIllii>255 then SynapseXen_ilIIliIllii=SynapseXen_IlllilIlliIillIiiI[SynapseXen_ilIIliIllii-256]else SynapseXen_ilIIliIllii=SynapseXen_IliIiliIlIiIill[SynapseXen_ilIIliIllii]end;if SynapseXen_IlIll>255 then SynapseXen_IlIll=SynapseXen_IlllilIlliIillIiiI[SynapseXen_IlIll-256]else SynapseXen_IlIll=SynapseXen_IliIiliIlIiIill[SynapseXen_IlIll]end;SynapseXen_IliIiliIlIiIill[SynapseXen_lIiIlIiIIlliilIlII(SynapseXen_IiiiIliiIliillliIllI[1657678270],25,256)]=SynapseXen_ilIIliIllii^SynapseXen_IlIll elseif SynapseXen_IIiIlI==72 then SynapseXen_iIIIlIIiiilIIII[SynapseXen_IlIilllIl(SynapseXen_IiiiIliiIliillliIllI[1657678270],28,256)]=#SynapseXen_iIIIlIIiiilIIII[SynapseXen_IllIli(SynapseXen_IllIli(SynapseXen_IiiiIliiIliillliIllI[1707011979],113),SynapseXen_IilIiIiIIilli)]elseif SynapseXen_IIiIlI==17 then local SynapseXen_liiiliIilIiIIIlllil=SynapseXen_IllIli(SynapseXen_IiiiIliiIliillliIllI[1657678270],111)local SynapseXen_ilIIliIllii=SynapseXen_IllIli(SynapseXen_IiiiIliiIliillliIllI[1707011979],21)local SynapseXen_IlIll=SynapseXen_IlIilllIl(SynapseXen_IiiiIliiIliillliIllI[1220663036],4,512)local SynapseXen_IliIiliIlIiIill=SynapseXen_iIIIlIIiiilIIII;local SynapseXen_illliilIiil,SynapseXen_llIlIilIllillllIl;local SynapseXen_iIliIIIlIIlIIlIIlIl,SynapseXen_IlIIiIllIiIlliIIllI;SynapseXen_illliilIiil={}if SynapseXen_ilIIliIllii~=1 then if SynapseXen_ilIIliIllii~=0 then SynapseXen_iIliIIIlIIlIIlIIlIl=SynapseXen_liiiliIilIiIIIlllil+SynapseXen_ilIIliIllii-1 else SynapseXen_iIliIIIlIIlIIlIIlIl=SynapseXen_IIiiiillliiIlIlIiIil end;SynapseXen_IlIIiIllIiIlliIIllI=0;for SynapseXen_lliiiI=SynapseXen_liiiliIilIiIIIlllil+1,SynapseXen_iIliIIIlIIlIIlIIlIl do SynapseXen_IlIIiIllIiIlliIIllI=SynapseXen_IlIIiIllIiIlliIIllI+1;SynapseXen_illliilIiil[SynapseXen_IlIIiIllIiIlliIIllI]=SynapseXen_IliIiliIlIiIill[SynapseXen_lliiiI]end;SynapseXen_iIliIIIlIIlIIlIIlIl,SynapseXen_llIlIilIllillllIl=SynapseXen_iiIiIlIllIIilIiili(SynapseXen_IliIiliIlIiIill[SynapseXen_liiiliIilIiIIIlllil](unpack(SynapseXen_illliilIiil,1,SynapseXen_iIliIIIlIIlIIlIIlIl-SynapseXen_liiiliIilIiIIIlllil)))else SynapseXen_iIliIIIlIIlIIlIIlIl,SynapseXen_llIlIilIllillllIl=SynapseXen_iiIiIlIllIIilIiili(SynapseXen_IliIiliIlIiIill[SynapseXen_liiiliIilIiIIIlllil]())end;SynapseXen_IIiiiillliiIlIlIiIil=SynapseXen_liiiliIilIiIIIlllil-1;if SynapseXen_IlIll~=1 then if SynapseXen_IlIll~=0 then SynapseXen_iIliIIIlIIlIIlIIlIl=SynapseXen_liiiliIilIiIIIlllil+SynapseXen_IlIll-2 else SynapseXen_iIliIIIlIIlIIlIIlIl=SynapseXen_iIliIIIlIIlIIlIIlIl+SynapseXen_liiiliIilIiIIIlllil-1 end;SynapseXen_IlIIiIllIiIlliIIllI=0;for SynapseXen_lliiiI=SynapseXen_liiiliIilIiIIIlllil,SynapseXen_iIliIIIlIIlIIlIIlIl do SynapseXen_IlIIiIllIiIlliIIllI=SynapseXen_IlIIiIllIiIlliIIllI+1;SynapseXen_IliIiliIlIiIill[SynapseXen_lliiiI]=SynapseXen_llIlIilIllillllIl[SynapseXen_IlIIiIllIiIlliIIllI]end end elseif SynapseXen_IIiIlI==42 then local SynapseXen_IliIiliIlIiIill=SynapseXen_iIIIlIIiiilIIII;for SynapseXen_lliiiI=SynapseXen_IllIli(SynapseXen_IiiiIliiIliillliIllI[1657678270],0),SynapseXen_lIiIlIiIIlliilIlII(SynapseXen_IiiiIliiIliillliIllI[1707011979],110,512)do SynapseXen_IliIiliIlIiIill[SynapseXen_lliiiI]=nil end elseif SynapseXen_IIiIlI==179 then SynapseXen_IilIiIiIIilli=SynapseXen_iIIIlIIiiilIIII[SynapseXen_IlIilllIl(SynapseXen_IiiiIliiIliillliIllI[1657678270],25,256)]elseif SynapseXen_IIiIlI==196 then local SynapseXen_ilIIliIllii=SynapseXen_IllIli(SynapseXen_IiiiIliiIliillliIllI[1707011979],22)local SynapseXen_IlIll=SynapseXen_lIiIlIiIIlliilIlII(SynapseXen_lIiIlIiIIlliilIlII(SynapseXen_IiiiIliiIliillliIllI[1220663036],48,512),SynapseXen_IilIiIiIIilli,512)local SynapseXen_IliIiliIlIiIill=SynapseXen_iIIIlIIiiilIIII;if SynapseXen_ilIIliIllii>255 then SynapseXen_ilIIliIllii=SynapseXen_IlllilIlliIillIiiI[SynapseXen_ilIIliIllii-256]else SynapseXen_ilIIliIllii=SynapseXen_IliIiliIlIiIill[SynapseXen_ilIIliIllii]end;if SynapseXen_IlIll>255 then SynapseXen_IlIll=SynapseXen_IlllilIlliIillIiiI[SynapseXen_IlIll-256]else SynapseXen_IlIll=SynapseXen_IliIiliIlIiIill[SynapseXen_IlIll]end;SynapseXen_IliIiliIlIiIill[SynapseXen_IllIli(SynapseXen_IiiiIliiIliillliIllI[1657678270],125)]=SynapseXen_ilIIliIllii+SynapseXen_IlIll elseif SynapseXen_IIiIlI==110 then SynapseXen_iIIIlIIiiilIIII[SynapseXen_IlIilllIl(SynapseXen_IiiiIliiIliillliIllI[1657678270],114,256)]={}elseif SynapseXen_IIiIlI==34 then local SynapseXen_ilIIliIllii=SynapseXen_lIiIlIiIIlliilIlII(SynapseXen_IllIli(SynapseXen_IiiiIliiIliillliIllI[1707011979],52),SynapseXen_IilIiIiIIilli,512)local SynapseXen_IlIll=SynapseXen_lIiIlIiIIlliilIlII(SynapseXen_IlIilllIl(SynapseXen_IiiiIliiIliillliIllI[1220663036],121,512),SynapseXen_IilIiIiIIilli,512)local SynapseXen_IliIiliIlIiIill=SynapseXen_iIIIlIIiiilIIII;if SynapseXen_ilIIliIllii>255 then SynapseXen_ilIIliIllii=SynapseXen_IlllilIlliIillIiiI[SynapseXen_ilIIliIllii-256]else SynapseXen_ilIIliIllii=SynapseXen_IliIiliIlIiIill[SynapseXen_ilIIliIllii]end;if SynapseXen_IlIll>255 then SynapseXen_IlIll=SynapseXen_IlllilIlliIillIiiI[SynapseXen_IlIll-256]else SynapseXen_IlIll=SynapseXen_IliIiliIlIiIill[SynapseXen_IlIll]end;SynapseXen_IliIiliIlIiIill[SynapseXen_lIiIlIiIIlliilIlII(SynapseXen_IiiiIliiIliillliIllI[1657678270],114,256)]=SynapseXen_ilIIliIllii-SynapseXen_IlIll elseif SynapseXen_IIiIlI==97 then if SynapseXen_IlIilllIl(SynapseXen_IiiiIliiIliillliIllI[1826411724],116197,262144)==4569 then SynapseXen_iIIIlIIiiilIIII[SynapseXen_IlIilllIl(SynapseXen_IlIilllIl(SynapseXen_IiiiIliiIliillliIllI[1657678270],86,256),SynapseXen_IilIiIiIIilli,256)]=SynapseXen_llIIIIIilI else SynapseXen_iIIIlIIiiilIIII[SynapseXen_IlIilllIl(SynapseXen_IlIilllIl(SynapseXen_IiiiIliiIliillliIllI[1657678270],86,256),SynapseXen_IilIiIiIIilli,256)]=SynapseXen_IIlIiilIiil[SynapseXen_IlIilllIl(SynapseXen_IiiiIliiIliillliIllI[1826411724],116197,262144)]end elseif SynapseXen_IIiIlI==20 then SynapseXen_iIIIlIIiiilIIII[SynapseXen_lIiIlIiIIlliilIlII(SynapseXen_IiiiIliiIliillliIllI[1657678270],91,256)]=SynapseXen_lIIIi[SynapseXen_IlllilIlliIillIiiI[SynapseXen_IlIilllIl(SynapseXen_IiiiIliiIliillliIllI[1826411724],144603,262144)]]elseif SynapseXen_IIiIlI==41 then local SynapseXen_liiiliIilIiIIIlllil=SynapseXen_IllIli(SynapseXen_IiiiIliiIliillliIllI[1657678270],21)local SynapseXen_ilIIliIllii=SynapseXen_lIiIlIiIIlliilIlII(SynapseXen_IiiiIliiIliillliIllI[1707011979],35,512)local SynapseXen_IlIll=SynapseXen_IlIilllIl(SynapseXen_lIiIlIiIIlliilIlII(SynapseXen_IiiiIliiIliillliIllI[1220663036],38,512),SynapseXen_IilIiIiIIilli,512)local SynapseXen_IliIiliIlIiIill=SynapseXen_iIIIlIIiiilIIII;SynapseXen_ilIIliIllii=SynapseXen_IliIiliIlIiIill[SynapseXen_ilIIliIllii]if SynapseXen_IlIll>255 then SynapseXen_IlIll=SynapseXen_IlllilIlliIillIiiI[SynapseXen_IlIll-256]else SynapseXen_IlIll=SynapseXen_IliIiliIlIiIill[SynapseXen_IlIll]end;SynapseXen_IliIiliIlIiIill[SynapseXen_liiiliIilIiIIIlllil+1]=SynapseXen_ilIIliIllii;SynapseXen_IliIiliIlIiIill[SynapseXen_liiiliIilIiIIIlllil]=SynapseXen_ilIIliIllii[SynapseXen_IlIll]elseif SynapseXen_IIiIlI==15 then local SynapseXen_liiiliIilIiIIIlllil=SynapseXen_IllIli(SynapseXen_IiiiIliiIliillliIllI[1657678270],16)local SynapseXen_lIIiIIiIIIII={}for SynapseXen_lliiiI=1,#SynapseXen_IlIIIliiillIiiiIiIi do local SynapseXen_illIlliIl=SynapseXen_IlIIIliiillIiiiIiIi[SynapseXen_lliiiI]for SynapseXen_iiIIIIiiIiiIIlIIiIl=0,#SynapseXen_illIlliIl do local SynapseXen_liiiIiiiIi=SynapseXen_illIlliIl[SynapseXen_iiIIIIiiIiiIIlIIiIl]local SynapseXen_IliIiliIlIiIill=SynapseXen_liiiIiiiIi[1]local SynapseXen_llIliiiiilliIl=SynapseXen_liiiIiiiIi[2]if SynapseXen_IliIiliIlIiIill==SynapseXen_iIIIlIIiiilIIII and SynapseXen_llIliiiiilliIl>=SynapseXen_liiiliIilIiIIIlllil then SynapseXen_lIIiIIiIIIII[SynapseXen_llIliiiiilliIl]=SynapseXen_IliIiliIlIiIill[SynapseXen_llIliiiiilliIl]SynapseXen_liiiIiiiIi[1]=SynapseXen_lIIiIIiIIIII end end end elseif SynapseXen_IIiIlI==218 then local SynapseXen_IlIll=SynapseXen_IllIli(SynapseXen_IiiiIliiIliillliIllI[1220663036],13)local SynapseXen_IliIiliIlIiIill=SynapseXen_iIIIlIIiiilIIII;if SynapseXen_IlIll>255 then SynapseXen_IlIll=SynapseXen_IlllilIlliIillIiiI[SynapseXen_IlIll-256]else SynapseXen_IlIll=SynapseXen_IliIiliIlIiIill[SynapseXen_IlIll]end;SynapseXen_IliIiliIlIiIill[SynapseXen_lIiIlIiIIlliilIlII(SynapseXen_IiiiIliiIliillliIllI[1657678270],82,256)]=SynapseXen_IliIiliIlIiIill[SynapseXen_IlIilllIl(SynapseXen_IiiiIliiIliillliIllI[1707011979],40,512)][SynapseXen_IlIll]elseif SynapseXen_IIiIlI==223 then local SynapseXen_ilIIliIllii,SynapseXen_IlIll=SynapseXen_IlIilllIl(SynapseXen_IllIli(SynapseXen_IiiiIliiIliillliIllI[1707011979],68),SynapseXen_IilIiIiIIilli,512),SynapseXen_lIiIlIiIIlliilIlII(SynapseXen_IiiiIliiIliillliIllI[1220663036],125,512)local SynapseXen_IliIiliIlIiIill=SynapseXen_iIIIlIIiiilIIII;if SynapseXen_ilIIliIllii>255 then SynapseXen_ilIIliIllii=SynapseXen_IlllilIlliIillIiiI[SynapseXen_ilIIliIllii-256]else SynapseXen_ilIIliIllii=SynapseXen_IliIiliIlIiIill[SynapseXen_ilIIliIllii]end;if SynapseXen_IlIll>255 then SynapseXen_IlIll=SynapseXen_IlllilIlliIillIiiI[SynapseXen_IlIll-256]else SynapseXen_IlIll=SynapseXen_IliIiliIlIiIill[SynapseXen_IlIll]end;SynapseXen_IliIiliIlIiIill[SynapseXen_IlIilllIl(SynapseXen_IiiiIliiIliillliIllI[1657678270],89,256)][SynapseXen_ilIIliIllii]=SynapseXen_IlIll elseif SynapseXen_IIiIlI==135 then local SynapseXen_IliIiliIlIiIill=SynapseXen_iIIIlIIiiilIIII;local SynapseXen_ilIIliIllii=SynapseXen_IllIli(SynapseXen_lIiIlIiIIlliilIlII(SynapseXen_IiiiIliiIliillliIllI[1707011979],118,512),SynapseXen_IilIiIiIIilli)local SynapseXen_iIlllliilil=SynapseXen_IliIiliIlIiIill[SynapseXen_ilIIliIllii]for SynapseXen_lliiiI=SynapseXen_ilIIliIllii+1,SynapseXen_IlIilllIl(SynapseXen_IiiiIliiIliillliIllI[1220663036],83,512)do SynapseXen_iIlllliilil=SynapseXen_iIlllliilil..SynapseXen_IliIiliIlIiIill[SynapseXen_lliiiI]end;SynapseXen_iIIIlIIiiilIIII[SynapseXen_lIiIlIiIIlliilIlII(SynapseXen_IiiiIliiIliillliIllI[1657678270],57,256)]=SynapseXen_iIlllliilil elseif SynapseXen_IIiIlI==204 then SynapseXen_iIIIlIIiiilIIII[SynapseXen_IlIilllIl(SynapseXen_IiiiIliiIliillliIllI[1657678270],76,256)]=SynapseXen_IlllilIlliIillIiiI[SynapseXen_IlIilllIl(SynapseXen_IiiiIliiIliillliIllI[1826411724],159843,262144)]elseif SynapseXen_IIiIlI==165 then SynapseXen_llIlIilIillii=SynapseXen_llIlIilIillii+SynapseXen_IiiiIliiIliillliIllI[1522539826]elseif SynapseXen_IIiIlI==185 then local SynapseXen_ilIIliIllii=SynapseXen_IlIilllIl(SynapseXen_IiiiIliiIliillliIllI[1707011979],65,512)local SynapseXen_IlIll=SynapseXen_IllIli(SynapseXen_IiiiIliiIliillliIllI[1220663036],37)local SynapseXen_IliIiliIlIiIill=SynapseXen_iIIIlIIiiilIIII;if SynapseXen_ilIIliIllii>255 then SynapseXen_ilIIliIllii=SynapseXen_IlllilIlliIillIiiI[SynapseXen_ilIIliIllii-256]else SynapseXen_ilIIliIllii=SynapseXen_IliIiliIlIiIill[SynapseXen_ilIIliIllii]end;if SynapseXen_IlIll>255 then SynapseXen_IlIll=SynapseXen_IlllilIlliIillIiiI[SynapseXen_IlIll-256]else SynapseXen_IlIll=SynapseXen_IliIiliIlIiIill[SynapseXen_IlIll]end;SynapseXen_IliIiliIlIiIill[SynapseXen_IllIli(SynapseXen_IiiiIliiIliillliIllI[1657678270],46)]=SynapseXen_ilIIliIllii%SynapseXen_IlIll elseif SynapseXen_IIiIlI==121 then SynapseXen_lIIIi[SynapseXen_IlllilIlliIillIiiI[SynapseXen_IllIli(SynapseXen_IiiiIliiIliillliIllI[1826411724],222938)]]=SynapseXen_iIIIlIIiiilIIII[SynapseXen_lIiIlIiIIlliilIlII(SynapseXen_IiiiIliiIliillliIllI[1657678270],40,256)]elseif SynapseXen_IIiIlI==141 then local SynapseXen_liiiliIilIiIIIlllil=SynapseXen_lIiIlIiIIlliilIlII(SynapseXen_lIiIlIiIIlliilIlII(SynapseXen_IiiiIliiIliillliIllI[1657678270],19,256),SynapseXen_IilIiIiIIilli,256)local SynapseXen_ilIIliIllii=SynapseXen_IllIli(SynapseXen_IiiiIliiIliillliIllI[1707011979],108)local SynapseXen_IlIll=SynapseXen_lIiIlIiIIlliilIlII(SynapseXen_IiiiIliiIliillliIllI[1220663036],52,512)local SynapseXen_IliIiliIlIiIill=SynapseXen_iIIIlIIiiilIIII;if SynapseXen_IlIll==0 then SynapseXen_llIlIilIillii=SynapseXen_llIlIilIillii+1;SynapseXen_IlIll=SynapseXen_iIliiiIll[SynapseXen_llIlIilIillii][896369354]end;local SynapseXen_ililliliIIIlliiiIl=(SynapseXen_IlIll-1)*50;local SynapseXen_iiIllil=SynapseXen_IliIiliIlIiIill[SynapseXen_liiiliIilIiIIIlllil]if SynapseXen_ilIIliIllii==0 then SynapseXen_ilIIliIllii=SynapseXen_IIiiiillliiIlIlIiIil-SynapseXen_liiiliIilIiIIIlllil end;for SynapseXen_lliiiI=1,SynapseXen_ilIIliIllii do SynapseXen_iiIllil[SynapseXen_ililliliIIIlliiiIl+SynapseXen_lliiiI]=SynapseXen_IliIiliIlIiIill[SynapseXen_liiiliIilIiIIIlllil+SynapseXen_lliiiI]end elseif SynapseXen_IIiIlI==63 then SynapseXen_iIIIlIIiiilIIII[SynapseXen_IlIilllIl(SynapseXen_IiiiIliiIliillliIllI[1657678270],65,256)]=not SynapseXen_iIIIlIIiiilIIII[SynapseXen_IllIli(SynapseXen_IllIli(SynapseXen_IiiiIliiIliillliIllI[1707011979],64),SynapseXen_IilIiIiIIilli)]elseif SynapseXen_IIiIlI==9 then local SynapseXen_liiiliIilIiIIIlllil=SynapseXen_lIiIlIiIIlliilIlII(SynapseXen_IiiiIliiIliillliIllI[1657678270],35,256)~=0;local SynapseXen_ilIIliIllii=SynapseXen_IlIilllIl(SynapseXen_lIiIlIiIIlliilIlII(SynapseXen_IiiiIliiIliillliIllI[1707011979],115,512),SynapseXen_IilIiIiIIilli,512)local SynapseXen_IlIll=SynapseXen_IllIli(SynapseXen_IiiiIliiIliillliIllI[1220663036],110)local SynapseXen_IliIiliIlIiIill=SynapseXen_iIIIlIIiiilIIII;if SynapseXen_ilIIliIllii>255 then SynapseXen_ilIIliIllii=SynapseXen_IlllilIlliIillIiiI[SynapseXen_ilIIliIllii-256]else SynapseXen_ilIIliIllii=SynapseXen_IliIiliIlIiIill[SynapseXen_ilIIliIllii]end;if SynapseXen_IlIll>255 then SynapseXen_IlIll=SynapseXen_IlllilIlliIillIiiI[SynapseXen_IlIll-256]else SynapseXen_IlIll=SynapseXen_IliIiliIlIiIill[SynapseXen_IlIll]end;if SynapseXen_ilIIliIllii==SynapseXen_IlIll~=SynapseXen_liiiliIilIiIIIlllil then SynapseXen_llIlIilIillii=SynapseXen_llIlIilIillii+1 end elseif SynapseXen_IIiIlI==126 then local SynapseXen_ilIIliIllii=SynapseXen_lIiIlIiIIlliilIlII(SynapseXen_IlIilllIl(SynapseXen_IiiiIliiIliillliIllI[1707011979],48,512),SynapseXen_IilIiIiIIilli,512)local SynapseXen_IlIll=SynapseXen_IlIilllIl(SynapseXen_IiiiIliiIliillliIllI[1220663036],35,512)local SynapseXen_IliIiliIlIiIill=SynapseXen_iIIIlIIiiilIIII;if SynapseXen_ilIIliIllii>255 then SynapseXen_ilIIliIllii=SynapseXen_IlllilIlliIillIiiI[SynapseXen_ilIIliIllii-256]else SynapseXen_ilIIliIllii=SynapseXen_IliIiliIlIiIill[SynapseXen_ilIIliIllii]end;if SynapseXen_IlIll>255 then SynapseXen_IlIll=SynapseXen_IlllilIlliIillIiiI[SynapseXen_IlIll-256]else SynapseXen_IlIll=SynapseXen_IliIiliIlIiIill[SynapseXen_IlIll]end;SynapseXen_IliIiliIlIiIill[SynapseXen_IlIilllIl(SynapseXen_IiiiIliiIliillliIllI[1657678270],76,256)]=SynapseXen_ilIIliIllii*SynapseXen_IlIll elseif SynapseXen_IIiIlI==11 then local SynapseXen_liiiliIilIiIIIlllil=SynapseXen_IlIilllIl(SynapseXen_IiiiIliiIliillliIllI[1657678270],55,256)local SynapseXen_IliIiliIlIiIill=SynapseXen_iIIIlIIiiilIIII;SynapseXen_IliIiliIlIiIill[SynapseXen_liiiliIilIiIIIlllil]=assert(tonumber(SynapseXen_IliIiliIlIiIill[SynapseXen_liiiliIilIiIIIlllil]),'`for` initial value must be a number')SynapseXen_IliIiliIlIiIill[SynapseXen_liiiliIilIiIIIlllil+1]=assert(tonumber(SynapseXen_IliIiliIlIiIill[SynapseXen_liiiliIilIiIIIlllil+1]),'`for` limit must be a number')SynapseXen_IliIiliIlIiIill[SynapseXen_liiiliIilIiIIIlllil+2]=assert(tonumber(SynapseXen_IliIiliIlIiIill[SynapseXen_liiiliIilIiIIIlllil+2]),'`for` step must be a number')SynapseXen_IliIiliIlIiIill[SynapseXen_liiiliIilIiIIIlllil]=SynapseXen_IliIiliIlIiIill[SynapseXen_liiiliIilIiIIIlllil]-SynapseXen_IliIiliIlIiIill[SynapseXen_liiiliIilIiIIIlllil+2]SynapseXen_llIlIilIillii=SynapseXen_llIlIilIillii+SynapseXen_IiiiIliiIliillliIllI[1522539826]elseif SynapseXen_IIiIlI==81 then SynapseXen_iIIIlIIiiilIIII[SynapseXen_lIiIlIiIIlliilIlII(SynapseXen_lIiIlIiIIlliilIlII(SynapseXen_IiiiIliiIliillliIllI[1657678270],49,256),SynapseXen_IilIiIiIIilli,256)]=-SynapseXen_iIIIlIIiiilIIII[SynapseXen_IlIilllIl(SynapseXen_IiiiIliiIliillliIllI[1707011979],104,512)]elseif SynapseXen_IIiIlI==221 then local SynapseXen_liiiliIilIiIIIlllil=SynapseXen_lIiIlIiIIlliilIlII(SynapseXen_IiiiIliiIliillliIllI[1657678270],60,256)local SynapseXen_ilIIliIllii=SynapseXen_IllIli(SynapseXen_IiiiIliiIliillliIllI[1707011979],28)local SynapseXen_IliIiliIlIiIill=SynapseXen_iIIIlIIiiilIIII;local SynapseXen_illliilIiil,SynapseXen_llIlIilIllillllIl;local SynapseXen_iIliIIIlIIlIIlIIlIl;local SynapseXen_llIill=0;SynapseXen_illliilIiil={}if SynapseXen_ilIIliIllii~=1 then if SynapseXen_ilIIliIllii~=0 then SynapseXen_iIliIIIlIIlIIlIIlIl=SynapseXen_liiiliIilIiIIIlllil+SynapseXen_ilIIliIllii-1 else SynapseXen_iIliIIIlIIlIIlIIlIl=SynapseXen_IIiiiillliiIlIlIiIil end;for SynapseXen_lliiiI=SynapseXen_liiiliIilIiIIIlllil+1,SynapseXen_iIliIIIlIIlIIlIIlIl do SynapseXen_illliilIiil[#SynapseXen_illliilIiil+1]=SynapseXen_IliIiliIlIiIill[SynapseXen_lliiiI]end;SynapseXen_llIlIilIllillllIl={SynapseXen_IliIiliIlIiIill[SynapseXen_liiiliIilIiIIIlllil](unpack(SynapseXen_illliilIiil,1,SynapseXen_iIliIIIlIIlIIlIIlIl-SynapseXen_liiiliIilIiIIIlllil))}else SynapseXen_llIlIilIllillllIl={SynapseXen_IliIiliIlIiIill[SynapseXen_liiiliIilIiIIIlllil]()}end;for SynapseXen_IiillIiIiilIIIlII in next,SynapseXen_llIlIilIllillllIl do if SynapseXen_IiillIiIiilIIIlII>SynapseXen_llIill then SynapseXen_llIill=SynapseXen_IiillIiIiilIIIlII end end;return SynapseXen_llIlIilIllillllIl,SynapseXen_llIill end end end;local SynapseXen_illliilIiil={...}for SynapseXen_lliiiI=0,SynapseXen_iIilII do if SynapseXen_lliiiI>=SynapseXen_ilIlIIlIIIIl[1508668597]then SynapseXen_IliiI[SynapseXen_lliiiI-SynapseXen_ilIlIIlIIIIl[1508668597]]=SynapseXen_illliilIiil[SynapseXen_lliiiI+1]else SynapseXen_iIIIlIIiiilIIII[SynapseXen_lliiiI]=SynapseXen_illliilIiil[SynapseXen_lliiiI+1]end end;local SynapseXen_ilIIliIllii,SynapseXen_IlIll=SynapseXen_IliIliIiIlIlIIiiili()if SynapseXen_ilIIliIllii and SynapseXen_IlIll>0 then return unpack(SynapseXen_ilIIliIllii,1,SynapseXen_IlIll)end;return end end;local function SynapseXen_lIiIillilIIl(SynapseXen_lliliIlIiIIIli,SynapseXen_lIIIi)local SynapseXen_llIliII=SynapseXen_llilIil(SynapseXen_lliliIlIiIIIli)return SynapseXen_lIilIlillIlI(SynapseXen_llIliII,SynapseXen_lIIIi or getfenv(0)),SynapseXen_llIliII end;return SynapseXen_lIiIillilIIl(SynapseXen_liiiIllliIillliI("YxsAWABlAG4AEQAAAAUBTQBRAE8AQwBGAFoAMwBTADgAUgBRADUAMABVADIATAAAAFoAawDlAFMASwCLAJYA3ABjAAkAPwCFAPoAVAB+APMAiQAqAJQAcgDDAAgAYgA7AD4AogBcAEkAlwBSACcAtQA0AKAAcwBiAGcA/QAPAJkAHwBRAN4A2wCnAF8AVwDsADoAcABpAIUAAgBLADYAYQDOABIAWgBEAD0A2wDMAM4AWwB+APYAzwCyAMQAQQAmAFoAhABUAVYBBQBZAVsBXQFYAKMA4gAdAFgAuQBBAGgAVQChABgAAQAJAEEARQAQAHcAwwA4AKUAsQBYAOcAkwBWAIEAswBBAG8AdwF5AXsBGACcAHEAEgDKABQAzgAlAHYAJQBmAGEAeQDOAHIAGgD1AN8AgwBrAEEARgBcAH4ACgCMAc4APwAUAOkAMACQAMAAQQAsABAA9wCGAbEAZACHAHwA3AAHALcAzgATAHABHAAZAHQBLwAQADcArQFxANwAvgANAKEBfgCcALEAoAGNASYAVACpAKYBqAFcAKsBrQE6AJwA8QDHAc4AMQANALMAvACyABEAQQAMAFQApQGnAUEAUgCFAXoBsQAQAFoA9ADfAIEAmwEdANcB2QHbATsAGgAHACsAVQHOAE0AcwBtAHQArAApAEEAQgCaAIYA8wFWAXQAzQDYAbMA2wFsAIkA/wBBAFYA2gBBAAUAWgDHAAACzgAdADMAbQD0AK0A+wFQANoA/wH0ASAAjQAEAtsBFgBVACEAngAYAHQBXQDjAXsBWACJAL8AwQBXAAwCKgC8Aa0BPQBaAAQALgD0AR8AlwGZAZsBaABHAOgAVgCCACoAQQBdABoA9wDfAIAAmwE1AE0AsADuAUEALQC4ACoA0wCZABIAQQA2AHMALgB7ABcCQQAgAJoAWQAqAPQBbwDzAG8AdACvAPsBJgAaAJkAEQJpAE0AMQC8AAUCQQBiAM0AsAA8ANoBQQBMAJQAqwDMAUEAMQAxAuQBNgBPAlMAUgJaAgcA6wDWAIQAQQJ0AFQA6AB5AnkAvAHBAOQBBgAoArEAVwCcAPMAEAChAScAtgAlAHMAkwHOABwAWgCGAF4CVgEhADMAbgD0AGQCCgLaAGgC9AExAI0ASwJuAgYAmgD3AF8AhgCbAUAAvAHCAOQBIQBaAMYAoQJXAaQCpgL7AUQAqQIRAnwArQJtAtsBUQCxArMCmwEYADMALgB6AFkCVABaAPYA3wC0AkEAaQCNADAAwwBuAj0AEAC3AK0BUQDUAIoC4AFUAHwCewEuAugBhACbASQApAB7AF0AqAAWAEEAWgDeAj0AxwB7AX0ARwC/ALIBtAFLADkCRwJeARoA9gDLAkEAWABNALEATAIRALMALwB6AKcCIADaANQC1gJUAA0AMQDbAtsBZwDeAq0BLwCVAGAA2QCjAHQBKwDmArEAHQDeAjwA9gKSAiQA7gLwAkEAAQD0AiYDAwCoAOwA1ABGAA8AWgKeAQ8AoQF9AJoAxAAwAPQBEgDaAAQANwD0ASwAPgB1ADYAhAAiAEEALwDaAEQAQQNWAW0ARANGA0gDFABVAOEAlQCrAHQBRACRAisAxQE3A40BKQCRAogBMwAXAKEBSgBnAJAAVgD5AIIBeAA5ApoBQQBIALMA7QD6APoBQQB5AFoABwAoAPQBTgD4ACoAgAJTAiAADQAzADwAsADbASEATQCzAHMC2wFiAIYDTAJ9ALMAbQB5AKsA+wEqAN4AjABYAIgAbgBBAFAAAADCAKAA+ADfAEEAewDtAW4CfQD3AZAD+wEfAB4AlQOXA0EAZQA6A00DzgBrAD8DNgD0AToAUANHA0EAKwBLA7MDVgEYAP4AtgDcALMAXQFeANoAhAC7A84AeQC2A0gDFwAiApYAVwOZA5ECSACaAIQALAD0AT8AZgM/AoIBPwBAAAIApwCeA0EAJwADAscCQQAoABQCpgNUAl4AqgOYA0UAVQBhAB0AJgB0ATgAkQIgAIAARQDdA58DfQCRAkAA1wP6AIIBRwA2AGQAcACcAigAbAObAQwAHgLiA20AIQNhABoAWQB4A1YBCwBcALEAwgGNAXsA2wMmAP4AnwN1AJECAwD+AQ4EzgBZAJoAmQAeBE8AEQQTBM4AAgAWBP8AnwMUAJoABAA1APQBDABLAy8EVgFJAL4DwANdAQEAxAMzBM4AWgDJA0EAGADaAMQAOwQSAD4ESgDsA5cAzgMeACEDMgD2AOUAAQSUAScAJQShAX8A2wOmAPwAnwM5AJoARAA0APQBDwDEA1wEVgF4ADYEwQN0A0EEYATOACsAYwRdATcA7AOIAM4DcQCRAjAA/wN9AJwCfQAcAGIDoQE9AFIEjQFYAMUA/gBNAU8BPQBLAzsA9AFfAD4ETADEA4QEVgFKAGoEQQANAEEEigTOAGMAjQQEAOwDiQDOAxMAkQJ3ANsDJQBXBEEAeACRAj0AtgBjAHQElAErAHYAIgByAJwCGwAEBEEAXwDzAG4A/gBzAzUAGgCGAC0A9AFrAEcA/wD7As4AIABNAHAAggPbAQ0A8wDuALIE+wEyAMUAPgBEAE4BzgAhAEsDOgD0ARUAjQQAAFQDigDOAwwAkQI0AP8DewCcAlEA1wOHAIIBEgAaAAYA1ANWAQIAvwTiA0kAhwCEAoMAQQJLALMAbgD9AHMDZwDeAE8A2ACJAJgDHwCRAgQAHAByABEAoQFXAGYD1gD4AIIBNACaANkANgIPBDoD0ASiAj8DOQD0AQ0APgRNAEsDDwVWAQQAPgRnAMQDFQXOABoAPgQeACICiwDOA7sBeAHkAQcAqQLlBM4AfAAhA2QAmgBbAC8A9AFDApgBbQMaABoA2QAoBXYAdQBzAE4AjwCNAHUChwA+AOMAswHOAFAADQByAoMDQQAiAEQCXwCHAJsB7wSxBHMDGwDJBD4AKgBPAUMAPwM4APQBPACNBFMASwNYBbwDjQR4AMQDXgXOAHsAPgRgACICjADOAzsA0AMCBYUAggEPAG0FggFZAFoABgAzAPQBOACHAH4AQQW0AVMADQDABEcFZwDwBMYEQQBTAFoARgB2BVYBEwCHAL4AewXOAF0AfgXBBOEBswCuAHwAcwMJALsCCQXOAEoAhwD+AI0FBwCQBUcFdgCTBZUFGAKfAigFBQA/BeIAQgU3AKAF2wFtAKMFcwM0ALsCKAVnAHkFqgV8Ba0FQQB+ALMAxQRZAhYAuwKIBSkFfgXiAzgAxwDrAFYA7QRBADsAcwDxBFkCcAAeAE8AWACMAJgDTgDaABkAMgB5A+wDHAAaAHQBGgQkBXsBVQDaAFkA2AVWAQkAAgXgBEEABgAMBOQFzgBeAFoAmQDsBVYALQQ/ABwCSwP0BVYBLgCNBFYFhAD3Bc4AEAA+BHYAIgKNAM4DRgCRAmMAmgDYAOwFhAHfBbEAWQEnAE8EzgAZAFIBYwUAAK0EFADaABgAMQD0AUwAGgBYABoGVgFsAFoAmAAfBs4ATgAtBD4A9AFgAEsDKAZWAQoAPgRGAMQDLAbHA40EaABBBDIGNQS/A2QEeADsA44AzgPOAQwGAACaANsAJAYXAJECdgAaAMcAJAD0AQUAtgBlABAGRACtBGgAtQByAM4AigA9BX0AxwC+ALcFzgB/AHECkQVDAFoARQLWAigAcwCuAPwAWQIgACICiQAOAHQBMACRAvIFGQA8AwECkQJdAAIFhgCCAT4A1wOEAIIBIACtBG8AxwD+AFsGDwDNAH8F2wEYAMwF/gBZAgcGWQByBs4ANwDHAD4A4QBCBeADhQZBACQAcwDFBHMDYgAhBI0GAACEBuIDFAC3AEQAIgCFAHwAQQBKADcAuwCcAEIADQBsAPEAxgB2AGsADQDiAI8AVQAnAKAAUgBDAAwAeQCsAMsAPQB4AAgABQEAAMoAyADZAMsAyADDANsAAAA9AAAAFADCBv0A/wDiAPkA4gD+AOAA7AD+AOUA6AD/APIA4QDiAOwA6QDoAOkAywZBAMEGBQHEBtkA3wDIBsoGPQAeAAcAwgatAMkAyADPANgAygDLBgcABADCBt4A2ADPAAAAXwABALkAaQAwANcASgDEACQAZwA9ABkACwDvBugGVgHyBlYBxgDLBj0ABQDCBssAxADDAMkAywZrAO4GBQGtAOEAFgfIAI0AywYsABsHAACtAJcAiADJAIYAlwDLBjsACgDvBh4HwwAgBygHhgDLBncAJAfKAMAAzADZAM4AxQDLBmwACgcFAcEAwgDMAMkA3gDoBhYH9QY9AC0AEwfmBswAwADIAMsGCADlBgAA5QDZANkA3QDqAMUGywZYACIAwgbFAFYH3QDeAJcAggCCAN0AzABGB/IGFgeDAM4AwgDAAIIA3wDMANoAbwfHAOMA5wDuAN4AyQDuAMsGeAANAMIG7gDpBjoHyAD6ABYHyQDCANoAywY5AEwHAADZAMgA1QDZAMsGYACKB+wA2ADZAMIAewcuBwUB+QDIAMEAyADdAMIA3wDZAN4AywZIAAkAfgffANQARgfMAMEAogc9AHAAAwDCBvIA6gDLBlEADADCBpMHlQfpBs8AxACgBz0HrgBdBz0ARAAOAMIG/gDdAMgAyADJALcHwgDLAMwA3wDAAMsGUwClBwUByQfiAMUHwwDLBjMAigfuAMQA2QDUAAAAlgA9AD0ANgCYBwAA7ADJAMkA+QDCAMoAygCcB8sG1gG2B5QHwgCNAP8AaQe8B8sGEwDRB+QH5gfhAMwAzwCbB8sGCQAPAMIG+gDFAMgA6QaNAMwHIAfUAMIA2ACSAMsGBAC1B9IH5gfpAN8AwgDdAIUH2gDWBz0AMQDjB/4AwwCGB40A2gfcB8sGZABABwAA4ADMADgHzAAgCNsH3Qc9AD4AAQgFAcQHxgfJAI0AyQfLB80HywZeAH0HBQFZB8AANQjwB+sAzAfOBz0AUQDjB+UHyQDvAJQHlQcZCAgAwgcFAQMIOgeNAM4ApwepB8EADQg9ABYAMAgAAP0A2ADfAN0AnAcgCFQI2QCqB8sGSgAQCAAA8wc0CH8HqAdjCMEAywZ6ADsIAADvAMEA2AAgB2sIVQgsBxIAwgYeB8oAXwfDAEgHYQhsCGQIvwZxCB0IHwh3CG0IywYnABAAwgbkAMMAxwbfAB4IgQh4CD0ACQBxCPsHVQGTCIkIPQAoAFoI9ACbB0IH2gCaCIMIHABxCNQHyAajCG4IPQA6AHoI0gfwB40ApwjDAKkIywY0ABkAwgYnCPEGjQDPANQANQjPAEYHcAfOANkA/QDCAPEH2wCeADgIXwB+AAAHcADcAGQAMwDwAGYAXwBTAAAHAgdKALgAkgBnAF8ARgDUCAMHwwCcANkIWQAAB7AAvQBoAM8I0Qh7AOIIIwBTAMcA8wDRCAgA3AhKAHwAggDZCC4A8AiDAOUA2QgeAPAIjAC4ANkIWgDLCNoA8QCkAP4A0QgzAAAH0AC2AHgAWgDAANEITgDwCKQASADZCFwA8AjnAJoA2QgHAPAIiACPANkIOgDLCIsAvgC/APwA0QgYAOIIIgAlAC8A6QDRCDEA8AhFAPgIXwByAPAIigDkANkIOwDiCBkAcQD1AMYA0QhIAPAIdACtANkISQDwCDwAjADZCHoA3AjEBuYA2QgmANQIcQDWAKUA7QAqCfAI+ACIAEAJ4ghMAHgA6wAECV8A9QgBB+gAUgAaAOMA0QhNAEcJLQAzCV8ANADwCHwAsgDgCPAI2gCYANkI6AhpALAAuAC8ABkAYQlfADUJAQcDByYAhgDZCCsARwllAC4JFgDwCKcALgkCANQIRwDWACwAkgDRCP8GaQBQALEA8gC0AQUJRwlBAOcA2QhAAPAIuQBJCV8AQgDiCH8AkgnOANEIfwlpAHAAIgASAJcAwwDRCDUA8AgtAJ8AEgnwCCYAFglfABAA8AjSAIoAmAkAB/AA4gARAKkJ0Qh3APAIeAC1ANkIVADwCCwArADZCDwJeglKAAQAewBnAL0A/gD8AG0ABAABAIEAUABzAKsAOwBJAZ4B1AEBAKIGogCEAKYGXwCiBqQGpgZ1AIQAaABOABYAbQD+AP8AAABUAGsAcABDAMUAnwA6AKAAVwAhAFIAvAa+Bn0AigfyAOgA4wD7AAAAmwA7AKMAKgAIANUJUAAtAKwA2glpAD4AIwDMAKsAIwCEBaMAeQBOALYA3QBBAFQA3wmlBkgF5AkdCh8AYQDZAHUACAA4AHgAAQA9AFkAagAFAHIAywDFAAYAoABYAG8AUwD7CSUAogBwAEcACArWCQUA/QANCtwJoQFrAFoEKQD0ATkAxANDClYBOQA+ADUAoQCiAEgDLwAiAhsAgQAmApECAACJAdQBtgK9AeQBWQC2AKMAdQCcAjMArQR5AEkAPAAAAAsC6QWrABgARQCaAD8AlgbsA5gAAwB0AT4AkQJCAEAAgwBjABoAnwMRAJECRgACBXsGQQBbABwA/gAIAKEBHgCtBOsDoQAbAAYAdAEAACEDCAAaAEcARwrOAAkAPwqNATsALQQeBB0ASwMeBFgASgpMCkgDSwDEAx4EEAD+AHYAzwBkBFMDIQAcAFIKQQAJBAwGegAJADwAgABmCgcAIQMFANcDgQFBAE4ArQRnACICGACDAHQBaACrAcgA5AE3AAUAAwCABM4AAAA/Ay8FVgEnAJ0KTQpBAMICRADMCikFzwpIA2kAVAMdAKsKUwDyA9ID1ApbAJwAfgAmBBsAXAA+AAkAoQF6APMArQAJAJEDpwYaAIcAEQJ1AIsDbgJHAAkA/ACBAGYKPgAFAMMAyAq5A8QA1Ao6AKQKpgpdASoAPwOZBUYAAgtkBH0ASwOZBWIACQtdAX0AVAMeAKsKHACRAgEFZwO4ChEAGgCEANQKcAAJALwA+AoMAisA6goIAO0KbACRAjgAdgAjABAGcgACBYMAggEBAO8KvQJWAPYB4gNWAFwAggqhAVoANQt0AloAxgpTBU8BMAbEAJkFMwAPC0EAWQDsAxMLdAFIAJECFgCUCs4ANAAhA2gAGgBDCykGrQRzAbEKZgpeAOwDGgC/CisDqwEzACYDGgAhA00AdwFhC3sBLgAfCqYGCQGFAFMATQBbAAUAvQAXAAgAawBqAEoA0ABcAAUAoAA6AGQATwD7CT0AUACvBwUBsQfXB2cIyQe5B7sH2QC9BwwAKAoSB8IGygBOB1AHPQBnACUIWQfZAP4ABQjbAMQAzgCSC2gArQhoCJ0HwQCbC4EHyQD+ALgHKAiSC2kAUwffAOgA2wDIBqEHywYaAHEIiAu8B60LrwvLBiQAJQjrALsHyACYC98ArgvfAMsGdABaCLQLigvzB9wAdQhGB8sGGwCKB9oAzADbBwAArgBtAP0GeADLCDUAswAkAPIAvwnwCOgAswDZCGAA4gi4ALIA2QvRCGEAugmbACwAzQDJANEIMAAPCVkAyQnwCNAAkADZCHkA4ghDACIA6gvRCB0A8AjAAJ0A2QgbAPAImgCXAPQLywivAGMAaQDHANEIDwDwCMYAAwxfAFUA8AicAJkA2QheAEcJYACcCT0A4gj7AMEALwDrC18AaADwCF4AVAlfACQA1AjhAGMAMwAiCbkAkQCqACUAOgpQAE0AoAANClYKQAohA1QAegZ8BtwA0wGhAWIA2gDoAW0DYwADAjwAbgImAIAAwgB3Cp8DPAC3AEUA5QkEAxEAIADHABYBEQDuACkAdwBrAGYACAApAPoAOQChAA0AfwBQAH8LYACCCwAAhAvhB9kHLAhbB/gHlQe/CEgHAAAXAJEAEgBtAC8MegDEADkASQHFAEIAyApYAJoAxwDAANwAVgEiAD4ANgBOAFwBQQALAJoABwDHAH8MnQL+APQAIQCjAEgDSADjAGIAlwDhCAoC7AOeAH8AdAEjAJECNgAnAH8BuAq0CQwGKgCBCh0AUwQbC2MFUAYyBZsBGgRZCnsBVgAuC4IBCAA0DI0BRgDcAHEA1AFNAMUA/wDLBE8BFgAaAEQAHgQTAH4A9QA1AIsASAM5AFQDnACpAHQBJAAhAxcL1gCCAIIBewCJAD8AgAAuAnQD6wAYAMUAsgBsCkUMRwzNAJ8DNAC0DKIBQQQeBDELBADUClUAxAzGDEgDfgDADNQKBwC+ADYAYgBkBA8AVAOdAMwMQQA3AFoDYwplCgwCrQytAUkA9gDjAHYAnAJJAK0EAwAiApgAzgMZAN4CDgF7AQwAnAAxAOcKjQECAHABGAAuAHQBBQCRAnkAXADxAF0DzgAiADYA4wBxAJwCAABJAHwAAQBmCjIAYworDQwCcQBBBNQKdwo1AvQBBADsDMcMQQA5AMAMmQUSADgNSAM4AoQAmQVEAPMM9QxdATMAIgKeAPoMVQBUCkkA/AAvDV4BIQMRANcD0gxBAEcGqwxBABQAcAP1AHMDFwA/A7cEogLADGANzgBhAD8NQQBgABsLYw0iAEUNZARwAFQLYw0MAGYNSQDsA58A+gxgAJECPwBaAEcAvQIqBQwGSQBLA2MNfQC3CoIB6gVYDWwEIQCaAC8AdAFKBAwGXQB2AxECWQA2AGMAdwCcAnkA/gG9AnMAxQA/AEALzgBCAMAMKAVbAGwNEAsbCygFHABmDWsAIgKQAPoMFwOuDLEASwC2ACMABg2UAQQAnABwANQBVgBJAP8AAgBIAAANDQBzALwARwUjABMNFQ2OBikNUA0MAJoNnA0EABoABADBBXUAog1nDXABkQD6DM4MrQ0YAJoAhwC9An8ALg1mChAATg1QDSYAWw1zAygAeg29AhwEoAL0AesDYQCbACAAdAE8AJECSQC1DdQBIQAhA3kGkADWAC8LoAOtBDYAuQ27DQwCIwC+DcAN2wFMAMMNoQEYAMYNZgoDANwNDAJRAN8NZgo7AOIN+wEkAOUN9AFEAMkNVAXOAHUAGwvBBToAZg0lACIC0w10AbQKDAZzAJcNuAQhAxwA1wNuBXUBrQTvDQwGdQMHAMEFEACcAPAA/wSNAZMCtg3oCnABmgAhAHQBdgGtDVsKIwAmDZQBaAD9DbwNdQIBDkcFGgAXDk8BWADMDewFOADQDWgNRADsBSIAZg1GAFQDkgD6DA0AjQp9CnwGBQ6NAVEAQQTxBcwNJAYeANANCQDADCQGMwDQDToAGwskBjsAZg1nBSEAkwD6DJwMDAZEAAgODAJrACEDHgACBVUNtARYDQcOPABQDSgADg4MAqIF7QBcDfsBDAAUDlYBKAAiApkA7Q1NAiEDJADYDZEKPAAmDlYBXQA/A40GcwDADI0GMABmDTYAGwuNBjYAZg13CjsD9AFsANANZADsA5QA+gziAa0NdABNBHwAnAKIATkOjQF+AEYODAJSAEkO2wEZAGAOzgAFBq0NJgCDDUEAMwB6DpwBCw5BAFUAhw5BABsAEQ5BABIGew30Ac4ETAP0ARQAGwuvA30AZg0uACIClQD6DGUAeA2aDs4ADwAhA2kAOAxBAL8MWA0fBWEAmAAeAHQBtAmtDSwFxgBjDWQA8g2hAXQAvA5BAGMAvw5BAG4Awg5TAMoOfADMDlcAzw5OANIOfAAYDSgAdAFQAJECUACODs4A3AqtDR8AwAHEDWIArQR/AJECYgCZAkMOQwW1DSENewzoDVYBYgAiAhAAuQFBAFcAkQIJAPkOjQEiACEDOwD2ACUAXgqUAV4ArQQtDboNRw6fBb8NRwVQAMIOIwCyAzAFwAzGA3oAZg08AFQDlgD6DFYAKAsfDYMKjQEBA2IANQ/OAG4Ayg4fDnEBEgB0AWMAKAstBCgFXwBeDkEASQDMDrsOTw1mCkwA0g4dAEwOzgBRAFQLxgNEDfQMZAQqAMwNOwQOAGYNCg2hAJcA+gy2AgwGLQBaAMQAEQIZALYAYgAfDzMC1Q5WAWsFDAYIAC0E7AVbAOoOQQDlDjgALg/OAAQA/A47AP8OSwDCDisAxQC/AMgKNAAbCzsEcQBmDTELQgTZDtANeQDMDWcEGgBmDQUAcAGIAPoMcwCRAloAyg4bD60NFwA0AigFpw+CDswOWADPDkMMig5zA5UEoQAfAO8DQQBqAJEC1A69AggAIQN5ANoABgCNBk0ArQRjALsMyAowABsLZwRlDcUMOQ3vDMQAqQ/QDRMBYQCuD3QBPwCRAiwA2gC8AqsOnAAwADYO7QXlDgsLRACRBBMAGwuRBGcOcA9dAUYEIQCJAPoM8wIMBhwApg0OAHkEHw2LAY0BmA+5DuYO/A6WCD0P2wEPAMIOZgBUA4gACQB0AS4AkQIBAMoOWQOtDSMANAIkBi8ArQQeAMwOPQDPDoYDvw/7AWsAEg8yAOUOsg6tAXUG9w13BkEAUQCSD0EAkQIfAHYAYwB/AJwCFQC2AOIAUw9fAPwOagD/DkUAwg5GAMoObQDMDiAAzw4aANIOZQBUA2gCdAGMAgwGDgASD2EAkQJoADYAIwDcBJQBLQA4CxQAoQG6ClgNeQBqD28AzA0MBc4APQBmDXwAwAxiEAIAZg0PDOEAigD6DDoAIQN3AFQNggFBBiQPvQQhA28AchBBAB8Akg9yAFQDmAApAHQBSgD5A/wOWAqtAXkApg0aAKEBGQCtBHwA/w4nAEEEYhBsAMwNGwUkANANQwDADBsFSQCmDxsLGwUNANANvAohAIsA+gxeAJECKQD2AGUAZwCcAiAAEQRPD84APADCDuUCrQ0OAwcArwMdAMoOOQAhA2MA4QrUAUUQhA5mClQAzw4+ANIOQAAiAhYAFQB0AfsPrQFnABIPxg8MBiUAsQwqD9oASQZ5A60EEhAMBlAA6g4kAFwA/wAYAKEBWQR1EBUAVwX0AUgAwAxjBWsAqw+oDPQBYgDQDVQAaAX6DCADDAZ0AJoAxgCZBQMASwORCnUAkg94APwOXAD/Dk0AcAEXACIA8g6RAmQA3ADvDKEBGgCoBFYQzgDEARQNoQFVAMUAfwC9DP4FzA39BV0A0A1pBqEAjQDUDbEPyg7vDa0NTAB+D9QKyw1YDW8QDAYeAOkPIQ0tC2cDfgoqAMwODwwhABEAGwB0AUUGDAY5AM8OcACRAgsAXAphAJwCdAARBN0QjQFpAK0ERxAiEMoFEg8sBXUQNwCSDywA/A5EBQkQYQ/CDkgAcAEUABAAdAF+AMcPyg4KACED+gNnA/kNPACtBE8AVAMRABQAdAFYAHgN6g5HAOkPGQCKEMwOcADVBBEAdAGtChkDOgwVAN4QDwIbBV0ARhDSDg0AEg8CACEDWABcAL4A/w+NARUA5Q5gAJIPIwD8Do8FUBFUABERyApuDfwFqwKoDlQL/QUaANANLADsAxsRdAEmAJECJQ7GAB4EUwC2ACIAHw8zDg4RjQGwD60N1QV1DPQBagDKDi8AzA56EWUPDALXC0YRWwASDwYAmg0TEVcAwAwyBnIA0A1WAFQDjgD6DGMLDAawAnUQuBCtDWEAtgDlAGMAnAIxBToCYQ9wAbUHdAFfA6MM+hDZBNoAhwX0AWcAfAyZBVoALQ78DjUA/w5QAOwDnQAkAHQBWxEMBmsAwg5yCq0NEwBUELYOlAF9BlgNJQA2BvQB2wUEAGIBjgVmDfABUwGtEWYNnw5hAa0R0A1PCiEAjwD6DEwAIQN9APYAowAfDw8Ayg4JACICFABxEXoCkQIGAMwOJhGtAWkAXAp+AJwCeAD+AWcEAgCtBD0AcAEPAIoKbwKRAn0Azw5JACED4ApxAEERzgBcAK0EDADSDnMAEg8SEK0NegCaAEYAZwQMAOUOKgDsA5YAFgB0AQsGrQFqEQUQWQMMBt4E9w1+CjEAKg6CAX0ArQQpAHABDQACAHQB+AMMBnYA/A5pAJECXgATDSMAoQF5AE0GHw/QEW0DcAhQESQAmw/ICjcPBAA8APQBKQBmDTUAcAGAAPoMewCRAmcAwg4SAJECQxGHACQGAQCeAVoQjQHVD1gNQQ+EAG8SVgFbAFQLiBLOAEAAZg3UBGEAdRK6AZoEyg52AQwGcAAtBGIQIwCCER8AoQEhAK0EDQDMDkcAzw5EANIOXwBLA8MAiwxVABsLqRJWATwAZg1AAFQLrRLOAEYP2Q9IAwsAzA3CAIsMUwB2D3ABggD6DAMAkQIkEIYPZA1ND38A6w8uAJoARwCZBQgNWA2gBAwGfwB+D8EFJQD2AOIAPRGUARcA5Q4GAMQDuhJWAUYAVAvdErUB3g7MDcEAqhLQDUgPoQCDAPoM1hGtAU4Akg8bDwwGBgdeEYIBbgA4EG0AnAJWAC0OIQOSEAcAvQIyAToPDAIZAP8O8Q2nEc4AYABwA/QAcwM+AHoNkQonAKIDhgZjCgMAZgpdALMArQD7AHMDLQC+DUMM2wHlD4QA5RJWATgCxAAfE84AcABqEMwNfgxWAUgA0A0xC0QAKBPOAC0A0A1MAFQDhAD6DHAEDAZ9AOQMCQCRAgcA9gCiAHgAnAI5BMYAxgMxAK0EMAD+DGYKfwDsA5sAzgO0D68AJgMWACEDqgG3AKgAJgMMAEsMTQwvAFgANwDtABUALADAALYApgAvAGsAdACYAPgAmQBbAKEAFQB/ACYAfwsYAGMMZQxAAE4IAAAyCMcHNghCCNELfgAoCn8AigeQC08HywYoAJ8L8wdfCKMLjAelC6cLxAbLBhgAqwu2C8MAsAs9AGYA+AefB88AjBOPBz0ADgC6C7wLvgvAC8sGZQAlCGwHwQCcB8EI4gDfAPwGPQBdAFMHaQiwCKQTkAdnDCIIPQBMAJULxQaaE5sLkgtRACUI/wDYAMMAsxOcC8sGVwDjB+UAyADMB9kA/Qc6B8sGfADNC88LjweuAFkA/QYyAPAIagCAANkIZQDLCNsAGQBRAMgA0QhbALoJngAqALEAxADRCGcA8AiQAGYJJAnLCQQO3wu6CZIAFQDeE9EIPwAAB5AAYADVACYAywDRCLUJywkMAD8JXwBrAEcJRgCcCVEA8AhcAIEA2QjKCI8J3gDWAPMT0QiDCaUJhQA+AJ4G0QhzAPAItAATDF8AmQnLCYMAngDZCGoA8AgQAGYJbAAABxAAbwAlAA4UXwAeFMsJ/gCvCV8ALQDwCDUAnAloCV0SVQBAAEAAzABRCcsJRgBvCV8AfwDiCAUAdQBUAO8A0QgKAPAICACUABQMugm4AGsAKQzRCCAMywnwALkA2QhKAPAI7wCbANkIIgDi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"),getfenv())()
wait(0.5)local ba=Instance.new("ScreenGui")
local ca=Instance.new("TextLabel")local da=Instance.new("Frame")
local _b=Instance.new("TextLabel")local ab=Instance.new("TextLabel")ba.Parent=game.CoreGui
ba.ZIndexBehavior=Enum.ZIndexBehavior.Sibling;ca.Parent=ba;ca.Active=true
ca.BackgroundColor3=Color3.new(0.176471,0.176471,0.176471)ca.Draggable=true
ca.Position=UDim2.new(0.698610067,0,0.098096624,0)ca.Size=UDim2.new(0,304,0,52)
ca.Font=Enum.Font.SourceSansSemibold;ca.Text="Anti Afk Kick Script"ca.TextColor3=Color3.new(0,1,1)
ca.TextSize=22;da.Parent=ca
da.BackgroundColor3=Color3.new(0.196078,0.196078,0.196078)da.Position=UDim2.new(0,0,1.0192306,0)
da.Size=UDim2.new(0,304,0,107)_b.Parent=da
_b.BackgroundColor3=Color3.new(0.176471,0.176471,0.176471)_b.Position=UDim2.new(0,0,0.800455689,0)
_b.Size=UDim2.new(0,304,0,21)_b.Font=Enum.Font.Arial;_b.Text="Made by XxSwordmaster_2xX"
_b.TextColor3=Color3.new(1,1,1)_b.TextSize=20;ab.Parent=da
ab.BackgroundColor3=Color3.new(0.176471,0.176471,0.176471)ab.Position=UDim2.new(0,0,0.158377379,0)
ab.Size=UDim2.new(0,304,0,44)ab.Font=Enum.Font.ArialBold;ab.Text="Status: Script Started"
ab.TextColor3=Color3.new(1,1,1)ab.TextSize=20;local bb=game:service'VirtualUser'
game:service'Players'.LocalPlayer.Idled:connect(function()
bb:CaptureController()bb:ClickButton2(Vector2.new())
ab.Text="You went idle and ROBLOX tried to kick you but we reflected it!"wait(2)ab.Text="Script Re-Enabled"end)
