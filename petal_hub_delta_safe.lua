-- Petal Hub ♡ — safe visual preview interface for Delta
-- This script creates a LOCAL UI only. It does not spawn, grant, equip, or trade
-- real Adopt Me pets/items and does not call game remotes or modify inventory.

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer
if not player then return end

-- Remove an older copy if the script is run again.
local function getParent()
    if typeof(gethui) == "function" then
        local ok, result = pcall(gethui)
        if ok and result then return result end
    end
    local ok, result = pcall(function() return game:GetService("CoreGui") end)
    if ok and result then return result end
    return player:WaitForChild("PlayerGui")
end

local parent = getParent()
pcall(function()
    local old = parent:FindFirstChild("PetalHubSafePreview")
    if old then old:Destroy() end
end)

local pets = {
    {name="Frost Dragon", emoji="🐉", rarity="Legendary"},
    {name="Shadow Dragon", emoji="🐲", rarity="Legendary"},
    {name="Strawberry Shortcake Bat Dragon", emoji="🍓", rarity="Legendary"},
    {name="Kitsune", emoji="🦊", rarity="Legendary"},
    {name="Bunny", emoji="🐰", rarity="Common"},
    {name="Axolotl", emoji="🩷", rarity="Legendary"},
    {name="Cat", emoji="🐱", rarity="Common"},
    {name="Red Panda", emoji="🐼", rarity="Ultra-Rare"},
    {name="Unicorn", emoji="🦄", rarity="Legendary"},
    {name="Capybara", emoji="🐹", rarity="Uncommon"},
    {name="Dachshund", emoji="🐶", rarity="Common"},
    {name="Penguin", emoji="🐧", rarity="Ultra-Rare"},
}
local wear = {
    {name="Flower Crown", emoji="🌼", kind="Head accessory idea"},
    {name="Pink Bow", emoji="🎀", kind="Accessory idea"},
    {name="Tiny Sun Hat", emoji="👒", kind="Hat idea"},
    {name="Heart Glasses", emoji="🩷", kind="Accessory idea"},
    {name="Butterfly Wings", emoji="🪽", kind="Back accessory idea"},
    {name="Starry Headphones", emoji="🎧", kind="Accessory idea"},
    {name="Daisy Clip", emoji="🌼", kind="Head accessory idea"},
    {name="Cozy Scarf", emoji="🧣", kind="Neck accessory idea"},
}
local toys = {
    {name="Plush Bunny", emoji="🧸", kind="Plush idea"},
    {name="Bubble Wand", emoji="🫧", kind="Toy idea"},
    {name="Star Rattle", emoji="⭐", kind="Toy idea"},
    {name="Rainbow Ball", emoji="🏐", kind="Toy idea"},
    {name="Tiny Teapot", emoji="🫖", kind="Pretend toy"},
    {name="Flower Frisbee", emoji="🌼", kind="Toy idea"},
    {name="Cloud Balloon", emoji="🎈", kind="Toy idea"},
    {name="Strawberry Plush", emoji="🍓", kind="Plush idea"},
}

local selectedPet = pets[1]
local selectedWear, selectedToy = nil, nil
local variant, flyLook, rideLook = "Normal", false, false
local activeTab = "Pets"
local petQuery, wearQuery, toyQuery = "", "", ""

local C = {
    bg = Color3.fromRGB(255, 247, 251),
    panel = Color3.fromRGB(255, 253, 254),
    pink = Color3.fromRGB(247, 201, 223),
    pinkLight = Color3.fromRGB(255, 232, 242),
    deep = Color3.fromRGB(185, 95, 141),
    ink = Color3.fromRGB(117, 68, 93),
    muted = Color3.fromRGB(167, 123, 145),
    line = Color3.fromRGB(242, 211, 226),
    white = Color3.fromRGB(255, 255, 255),
    lilac = Color3.fromRGB(241, 235, 255),
}

local function make(className, props, parentObj)
    local obj = Instance.new(className)
    for k, v in pairs(props or {}) do
        obj[k] = v
    end
    obj.Parent = parentObj
    return obj
end
local function corner(obj, radius)
    make("UICorner", {CornerRadius=UDim.new(0, radius or 12)}, obj)
end
local function stroke(obj, color, thickness)
    make("UIStroke", {Color=color or C.line, Thickness=thickness or 1, Transparency=0.1}, obj)
