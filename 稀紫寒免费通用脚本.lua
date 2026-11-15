local LocalPlayer = game.Players.LocalPlayer
local WhitelistUsers = {
    ["稀紫寒"] = true,
    ["tntwaw"] = true,
    ["4hggeryUSSB"] = true,
    ["tggyggggih"] = true,
    [""] = true,
    [""] = true,
    [""] = true,
    [""] = true,
    [""] = true,
    [""] = true,
    [""] = true,
    [""] = true,
    [""] = true
}
-- ========== 控件点击音效（提前定义，白名单等早期 UI 也能用） ==========
ClickSfxBase = nil
ClickSfxEnabled = true
ClickSoundPlay = function()
    if not ClickSfxEnabled then return end
    pcall(function()
        if not ClickSfxBase or not ClickSfxBase.Parent then
            ClickSfxBase = Instance.new("Sound")
            ClickSfxBase.Name = "XzhClickSfxBase"
            ClickSfxBase.SoundId = "rbxassetid://2818606146"
            ClickSfxBase.Volume = 0.7
            ClickSfxBase.Parent = game:GetService("SoundService")
            pcall(function()
                game:GetService("ContentProvider"):PreloadAsync({ClickSfxBase})
            end)
        end
        local s = ClickSfxBase:Clone()
        s.Parent = game:GetService("SoundService")
        s:Play()
        task.delay(4, function()
            pcall(function() s:Destroy() end)
        end)
    end)
end

ClickSfxLast = 0
PressSfx = { input = nil, pos = nil }

PlayClickSfxDedup = function()
    if not ClickSfxEnabled then return end
    local now = os.clock()
    if (now - ClickSfxLast) < 0.1 then return end
    ClickSfxLast = now
    ClickSoundPlay()
end

game:GetService("UserInputService").InputEnded:Connect(function(input)
    if not PressSfx.input then return end
    if input == PressSfx.input then
        local moved = (input.Position - PressSfx.pos).Magnitude
        PressSfx.input = nil
        if moved <= 20 then
            PlayClickSfxDedup()
        end
    end
end)

BindClickSound = function(obj)
    if not obj then return end
    pcall(function()
        -- 明确标记不响音效的控件（相册图片格子等）
        local cur = obj
        -- 原生触控控件（跳跃键/摇杆等）不绑点击音效
        local NativeNames = {
            TouchGui = true, TouchControlFrame = true, JumpButton = true,
            DynamicThumbstick = true, Thumbpad = true, MoveButton = true,
            LeftButton = true, RightButton = true, ThumbstickFrame = true,
        }
        for _ = 1, 6 do
            if cur and cur:GetAttribute("XzhNoClickSfx") then return end
            if cur and NativeNames[cur.Name] then return end
            cur = cur and cur.Parent
        end
        if obj:GetAttribute("XzhClickSfxBound") then return end

        -- 竖框/分隔线：极窄的条状控件不响
        local sizeOk, sz = pcall(function() return obj.AbsoluteSize end)
        if sizeOk and sz then
            if (sz.X > 0 and sz.X <= 12) or (sz.Y > 0 and sz.Y <= 8) then
                obj:SetAttribute("XzhClickSfxBound", true)
                return
            end
        end

        -- 纯装饰文字（横线/竖线符号、或大段说明文字）不响
        local txt = nil
        pcall(function() txt = obj.Text end)
        if type(txt) == "string" and #txt > 0 then
            local onlyLines = txt:gsub("[%s─━═—=_|│┃┆┊●•·-]", "")
            if #onlyLines == 0 then
                obj:SetAttribute("XzhClickSfxBound", true)
                return
            end
            if txt:find("\n", 1, true) then
                obj:SetAttribute("XzhClickSfxBound", true)
                return
            end
        end

        obj:SetAttribute("XzhClickSfxBound", true)
        pcall(function() obj.MouseButton1Click:Connect(PlayClickSfxDedup) end)
        pcall(function() obj.Activated:Connect(PlayClickSfxDedup) end)
        -- 按下记录，松手时同位置抬起才响：兼容点击后立刻销毁/重建的按钮
        pcall(function()
            obj.InputBegan:Connect(function(input)
                local it = input.UserInputType
                if it == Enum.UserInputType.Touch or it == Enum.UserInputType.MouseButton1 then
                    PressSfx.input = input
                    PressSfx.pos = input.Position
                end
            end)
        end)
    end)
end

BindTree = function(root)
    if not root then return end
    pcall(function()
        if root:GetAttribute("XzhTreeBound") then return end
        root:SetAttribute("XzhTreeBound", true)
        local function one(d)
            if d:IsA("GuiButton") then
                BindClickSound(d)
            end
        end
        for _, d in ipairs(root:GetDescendants()) do
            one(d)
        end
        root.DescendantAdded:Connect(function(d)
            pcall(function() one(d) end)
        end)
    end)
end

if not WhitelistUsers[LocalPlayer.Name] then
    LocalPlayer:Kick("❌ 你不在脚本白名单内\n请联系作者购买:2701378793")
    return
end
-- 先把通知用的图标下好，等通知弹出来时图已经在本地，不会再空白一下
do
    task.spawn(function()
        pcall(function()
            local cp = game:GetService("ContentProvider")
            local holder = Instance.new("ScreenGui")
            holder.Name = "NotifyIconPreload"
            holder.ResetOnSpawn = false
            holder.Parent = LocalPlayer:FindFirstChildOfClass("PlayerGui") or LocalPlayer.PlayerGui
            local img = Instance.new("ImageLabel")
            img.Size = UDim2.fromOffset(2, 2)
            img.Visible = false
            img.Image = "rbxthumb://type=Asset&id=134211902405486&w=420&h=420"
            img.Parent = holder
            pcall(function() cp:PreloadAsync({img}) end)
            pcall(function() holder:Destroy() end)
        end)
    end)
end

-- 通知弹窗用的小图标：从这批宠物图里随机取一张
function GetRandomPetIconUrl()
    local petIds = {
        137558016172303,
        87650432616407,
        96822564699232,
        117893234568653,
        81078728909423,
        116299558673425,
        85455640633897,
        139645724124690,
        91907390446047,
        89445476070903,
        121505484334701,
        78698570709423,
        128666287724443,
        90625919144422,
        128201662179118,
        88722416304193,
        93792338772594,
        98784091091200,
        136925138836143,
        126151514190755,
        120695528349888,
        71448890902124,
        112306126074855,
        79205956860435,
        71616202556551,
        84146724541604,
        121070261826501,
        76117979265551,
        102544076444838,
        81707138358779,
        106984341579599,
        114936374297852,
    }
    local pick = petIds[math.random(1, #petIds)]
    return "rbxthumb://type=Asset&id=" .. tostring(pick) .. "&w=420&h=420"
end

-- 失败原因右下角提示
function NotifyReason(text)
    pcall(function()
        local icon = nil
        pcall(function() icon = GetRandomPetIconUrl() end)
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "❌ 执行失败",
            Text = tostring(text),
            Duration = 2.5,
            Icon = icon or "rbxassetid://134211902405486"
        })
    end)
    warn("❌ " .. tostring(text))
end


-- 成功提示
function NotifySuccess(text)
    pcall(function()
        local icon = nil
        pcall(function() icon = GetRandomPetIconUrl() end)
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "✅ 执行成功",
            Text = tostring(text),
            Duration = 2.5,
            Icon = icon or "rbxassetid://134211902405486"
        })
    end)
    print("✅ " .. tostring(text))
end

-- 控件点击提示：成功走对号，失败走红叉（失败原因在正文）
function TipState(title, on)
    if on then
        NotifySuccess(tostring(title) .. " 已开启")
    else
        NotifySuccess(tostring(title) .. " 已关闭")
    end
end

function TipDone(title)
    pcall(function()
        local icon = nil
        pcall(function() icon = GetRandomPetIconUrl() end)
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "✅ 执行成功",
            Text = "已执行：" .. tostring(title),
            Duration = 2,
            Icon = icon or "rbxassetid://134211902405486"
        })
    end)
end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "StartConfirmUI"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = LocalPlayer.PlayerGui
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 400, 0, 200)
frame.Position = UDim2.new(0.5, -200, 0.5, -100)
frame.BackgroundTransparency = 0.22
frame.BackgroundColor3 = Color3.new(0.07,0.07,0.09)
frame.BorderSizePixel = 0
local frameCorner = Instance.new("UICorner")
frameCorner.CornerRadius = UDim.new(0,18)
frameCorner.Parent = frame
local frameStroke = Instance.new("UIStroke")
frameStroke.Thickness = 2.4
frameStroke.Transparency = 0.25
frameStroke.Color = Color3.new(0.22,0.55,0.96)
frameStroke.Parent = frame
local hue = 0
task.spawn(function()
    while frame:IsDescendantOf(game) do
        hue += 0.22/30
        frameStroke.Color = Color3.fromHSV(hue%1,0.65,0.92)
        task.wait(1/30)
    end
end)
local topLabel = Instance.new("TextLabel")
topLabel.Size = UDim2.new(1, -30, 0, 76)
topLabel.Position = UDim2.new(0,15,0,14)
topLabel.BackgroundTransparency = 1
topLabel.Text = "检测拥有白名单"
topLabel.TextColor3 = Color3.new(0.94,0.96,1)
topLabel.Font = Enum.Font.GothamBold
topLabel.TextSize =26
topLabel.TextWrapped = true
topLabel.Parent = frame
local bottomLabel = Instance.new("TextLabel")
bottomLabel.Size = UDim2.new(1,-30,0,40)
bottomLabel.Position = UDim2.new(0,15,0,88)
bottomLabel.BackgroundTransparency =1
bottomLabel.Text = "是否执行"
bottomLabel.TextColor3 = Color3.new(0.72,0.76,0.82)
bottomLabel.Font = Enum.Font.Gotham
bottomLabel.TextSize =21
bottomLabel.Parent = frame
local btnFrame = Instance.new("Frame")
btnFrame.Size = UDim2.new(1,-30,0,48)
btnFrame.Position = UDim2.new(0,15,0,138)
btnFrame.BackgroundTransparency =1
btnFrame.Parent = frame
local startMain = false
local btnRun = Instance.new("TextButton")
btnRun.Size = UDim2.new(0.48,0,1,0)
btnRun.Position = UDim2.new(0,0,0,0)
btnRun.BackgroundTransparency =0
btnRun.BackgroundColor3 = Color3.new(0.18,0.58,0.32)
btnRun.Text = "yes"
btnRun.TextColor3 = Color3.new(1,1,1)
btnRun.Font = Enum.Font.GothamBold
btnRun.TextSize =19
btnRun.AutoLocalize = false
local runCorner = Instance.new("UICorner")
runCorner.CornerRadius = UDim.new(0,12)
runCorner.Parent = btnRun
local btnRunStroke = Instance.new("UIStroke")
btnRunStroke.Thickness =1.8
btnRunStroke.Transparency =0.2
btnRunStroke.Color = Color3.new(0.35,0.85,0.55)
btnRunStroke.Parent = btnRun
btnRun.Parent = btnFrame
BindClickSound(btnRun)
local btnCancel = Instance.new("TextButton")
btnCancel.Size = UDim2.new(0.48,0,1,0)
btnCancel.Position = UDim2.new(0.52,0,0,0)
btnCancel.BackgroundTransparency =0
btnCancel.BackgroundColor3 = Color3.new(0.62,0.2,0.22)
btnCancel.Text = "No"
btnCancel.TextColor3 = Color3.new(1,1,1)
btnCancel.Font = Enum.Font.GothamBold
btnCancel.TextSize =19
btnCancel.AutoLocalize = false
local cancelCorner = Instance.new("UICorner")
cancelCorner.CornerRadius = UDim.new(0,12)
cancelCorner.Parent = btnCancel
local btnCancelStroke = Instance.new("UIStroke")
btnCancelStroke.Thickness =1.8
btnCancelStroke.Transparency =0.2
btnCancelStroke.Color = Color3.new(0.9,0.38,0.4)
btnCancelStroke.Parent = btnCancel
btnCancel.Parent = btnFrame
BindClickSound(btnCancel)
frame.Parent = screenGui
pcall(function() BindTree(screenGui) end)
btnRun.MouseButton1Click:Connect(function()
    local StarterGui = game:GetService("StarterGui")
    pcall(function()
        StarterGui:SetCore("SendNotification",{
            Title = "执行中ing",
            Text = "请稍等",
            Duration = 2.2,
            Icon = GetRandomPetIconUrl()
        })
    end)
    screenGui:Destroy()
    startMain = true
end)
btnCancel.MouseButton1Click:Connect(function()
    screenGui:Destroy()
end)
repeat task.wait() until startMain
-- ==============================================================
local function showErrorTip()
    local pg = LocalPlayer.PlayerGui
    local errGui = Instance.new("ScreenGui")
    errGui.Name = "UIFailAlert"
    errGui.ResetOnSpawn = false
    errGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    errGui.Parent = pg
    local frameErr = Instance.new("Frame")
    frameErr.Size = UDim2.new(0,220,0,90)
    frameErr.Position = UDim2.new(0.98, -220,0.02,0)
    frameErr.BackgroundColor3 = Color3.new(0.15,0.05,0.05)
    frameErr.BorderSizePixel =0
    local crErr = Instance.new("UICorner")
    crErr.CornerRadius = UDim.new(0,8)
    crErr.Parent = frameErr
    local strokeErr = Instance.new("UIStroke")
    strokeErr.Color = Color3.new(0.9,0.2,0.2)
    strokeErr.Thickness =1.5
    strokeErr.Parent = frameErr
    local labelErr = Instance.new("TextLabel")
    labelErr.Size = UDim2.new(0.95,0,0.95,0)
    labelErr.Position = UDim2.new(0.025,0,0.025,0)
    labelErr.BackgroundTransparency =1
    labelErr.Text = "脚本加载失败!"
    labelErr.TextColor3 = Color3.new(1,1,1)
    labelErr.Font = Enum.Font.SourceSans
    labelErr.TextSize =26
    labelErr.TextWrapped = true
    labelErr.Parent = frameErr
    frameErr.Parent = errGui
    task.delay(3,function() errGui:Destroy() end)
end
local rawWindUISource, getSuccess = nil, false
local ok, res = pcall(function()
    return game:HttpGet("https://raw.githubusercontent.com/tnine-n9/tnine-public/27678a61e5fa27df27ae6e8f7448f63deb21be11/wind%20ui%E6%BA%90%E7%A0%81.lua")
end)
if ok then
    rawWindUISource = res
    getSuccess = true
end
if not getSuccess then
    showErrorTip()
    return
end
rawWindUISource = rawWindUISource:gsub("Close the Script window%?","关闭脚本窗口？")
rawWindUISource = rawWindUISource:gsub("Please continue to enjoy the game%.","作者QQ2701378793")
rawWindUISource = rawWindUISource:gsub("Join the QQ group .- to communicate with us%.","加入QQ群704693000交流")
rawWindUISource = rawWindUISource:gsub("Stay Open%.","保持打开")
rawWindUISource = rawWindUISource:gsub([["Close"]],[["关闭"]])
-- 主窗口拖动只认按下去的那根手指（WindUI 原有全局 InputChanged 分支不校验输入对象，双指会乱跑）
rawWindUISource = rawWindUISource:gsub("local C\nlocal F,G,H", "local C\nlocal F,G,H\nlocal K", 1)
rawWindUISource = rawWindUISource:gsub("C=M\nF=true", "C=M\nK=N\nF=true", 1)
rawWindUISource = rawWindUISource:gsub("if F and C==M then", "if F and C==M and K~=nil and N==K then", 1)
rawWindUISource = rawWindUISource:gsub("if F and C~=nil then", "if F and C~=nil and K~=nil and N==K then", 1)
rawWindUISource = rawWindUISource:gsub("F=false\nC=nil", "F=false\nC=nil\nK=nil", 1)
local WindUI, loadOk = nil, false
ok, res = pcall(function()
    return loadstring(rawWindUISource)()
end)
if ok then
    WindUI = res
    loadOk = true
end
if not loadOk or not WindUI then
    showErrorTip()
    return
end
local plr = game.Players.LocalPlayer
local StarterGui = game:GetService("StarterGui")
local function showNotify()
    local ok2
    repeat
        ok2 = pcall(function()
            StarterGui:SetCore("SendNotification",{
                Title = "欢迎使用",
                Text = plr.Name,
                Duration = 3,
                Icon = GetRandomPetIconUrl()
            })
        end)
        task.wait(0.05)
    until ok2
end
task.spawn(showNotify)
local Window = WindUI:CreateWindow({
    Title = "xzh",
    Icon = "cat",
    Author = "xzh",
    Folder = "xzh",
    Size = UDim2.fromOffset(
        math.clamp(math.floor((workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize.X or 800) * 0.64), 320, 600),
        math.clamp(math.floor((workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize.Y or 360) * 0.92), 340, 700)
    ),
    Transparent = true,
    Theme = "Dark",
    SideBarWidth = 100,
    ScrollBarEnabled = true
})
local MainTab = Window:Tab({Title = "主页", Icon = "folder"})
MoveTab = Window:Tab({Title = "功能", Icon = "zap"})
local SecondaryTab = Window:Tab({Title = "传送透视", Icon = "map-pin"})
local AutoTab = Window:Tab({Title = "自动", Icon = "settings-2"})
local OtherTab = Window:Tab({Title = "其他", Icon = "settings"})

OtherTab:Button({
    Title = "重置人物",
    Callback = function()
        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if not hum then
            NotifyReason("角色还没加载，稍等再试")
            return
        end
        local ok = false
        -- 1) 恢复常规速度/跳跃
        pcall(function()
            hum.WalkSpeed = 16
            hum.JumpPower = 50
            hum.JumpHeight = 0
            ok = true
        end)
        -- 2) 回到出生点
        local moved = false
        pcall(function()
            local hrp = char:FindFirstChild("HumanoidRootPart")
            local spawn = workspace:FindFirstChildOfClass("SpawnLocation")
            if hrp and spawn then
                hrp.CFrame = spawn.CFrame + Vector3.new(0, 6, 0)
                hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                moved = true
            end
        end)
        -- 3) 视角恢复正常
        pcall(function()
            LocalPlayer.CameraMode = Enum.CameraMode.Classic
            LocalPlayer.CameraMinZoomDistance = 0.5
            LocalPlayer.CameraMaxZoomDistance = 128
        end)
        if moved then
            print("✅ 人物已重置：速度/跳跃已恢复，已回到出生点")
            pcall(function() TipDone("重置人物") end)
        else
            pcall(function() hum.Health = 0 end)
            print("✅ 人物已重置（已重生）")
            pcall(function() TipDone("重置人物") end)
        end
    end
})

--===== 相册（其他页里的「打开相册」开关，一行 5 张缩略图） =====
;(function()
local albumToggle = nil
local function ForceToggleOff(tg)
    if not tg then return end
    for _, n in ipairs({"Set","SetValue","SetState","Update"}) do
        local m = nil
        pcall(function() m = tg[n] end)
        if type(m) == "function" then
            if pcall(function() m(tg, false) end) then return end
        end
    end
    pcall(function() tg.Value = false end)
end
local ALBUM_IMAGES = {
    { id = "rbxassetid://74946424816754", name = "" },
    { id = "rbxassetid://106392843245408", name = "" },
    { id = "rbxassetid://113918492888036", name = "" },
    { id = "rbxassetid://130903228052970", name = "" },
    { id = "rbxassetid://97501162202844", name = "" },
    { id = "rbxassetid://113142824433803", name = "" },
    { id = "rbxassetid://95609040171663", name = "" },
    { id = "rbxassetid://118298954485998", name = "" },
    { id = "rbxassetid://84370165529207", name = "" },
    { id = "rbxassetid://100868417115439", name = "" },
    { id = "rbxassetid://104916824802958", name = "" },
    { id = "rbxassetid://92453729997835", name = "" },
    { id = "rbxassetid://85863603557347", name = "" },
    { id = "rbxassetid://121164953192128", name = "" },
    { id = "rbxassetid://103292653721677", name = "" },
    { id = "rbxassetid://71091584834805", name = "" },
    { id = "rbxassetid://91542930895004", name = "" },
    { id = "rbxassetid://99724875926052", name = "" },
    { id = "rbxassetid://123419779926323", name = "" },
    { id = "rbxassetid://92349752536926", name = "" },
    { id = "rbxassetid://129499646062131", name = "" },
    { id = "rbxassetid://105905603438586", name = "" },
    { id = "rbxassetid://114489262506857", name = "" },
    { id = "rbxassetid://129268094256452", name = "" },
    { id = "rbxassetid://81444185136233", name = "" },
    { id = "rbxassetid://137558016172303", name = "" },
    { id = "rbxassetid://87650432616407", name = "" },
    { id = "rbxassetid://96822564699232", name = "" },
    { id = "rbxassetid://117893234568653", name = "" },
    { id = "rbxassetid://81078728909423", name = "" },
    { id = "rbxassetid://116299558673425", name = "" },
    { id = "rbxassetid://85455640633897", name = "" },
    { id = "rbxassetid://139645724124690", name = "" },
    { id = "rbxassetid://91907390446047", name = "" },
    { id = "rbxassetid://89445476070903", name = "" },
    { id = "rbxassetid://121505484334701", name = "" },
    { id = "rbxassetid://78698570709423", name = "" },
    { id = "rbxassetid://128666287724443", name = "" },
    { id = "rbxassetid://90625919144422", name = "" },
    { id = "rbxassetid://128201662179118", name = "" },
    { id = "rbxassetid://88722416304193", name = "" },
    { id = "rbxassetid://93792338772594", name = "" },
    { id = "rbxassetid://98784091091200", name = "" },
    { id = "rbxassetid://136925138836143", name = "" },
    { id = "rbxassetid://126151514190755", name = "" },
    { id = "rbxassetid://120695528349888", name = "" },
    { id = "rbxassetid://71448890902124", name = "" },
    { id = "rbxassetid://112306126074855", name = "" },
    { id = "rbxassetid://79205956860435", name = "" },
    { id = "rbxassetid://71616202556551", name = "" },
    { id = "rbxassetid://84146724541604", name = "" },
    { id = "rbxassetid://121070261826501", name = "" },
    { id = "rbxassetid://76117979265551", name = "" },
    { id = "rbxassetid://102544076444838", name = "" },
    { id = "rbxassetid://81707138358779", name = "" },
    { id = "rbxassetid://106984341579599", name = "" },
    { id = "rbxassetid://114936374297852", name = "" },
}

local albumGui = nil
local albumPanel = nil
local albumScroll = nil
local albumConns = {}
local popup = nil

local function ClosePopup()
    if popup then pcall(function() popup:Destroy() end) popup = nil end
end

local function ShowPreview(id, name)
    ClosePopup()
    local holder = Instance.new("ScreenGui")
    holder.Name = "AlbumPreview"
    holder.ResetOnSpawn = false
    holder.IgnoreGuiInset = true
    holder.DisplayOrder = 60
    holder.Parent = LocalPlayer:FindFirstChildOfClass("PlayerGui") or LocalPlayer.PlayerGui
    local box = Instance.new("Frame")
    box.Size = UDim2.new(0.88, 0, 0.7, 0)
    box.AnchorPoint = Vector2.new(0.5, 0.5)
    box.Position = UDim2.new(0.5, 0, 0.5, 0)
    box.BackgroundColor3 = Color3.new(0.06, 0.06, 0.09)
    box.BackgroundTransparency = 0.05
    box.BorderSizePixel = 0
    box.Parent = holder
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 16)
    corner.Parent = box
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(150, 110, 255)
    stroke.Thickness = 2
    stroke.Parent = box
    local img = Instance.new("ImageLabel")
    img.Size = UDim2.new(1, -24, 1, -92)
    img.Position = UDim2.new(0, 12, 0, 56)
    img.BackgroundTransparency = 1
    img.ScaleType = Enum.ScaleType.Fit
    local nid = tostring(id):match("%d+") or tostring(id)
    img.Image = "rbxthumb://type=Asset&id=" .. nid .. "&w=720&h=720"
    img.Parent = box
    task.spawn(function()
        task.wait(1.2)
        local okL = false
        pcall(function() okL = img.IsLoaded end)
        if not okL then
            pcall(function() img.Image = "rbxassetid://" .. nid end)
        end
    end)
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -140, 0, 44)
    title.Position = UDim2.new(0, 12, 0, 6)
    title.BackgroundTransparency = 1
    title.Text = name
    title.TextColor3 = Color3.new(1, 1, 1)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 18
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = box
    local close = Instance.new("TextButton")
    close.Size = UDim2.new(0, 64, 0, 32)
    close.Position = UDim2.new(1, -76, 1, -44)
    close.BackgroundColor3 = Color3.fromRGB(200, 45, 50)
    close.Text = "关闭"
    close.TextColor3 = Color3.new(1, 1, 1)
    close.Font = Enum.Font.GothamBold
    close.TextSize = 15
    close.AutoButtonColor = false
    close.BorderSizePixel = 0
    close.Parent = box
    local cc = Instance.new("UICorner")
    cc.CornerRadius = UDim.new(0, 8)
    cc.Parent = close
    close.MouseButton1Click:Connect(ClosePopup)
    popup = holder
end

local function DestroyAlbum()
    for _, c in ipairs(albumConns) do pcall(function() c:Disconnect() end) end
    albumConns = {}
    ClosePopup()
    if albumGui then pcall(function() albumGui:Destroy() end) end
    albumGui = nil
    albumPanel = nil
    albumScroll = nil
end

local function BuildAlbum()
    if albumGui then return end
    local vp = workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize or Vector2.new(800, 450)
    local W = math.clamp(vp.X * 0.82, 320, 900)
    local H = math.clamp(vp.Y * 0.6, 340, 520)
    local pad = 10
    local gui = Instance.new("ScreenGui")
    gui.Name = "WindAlbumViewer"
    gui.ResetOnSpawn = false
    gui.IgnoreGuiInset = true
    gui.DisplayOrder = 46
    gui.Parent = LocalPlayer:FindFirstChildOfClass("PlayerGui") or LocalPlayer.PlayerGui
    albumGui = gui

    local panel = Instance.new("Frame")
    panel.Size = UDim2.fromOffset(W, H)
    panel.Position = UDim2.new(0.5, -W / 2, 0.5, -H / 2)
    panel.BackgroundColor3 = Color3.fromRGB(16, 16, 22)
    panel.BackgroundTransparency = 0.06
    panel.BorderSizePixel = 0
    panel.ClipsDescendants = true
    panel.Parent = gui
    albumPanel = panel
    local pc = Instance.new("UICorner")
    pc.CornerRadius = UDim.new(0, 16)
    pc.Parent = panel
    local ps = Instance.new("UIStroke")
    ps.Color = Color3.fromRGB(140, 110, 240)
    ps.Thickness = 1.8
    ps.Transparency = 0.25
    ps.Parent = panel

    local header = Instance.new("TextButton")
    header.Size = UDim2.new(1, -12, 0, 40)
    header.Position = UDim2.new(0, 6, 0, 5)
    header.BackgroundColor3 = Color3.fromRGB(28, 26, 40)
    header.BackgroundTransparency = 0.2
    header.Text = "图片相册"
    header.TextColor3 = Color3.fromRGB(235, 230, 255)
    header.Font = Enum.Font.GothamBold
    header.TextSize = 16
    header.TextXAlignment = Enum.TextXAlignment.Left
    header.AutoButtonColor = false
    header.BorderSizePixel = 0
    header.Parent = panel
    local hc = Instance.new("UICorner")
    hc.CornerRadius = UDim.new(0, 10)
    hc.Parent = header
    local hp = Instance.new("UIPadding")
    hp.PaddingLeft = UDim.new(0, 12)
    hp.Parent = header

    local minBtn = Instance.new("TextButton")
    minBtn.Size = UDim2.new(0, 34, 0, 30)
    minBtn.Position = UDim2.new(1, -84, 0, 5)
    minBtn.BackgroundColor3 = Color3.fromRGB(48, 46, 68)
    minBtn.Text = "－"
    minBtn.TextColor3 = Color3.new(1, 1, 1)
    minBtn.Font = Enum.Font.GothamBold
    minBtn.TextSize = 16
    minBtn.AutoButtonColor = false
    minBtn.BorderSizePixel = 0
    minBtn.ZIndex = 5
    minBtn.Parent = panel
    local mbc = Instance.new("UICorner")
    mbc.CornerRadius = UDim.new(0, 8)
    mbc.Parent = minBtn

    local miniBtn = Instance.new("TextButton")
    miniBtn.Size = UDim2.new(0, 96, 0, 44)
    miniBtn.AnchorPoint = Vector2.new(1, 0)
    miniBtn.Position = UDim2.new(1, -16, 0, 60)
    miniBtn.BackgroundColor3 = Color3.fromRGB(28, 26, 40)
    miniBtn.BackgroundTransparency = 0.05
    miniBtn.Text = "展开"
    miniBtn.TextColor3 = Color3.fromRGB(235, 230, 255)
    miniBtn.Font = Enum.Font.GothamBold
    miniBtn.TextSize = 15
    miniBtn.AutoButtonColor = false
    miniBtn.BorderSizePixel = 0
    miniBtn.Visible = false
    miniBtn.ZIndex = 8
    miniBtn.Parent = gui
    local mbc2 = Instance.new("UICorner")
    mbc2.CornerRadius = UDim.new(0, 12)
    mbc2.Parent = miniBtn
    local mbs2 = Instance.new("UIStroke")
    mbs2.Color = Color3.fromRGB(140, 110, 240)
    mbs2.Thickness = 1.6
    mbs2.Transparency = 0.25
    mbs2.Parent = miniBtn

    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 34, 0, 30)
    closeBtn.Position = UDim2.new(1, -44, 0, 5)
    closeBtn.BackgroundColor3 = Color3.fromRGB(200, 45, 50)
    closeBtn.Text = "✕"
    closeBtn.TextColor3 = Color3.new(1, 1, 1)
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.TextSize = 16
    closeBtn.AutoButtonColor = false
    closeBtn.BorderSizePixel = 0
    closeBtn.ZIndex = 5
    closeBtn.Parent = panel
    local cbc = Instance.new("UICorner")
    cbc.CornerRadius = UDim.new(0, 8)
    cbc.Parent = closeBtn

    local scroll = Instance.new("ScrollingFrame")
    scroll.Size = UDim2.new(1, -pad * 2, 1, -(52 + pad))
    scroll.Position = UDim2.new(0, pad, 0, 52)
    scroll.BackgroundTransparency = 1
    scroll.BorderSizePixel = 0
    scroll.ScrollBarThickness = 6
    scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    scroll.ScrollingDirection = Enum.ScrollingDirection.Y
    scroll.Parent = panel
    albumScroll = scroll
    local grid = Instance.new("UIGridLayout")
    grid.CellSize = UDim2.new(0.2, -8, 0, 118)
    grid.CellPadding = UDim2.new(0, 6, 0, 8)
    grid.SortOrder = Enum.SortOrder.LayoutOrder
    grid.Parent = scroll

    for i, item in ipairs(ALBUM_IMAGES) do
        local cell = Instance.new("TextButton")
        cell.BackgroundColor3 = Color3.fromRGB(30, 32, 42)
        cell.BorderSizePixel = 0
        cell.Text = ""
        cell.AutoButtonColor = false
        cell.LayoutOrder = i
        cell:SetAttribute("XzhNoClickSfx", true)
        cell.Parent = scroll
        local cc1 = Instance.new("UICorner")
        cc1.CornerRadius = UDim.new(0, 10)
        cc1.Parent = cell
        local cs = Instance.new("UIStroke")
        cs.Color = Color3.fromRGB(120, 110, 210)
        cs.Thickness = 1.2
        cs.Transparency = 0.45
        cs.Parent = cell
        local hasName = (item.name ~= "")
        local img = Instance.new("ImageLabel")
        if hasName then
            img.Size = UDim2.new(1, -8, 1, -36)
        else
            img.Size = UDim2.new(1, -8, 1, -8)
        end
        img.Position = UDim2.new(0, 4, 0, 4)
        img.BackgroundTransparency = 1
        img.BorderSizePixel = 0
        img.ScaleType = Enum.ScaleType.Crop
        local nid = tostring(item.id):match("%d+") or tostring(item.id)
        img.Image = "rbxthumb://type=Asset&id=" .. nid .. "&w=420&h=420"
        img.Parent = cell
        local cc2 = Instance.new("UICorner")
        cc2.CornerRadius = UDim.new(0, 8)
        cc2.Parent = img
        if not hasName then
            local cc3 = Instance.new("UICorner")
            cc3.CornerRadius = UDim.new(0, 8)
            cc3.Parent = img
            local clickArea = Instance.new("TextButton")
            clickArea.Size = UDim2.new(1, 0, 1, 0)
            clickArea.BackgroundTransparency = 1
            clickArea.Text = ""
            clickArea.ZIndex = 3
            clickArea:SetAttribute("XzhNoClickSfx", true)
            clickArea.Parent = cell
        end
        local nameLbl = Instance.new("TextLabel")
        nameLbl.Size = UDim2.new(1, 0, 0, 26)
        nameLbl.Position = UDim2.new(0, 0, 1, -28)
        nameLbl.BackgroundColor3 = Color3.new(0, 0, 0)
        nameLbl.BackgroundTransparency = 0.35
        nameLbl.BorderSizePixel = 0
        nameLbl.Text = item.name
        nameLbl.TextColor3 = Color3.fromRGB(255, 240, 190)
        nameLbl.Font = Enum.Font.GothamBold
        nameLbl.TextSize = 11
        nameLbl.TextWrapped = true
        nameLbl.TextScaled = true
        nameLbl.AutoLocalize = false
        if hasName then
            nameLbl.Parent = cell
        else
            nameLbl:Destroy()
        end
        -- 不再点击放大，只静态展示
    end
    local rows = math.ceil(#ALBUM_IMAGES / 5)
    scroll.CanvasSize = UDim2.new(0, 0, 0, rows * 126 + 8)

    closeBtn.MouseButton1Click:Connect(function()
        DestroyAlbum()
        pcall(ForceToggleOff, albumToggle)
        print("🛑 相册面板已关闭")
    end)
    minBtn.MouseButton1Click:Connect(function()
        panel.Visible = false
        miniBtn.Visible = true
        ClosePopup()
    end)
    miniBtn.MouseButton1Click:Connect(function()
        panel.Visible = true
        miniBtn.Visible = false
    end)

    -- 标题栏长按拖动
    local dragging, dragStart, startPos, dragTouch = false, nil, nil, nil
    table.insert(albumConns, header.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragTouch = input
            dragStart = input.Position
            startPos = panel.Position
        end
    end))
    table.insert(albumConns, game:GetService("UserInputService").InputChanged:Connect(function(input)
        if not dragging then return end
        if dragTouch and input ~= dragTouch and input.UserInputType ~= Enum.UserInputType.MouseMovement then return end
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement then
            local d = input.Position - dragStart
            panel.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
        end
    end))
    table.insert(albumConns, game:GetService("UserInputService").InputEnded:Connect(function(input)
        if not dragging then return end
        if dragTouch and input ~= dragTouch and input.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
        dragging = false
        dragTouch = nil
    end))
    print("✅ 相册面板已打开，共 " .. #ALBUM_IMAGES .. " 张图")
end

albumToggle = OtherTab:Toggle({
    Title = "打开相册",
    Default = false,
    Callback = function(state)
        if state then
            BuildAlbum()
        else
            DestroyAlbum()
            print("🛑 相册面板已关闭")
        end
        pcall(function() TipState("打开相册", state) end)
    end
})
end)()