end
local function label(parentObj, text, size, color, bold)
    return make("TextLabel", {
        BackgroundTransparency=1, Text=text, TextSize=size or 13,
        TextColor3=color or C.ink, Font=bold and Enum.Font.GothamBold or Enum.Font.Gotham,
        TextWrapped=true, TextXAlignment=Enum.TextXAlignment.Left,
        TextYAlignment=Enum.TextYAlignment.Center, Size=UDim2.new(1,0,0,24),
    }, parentObj)
end
local function button(parentObj, text, size, bg, textColor)
    local b = make("TextButton", {
        Text=text, TextSize=12, Font=Enum.Font.GothamBold,
        TextColor3=textColor or C.ink, BackgroundColor3=bg or C.white,
        AutoButtonColor=true, Size=size or UDim2.new(1,0,0,40),
        TextWrapped=true, BorderSizePixel=0,
    }, parentObj)
    corner(b, 12); stroke(b, C.line, 1)
    return b
end

local gui = make("ScreenGui", {
    Name="PetalHubSafePreview", ResetOnSpawn=false, IgnoreGuiInset=false,
    ZIndexBehavior=Enum.ZIndexBehavior.Sibling, DisplayOrder=999,
}, parent)
pcall(function() gui.ScreenInsets = Enum.ScreenInsets.DeviceSafeInsets end)

local scale = make("UIScale", {Scale=1}, gui)
local function updateScale()
    local camera = workspace.CurrentCamera
    if camera then
        local width = camera.ViewportSize.X
        scale.Scale = math.clamp(width / 420, 0.78, 1)
    end
end
updateScale()
if workspace.CurrentCamera then
    workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(updateScale)
end

local shell = make("Frame", {
    Name="Window", Size=UDim2.new(0, 370, 0, 510),
    Position=UDim2.new(0.5,-185,0.5,-255),
    BackgroundColor3=C.bg, BorderSizePixel=0, Active=true,
}, gui)
corner(shell, 22); stroke(shell, C.line, 1)
make("UISizeConstraint", {MinSize=Vector2.new(290, 390), MaxSize=Vector2.new(390, 560)}, shell)

local top = make("Frame", {
    Size=UDim2.new(1,0,0,82), BackgroundColor3=C.pinkLight, BorderSizePixel=0,
}, shell)
corner(top, 22)
make("UIGradient", {
    Color=ColorSequence.new({
        ColorSequenceKeypoint.new(0, C.pink),
        ColorSequenceKeypoint.new(0.55, C.pinkLight),
        ColorSequenceKeypoint.new(1, C.lilac),
    }),
    Rotation=15,
}, top)
local title = make("TextLabel", {
    BackgroundTransparency=1, Position=UDim2.new(0,16,0,10), Size=UDim2.new(1,-58,0,30),
    Text="PETAL HUB ♡", TextColor3=C.deep, TextSize=22, Font=Enum.Font.GothamBold,
    TextXAlignment=Enum.TextXAlignment.Left,
}, top)
local subtitle = make("TextLabel", {
    BackgroundTransparency=1, Position=UDim2.new(0,17,0,40), Size=UDim2.new(1,-30,0,20),
    Text="safe pet preview studio  •  beta", TextColor3=C.ink, TextSize=11,
    Font=Enum.Font.Gotham, TextXAlignment=Enum.TextXAlignment.Left,
}, top)
local close = button(top, "×", UDim2.new(0,32,0,32), C.white, C.deep)
close.Position = UDim2.new(1,-42,0,12)
close.TextSize = 22
close.MouseButton1Click:Connect(function() gui:Destroy() end)

-- Dragging works with mouse and touch.
do
    local dragging, dragInput, dragStart, startPos = false, nil, nil, nil
    top.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true; dragStart = input.Position; startPos = shell.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    top.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragInput = input end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input == dragInput or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            shell.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

local tabs = make("Frame", {
    Position=UDim2.new(0,10,0,91), Size=UDim2.new(1,-20,0,36),
    BackgroundTransparency=1,
}, shell)
make("UIListLayout", {FillDirection=Enum.FillDirection.Horizontal, Padding=UDim.new(0,5), SortOrder=Enum.SortOrder.LayoutOrder}, tabs)
local tabButtons = {}
for i, name in ipairs({"Pets","Wear","Toys","Settings"}) do
    local b = button(tabs, name, UDim2.new(0.25,-4,1,0), C.white, C.muted)
    b.LayoutOrder=i; tabButtons[name]=b
end

local content = make("ScrollingFrame", {
    Position=UDim2.new(0,10,0,136), Size=UDim2.new(1,-20,1,-146),
    BackgroundColor3=C.panel, BorderSizePixel=0, ScrollBarThickness=4,
    ScrollBarImageColor3=C.pink, CanvasSize=UDim2.new(0,0,0,0),
    AutomaticCanvasSize=Enum.AutomaticSize.Y, ScrollingDirection=Enum.ScrollingDirection.Y,
}, shell)
corner(content, 17); stroke(content, C.line, 1)
local contentLayout = make("UIListLayout", {
    Padding=UDim.new(0,8), SortOrder=Enum.SortOrder.LayoutOrder,
}, content)
make("UIPadding", {
    PaddingTop=UDim.new(0,10), PaddingBottom=UDim.new(0,12),
    PaddingLeft=UDim.new(0,10), PaddingRight=UDim.new(0,10),
}, content)

local status = make("TextLabel", {
    BackgroundTransparency=1, Size=UDim2.new(1,0,0,36),
    Text="Preview only — no real inventory changes.", TextColor3=C.muted,
    TextSize=11, Font=Enum.Font.Gotham, TextWrapped=true,
    TextXAlignment=Enum.TextXAlignment.Left, LayoutOrder=999,
}, content)

local function clearContent()
    for _, child in ipairs(content:GetChildren()) do
        if child ~= contentLayout and child ~= status and child.ClassName ~= "UIPadding" then child:Destroy() end
    end
    status.LayoutOrder = 999
end
local function addHeading(text)
    local h = label(content, text, 15, C.deep, true)
    h.Size = UDim2.new(1,0,0,28)
    return h
end
local function addHint(text)
    local h = label(content, text, 11, C.muted, false)
    h.Size = UDim2.new(1,0,0,34)
    return h
end
local function addSearch(placeholder, initial, callback)
    local box = make("TextBox", {
        Size=UDim2.new(1,0,0,38), BackgroundColor3=C.white, BorderSizePixel=0,
        Text=initial or "", PlaceholderText=placeholder, PlaceholderColor3=C.muted,
        TextColor3=C.ink, TextSize=12, Font=Enum.Font.Gotham,
        ClearTextOnFocus=false, TextXAlignment=Enum.TextXAlignment.Left,
    }, content)
    corner(box, 12); stroke(box, C.line, 1)
    make("UIPadding", {PaddingLeft=UDim.new(0,12), PaddingRight=UDim.new(0,8)}, box)
    box.FocusLost:Connect(function() callback(box.Text) end)
    return box
end
local function addGrid()
    local holder = make("Frame", {
        BackgroundTransparency=1, Size=UDim2.new(1,0,0,10),
        AutomaticSize=Enum.AutomaticSize.Y,
    }, content)
    local grid = make("UIGridLayout", {
        CellSize=UDim2.new(0.5,-5,0,72), CellPadding=UDim2.new(0,8,0,8),
        SortOrder=Enum.SortOrder.LayoutOrder,
    }, holder)
    return holder
end
local function showStatus(text)
    status.Text = text
end

local render
local function addCard(holder, item, selected, callback, detail)
    local b = button(holder, item.emoji.."  "..item.name.."\n"..(detail or ""), UDim2.new(0,0,0,72), selected and C.pinkLight or C.white, C.ink)
    b.Size = UDim2.new(0,0,0,72)
    b.AutomaticSize = Enum.AutomaticSize.None
    b.MouseButton1Click:Connect(callback)
    if selected then stroke(b, C.deep, 2) end
    return b
end