--===== 自瞄吸附（其他页：打开相册下方） =====
AimbotOn = false
AimTarget = nil
AimFrame = nil
AimGui = nil

AimBuild = function()
    if AimGui and AimGui.Parent then return end
    pcall(function()
        AimGui = Instance.new("ScreenGui")
        AimGui.Name = "XzhAimbotCircle"
        AimGui.ResetOnSpawn = false
        AimGui.IgnoreGuiInset = true
        AimGui.DisplayOrder = 60
        AimGui.Parent = LocalPlayer:FindFirstChildOfClass("PlayerGui") or LocalPlayer.PlayerGui
        local circle = Instance.new("Frame")
        circle.Name = "Circle"
        circle.Size = UDim2.fromOffset(10, 10)
        circle.AnchorPoint = Vector2.new(0.5, 0.5)
        circle.BackgroundTransparency = 1
        circle.Position = UDim2.new(0.5, 0, 0.5, 0)
        circle.Parent = AimGui
        local ring = Instance.new("Frame")
        ring.Size = UDim2.new(1, 0, 1, 0)
        ring.BackgroundTransparency = 1
        ring.Parent = circle
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(1, 0)
        corner.Parent = ring
        local stroke = Instance.new("UIStroke")
        stroke.Name = "RingStroke"
        stroke.Color = Color3.fromRGB(0, 255, 190)
        stroke.Thickness = 2
        stroke.Transparency = 0.1
        stroke.Parent = ring
        AimFrame = circle
    end)
end

AimLocked = nil
AimLockTime = 0

AimRefresh = function()
    if not AimbotOn or not AimFrame then return end
    pcall(function()
        local cam = workspace.CurrentCamera
        if not cam then return end
        local vp = cam.ViewportSize
        local cx, cy = vp.X / 2, vp.Y / 2

        -- 圆圈永远固定在屏幕正中，靠视角转过去，不单独移动圆圈
        AimFrame.Position = UDim2.fromOffset(cx, cy)

        local function headScreen(pl)
            local ch = pl.Character
            local hum = ch and ch:FindFirstChildOfClass("Humanoid")
            local head = ch and ch:FindFirstChild("Head")
            if not ch or not hum or hum.Health <= 0 or not head then return nil end
            local sp, onScreen = cam:WorldToViewportPoint(head.Position)
            if not onScreen then return nil end
            if sp.X < 0 or sp.Y < 0 or sp.X > vp.X or sp.Y > vp.Y then return nil end
            local rp = RaycastParams.new()
            rp.FilterType = Enum.RaycastFilterType.Exclude
            rp.IgnoreWater = true
            local excl = {ch}
            local myChar = LocalPlayer.Character
            if myChar then table.insert(excl, myChar) end
            rp.FilterDescendantsInstances = excl
            if workspace:Raycast(cam.CFrame.Position, head.Position - cam.CFrame.Position, rp) then
                return nil
            end
            return Vector2.new(sp.X, sp.Y)
        end

        -- 已锁定：目标滑出范围 / 出屏 / 被挡 / 阵亡 就立刻放手
        if AimLocked then
            local pos2 = headScreen(AimLocked)
            if pos2 then
                local d2 = (pos2 - Vector2.new(cx, cy)).Magnitude
                if d2 <= 170 then
                    local ring = AimFrame:FindFirstChild("Frame")
                    ring = ring and ring:FindFirstChild("RingStroke")
                    if ring then
                        ring.Color = Color3.fromRGB(255, 60, 60)
                        ring.Thickness = 2
                    end
                    return
                end
            end
            AimLocked = nil
        end

        -- 未锁定：只有滑到中心 100 像素内才吸附
        local near = 100
        local bestPlr, bestDist = nil, near
        for _, pl in ipairs(game.Players:GetPlayers()) do
            if pl ~= LocalPlayer then
                local pos = headScreen(pl)
                if pos then
                    local d = (pos - Vector2.new(cx, cy)).Magnitude
                    if d < bestDist then
                        bestDist = d
                        bestPlr = pl
                    end
                end
            end
        end

        if bestPlr then
            AimLocked = bestPlr
        end

        local ring = AimFrame:FindFirstChild("Frame")
        ring = ring and ring:FindFirstChild("RingStroke")
        if ring then
            ring.Color = bestPlr and Color3.fromRGB(255, 60, 60) or Color3.fromRGB(0, 255, 190)
            ring.Thickness = 2
        end
    end)
end

AimStop = function()
    AimbotOn = false
    AimTarget = nil
    AimLocked = nil
    if AimGui then pcall(function() AimGui.Enabled = false end) end
end

task.spawn(function()
    while true do
        task.wait(0.03)
        if AimbotOn then AimRefresh() end
    end
end)

-- 吸附后带动玩家视角转向被吸附玩家的头部
pcall(function()
    game:GetService("RunService"):BindToRenderStep("XzhAimCam", Enum.RenderPriority.Camera.Value + 1, function(dt)
        if not AimbotOn or not AimLocked then return end
        pcall(function()
            local cam = workspace.CurrentCamera
            if not cam then return end
            local ch = AimLocked.Character
            local head = ch and ch:FindFirstChild("Head")
            if not head then return end
            local target = CFrame.lookAt(cam.CFrame.Position, head.Position)
            cam.CFrame = target
        end)
    end)
end)

OtherTab:Toggle({
    Title = "自瞄吸附",
    Default = false,
    Callback = function(state)
        AimbotOn = state
        if state then
            pcall(AimBuild)
            if AimGui then pcall(function() AimGui.Enabled = true end) end
            print("✅ 自瞄吸附已开启：准心靠近其他玩家会自动吸附到其头部")
        else
            pcall(AimStop)
            print("🛑 自瞄吸附已关闭")
        end
        pcall(function() TipState("自瞄吸附", state) end)
    end
})

OtherTab:Button({
    Title = "打开 XT 翻译",
    Callback = function()
        local code = nil
        pcall(function()
            code = game:HttpGet("https://aka.doubaocdn.com/s/uLo0rQfVi2")
        end)
        if type(code) ~= "string" or #code < 100 then
            NotifyReason("XT 翻译加载失败：下载失败")
            return
        end
        local fn = nil
        pcall(function()
            fn = loadstring(code)
        end)
        if not fn then
            NotifyReason("XT 翻译加载失败：代码编译失败")
            return
        end
        NotifySuccess("XT 翻译已打开")
        task.spawn(fn)
    end
})

--===== 帧率与卡退风险检测 =====
PerfOn = false
PerfGui = nil
PerfFpsLabel = nil
PerfRiskLabel = nil
PerfMemLabel = nil

pcall(function()
    local gui = Instance.new("ScreenGui")
    gui.Name = "XzhPerfPanel"
    gui.DisplayOrder = 40
    gui.IgnoreGuiInset = true
    gui.ResetOnSpawn = false
    gui.Enabled = false

    local bg = Instance.new("Frame")
    bg.Size = UDim2.new(0, 170, 0, 94)
    bg.Position = UDim2.new(1, -16, 0, 46)
    bg.AnchorPoint = Vector2.new(1, 0)
    bg.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    bg.BackgroundTransparency = 0.45
    bg.BorderSizePixel = 0
    bg.Active = true
    bg.Draggable = true
    bg.Parent = gui
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = bg

    local function mkLabel(y, size)
        local l = Instance.new("TextLabel")
        l.Size = UDim2.new(1, -8, 0, size)
        l.Position = UDim2.new(0, 4, 0, y)
        l.BackgroundTransparency = 1
        l.TextXAlignment = Enum.TextXAlignment.Left
        l.Font = Enum.Font.GothamBold
        l.TextStrokeTransparency = 0.6
        l.Parent = bg
        return l
    end

    local fpsL = mkLabel(6, 22)
    fpsL.TextSize = 16
    fpsL.TextColor3 = Color3.fromRGB(0, 255, 190)
    fpsL.Text = "FPS -"

    local riskL = mkLabel(28, 20)
    riskL.TextSize = 14
    riskL.TextColor3 = Color3.fromRGB(255, 200, 60)
    riskL.Text = "卡退风险 -"

    local memL = mkLabel(48, 18)
    memL.TextSize = 12
    memL.TextColor3 = Color3.fromRGB(200, 200, 200)
    memL.Text = "内存 -"

    local pingL = mkLabel(68, 20)
    pingL.TextSize = 12
    pingL.TextColor3 = Color3.fromRGB(160, 220, 255)
    pingL.Text = "Ping -"

    local ok = pcall(function()
        gui.Parent = LocalPlayer:FindFirstChild("PlayerGui")
    end)
    if not ok then
        pcall(function() gui.Parent = game:GetService("CoreGui") end)
    end

    PerfGui = gui
    PerfFpsLabel = fpsL
    PerfRiskLabel = riskL
    PerfMemLabel = memL
    PerfPingLabel = pingL
end)

PerfFrames = 0
PerfStart = os.clock()
PerfLastFrame = os.clock()
PerfMaxGap = 0
PerfLowTime = 0
PerfFps = 60

task.spawn(function()
    while true do
        local dt = task.wait()
        if PerfOn then
            PerfFrames = PerfFrames + 1
            local now = os.clock()
            local gap = now - PerfLastFrame
            PerfLastFrame = now
            if gap > PerfMaxGap then PerfMaxGap = gap end
            if now - PerfStart >= 1 then
                PerfFps = math.floor(PerfFrames / (now - PerfStart))
                PerfFrames = 0
                PerfStart = now
                if PerfFps < 20 then
                    PerfLowTime = PerfLowTime + 1
                else
                    PerfLowTime = 0
                end
                PerfMaxGap = 0
                if PerfGui and PerfGui.Enabled then
                    pcall(function()
                        PerfFpsLabel.Text = "FPS " .. PerfFps
                        local risk = 0
                        if PerfFps < 10 then risk = risk + 60
                        elseif PerfFps < 20 then risk = risk + 40
                        elseif PerfFps < 30 then risk = risk + 20
                        elseif PerfFps < 45 then risk = risk + 8 end
                        if PerfLowTime >= 5 then risk = risk + 20 end
                        local mem = nil
                        pcall(function()
                            mem = game:GetService("Stats"):GetTotalMemoryUsageMb()
                        end)
                        if mem then
                            if mem > 1200 then risk = risk + 30
                            elseif mem > 800 then risk = risk + 18
                            elseif mem > 600 then risk = risk + 8 end
                            PerfMemLabel.Text = "内存 " .. math.floor(mem) .. " MB"
                        else
                            PerfMemLabel.Text = "内存 -"
                        end
                        -- 网络延迟与波动
                        local pingVal = nil
                        pcall(function()
                            pingVal = game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue()
                        end)
                        if pingVal then
                            PerfPingHist = PerfPingHist or {}
                            table.insert(PerfPingHist, pingVal)
                            if #PerfPingHist > 10 then table.remove(PerfPingHist, 1) end
                            local mn, mx = pingVal, pingVal
                            for _, v in ipairs(PerfPingHist) do
                                if v < mn then mn = v end
                                if v > mx then mx = v end
                            end
                            local jitter = mx - mn
                            PerfPingLabel.Text = "Ping " .. math.floor(pingVal) .. "ms 波动 " .. math.floor(jitter) .. "ms"
                            if jitter >= 80 or pingVal >= 200 then
                                PerfPingLabel.TextColor3 = Color3.fromRGB(255, 70, 70)
                                risk = risk + 12
                            elseif jitter >= 40 or pingVal >= 120 then
                                PerfPingLabel.TextColor3 = Color3.fromRGB(255, 200, 60)
                                risk = risk + 6
                            else
                                PerfPingLabel.TextColor3 = Color3.fromRGB(160, 220, 255)
                            end
                        else
                            pcall(function() PerfPingLabel.Text = "Ping -" end)
                        end

                        if risk > 95 then risk = 95 end
                        PerfRiskLabel.Text = "卡退风险 " .. risk .. "%"
                        if risk >= 60 then
                            PerfRiskLabel.TextColor3 = Color3.fromRGB(255, 70, 70)
                        elseif risk >= 30 then
                            PerfRiskLabel.TextColor3 = Color3.fromRGB(255, 200, 60)
                        else
                            PerfRiskLabel.TextColor3 = Color3.fromRGB(120, 255, 120)
                        end
                    end)
                end
            end
        else
            PerfFrames = 0
            PerfStart = os.clock()
            PerfLastFrame = os.clock()
        end
    end
end)

OtherTab:Toggle({
    Title = "显示帧率与卡退风险",
    Default = false,
    Callback = function(state)
        PerfOn = state
        if PerfGui then
            pcall(function() PerfGui.Enabled = state end)
        end
        if state then
            print("✅ 帧率检测已开启：左上角显示 FPS 与卡退风险")
        else
            print("🛑 帧率检测已关闭")
        end
        pcall(function() TipState("显示帧率与卡退风险", state) end)
    end
})


-- 打开就停在主页，不要停在空白页
pcall(function() Window:SelectTab(1) end)
pcall(function() MainTab:Select() end)
local welcomePara = MainTab:Paragraph({
    Title = "欢迎使用",
    Desc = "By稀紫寒",
    Image = "rbxassetid://134211902405486"
})
-- 复制到剪贴板（多种注入器 API 兜底）
CopyClip = function(txt)
    local tries = {}
    pcall(function() if setclipboard then table.insert(tries, function() return setclipboard(txt) end) end end)
    pcall(function() if toclipboard then table.insert(tries, function() return toclipboard(txt) end) end end)
    pcall(function() if syn and syn.setclipboard then table.insert(tries, function() return syn.setclipboard(txt) end) end end)
    pcall(function() if _G.setclipboard then table.insert(tries, function() return _G.setclipboard(txt) end) end end)
    pcall(function() if Clipboard and Clipboard.set then table.insert(tries, function() return Clipboard.set(txt) end) end end)
    for _, f in ipairs(tries) do
        local ok, res = pcall(f)
        if ok and res ~= false then return true end
    end
    return false
end

MainTab:Button({
    Title = "获取作者QQ",
    Callback = function()
        if CopyClip("Q:2701378793") then
            print("✅ 已复制作者QQ：2701378793")
            pcall(function() TipDone("已复制作者QQ") end)
        else
            NotifyReason("复制失败，请手动记：Q:2701378793")
        end
    end
})

MainTab:Button({
    Title = "获取交流群QQ",
    Callback = function()
        if CopyClip("Q群:704693000") then
            print("✅ 已复制交流群QQ：704693000")
            pcall(function() TipDone("已复制交流群QQ") end)
        else
            NotifyReason("复制失败，请手动记：Q群:704693000")
        end
    end
})

MainTab:Toggle({
    Title = "关闭脚本点击音效",
    Desc = "打开后所有按钮不再响点击音",
    Default = false,
    Callback = function(state)
        ClickSfxEnabled = not state
        if state then
            print("🔇 点击音效已关闭")
        else
            print("🔊 点击音效已开启")
        end
        pcall(function() TipState("关闭脚本点击音效", state) end)
    end
})

local logParagraph = nil
local logBuffer = {}
local oldPrint = print
local oldWarn = warn
local function pushLog(txt)
    table.insert(logBuffer, `[{os.date("%H:%M:%S")}] {txt}`)
end
print = function(...)
    local s = table.concat({...}, "\t")
    pushLog("INFO: " .. s)
    oldPrint(...)
end
warn = function(...)
    local s = table.concat({...}, "\t")
    pushLog("WARN: " .. s)
    oldWarn(...)
end


--================ 传送Tab：玩家列表 =================
local selectedPlayerObj = nil
local selectedBtn = nil
local listOpen = false
local listBtn
local listFrame
local listScroll
local listLayout

local function GetFriendIds()
    local t = {}
    local pages = nil
    -- 注意：GetFriendsAsync 只返回一个 FriendPages，不是 (ok, pages)，
    -- 之前按两返回值取会拿到 nil，导致好友永远识别不出来
    local ok1, p1 = pcall(function()
        return LocalPlayer:GetFriendsAsync(LocalPlayer.UserId)
    end)
    if ok1 and p1 then pages = p1 end
    if not pages then
        local ok2, p2 = pcall(function()
            return game:GetService("Players"):GetFriendsAsync(LocalPlayer.UserId)
        end)
        if ok2 and p2 then pages = p2 end
    end
    if not pages then
        return t
    end
    pcall(function()
        repeat
            for _, info in ipairs(pages:GetCurrentPage()) do
                t[info.Id] = true
            end
            if pages.IsFinished then break end
        until not pages:AdvanceToNextPageAsync()
    end)
    return t
end

local function ClearList()
    for _,child in ipairs(listScroll:GetChildren()) do
        if child:IsA("TextButton") then
            child:Destroy()
        end
    end
end

local rowsByUid = {}
local friendSetCache, friendSetAt = nil, -999

-- 好友列表异步拉取：绝不在刷新线程里等待网络，否则整张列表会被卡住不动
local function GetFriendSetCached()
    local now = os.clock()
    if friendSetCache and (now - friendSetAt <= 30) then
        return friendSetCache
    end
    if friendSetAt == -1 then
        return friendSetCache or {}
    end
    friendSetAt = -1
    task.spawn(function()
        local ok, set = pcall(GetFriendIds)
        friendSetCache = (ok and set) or friendSetCache or {}
        friendSetAt = os.clock()
    end)
    return friendSetCache or {}
end

-- 实时名称：优先角色 Humanoid.DisplayName（游戏内改名会变），其次 DisplayName、Name
local function GetNameOf(plr)
    local char = plr.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local dn = hum and hum.DisplayName
    if dn and dn ~= "" and dn ~= plr.Name then
        return dn
    end
    local d2 = plr.DisplayName
    if d2 and d2 ~= "" then
        return d2
    end
    return plr.Name
end

local function CreateRow(plr, friendSet, order)
    local isFr = friendSet[plr.UserId] and true or false
    local dispName = GetNameOf(plr) .. "  (" .. plr.Name .. ")"
    local disp = isFr and ("★ 好友 · "..dispName) or dispName
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1,0,0,34)
    btn.BackgroundColor3 = isFr and Color3.fromRGB(0.14,0.15,0.24) or Color3.new(0.16,0.16,0.18)
    btn.Text = disp
    btn.TextColor3 = isFr and Color3.fromRGB(255,214,92) or Color3.new(1,1,1)
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 15
    btn.AutoButtonColor = false
    btn.LayoutOrder = order
    btn:SetAttribute("xzhUid", plr.UserId)
    btn.Parent = listScroll
    if selectedPlayerObj == plr then
        btn.BackgroundColor3 = Color3.new(0.18,0.58,0.32)
        selectedBtn = btn
    end
    btn.InputBegan:Connect(function(input)
        if input.UserInputType ~= Enum.UserInputType.Touch and input.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
        if selectedBtn and selectedBtn.Parent then
            pcall(function() selectedBtn.BackgroundColor3 = Color3.new(0.16,0.16,0.18) end)
        end
        selectedPlayerObj = plr
        selectedBtn = btn
        btn.BackgroundColor3 = Color3.new(0.18,0.58,0.32)
        listBtn.Text = "已选中："..GetNameOf(plr)
        print("✅ 已选中玩家："..GetNameOf(plr))
    end)
    rowsByUid[plr.UserId] = { plr = plr, btn = btn }
    return btn
end

-- 每 0.2 秒对账：谁不在了就删行，谁新来了就加行，其他行原样不动
local function RefreshList(force)
    if not (listScroll and listScroll:IsDescendantOf(game)) then return end
    local friendSet = GetFriendSetCached()
    if force then
        for uid, row in pairs(rowsByUid) do
            pcall(function() row.btn:Destroy() end)
            rowsByUid[uid] = nil
        end
        selectedBtn = nil
        for _, child in ipairs(listScroll:GetChildren()) do
            if child:IsA("TextButton") then child:Destroy() end
        end
    end
    -- 先拿服务器上真实存在的玩家（唯一权威名单）
    local players = {}
    for _, p in ipairs(game.Players:GetPlayers()) do
        if p ~= LocalPlayer then table.insert(players, p) end
    end
    table.sort(players, function(a,b)
        local fa = friendSet[a.UserId] and 1 or 0
        local fb = friendSet[b.UserId] and 1 or 0
        if fa ~= fb then return fa > fb end
        return a.Name:lower() < b.Name:lower()
    end)
    local aliveByUid = {}
    for _, p in ipairs(players) do aliveByUid[p.UserId] = p end

    -- 1) 服务器上已经没有的人：立刻删行（含已脱离 Players 的对象、已销毁的对象）
    for uid, row in pairs(rowsByUid) do
        local stillThere = aliveByUid[uid] ~= nil and row.plr and row.plr:IsDescendantOf(game) and row.plr.Parent == game.Players
        if not stillThere then
            if selectedBtn == row.btn then
                selectedBtn = nil
                if selectedPlayerObj and selectedPlayerObj.UserId == uid then
                    selectedPlayerObj = nil
                end
            end
            pcall(function() row.btn:Destroy() end)
            rowsByUid[uid] = nil
        end
    end

    -- 2) 新来的加入 + 名字实时更新 + 排序
    for i, plr in ipairs(players) do
        local row = rowsByUid[plr.UserId]
        if (not row) or (not row.btn) or (not row.btn.Parent) then
            if row and row.btn then pcall(function() row.btn:Destroy() end) end
            rowsByUid[plr.UserId] = nil
            CreateRow(plr, friendSet, i)
        else
            if row.btn.LayoutOrder ~= i then row.btn.LayoutOrder = i end
            local isFr = friendSet[plr.UserId] and true or false
            local wantName = GetNameOf(plr) .. "  (" .. plr.Name .. ")"
            local want = isFr and ("★ 好友 · "..wantName) or wantName
            if row.btn.Text ~= want then
                row.btn.Text = want
            end
            local wantColor = isFr and Color3.fromRGB(255,214,92) or Color3.new(1,1,1)
            if row.btn.TextColor3 ~= wantColor then
                row.btn.TextColor3 = wantColor
            end
        end
    end

    -- 3) 孤儿行清理：凡是没对应到当前玩家的行，一律销毁
    for _, child in ipairs(listScroll:GetChildren()) do
        if child:IsA("TextButton") and child.Name ~= "NoPlayerHint" then
            local uid = child:GetAttribute("xzhUid")
            if (not uid) or (not aliveByUid[uid]) then
                pcall(function() child:Destroy() end)
            end
        end
    end

    -- 4) 空提示
    local hint = listScroll:FindFirstChild("NoPlayerHint")
    if #players == 0 then
        if not hint then
            local n = Instance.new("TextButton")
            n.Name = "NoPlayerHint"
            n.Size = UDim2.new(1,0,0,34)
            n.BackgroundTransparency = 0.9
            n.Text = "【无其他玩家】"
            n.TextColor3 = Color3.new(1,1,1)
            n.Font = Enum.Font.Gotham
            n.TextSize = 15
            n.LayoutOrder = 999
            n.Parent = listScroll
        end
    elseif hint then
        pcall(function() hint:Destroy() end)
    end

    -- 5) 选中状态与标题
    if selectedPlayerObj and selectedPlayerObj.Parent == game.Players then
        pcall(function() listBtn.Text = "已选中："..GetNameOf(selectedPlayerObj) end)
    else
        selectedPlayerObj = nil
        pcall(function() listBtn.Text = "选择玩家 ▼ ("..#players..")" end)
    end
end

-- 记录每个玩家最后一次可见的坐标：即使模型被 Streaming 卸载，也还能送过去
local lastPosByUid = {}
task.spawn(function()
    while task.wait(0.3) do
        pcall(function()
            for _, p in ipairs(game.Players:GetPlayers()) do
                if p ~= LocalPlayer then
                    local char = p.Character
                    local hrp = char and char:FindFirstChild("HumanoidRootPart")
                    if hrp then
                        lastPosByUid[p.UserId] = hrp.CFrame
                    end
                end
            end
        end)
    end
end)

listBtn = SecondaryTab:Button({Title = "选择玩家 ▼", Callback=function()
    listOpen = not listOpen
    listFrame.Visible = listOpen
    if listOpen then
        listFrame.Size = UDim2.new(1,0,1,0)
        listFrame.Position = UDim2.new(0,0,0,0)
        pcall(RefreshList)
        print("✅ 玩家列表已展开")
    else
        print("✅ 玩家列表已收起")
    end
end})

local windUiRoot = Window.UIElements.Main
listFrame = Instance.new("Frame")
listFrame.Size = UDim2.new(0,300,0,230)
listFrame.Position = UDim2.new(0,0,0,44)
listFrame.BackgroundColor3 = Color3.new(0.12,0.12,0.14)
listFrame.BorderSizePixel=0
listFrame.Visible=false
listFrame.ZIndex=99
listFrame.Parent = windUiRoot


local listCorner = Instance.new("UICorner")
listCorner.CornerRadius=UDim.new(0,6)
listCorner.Parent=listFrame

local playerCloseBtn = Instance.new("TextButton")
playerCloseBtn.Size = UDim2.new(0,30,0,30)
playerCloseBtn.Position = UDim2.new(1,-36,0,4)
playerCloseBtn.AnchorPoint = Vector2.new(0,0)
playerCloseBtn.BackgroundColor3 = Color3.fromRGB(0.78,0.16,0.20)
playerCloseBtn.Text = "✕"
playerCloseBtn.TextColor3 = Color3.new(1,1,1)
playerCloseBtn.Font = Enum.Font.GothamBold
playerCloseBtn.TextSize = 16
playerCloseBtn.AutoButtonColor = false
playerCloseBtn.ZIndex =400
playerCloseBtn.Parent = listFrame
local pcBtnCorner = Instance.new("UICorner")
pcBtnCorner.CornerRadius = UDim.new(0,8)
pcBtnCorner.Parent = playerCloseBtn
local pcBtnStroke = Instance.new("UIStroke")
pcBtnStroke.Color = Color3.fromRGB(255,90,90)
pcBtnStroke.Thickness = 1.5
pcBtnStroke.Parent = playerCloseBtn
playerCloseBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        playerCloseBtn.BackgroundColor3 = Color3.fromRGB(1,0.35,0.35)
        listOpen = false
        listFrame.Visible = false
        print("✅ 玩家列表已关闭")
        task.delay(0.15, function()
            pcall(function() playerCloseBtn.BackgroundColor3 = Color3.fromRGB(0.78,0.16,0.20) end)
        end)
    end
end)
playerCloseBtn.MouseButton1Click:Connect(function()
    listOpen = false
    listFrame.Visible = false
end)

listScroll = Instance.new("ScrollingFrame")
listScroll.Size=UDim2.new(1,-4,1,-4)
listScroll.Position=UDim2.new(0,2,0,2)
listScroll.BackgroundTransparency=1
listScroll.ScrollBarThickness=6
listScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
listScroll.CanvasSize=UDim2.new(0,0,0,0)
listScroll.Parent=listFrame

listLayout = Instance.new("UIListLayout")
listLayout.Padding = UDim.new(0,2)
listLayout.SortOrder=Enum.SortOrder.LayoutOrder
listLayout.Parent=listScroll

task.spawn(function()
    while task.wait(0.15) do
        local ok, err = pcall(RefreshList)
        if not ok and not _listErrShown then
            _listErrShown = true
            warn("❌ 玩家列表刷新出错：" .. tostring(err))
        end
    end
end)

SecondaryTab:Button({
    Title = "传送至选中玩家",
    Callback = function()
        pcall(function()
            if not selectedPlayerObj then
                NotifyReason("还没有选择玩家，请先点上方【选择玩家 ▼】")
                return
            end
            if not selectedPlayerObj:IsDescendantOf(game) then
                NotifyReason("选中的玩家已经离开服务器")
                selectedPlayerObj=nil
                listBtn.Text="选择玩家 ▼"
                return
            end
            local uid = selectedPlayerObj.UserId
            local tarChar = selectedPlayerObj.Character
            local tarHrp = tarChar and tarChar:FindFirstChild("HumanoidRootPart")
            local goal = nil
            if tarHrp then
                goal = tarHrp.CFrame * CFrame.new(0, 3, 0)
            elseif lastPosByUid[uid] then
                -- 模型没复制到本地：请求把那一带的地图/角色流式加载过来，并用最后已知坐标兜底
                pcall(function() workspace:RequestStreamAroundAsync(lastPosByUid[uid].Position) end)
                goal = lastPosByUid[uid] * CFrame.new(0, 3, 0)
                NotifyReason("目标模型没加载，先用最后记录的位置传送")
            else
                NotifyReason("从没拿到这个玩家的坐标，无法传送；先靠近他或等他动一下")
                return
            end
            local myChar = LocalPlayer.Character
            if not myChar then NotifyReason("你的角色还没加载，稍等再试") return end
            local myHrp = myChar:FindFirstChild("HumanoidRootPart")
            if not myHrp then NotifyReason("找不到你的角色根部件，无法传送") return end
            -- 落点抬高 3 格：避免直接落在地面碰撞体里被卡住 / 被服务器判定异常
            pcall(function() myChar:PivotTo(goal) end)
            pcall(function()
                myHrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                myHrp.CFrame = goal
            end)
            -- 补两次：抵消服务器位置校验把角色拉回
            task.delay(0.1, function() pcall(function() myHrp.CFrame = goal end) end)
            task.delay(0.3, function() pcall(function() myHrp.CFrame = goal end) end)
            print("✅ 传送成功："..selectedPlayerObj.Name)
            pcall(function() TipDone("传送至选中玩家") end)
        end)
    end
})

SecondaryTab:Button({
    Title = "将选中玩家传送到我的位置",
    Callback = function()
        pcall(function()
            if not selectedPlayerObj then
                NotifyReason("还没有选择玩家，请先点上方【选择玩家 ▼】")
                return
            end
            if not selectedPlayerObj:IsDescendantOf(game) then
                NotifyReason("选中的玩家已经离开服务器")
                selectedPlayerObj = nil
                listBtn.Text="选择玩家 ▼"
                return
            end
            local myChar = LocalPlayer.Character
            if not myChar then NotifyReason("你的角色还没加载，稍等再试") return end
            local myHrp = myChar:FindFirstChild("HumanoidRootPart")
            if not myHrp then NotifyReason("找不到你的角色根部件，无法传送") return end
            local targetChar = selectedPlayerObj.Character
            if targetChar then
                local targetHrp = targetChar:FindFirstChild("HumanoidRootPart")
                if targetHrp then
                    targetHrp.CFrame = myHrp.CFrame
                    print("✅ "..selectedPlayerObj.Name.." 已传送到你的位置")
                    pcall(function() TipDone("将选中玩家传送到我的位置") end)
                else
                    NotifyReason("目标角色还没加载，无法传送")
                end
            else
                NotifyReason("目标角色还没加载，无法传送")
            end
        end)
    end
})

SecondaryTab:Button({
    Title = "将所有人传送到我的位置",
    Callback = function()
        pcall(function()
            local myChar = LocalPlayer.Character
            if not myChar then NotifyReason("你的角色还没加载，稍等再试") return end
            local myHrp = myChar:FindFirstChild("HumanoidRootPart")
            if not myHrp then NotifyReason("找不到你的角色根部件，无法传送") return end
            local count = 0
            for _,p in ipairs(game.Players:GetPlayers()) do
                if p ~= LocalPlayer and p.Character then
                    local hrp = p.Character:FindFirstChild("HumanoidRootPart")
                    if hrp then
                        hrp.CFrame = myHrp.CFrame
                        count = count + 1
                    end
                end
            end
            print("✅ 已把 "..count.." 个玩家传送到你的位置")
            pcall(function() TipDone("将所有人传送到我的位置") end)
        end)
    end
})

--===== 观战选中玩家 =====
local spectateOn = false
local spectateConn = nil
local Camera = workspace.CurrentCamera

local function StopSpectate()
    spectateOn = false
    if spectateConn then spectateConn:Disconnect() spectateConn = nil end
    pcall(function()
        if LocalPlayer.Character then
            local myHum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if myHum then Camera.CameraSubject = myHum end
        end
    end)
    print("🛑 已退出观战")
end

SecondaryTab:Toggle({
    Title = "观战选中玩家",
    Default = false,
    Callback = function(state)
        spectateOn = state
        if spectateConn then spectateConn:Disconnect() spectateConn = nil end
        if state then
            if not selectedPlayerObj then
                NotifyReason("还没有选择玩家，请先点上方【选择玩家 ▼】")
                spectateOn = false
                return
            end
            print("✅ 开始观战："..selectedPlayerObj.Name)
            task.spawn(function()
                while spectateOn and selectedPlayerObj and selectedPlayerObj:IsDescendantOf(game) do
                    pcall(function()
                        local char = selectedPlayerObj.Character
                        if char then
                            local hum = char:FindFirstChildOfClass("Humanoid")
                            if hum then Camera.CameraSubject = hum end
                        end
                    end)
                    task.wait(0.1)
                end
                if spectateOn then StopSpectate() end
            end)
        else
            StopSpectate()
        end
        pcall(function() TipState("观战选中玩家", state) end)
    end
})

--================ 自动Tab =================
local loopRunning = false
local userCode = ""
local loopInterval = 1
local remoteInputBox

RemCodeRoot = function()
    return windUiRoot or game:GetService("Players").LocalPlayer:FindFirstChild("PlayerGui")
end

RemCodeIsTitle = function(txt)
    if type(txt) ~= "string" then return false end
    if txt == "远程事件代码" then return true end
    if string.match(txt, "^远程事件代码%s*%d+$") then return true end
    return false
end

RemCodeFindContainer = function()
    local root = RemCodeRoot()
    if not root then return nil end
    local best = nil
    for _, d in ipairs(root:GetDescendants()) do
        if d:IsA("ScrollingFrame") then
            local found = false
            for _, e in ipairs(d:GetDescendants()) do
                if e:IsA("TextLabel") and e.Text == "远程事件代码" then
                    found = true
                    break
                end
            end
            if found then
                if (not best) or (#d:GetChildren() > #best:GetChildren()) then
                    best = d
                end
            end
        end
    end
    return best
end

RemCodePlaceNew = function(newTitle)
    pcall(function()
        local container = RemCodeFindContainer()
        if not container then return end
        local frames = {}
        for _, c in ipairs(container:GetChildren()) do
            if c:IsA("GuiObject") and not c:IsA("ScrollingFrame") then
                table.insert(frames, c)
            end
        end
        if #frames == 0 then return end
        table.sort(frames, function(a, b)
            return a.AbsolutePosition.Y < b.AbsolutePosition.Y
        end)
        local anchorIdx, newIdx = nil, nil
        for i, f in ipairs(frames) do
            local title = nil
            for _, d in ipairs(f:GetDescendants()) do
                if d:IsA("TextLabel") and RemCodeIsTitle(d.Text) then
                    title = d.Text
                    break
                end
            end
            if title then
                if title == "远程事件代码" then anchorIdx = i end
                if title == newTitle then newIdx = i end
            end
        end
        if not anchorIdx or not newIdx then return end
        local order = {}
        for i, f in ipairs(frames) do order[i] = f end
        table.remove(order, newIdx)
        table.insert(order, anchorIdx + 1, frames[newIdx])
        for i, f in ipairs(order) do
            f.LayoutOrder = i
        end
    end)
end

RemCodeClearAll = function()
    local root = RemCodeRoot()
    if not root then return 0 end
    local n = 0
    for _, d in ipairs(root:GetDescendants()) do
        if d:IsA("TextLabel") and RemCodeIsTitle(d.Text) then
            local el = d
            local guard = 0
            while el and (not el:FindFirstChildOfClass("TextBox")) and guard < 5 and el.Parent do
                el = el.Parent
                guard = guard + 1
            end
            if el then
                for _, t in ipairs(el:GetDescendants()) do
                    if t:IsA("TextBox") and t.Text ~= "" then
                        t.Text = ""
                        n = n + 1
                    end
                end
            end
        end
    end
    return n
end

-- 多个「远程事件代码」输入框共用一个发送逻辑
RemoteCodeTexts = { [1] = "" }
RemoteCodeCount = 1
RemCodeRefresh = function()
    local parts_ = {}
    for i = 1, RemoteCodeCount do
        local t = RemoteCodeTexts[i]
        if type(t) == "string" and t:match("%S") then
            table.insert(parts_, t)
        end
    end
    userCode = table.concat(parts_, "\n")
    return userCode
end

AutoTab:Toggle({
    Title = "无限发送远程事件",
    Default = false,
    Callback = function(state)
        loopRunning = state
        if state then
            if type(userCode) ~= "string" or userCode:match("^%s*$") then
                loopRunning = false
                NotifyReason("还没填远程事件代码，请先在【远程事件代码】输入")
                return
            end
            pcall(function()
                local n = tonumber(loopInterval)
                if not (n and n>0) then loopInterval = 1 end
            end)
            print("✅ 无限发送远程事件已开启，间隔："..loopInterval.."秒")
            task.spawn(function()
                while loopRunning do
                    pcall(function()
                        local fn = loadstring(userCode)
                        if fn then fn() end
                    end)
                    task.wait(loopInterval)
                end
                print("🛑 无限发送远程事件已停止")
            end)
        else
            print("🛑 请求停止无限发送远程事件")
        end
        pcall(function() TipState("无限发送远程事件", state) end)
    end
})

AutoTab:Button({
    Title = "增加远程事件代码输入框",
    Callback = function()
        RemoteCodeCount = RemoteCodeCount + 1
        local idx = RemoteCodeCount
        RemoteCodeTexts[idx] = ""
        local ok, err = pcall(function()
            AutoTab:Input({
                Title = "远程事件代码 " .. idx,
                Default = "",
                Callback = function(t)
                    RemoteCodeTexts[idx] = t
                    RemCodeRefresh()
                    print("✅ 远程事件代码 " .. idx .. " 已更新")
                end
            })
        end)
        if ok then
            task.defer(function()
                pcall(function() RemCodePlaceNew("远程事件代码 " .. idx) end)
            end)
            print("✅ 已增加远程事件代码输入框，共 " .. RemoteCodeCount .. " 个")
            pcall(function() TipDone("已增加代码输入框") end)
        else
            RemoteCodeCount = RemoteCodeCount - 1
            NotifyReason("增加输入框失败：" .. tostring(err))
        end
    end
})

AutoTab:Button({
    Title = "清空远程代码",
    Callback = function()
        local n = RemCodeClearAll() or 0
        userCode = ""
        for i = 1, RemoteCodeCount do RemoteCodeTexts[i] = "" end
        if n > 0 then
            print("✅ 已清空全部远程事件代码，共 " .. n .. " 个输入框")
            pcall(function() TipDone("清空远程代码") end)
        else
            print("✅ 已清空全部远程事件代码")
            pcall(function() TipDone("清空远程代码") end)
        end
    end
})

AutoTab:Input({
    Title = "发送间隔(秒)",
    Default = "1",
    Callback = function(t)
        local n = tonumber(t)
        if n and n > 0 then
            loopInterval = n
            print("✅ 发送间隔已更新为："..loopInterval.." 秒")
        else
            warn("❌ 无效数字，保持原有间隔："..loopInterval)
        end
    end
})

remoteInputBox = AutoTab:Input({
    Title = "远程事件代码",
    Default = "",
    Callback = function(t)
        RemoteCodeTexts[1] = t
        RemCodeRefresh()
        print("✅ 远程事件代码已更新")
    end
})

--===== AutoTab：物品透视 =====
local itemRun = game:GetService("RunService")
local itemEspOn = false
local itemEspName = ""
local itemEspConn = nil
local itemEspHighlights = {}
local itemEspAcc = 0
local itemEspLastCount = -1

local function ClearItemEsp()
    for _, h in ipairs(itemEspHighlights) do
        pcall(function() h:Destroy() end)
    end
    itemEspHighlights = {}
end

local function GetObjPart(obj)
    if obj:IsA("BasePart") then
        return obj
    end
    if obj:IsA("Model") then
        return obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")
    end
    return nil
end

local function GetObjPos(obj)
    local part = GetObjPart(obj)
    return part and part.Position or nil
end

local function GetNearItems(name, limit)
    local list = {}
    if name == "" then return list end
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local origin = hrp and hrp.Position or workspace.CurrentCamera.CFrame.Position
    local key = string.lower(name)
    for _, obj in ipairs(workspace:GetDescendants()) do
        local objName = obj:IsA("BasePart") or obj:IsA("Model")
        if objName and string.find(string.lower(obj.Name), key, 1, true) then
            local part = GetObjPart(obj)
            if part then
                local pos = part.Position
                table.insert(list, { obj = obj, part = part, pos = pos, dist = (pos - origin).Magnitude })
            end
        end
    end
    table.sort(list, function(a, b) return a.dist < b.dist end)
    while #list > limit do
        table.remove(list)
    end
    return list
end

-- 物品透视：物品整体完全在屏幕内 → 不显示框和名字
task.spawn(function()
    while true do
        task.wait(0.15)
        pcall(function()
            for _, inst in ipairs(itemEspHighlights) do
                if inst:IsA("Highlight") then
                    local obj = inst.Parent
                    if obj and (obj:IsA("Model") or obj:IsA("BasePart")) then
                        if EspVisibleEnough then inst.Enabled = not EspVisibleEnough(obj) end
                    end
                elseif inst:IsA("BillboardGui") then
                    -- 物品名字始终显示
                    inst.Enabled = true
                end
            end
        end)
    end
end)

local function RefreshItemEsp()
    ClearItemEsp()
    if not itemEspOn or itemEspName == "" then return end
    local list = GetNearItems(itemEspName, 25)
    if #list ~= (itemEspLastCount or -1) then
        itemEspLastCount = #list
        print("✅ 已透视「"..itemEspName.."」最近 "..#list.." 个")
    end
    for _, t in ipairs(list) do
        local h = Instance.new("Highlight")
        h.Name = "xzhItemEsp"
        h.FillColor = Color3.new(1, 0.25, 0.25)
        h.FillTransparency = 0.5
        h.OutlineColor = Color3.new(1, 1, 0)
        h.OutlineTransparency = 0
        h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        pcall(function() h.Parent = t.obj end)
        -- 一建出来就先按"能不能直接看到"决定显不显示，避免每秒刷新时闪一下
        pcall(function()
            if EspSeenDirectly then
                h.Enabled = not EspSeenDirectly(t.obj)
            end
        end)
        table.insert(itemEspHighlights, h)
        local part = t.part
        if part and part.Parent then
            local bb = Instance.new("BillboardGui")
            bb.Name = "xzhItemEspTag"
            bb.Size = UDim2.new(0, 110, 0, 26)
            bb.StudsOffset = Vector3.new(0, 2.5, 0)
            bb.AlwaysOnTop = true
            bb.LightInfluence = 0
            bb.Adornee = part
            local tl = Instance.new("TextLabel")
            tl.Size = UDim2.new(1, 0, 1, 0)
            tl.BackgroundTransparency = 1
            tl.Text = t.obj.Name .. " · " .. math.floor(t.dist) .. "格"
            tl.TextColor3 = Color3.new(1, 1, 0.2)
            tl.TextStrokeTransparency = 0
            tl.TextStrokeColor3 = Color3.new(0, 0, 0)
            tl.Font = Enum.Font.GothamBold
            tl.TextSize = 13
            tl.AutoLocalize = false
            tl.Parent = bb
            pcall(function() bb.Parent = part end)
            table.insert(itemEspHighlights, bb)
        end
    end
end

AutoTab:Paragraph({
    Title = "────────────────────────────────────",
    Desc = ""
})

AutoTab:Input({
    Title = "物品名称(变量名)",
    Default = "",
    Callback = function(t)
        local trimmed = t:match("^%s*(.-)%s*$") or t
        itemEspName = trimmed
        print("✅ 透视/传送目标已设为："..itemEspName)
    end
})

AutoTab:Toggle({
    Title = "物品透视(最近25个)",
    Default = false,
    Callback = function(state)
        if state and itemEspName == "" then
            itemEspOn = false
            NotifyReason("还没填物品名称，请先在【物品名称(变量名)】输入")
            return
        end
        itemEspOn = state
        if itemEspConn then
            pcall(function() itemEspConn:Disconnect() end)
            itemEspConn = nil
        end
        if state then
            itemEspAcc = 0
            RefreshItemEsp()
            itemEspConn = itemRun.Heartbeat:Connect(function(dt)
                itemEspAcc = itemEspAcc + dt
                if itemEspAcc >= 1 then
                    itemEspAcc = 0
                    pcall(RefreshItemEsp)
                end
            end)
            print("✅ 物品透视已开启，每 1 秒刷新最近的 25 个「"..itemEspName.."」")
        else
            ClearItemEsp()
            print("🛑 物品透视已关闭")
        end
        pcall(function() TipState("物品透视(最近25个)", state) end)
    end
})

AutoTab:Button({
    Title = "传送一次最近此物品",
    Callback = function()
        if itemEspName == "" then
            NotifyReason("还没填物品名称，请先在【物品名称(变量名)】输入")
            return
        end
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if not hrp then
            NotifyReason("你的角色还没加载，稍等再试")
            return
        end
        local list = GetNearItems(itemEspName, 1)
        if #list == 0 then
            NotifyReason("附近没找到「"..itemEspName.."」，换个物品名试试")
            return
        end
        local t = list[1]
        pcall(function()
            hrp.CFrame = CFrame.new(t.pos + Vector3.new(0, 4, 0))
            hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
        end)
        print("✅ 已传送到最近「"..itemEspName.."」，距离 "..math.floor(t.dist).." 格")
        pcall(function() TipDone("传送一次最近此物品") end)
    end
})

local itemAutoOn = false

local function InteractWith(obj)
    if not obj or not obj.Parent then return end
    local hitPrompt = false
    for _, pp in ipairs(obj:GetDescendants()) do
        if pp:IsA("ProximityPrompt") then
            pcall(function()
                pp.HoldDuration = 0
                pp:InputHoldBegin()
                pp:InputHoldEnd()
            end)
            hitPrompt = true
        end
    end
    for _, cd in ipairs(obj:GetDescendants()) do
        if cd:IsA("ClickDetector") then
            pcall(function() fireclickdetector(cd) end)
        end
    end
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local part = nil
    if obj:IsA("BasePart") then
        part = obj
    elseif obj:IsA("Model") then
        part = obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")
    end
    if hrp and part then
        pcall(function()
            firetouchinterest(hrp, part, 0)
            task.wait(0.08)
            firetouchinterest(hrp, part, 1)
        end)
    end
    return hitPrompt
end

local function StartItemAutoLoop()
    task.spawn(function()
        local curObj = nil
        local curPos = nil
        while itemAutoOn do
            local char = LocalPlayer.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            if not hrp then
                task.wait(0.3)
            elseif itemEspName == "" then
                NotifyReason("还没填物品名称，请先在【物品名称(变量名)】输入")
                task.wait(1)
            else
                if not (curObj and curObj.Parent) then
                    curObj = nil
                    curPos = nil
                    local list = GetNearItems(itemEspName, 60)
                    local target = nil
                    for _, t in ipairs(list) do
                        if t.obj.Parent then
                            target = t
                            break
                        end
                    end
                    if target then
                        curObj = target.obj
                        curPos = target.pos
                        print("✅ 锁定「"..curObj.Name.."」，一直停在它身上直到拾取成功")
                    else
                        print("✅ 附近「"..itemEspName.."」已全部拾取，2 秒后重新扫描")
                        task.wait(2)
                    end
                end
                if curObj and curPos then
                    local born = os.clock()
                    local tick = 0
                    while itemAutoOn and curObj and curObj.Parent do
                        local c2 = LocalPlayer.Character
                        local hp = c2 and c2:FindFirstChild("HumanoidRootPart")
                        if not hp then break end
                        pcall(function()
                            hp.CFrame = CFrame.new(curPos + Vector3.new(0, 4, 0))
                            hp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                        end)
                        tick = tick + 1
                        if tick % 5 == 1 then
                            pcall(InteractWith, curObj)
                        end
                        if os.clock() - born > 25 then
                            print("⚠ 「"..curObj.Name.."」25 秒还没拾取到，先跳到下一个")
                            curObj = nil
                            break
                        end
                        task.wait(0.05)
                    end
                    if curObj and not curObj.Parent then
                        print("✅ 已拾取「"..curObj.Name.."」，接着锁定下一个")
                        curObj = nil
                        curPos = nil
                    end
                end
            end
        end
    end)
end

AutoTab:Toggle({
    Title = "自动传送交互物品",
    Default = false,
    Callback = function(state)
        if state and itemEspName == "" then
            NotifyReason("还没填物品名称，请先在【物品名称(变量名)】输入")
            return
        end
        itemAutoOn = state
        if state then
            print("✅ 自动传送交互已开启，逐个传送到物品并完成交互")
            StartItemAutoLoop()
        else
            print("🛑 自动传送交互已关闭")
        end
        pcall(function() TipState("自动传送交互物品", state) end)
    end
})

--==================== xzh标签页 ====================
local physControlRunning = false
local setWalkSpeed = 50
local setJumpPower = 90
local savedWalkSpeed = nil
local savedJumpPower = nil

local nightVisionOn = false
local nightVisionLoopConn = nil
local origAmbient
local origOutdoorAmbient
local origBrightness
local origColorShiftTop
local origColorShiftBottom
local origAtmosphereDensity
local origAtmosphereGlare
local origAtmosphereHaze

--===== 暴力穿墙ESP（彩虹流动版） =====
local espPlayersOn = false
local espBoxList = {}
local espConnTable = {}
local espRefreshLoop

local espColorPresets = {
    ["纯红"]   = Color3.new(1, 0, 0),
    ["纯青"]   = Color3.new(0, 1, 1),
    ["纯绿"]   = Color3.new(0, 1, 0),
    ["纯黄"]   = Color3.new(1, 1, 0),
    ["纯紫"]   = Color3.new(1, 0, 1),
    ["纯橙"]   = Color3.new(1, 0.5, 0),
    ["纯白"]   = Color3.new(1, 1, 1),
    ["纯蓝"]   = Color3.new(0, 0, 1),
}
local espColorNames = {"纯红","纯青","纯绿","纯黄","纯紫","纯橙","纯白","纯蓝","彩虹流动"}
local espSelectedColor = "纯红"
local espCurrentColor = espColorPresets[espSelectedColor]
local espBoxTransparency = 0.15

local rainbowHue = 0
local rainbowConn = nil
local RunService = game:GetService("RunService")

-- 判断"屏幕上能不能直接看到这个模型"：相机射线被墙/物体挡住就看不到
EspSeenDirectly = function(model)
    local cam = workspace.CurrentCamera
    if not cam or not model then return false end
    local parts = {}
    pcall(function()
        if model:IsA("BasePart") then
            parts[1] = model
        else
            for _, d in ipairs(model:GetDescendants()) do
                if d:IsA("BasePart") then
                    parts[#parts + 1] = d
                    if #parts >= 8 then break end
                end
            end
        end
    end)
    if #parts == 0 then return false end
    local vp = cam.ViewportSize
    local origin = cam.CFrame.Position
    local total = 0
    local seen = 0
    local params
    pcall(function()
        params = RaycastParams.new()
        params.FilterType = Enum.RaycastFilterType.Exclude
        local excl = {model}
        local myChar = LocalPlayer.Character
        if myChar then table.insert(excl, myChar) end
        params.FilterDescendantsInstances = excl
        params.IgnoreWater = true
    end)
    for _, part in ipairs(parts) do
        pcall(function()
            local pos = part.Position
            local sp, onScreen = cam:WorldToViewportPoint(pos)
            total = total + 1
            if onScreen and sp.X >= 2 and sp.Y >= 2 and sp.X <= (vp.X - 2) and sp.Y <= (vp.Y - 2) then
                local hit = nil
                if params then
                    hit = workspace:Raycast(origin, pos - origin, params)
                end
                if not hit then
                    seen = seen + 1
                end
            end
        end)
    end
    if total <= 0 then return false end
    return (seen / total) >= 0.7
end

EspVisibleEnough = function(model)
    return EspSeenDirectly(model)
end

local function GetPlayerBoxSize(char)
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local mult = 1
    if hum then
        local depth = hum:FindFirstChild("BodyDepthScale")
        local height = hum:FindFirstChild("BodyHeightScale")
        local width = hum:FindFirstChild("BodyWidthScale")
        local d = depth and depth.Value or 1
        local h = height and height.Value or 1
        local w = width and width.Value or 1
        mult = (d + h + w) / 3
    end
    local base = Vector3.new(3.2, 6.5, 2.6)
    return Vector3.new(
        math.max(0.9, base.X * mult),
        math.max(1.4, base.Y * mult),
        math.max(0.9, base.Z * mult)
    )
end

local function RefreshAllEspColors()
    for _, box in ipairs(espBoxList) do
        pcall(function()
            box.Color3 = espCurrentColor
            box.Transparency = espBoxTransparency
            local ad = box.Adornee
            if ad then
                local gui = ad:FindFirstChild("PlayerESPName")
                local lbl = gui and gui:FindFirstChild("NameLabel")
                if lbl then lbl.TextColor3 = espCurrentColor end
            end
        end)
    end
end

local function RefreshAllEspSizes()
    for _, box in ipairs(espBoxList) do
        pcall(function()
            local char = box.Adornee and box.Adornee.Parent
            if char and char:FindFirstChildOfClass("Humanoid") then
                box.Size = GetPlayerBoxSize(char)
            end
        end)
    end
end

local function StopRainbow()
    if rainbowConn then
        rainbowConn:Disconnect()
        rainbowConn = nil
    end
end

local function StartRainbow()
    StopRainbow()
    rainbowConn = RunService.RenderStepped:Connect(function(dt)
        rainbowHue += dt * 0.4
        if rainbowHue > 1 then rainbowHue = 0 end
        espCurrentColor = Color3.fromHSV(rainbowHue, 1, 1)
        RefreshAllEspColors()
    end)
end

-- 删除透视方框（连同头顶名称）
EspBoxCrush = function(b)
    if not b then return end
    pcall(function()
        local ad = b.Adornee
        b:Destroy()
        if ad then
            local n = ad:FindFirstChild("PlayerESPName")
            if n then n:Destroy() end
        end
    end)
end

local function MakeBoxESP(rootPart)
    local box = Instance.new("BoxHandleAdornment")
    box.Name = "PlayerESPBox"
    box.Adornee = rootPart
    box.Color3 = espCurrentColor
    box.Transparency = espBoxTransparency
    box.Shading = Enum.AdornShading.XRay
    box.AlwaysOnTop = true
    box.ZIndex = 0
    box.Size = GetPlayerBoxSize(rootPart.Parent)
    box.Parent = rootPart
    pcall(function()
        local old = rootPart:FindFirstChild("PlayerESPName")
        if old then old:Destroy() end
        local gui = Instance.new("BillboardGui")
        gui.Name = "PlayerESPName"
        gui.Adornee = rootPart
        gui.AlwaysOnTop = true
        gui.Size = UDim2.new(0, 110, 0, 22)
        gui.StudsOffset = Vector3.new(0, 2.5, 0)
        gui.MaxDistance = 1200
        gui.LightInfluence = 0
        gui.Parent = rootPart
        local lbl = Instance.new("TextLabel")
        lbl.Name = "NameLabel"
        lbl.Size = UDim2.new(1, 0, 1, 0)
        lbl.BackgroundTransparency = 1
        lbl.Text = (rootPart.Parent and rootPart.Parent.Name) or ""
        lbl.TextColor3 = espCurrentColor
        lbl.TextStrokeTransparency = 0
        lbl.TextStrokeColor3 = Color3.new(0, 0, 0)
        lbl.TextSize = 13
        lbl.Font = Enum.Font.GothamBold
        lbl.Parent = gui
    end)
    return box
end



-- 人物透视：视线能直达约 70% 就不画框；名字始终显示
task.spawn(function()
    while true do
        task.wait(0.12)
        pcall(function()
            for _, b in ipairs(espBoxList) do
                local ad = b.Adornee
                if ad and ad.Parent then
                    local char = ad.Parent
                    local full = EspVisibleEnough(char)
                    b.Transparency = full and 1 or espBoxTransparency
                    local nm = ad:FindFirstChild("PlayerESPName")
                    if nm then nm.Enabled = true end
                end
            end
        end)
    end
end)


local function SetupPlayerESP(pl)
    if pl == LocalPlayer then return end
    local charAddedConn
    charAddedConn = pl.CharacterAdded:Connect(function(char)
        task.wait(0.1)
        if not espPlayersOn then return end
        local hrp = char:WaitForChild("HumanoidRootPart", 2)
        if hrp then
            local b = MakeBoxESP(hrp)
            table.insert(espBoxList, b)
            print("✅ 已为 " .. pl.Name .. " 添加透视方框")
        end
    end)
    table.insert(espConnTable, charAddedConn)
    if pl.Character then
        local hrp = pl.Character:FindFirstChild("HumanoidRootPart")
        if hrp then
            local b = MakeBoxESP(hrp)
            table.insert(espBoxList, b)
            print("✅ 已为 " .. pl.Name .. " 添加透视方框")
        end
    end
end







--===== 无限跳跃 =====
local infJumpOn = false
local infJumpConn = nil
local infJumpLoopConn = nil
local jumpHeld = false
local jumpBtnRef = nil
local jumpBtnConns = {}
local UserInputService = game:GetService("UserInputService")

local function disconnectJumpButton()
    for _, c in ipairs(jumpBtnConns) do
        pcall(function() c:Disconnect() end)
    end
    jumpBtnConns = {}
    jumpBtnRef = nil
    jumpHeld = false
end

-- 手机端长按跳跃按钮：监听核心 JumpButton 的按下/松开
local function hookJumpButton()
    if not infJumpOn then return end
    local pg = LocalPlayer:FindFirstChild("PlayerGui")
    local tg = pg and pg:FindFirstChild("TouchGui")
    local btn = tg and tg:FindFirstChild("JumpButton")
    if btn and btn ~= jumpBtnRef then
        disconnectJumpButton()
        jumpBtnRef = btn
        table.insert(jumpBtnConns, btn.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
                jumpHeld = true
            end
        end))
        table.insert(jumpBtnConns, btn.InputEnded:Connect(function(input)
            jumpHeld = false
        end))
    end
end

local function doInfJump()
    local myChar = LocalPlayer.Character
    if not myChar then return end
    local hum = myChar:FindFirstChildOfClass("Humanoid")
    local hrp = myChar:FindFirstChild("HumanoidRootPart")
    if not (hum and hrp) then return end
    local power = hum.JumpPower
    if power <= 0 then power = 50 end
    local vel = hrp.AssemblyLinearVelocity
    pcall(function()
        hrp.AssemblyLinearVelocity = Vector3.new(vel.X, power, vel.Z)
    end)
    pcall(function()
        hum:ChangeState(Enum.HumanoidStateType.Freefall)
    end)
end

local function bindInfJump(char)
    if infJumpConn then
        pcall(function() infJumpConn:Disconnect() end)
        infJumpConn = nil
    end
    if infJumpLoopConn then
        pcall(function() infJumpLoopConn:Disconnect() end)
        infJumpLoopConn = nil
    end
    infJumpConn = UserInputService.JumpRequest:Connect(function()
        if not infJumpOn then return end
        doInfJump()
    end)
    local btnTimer = 0
    infJumpLoopConn = RunService.Heartbeat:Connect(function(dt)
        if not infJumpOn then return end
        btnTimer = btnTimer + dt
        if btnTimer > 0.5 then
            btnTimer = 0
            pcall(hookJumpButton)
        end
        local myChar = LocalPlayer.Character
        if not myChar then return end
        local hum = myChar:FindFirstChildOfClass("Humanoid")
        local hrp = myChar:FindFirstChild("HumanoidRootPart")
        if not (hum and hrp) then return end
        if (jumpHeld or hum.Jump) then
            doInfJump()
        end
    end)
end



LocalPlayer.CharacterAdded:Connect(function(char)
    task.wait(0.3)
    if infJumpOn then bindInfJump(char) end
end)

local function stopNightVision()
    nightVisionOn = false
    if nightVisionLoopConn then
        pcall(function() task.cancel(nightVisionLoopConn) end)
        nightVisionLoopConn = nil
    end
    local lighting = game:GetService("Lighting")
    if origAmbient then lighting.Ambient = origAmbient end
    if origOutdoorAmbient then lighting.OutdoorAmbient = origOutdoorAmbient end
    if origBrightness then lighting.Brightness = origBrightness end
    if origColorShiftTop then lighting.ColorShift_Top = origColorShiftTop end
    if origColorShiftBottom then lighting.ColorShift_Bottom = origColorShiftBottom end
    local atmo = lighting:FindFirstChild("Atmosphere")
    if atmo then
        if origAtmosphereDensity then atmo.Density = origAtmosphereDensity end
        if origAtmosphereGlare then atmo.Glare = origAtmosphereGlare end
        if origAtmosphereHaze then atmo.Haze = origAtmosphereHaze end
    end
end



SecondaryTab:Toggle({
    Title = "透视全部玩家",
    Default = false,
    Callback = function(state)
        espPlayersOn = state
        for _,c in ipairs(espConnTable) do pcall(function() c:Disconnect() end) end
        espConnTable = {}
        for _,box in ipairs(espBoxList) do EspBoxCrush(box) end
        espBoxList = {}
        if espRefreshLoop then task.cancel(espRefreshLoop) espRefreshLoop=nil end
        StopRainbow()

        if state then
            print("✅ 透视全部玩家已开启，颜色："..espSelectedColor)
            local PlayersService = game:GetService("Players")
            for _,p in ipairs(PlayersService:GetPlayers()) do SetupPlayerESP(p) end
            local pac = PlayersService.PlayerAdded:Connect(function(newPl) SetupPlayerESP(newPl) end)
            table.insert(espConnTable,pac)
            espRefreshLoop = task.spawn(function()
                while espPlayersOn do
                    RefreshAllEspSizes()
                    task.wait(0.4)
                end
            end)
            if espSelectedColor == "彩虹流动" then
                StartRainbow()
            end
        else
            print("🛑 透视全部玩家已关闭")
        end
        pcall(function() TipState("透视全部玩家", state) end)
    end
})

local espColorDropdownOpen = false
local espColorDropdownFrame
local espColorDropdownScroll
local espColorDropdownLayout

local espColorBtn = SecondaryTab:Button({Title = "透视框颜色 ▼", Callback=function()
    espColorDropdownOpen = not espColorDropdownOpen
    espColorDropdownFrame.Visible = espColorDropdownOpen
    if espColorDropdownOpen then
        espColorDropdownFrame.Size = UDim2.new(1,0,1,0)
        espColorDropdownFrame.Position = UDim2.new(0,0,0,0)
        print("✅ 颜色选择列表已展开")
    else
        print("✅ 颜色选择列表已收起")
    end
end})

espColorDropdownFrame = Instance.new("Frame")
espColorDropdownFrame.Size = UDim2.new(0,280,0,260)
espColorDropdownFrame.Position = UDim2.new(0,10,0,260)
espColorDropdownFrame.BackgroundColor3 = Color3.new(0.12,0.12,0.14)
espColorDropdownFrame.BorderSizePixel =0
espColorDropdownFrame.Visible = false
espColorDropdownFrame.ZIndex = 200
espColorDropdownFrame.Parent = windUiRoot

local espColorCloseBtn = Instance.new("TextButton")
espColorCloseBtn.Size = UDim2.new(0,24,0,24)
espColorCloseBtn.Position = UDim2.new(1,-26,0,2)
espColorCloseBtn.BackgroundColor3 = Color3.new(0.8,0,0)
espColorCloseBtn.Text = "X"
espColorCloseBtn.TextColor3 = Color3.new(1,1,1)
espColorCloseBtn.Font = Enum.Font.GothamBold
espColorCloseBtn.TextSize =14
espColorCloseBtn.ZIndex =201
espColorCloseBtn.Parent = espColorDropdownFrame
espColorCloseBtn.InputBegan:Connect(function(input)
    if input.UserInputType ~= Enum.UserInputType.Touch and input.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
    espColorDropdownOpen = false
    espColorDropdownFrame.Visible = false
    print("✅ 颜色选择列表已关闭")
end)

espColorDropdownScroll = Instance.new("ScrollingFrame")
espColorDropdownScroll.Size = UDim2.new(1,-4,1,-4)
espColorDropdownScroll.Position = UDim2.new(0,2,0,2)
espColorDropdownScroll.BackgroundTransparency=1
espColorDropdownScroll.ScrollBarThickness=6
espColorDropdownScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
espColorDropdownScroll.CanvasSize=UDim2.new(0,0,0,0)
espColorDropdownScroll.Parent = espColorDropdownFrame

espColorDropdownLayout = Instance.new("UIListLayout")
espColorDropdownLayout.Padding = UDim.new(0,2)
espColorDropdownLayout.SortOrder=Enum.SortOrder.LayoutOrder
espColorDropdownLayout.Parent=espColorDropdownScroll

local espColorRows = {}
local espColorSelectedBtn = nil

for i, cName in ipairs(espColorNames) do
    local colorBtn = Instance.new("TextButton")
    colorBtn.Name = "ColorRow"
    colorBtn.Size=UDim2.new(1,0,0,34)
    colorBtn.BackgroundColor3 = Color3.new(0.16,0.16,0.18)
    colorBtn.Text = cName
    colorBtn.TextColor3=Color3.new(1,1,1)
    colorBtn.Font=Enum.Font.Gotham
    colorBtn.TextSize=15
    colorBtn.LayoutOrder = i
    colorBtn.AutoButtonColor = false
    colorBtn.Parent = espColorDropdownScroll
    colorBtn.InputBegan:Connect(function(input)
        if input.UserInputType ~= Enum.UserInputType.Touch and input.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
        if espColorSelectedBtn then
            pcall(function() espColorSelectedBtn.BackgroundColor3 = Color3.new(0.16,0.16,0.18) end)
        end
        espColorSelectedBtn = colorBtn
        colorBtn.BackgroundColor3 = Color3.new(0.18,0.58,0.32)
        espSelectedColor = cName
        StopRainbow()
        if cName == "彩虹流动" then
            espCurrentColor = Color3.fromHSV(rainbowHue, 1, 1)
            if espPlayersOn then StartRainbow() end
        else
            espCurrentColor = espColorPresets[cName]
        end
        espColorBtn.Title = "透视框颜色 ▼ ("..cName..")"
        RefreshAllEspColors()
        print("✅ 透视框颜色已切换为："..cName)
    end)
    espColorRows[cName] = colorBtn
end

--===== xzh：玩家选择 + 单独透视（与传送玩家列表同款逻辑）=====
;(function()
local soloOn = false
local targetPlr = nil
local targetBtn = nil
local soloFrame = nil
local soloScroll = nil
local soloSelectedBtn = nil
local soloRows = {}

local function clearBoxes()
    for _, b in ipairs(espBoxList) do
        EspBoxCrush(b)
    end
    espBoxList = {}
end

local function enforceSolo()
    local t = targetPlr
    if not t or (not t:IsDescendantOf(game)) or t.Parent ~= game.Players then
        if #espBoxList > 0 then clearBoxes() end
        return
    end
    local char = t.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then
        if #espBoxList > 0 then clearBoxes() end
        return
    end
    local keep = nil
    for i = #espBoxList, 1, -1 do
        local b = espBoxList[i]
        if b.Parent and b.Adornee and b.Adornee.Parent == char then
            keep = b
        else
            EspBoxCrush(b)
            table.remove(espBoxList, i)
        end
    end
    if not keep then
        keep = MakeBoxESP(hrp)
        table.insert(espBoxList, keep)
    end
    pcall(function()
        keep.Color3 = espCurrentColor
        -- 透明度交给统一的可见性循环控制，避免把"看得见就不画框"覆盖掉
    end)
end

local function CreateSoloRow(plr, order, friendSet)
    local isFr = friendSet and friendSet[plr.UserId] and true or false
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1,0,0,34)
    btn.BackgroundColor3 = isFr and Color3.fromRGB(0.14,0.15,0.24) or Color3.new(0.16,0.16,0.18)
    local dispName = GetNameOf(plr) .. "  (" .. plr.Name .. ")"
    btn.Text = isFr and ("★ 好友 · "..dispName) or dispName
    btn.TextColor3 = isFr and Color3.fromRGB(255,214,92) or Color3.new(1,1,1)
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 15
    btn.AutoButtonColor = false
    btn.LayoutOrder = order
    btn:SetAttribute("xzhSoloUid", plr.UserId)
    btn.Parent = soloScroll
    if targetPlr == plr then
        btn.BackgroundColor3 = Color3.new(0.18,0.58,0.32)
        soloSelectedBtn = btn
    end
    btn.InputBegan:Connect(function(input)
        if input.UserInputType ~= Enum.UserInputType.Touch and input.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
        if soloSelectedBtn and soloSelectedBtn.Parent then
            pcall(function() soloSelectedBtn.BackgroundColor3 = Color3.new(0.16,0.16,0.18) end)
        end
        soloSelectedBtn = btn
        btn.BackgroundColor3 = Color3.new(0.18,0.58,0.32)
        targetPlr = plr
        pcall(function() targetBtn.Title = "透视目标 ▼ ("..GetNameOf(plr)..")" end)
        print("✅ 透视目标已设为："..GetNameOf(plr))
        if soloOn then pcall(enforceSolo) end
    end)
    soloRows[plr.UserId] = { plr = plr, btn = btn }
end

-- 每 0.15 秒对账，与传送玩家列表同一套：不在的就删、新来的就加、名字实时同步
local function refreshTargets(force)
    if not (soloScroll and soloScroll:IsDescendantOf(game)) then return end
    if force then
        for uid, row in pairs(soloRows) do
            pcall(function() row.btn:Destroy() end)
            soloRows[uid] = nil
        end
        soloSelectedBtn = nil
        for _, child in ipairs(soloScroll:GetChildren()) do
            if child:IsA("TextButton") then child:Destroy() end
        end
    end
    local friendSet = GetFriendSetCached()
    local players = {}
    for _, p in ipairs(game.Players:GetPlayers()) do
        if p ~= LocalPlayer then table.insert(players, p) end
    end
    table.sort(players, function(a,b)
        local fa = friendSet[a.UserId] and 1 or 0
        local fb = friendSet[b.UserId] and 1 or 0
        if fa ~= fb then return fa > fb end
        return a.Name:lower() < b.Name:lower()
    end)
    local alive = {}
    for _, p in ipairs(players) do alive[p.UserId] = p end

    -- 1) 已不在服务器的：删除
    for uid, row in pairs(soloRows) do
        local still = alive[uid] ~= nil and row.plr and row.plr:IsDescendantOf(game) and row.plr.Parent == game.Players
        if not still then
            if soloSelectedBtn == row.btn then
                soloSelectedBtn = nil
            end
            if targetPlr and targetPlr.UserId == uid then
                targetPlr = nil
                pcall(function() targetBtn.Title = "透视目标 ▼" end)
            end
            pcall(function() row.btn:Destroy() end)
            soloRows[uid] = nil
        end
    end

    -- 2) 新来的加入 / 名字与排序更新
    for i, plr in ipairs(players) do
        local row = soloRows[plr.UserId]
        if (not row) or (not row.btn) or (not row.btn.Parent) then
            if row and row.btn then pcall(function() row.btn:Destroy() end) end
            soloRows[plr.UserId] = nil
            CreateSoloRow(plr, i, friendSet)
        else
            if row.btn.LayoutOrder ~= i then row.btn.LayoutOrder = i end
            local isFr = friendSet[plr.UserId] and true or false
            local wantName = GetNameOf(plr) .. "  (" .. plr.Name .. ")"
            local want = isFr and ("★ 好友 · "..wantName) or wantName
            if row.btn.Text ~= want then row.btn.Text = want end
            local wantColor = isFr and Color3.fromRGB(255,214,92) or Color3.new(1,1,1)
            if row.btn.TextColor3 ~= wantColor then row.btn.TextColor3 = wantColor end
        end
    end

    -- 3) 孤儿行清理
    for _, child in ipairs(soloScroll:GetChildren()) do
        if child:IsA("TextButton") and child.Name ~= "SoloNoHint" then
            local uid = child:GetAttribute("xzhSoloUid")
            if (not uid) or (not alive[uid]) then
                pcall(function() child:Destroy() end)
            end
        end
    end

    -- 4) 空提示
    local hint = soloScroll:FindFirstChild("SoloNoHint")
    if #players == 0 then
        if not hint then
            local n = Instance.new("TextButton")
            n.Name = "SoloNoHint"
            n.Size = UDim2.new(1,0,0,34)
            n.BackgroundTransparency = 0.9
            n.Text = "【无其他玩家】"
            n.TextColor3 = Color3.new(1,1,1)
            n.Font = Enum.Font.Gotham
            n.TextSize = 15
            n.LayoutOrder = 999
            n.Parent = soloScroll
        end
    elseif hint then
        pcall(function() hint:Destroy() end)
    end

    -- 5) 目标名字实时更新
    if targetPlr and targetPlr.Parent == game.Players then
        pcall(function() targetBtn.Title = "透视目标 ▼ ("..GetNameOf(targetPlr)..")" end)
    end