local function addChoices(options, current, onPick)
    local holder = make("Frame", {BackgroundTransparency=1, Size=UDim2.new(1,0,0,40)}, content)
    make("UIListLayout", {FillDirection=Enum.FillDirection.Horizontal, Padding=UDim.new(0,6)}, holder)
    for _, option in ipairs(options) do
        local b = button(holder, option, UDim2.new(1/#options,-3,1,0), option==current and C.pink or C.white, C.ink)
        b.MouseButton1Click:Connect(function() onPick(option); render() end)
    end
end
local function addToggle(text, current, callback)
    local b = button(content, (current and "☑  " or "□  ")..text, UDim2.new(1,0,0,38), current and C.pinkLight or C.white, C.ink)
    b.MouseButton1Click:Connect(function() callback(not current); render() end)
end

local function renderPetsPage()
    addHeading("୨୧ Find your dream pet")
    addHint("Pick a catalogue entry and customise its visual preview.")
    addSearch("Search pet names...", petQuery, function(value) petQuery=value; render() end)
    local holder = addGrid()
    local shown = 0
    for _, pet in ipairs(pets) do
        if pet.name:lower():find(petQuery:lower(), 1, true) then
            shown = shown + 1
            addCard(holder, pet, selectedPet == pet, function()
                selectedPet = pet; showStatus("Selected "..pet.name.." ♡"); render()
            end, pet.rarity)
        end
    end
    if shown == 0 then addHint("No matching pets — try another search.") end
    addHeading("Appearance")
    addChoices({"Normal","Neon","Mega Neon"}, variant, function(value) variant=value end)
    addHeading("Extra preview effects")
    addToggle("Flyable look", flyLook, function(value) flyLook=value end)
    addToggle("Rideable look", rideLook, function(value) rideLook=value end)
    local preview = button(content, "♡ Preview my selection ♡", UDim2.new(1,0,0,44), C.pink, C.ink)
    preview.MouseButton1Click:Connect(function()
        local tags = {variant}
        if flyLook then table.insert(tags, "Flyable look") end
        if rideLook then table.insert(tags, "Rideable look") end
        showStatus("♡ "..selectedPet.emoji.." "..selectedPet.name.."  •  "..table.concat(tags, " / ").."  •  visual preview only. No real pet was created.")
    end)
end

local function renderCatalogPage(which)
    local isWear = which == "Wear"
    local data = isWear and wear or toys
    local query = isWear and wearQuery or toyQuery
    addHeading(isWear and "୨୧ Pet wear closet" or "୨୧ Little toy box")
    addHint(isWear and "Choose an accessory idea for a local preview." or "Choose a toy idea for a local preview.")
    addSearch(isWear and "Search pet wear..." or "Search toys...", query, function(value)
        if isWear then wearQuery=value else toyQuery=value end
        render()
    end)
    local holder = addGrid()
    local chosen = isWear and selectedWear or selectedToy
    local shown = 0
    for _, item in ipairs(data) do
        if item.name:lower():find(query:lower(), 1, true) then
            shown = shown + 1
            addCard(holder, item, chosen == item, function()
                if isWear then selectedWear=item else selectedToy=item end
                showStatus("Selected "..item.name.." — catalogue preview only ♡")
                render()
            end, item.kind)
        end
    end
    if shown == 0 then addHint("No matches found — try another search.") end
    local chosenNow = isWear and selectedWear or selectedToy
    addHeading("Selected item")
    addHint(chosenNow and (chosenNow.emoji.." "..chosenNow.name.." • "..chosenNow.kind) or "Nothing selected yet ♡")
end

local function renderSettings()
    addHeading("୨୧ Little settings nook")
    addHint("Cotton-candy pink, cream and lilac.")
    addHint("This interface is local-only. It does not connect to Adopt Me inventory or trade systems.")
    addHint("Never paste your Roblox password, session cookie, or account token into scripts.")
    local reset = button(content, "Reset preview settings", UDim2.new(1,0,0,42), C.pinkLight, C.deep)
    reset.MouseButton1Click:Connect(function()
        selectedPet=pets[1]; selectedWear=nil; selectedToy=nil
        variant="Normal"; flyLook=false; rideLook=false
        petQuery=""; wearQuery=""; toyQuery=""
        render()
        showStatus("Preview settings reset ♡")
    end)
end

render = function()
    clearContent()
    for name, b in pairs(tabButtons) do
        b.BackgroundColor3 = (name == activeTab) and C.deep or C.white
        b.TextColor3 = (name == activeTab) and C.white or C.muted
    end
    if activeTab == "Pets" then renderPetsPage()
    elseif activeTab == "Wear" then renderCatalogPage("Wear")
    elseif activeTab == "Toys" then renderCatalogPage("Toys")
    else renderSettings() end
    status.LayoutOrder = 999
end
for name, b in pairs(tabButtons) do
    b.MouseButton1Click:Connect(function() activeTab=name; render() end)
end

-- Keep window inside the visible screen when it first appears.
local camera = workspace.CurrentCamera
if camera then
    local viewport = camera.ViewportSize
    if viewport.X < 410 then
        shell.Size = UDim2.new(1,-20,0,500)
        shell.Position = UDim2.new(0,10,0.5,-250)
    end
end
render()