end

SoloOnlyToggle = SecondaryTab:Toggle({
    Title = "只透视选中玩家",
    Default = false,
    Callback = function(state)
        soloOn = state
        if state then
            if not targetPlr then
                NotifyReason("还没有选择玩家，请先点上方【选择玩家 ▼】")
            else
                print("✅ 只透视："..GetNameOf(targetPlr))
                pcall(enforceSolo)
                pcall(function() TipState("只透视选中玩家", true) end)
            end
        else
            clearBoxes()
            if espPlayersOn then
                for _, p in ipairs(game.Players:GetPlayers()) do
                    pcall(function() SetupPlayerESP(p) end)
                end
            end
            print("🛑 已退出单独透视")
            pcall(function() TipState("只透视选中玩家", false) end)
        end
    end
})

-- 透视目标直接跟传送页的选择玩家共用一份选择
task.spawn(function()
    while task.wait(0.2) do
        pcall(function()
            if selectedPlayerObj ~= targetPlr then
                targetPlr = selectedPlayerObj
            end
        end)
    end
end)

task.spawn(function()
    while task.wait(0.25) do
        if soloOn then pcall(enforceSolo) end
    end
end)

-- 颜色与全量透视共用同一套：包含「彩虹流动」时自己也流动，
-- 不再等全量透视那边启动彩虹才变色
RunService.RenderStepped:Connect(function()
    if not soloOn then return end
    local col = espCurrentColor
    if espSelectedColor == "彩虹流动" then
        col = Color3.fromHSV((os.clock() * 0.12) % 1, 1, 1)
    end
    for _, b in ipairs(espBoxList) do
        pcall(function()
            b.Color3 = col
            b.Transparency = espBoxTransparency
        end)
    end
end)
end)()

--==================== OtherTab ====================
local hideOtherPlayers = false
local hideConnections = {}

local function ClearOtherPlayerCharacters()
    for _,pl in ipairs(game.Players:GetPlayers()) do
        if pl ~= LocalPlayer and pl.Character then
            pcall(function() pl.Character:Destroy() end)
        end
    end
end

OtherTab:Toggle({
    Title = "持续删除其他玩家模型",
    Default = false,
    Callback = function(state)
        hideOtherPlayers = state
        for _,conn in ipairs(hideConnections) do pcall(function() conn:Disconnect() end) end
        hideConnections = {}
        if state then
            print("✅ 持续删除其他玩家模型已开启")
            ClearOtherPlayerCharacters()
            for _,pl in ipairs(game.Players:GetPlayers()) do
                if pl ~= LocalPlayer then
                    table.insert(hideConnections, pl.CharacterAdded:Connect(function(char)
                        task.wait(0.1)
                        pcall(function() char:Destroy() end)
                        print("✅ 已删除玩家 "..pl.Name.." 的模型")
                    end))
                end
            end
            table.insert(hideConnections, game.Players.PlayerAdded:Connect(function(newPl)
                table.insert(hideConnections, newPl.CharacterAdded:Connect(function(char)
                    task.wait(0.1)
                    pcall(function() char:Destroy() end)
                    print("✅ 已删除新玩家 "..newPl.Name.." 的模型")
                end))
            end))
            task.spawn(function()
                while hideOtherPlayers do
                    ClearOtherPlayerCharacters()
                    task.wait(0.5)
                end
            end)
        else
            print("🛑 持续删除其他玩家模型已关闭")
        end
        pcall(function() TipState("持续删除其他玩家模型", state) end)
    end
})

--===== OtherTab：单击触发（取消长按ProximityPrompt） =====
local oneTapPickup = false
OtherTab:Toggle({
    Title = "单击触发（取消长按）",
    Default = false,
    Callback = function(state)
        oneTapPickup = state
        if state then
            print("✅ 单击触发ProximityPrompt 开启，取消长按")
        else
            print("🛑 单击触发ProximityPrompt 关闭，恢复长按")
        end
        pcall(function() TipState("单击触发（取消长按）", state) end)
    end
})

task.spawn(function()
    while task.wait(0.35 + math.random() * 0.45) do
        if oneTapPickup then
            pcall(function()
                for _,obj in ipairs(workspace:GetDescendants()) do
                    if obj:IsA("ProximityPrompt") then
                        obj.HoldDuration = 0
                    end
                end
            end)
        end
    end
end)

--===== OtherTab：穿透（正面碰到的物体不变成实体） =====
local ghostOn = false
local ghostOrigWalkSpeed = nil
local ghostOrigJumpPower = nil
local ghostOrigJumpHeight = nil
local ghostOrigCollide = {}
local ghostConn = nil
local ghostAcc = 0

local function RestoreGhostParts()
    for part, orig in pairs(ghostOrigCollide) do
        pcall(function()
            if part.Parent then
                part.CanCollide = orig
            end
        end)
    end
    ghostOrigCollide = {}
    print("🛑 已恢复所有物体的实体状态")
end

local function IsCharacterPart(part)
    local model = part:FindFirstAncestorOfClass("Model")
    if model then
        if model:FindFirstChildOfClass("Humanoid") then return true end
        if game.Players:GetPlayerFromCharacter(model) then return true end
    end
    return false
end

local function GetFloorPart(char, hrp)
    local rp = RaycastParams.new()
    rp.FilterType = Enum.RaycastFilterType.Exclude
    rp.FilterDescendantsInstances = {char}
    local hit = workspace:Raycast(hrp.Position, Vector3.new(0, -12, 0), rp)
    if hit then return hit.Instance end
    return nil
end

local function IsFloorBelow(part, feetY)
    local topY = part.Position.Y + part.Size.Y * 0.5
    return topY <= feetY + 0.5
end

local function ApplyGhostThrough()
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local floorPart = GetFloorPart(char, hrp)
    local feetY = hrp.Position.Y - hrp.Size.Y * 0.5
    local boxSize = Vector3.new(hrp.Size.X + 6, hrp.Size.Y + 4, hrp.Size.Z + 6)
    local boxCF = hrp.CFrame
    local parts = nil
    pcall(function()
        parts = workspace:GetPartBoundsInBox(boxCF, boxSize)
    end)
    if not parts then return end
    for _, part in ipairs(parts) do
        if (part:IsA("BasePart")
            and part.CanCollide
            and not part:IsDescendantOf(char)
            and not IsCharacterPart(part)
            and part ~= floorPart
            and not IsFloorBelow(part, feetY)) then
            pcall(function()
                ghostOrigCollide[part] = part.CanCollide
                part.CanCollide = false
            end)
        end
    end
end

local function SetCharCollide(state)
    local char = LocalPlayer.Character
    if not char then return end
    for _, d in ipairs(char:GetDescendants()) do
        if d:IsA("BasePart") then
            pcall(function() d.CanCollide = state end)
        end
    end
end

local ghostRayParams = RaycastParams.new()
ghostRayParams.FilterType = Enum.RaycastFilterType.Exclude
ghostRayParams.FilterDescendantsInstances = {LocalPlayer.Character}
local ghostBoost = 0

-- 本体非实体：穿透 Terrain 地形和一切物理阻挡；移动改为 CFrame 驱动，贴地不下坠
local function ApplySelfGhost(dt)
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hrp then return end
    for _, d in ipairs(char:GetDescendants()) do
        if d:IsA("BasePart") and d.CanCollide then
            pcall(function() d.CanCollide = false end)
        end
    end
    ghostRayParams.FilterDescendantsInstances = {char}
    -- 位移完全交给 Humanoid 自己的 WalkSpeed：
    -- 之前是「物理行走 + CFrame 位移」两套同时作用，等于双倍速度，这才是加速的真正原因
    local hit = workspace:Raycast(hrp.Position, Vector3.new(0, -10, 0), ghostRayParams)
    if hit then
        local targetY = hit.Position.Y + 2.2
        -- 只有真的掉到地面高度以下才被接住：上升/跳跃过程中完全不影响，
        -- 所以跳跃高度还是原本的 JumpPower 决定的数值
        if hrp.Position.Y < targetY then
            pcall(function()
                hrp.CFrame = hrp.CFrame + Vector3.new(0, targetY - hrp.Position.Y, 0)
                local v = hrp.AssemblyLinearVelocity
                hrp.AssemblyLinearVelocity = Vector3.new(v.X, 0, v.Z)
            end)
        end
    end
end

local function CleanGhostTable()
    for part, orig in pairs(ghostOrigCollide) do
        if not part.Parent then
            ghostOrigCollide[part] = nil
        end
    end
end



--===== OtherTab：踏空行走 =====
local airWalkOn = false
local airWalkConn = nil
local airWalkJumpConn = nil
local airWalkPlat = nil
local airWalkPlatChar = nil

local function RemoveAirWalkPlatform()
    if airWalkPlat then
        pcall(function() airWalkPlat:Destroy() end)
    end
    airWalkPlat = nil
    airWalkPlatChar = nil
end

local function SpawnAirWalkPlatform(hrp)
    local p = Instance.new("Part")
    p.Name = "AirWalkPlatform"
    p.Size = Vector3.new(14, 0.25, 14)
    p.Anchored = true
    p.CanCollide = true
    p.CanQuery = false
    p.CanTouch = false
    p.CastShadow = false
    p.Transparency = 1
    p.TopSurface = Enum.SurfaceType.Smooth
    p.BottomSurface = Enum.SurfaceType.Smooth
    p.CFrame = CFrame.new(hrp.Position.X, hrp.Position.Y - 3.35, hrp.Position.Z)
    p.Parent = workspace
    return p
end

-- 在脚下生成透明可碰的水平平台，人是真的站在实体上：
-- 状态自然是 Running、正立行走、跳跃正常，不靠改速度/重力，也不会抖
local function ApplyAirWalk(dt)
    local char = LocalPlayer.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not (hum and hrp) then return end
    -- 每次起跳后，等跳到最高点（垂直速度由正转负）时，才在脚下生成平台
    local st = hum:GetState()
    local airborne = (st == Enum.HumanoidStateType.Jumping or st == Enum.HumanoidStateType.Freefall)
    local wasAir = char:GetAttribute("xzhAirWasAir")
    local velY = hrp.AssemblyLinearVelocity.Y
    local apexDone = char:GetAttribute("xzhAirApex")
    if airborne and not wasAir then
        char:SetAttribute("xzhAirApex", false)
    elseif airborne and velY > 2 then
        char:SetAttribute("xzhAirApex", false)
    end
    if airborne and velY <= 0.5 and (not apexDone) then
        RemoveAirWalkPlatform()
        airWalkPlat = SpawnAirWalkPlatform(hrp)
        airWalkPlatChar = char
        char:SetAttribute("xzhAirApex", true)
    end
    char:SetAttribute("xzhAirWasAir", airborne)
    if (not airWalkPlat) or (not airWalkPlat.Parent) or airWalkPlatChar ~= char then
        airWalkPlat = nil
        airWalkPlatChar = nil
        return
    end
    local pos = hrp.Position
    local platPos = airWalkPlat.Position
    local dx = pos.X - platPos.X
    local dz = pos.Z - platPos.Z
    local dist2 = dx * dx + dz * dz
    local platTop = platPos.Y + airWalkPlat.Size.Y * 0.5
    local feetY = pos.Y - 2.9
    if dist2 > 10000 then
        RemoveAirWalkPlatform()
        airWalkPlat = SpawnAirWalkPlatform(hrp)
        airWalkPlatChar = char
    else
        -- 高度只在“跳跃那一刻”重新生成（见 JumpRequest），这里只做水平跟随，
        -- 保证空中平移时脚下一直有东西可踩
        if dist2 > 9 then
            pcall(function()
                airWalkPlat.CFrame = CFrame.new(pos.X, platPos.Y, pos.Z)
            end)
        end
    end
end



--===== OtherTab：反虚空 =====
local antiVoidOn = false
local antiVoidConn = nil
local antiVoidSafe = nil
local antiVoidLimit = -400
local antiVoidAcc = 0

-- 每 0.2 秒记录一次“能稳定站立”的位置（脚下有地面、不在高速移动）
local function RecordAntiVoidSafe()
    local char = LocalPlayer.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not (hum and hrp) then return end
    if hum.Health <= 0 then return end
    if hum.FloorMaterial == Enum.Material.Air then return end
    if hrp.AssemblyLinearVelocity.Magnitude > 80 then return end
    antiVoidSafe = hrp.CFrame
end

local function CheckAntiVoid()
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    if hrp.Position.Y < antiVoidLimit and antiVoidSafe then
        pcall(function()
            hrp.CFrame = antiVoidSafe + Vector3.new(0, 2, 0)
            hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
            hrp.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
        end)
        print("✅ 检测到掉入虚空，已拉回最近安全点")
    end
end



--===== OtherTab：飞行（外置倍速面板，主UI关闭后仍可用） =====
local flyOn = false
local flyConn = nil
local flyBaseSpeed = 60
local flyMult = 1
local flyStep = 0.5
local flyUpHeld = false
local flyDownHeld = false
local flyActive = false
local flyBV = nil

local function ClearFlyBV()
    if flyBV then
        pcall(function() flyBV:Destroy() end)
    end
    flyBV = nil
end

local flyLockedParts = nil
local flyLockedChar = nil
local flyControls = nil
local flyLastPos = nil

local function InitFlyControls()
    if flyControls then return end
    pcall(function()
        local pm = LocalPlayer.PlayerScripts:FindFirstChild("PlayerModule")
        if pm then
            flyControls = require(pm):GetControls()
        end
    end)
end

local function UnlockCharacter()
    if flyLockedParts then
        for _, e in ipairs(flyLockedParts) do
            local p = e.part
            if p and p.Parent then
                pcall(function() p.Anchored = e.anchored end)
            end
        end
    end
    flyLockedParts = nil
    local ch = flyLockedChar
    flyLockedChar = nil
    local hum = ch and ch:FindFirstChildOfClass("Humanoid")
    if hum then
        pcall(function()
            hum.PlatformStand = false
            hum.AutoRotate = true
            hum:ChangeState(Enum.HumanoidStateType.Running)
        end)
    end
end

-- 全身冻结：所有部件锁定成刚性整体，不受重力、碰撞推力、动画影响
local function LockCharacter(char, hrp)
    UnlockCharacter()
    flyLockedParts = {}
    flyLockedChar = char
    local root = hrp.CFrame
    for _, p in ipairs(char:GetDescendants()) do
        if p:IsA("BasePart") then
            local off = root:ToObjectSpace(p.CFrame)
            table.insert(flyLockedParts, { part = p, anchored = p.Anchored, offset = off })
            pcall(function() p.Anchored = true end)
        end
    end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then
        pcall(function()
            hum.AutoRotate = false
            hum.PlatformStand = true
            hum:ChangeState(Enum.HumanoidStateType.Physics)
        end)
    end
end
local flyGui = nil
local flyPanel = nil
local flyLabel = nil
local flyConns = {}

local function UpdateFlyLabel()
    if flyLabel then
        flyLabel.Text = "飞行速度 " .. string.format("%.1f", flyMult) .. "x"
    end
end

local function DestroyFlyGui()
    for _, c in ipairs(flyConns) do
        pcall(function() c:Disconnect() end)
    end
    flyConns = {}
    if flyGui then
        pcall(function() flyGui:Destroy() end)
    end
    flyGui = nil
    flyPanel = nil
    flyLabel = nil
    flyUpHeld = false
    flyDownHeld = false
end

local function MakeFlyBtn(parent, text, x, y, w, h, color)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(0, w, 0, h)
    b.Position = UDim2.new(0, x, 0, y)
    b.BackgroundColor3 = color
    b.BorderSizePixel = 0
    b.Text = text
    b.TextColor3 = Color3.new(1, 1, 1)
    b.Font = Enum.Font.GothamBold
    b.TextSize = 16
    b.AutoLocalize = false
    b.Parent = parent
    local cr = Instance.new("UICorner")
    cr.CornerRadius = UDim.new(0, 8)
    cr.Parent = b
    return b
end

local function BuildFlyGui()
    if flyGui then return end
    local gui = Instance.new("ScreenGui")
    gui.Name = "FlyPanelGui"
    gui.ResetOnSpawn = false
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    gui.IgnoreGuiInset = true
    gui.Parent = LocalPlayer.PlayerGui
    flyGui = gui

    local flySide = "right"
    local vp0 = workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize or Vector2.new(800, 600)
    local panPos = Vector2.new(math.max(4, math.floor(vp0.X - 226)), math.max(4, math.floor(vp0.Y * 0.25)))
    local miniPos = Vector2.new(math.max(4, math.floor(vp0.X - 112)), math.max(4, math.floor(vp0.Y * 0.25)))
    local panel = Instance.new("Frame")
    panel.Size = UDim2.new(0, 210, 0, 128)
    panel.Position = UDim2.fromOffset(panPos.X, panPos.Y)
    panel.BackgroundColor3 = Color3.new(0.09, 0.09, 0.11)
    panel.BackgroundTransparency = 0.15
    panel.BorderSizePixel = 0
    panel.ClipsDescendants = true
    panel.Parent = gui
    local pc = Instance.new("UICorner")
    pc.CornerRadius = UDim.new(0, 10)
    pc.Parent = panel
    local ps = Instance.new("UIStroke")
    ps.Color = Color3.new(0.22, 0.55, 0.96)
    ps.Thickness = 1.6
    ps.Transparency = 0.3
    ps.Parent = panel
    flyPanel = panel

    local label = Instance.new("TextButton")
    label.Size = UDim2.new(1, -40, 0, 30)
    label.Position = UDim2.new(0, 8, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = "飞行速度 1.0x"
    label.TextColor3 = Color3.new(0.94, 0.96, 1)
    label.Font = Enum.Font.GothamBold
    label.TextSize = 15
    label.AutoLocalize = false
    label.Parent = panel
    flyLabel = label

    local minBtn = MakeFlyBtn(panel, "－", 0, 0, 32, 28, Color3.new(0.18, 0.18, 0.22))
    minBtn.Position = UDim2.new(1, -36, 0, 1)
    minBtn.TextSize = 18

    local miniBtn = Instance.new("TextButton")
    miniBtn.Size = UDim2.fromOffset(96, 44)
    miniBtn.Position = UDim2.fromOffset(miniPos.X, miniPos.Y)
    miniBtn.BackgroundColor3 = Color3.new(0.10, 0.10, 0.14)
    miniBtn.BackgroundTransparency = 0.05
    miniBtn.BorderSizePixel = 0
    miniBtn.Text = "展开"
    miniBtn.TextColor3 = Color3.fromRGB(150, 200, 255)
    miniBtn.Font = Enum.Font.GothamBold
    miniBtn.TextSize = 15
    miniBtn.Visible = false
    miniBtn.Parent = gui
    local mc = Instance.new("UICorner")
    mc.CornerRadius = UDim.new(0, 12)
    mc.Parent = miniBtn
    local ms = Instance.new("UIStroke")
    ms.Color = Color3.new(0.22, 0.55, 0.96)
    ms.Thickness = 1.4
    ms.Transparency = 0.25
    ms.Parent = miniBtn

    local function FlyVp()
        local vp = workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize or Vector2.new(800, 600)
        return vp
    end
    local function FlySideX(x, w, vp)
        if flySide == "left" then
            return math.clamp(x, 4, math.max(4, vp.X * 0.5 - w - 4))
        else
            local minX = math.max(4, vp.X * 0.5)
            local maxX = math.max(minX, vp.X - w - 4)
            return math.clamp(x, minX, maxX)
        end
    end
    local function FlyPickSide(cx, vp)
        if cx < vp.X * 0.5 then
            flySide = "left"
        else
            flySide = "right"
        end
    end
    minBtn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            local vp = FlyVp()
            miniPos = Vector2.new(FlySideX(panPos.X + 114, 96, vp), math.clamp(panPos.Y + 2, 0, vp.Y - 48))
            miniBtn.Position = UDim2.fromOffset(miniPos.X, miniPos.Y)
            panel.Visible = false
            miniBtn.Visible = true
        end
    end)
    local miniDrag = false
    local miniStart = nil
    local miniStartPos = nil
    local miniMoved = false
    local miniTouch = nil
    miniBtn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            miniDrag = true
            miniMoved = false
            miniTouch = input
            miniStart = input.Position
            miniStartPos = miniPos
        end
    end)
    table.insert(flyConns, UserInputService.InputChanged:Connect(function(input)
        if not miniDrag then return end
        if miniTouch and input ~= miniTouch and input.UserInputType ~= Enum.UserInputType.MouseMovement then return end
        if (input.UserInputType == Enum.UserInputType.Touch) or (input.UserInputType == Enum.UserInputType.MouseMovement) then
            local d = input.Position - miniStart
            if math.abs(d.X) > 8 or math.abs(d.Y) > 8 then miniMoved = true end
            local vp = FlyVp()
            miniPos = Vector2.new(math.clamp(miniStartPos.X + d.X, 4, vp.X - 100), math.clamp(miniStartPos.Y + d.Y, 0, vp.Y - 48))
            miniBtn.Position = UDim2.fromOffset(miniPos.X, miniPos.Y)
        end
    end))
    table.insert(flyConns, UserInputService.InputEnded:Connect(function(input)
        if not miniDrag then return end
        if miniTouch and input ~= miniTouch and input.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
        if (input.UserInputType == Enum.UserInputType.Touch) or (input.UserInputType == Enum.UserInputType.MouseButton1) then
            miniDrag = false
            miniTouch = nil
            if miniBtn.Visible then
                local vp = FlyVp()
                FlyPickSide(miniPos.X + 48, vp)
            end
            if not miniMoved and miniBtn.Visible then
                local vp = FlyVp()
                panPos = Vector2.new(FlySideX(miniPos.X - 114, 210, vp), math.clamp(miniPos.Y - 2, 0, vp.Y - 132))
                panel.Position = UDim2.fromOffset(panPos.X, panPos.Y)
                panel.Visible = true
                miniBtn.Visible = false
            end
        end
    end))

    local minusBtn = MakeFlyBtn(panel, "-", 8, 36, 56, 36, Color3.new(0.62, 0.2, 0.22))
    local plusBtn = MakeFlyBtn(panel, "+", 146, 36, 56, 36, Color3.new(0.18, 0.58, 0.32))
    local powerBtn = MakeFlyBtn(panel, "开启", 70, 36, 70, 36, Color3.new(0.16, 0.5, 0.32))
    powerBtn.TextSize = 15
    local upBtn = MakeFlyBtn(panel, "上升", 8, 80, 96, 38, Color3.new(0.18, 0.45, 0.75))
    local downBtn = MakeFlyBtn(panel, "下降", 106, 80, 96, 38, Color3.new(0.35, 0.35, 0.4))

    local function isTouchInput(input)
        return input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1
    end

    local function StepMult(delta)
        flyMult = math.clamp(flyMult + delta, 0.5, 50)
        flyMult = math.floor(flyMult * 10 + 0.5) / 10
        UpdateFlyLabel()
    end
    local function BindHold(btn, delta)
        local holding = false
        btn.InputBegan:Connect(function(input)
            if not isTouchInput(input) then return end
            holding = true
            StepMult(delta)
            task.spawn(function()
                task.wait(0.25)
                while holding do
                    StepMult(delta)
                    task.wait(0.05)
                end
            end)
        end)
        btn.InputEnded:Connect(function() holding = false end)
        btn.MouseLeave:Connect(function() holding = false end)
    end
    BindHold(minusBtn, -0.5)
    BindHold(plusBtn, 0.5)
    upBtn.InputBegan:Connect(function(input)
        if isTouchInput(input) then flyUpHeld = true end
    end)
    upBtn.InputEnded:Connect(function()
        flyUpHeld = false
    end)
    downBtn.InputBegan:Connect(function(input)
        if isTouchInput(input) then flyDownHeld = true end
    end)
    downBtn.InputEnded:Connect(function()
        flyDownHeld = false
    end)
    local function SetFlyActive(v)
        flyActive = v
        if v then
            powerBtn.Text = "停止"
            powerBtn.BackgroundColor3 = Color3.new(0.68, 0.22, 0.24)
            InitFlyControls()
            flyLastPos = nil
            local ch = LocalPlayer.Character
            local hrp = ch and ch:FindFirstChild("HumanoidRootPart")
            if ch and hrp then
                pcall(function() LockCharacter(ch, hrp) end)
            end
            print("✅ 开始飞行，全身已冻结")
        else
            powerBtn.Text = "开启"
            powerBtn.BackgroundColor3 = Color3.new(0.16, 0.5, 0.32)
            ClearFlyBV()
            UnlockCharacter()
            flyLastPos = nil
            print("🛑 已停止飞行，全身恢复")
        end
    end
    FlyPanelStop = function()
        if flyActive then
            pcall(function() SetFlyActive(false) end)
        end
    end
    powerBtn.InputBegan:Connect(function(input)
        if isTouchInput(input) then
            SetFlyActive(not flyActive)
        end
    end)

    -- 拖标题条移动整个面板
    local dragging = false
    local dragStart = nil
    local startPos = nil
    local dragTouch = nil
    table.insert(flyConns, label.InputBegan:Connect(function(input)
        if isTouchInput(input) then
            dragging = true
            dragTouch = input
            dragStart = input.Position
            startPos = panPos
        end
    end))
    table.insert(flyConns, UserInputService.InputChanged:Connect(function(input)
        if not dragging then return end
        if dragTouch and input ~= dragTouch and input.UserInputType ~= Enum.UserInputType.MouseMovement then return end
        if (input.UserInputType == Enum.UserInputType.Touch) or (input.UserInputType == Enum.UserInputType.MouseMovement) then
            local d = input.Position - dragStart
            local vp = FlyVp()
            panPos = Vector2.new(math.clamp(startPos.X + d.X, 4, vp.X - 214), math.clamp(startPos.Y + d.Y, 4, vp.Y - 132))
            panel.Position = UDim2.fromOffset(panPos.X, panPos.Y)
        end
    end))
    table.insert(flyConns, UserInputService.InputEnded:Connect(function(input)
        if not dragging then return end
        if dragTouch and input ~= dragTouch and input.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
        dragging = false
        dragTouch = nil
        local vp = FlyVp()
        FlyPickSide(panPos.X + 105, vp)
        panPos = Vector2.new(FlySideX(panPos.X, 210, vp), panPos.Y)
        panel.Position = UDim2.fromOffset(panPos.X, panPos.Y)
    end))
end

local function FlyStep(dt)
    if not (flyOn and flyActive) then return end
    local char = LocalPlayer.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local cam = workspace.CurrentCamera
    if not (hum and hrp and cam) then return end
    if (not flyLockedParts) or flyLockedChar ~= char then
        pcall(function() LockCharacter(char, hrp) end)
        if not flyLockedParts then return end
    end
    local speed = flyBaseSpeed * flyMult
    local look = cam.CFrame.LookVector
    local right = cam.CFrame.RightVector
    local horizLook = Vector3.new(look.X, 0, look.Z)
    if horizLook.Magnitude < 0.01 then
        horizLook = Vector3.new(0, 0, -1)
    end
    horizLook = horizLook.Unit
    local mv = nil
    if flyControls then
        local ok, v = pcall(function() return flyControls:GetMoveVector() end)
        if ok and typeof(v) == "Vector3" then
            mv = v
        end
    end
    local dir
    if mv and mv.Magnitude > 0.01 then
        dir = cam.CFrame:VectorToWorldSpace(mv)
    else
        local move = hum.MoveDirection
        local fwd = move:Dot(horizLook)
        local side = move:Dot(right)
        dir = look * fwd + right * side
    end
    if dir.Magnitude > 1 then
        dir = dir.Unit
    end
    local step = dir * (speed * dt)
    if flyUpHeld then
        step = step + Vector3.new(0, speed * dt, 0)
    end
    if flyDownHeld then
        step = step - Vector3.new(0, speed * dt, 0)
    end

    -- 分轴射线检测：撞到实体就停在表面，不穿透物体
    local pos = hrp.CFrame.Position
    local radius = 0.75
    local function clampAxis(v)
        if v.Magnitude < 0.0001 then return v end
        local params = RaycastParams.new()
        params.FilterType = Enum.RaycastFilterType.Exclude
        params.FilterDescendantsInstances = { char }
        params.IgnoreWater = true
        local hit = workspace:Raycast(pos, v.Unit * (v.Magnitude + radius), params)
        if hit and hit.Instance and hit.Instance.CanCollide then
            local allowed = math.max(0, hit.Distance - radius)
            return v.Unit * allowed
        end
        return v
    end
    local mx = clampAxis(Vector3.new(step.X, 0, 0))
    local mz = clampAxis(Vector3.new(0, 0, step.Z))
    local my = clampAxis(Vector3.new(0, step.Y, 0))
    local newPos = pos + mx + mz + my

    -- 朝向跟随视角水平方向，四肢姿势保持冻结
    local base = CFrame.lookAt(newPos, newPos + horizLook)
    if flyLastPos then
        pcall(function()
            cam.CFrame = cam.CFrame + (newPos - flyLastPos)
        end)
    end
    flyLastPos = newPos
    pcall(function()
        hrp.CFrame = base
        for _, e in ipairs(flyLockedParts) do
            local p = e.part
            if p and p.Parent and p ~= hrp then
                p.CFrame = base * e.offset
            end
        end
    end)
end



--===== OtherTab：强制第一人称 / 第三人称（每 0.2 秒钉一次，游戏改也拨回来） =====
;(function()
camForce = nil -- nil / "first" / "third"
firstToggle = nil
thirdToggle = nil
local oldMinZoom = nil
local oldMaxZoom = nil
pcall(function()
    oldMinZoom = LocalPlayer.CameraMinZoomDistance
    oldMaxZoom = LocalPlayer.CameraMaxZoomDistance
end)

TurnOff = function(tg)
    if not tg then return end
    for _, n in ipairs({"Set","SetValue","SetState","Update"}) do
        local m = nil
        pcall(function() m = tg[n] end)
        if type(m) == "function" then
            if pcall(function() m(tg, false) end) then return end
        end
    end
    pcall(function() tg.Value = false end)
end





task.spawn(function()
    local lastMode = nil
    while true do
        task.wait(0.2)
        local mode = camForce
        if mode == "first" then
            pcall(function() LocalPlayer.CameraMode = Enum.CameraMode.LockFirstPerson end)
        elseif mode == "third" then
            pcall(function() LocalPlayer.CameraMode = Enum.CameraMode.Classic end)
            pcall(function() LocalPlayer.CameraMinZoomDistance = 12 end)
            pcall(function() LocalPlayer.CameraMaxZoomDistance = 128 end)
        elseif lastMode ~= nil then
            pcall(function() LocalPlayer.CameraMode = Enum.CameraMode.Classic end)
            if oldMinZoom then pcall(function() LocalPlayer.CameraMinZoomDistance = oldMinZoom end) end
            if oldMaxZoom then pcall(function() LocalPlayer.CameraMaxZoomDistance = oldMaxZoom end) end
        end
        lastMode = mode
    end
end)
end)()

--===== OtherTab：查看其他玩家背包（横版自适应面板，长按任意位置可拖） =====
;(function()
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local bagGui = nil
local bagToggleRef = nil
local function ForceToggleOff(tg)
    if not tg then return end
    for _, n in ipairs({"Set","SetValue","SetState","Update"}) do
        local m = nil
        pcall(function() m = tg[n] end)
        if type(m) == "function" then
            if pcall(function() m(tg, false) end) then return end
            if pcall(function() m(false) end) then return end
        end
    end
    pcall(function() tg.Value = false end)
end
local bagPanel = nil
local bagPlayerScroll = nil
local bagPlayerContent = nil
local bagItemScroll = nil
local bagItemContent = nil
local bagRightTitle = nil
local bagPanelRef = nil
local bagRows = {}
local bagOpen = false
local bagLoopThread = nil
local bagMinimized = false
local bagPage = "players"
local bagFullH = 300
local bagMiniBtn = nil
local bagSavedPos = nil

local function GetParentGui()
    local parent = nil
    pcall(function()
        if gethui then parent = gethui() end
    end)
    if parent then return parent end
    return LocalPlayer:FindFirstChildOfClass("PlayerGui") or LocalPlayer:WaitForChild("PlayerGui")
end

local function GetName(plr)
    local char = plr.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hum and hum.DisplayName and hum.DisplayName ~= "" then return hum.DisplayName end
    if plr.DisplayName and plr.DisplayName ~= "" then return plr.DisplayName end
    return plr.Name
end

local BAG_DICT = {
    ["sword"]="剑", ["blade"]="刀", ["knife"]="小刀", ["dagger"]="匕首", ["axe"]="斧", ["hammer"]="锤",
    ["spear"]="长矛", ["lance"]="骑枪", ["bow"]="弓", ["arrow"]="箭", ["staff"]="法杖", ["wand"]="魔杖",
    ["gun"]="枪", ["pistol"]="手枪", ["rifle"]="步枪", ["shotgun"]="霰弹枪", ["sniper"]="狙击枪",
    ["smg"]="冲锋枪", ["minigun"]="转轮机枪", ["launcher"]="发射器", ["rocket"]="火箭", ["grenade"]="手榴弹",
    ["bomb"]="炸弹", ["mine"]="地雷", ["cannon"]="大炮", ["turret"]="炮塔", ["bowgun"]="弩",
    ["shield"]="盾", ["armor"]="护甲", ["helmet"]="头盔", ["boots"]="靴子", ["gloves"]="手套",
    ["cloak"]="披风", ["cape"]="斗篷", ["mask"]="面具", ["crown"]="王冠", ["ring"]="戒指",
    ["amulet"]="护符", ["necklace"]="项链", ["bag"]="背包", ["backpack"]="背包", ["crate"]="木箱",
    ["box"]="箱子", ["chest"]="宝箱", ["key"]="钥匙", ["coin"]="硬币", ["gem"]="宝石",
    ["crystal"]="水晶", ["diamond"]="钻石", ["gold"]="黄金", ["silver"]="白银", ["iron"]="铁",
    ["wood"]="木头", ["stone"]="石头", ["steel"]="钢", ["bronze"]="青铜", ["emerald"]="翡翠",
    ["ruby"]="红宝石", ["sapphire"]="蓝宝石", ["pearl"]="珍珠", ["potion"]="药水", ["elixir"]="灵药",
    ["scroll"]="卷轴", ["book"]="书", ["tome"]="古籍", ["map"]="地图", ["totem"]="图腾",
    ["rune"]="符文", ["orb"]="宝珠", ["soul"]="灵魂", ["heart"]="心脏", ["skull"]="骷髅",
    ["bone"]="骨头", ["fang"]="獠牙", ["claw"]="利爪", ["scale"]="鳞片", ["horn"]="角",
    ["wing"]="翅膀", ["feather"]="羽毛", ["tail"]="尾巴", ["eye"]="眼睛", ["fang"]="獠牙",
    ["fire"]="火焰", ["flame"]="烈焰", ["ice"]="冰霜", ["frost"]="霜冻", ["snow"]="雪",
    ["lightning"]="雷电", ["thunder"]="雷鸣", ["storm"]="风暴", ["poison"]="毒", ["toxic"]="剧毒",
    ["magic"]="魔法", ["arcane"]="奥术", ["holy"]="神圣", ["dark"]="暗黑", ["shadow"]="暗影",
    ["light"]="光", ["void"]="虚空", ["energy"]="能量", ["plasma"]="等离子", ["laser"]="激光",
    ["plasma"]="等离子", ["gravity"]="重力", ["time"]="时间", ["space"]="空间", ["wind"]="风",
    ["earth"]="大地", ["water"]="水", ["aqua"]="水", ["nature"]="自然", ["life"]="生命",
    ["death"]="死亡", ["blood"]="血", ["spirit"]="精灵", ["ghost"]="幽灵", ["zombie"]="僵尸",
    ["demon"]="恶魔", ["devil"]="魔鬼", ["angel"]="天使", ["god"]="神", ["divine"]="神域",
    ["dragon"]="龙", ["tiger"]="虎", ["wolf"]="狼", ["bear"]="熊", ["lion"]="狮",
    ["cat"]="猫", ["dog"]="狗", ["fox"]="狐", ["snake"]="蛇", ["phoenix"]="凤凰",
    ["bird"]="鸟", ["fish"]="鱼", ["shark"]="鲨鱼", ["rabbit"]="兔", ["monkey"]="猴",
    ["king"]="国王", ["queen"]="女王", ["knight"]="骑士", ["paladin"]="圣骑士", ["mage"]="法师",
    ["wizard"]="巫师", ["archer"]="弓箭手", ["warrior"]="战士", ["rogue"]="盗贼", ["assassin"]="刺客",
    ["ninja"]="忍者", ["samurai"]="武士", ["ranger"]="游侠", ["priest"]="祭司", ["summoner"]="召唤师",
    ["tool"]="工具", ["hammer"]="锤", ["pickaxe"]="镐", ["shovel"]="铲", ["hoe"]="锄",
    ["fishing"]="钓鱼", ["rod"]="竿", ["net"]="网", ["rope"]="绳", ["trap"]="陷阱",
    ["torch"]="火把", ["lantern"]="提灯", ["candle"]="蜡烛", ["flare"]="信号弹", ["lamp"]="灯",
    ["food"]="食物", ["bread"]="面包", ["apple"]="苹果", ["meat"]="肉", ["cake"]="蛋糕",
    ["candy"]="糖果", ["coffee"]="咖啡", ["tea"]="茶", ["milk"]="牛奶", ["juice"]="果汁",
    ["medkit"]="医疗包", ["bandage"]="绷带", ["syringe"]="注射器", ["pill"]="药丸", ["drug"]="药剂",
    ["speed"]="速度", ["jump"]="跳跃", ["fly"]="飞行", ["flight"]="飞行", ["invisible"]="隐身",
    ["invisibility"]="隐身", ["freeze"]="冰冻", ["shield"]="盾", ["heal"]="治疗", ["revive"]="复活",
    ["gift"]="礼物", ["present"]="礼物", ["ticket"]="票券", ["token"]="代币", ["badge"]="徽章",
    ["trophy"]="奖杯", ["medal"]="奖牌", ["star"]="星星", ["moon"]="月亮", ["sun"]="太阳",
    ["sky"]="天空", ["cloud"]="云", ["rain"]="雨", ["sand"]="沙", ["lava"]="岩浆",
    ["snowball"]="雪球", ["brick"]="砖", ["ball"]="球", ["dice"]="骰子", ["card"]="卡牌",
    ["phone"]="手机", ["radio"]="无线电", ["camera"]="相机", ["tv"]="电视", ["clock"]="钟表",
    ["toy"]="玩具", ["robot"]="机器人", ["drone"]="无人机", ["jet"]="喷气机", ["plane"]="飞机",
    ["car"]="汽车", ["boat"]="船", ["bike"]="自行车", ["tank"]="坦克", ["bus"]="巴士"
}

local function BagLookupWord(lw)
    local function hit(k) return BAG_DICT[k] end
    if hit(lw) then return hit(lw) end
    if #lw > 3 and lw:sub(#lw) == "s" then
        local sing = lw:sub(1, #lw - 1)
        if hit(sing) then return hit(sing) end
        if #sing > 2 and sing:sub(#sing) == "e" then
            local sing2 = sing:sub(1, #sing - 1)
            if hit(sing2) then return hit(sing2) end
        end
    end
    if #lw > 3 and lw:sub(#lw-1) == "es" then
        local sing = lw:sub(1, #lw - 2)
        if hit(sing) then return hit(sing) end
    end
    return nil
end

local function TranslateToolName(raw)
    if not raw or raw == "" then return raw end
    local lower = string.lower(raw)
    if BAG_DICT[lower] then return BAG_DICT[lower] end
    local pieces = {}
    local changed = false
    for w in string.gmatch(raw, "[%a%d]+") do
        local lw = string.lower(w)
        local cn = BagLookupWord(lw)
        if cn then
            table.insert(pieces, cn)
            changed = true
        else
            table.insert(pieces, w)
        end
    end
    if changed then
        return table.concat(pieces)
    end
    return raw
end



local function ClearItemRows()
    if not bagItemContent then return end
    for _, c in ipairs(bagItemContent:GetChildren()) do
        if c:IsA("TextLabel") or c:IsA("Frame") then
            pcall(function() c:Destroy() end)
        end
    end
end

local function GetToolImage(tool)
    if not tool then return nil end
    local function ok(v)
        return type(v) == "string" and v ~= ""
    end
    local v = nil
    pcall(function() v = tool.TextureId end)
    if ok(v) then return v end
    for _, k in ipairs({"Icon","Image","ImageId","Texture","TextureId","IconId","ImageUrl"}) do
        local attr = nil
        pcall(function() attr = tool:GetAttribute(k) end)
        if ok(attr) then
            if attr:match("^rbxassetid://") or attr:match("^rbxasset://") or attr:match("^http") or attr:match("^rbxthumb") then
                return attr
            end
            if tonumber(attr) then return "rbxassetid://" .. attr end
        end
    end
    local found = nil
    pcall(function()
        for _, d in ipairs(tool:GetDescendants()) do
            if d:IsA("ImageLabel") and ok(d.Image) then found = d.Image break end
            if d:IsA("ImageButton") and ok(d.Image) then found = d.Image break end
            if d:IsA("Decal") and ok(d.Texture) then found = d.Texture break end
            if d:IsA("Texture") and ok(d.Texture) then found = d.Texture break end
        end
    end)
    return found
end

local function GiveToolToSelf(tool)
    if not tool then return false end
    local bag = LocalPlayer:FindFirstChildOfClass("Backpack")
    if not bag then
        warn("❌ 找不到自己的背包")
        return false
    end
    local copy = nil
    pcall(function() copy = tool:Clone() end)
    if not copy then
        warn("❌ 复制物品失败（该物品可能不允许克隆）")
        return false
    end
    local base = tool.Name
    local n = 1
    for _, c in ipairs(bag:GetChildren()) do
        if c.Name == base then n = n + 1 end
    end
    if n > 1 then copy.Name = base .. " #" .. tostring(n) end
    copy.Parent = bag
    print("✅ 已获得物品：" .. copy.Name .. "（本地副本，已放进你的背包）")
    return true
end

local function ShowItems(plr)
    if not bagItemScroll then return end
    bagPage = "items"
    -- 左右分栏：玩家列表始终保留，才能连续点不同玩家
    if bagPlayerScroll and not bagMinimized then bagPlayerScroll.Visible = true end
    if bagItemScroll and not bagMinimized then bagItemScroll.Visible = true end
    if bagRightTitle then bagRightTitle.Text = GetName(plr) .. " 的背包" end
    ClearItemRows()

    local counts = {}
    local order = {}
    local samples = {}
    local function addTool(t)
        local n = t.Name
        if counts[n] == nil then
            counts[n] = 0
            samples[n] = t
            table.insert(order, n)
        end
        counts[n] = counts[n] + 1
    end
    local bp = plr:FindFirstChildOfClass("Backpack")
    if bp then
        for _, t in ipairs(bp:GetChildren()) do
            if t:IsA("Tool") then addTool(t) end
        end
    end
    local char = plr.Character
    if char then
        for _, t in ipairs(char:GetChildren()) do
            if t:IsA("Tool") then addTool(t) end
        end
    end

    if #order == 0 then
        local hint = Instance.new("TextLabel")
        hint.Size = UDim2.new(1,0,0,40)
        hint.BackgroundTransparency = 1
        hint.Text = "（背包为空，或这游戏不公开背包内容）"
        hint.TextColor3 = Color3.fromRGB(160,160,170)
        hint.TextSize = 13
        hint.Font = Enum.Font.Gotham
        hint.Parent = bagItemContent
        return
    end

    for i, name in ipairs(order) do
        local row = Instance.new("Frame")
        row.Size = UDim2.new(1,-8,0,46)
        row.BackgroundColor3 = Color3.fromRGB(0.15,0.15,0.19)
        row.BorderSizePixel = 0
        row.LayoutOrder = i
        row.Parent = bagItemContent

        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0,6)
        corner.Parent = row

        local cnName = TranslateToolName(name)
        local imgSrc = GetToolImage(samples[name])

        local icon = Instance.new("ImageLabel")
        icon.Size = UDim2.new(0,36,0,36)
        icon.Position = UDim2.new(0,5,0,5)
        icon.BackgroundColor3 = Color3.fromRGB(0.10,0.10,0.14)
        icon.BorderSizePixel = 0
        icon.Image = imgSrc or ""
        icon.ScaleType = Enum.ScaleType.Fit
        icon.Parent = row
        local icc = Instance.new("UICorner")
        icc.CornerRadius = UDim.new(0,6)
        icc.Parent = icon
        local stroke = Instance.new("UIStroke")
        stroke.Color = Color3.fromRGB(120,90,180)
        stroke.Thickness = 1
        stroke.Parent = icon

        if not imgSrc then
            -- 没图就显示首字，避免一片空
            local first = Instance.new("TextLabel")
            first.Size = UDim2.new(1,0,1,0)
            first.BackgroundTransparency = 1
            first.Text = string.sub(cnName, 1, 1)
            first.TextColor3 = Color3.fromRGB(200,170,255)
            first.TextSize = 16
            first.Font = Enum.Font.GothamBold
            first.Parent = icon
        end

        local nm = Instance.new("TextLabel")
        nm.Size = UDim2.new(1,-166,1,0)
        nm.Position = UDim2.new(0,48,0,0)
        nm.BackgroundTransparency = 1
        nm.Text = cnName
        nm.TextColor3 = Color3.new(1,1,1)
        nm.TextSize = 14
        nm.Font = Enum.Font.Gotham
        nm.TextXAlignment = Enum.TextXAlignment.Left
        nm.TextTruncate = Enum.TextTruncate.AtEnd
        nm.Parent = row

        local cnt = Instance.new("TextLabel")
        cnt.Size = UDim2.new(0,34,1,0)
        cnt.Position = UDim2.new(1,-108,0,0)
        cnt.BackgroundTransparency = 1
        cnt.Text = "x" .. tostring(counts[name])
        cnt.TextColor3 = Color3.fromRGB(190,140,255)
        cnt.TextSize = 13
        cnt.Font = Enum.Font.GothamBold
        cnt.Parent = row

        local getBtn = Instance.new("TextButton")
        getBtn.Size = UDim2.new(0,54,0,26)
        getBtn.Position = UDim2.new(1,-64,0.5,-13)
        getBtn.BackgroundColor3 = Color3.fromRGB(0.30,0.20,0.48)
        getBtn.Text = "获得"
        getBtn.TextColor3 = Color3.fromRGB(225,205,255)
        getBtn.TextSize = 13
        getBtn.Font = Enum.Font.GothamBold
        getBtn.AutoButtonColor = false
        getBtn.Parent = row
        local gc = Instance.new("UICorner")
        gc.CornerRadius = UDim.new(0,6)
        gc.Parent = getBtn
        local gs = Instance.new("UIStroke")
        gs.Color = Color3.fromRGB(150,105,235)
        gs.Thickness = 1
        gs.Parent = getBtn

        local baseColor = getBtn.BackgroundColor3
        getBtn.MouseButton1Down:Connect(function()
            getBtn.BackgroundColor3 = Color3.fromRGB(0.52,0.34,0.78)
            getBtn.Text = "获得中…"
        end)
        getBtn.MouseButton1Up:Connect(function()
            getBtn.BackgroundColor3 = baseColor
        end)
        getBtn.MouseButton1Click:Connect(function()
            local okk, err = pcall(GiveToolToSelf, samples[name])
            if not okk then
                warn("❌ 获得物品失败：" .. tostring(err))
                getBtn.Text = "获得"
                return
            end
            getBtn.BackgroundColor3 = Color3.fromRGB(0.18,0.62,0.34)
            getBtn.Text = "已获得 ✓"
            task.delay(0.9, function()
                pcall(function()
                    getBtn.BackgroundColor3 = baseColor
                    getBtn.Text = "获得"
                end)
            end)
            if bagPanelRef then
                local fx = Instance.new("TextLabel")
                fx.Size = UDim2.new(0,90,0,26)
                fx.BackgroundTransparency = 1
                fx.Text = "获得 +1"
                fx.TextColor3 = Color3.fromRGB(130,255,175)
                fx.TextSize = 15
                fx.Font = Enum.Font.GothamBold
                fx.TextXAlignment = Enum.TextXAlignment.Center
                local wp = getBtn.AbsolutePosition
                local panelAbs = bagPanelRef.AbsolutePosition
                fx.Position = UDim2.new(0, wp.X - panelAbs.X - 18, 0, wp.Y - panelAbs.Y - 4)
                fx.ZIndex = 6
                fx.Parent = bagPanelRef
                local tween = TweenService:Create(fx, TweenInfo.new(0.7, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                    Position = UDim2.new(0, wp.X - panelAbs.X - 18, 0, wp.Y - panelAbs.Y - 40),
                    TextTransparency = 1
                })
                tween:Play()
                task.delay(0.8, function()
                    pcall(function() fx:Destroy() end)
                end)
            end
        end)
    end
end

local function CreateRow(plr)
    local row = Instance.new("TextButton")
    row.Size = UDim2.new(1,-8,0,44)
    row.BackgroundColor3 = Color3.fromRGB(0.16,0.16,0.20)
    row.AutoButtonColor = false
    row.Text = ""
    row.BorderSizePixel = 0
    row.Parent = bagPlayerContent

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0,6)
    corner.Parent = row

    local img = Instance.new("ImageLabel")
    img.Size = UDim2.new(0,36,0,36)
    img.Position = UDim2.new(0,6,0,4)
    img.BackgroundColor3 = Color3.fromRGB(0.10,0.10,0.12)
    img.Image = "rbxthumb://type=AvatarHeadShot&id=" .. tostring(plr.UserId) .. "&w=150&h=150"
    img.Parent = row
    local ic = Instance.new("UICorner")
    ic.CornerRadius = UDim.new(0,6)
    ic.Parent = img

    local nm = Instance.new("TextLabel")
    nm.Size = UDim2.new(1,-56,1,0)
    nm.Position = UDim2.new(0,50,0,0)
    nm.BackgroundTransparency = 1
    nm.Text = GetName(plr) .. "  (" .. plr.Name .. ")"
    nm.TextColor3 = Color3.new(1,1,1)
    nm.TextSize = 14
    nm.Font = Enum.Font.Gotham
    nm.TextXAlignment = Enum.TextXAlignment.Left
    nm.TextTruncate = Enum.TextTruncate.AtEnd
    nm.Parent = row

    local isFr = false
    pcall(function()
        isFr = GetFriendSetCached()[plr.UserId] and true or false
    end)
    row:SetAttribute("isFriend", isFr)
    if isFr then
        row.BackgroundColor3 = Color3.fromRGB(0.22,0.18,0.30)
        nm.Text = "★ " .. GetName(plr) .. "  (" .. plr.Name .. ")"
        nm.TextColor3 = Color3.fromRGB(255,214,110)
        local fs = Instance.new("UIStroke")
        fs.Color = Color3.fromRGB(255,200,90)
        fs.Thickness = 1
        fs.Parent = row
    end

    row.MouseButton1Click:Connect(function()
        local ok, err = pcall(ShowItems, plr)
        if not ok then warn("❌ 读取背包失败：" .. tostring(err)) end
    end)
    return row
end

local function RefreshPlayers()
    if not bagPlayerScroll then return end
    local list = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then table.insert(list, p) end
    end
    local friendSet = {}
    pcall(function() friendSet = GetFriendSetCached() or {} end)
    table.sort(list, function(a,b)
        local fa = (friendSet[a.UserId] and 1) or 0
        local fb = (friendSet[b.UserId] and 1) or 0
        if fa ~= fb then return fa > fb end
        return GetName(a):lower() < GetName(b):lower()
    end)

    local alive = {}
    for i, plr in ipairs(list) do
        alive[plr.UserId] = true
        local nowFr = (friendSet[plr.UserId] and true) or false
        local row = bagRows[plr.UserId]
        if row and row.Parent and row:GetAttribute("isFriend") ~= nowFr then
            pcall(function() row:Destroy() end)
            row = nil
            bagRows[plr.UserId] = nil
        end
        if not row or not row.Parent then
            row = CreateRow(plr)
            bagRows[plr.UserId] = row
        end
        row.LayoutOrder = i
    end
    for uid, row in pairs(bagRows) do
        if not alive[uid] then
            pcall(function() row:Destroy() end)
            bagRows[uid] = nil
        end
    end
end

local function DestroyBagGui()
    bagOpen = false
    bagLoopThread = nil
    if bagGui then
        pcall(function() bagGui:Destroy() end)
        bagGui = nil
    end
    bagPanel = nil
    bagPlayerScroll = nil
    bagPlayerContent = nil
    bagItemScroll = nil
    bagItemContent = nil
    bagRightTitle = nil
    bagPanelRef = nil
    bagMiniBtn = nil
    bagSavedPos = nil
    bagMinimized = false
    bagPage = "players"
    bagRows = {}
end

local function BuildBagGui()
    if bagGui and bagGui.Parent then return end
    local vp = workspace.CurrentCamera.ViewportSize
    local W = math.clamp(vp.X * 0.8, 320, 900)
    -- 一行 44 + 间距 4 = 48，6 行 288；再加标题栏 46 和上下留白 16
    local H = math.clamp(vp.Y * 0.58, 350, 460)
    bagFullH = H

    bagGui = Instance.new("ScreenGui")
    bagGui.Name = "WindBagViewer"
    bagGui.ResetOnSpawn = false
    bagGui.IgnoreGuiInset = true
    bagGui.DisplayOrder = 45
    bagGui.Enabled = true
    bagGui.Parent = GetParentGui()
    pcall(function() BindTree(bagGui) end)

    local panel = Instance.new("Frame")
    panel.Size = UDim2.fromOffset(W, H)
    panel.Position = UDim2.new(0.5,0,0.5,0)
    panel.AnchorPoint = Vector2.new(0.5,0.5)
    panel.BackgroundColor3 = Color3.fromRGB(0.09,0.09,0.12)
    panel.BackgroundTransparency = 0.05
    panel.BorderSizePixel = 0
    panel.ClipsDescendants = true
    panel.Parent = bagGui
    bagPanel = panel
    bagPanelRef = panel
    local pc = Instance.new("UICorner")
    pc.CornerRadius = UDim.new(0,18)
    pc.Parent = panel
    local ps = Instance.new("UIStroke")
    ps.Color = Color3.fromRGB(150,105,235)
    ps.Thickness = 2
    ps.Parent = panel

    -- 标题栏：整条作为拖动柄（手机上按住就能拖）
    local header = Instance.new("Frame")
    header.Size = UDim2.new(1,-12,0,40)
    header.Position = UDim2.new(0,6,0,5)
    header.BackgroundColor3 = Color3.fromRGB(0.12,0.12,0.17)
    header.BackgroundTransparency = 0.25
    header.BorderSizePixel = 0
    header.Parent = panel
    local hc = Instance.new("UICorner")
    hc.CornerRadius = UDim.new(0,10)
    hc.Parent = header

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1,-100,1,0)
    title.Position = UDim2.new(0,12,0,0)
    title.BackgroundTransparency = 1
    title.Text = "玩家背包"
    title.TextColor3 = Color3.fromRGB(205,175,255)
    title.TextSize = 16
    title.Font = Enum.Font.GothamBold
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = header

    local minBtn = Instance.new("TextButton")
    minBtn.Size = UDim2.new(0,32,0,32)
    minBtn.Position = UDim2.new(1,-78,0,5)
    minBtn.BackgroundColor3 = Color3.fromRGB(0.20,0.20,0.28)
    minBtn.Text = "—"
    minBtn.TextColor3 = Color3.new(1,1,1)
    minBtn.TextSize = 18
    minBtn.Font = Enum.Font.GothamBold
    minBtn.AutoButtonColor = false
    minBtn.ZIndex = 3
    minBtn.Parent = header
    local m1 = Instance.new("UICorner")
    m1.CornerRadius = UDim.new(0,8)
    m1.Parent = minBtn

    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0,32,0,32)
    closeBtn.Position = UDim2.new(1,-44,0,5)
    closeBtn.BackgroundColor3 = Color3.fromRGB(0.72,0.24,0.28)
    closeBtn.Text = "×"
    closeBtn.TextColor3 = Color3.new(1,1,1)
    closeBtn.TextSize = 18
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.AutoButtonColor = false
    closeBtn.ZIndex = 3
    closeBtn.Parent = header
    local c1 = Instance.new("UICorner")
    c1.CornerRadius = UDim.new(0,8)
    c1.Parent = closeBtn

    local pad = 22
    local listH = H - 46 - pad * 2
    if listH < 60 then listH = 60 end
    local leftW = math.floor((W - pad * 3) * 0.42)
    local rightW = W - pad * 3 - leftW

    local listFrame = Instance.new("ScrollingFrame")
    listFrame.Size = UDim2.fromOffset(leftW, listH)
    listFrame.Position = UDim2.fromOffset(pad, 46 + pad)
    listFrame.BackgroundColor3 = Color3.fromRGB(0.07,0.07,0.10)
    listFrame.BackgroundTransparency = 0.4
    listFrame.BorderSizePixel = 0
    listFrame.ScrollBarThickness = 6
    listFrame.ScrollingDirection = Enum.ScrollingDirection.Y
    listFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
    listFrame.CanvasSize = UDim2.new(0,0,0,0)
    listFrame.ClipsDescendants = true
    listFrame.Parent = panel
    bagPlayerScroll = listFrame
    local lc = Instance.new("UICorner")
    lc.CornerRadius = UDim.new(0,8)
    lc.Parent = listFrame
    local pContent = Instance.new("Frame")
    pContent.Size = UDim2.new(1,0,0,0)
    pContent.BackgroundTransparency = 1
    pContent.AutomaticSize = Enum.AutomaticSize.Y
    pContent.Parent = listFrame
    bagPlayerContent = pContent
    local pl = Instance.new("UIListLayout")
    pl.Padding = UDim.new(0,4)
    pl.SortOrder = Enum.SortOrder.LayoutOrder
    pl.Parent = pContent

    local rightTitle = Instance.new("TextLabel")
    rightTitle.Size = UDim2.fromOffset(rightW, 24)
    rightTitle.Position = UDim2.fromOffset(pad * 2 + leftW, 46 + pad)
    rightTitle.BackgroundTransparency = 1
    rightTitle.Text = "点击左侧玩家查看背包"
    rightTitle.TextColor3 = Color3.fromRGB(170,150,200)
    rightTitle.TextSize = 13
    rightTitle.Font = Enum.Font.Gotham
    rightTitle.TextXAlignment = Enum.TextXAlignment.Left
    rightTitle.TextTruncate = Enum.TextTruncate.AtEnd
    rightTitle.Parent = panel
    bagRightTitle = rightTitle

    local itemH = listH - 30
    if itemH < 40 then itemH = 40 end
    local itemFrame = Instance.new("ScrollingFrame")
    itemFrame.Size = UDim2.fromOffset(rightW, itemH)
    itemFrame.Position = UDim2.fromOffset(pad * 2 + leftW, 46 + pad + 30)
    itemFrame.BackgroundTransparency = 1
    itemFrame.BorderSizePixel = 0
    itemFrame.ScrollBarThickness = 6
    itemFrame.ScrollingDirection = Enum.ScrollingDirection.Y
    itemFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
    itemFrame.CanvasSize = UDim2.new(0,0,0,0)
    itemFrame.ClipsDescendants = true
    itemFrame.Parent = panel
    bagItemScroll = itemFrame
    local iContent = Instance.new("Frame")
    iContent.Size = UDim2.new(1,0,0,0)
    iContent.BackgroundTransparency = 1
    iContent.AutomaticSize = Enum.AutomaticSize.Y
    iContent.Parent = itemFrame
    bagItemContent = iContent
    local il = Instance.new("UIListLayout")
    il.Padding = UDim.new(0,4)
    il.SortOrder = Enum.SortOrder.LayoutOrder
    il.Parent = iContent

    -- 拖动：标题栏和四条边框都能按住拖
    local dragging = false
    local dragStart = nil
    local startPos = nil
    local dragTouch = nil
    local function BeginDrag(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragTouch = input
            dragStart = input.Position
            startPos = panel.Position
        end
    end
    local function AttachDrag(obj)
        obj.InputBegan:Connect(BeginDrag)
    end
    -- 移动统一走全局 InputChanged：不管手指滑到哪里都跟得上，比 GuiObject.InputChanged 灵敏
    UIS.InputChanged:Connect(function(input)
        if not dragging or not bagPanel then return end
        if dragTouch and input ~= dragTouch and input.UserInputType ~= Enum.UserInputType.MouseMovement then return end
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement then
            local d = input.Position - dragStart
            bagPanel.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
        end
    end)
    UIS.InputEnded:Connect(function(input)
        if not dragging then return end
        if dragTouch and input ~= dragTouch and input.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
            dragTouch = nil
        end
    end)

    AttachDrag(header)
    AttachDrag(panel)

    local edge = 12
    local edgeDefs = {
        {Size = UDim2.new(1,0,0,edge), Pos = UDim2.new(0,0,0,0)},
        {Size = UDim2.new(1,0,0,edge), Pos = UDim2.new(0,0,1,-edge)},
        {Size = UDim2.new(0,edge,1,0), Pos = UDim2.new(0,0,0,0)},
        {Size = UDim2.new(0,edge,1,0), Pos = UDim2.new(1,-edge,0,0)},
    }
    for _, def in ipairs(edgeDefs) do
        local strip = Instance.new("TextButton")
        strip.Size = def.Size
        strip.Position = def.Pos
        strip.BackgroundTransparency = 1
        strip.Text = ""
        strip.AutoButtonColor = false
        strip.ZIndex = 2
        strip.Parent = panel
        AttachDrag(strip)
    end

    closeBtn.MouseButton1Click:Connect(function()
        DestroyBagGui()
        pcall(ForceToggleOff, bagToggleRef)
        print("🛑 玩家背包面板已关闭")
    end)
    -- 最小化后的小方框：只显示两个字「展开」
    local miniBtn = Instance.new("TextButton")
    miniBtn.Size = UDim2.fromOffset(96, 44)
    miniBtn.BackgroundColor3 = Color3.fromRGB(0.10,0.10,0.14)
    miniBtn.BackgroundTransparency = 0.05
    miniBtn.Text = "展开"
    miniBtn.TextColor3 = Color3.fromRGB(205,175,255)
    miniBtn.TextSize = 15
    miniBtn.Font = Enum.Font.GothamBold
    miniBtn.AutoButtonColor = false
    miniBtn.Visible = false
    miniBtn.ZIndex = 5
    miniBtn.AnchorPoint = Vector2.new(1,0)
    miniBtn.Position = UDim2.new(1,-16,0,60)
    miniBtn.Parent = bagGui
    bagMiniBtn = miniBtn
    local mc = Instance.new("UICorner")
    mc.CornerRadius = UDim.new(0,12)
    mc.Parent = miniBtn
    local ms = Instance.new("UIStroke")
    ms.Color = Color3.fromRGB(150,105,235)
    ms.Thickness = 2
    ms.Parent = miniBtn

    minBtn.MouseButton1Click:Connect(function()
        if not bagPanel then return end
        bagMinimized = true
        bagSavedPos = bagPanel.Position
        miniBtn.Visible = true
        bagPanel.Visible = false
    end)

    miniBtn.MouseButton1Click:Connect(function()
        if not bagPanel then return end
        bagMinimized = false
        if bagSavedPos then bagPanel.Position = bagSavedPos end
        bagPanel.Visible = true
        miniBtn.Visible = false
        if bagPlayerScroll then bagPlayerScroll.Visible = true end
        if bagItemScroll then bagItemScroll.Visible = true end
        if bagRightTitle then bagRightTitle.Visible = true end
    end)

    local ok, err = pcall(RefreshPlayers)
    if not ok then warn("❌ 玩家列表首次填充失败：" .. tostring(err)) end
    print("✅ 玩家列表已填充，其他玩家数：" .. tostring(#Players:GetPlayers()-1))
end

local function OpenBag()
    bagOpen = true
    BuildBagGui()
    if bagLoopThread then return end
    bagLoopThread = task.spawn(function()
        while bagOpen do
            task.wait(0.4)
            if not bagOpen then break end
            local ok, err = pcall(RefreshPlayers)
            if not ok then warn("❌ 玩家背包列表刷新出错：" .. tostring(err)) end
        end
    end)
end

bagToggleRef = OtherTab:Toggle({
    Title = "查看玩家背包",
    Default = false,
    Callback = function(state)
        if state then
            OpenBag()
            print("✅ 玩家背包面板已打开，点击玩家头像查看其背包")
        else
            DestroyBagGui()
            print("🛑 玩家背包面板已关闭")
        end
        pcall(function() TipState("查看玩家背包", state) end)
    end
})

-- 主 UI 真正关掉后才收起：必须"先确实看到过主 UI 打开"，再连续 2 秒判定关闭才动手。
-- 这样主 UI 状态读不到时不会误判，点屏幕也绝不会把面板弄没。
task.spawn(function()
    local seenOpen = false
    local closedTicks = 0
    while true do
        task.wait(0.25)
        local isOpen = false
        pcall(function()
            local sg = windUiRoot and windUiRoot:FindFirstAncestorOfClass("ScreenGui")
            if sg and sg.Parent and sg.Enabled == true then isOpen = true end
        end)
        if isOpen then
            seenOpen = true
            closedTicks = 0
        elseif seenOpen then
            closedTicks = closedTicks + 1
            if closedTicks >= 8 then
                closedTicks = 0
                seenOpen = false
                if bagGui and bagGui.Parent then
                    pcall(DestroyBagGui)
                    print("🛑 主 UI 已关闭，玩家背包面板自动收起")
                end
                pcall(ForceToggleOff, bagToggleRef)
            end
        end
    end
end)
end)()

--===== OtherTab：Roblox物品面板 =====
-- 本段整体包进立即执行函数，避免主代码块 local 变量超过 Lua 上限(200)
;(function()
local TweenService = game:GetService("TweenService")
local UIS = game:GetService("UserInputService")
local shopGui = nil
local shopToggleRef = nil
local function ShopForceToggleOff(tg)
    if not tg then return end
    for _, n in ipairs({"Set","SetValue","SetState","Update"}) do
        local m = nil
        pcall(function() m = tg[n] end)
        if type(m) == "function" then
            if pcall(function() m(tg, false) end) then return end
            if pcall(function() m(false) end) then return end
        end
    end
    pcall(function() tg.Value = false end)
end
local shopPanel = nil
local shopScroll = nil
local shopMinimized = false
local shopConns = {}
local SHOP_PANEL_SIZE = UDim2.new(0, 300, 0, 330)
local PHOTO_W, PHOTO_H = 26, 14

local PHOTO_TESLA = "040A0E060A0E050A0D050C1108101609121A07111908131A08131B09131B08131B0E1A2315222B0F1D291628371627341828351F32442139501D31441A2C3D13212F0E1A2409141E06121F03111F071015060C10070E13060F15050E140710150812180A151C0B161E0A161E0B17200F1C26111C2715212D1A283619304818375B254B754E647E25374F192738121E2D13263C1D3857213D5C345D830A1318070E120A131A0812180913190A141B0A13190C141B0B12180A131B0B141E0B1A2A0B2C42113B5A365D7D3A5B8573A0D380BAE46497C486838D7A74786B7E9C6296C95C8CBC4D76A334567B0A131A0B141C0C161E0B151C151E25101E291022310D2A3E12406015405E1C5F793D92A66CB7C8A3DED7C1D9CCC8E4E3C9E3DBAFC8C0CFEFF9FFFCE1DFD2CB8E9CBA45628723406022354A0F1F300D17200710170811170E1821152431152330122B422B546E93BAA8C3D5A08DB08E9FB072AE954BAA914EBCAA69A8B5997C958D82988EB9E1F2A5A7B65D6176363A4735363B101D2D1B293714233111181E1B242B101A230E192317222E1F436A5990AF9CC2BFADC2B17B91786B624C66686978837E849994B0AB7C9F9E8C65737F6899B08CCDF450688F243750212C3A192330111C290A162208131D24303E33455A2E445A2F465B49779577C0DF82B8BF9ED5CD9DBAA883885E8584643E55621B2E3D42403264512872756B626E731F4A743E6B9831486815253714212E121E2A0D17210B151E08131A385F7D45779F4F7EA0528BB3579DCD7AB9D68482733440447F7544B6953B4A595B22333B1B2B3622364C1D324B5D66653F4B52182F49172A3F12233513212D101B260C17210A151D08121907101732587735526D4456683C50673D50672948695A68766B5A44C0B45D5B563C545F6C8F959350585B5A5D5D5354523C404315253617273713202D101C290E1A250D18230B16200A141C09121A080F153B414A2A35403343553C4E632B364235465D897B6FB9A861F7F174947F3A6A6152515F6F4F5D6E32404E2334451B2C3D1A28371623310E19230D18220C161E0A141B0913190A1015090F140910163A3B3A222B3227384B3244583A5068656F7CA29672B8B97973612F201F205C5E5F3C5169364A612D3E512D3F51203040213141203141162330131F290C161D0B13190B11160E14180F14180A0E0F121D2817222D1C2935222F3B33465D617B9261756C83733D59431E36424F465D7835485B2F40522838482738492A3C4F30435828394C1C2A39182330131D28101A240C161F0D161C0D141A080E13131C22131C22151D25202C382C3C4C36516E3C546D5D5E5C8068475055592E415423303C1D2A361C28351D293621303F2736481E2B39131E28101A230F19210D161E0B141B0C13180C13170A1217101A21101A21121C2419232B232E372835412E3E4E3C4A5949525C3948572635431C273117212A151E26151E27151E2717212A162029131C240F191F0D171C0D171D0912191B212625292C202427"
local PHOTO_FROST = "02080E01050A040C16050E19020913030A14030B15040F1B05101C06101D081523091828081627081626091A2C0A1B2E08172908182A07152505101D05111E040F1D05101E020B16030B1502091200040D020A13030A14020810030B15030C16030C17030E19040E1A05111D08152308162608162507162708182905152505121F0512200716260A1C32030E1E05101E040F1A0613210009160310202F475C0A182807111F020811030A14040C16030B17030E19050F1A0714210C1A2A0D1B2C0B18260512210817260F1F330F264310274107111F213E623059840D1523091524051426203E59436E8F1E32450D1E300A1A2B040F1A030C17040F1A05111E06121E0412220312251021361D334D1328411C34510922410D284B0F2B5324538E152B52626F7DA5CEEF4A4E5F0F213C0E1E34273F562039520515270918281B304A0B1A2A0915220D1A28101D2D132B4C273B53545C5E46525B4651592B425E4A78A472A5CA5F99C63B6185405B814F7FB29DC2DCEAFAFCE2F1FB97C0E871787F615F543E454915314F12263E3A587B294261091D371230542B5481366499798383A0A9A391A5B09BABAC8C949872889F9AA6A893A6B6BFC1BA97A7A85B97CA88BCE6C6E4F6ABBCCE47658C1B2C450D1C2E0E20340B21391228443D66934A81B45381A37698B46C98B97D8FA06E84B96FA8D88CD7F781A2BC5984AA2C73B62E6095335D8D3D66934288C74291CC567CA39897A15D54530713290B18290A19290C1D2E2137501B324D335983A8B0A9AAAA9D656B732E40593F68904560894F6F9961A8D571C3ED4F81B11C406B17365C0A264A10315B163963122A4813243F242B3B1C25330C1B2E0917270B1B2D0E21353F5D7F44617E4569926B7B875C6B780526531A3C662B619A708A9B43637F2E60915CD6FA5CA1C6133057112D4A122B461328410A1D340D2540091C3006182B06172805121F08172606132105101D395879506F8D4D6C8A2E4E73425B7A294666163355436280496B8D133559112E5548A9D280DBFF37506D0C27450F25400C2341091C3903143001112903122907162A0511200B192907142207121E3B5E8250759A5180A9517CA75780A92D4D721D39593961813E64841C3D6114304F2049733F79A921486F1544731B5B911E6DA517629419618A1B5E8417547C0F4369082F5107213C09192B0B1A2B46678C45688D547CA46F99C36E99C36991BA557BA337587E2F537B375E88355B8426486D254A74275381295C8E2E71AB388AC53D9CD945B3EB49C0F644B1E73AACE5238AC7114F84112A470E20364B6D9254779C6489B078A1CB83AED786B1DB86B3DF7EABD782AFDD8CB8E594C0EA8CB5DE8DB6DE82A8D16A8CB55D7DA56381A9506B92405B833757822B4C7725456E203C611B324F1B3553203C5D2238522A415B3E5B7C4564874564874260823A57783C5A7D3D5A7D3B5575405C7D456182476283425C7C364E6C2A415C263B541F31461E30431D2D4018293B1422330D1B2C1F2E3F283B50263F59"
local PHOTO_GREN = "05060A06080B090A110A0B150B0E190E1221101528191D35212644282E532E325E3E3178A490E0CCAFFB583F8F2E2D572327481A203A13172B1011210E0E1A0C0C17090A1008090D08080B06070707090B080A0E0A0B140C0C170D101B11142313182C1A1F38222644272B502D2F55473876A891DCC7A4EF553E7F302E5226264A28244E211D4116182C1415270E0D190D0C120B0A0F09090C090909090B0D0A0C120B0C160D0E180F111C151625181A2E1F203820223D292848302D53433371B69AE0CFA6ED6E5190433261342A572D25483D346A272B51141220100F1A110F150D0C100A0A0D0A0A0A0A0C0F0B0C140C0E160F111B11131E1818281C1B2D26203A3D2F5F413567473A6B8965B4E2C9F4F5DAFFA17ED66B5397362E582927474B5892282C5316132014121B1110170F0E130D0C100B0C0D0C0E150D0F170E111910131E1816222720312E243E4F3772583D815C45887061B29A7AC4CAA7CCD3B0CED2B2C5A184BD5344814D5C96464F82231C2E1A1723221C291B17221C16142D21170B0B0A0C0C120D0E140E0F1615131C17131C281D2C7356746E49924630624F437A8785D3AE90D6AB8B976C4D67886366AB89AA9D8ED46F69A6442E59433149211A26191621141117110C0C110C090A08050A0A0C0F0D100A090D1812191E141E22172238232D6E4A72A981A9AE8BB0BEB2F0C4B7E2B6A2A38464708D6C77B390ACD7C4EFCEACDB9E758B5C35423C232B2A1C1A160F0F100C0D0C0A0A070707090809140E0F110D111C131A22161E2F1A25865C5AC39884A677A38E64A5A39DDFC7C8D199858B715362AD95B0A69DDF8E88CE76507AD2A58DE1BB95562E314C342C180F0F1410130E0E120D0D110C0D1110101615141D2119202D212D5C3B64D1A693D8B29770466DA573C2C29AEDE7CB8DBCA1749B6E5FD9D9F3BEB6F27E5792986F6EEFCCADB38E7B43272F3223282B2024181318120F120D0C0F18171F1C1B23221F282B242F423440654E75886588C8A39DD8AFADD9B2C8F4D7F9EFD9ADB7855FC99B89F1ECFECFA2D5C2929FD2A7978E6769794F6F5D435B2D1F262E1F2536232030201C1B13163029313A3037483940544450614D5C755C6A9B7796A176A6BF91B4D6A6CBEAC8EFFEF1FFF7EEF5F9F2FAFBE8FFE3B6DFCA9DBDB386B298739D926B8468454857393A51353580543867422C3522202621293329323B303D4035484D40567C5F72967596B695C6CD9FC8D39DC1EAC1DDF4DCF2FEF7FAFCF3F7F0D2E4E1B8B9DAA7B0DFB2C8B188AEAE7E818358516B45426E473B915F4069432F36232025212932292E2825332D283839314347394A6F5057966B728E637EA57390B484B7C99EC2E4C9B9E5C6BEC38EB28A5D89936572A471618B5B49663F384B2E2E4C302D50322A7F5336714C2F3A271E1B191F1F1C2321202C2423302D2937362C3E815C59BB8670794E71855A96A686C6C2979FC8986EC5928AA878AE79609F71598D8D5E61AE754F6F46383A25263925233C251F835B3B7A593D3E312B"
local PHOTO_BLADE = "010615020918030A1A000F2B001D45070923241232733571190B2B0A143214305204132F030C1F040C1E030C231025420A112A0C0418682B632F12330C061A081E3F000B1F00010900020C0802110A1E4006102B020A2322222E423938151C32040B304B17592A113A0A17332C699B082951060F26070F25061F4229639509142B240A2B68185C120A1E020816050E241B14332E163639163D722D6A3A7EB21A639C09264F3C3634784E207B5F3E726751594F5A39265B07164202225510437F09153604112F09366C00143B0A0A203C10411F0828100D202915381E0E3155245855204F1C07211F0720042D5B128BD9094B870C2A553D33335C3F2B6B4D2C7D5A2FA68A656D6B7933578F2168B62067AC31578B3331534B3137321A39290A330C0B1D47174C471B4C0D0B200D081C03112B072B52071937030E2804366A0A5BA60330620026511122450C356C111D43442A1D936D39A98B628A828E6877B7537FC15B7FB2817078AE7A5C50333E260F34492054110B25130B230E0B2A251F502B1B4B122151050F2505112C06346625407F503875131F481641753D64A85D455B47262B77502BBC9068CB9F93A2869C8575AF5D77CF7C728E93666739174F2E1C3D140D2D5B2158943587B5479F8D307B25082F080E25060C1E061736162558342866243160385B9CB6A7B95E5F893B2F7C5C3569714D808F6294B18482C8969B9C78909B99C68D679658295528163D2312315A1A53EF5AC6FC6AD4691E5F1703210B081B0C10261120465D3B76B67FC8626AB63B6AB6A292ABB098926857756347874A3776513E89705485A57564C18384C8AB9DA3A5D0A05C78743E5E29122F5D2157852C76702E703514443E1B52070B2018274E4057986C5CA38D67AC54569C3556952D478353465F74627176677D726483725D8C9264C4875BA39A6162AA7A65B2A0A9AF867ECA776555355027274E1A0D2A15244D18315919355C222C572F3B6C535D9E4B5493222A5B282B5B181D4318204519234C1D1D44262C5D34315C34274C552B599959B07A4AA0946255A36C3BB89059D59B72A25A5335141D2411181108100C060C040206734386764587794D9185519A9F45935F306C162B56283B6C343D6F3539653136633134653430583B305A6A4362A4668ABA75A8CC8672BC7B35D2973CE69D77833D5053193C3A0D342B0A2A1F0924232E5F27356A233A6E884691E954B6473D7A1F54932F5596334178343F76373D744947835C5699645BA0695498775182935E7AC68397E59D9BF8C07CFEEC9DE8B2A4974571782E6A4F205329193F061938122954143361873880D33F9B362B5E1954911F47801D1F451F224825264F2E2B573A2B593C295A503168773F6DA7597BCC7772C06F5FE19860FECA77DE8F77B03872A0307667255E2C2045031F450A234C091E424E1C526C1E5B15163B0F66A51A4476140E2714112A141A3B1616372E1B414E2B6E7D419E9A4D9CBC5E878D4D57A06743CE8248B561437F2D35900F5BAF2774882765231D36"

local SHOP_ITEMS = {
    { name = "雷暴电手枪", shape = "tesla", photo = PHOTO_TESLA, imageId = 120324908226758 },
    { name = "霜龙连发步枪", shape = "frost", photo = PHOTO_FROST, imageId = 83041338461928 },
    { name = "紫电手雷", shape = "grenade", photo = PHOTO_GREN, imageId = 128830698576831 },
    { name = "金鳞龙刀", shape = "blade", photo = PHOTO_BLADE, imageId = 104542164269201 },
}

-- 预先缓存武器图，避免打开武器库后才开始下载
task.spawn(function()
    pcall(function()
        local cg = Instance.new("ScreenGui")
        cg.Name = "ShopImgPreload"
        cg.ResetOnSpawn = false
        cg.Parent = LocalPlayer.PlayerGui
        local list = {}
        for _, item in ipairs(SHOP_ITEMS) do
            if item.imageId then
                local t = Instance.new("ImageLabel")
                t.Size = UDim2.fromOffset(2, 2)
                t.Visible = false
                t.Image = "rbxthumb://type=Asset&id=" .. tostring(item.imageId) .. "&w=420&h=420"
                t.Parent = cg
                table.insert(list, t)
            end
        end
        pcall(function() game:GetService("ContentProvider"):PreloadAsync(list) end)
        pcall(function() cg:Destroy() end)
    end)
end)

local function NewPiece(tool, name, size, color, material)
    local p = Instance.new("Part")
    p.Name = name
    p.Size = size
    p.Color = color
    p.Material = material or Enum.Material.Metal
    p.CanCollide = false
    p.Massless = true
    p.CastShadow = false
    p.TopSurface = Enum.SurfaceType.Smooth
    p.BottomSurface = Enum.SurfaceType.Smooth
    p.Parent = tool
    return p
end

local function Weld(part, base)
    local w = Instance.new("WeldConstraint")
    w.Part0 = base
    w.Part1 = part
    w.Parent = part
end

local function Pick(tool, ...)
    for _, n in ipairs({ ... }) do
        local p = tool:FindFirstChild(n)
        if p then return p end
    end
    return nil
end

-- 球形闪光
local function Flash(pos, color, size, dur)
    local p = Instance.new("Part")
    p.Shape = Enum.PartType.Ball
    p.Size = Vector3.new(1, 1, 1) * size
    p.Color = color
    p.Material = Enum.Material.Neon
    p.Anchored = true
    p.CanCollide = false
    p.CanQuery = false
    p.CanTouch = false
    p.CastShadow = false
    p.CFrame = CFrame.new(pos)
    p.Parent = workspace
    TweenService:Create(p, TweenInfo.new(dur, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Size = p.Size * 2.8,
        Transparency = 1,
    }):Play()
    task.delay(dur + 0.03, function()
        pcall(function() p:Destroy() end)
    end)
end

-- 水平冲击环
local function RingWave(pos, color, fromSize, toSize, dur)
    local p = Instance.new("Part")
    p.Shape = Enum.PartType.Cylinder
    p.Size = Vector3.new(0.12, fromSize, fromSize)
    p.Color = color
    p.Material = Enum.Material.Neon
    p.Anchored = true
    p.CanCollide = false
    p.CanQuery = false
    p.CanTouch = false
    p.CastShadow = false
    p.Transparency = 0.05
    p.CFrame = CFrame.new(pos) * CFrame.Angles(0, 0, math.rad(90))
    p.Parent = workspace
    TweenService:Create(p, TweenInfo.new(dur, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Size = Vector3.new(0.12, toSize, toSize),
        Transparency = 1,
    }):Play()
    task.delay(dur + 0.03, function()
        pcall(function() p:Destroy() end)
    end)
end

-- 竖直光柱
local function LightPillar(pos, color, height, dur)
    local p = Instance.new("Part")
    p.Shape = Enum.PartType.Cylinder
    p.Size = Vector3.new(height, 0.55, 0.55)
    p.Color = color
    p.Material = Enum.Material.Neon
    p.Anchored = true
    p.CanCollide = false
    p.CanQuery = false
    p.CanTouch = false
    p.CastShadow = false
    p.Transparency = 0.15
    p.CFrame = CFrame.new(pos) * CFrame.Angles(0, math.rad(90), 0)
    p.Parent = workspace
    TweenService:Create(p, TweenInfo.new(dur, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Size = Vector3.new(height * 1.6, 2.2, 2.2),
        Transparency = 1,
    }):Play()
    task.delay(dur + 0.03, function()
        pcall(function() p:Destroy() end)
    end)
end

-- 粒子爆发
local function Burst(pos, color, count, speed, dir, texture, life)
    local holder = Instance.new("Part")
    holder.Size = Vector3.new(0.1, 0.1, 0.1)
    holder.Transparency = 1
    holder.Anchored = true
    holder.CanCollide = false
    holder.CanQuery = false
    holder.CanTouch = false
    holder.CFrame = CFrame.new(pos)
    holder.Parent = workspace
    local em = Instance.new("ParticleEmitter")
    em.Texture = texture or "rbxasset://textures/particles/sparkles_main.dds"
    em.Color = ColorSequence.new(color)
    em.Size = NumberSequence.new({ NumberSequenceKeypoint.new(0, 1.15), NumberSequenceKeypoint.new(1, 0) })
    em.Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.2), NumberSequenceKeypoint.new(1, 1) })
    em.Lifetime = NumberRange.new(0.2, (life or 0.45))
    em.Speed = NumberRange.new((speed or 12), (speed or 12) + 12)
    em.SpreadAngle = Vector2.new(180, 180)
    em.LightEmission = 1
    em.Rate = 0
    if dir then
        em.EmissionDirection = dir
        em.SpreadAngle = Vector2.new(12, 12)
    end
    em.Parent = holder
    em:Emit(count or 18)
    task.delay(1.2, function()
        pcall(function() holder:Destroy() end)
    end)
end

-- 本地音效池（挂相机=2D播放，连发不会堆积实例）
local function SoundPool(id, n, vol, pitch)
    local pool = {}
    local host = workspace.CurrentCamera or workspace
    for i = 1, n do
        local s = Instance.new("Sound")
        s.SoundId = id
        s.Volume = vol or 1
        s.PlaybackSpeed = pitch or 1
        s.Parent = host
        pool[i] = s
    end
    local idx = 0
    return function()
        idx = idx % #pool + 1
        local s = pool[idx]
        pcall(function()
            s.TimePosition = 0
            s:Play()
        end)
    end
end

-- 装备/收起通用特效：光柱 + 双环 + 上旋粒子
local function LifeFxAura(pos, color, mainColor)
    LightPillar(pos, color, 3.2, 0.42)
    RingWave(pos, color, 0.6, 4.2, 0.45)
    task.delay(0.1, function()
        pcall(function() RingWave(pos, mainColor, 0.4, 2.6, 0.4) end)
    end)
    Flash(pos, color, 0.9, 0.3)
    Burst(pos, color, 26, 10, Enum.NormalId.Top, nil, 0.6)
    task.delay(0.18, function()
        pcall(function() Burst(pos, mainColor, 16, 14, nil, nil, 0.4) end)
    end)
end

-- 武器常驻粒子（装备后持续，收起停止）
local function IdleFx(part, color, rate, speed, size)
    if not part then return nil end
    local em = Instance.new("ParticleEmitter")
    em.Texture = "rbxasset://textures/particles/sparkles_main.dds"
    em.Color = ColorSequence.new(color)
    em.Size = NumberSequence.new({ NumberSequenceKeypoint.new(0, size or 0.28), NumberSequenceKeypoint.new(1, 0) })
    em.Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.25), NumberSequenceKeypoint.new(1, 1) })
    em.Lifetime = NumberRange.new(0.35, 0.7)
    em.Speed = NumberRange.new((speed or 2), (speed or 2) + 2)
    em.SpreadAngle = Vector2.new(180, 180)
    em.EmissionDirection = Enum.NormalId.Top
    em.LightEmission = 1
    em.Rate = rate or 4
    em.Parent = part
    return em
end

-- 拖尾（刀/枪气流）
local function AddTrail(part, color, w, life)
    if not part then return end
    local a0 = Instance.new("Attachment")
    a0.Position = Vector3.new(0, part.Size.Y * 0.5, 0)
    a0.Parent = part
    local a1 = Instance.new("Attachment")
    a1.Position = Vector3.new(0, -part.Size.Y * 0.5, 0)
    a1.Parent = part
    local tr = Instance.new("Trail")
    tr.Attachment0 = a0
    tr.Attachment1 = a1
    tr.Color = ColorSequence.new(color)
    tr.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.1),
        NumberSequenceKeypoint.new(1, 1),
    })
    tr.Lifetime = life or 0.28
    tr.MinLength = 0.1
    tr.LightEmission = 1
    tr.WidthScale = NumberSequence.new({ NumberSequenceKeypoint.new(0, w or 1), NumberSequenceKeypoint.new(1, 0) })
    tr.Parent = part
    part.Transparency = part.Transparency
end

-- 通用装备/收起行为
local function BindToolFx(tool, auraColor, mainColor, idlePart, idleColor, idleRate)
    local idleEmitter = nil
    tool.Equipped:Connect(function()
        local h = tool:FindFirstChild("Handle")
        local pos = h and h.Position or nil
        if pos then
            LifeFxAura(pos, auraColor, mainColor)
        end
        if not idleEmitter then
            idleEmitter = IdleFx(idlePart or h, idleColor or mainColor, idleRate or 4, 2, 0.3)
        end
        print("✅ 已装备「" .. tool.Name .. "」")
    end)
    tool.Unequipped:Connect(function()
        local pos = nil
        local h = tool:FindFirstChild("Handle")
        if h then pos = h.Position end
        if idleEmitter then
            pcall(function() idleEmitter.Rate = 0 end)
        end
        if pos then
            RingWave(pos, auraColor, 3.4, 0.4, 0.38)
            LightPillar(pos, mainColor, 2.2, 0.3)
            Burst(pos, auraColor, 18, 8, Enum.NormalId.Bottom, nil, 0.5)
        end
    end)
end

-- 人物缩放：按角色体型等比放大武器
local function GetCharScale(char)
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local s = 1
    if hrp then
        s = hrp.Size.Y / 2
    end
    if hum then
        local ok, val = pcall(function() return hum.BodyHeightScale end)
        if ok and type(val) == "number" and val > 0 then
            s = math.max(s, val)
        end
    end
    return math.clamp(s, 0.8, 3)
end

local function ApplyToolScale(tool, scale)
    if not scale or scale <= 0 then return end
    local ok = pcall(function() tool:ScaleTo(scale) end)
    if ok then
        local g = tool.Grip
        tool.Grip = CFrame.new(g.Position * scale) * g.Rotation
        return
    end
    local h = tool:FindFirstChild("Handle")
    if not h then return end
    local bases = {}
    for _, p in ipairs(tool:GetChildren()) do
        if p:IsA("BasePart") then
            table.insert(bases, { p = p, rel = h.CFrame:ToObjectSpace(p.CFrame) })
        end
    end
    for _, it in ipairs(bases) do
        it.p.Size = it.p.Size * scale
        it.p.CFrame = h.CFrame * CFrame.new(it.rel.Position * scale) * it.rel.Rotation
    end
    local g = tool.Grip
    tool.Grip = CFrame.new(g.Position * scale) * g.Rotation
end

-- 记录手指/鼠标最后按在屏幕的位置
local lastPointerPos = nil
local function BindPointerTrack()
    UIS.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            lastPointerPos = Vector2.new(input.Position.X, input.Position.Y)
        end
    end)
    UIS.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement then
            lastPointerPos = Vector2.new(input.Position.X, input.Position.Y)
        end
    end)
end
BindPointerTrack()

local fpState = false
local fpMissCount = 0
local function IsFirstPerson()
    local char = LocalPlayer.Character
    local cam = workspace.CurrentCamera
    if not (char and cam) then return false end
    local head = char:FindFirstChild("Head")
    if not head then return false end
    local d = (cam.CFrame.Position - head.Position).Magnitude
    if d < 3.0 then
        fpState = true
        fpMissCount = 0
    elseif d > 5.0 then
        fpMissCount = fpMissCount + 1
        if fpMissCount > 12 then
            fpState = false
        end
    else
        fpMissCount = math.max(0, fpMissCount - 1)
    end
    return fpState
end

-- 点击点/准星对应的世界坐标
local function PointerWorldPoint()
    local cam = workspace.CurrentCamera
    if not cam then return nil end
    local vp = cam.ViewportSize
    local p = lastPointerPos or Vector2.new(vp.X * 0.5, vp.Y * 0.5)
    if IsFirstPerson() then p = Vector2.new(vp.X * 0.5, vp.Y * 0.5) end
    local ray = cam:ViewportPointToRay(p.X, p.Y, 0)
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    local char = LocalPlayer.Character
    params.FilterDescendantsInstances = char and { char } or {}
    local res = workspace:Raycast(ray.Origin, ray.Direction * 500, params)
    if res then return res.Position, res end
    return ray.Origin + ray.Direction * 90
end

-- 第一人称动态十字准星
local crossGui = nil
local crossHolder = nil
local crossLines = nil
local crossKick = 0
local crossEnabled = false
local function SetCrosshairEnabled(v) crossEnabled = v end
local crossT = 0
local crossSpin = 0
local crossTouch = nil
local crossHold = 0

local function EnsureCrosshair()
    if crossGui and crossGui.Parent then return end
    local gui = Instance.new("ScreenGui")
    gui.Name = "WindCrosshair"
    gui.ResetOnSpawn = false
    gui.IgnoreGuiInset = true
    gui.DisplayOrder = 50
    gui.Enabled = false
    gui.Parent = LocalPlayer.PlayerGui
    crossGui = gui

    local holder = Instance.new("Frame")
    holder.Size = UDim2.new(0, 120, 0, 120)
    holder.Position = UDim2.new(0.5, 0, 0.5, 0)
    holder.AnchorPoint = Vector2.new(0.5, 0.5)
    holder.BackgroundTransparency = 1
    holder.Parent = gui
    crossHolder = holder

    local lines = {}
    local cols = {
        Color3.fromRGB(120, 235, 255),
        Color3.fromRGB(120, 235, 255),
        Color3.fromRGB(120, 235, 255),
        Color3.fromRGB(120, 235, 255),
    }
    for i = 1, 4 do
        local f = Instance.new("Frame")
        f.Name = "Tick" .. i
        f.AnchorPoint = Vector2.new(0.5, 0.5)
        f.BorderSizePixel = 0
        f.BackgroundColor3 = cols[i]
        f.Parent = holder
        lines[i] = f
    end
    local dot = Instance.new("Frame")
    dot.Name = "Dot"
    dot.Size = UDim2.new(0, 2, 0, 2)
    dot.Position = UDim2.new(0.5, 0, 0.5, 0)
    dot.AnchorPoint = Vector2.new(0.5, 0.5)
    dot.BorderSizePixel = 0
    dot.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    dot.Parent = holder
    local dc = Instance.new("UICorner")
    dc.CornerRadius = UDim.new(0.5, 0)
    dc.Parent = dot
    lines[5] = dot
    crossLines = lines

    UIS.InputBegan:Connect(function(input, gp)
        if gp then return end
        if input.UserInputType ~= Enum.UserInputType.Touch then return end
        local vp = workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize or Vector2.new(1280, 720)
        local center = Vector2.new(vp.X * 0.5, vp.Y * 0.5)
        local p = Vector2.new(input.Position.X, input.Position.Y)
        if (p - center).Magnitude <= 80 then
            crossTouch = input
        end
    end)

    UIS.InputEnded:Connect(function(input)
        if input == crossTouch then
            crossTouch = nil
            crossHold = 0
            crossSpin = 0
        end
    end)

    RunService.RenderStepped:Connect(function(dt)
        if not (crossGui and crossGui.Parent) then return end
        local show = crossEnabled and IsFirstPerson()
        if crossGui.Enabled ~= show then
            crossGui.Enabled = show
        end
        if not show then return end
        crossT = crossT + dt
        crossKick = math.max(0, crossKick - dt * 5)
        -- 长按准心：动态扩张 + 旋转
        if crossTouch then
            crossHold = math.min(1, crossHold + dt * 3.5)
            crossSpin = crossSpin + dt * 90
        else
            crossHold = math.max(0, crossHold - dt * 4)
        end
        local base = math.floor(7 + crossKick * 9 + crossHold * 12)
        local len = math.floor(9 + crossKick * 5 + crossHold * 6)
        holder.Rotation = crossHold * crossSpin
        local l1, l2, l3, l4, dot = lines[1], lines[2], lines[3], lines[4], lines[5]
        l1.Size = UDim2.new(0, 1.6, 0, len)
        l1.Position = UDim2.new(0.5, 0, 0.5, -base)
        l2.Size = UDim2.new(0, 1.6, 0, len)
        l2.Position = UDim2.new(0.5, 0, 0.5, base)
        l3.Size = UDim2.new(0, len, 0, 1.6)
        l3.Position = UDim2.new(0.5, -base, 0.5, 0)
        l4.Size = UDim2.new(0, len, 0, 1.6)
        l4.Position = UDim2.new(0.5, base, 0.5, 0)
        for i = 1, 4 do
            lines[i].BackgroundTransparency = 0.35
        end
        dot.BackgroundTransparency = 0.25
    end)
end
EnsureCrosshair()

local function FireOnce(tool, shootInterval)
    crossKick = 1
end

local function AutoFire(tool, shoot, interval)
    EnsureCrosshair()
    local firing = false
    local function isHeld()
        return tool.Parent and tool.Parent:FindFirstChildOfClass("Humanoid") ~= nil
    end
    local function start()
        if firing or not isHeld() then return end
        firing = true
        crossKick = 1
        task.spawn(function()
            while firing and tool.Parent do
                pcall(shoot)
                task.wait(interval or 0.13)
            end
            firing = false
        end)
    end
    local function stop()
        firing = false
    end
    tool.Unequipped:Connect(stop)
    tool.Destroying:Connect(stop)
    return { start = start, stop = stop }
end

-- 外置射击按键（持枪时显示，按住连发）
local fireHook = nil
local function SetFireHook(h)
    fireHook = h
end

local function BuildFireButton()
    local gui = Instance.new("ScreenGui")
    gui.Name = "WindFireButton"
    gui.ResetOnSpawn = false
    gui.IgnoreGuiInset = true
    gui.DisplayOrder = 40
    gui.Enabled = false
    gui.Parent = LocalPlayer.PlayerGui

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 88, 0, 88)
    btn.Position = UDim2.new(1, -60, 0, 60)
    btn.AnchorPoint = Vector2.new(0.5, 0.5)
    btn.BackgroundColor3 = Color3.fromRGB(80, 50, 130)
    btn.BackgroundTransparency = 0.25
    btn.BorderSizePixel = 0
    btn.Text = "射击"
    btn.TextColor3 = Color3.fromRGB(235, 220, 255)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 15
    btn.AutoLocalize = false
    btn.Parent = gui
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0.5, 0)
    c.Parent = btn
    local st = Instance.new("UIStroke")
    st.Color = Color3.fromRGB(170, 120, 255)
    st.Thickness = 2
    st.Parent = btn

    local fireTouch = nil
    btn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            fireTouch = input
            if fireHook then
                pcall(function() fireHook.start() end)
            end
            btn.BackgroundTransparency = 0.05
        end
    end)
    -- 按住后手指在屏幕上滑动，依旧保持射击；按钮本身不移动
    UIS.InputChanged:Connect(function(input)
        if not fireTouch then return end
        if input == fireTouch then
            if fireHook then
                pcall(function() fireHook.start() end)
            end
        end
    end)
    UIS.InputEnded:Connect(function(input)
        if fireTouch and input == fireTouch then
            fireTouch = nil
            if fireHook then
                pcall(function() fireHook.stop() end)
            end
            btn.BackgroundTransparency = 0.25
        elseif input.UserInputType == Enum.UserInputType.MouseButton1 and fireTouch == nil then
            if fireHook then
                pcall(function() fireHook.stop() end)
            end
            btn.BackgroundTransparency = 0.25
        end
    end)

    RunService.RenderStepped:Connect(function()
        if not (gui and gui.Parent) then return end
        local show = fireHook ~= nil
        if gui.Enabled ~= show then
            gui.Enabled = show
        end
    end)
end
BuildFireButton()

-- 点击射线的起点与方向（子弹按这条线飞，命中点与你点的地方完全一致）
local function PointerRayInfo()
    local cam = workspace.CurrentCamera
    if not cam then return nil end
    local vp = cam.ViewportSize
    local p = lastPointerPos or Vector2.new(vp.X * 0.5, vp.Y * 0.5)
    if IsFirstPerson() then p = Vector2.new(vp.X * 0.5, vp.Y * 0.5) end
    local ray = cam:ViewportPointToRay(p.X, p.Y, 0)
    return ray.Origin, ray.Direction
end

-- 第一人称时把右臂摆动归零，武器不再左右乱飘
local armLock = false
local function SetArmLock(v)
    armLock = v
end
local armMotor = nil
local armChar = nil
RunService.RenderStepped:Connect(function()
    if not armLock or not IsFirstPerson() then return end
    local char = LocalPlayer.Character
    if not char then return end
    if char ~= armChar then
        armChar = char
        armMotor = char:FindFirstChild("RightShoulder") or char:FindFirstChild("Right Shoulder")
        if not armMotor and char:FindFirstChild("RightArm") then
            armMotor = char:FindFirstChild("RightArm"):FindFirstChildOfClass("Motor6D")
        end
    end
    if armMotor then
        armMotor.Transform = CFrame.new()
    end
end)

-- 瞄准点（准星指向的落点）
local function GetAimPoint(rangeDistance)
    local cam = workspace.CurrentCamera
    if not cam then return nil end
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    local char = LocalPlayer.Character
    params.FilterDescendantsInstances = char and { char } or {}
    local res = workspace:Raycast(cam.CFrame.Position, cam.CFrame.LookVector * (rangeDistance or 160), params)
    if res then return res.Position end
    return cam.CFrame.Position + cam.CFrame.LookVector * 50
end

-- 子弹：纯直线飞行（无重力下落），轨迹完全沿点击射线
local function FireBullet(origin, dir, speed, color, hitColor, size)
    local bullet = Instance.new("Part")
    bullet.Shape = Enum.PartType.Ball
    bullet.Size = Vector3.new(1, 1, 1) * (size or 0.16)
    bullet.Color = color
    bullet.Material = Enum.Material.Neon
    bullet.Anchored = true
    bullet.CanCollide = false
    bullet.CanQuery = false
    bullet.CanTouch = false
    bullet.CastShadow = false
    bullet.CFrame = CFrame.new(origin)
    bullet.Parent = workspace

    local a0 = Instance.new("Attachment")
    a0.Parent = bullet
    local a1 = Instance.new("Attachment")
    a1.Position = Vector3.new(0, 0, -0.9)
    a1.Parent = bullet
    local tr = Instance.new("Trail")
    tr.Attachment0 = a0
    tr.Attachment1 = a1
    tr.Color = ColorSequence.new(color)
    tr.Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.15), NumberSequenceKeypoint.new(1, 1) })
    tr.Lifetime = 0.14
    tr.LightEmission = 1
    tr.WidthScale = NumberSequence.new({ NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(1, 0) })
    tr.Parent = bullet

    local vel = dir.Unit * speed
    local life = 0
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    local char = LocalPlayer.Character
    params.FilterDescendantsInstances = char and { char, bullet } or { bullet }
    local conn
    conn = RunService.RenderStepped:Connect(function(dt)
        if not bullet.Parent then
            pcall(function() conn:Disconnect() end)
            return
        end
        life = life + dt
        local step = vel * dt
        local res = workspace:Raycast(bullet.Position, step, params)
        if res then
            local hp = res.Position
            pcall(function()
                Flash(hp, hitColor, 1.0, 0.16)
                RingWave(hp, hitColor, 0.4, 1.8, 0.22)
                Burst(hp, hitColor, 14, 9, res.Normal, nil, 0.3)
            end)
            bullet:Destroy()
            pcall(function() conn:Disconnect() end)
            return
        end
        local np = bullet.Position + step
        bullet.CFrame = CFrame.lookAt(np, np + vel)
        if life > 1.6 or np.Y < -400 then
            bullet:Destroy()
            pcall(function() conn:Disconnect() end)
        end
    end)
end

-- 手雷抛投：按准星落点解抛物线，弧线飞到瞄准点再爆
local function ThrowGrenadePart(g, startPos, targetPos, gravity, flightTime, onHit)
    flightTime = flightTime or 0.95
    gravity = gravity or 80
    local delta = targetPos - startPos
    if delta.Magnitude < 6 then
        delta = delta.Unit * 6
    end
    local vel = delta / flightTime + Vector3.new(0, 0.5 * gravity * flightTime, 0)
    local t = 0
    local last = g.Position
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    local char = LocalPlayer.Character
    params.FilterDescendantsInstances = char and { char, g } or { g }
    local conn
    conn = RunService.RenderStepped:Connect(function(dt)
        if not g.Parent then
            pcall(function() conn:Disconnect() end)
            return
        end
        t = t + dt
        local np = startPos + vel * t + Vector3.new(0, -0.5 * gravity * t * t, 0)
        local step = np - last
        local res = workspace:Raycast(last, step, params)
        local hit = res and res.Position or nil
        g.CFrame = CFrame.lookAt(np, np + (vel + Vector3.new(0, -gravity * t, 0)))
        last = np
        if hit or t >= flightTime then
            local p = hit or np
            pcall(function() onHit(p) end)
            pcall(function() g:Destroy() end)
            pcall(function() conn:Disconnect() end)
        end
    end)
end

-- 后坐/挥动
local gripBase = setmetatable({}, { __mode = "k" })
local recoilBusy = setmetatable({}, { __mode = "k" })

local function GetBaseGrip(tool)
    local g = gripBase[tool]
    if not g then
        g = tool.Grip
        gripBase[tool] = g
    end
    return g
end

local function Recoil(tool, pushZ, backTime, outTime, twist)
    local orig = GetBaseGrip(tool)
    if recoilBusy[tool] then
        -- 上一次后坐还没播完：直接复位到基准握姿，绝不叠加
        pcall(function() tool.Grip = orig end)
        return
    end
    recoilBusy[tool] = true
    local goal = orig * CFrame.new(0, 0, pushZ or 0.3)
    if twist then
        goal = orig * CFrame.Angles(math.rad(twist), 0, math.rad(18))
    end
    pcall(function()
        TweenService:Create(tool, TweenInfo.new(backTime or 0.06, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Grip = goal }):Play()
    end)
    task.delay(backTime or 0.06, function()
        pcall(function()
            TweenService:Create(tool, TweenInfo.new(outTime or 0.16, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Grip = orig }):Play()
        end)
        task.delay((outTime or 0.16) + 0.04, function()
            pcall(function() tool.Grip = orig end)
            recoilBusy[tool] = nil
        end)
    end)
end

-- 雷暴电手枪：握把竖直，枪身在上方，枪管向-Z
local function BuildTesla(tool)
    local handle = NewPiece(tool, "Handle", Vector3.new(0.30, 0.74, 0.36), Color3.fromRGB(42, 40, 46), Enum.Material.Metal)
    local body = NewPiece(tool, "Body", Vector3.new(0.42, 0.34, 1.10), Color3.fromRGB(205, 168, 62), Enum.Material.Metal)
    body.CFrame = handle.CFrame * CFrame.new(0, 0.58, -0.58)
    Weld(body, handle)
    local rail = NewPiece(tool, "Rail", Vector3.new(0.30, 0.09, 0.92), Color3.fromRGB(240, 210, 118), Enum.Material.Metal)
    rail.CFrame = body.CFrame * CFrame.new(0, 0.22, 0)
    Weld(rail, body)
    local glow = NewPiece(tool, "GlowStrip", Vector3.new(0.45, 0.05, 0.88), Color3.fromRGB(70, 185, 255), Enum.Material.Neon)
    glow.CFrame = body.CFrame * CFrame.new(0, 0.0, 0)
    Weld(glow, body)
    local barrel = NewPiece(tool, "Barrel", Vector3.new(0.18, 0.18, 0.82), Color3.fromRGB(226, 228, 238), Enum.Material.Metal)
    barrel.CFrame = body.CFrame * CFrame.new(0, 0.04, -0.82)
    Weld(barrel, body)
    local core = NewPiece(tool, "Core", Vector3.new(0.30, 0.26, 0.26), Color3.fromRGB(95, 200, 255), Enum.Material.Neon)
    core.Shape = Enum.PartType.Cylinder
    core.CFrame = body.CFrame * CFrame.new(-0.24, 0.02, 0.42) * CFrame.Angles(0, 0, math.rad(90))
    Weld(core, body)
    local ring = NewPiece(tool, "MuzzleRing", Vector3.new(0.34, 0.1, 0.34), Color3.fromRGB(130, 215, 255), Enum.Material.Neon)
    ring.Shape = Enum.PartType.Cylinder
    ring.CFrame = barrel.CFrame * CFrame.new(0, 0, -0.44) * CFrame.Angles(0, 0, math.rad(90))
    Weld(ring, barrel)
    local guard = NewPiece(tool, "TriggerGuard", Vector3.new(0.22, 0.05, 0.10), Color3.fromRGB(200, 165, 70), Enum.Material.Metal)
    guard.CFrame = handle.CFrame * CFrame.new(0, 0.10, -0.28)
    Weld(guard, handle)
    local hammer = NewPiece(tool, "Hammer", Vector3.new(0.12, 0.16, 0.10), Color3.fromRGB(210, 175, 80), Enum.Material.Metal)
    hammer.CFrame = handle.CFrame * CFrame.new(0, 0.42, 0.16)
    Weld(hammer, handle)
    tool.Grip = CFrame.new(0, 0.16, 0) * CFrame.Angles(math.rad(-6), 0, 0)
    AddTrail(barrel, Color3.fromRGB(90, 190, 255), 0.35, 0.16)
    BindToolFx(tool, Color3.fromRGB(120, 210, 255), Color3.fromRGB(255, 215, 110), handle, Color3.fromRGB(110, 200, 255), 3)
    local sfxShot = SoundPool("rbxasset://sounds/electronicpingshort.wav", 4, 0.65, 1.55)
    tool.Equipped:Connect(function()
        SetCrosshairEnabled(true)
    end)
    tool.Unequipped:Connect(function() SetCrosshairEnabled(false) end)
    tool.Destroying:Connect(function() SetCrosshairEnabled(false) end)

    local function shoot()
        pcall(function() tool.Grip = GetBaseGrip(tool) end)
        pcall(function() sfxShot() end)
        local mz = Pick(tool, "MuzzleRing", "Barrel")
        local ro, rd = PointerRayInfo()
        if mz and ro then
            Flash(mz.CFrame.Position, Color3.fromRGB(150, 225, 255), 0.85, 0.16)
            Burst(mz.CFrame.Position, Color3.fromRGB(120, 205, 255), 22, 14, Enum.NormalId.Front, nil, 0.3)
            RingWave(mz.CFrame.Position, Color3.fromRGB(120, 215, 255), 0.4, 1.8, 0.18)
            FireBullet(ro + rd * 2.4, rd, 240, Color3.fromRGB(150, 225, 255), Color3.fromRGB(120, 210, 255), 0.15)
        end
        Recoil(tool, 0.24, 0.05, 0.14)
    end
    local fireCtl = AutoFire(tool, shoot, 0.3)
    tool.Equipped:Connect(function() SetFireHook(fireCtl) end)
    tool.Unequipped:Connect(function() SetFireHook(nil) end)
    tool.Destroying:Connect(function() SetFireHook(nil) end)
end

-- 霜龙连发步枪
local function BuildFrost(tool)
    local handle = NewPiece(tool, "Handle", Vector3.new(0.32, 0.78, 0.40), Color3.fromRGB(24, 24, 32), Enum.Material.Metal)
    local body = NewPiece(tool, "Body", Vector3.new(0.36, 0.42, 1.45), Color3.fromRGB(216, 222, 236), Enum.Material.Metal)
    body.CFrame = handle.CFrame * CFrame.new(0, 0.60, -0.70)
    Weld(body, handle)
    local upper = NewPiece(tool, "UpperRail", Vector3.new(0.28, 0.10, 1.30), Color3.fromRGB(242, 226, 178), Enum.Material.Metal)
    upper.CFrame = body.CFrame * CFrame.new(0, 0.24, -0.05)
    Weld(upper, body)
    local mag = NewPiece(tool, "Mag", Vector3.new(0.30, 0.50, 0.40), Color3.fromRGB(170, 115, 255), Enum.Material.Neon)
    mag.CFrame = body.CFrame * CFrame.new(0, -0.40, -0.10) * CFrame.Angles(math.rad(10), 0, 0)
    Weld(mag, body)
    local magCase = NewPiece(tool, "MagCase", Vector3.new(0.34, 0.34, 0.42), Color3.fromRGB(226, 232, 244), Enum.Material.Metal)
    magCase.CFrame = mag.CFrame * CFrame.new(0, -0.26, 0.02)
    Weld(magCase, mag)
    local stock = NewPiece(tool, "Stock", Vector3.new(0.30, 0.32, 1.00), Color3.fromRGB(242, 226, 178), Enum.Material.Metal)
    stock.CFrame = body.CFrame * CFrame.new(0, 0.0, 1.02)
    Weld(stock, body)
    local barrel = NewPiece(tool, "Barrel", Vector3.new(0.14, 0.14, 1.90), Color3.fromRGB(232, 236, 245), Enum.Material.Metal)
    barrel.CFrame = body.CFrame * CFrame.new(0, 0.06, -1.62)
    Weld(barrel, body)
    local muzzle = NewPiece(tool, "Muzzle", Vector3.new(0.26, 0.1, 0.26), Color3.fromRGB(150, 225, 255), Enum.Material.Neon)
    muzzle.Shape = Enum.PartType.Cylinder
    muzzle.CFrame = barrel.CFrame * CFrame.new(0, 0, -0.98) * CFrame.Angles(0, 0, math.rad(90))
    Weld(muzzle, barrel)
    local scope = NewPiece(tool, "Scope", Vector3.new(0.16, 0.16, 0.50), Color3.fromRGB(52, 66, 110), Enum.Material.Metal)
    scope.CFrame = body.CFrame * CFrame.new(0, 0.36, 0.10)
    Weld(scope, body)
    local fin = NewPiece(tool, "DragonFin", Vector3.new(0.06, 0.30, 0.76), Color3.fromRGB(255, 226, 150), Enum.Material.Neon)
    fin.CFrame = barrel.CFrame * CFrame.new(0, 0.24, 0.62) * CFrame.Angles(0, 0, math.rad(18))
    Weld(fin, barrel)
    local gripA = NewPiece(tool, "GripFore", Vector3.new(0.20, 0.18, 0.24), Color3.fromRGB(232, 236, 245), Enum.Material.Metal)
    gripA.CFrame = body.CFrame * CFrame.new(0, -0.26, -0.62)
    Weld(gripA, body)
    local glowLine = NewPiece(tool, "PurpleLine", Vector3.new(0.05, 0.04, 1.30), Color3.fromRGB(180, 125, 255), Enum.Material.Neon)
    glowLine.CFrame = body.CFrame * CFrame.new(0.19, 0.02, -0.05)
    Weld(glowLine, body)
    tool.Grip = CFrame.new(0, 0.17, 0) * CFrame.Angles(math.rad(-5), 0, 0)
    AddTrail(barrel, Color3.fromRGB(185, 130, 255), 0.5, 0.2)
    BindToolFx(tool, Color3.fromRGB(190, 140, 255), Color3.fromRGB(255, 228, 160), handle, Color3.fromRGB(180, 125, 255), 3)

    -- 枪身紫色光效持续外散
    local auraSrc = NewPiece(tool, "AuraSrc", Vector3.new(0.06, 0.06, 0.06), Color3.fromRGB(180, 125, 255), Enum.Material.Neon)
    auraSrc.Transparency = 1
    auraSrc.CFrame = body.CFrame
    Weld(auraSrc, body)
    local aura = Instance.new("ParticleEmitter")
    aura.Texture = "rbxasset://textures/particles/sparkles_main.dds"
    aura.Color = ColorSequence.new(Color3.fromRGB(185, 130, 255))
    aura.Size = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.42), NumberSequenceKeypoint.new(1, 0) })
    aura.Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.3), NumberSequenceKeypoint.new(1, 1) })
    aura.Lifetime = NumberRange.new(0.6, 1.2)
    aura.Speed = NumberRange.new(1, 3.2)
    aura.SpreadAngle = Vector2.new(180, 180)
    aura.LightEmission = 1
    aura.Rate = 7
    aura.Parent = auraSrc
    local gunLight = Instance.new("PointLight")
    gunLight.Color = Color3.fromRGB(180, 125, 255)
    gunLight.Brightness = 1.4
    gunLight.Range = 10
    gunLight.Parent = body
    TweenService:Create(gunLight, TweenInfo.new(1.4, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), {
        Brightness = 2.6,
    }):Play()
    local sfxShot = SoundPool("rbxasset://sounds/electronicpingshort.wav", 6, 0.45, 1.15)
    tool.Equipped:Connect(function()
        SetArmLock(true)
        SetCrosshairEnabled(true)
    end)
    tool.Unequipped:Connect(function()
        SetArmLock(false)
        SetCrosshairEnabled(false)
    end)
    tool.Destroying:Connect(function()
        SetArmLock(false)
        SetCrosshairEnabled(false)
    end)

    local function shoot()
        local mz = Pick(tool, "Muzzle", "Barrel")
        local ro, rd = PointerRayInfo()
        if not (mz and ro) then return end
        pcall(function() sfxShot() end)
        Flash(mz.CFrame.Position, Color3.fromRGB(190, 140, 255), 0.9, 0.14)
        RingWave(mz.CFrame.Position, Color3.fromRGB(180, 125, 255), 0.4, 2.0, 0.18)
        Burst(mz.CFrame.Position, Color3.fromRGB(190, 135, 255), 16, 16, Enum.NormalId.Front, nil, 0.28)
        Burst(mz.CFrame.Position, Color3.fromRGB(240, 230, 255), 8, 9, nil, nil, 0.24)
        FireBullet(ro + rd * 2.4, rd, 380, Color3.fromRGB(200, 155, 255), Color3.fromRGB(180, 130, 255), 0.17)
        Recoil(tool, 0.14, 0.035, 0.08)
    end
    local fireCtl = AutoFire(tool, shoot, 0.135)
    tool.Equipped:Connect(function() SetFireHook(fireCtl) end)
    tool.Unequipped:Connect(function() SetFireHook(nil) end)
    tool.Destroying:Connect(function() SetFireHook(nil) end)
end

-- 紫电手雷（按准星落点抛出）
local function GrenadeExplosion(p)
    Flash(p, Color3.fromRGB(210, 150, 255), 8, 0.42)
    Flash(p, Color3.fromRGB(255, 180, 95), 5.5, 0.32)
    RingWave(p, Color3.fromRGB(200, 140, 255), 2.5, 14, 0.5)
    task.delay(0.12, function()
        pcall(function() RingWave(p, Color3.fromRGB(255, 190, 110), 1.5, 9, 0.42) end)
    end)
    LightPillar(p, Color3.fromRGB(200, 145, 255), 6, 0.45)
    Burst(p, Color3.fromRGB(200, 145, 255), 70, 30, nil, nil, 0.55)
    Burst(p, Color3.fromRGB(255, 205, 130), 40, 22, nil, nil, 0.45)
    for i = 1, 6 do
        local dir = Vector3.new(math.random(-100, 100), math.random(-20, 100), math.random(-100, 100)).Unit
        local bolt = Instance.new("Part")
        bolt.Size = Vector3.new(0.3, 0.3, 4.5)
        bolt.Color = Color3.fromRGB(200, 150, 255)
        bolt.Material = Enum.Material.Neon
        bolt.Anchored = true
        bolt.CanCollide = false
        bolt.Transparency = 0.15
        bolt.CFrame = CFrame.new(p + dir * 2.2, p + dir * 6)
        bolt.Parent = workspace
        TweenService:Create(bolt, TweenInfo.new(0.3), { Transparency = 1 }):Play()
        task.delay(0.35, function() pcall(function() bolt:Destroy() end) end)
    end
end

local function BuildGrenade(tool)
    local handle = NewPiece(tool, "Handle", Vector3.new(0.56, 0.56, 0.56), Color3.fromRGB(116, 88, 196), Enum.Material.Metal)
    local core = NewPiece(tool, "Core", Vector3.new(0.40, 0.40, 0.40), Color3.fromRGB(196, 128, 255), Enum.Material.Neon)
    core.CFrame = handle.CFrame
    Weld(core, handle)
    local top = NewPiece(tool, "Top", Vector3.new(0.14, 0.34, 0.14), Color3.fromRGB(255, 226, 140), Enum.Material.Neon)
    top.CFrame = handle.CFrame * CFrame.new(0, 0.42, 0)
    Weld(top, handle)
    local b1 = NewPiece(tool, "Band1", Vector3.new(0.60, 0.08, 0.60), Color3.fromRGB(250, 212, 112), Enum.Material.Metal)
    b1.CFrame = handle.CFrame * CFrame.new(0, 0.22, 0)
    Weld(b1, handle)
    local b2 = NewPiece(tool, "Band2", Vector3.new(0.60, 0.08, 0.60), Color3.fromRGB(250, 212, 112), Enum.Material.Metal)
    b2.CFrame = handle.CFrame * CFrame.new(0, -0.22, 0)
    Weld(b2, handle)
    for i = 1, 4 do
        local a = math.rad(90 * i)
        local spike = NewPiece(tool, "Spike" .. i, Vector3.new(0.06, 0.16, 0.06), Color3.fromRGB(255, 232, 150), Enum.Material.Metal)
        spike.CFrame = handle.CFrame * CFrame.new(math.cos(a) * 0.32, 0, math.sin(a) * 0.32) * CFrame.Angles(math.rad(28), a, 0)
        Weld(spike, handle)
    end
    tool.Grip = CFrame.new(0, 0, 0)
    BindToolFx(tool, Color3.fromRGB(190, 130, 255), Color3.fromRGB(255, 214, 120), handle, Color3.fromRGB(180, 120, 255), 4)
    local sfxThrow = SoundPool("rbxasset://sounds/unsheath.wav", 2, 0.75, 1.35)

    tool.Activated:Connect(function()
        local char = tool.Parent
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        local cam = workspace.CurrentCamera
        if not (hrp and cam) then return end
        local target = PointerWorldPoint() or (hrp.Position + cam.CFrame.LookVector * 45)
        pcall(function() sfxThrow() end)
        local h = tool:FindFirstChild("Handle")
        local start = h and h.Position or (hrp.Position + Vector3.new(0, 1, 0))

        local g = Instance.new("Part")
        g.Name = "ThrownGrenade"
        g.Size = Vector3.new(0.6, 0.6, 0.6)
        g.Color = Color3.fromRGB(150, 105, 235)
        g.Material = Enum.Material.Neon
        g.CanCollide = false
        g.CanQuery = false
        g.CastShadow = false
        g.CFrame = CFrame.new(start)
        g.Parent = workspace
        local em = Instance.new("ParticleEmitter")
        em.Texture = "rbxasset://textures/particles/sparkles_main.dds"
        em.Color = ColorSequence.new(Color3.fromRGB(190, 130, 255))
        em.Size = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.5), NumberSequenceKeypoint.new(1, 0) })
        em.Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.2), NumberSequenceKeypoint.new(1, 1) })
        em.Lifetime = NumberRange.new(0.3, 0.6)
        em.Speed = NumberRange.new(1, 4)
        em.SpreadAngle = Vector2.new(180, 180)
        em.Rate = 20
        em.LightEmission = 1
        em.Parent = g
        Flash(start, Color3.fromRGB(170, 118, 255), 1.0, 0.24)
        RingWave(start, Color3.fromRGB(180, 125, 255), 0.5, 2.0, 0.2)

        local exploded = false
        local sfxBoom = SoundPool("rbxasset://sounds/bass.wav", 3, 1.1, 0.85)
        local sfxFizz = SoundPool("rbxasset://sounds/snap.wav", 3, 0.9, 0.7)
        local function boom(p)
            if exploded then return end
            exploded = true
            pcall(function() sfxBoom() end)
            pcall(function() sfxFizz() end)
            pcall(function() GrenadeExplosion(p) end)
        end
        ThrowGrenadePart(g, start, target, 80, 0.95, boom)
        task.delay(2.2, function()
            if not exploded and g.Parent then
                boom(g.Position)
                pcall(function() g:Destroy() end)
            end
        end)

        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then pcall(function() hum:UnequipTools() end) end
        task.delay(0.1, function() pcall(function() tool:Destroy() end) end)
        print("✅ 紫电手雷已掷向准星处")
    end)
end

-- 金鳞龙刀（尼泊尔弯刀·三层光效版）
local function BuildBlade(tool)
    local handle = NewPiece(tool, "Handle", Vector3.new(0.17, 0.20, 0.80), Color3.fromRGB(66, 41, 27), Enum.Material.Wood)
    for i = 1, 4 do
        local wrap = NewPiece(tool, "Wrap" .. i, Vector3.new(0.185, 0.215, 0.05), Color3.fromRGB(48, 33, 23), Enum.Material.Fabric)
        wrap.CFrame = handle.CFrame * CFrame.new(0, 0, 0.24 - i * 0.115)
        Weld(wrap, handle)
    end
    local pommel = NewPiece(tool, "Pommel", Vector3.new(0.22, 0.24, 0.14), Color3.fromRGB(214, 176, 78), Enum.Material.Metal)
    pommel.CFrame = handle.CFrame * CFrame.new(0, 0, 0.42)
    Weld(pommel, handle)
    local pommelRing = NewPiece(tool, "PommelRing", Vector3.new(0.26, 0.28, 0.05), Color3.fromRGB(240, 202, 112), Enum.Material.Metal)
    pommelRing.CFrame = pommel.CFrame * CFrame.new(0, 0, 0.08)
    Weld(pommelRing, pommel)
    local guard = NewPiece(tool, "Guard", Vector3.new(0.46, 0.11, 0.14), Color3.fromRGB(240, 202, 112), Enum.Material.Metal)
    guard.CFrame = handle.CFrame * CFrame.new(0, 0, -0.44)
    Weld(guard, handle)
    local gUp = NewPiece(tool, "GuardUp", Vector3.new(0.10, 0.26, 0.10), Color3.fromRGB(252, 220, 140), Enum.Material.Metal)
    gUp.CFrame = guard.CFrame * CFrame.new(0, 0.16, 0)
    Weld(gUp, guard)
    local gDown = NewPiece(tool, "GuardDown", Vector3.new(0.08, 0.22, 0.08), Color3.fromRGB(252, 220, 140), Enum.Material.Metal)
    gDown.CFrame = guard.CFrame * CFrame.new(0, -0.16, 0)
    Weld(gDown, guard)

    -- 刀身：弧长积分生成弯曲曲线（越靠尖越弯，尼泊尔轮廓）
    local n = 14
    local Lseg = 0.235
    local totalA = math.rad(62)
    local z0 = -0.50
    local sPos = Vector3.new(0, 0, z0)
    local bladeParts = {}
    for i = 1, n do
        local t = (i - 0.5) / n
        local ang = totalA * (t ^ 1.45)
        local dir = Vector3.new(0, math.sin(ang), -math.cos(ang))
        local center = sPos + dir * (Lseg * 0.5)
        local w = 0.37 - 0.21 * (t ^ 0.8)
        local b = NewPiece(tool, "Blade" .. i, Vector3.new(0.062, w, Lseg + 0.026), Color3.fromRGB(238, 198, 104), Enum.Material.Metal)
        b.CFrame = handle.CFrame * CFrame.lookAt(center, center + dir)
        Weld(b, handle)

        -- 光效 1：金色刀芯（从两侧透出，像烧红的金属）
        local core = NewPiece(tool, "Core" .. i, Vector3.new(0.098, w - 0.10, Lseg - 0.01), Color3.fromRGB(170, 115, 255), Enum.Material.Neon)
        core.CFrame = b.CFrame
        Weld(core, b)

        -- 光效 2：刃口冷白高光
        local edge = NewPiece(tool, "Edge" .. i, Vector3.new(0.030, 0.045, Lseg - 0.012), Color3.fromRGB(255, 252, 240), Enum.Material.Neon)
        edge.CFrame = b.CFrame * CFrame.new(0, w * 0.5 - 0.014, 0)
        Weld(edge, b)

        -- 光效 3：刀背龙纹流光（紫金脉动）
        if i >= 2 and i <= 12 then
            local back = NewPiece(tool, "BackGlow" .. i, Vector3.new(0.042, 0.05, Lseg - 0.02), Color3.fromRGB(205, 130, 255), Enum.Material.Neon)
            back.CFrame = b.CFrame * CFrame.new(0, -w * 0.5 + 0.03, 0)
            Weld(back, b)
            if i % 2 == 0 then
                TweenService:Create(back, TweenInfo.new(0.7 + (i % 4) * 0.12, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), {
                    Color = Color3.fromRGB(90, 170, 255),
                }):Play()
            end
        end

        if i == 3 or i == 6 or i == 9 then
            local fuller = NewPiece(tool, "Fuller" .. i, Vector3.new(0.072, 0.048, Lseg * 0.8), Color3.fromRGB(196, 156, 66), Enum.Material.Metal)
            fuller.CFrame = b.CFrame * CFrame.new(0, -w * 0.5 + 0.06, 0)
            Weld(fuller, b)
        end

        bladeParts[i] = b
        sPos = sPos + dir * Lseg
    end

    -- 刀尖
    local tEnd = 1.0
    local angEnd = totalA * (tEnd ^ 1.45)
    local dirEnd = Vector3.new(0, math.sin(angEnd), -math.cos(angEnd))
    local tipStart = sPos
    local tip = NewPiece(tool, "Tip", Vector3.new(0.048, 0.085, 0.30), Color3.fromRGB(255, 248, 220), Enum.Material.Neon)
    tip.CFrame = handle.CFrame * CFrame.lookAt(tipStart + dirEnd * 0.14, tipStart + dirEnd * 0.6)
    Weld(tip, bladeParts[n])

    -- 刀身发光：点光源呼吸（挥砍暴涨）
    local glowLight = Instance.new("PointLight")
    glowLight.Color = Color3.fromRGB(185, 125, 255)
    glowLight.Brightness = 2.0
    glowLight.Range = 15
    glowLight.Parent = bladeParts[5]
    TweenService:Create(glowLight, TweenInfo.new(1.3, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), {
        Brightness = 3.2,
    }):Play()

    -- 三层光的整体呼吸（错相位）
    local glowA = bladeParts[2]:FindFirstChild("Core2")
    local glowB = bladeParts[8]:FindFirstChild("BackGlow8")
    if glowA then
        TweenService:Create(glowA, TweenInfo.new(0.9, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), {
            Transparency = 0.35,
        }):Play()
    end
    if glowB then
        TweenService:Create(glowB, TweenInfo.new(1.15, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), {
            Transparency = 0.3,
        }):Play()
    end

    -- 刀身持续外散紫色光气
    local auraHolder = NewPiece(tool, "AuraSrc", Vector3.new(0.05, 0.05, 0.05), Color3.fromRGB(170, 115, 255), Enum.Material.Neon)
    auraHolder.Transparency = 1
    auraHolder.CFrame = bladeParts[5].CFrame
    Weld(auraHolder, bladeParts[5])
    local aura = Instance.new("ParticleEmitter")
    aura.Texture = "rbxasset://textures/particles/sparkles_main.dds"
    aura.Color = ColorSequence.new(Color3.fromRGB(175, 120, 255))
    aura.Size = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.55), NumberSequenceKeypoint.new(1, 0) })
    aura.Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.25), NumberSequenceKeypoint.new(1, 1) })
    aura.Lifetime = NumberRange.new(0.7, 1.4)
    aura.Speed = NumberRange.new(1.5, 4)
    aura.SpreadAngle = Vector2.new(180, 180)
    aura.LightEmission = 1
    aura.Rate = 9
    aura.Parent = auraHolder

    -- 斜持上挑：刀尖朝上前方，弧面朝向自己
    tool.Grip = CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(-42), math.rad(22), math.rad(-68))
    AddTrail(bladeParts[4], Color3.fromRGB(180, 125, 255), 1.6, 0.28)
    local sfxSlash = SoundPool("rbxasset://sounds/swordslash.wav", 3, 0.85, 1.05)
    local sfxDraw = SoundPool("rbxasset://sounds/unsheath.wav", 2, 0.6, 1.0)
    tool.Equipped:Connect(function() pcall(function() sfxDraw() end) end)
    tool.Unequipped:Connect(function() pcall(function() sfxDraw() end) end)
    BindToolFx(tool, Color3.fromRGB(255, 205, 100), Color3.fromRGB(255, 245, 200), handle, Color3.fromRGB(255, 200, 100), 4)

    local swinging = false
    tool.Activated:Connect(function()
        if swinging then return end
        swinging = true
        crossKick = 1
        pcall(function() sfxSlash() end)
        local h = tool:FindFirstChild("Handle")
        local orig = tool.Grip
        -- 前后挥：刀尖在水平面上沿前后方向扫过（只绕竖轴旋转）
        local windUp = orig * CFrame.Angles(0, math.rad(-64), 0)
        local strike = orig * CFrame.Angles(0, math.rad(62), 0)
        pcall(function()
            TweenService:Create(tool, TweenInfo.new(0.11, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Grip = windUp }):Play()
        end)
        pcall(function()
            glowLight.Brightness = 7.5
            task.delay(0.24, function()
                pcall(function() glowLight.Brightness = 2.6 end)
            end)
        end)
        task.delay(0.11, function()
            pcall(function()
                TweenService:Create(tool, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.In), { Grip = strike }):Play()
            end)
        end)
        task.delay(0.28, function()
            pcall(function()
                TweenService:Create(tool, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Grip = orig }):Play()
            end)
            task.delay(0.44, function()
                pcall(function() tool.Grip = orig end)
                swinging = false
            end)
        end)
        if h then
            local tipPos2 = h.Position + h.CFrame.LookVector * 2
            for k = 1, 4 do
                task.delay(0.05 * k, function()
                    pcall(function()
                        local p = h.Position + Vector3.new(math.random(-2, 2), math.random(-2, 2), math.random(-2, 2))
                        RingWave(p, Color3.fromRGB(185, 125, 255), 0.3, 1.8, 0.22)
                    end)
                end)
            end
            Flash(tipPos2, Color3.fromRGB(195, 135, 255), 1.4, 0.24)
            RingWave(h.Position, Color3.fromRGB(180, 120, 255), 1.0, 3.8, 0.3)
            RingWave(h.Position, Color3.fromRGB(120, 175, 255), 0.8, 2.6, 0.34)
            Burst(tipPos2, Color3.fromRGB(190, 130, 255), 28, 15, nil, nil, 0.45)
            task.delay(0.12, function()
                pcall(function() Burst(tipPos2, Color3.fromRGB(255, 245, 205), 12, 10, nil, nil, 0.3) end)
            end)
        end
    end)
end

local function BuildLocalTool(item)
    local tool = Instance.new("Tool")
    tool.Name = item.name
    tool.RequiresHandle = true
    tool.CanBeDropped = false
    if item.shape == "tesla" then
        BuildTesla(tool)
    elseif item.shape == "frost" then
        BuildFrost(tool)
    elseif item.shape == "grenade" then
        BuildGrenade(tool)
    elseif item.shape == "blade" then
        BuildBlade(tool)
    end
    return tool
end

local function GiveLocalTool(item)
    local char = LocalPlayer.Character
    if not char then
        NotifyReason("你的角色还没加载，稍等再试")
        return
    end
    local hum = char:FindFirstChildOfClass("Humanoid")
    local bp = LocalPlayer:FindFirstChildOfClass("Backpack")
    local tool = BuildLocalTool(item)
    pcall(function() ApplyToolScale(tool, GetCharScale(char) * 1.35) end)
    pcall(function()
        if bp then
            tool.Parent = bp
        else
            tool.Parent = char
        end
        if hum then
            hum:EquipTool(tool)
        end
    end)
    print("✅ 已获得「" .. item.name .. "」并装备")
end

local function DrawPixelGrid(parent, hex)
    local gw, gh = PHOTO_W, PHOTO_H
    local grid = Instance.new("Frame")
    grid.Size = UDim2.new(1, -6, 0, 72)
    grid.Position = UDim2.new(0, 3, 0, 3)
    grid.BackgroundTransparency = 1
    grid.ClipsDescendants = true
    grid.Parent = parent
    for i = 0, gw * gh - 1 do
        local hx = i * 6 + 1
        local r = tonumber(hex:sub(hx, hx + 1), 16) or 0
        local g = tonumber(hex:sub(hx + 2, hx + 3), 16) or 0
        local b = tonumber(hex:sub(hx + 4, hx + 5), 16) or 0
        local f = Instance.new("Frame")
        f.Size = UDim2.new(1 / gw + 0.004, 0, 1 / gh + 0.004, 0)
        f.Position = UDim2.new((i % gw) / gw, 0, math.floor(i / gw) / gh, 0)
        f.BackgroundColor3 = Color3.fromRGB(r, g, b)
        f.BorderSizePixel = 0
        f.Parent = grid
    end
end

local function AddPhotoGrid(parent, hex, imageId)
    if imageId then
        local img = Instance.new("ImageLabel")
        img.Size = UDim2.new(1, -6, 0, 72)
        img.Position = UDim2.new(0, 3, 0, 3)
        img.BackgroundTransparency = 1
        img.BorderSizePixel = 0
        img.ScaleType = Enum.ScaleType.Crop
        img.Image = "rbxthumb://type=Asset&id=" .. tostring(imageId) .. "&w=420&h=420"
        img.Parent = parent
        local ic = Instance.new("UICorner")
        ic.CornerRadius = UDim.new(0, 6)
        ic.Parent = img
        task.spawn(function()
            task.wait(1.5)
            local ok = false
            pcall(function() ok = img.IsLoaded end)
            if not ok then
                pcall(function()
                    img.Image = "rbxassetid://" .. tostring(imageId)
                end)
                task.wait(1.5)
                local ok2 = false
                pcall(function() ok2 = img.IsLoaded end)
                if not ok2 then
                    pcall(function() img:Destroy() end)
                    if hex then pcall(function() DrawPixelGrid(parent, hex) end) end
                    print("⚠ 武器图加载失败，已回退为像素图")
                end
            end
        end)
        return
    end
    DrawPixelGrid(parent, hex)
end

local function DestroyShopGui()
    for _, c in ipairs(shopConns) do
        pcall(function() c:Disconnect() end)
    end
    shopConns = {}
    if shopGui then pcall(function() shopGui:Destroy() end) end
    shopGui = nil
    shopPanel = nil
    shopScroll = nil
    shopMinimized = false
end

local function BuildShopGui()
    if shopGui then return end
    local gui = Instance.new("ScreenGui")
    gui.Name = "RobloxItemShopGui"
    gui.ResetOnSpawn = false
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    gui.Parent = LocalPlayer.PlayerGui
    shopGui = gui
    pcall(function() BindTree(gui) end)

    local panel = Instance.new("Frame")
    panel.Size = SHOP_PANEL_SIZE
    panel.Position = UDim2.new(0.5, -150, 0.16, 0)
    panel.BackgroundColor3 = Color3.new(0.08, 0.08, 0.1)
    panel.BackgroundTransparency = 0.08
    panel.BorderSizePixel = 0
    panel.ClipsDescendants = true
    panel.Parent = gui
    local pc = Instance.new("UICorner")
    pc.CornerRadius = UDim.new(0, 10)
    pc.Parent = panel
    local ps = Instance.new("UIStroke")
    ps.Color = Color3.fromRGB(56, 140, 245)
    ps.Thickness = 1.6
    ps.Transparency = 0.3
    ps.Parent = panel
    shopPanel = panel

    local title = Instance.new("TextButton")
    title.Size = UDim2.new(1, -60, 0, 32)
    title.BackgroundTransparency = 1
    title.Text = "武器库（点击获得）"
    title.TextColor3 = Color3.fromRGB(240, 244, 255)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 14
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.AutoLocalize = false
    title.Parent = panel
    local tp = Instance.new("UIPadding")
    tp.PaddingLeft = UDim.new(0, 10)
    tp.Parent = title

    local minBtn = Instance.new("TextButton")
    minBtn.Size = UDim2.new(0, 26, 0, 22)
    minBtn.Position = UDim2.new(1, -56, 0, 5)
    minBtn.BackgroundColor3 = Color3.fromRGB(52, 115, 190)
    minBtn.BorderSizePixel = 0
    minBtn.Text = "－"
    minBtn.TextColor3 = Color3.new(1, 1, 1)
    minBtn.Font = Enum.Font.GothamBold
    minBtn.TextSize = 14
    minBtn.AutoLocalize = false
    minBtn.Parent = panel
    local mc = Instance.new("UICorner")
    mc.CornerRadius = UDim.new(0, 6)
    mc.Parent = minBtn

    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 26, 0, 22)
    closeBtn.Position = UDim2.new(1, -26, 0, 5)
    closeBtn.BackgroundColor3 = Color3.fromRGB(158, 52, 56)
    closeBtn.BorderSizePixel = 0
    closeBtn.Text = "×"
    closeBtn.TextColor3 = Color3.new(1, 1, 1)
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.TextSize = 15
    closeBtn.AutoLocalize = false
    closeBtn.Parent = panel
    local cc = Instance.new("UICorner")
    cc.CornerRadius = UDim.new(0, 6)
    cc.Parent = closeBtn

    local scroll = Instance.new("ScrollingFrame")
    scroll.Size = UDim2.new(1, -12, 1, -38)
    scroll.Position = UDim2.new(0, 6, 0, 34)
    scroll.BackgroundTransparency = 1
    scroll.BorderSizePixel = 0
    scroll.ScrollBarThickness = 4
    scroll.ScrollBarImageColor3 = Color3.fromRGB(76, 140, 230)
    scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    scroll.ScrollingDirection = Enum.ScrollingDirection.Y
    scroll.Parent = panel
    shopScroll = scroll
    local grid = Instance.new("UIGridLayout")
    grid.CellSize = UDim2.new(0, 132, 0, 118)
    grid.CellPadding = UDim2.new(0, 8, 0, 8)
    grid.Parent = scroll

    for _, item in ipairs(SHOP_ITEMS) do
        local card = Instance.new("Frame")
        card.Size = UDim2.new(0, 132, 0, 118)
        card.BackgroundColor3 = Color3.fromRGB(33, 36, 44)
        card.BorderSizePixel = 0
        card.ClipsDescendants = true
        card.Parent = scroll
        local c1 = Instance.new("UICorner")
        c1.CornerRadius = UDim.new(0, 8)
        c1.Parent = card
        AddPhotoGrid(card, item.photo, item.imageId)
        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(1, 0, 0, 34)
        lbl.Position = UDim2.new(0, 0, 1, -36)
        lbl.BackgroundColor3 = Color3.new(0, 0, 0)
        lbl.BackgroundTransparency = 0.3
        lbl.BorderSizePixel = 0
        lbl.Text = item.name
        lbl.TextColor3 = Color3.fromRGB(255, 240, 190)
        lbl.Font = Enum.Font.GothamBold
        lbl.TextSize = 12
        lbl.AutoLocalize = false
        lbl.Parent = card
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, 0, 1, 0)
        btn.BackgroundTransparency = 1
        btn.Text = ""
        btn.Parent = card
        btn.MouseButton1Click:Connect(function()
            GiveLocalTool(item)
        end)
    end

    minBtn.MouseButton1Click:Connect(function()
        shopMinimized = not shopMinimized
        if shopMinimized then
            panel.Size = UDim2.new(0, 300, 0, 32)
            scroll.Visible = false
            minBtn.Text = "□"
        else
            panel.Size = SHOP_PANEL_SIZE
            scroll.Visible = true
            minBtn.Text = "－"
        end
    end)
    closeBtn.MouseButton1Click:Connect(function()
        DestroyShopGui()
        pcall(ShopForceToggleOff, shopToggleRef)
        print("🛑 武器库已关闭")
    end)

    local dragging = false
    local dragStart = nil
    local startPos = nil
    local dragTouch = nil
    table.insert(shopConns, title.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragTouch = input
            dragStart = input.Position
            startPos = panel.Position
        end
    end))
    table.insert(shopConns, UIS.InputChanged:Connect(function(input)
        if not dragging then return end
        if dragTouch and input ~= dragTouch and input.UserInputType ~= Enum.UserInputType.MouseMovement then return end
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement then
            local d = input.Position - dragStart
            panel.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
        end
    end))
    table.insert(shopConns, UIS.InputEnded:Connect(function(input)
        if not dragging then return end
        if dragTouch and input ~= dragTouch and input.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
        dragging = false
        dragTouch = nil
    end))
end

shopToggleRef = OtherTab:Toggle({
    Title = "打开武器库",
    Default = false,
    Callback = function(state)
        if state then
            BuildShopGui()
            print("✅ 武器库已打开，点击武器获得")
        else
            DestroyShopGui()
            print("🛑 武器库已关闭")
        end
        pcall(function() TipState("打开武器库", state) end)
    end
})

task.spawn(function()
    local seenOpen = false
    local closedTicks = 0
    while true do
        task.wait(0.25)
        local isOpen = false
        pcall(function()
            local sg = windUiRoot and windUiRoot:FindFirstAncestorOfClass("ScreenGui")
            if sg and sg.Parent and sg.Enabled == true then isOpen = true end
        end)
        if isOpen then
            seenOpen = true
            closedTicks = 0
        elseif seenOpen then
            closedTicks = closedTicks + 1
            if closedTicks >= 8 then
                closedTicks = 0
                seenOpen = false
                if shopGui then
                    pcall(DestroyShopGui)
                    print("🛑 主 UI 已关闭，武器库面板自动收起")
                end
                pcall(ShopForceToggleOff, shopToggleRef)
            end
        end
    end
end)
end)()


--===== 功能页控件（按指定顺序创建） =====
MoveTab:Toggle({
    Title = "飞行",
    Default = false,
    Callback = function(state)
        flyOn = state
        if flyConn then
            pcall(function() flyConn:Disconnect() end)
            flyConn = nil
        end
        if state then
            BuildFlyGui()
            print("✅ 飞行已开启，右侧外置面板可调倍速/升降")
            flyConn = RunService.RenderStepped:Connect(function(dt)
                if not flyOn then return end
                pcall(FlyStep, dt)
            end)
        else
            pcall(function() if FlyPanelStop then FlyPanelStop() end end)
            if flyActive then
                pcall(function() ClearFlyBV() UnlockCharacter() end)
            end
            DestroyFlyGui()
            ClearFlyBV()
            flyActive = false
            print("🛑 飞行已关闭")
        end
        pcall(function() TipState("飞行", state) end)
    end
})

MoveTab:Toggle({
    Title = "穿透",
    Default = false,
    Callback = function(state)
        ghostOn = state
        if ghostConn then
            ghostConn:Disconnect()
            ghostConn = nil
        end
        if state then
            local char = LocalPlayer.Character
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            if hum then
                ghostOrigWalkSpeed = hum.WalkSpeed
                ghostOrigJumpPower = hum.JumpPower
                ghostOrigJumpHeight = hum.JumpHeight
                hum.JumpPower = ghostOrigJumpPower
                hum.JumpHeight = ghostOrigJumpHeight
            end
            print("✅ 穿透已开启：人物碰到的一切物体、Terrain 地形都不再阻挡（原始移速 "..tostring(ghostOrigWalkSpeed).."、跳跃保留）")
            SetCharCollide(false)
            ghostAcc = 0
            ghostConn = RunService.Heartbeat:Connect(function(dt)
                if not ghostOn then return end
                pcall(ApplySelfGhost, dt)
                if ghostOrigWalkSpeed and LocalPlayer.Character then
                    local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
                    if hum then
                        if hum.WalkSpeed ~= ghostOrigWalkSpeed then hum.WalkSpeed = ghostOrigWalkSpeed end
                        if ghostOrigJumpPower and hum.JumpPower ~= ghostOrigJumpPower then hum.JumpPower = ghostOrigJumpPower end
                        if ghostOrigJumpHeight and hum.JumpHeight ~= ghostOrigJumpHeight then hum.JumpHeight = ghostOrigJumpHeight end
                    end
                end
                ghostAcc = ghostAcc + dt
                if ghostAcc < 0.1 then return end
                ghostAcc = 0
                pcall(ApplyGhostThrough)
                pcall(CleanGhostTable)
            end)
        else
            SetCharCollide(true)
            RestoreGhostParts()
            print("🛑 穿透已关闭，物体与自身碰撞已恢复实体")
        end
        pcall(function() TipState("穿透", state) end)
    end
})

MoveTab:Toggle({
    Title = "反虚空",
    Default = false,
    Callback = function(state)
        antiVoidOn = state
        if antiVoidConn then
            pcall(function() antiVoidConn:Disconnect() end)
            antiVoidConn = nil
        end
        if state then
            antiVoidAcc = 0
            antiVoidSafe = nil
            print("✅ 反虚空已开启，检测高度："..antiVoidLimit)
            antiVoidConn = RunService.Heartbeat:Connect(function(dt)
                if not antiVoidOn then return end
                antiVoidAcc = antiVoidAcc + dt
                if antiVoidAcc < 0.2 then return end
                antiVoidAcc = 0
                pcall(RecordAntiVoidSafe)
                pcall(CheckAntiVoid)
            end)
        else
            print("🛑 反虚空已关闭")
        end
        pcall(function() TipState("反虚空", state) end)
    end
})

MoveTab:Toggle({
    Title = "踏空行走",
    Default = false,
    Callback = function(state)
        airWalkOn = state
        if airWalkConn then
            pcall(function() airWalkConn:Disconnect() end)
            airWalkConn = nil
        end
        if state then
            print("✅ 踏空行走已开启（脚下生成隐形平台，内置无限跳跃）")
            airWalkJumpConn = UserInputService.JumpRequest:Connect(function()
                if not airWalkOn then return end
                doInfJump()
            end)
            airWalkConn = RunService.RenderStepped:Connect(function(dt)
                if not airWalkOn then return end
                pcall(ApplyAirWalk, dt)
            end)
        else
            if airWalkJumpConn then
                pcall(function() airWalkJumpConn:Disconnect() end)
                airWalkJumpConn = nil
            end
            RemoveAirWalkPlatform()
            pcall(function()
                local char = LocalPlayer.Character
                if char then char:SetAttribute("xzhAirWasAir", nil) end
            end)
            print("🛑 踏空行走已关闭，恢复正常下落")
        end
        pcall(function() TipState("踏空行走", state) end)
    end
})

MoveTab:Toggle({
    Title = "无限跳跃",
    Default = false,
    Callback = function(state)
        infJumpOn = state
        if state then
            bindInfJump(LocalPlayer.Character)
            print("✅ 无限跳跃已开启，点按/长按都能连续跳")
        else
            if infJumpConn then
                pcall(function() infJumpConn:Disconnect() end)
                infJumpConn = nil
            end
            if infJumpLoopConn then
                pcall(function() infJumpLoopConn:Disconnect() end)
                infJumpLoopConn = nil
            end
            disconnectJumpButton()
            print("🛑 无限跳跃已关闭")
        end
        pcall(function() TipState("无限跳跃", state) end)
    end
})

MoveTab:Toggle({
    Title = "夜视【满亮度】",
    Default = false,
    Callback = function(state)
        stopNightVision()
        if state then
            local lighting = game:GetService("Lighting")
            origAmbient = lighting.Ambient
            origOutdoorAmbient = lighting.OutdoorAmbient
            origBrightness = lighting.Brightness
            origColorShiftTop = lighting.ColorShift_Top
            origColorShiftBottom = lighting.ColorShift_Bottom
            local atmo = lighting:FindFirstChild("Atmosphere")
            if atmo then
                origAtmosphereDensity = atmo.Density
                origAtmosphereGlare = atmo.Glare
                origAtmosphereHaze = atmo.Haze
            end
            nightVisionOn = true
            print("✅ 夜视【满亮度】已开启")
            nightVisionLoopConn = task.spawn(function()
                while nightVisionOn do
                    pcall(function()
                        lighting.Ambient = Color3.new(1,1,1)
                        lighting.OutdoorAmbient = Color3.new(1,1,1)
                        lighting.Brightness = 2
                        lighting.ColorShift_Top = Color3.new(1,1,1)
                        lighting.ColorShift_Bottom = Color3.new(1,1,1)
                        if atmo then
                            atmo.Density = 0
                            atmo.Glare = 0
                            atmo.Haze = 0
                        end
                    end)
                    task.wait(0.3)
                end
                print("🛑 夜视【满亮度】已关闭，恢复原光照")
            end)
        else
            print("🛑 请求关闭夜视")
        end
        pcall(function() TipState("夜视【满亮度】", state) end)
    end
})

thirdToggle = MoveTab:Toggle({
    Title = "强制第三人称",
    Default = false,
    Callback = function(state)
        if state then
            camForce = "third"
            if firstToggle then pcall(TurnOff, firstToggle) end
            print("✅ 已强制第三人称")
        else
            if camForce == "third" then camForce = nil end
            print("🛑 已取消第三人称强制")
        end
        pcall(function() TipState("强制第三人称", state) end)
    end
})

firstToggle = MoveTab:Toggle({
    Title = "强制第一人称",
    Default = false,
    Callback = function(state)
        if state then
            camForce = "first"
            if thirdToggle then pcall(TurnOff, thirdToggle) end
            print("✅ 已强制第一人称")
        else
            if camForce == "first" then camForce = nil end
            print("🛑 已取消第一人称强制")
        end
        pcall(function() TipState("强制第一人称", state) end)
    end
})

MoveTab:Toggle({
    Title = "启用自动移速/跳跃",
    Default = false,
    Callback = function(state)
        physControlRunning = state
        if state then
            local ch = LocalPlayer.Character
            if ch then
                local hum = ch:FindFirstChildOfClass("Humanoid")
                if hum then
                    savedWalkSpeed = hum.WalkSpeed
                    savedJumpPower = hum.JumpPower
                    print("✅ 已保存初始移速："..savedWalkSpeed.."，初始跳跃："..savedJumpPower)
                end
            end
            print("✅ 自定义移速/跳跃已开启，移速："..setWalkSpeed.."，跳跃："..setJumpPower)
            task.spawn(function()
                while physControlRunning do
                    pcall(function()
                        local char = LocalPlayer.Character
                        if char then
                            local hum = char:FindFirstChildOfClass("Humanoid")
                            if hum then
                                hum.WalkSpeed = setWalkSpeed
                                hum.JumpPower = setJumpPower
                            end
                        end
                    end)
                    task.wait(0.2)
                end
                pcall(function()
                    local char = LocalPlayer.Character
                    if char then
                        local hum = char:FindFirstChildOfClass("Humanoid")
                        if hum and savedWalkSpeed ~= nil and savedJumpPower ~= nil then
                            hum.WalkSpeed = savedWalkSpeed
                            hum.JumpPower = savedJumpPower
                        end
                    end
                end)
                print("🛑 自定义移速/跳跃已关闭，恢复初始值")
            end)
        else
            print("🛑 请求关闭自定义移速/跳跃")
        end
        pcall(function() TipState("启用自动移速/跳跃", state) end)
    end
})

walkInputBox = MoveTab:Input({
    Title = "移动速度数值",
    Value = "50",
    Callback = function(inputText)
        local num = tonumber(inputText)
        if num and num >=0 then
            setWalkSpeed = num
            print("✅ 移速已设置为："..setWalkSpeed)
        else
            warn("❌ 请输入有效数字")
        end
    end
})

jumpInputBox = MoveTab:Input({
    Title = "跳跃高度数值",
    Value = "90",
    Callback = function(inputText)
        local num = tonumber(inputText)
        if num and num >=0 then
            setJumpPower = num
            print("✅ 跳跃力已设置为："..setJumpPower)
        else
            warn("❌ 请输入有效数字")
        end
    end
})

--===== 其他页：重新加入此服务器 =====
OtherTab:Button({
    Title = "重新加入此服务器",
    Callback = function()
        local ok, err = pcall(function()
            local TS = game:GetService("TeleportService")
            TS:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
        end)
        if ok then
            print("✅ 正在重新加入当前服务器")
            pcall(function() TipDone("重新加入此服务器") end)
        else
            NotifyReason("重新加入失败：" .. tostring(err))
        end
    end
})


--===== 其他页：加入人数最多/最少的服务器 =====
JoinServerHttp = function(url)
    local fns = {}
    pcall(function() if syn and syn.request then fns[#fns+1] = function() return syn.request({Url = url, Method = "GET"}) end end end)
    pcall(function() if http_request then fns[#fns+1] = function() return http_request({Url = url, Method = "GET"}) end end end)
    pcall(function() if request then fns[#fns+1] = function() return request({Url = url, Method = "GET"}) end end end)
    pcall(function() if http and http.request then fns[#fns+1] = function() return http.request({Url = url, Method = "GET"}) end end end)
    for _, f in ipairs(fns) do
        local ok, res = pcall(f)
        if ok and type(res) == "table" then
            local body = res.Body or res.body
            if body then return body end
        end
    end
    return nil
end

JoinServerByMode = function(mode, title)
    local placeId = game.PlaceId
    local url = "https://games.roblox.com/v1/games/" .. placeId .. "/servers/Public?sortOrder=" .. mode .. "&limit=100"
    local body = JoinServerHttp(url)
    if not body then
        NotifyReason("获取服务器列表失败")
        return
    end
    local ok, data = pcall(function()
        return game:GetService("HttpService"):JSONDecode(body)
    end)
    if not ok or type(data) ~= "table" or type(data.data) ~= "table" then
        NotifyReason("服务器列表解析失败")
        return
    end
    local pick = nil
    for _, sv in ipairs(data.data) do
        local playing = tonumber(sv.playing) or 0
        local maxp = tonumber(sv.maxPlayers) or 0
        if sv.id and playing > 0 and playing < maxp then
            if not pick then
                pick = sv
            elseif mode == "Desc" and playing > (tonumber(pick.playing) or 0) then
                pick = sv
            elseif mode == "Asc" and playing < (tonumber(pick.playing) or 0) then
                pick = sv
            end
        end
    end
    if not pick then
        NotifyReason("没找到有人的服务器")
        return
    end
    local okTp, err = pcall(function()
        game:GetService("TeleportService"):TeleportToPlaceInstance(placeId, pick.id, LocalPlayer)
    end)
    if okTp then
        print("✅ 正在加入服务器（人数 " .. tostring(pick.playing) .. "）")
        pcall(function() TipDone(title) end)
    else
        NotifyReason("加入失败：" .. tostring(err))
    end
end

OtherTab:Button({
    Title = "加入人数最多的服务器",
    Callback = function()
        JoinServerByMode("Desc", "加入人数最多的服务器")
    end
})

OtherTab:Button({
    Title = "加入人数最少的服务器",
    Callback = function()
        JoinServerByMode("Asc", "加入人数最少的服务器")
    end
})


--===== 其他页：退出此服务器 =====
OtherTab:Button({
    Title = "退出此服务器",
    Callback = function()
        pcall(function() TipDone("退出此服务器") end)
        task.defer(function()
            pcall(function() game:Shutdown() end)
            task.wait(0.3)
            pcall(function()
                game:GetService("Players").LocalPlayer:Kick("已退出服务器")
            end)
        end)
    end
})




-- 给脚本所有 UI（含外置面板、动态创建的按钮）自动绑定点击音效
task.spawn(function()
    local function ScanRoot(root)
        if not root then return end
        pcall(function()
            for _, d in ipairs(root:GetDescendants()) do
                if d:IsA("GuiButton") then
                    BindClickSound(d)
                end
            end
        end)
    end
    while true do
        task.wait(0.35)
        pcall(function()
            ScanRoot(windUiRoot)
            local pg = game:GetService("Players").LocalPlayer:FindFirstChild("PlayerGui")
            if pg then
                -- 只处理脚本自己创建的界面（Wind* / Xzh* / xzh* 以及脚本自建名单），游戏自带 UI 一律不绑
                local exactNames = {
                    StartConfirmUI = true,
                    UIFailAlert = true,
                    WindBagViewer = true,
                    WindAlbumViewer = true,
                    WindFireButton = true,
                    WindCrosshair = true,
                    FlyPanelGui = true,
                    XzhAimbotCircle = true,
                    RobloxItemShopGui = true,
                }
                for _, gui in ipairs(pg:GetChildren()) do
                    if gui:IsA("ScreenGui") then
                        local nm = gui.Name
                        if nm:match("^Wind") or nm:match("^Xzh") or nm:match("^xzh") or exactNames[nm] then
                            ScanRoot(gui)
                            pcall(function() BindTree(gui) end)
                        end
                    end
                end
            end
        end)
    end
end)


-- 音效兜底：按下并抬起在同一处且点在脚本 UI 的按钮上才响（覆盖点击后立即销毁/重建的按钮，如主 UI 展开小框）
task.spawn(function()
    local uis2 = game:GetService("UserInputService")
    local scriptGuiNames = {
        StartConfirmUI = true,
        UIFailAlert = true,
        WindBagViewer = true,
        WindAlbumViewer = true,
        WindFireButton = true,
        WindCrosshair = true,
        FlyPanelGui = true,
        XzhAimbotCircle = true,
        RobloxItemShopGui = true,
    }
    local press = nil

    local function IsScriptGui(obj)
        local sg = obj:FindFirstAncestorOfClass("ScreenGui")
        if not sg then return false end
        local nm = sg.Name
        return (nm:match("^Wind") or nm:match("^Xzh") or nm:match("^xzh") or scriptGuiNames[nm] == true)
    end

    local function HasButton(obj)
        local cur = obj
        for _ = 1, 4 do
            if cur and cur:IsA("GuiButton") then
                local blocked = false
                local c2 = cur
                for _ = 1, 3 do
                    if c2 and c2:GetAttribute("XzhNoClickSfx") then blocked = true break end
                    c2 = c2 and c2.Parent
                end
                if not blocked then return true end
                return false
            end
            cur = cur and cur.Parent
        end
        return false
    end

    uis2.InputBegan:Connect(function(input, gp)
        if gp then return end
        local isTouch = input.UserInputType == Enum.UserInputType.Touch
        local isMouse = input.UserInputType == Enum.UserInputType.MouseButton1
        if not (isTouch or isMouse) then return end
        pcall(function()
            local x, y
            if isTouch then
                x, y = input.Position.X, input.Position.Y
            else
                local mp = uis2:GetMouseLocation()
                x, y = mp.X, mp.Y
            end
            local pg2 = game:GetService("Players").LocalPlayer:FindFirstChild("PlayerGui")
            if not pg2 then return end
            local objs = pg2:GetGuiObjectsAtPosition(x, y)
            for _, o in ipairs(objs) do
                if HasButton(o) and IsScriptGui(o) then
                    press = { input = input, pos = input.Position }
                    return
                end
            end
        end)
    end)

    uis2.InputEnded:Connect(function(input)
        if press and press.input == input then
            local moved = (input.Position - press.pos).Magnitude
            press = nil
            if moved <= 20 then
                local now = os.clock()
                if (now - ClickSfxLast) >= 0.1 then
                    ClickSfxLast = now
                    ClickSoundPlay()
                end
            end
        end
    end)
end)
