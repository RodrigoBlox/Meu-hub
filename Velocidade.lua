-- Serviços
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local humanoid = char:WaitForChild("Humanoid")
local cam = workspace.CurrentCamera
local UIS = game:GetService("UserInputService")
local RS = game:GetService("RunService")

-- GUI principal
local gui = Instance.new("ScreenGui", game.CoreGui)
gui.Name = "MeuHub"

local mainFrame = Instance.new("Frame", gui)
mainFrame.Size = UDim2.new(0, 270, 0, 250)
mainFrame.Position = UDim2.new(0, 100, 0, 100)
mainFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
mainFrame.Active = true
mainFrame.Draggable = true
Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 12)

-- Botão de fechar
local closeBtn = Instance.new("TextButton", mainFrame)
closeBtn.Size = UDim2.new(0, 24, 0, 24)
closeBtn.Position = UDim2.new(1, -28, 0, 4)
closeBtn.Text = "X"
closeBtn.TextSize = 16
closeBtn.TextColor3 = Color3.new(1, 1, 1)
closeBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(1, 0)

-- Botão flutuante para reabrir
local openBtn = Instance.new("ImageButton", gui)
openBtn.Size = UDim2.new(0, 40, 0, 40)
openBtn.Position = UDim2.new(0, 10, 0, 10)
openBtn.Image = "rbxassetid://6031097225"
openBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
openBtn.Visible = false
Instance.new("UICorner", openBtn).CornerRadius = UDim.new(1, 0)

closeBtn.MouseButton1Click:Connect(function()
	mainFrame.Visible = false
	openBtn.Visible = true
end)

openBtn.MouseButton1Click:Connect(function()
	mainFrame.Visible = true
	openBtn.Visible = false
end)

-- ScrollingFrame
local scroll = Instance.new("ScrollingFrame", mainFrame)
scroll.Size = UDim2.new(1, -20, 1, -40)
scroll.Position = UDim2.new(0, 10, 0, 36)
scroll.CanvasSize = UDim2.new(0, 0, 0, 500)
scroll.ScrollBarThickness = 6
scroll.BackgroundTransparency = 1

local layout = Instance.new("UIListLayout", scroll)
layout.Padding = UDim.new(0, 10)

-- Botão Criador
local function criarBotao(nome, cor)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1, 0, 0, 40)
	btn.Text = nome
	btn.BackgroundColor3 = cor or Color3.fromRGB(70, 130, 180)
	btn.TextColor3 = Color3.new(1, 1, 1)
	btn.Font = Enum.Font.SourceSansBold
	btn.TextSize = 18
	Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
	btn.Parent = scroll
	return btn
end

-- Função criarBotao (assumo que você já tem no seu script, como nos anteriores)
-- Exemplo de uso no seu GUI:
local btnFlyGui = criarBotao("Fly Gui", Color3.fromRGB(50, 200, 50)) -- Botão verde

btnFlyGui.MouseButton1Click:Connect(function()
    local url = "https://rawscripts.net/raw/Universal-Script-fly-gui-v3-46328"
    local sucesso, resultado = pcall(function()
        loadstring(game:HttpGet(url))()
    end)

    if not sucesso then
        warn("Erro ao executar o Fly Gui: " .. tostring(resultado))
    end
end)

-- Velocidade
local btnSpeed = criarBotao("Velocidade X2")
local speedNormal = 16
local speedFast = 32
local usandoSpeed = false

btnSpeed.MouseButton1Click:Connect(function()
	usandoSpeed = not usandoSpeed
	humanoid.WalkSpeed = usandoSpeed and speedFast or speedNormal
	btnSpeed.Text = usandoSpeed and "Velocidade Normal" or "Velocidade X2"
end)

-- Pulo Duplo
local btnPulo = criarBotao("Pulo Duplo")
local pulos = 0
local maxPulos = 2
local ativadoPulo = false

btnPulo.MouseButton1Click:Connect(function()
	if ativadoPulo then return end
	ativadoPulo = true
	humanoid.UseJumpPower = true
	humanoid.JumpPower = 50

	humanoid.StateChanged:Connect(function(_, state)
		if state == Enum.HumanoidStateType.Landed then
			pulos = 0
		end
	end)

	UIS.JumpRequest:Connect(function()
		if pulos < maxPulos then
			humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
			pulos += 1
		end
	end)

	btnPulo.Text = "Pulo Duplo Ativado"
	btnPulo.AutoButtonColor = false
end)

local btnAuraESP = criarBotao("Aura Verde ESP")
local auraAtivo = false

-- Função para criar Aura ESP
local function adicionarAura(playerAlvo)
	local hrp = playerAlvo.Character and playerAlvo.Character:FindFirstChild("HumanoidRootPart")
	if not hrp then return end
	if hrp:FindFirstChild("AuraESP") then return end -- Já existe

	local particle = Instance.new("ParticleEmitter")
	particle.Name = "AuraESP"
	particle.Texture = "rbxassetid://243660364" -- textura suave circular
	particle.Rate = 40
	particle.Lifetime = NumberRange.new(1)
	particle.Speed = NumberRange.new(0)
	particle.Size = NumberSequence.new(3)
	particle.Color = ColorSequence.new(Color3.fromRGB(0, 200, 0))
	particle.LightEmission = 1
	particle.Transparency = NumberSequence.new(0.3)
	particle.Rotation = NumberRange.new(0, 360)
	particle.RotSpeed = NumberRange.new(30)
	particle.Parent = hrp
end

-- Atualiza para todos os jogadores
local function aplicarAuraEmTodos()
	for _, p in ipairs(Players:GetPlayers()) do
		if p ~= player and p.Character then
			adicionarAura(p)
		end
	end
end

-- Ativa / desativa a Aura ESP
btnAuraESP.MouseButton1Click:Connect(function()
	auraAtivo = not auraAtivo
	btnAuraESP.Text = auraAtivo and "Desativar Aura ESP" or "Aura Verde ESP"

	if auraAtivo then
		aplicarAuraEmTodos()

		-- Adiciona aura quando alguém entrar
		Players.PlayerAdded:Connect(function(plr)
			plr.CharacterAdded:Connect(function()
				repeat wait() until plr.Character:FindFirstChild("HumanoidRootPart")
				adicionarAura(plr)
			end)
		end)
	end
end)

-- Ajuste Dinâmico de WalkSpeed
local speedAtual = humanoid.WalkSpeed
local labelTitulo = Instance.new("TextLabel")
labelTitulo.Size = UDim2.new(1, 0, 0, 30)
labelTitulo.BackgroundTransparency = 1
labelTitulo.Text = "Walkspeed"
labelTitulo.TextColor3 = Color3.new(1, 1, 1)
labelTitulo.Font = Enum.Font.FredokaOne
labelTitulo.TextSize = 22
labelTitulo.TextStrokeTransparency = 0.6
labelTitulo.Parent = scroll -- ou onde você estiver organizando os botões
-- Label do valor
local labelSpeed = Instance.new("TextLabel")
labelSpeed.Size = UDim2.new(1, 0, 0, 30)
labelSpeed.BackgroundTransparency = 1
labelSpeed.Text = "Velocidade: " .. speedAtual
labelSpeed.TextColor3 = Color3.new(1, 1, 1)
labelSpeed.Font = Enum.Font.FredokaOne
labelSpeed.TextSize = 18
labelSpeed.Parent = scroll

-- Botão Aumentar
local btnAumentar = criarBotao("Aumentar Velocidade")
btnAumentar.MouseButton1Click:Connect(function()
	speedAtual += 2
	humanoid.WalkSpeed = speedAtual
	labelSpeed.Text = "Velocidade: " .. speedAtual
end)

-- Botão Diminuir
local btnDiminuir = criarBotao("Diminuir Velocidade")
btnDiminuir.MouseButton1Click:Connect(function()
	speedAtual = math.max(4, speedAtual - 2)
	humanoid.WalkSpeed = speedAtual
	labelSpeed.Text = "Velocidade: " .. speedAtual
end)

local btnTpTool = criarBotao("Receber Tp Tool", Color3.fromRGB(0, 200, 0))

btnTpTool.MouseButton1Click:Connect(function()
	local tool = Instance.new("Tool")
	tool.Name = "tptool"
	tool.RequiresHandle = false
	tool.CanBeDropped = false

	local equipped = false

	tool.Equipped:Connect(function()
		equipped = true
	end)

	tool.Unequipped:Connect(function()
		equipped = false
	end)

	tool.Activated:Connect(function()
		if equipped then
			local mouse = player:GetMouse()
			local pos = mouse.Hit.Position
			if pos then
				char:SetPrimaryPartCFrame(CFrame.new(pos + Vector3.new(0, 5, 0)))
			end
		end
	end)

	tool.Parent = player.Backpack
end)

-- Adiciona botão no seu GUI personalizado
local btnTrazer = criarBotao("Trazer Todos", Color3.fromRGB(0, 200, 0)) -- Botão verde

btnTrazer.MouseButton1Click:Connect(function()
    local Players = game:GetService("Players")
    local localPlayer = Players.LocalPlayer
    local myChar = localPlayer.Character

    if not myChar or not myChar:FindFirstChild("HumanoidRootPart") then return end
    local targetPos = myChar.HumanoidRootPart.Position + Vector3.new(0, 5, 0)

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= localPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            player.Character.HumanoidRootPart.CFrame = CFrame.new(targetPos + Vector3.new(math.random(-5, 5), 0, math.random(-5, 5)))
        end
    end
end)

local noclipAtivo = false
local conexaoNoclip = nil

local btnNoclip = criarBotao("Atravessar Paredes", Color3.fromRGB(0, 200, 0)) -- Verde

btnNoclip.MouseButton1Click:Connect(function()
	noclipAtivo = not noclipAtivo
	
	if noclipAtivo then
		btnNoclip.Text = "NoClip: Ativado"
		conexaoNoclip = game:GetService("RunService").Stepped:Connect(function()
			local char = game.Players.LocalPlayer.Character
			if char then
				for _, parte in pairs(char:GetDescendants()) do
					if parte:IsA("BasePart") and parte.CanCollide == true then
						parte.CanCollide = false
					end
				end
			end
		end)
	else
		btnNoclip.Text = "Atravessar Paredes"
		if conexaoNoclip then
			conexaoNoclip:Disconnect()
			conexaoNoclip = nil
		end
	end
end)

-- Criar o painel do botão no seu scroll existente
local scroll = -- coloque aqui sua referência do ScrollingFrame, por exemplo: script.Parent.ScrollingFrame

local Players = game:GetService("Players")
local player = Players.LocalPlayer

local hitboxSize = 2

-- Função para aplicar hitbox nos outros jogadores
local function aplicarHitbox(tamanho)
	for _, p in pairs(Players:GetPlayers()) do
		if p ~= player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
			local hrp = p.Character.HumanoidRootPart
			hrp.Size = Vector3.new(tamanho, tamanho, tamanho)
			hrp.Transparency = 0.5
			hrp.Material = Enum.Material.ForceField
			hrp.CanCollide = false
		end
	end
end

-- Container do painel
local hitboxFrame = Instance.new("Frame")
hitboxFrame.Size = UDim2.new(1, 0, 0, 100)
hitboxFrame.BackgroundTransparency = 1
hitboxFrame.Parent = scroll

-- Botão de Aumentar Hitbox
local plusBtn = Instance.new("TextButton")
plusBtn.Text = "+"
plusBtn.Size = UDim2.new(0, 40, 0, 40)
plusBtn.Position = UDim2.new(0, 5, 0, 5)
plusBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
plusBtn.TextColor3 = Color3.new(1, 1, 1)
plusBtn.Font = Enum.Font.FredokaOne
plusBtn.TextSize = 24
plusBtn.Parent = hitboxFrame
Instance.new("UICorner", plusBtn).CornerRadius = UDim.new(0, 8)

-- Botão de Diminuir Hitbox
local minusBtn = Instance.new("TextButton")
minusBtn.Text = "-"
minusBtn.Size = UDim2.new(0, 40, 0, 40)
minusBtn.Position = UDim2.new(1, -45, 0, 5)
minusBtn.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
minusBtn.TextColor3 = Color3.new(1, 1, 1)
minusBtn.Font = Enum.Font.FredokaOne
minusBtn.TextSize = 24
minusBtn.Parent = hitboxFrame
Instance.new("UICorner", minusBtn).CornerRadius = UDim.new(0, 8)

-- Título "Hitbox"
local titleLbl = Instance.new("TextLabel")
titleLbl.Text = "Hitbox"
titleLbl.Size = UDim2.new(0, 100, 0, 40)
titleLbl.Position = UDim2.new(0.5, -50, 0, 5)
titleLbl.BackgroundTransparency = 1
titleLbl.TextColor3 = Color3.new(1, 1, 1)
titleLbl.Font = Enum.Font.FredokaOne
titleLbl.TextSize = 22
titleLbl.Parent = hitboxFrame

-- Texto com o valor atual
local valueLbl = Instance.new("TextLabel")
valueLbl.Text = "Tamanho: " .. hitboxSize
valueLbl.Size = UDim2.new(1, 0, 0, 25)
valueLbl.Position = UDim2.new(0, 0, 1, -25)
valueLbl.BackgroundTransparency = 1
valueLbl.TextColor3 = Color3.new(1, 1, 1)
valueLbl.Font = Enum.Font.FredokaOne
valueLbl.TextSize = 18
valueLbl.Parent = hitboxFrame

-- Conexões dos botões
plusBtn.MouseButton1Click:Connect(function()
	hitboxSize += 1
	valueLbl.Text = "Tamanho: " .. hitboxSize
	aplicarHitbox(hitboxSize)
end)

minusBtn.MouseButton1Click:Connect(function()
	hitboxSize = math.max(1, hitboxSize - 1)
	valueLbl.Text = "Tamanho: " .. hitboxSize
	aplicarHitbox(hitboxSize)
end)

-- Aplica a hitbox inicial
aplicarHitbox(hitboxSize)

local btnHitbox = criarBotao("Abrir Hitbox GUI", Color3.fromRGB(0, 255, 100))

loadstring([[
-- Serviços
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local LocalPlayer = Players.LocalPlayer

-- Variáveis
local hitboxSize = 2
local autoKillAll = false
local autoClickerEnabled = false
local fpsBoost = false

-- GUI principal
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
ScreenGui.Name = "HitboxGui"

-- Frame
local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 240, 0, 260)
MainFrame.Position = UDim2.new(0.5, -120, 0.4, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MainFrame.Active = true
MainFrame.Draggable = true
Instance.new("UICorner", MainFrame)

-- Título
local Title = Instance.new("TextLabel", MainFrame)
Title.Size = UDim2.new(1, 0, 0, 30)
Title.Text = "Hitbox"
Title.Font = Enum.Font.FredokaOne
Title.TextSize = 22
Title.TextColor3 = Color3.new(1,1,1)
Title.BackgroundTransparency = 1

-- Valor da hitbox
local ValueLabel = Instance.new("TextLabel", MainFrame)
ValueLabel.Position = UDim2.new(0, 0, 0, 30)
ValueLabel.Size = UDim2.new(1, 0, 0, 25)
ValueLabel.Text = "Tamanho: " .. hitboxSize
ValueLabel.Font = Enum.Font.FredokaOne
ValueLabel.TextSize = 20
ValueLabel.TextColor3 = Color3.new(1,1,1)
ValueLabel.BackgroundTransparency = 1

-- Botão +
local PlusButton = Instance.new("TextButton", MainFrame)
PlusButton.Position = UDim2.new(0, 10, 0, 60)
PlusButton.Size = UDim2.new(0, 60, 0, 30)
PlusButton.Text = "+"
PlusButton.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
PlusButton.Font = Enum.Font.FredokaOne
PlusButton.TextSize = 22
PlusButton.TextColor3 = Color3.new(1, 1, 1)
Instance.new("UICorner", PlusButton)

-- Botão -
local MinusButton = Instance.new("TextButton", MainFrame)
MinusButton.Position = UDim2.new(0, 80, 0, 60)
MinusButton.Size = UDim2.new(0, 60, 0, 30)
MinusButton.Text = "-"
MinusButton.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
MinusButton.Font = Enum.Font.FredokaOne
MinusButton.TextSize = 22
MinusButton.TextColor3 = Color3.new(1, 1, 1)
Instance.new("UICorner", MinusButton)

-- Botão Fechar
local CloseButton = Instance.new("TextButton", MainFrame)
CloseButton.Position = UDim2.new(1, -25, 0, 5)
CloseButton.Size = UDim2.new(0, 20, 0, 20)
CloseButton.Text = "X"
CloseButton.BackgroundColor3 = Color3.fromRGB(255, 70, 70)
CloseButton.Font = Enum.Font.FredokaOne
CloseButton.TextSize = 16
CloseButton.TextColor3 = Color3.new(1, 1, 1)
Instance.new("UICorner", CloseButton)

-- Botão Abrir
local OpenButton = Instance.new("TextButton", ScreenGui)
OpenButton.Size = UDim2.new(0, 100, 0, 30)
OpenButton.Position = UDim2.new(0.5, -50, 0.9, 0)
OpenButton.Text = "Abrir Hitbox"
OpenButton.BackgroundColor3 = Color3.fromRGB(50, 150, 255)
OpenButton.Font = Enum.Font.FredokaOne
OpenButton.TextSize = 18
OpenButton.TextColor3 = Color3.new(1, 1, 1)
OpenButton.Visible = false
Instance.new("UICorner", OpenButton)

-- Botão Auto Kill All
local AutoKillButton = Instance.new("TextButton", MainFrame)
AutoKillButton.Position = UDim2.new(0, 10, 0, 100)
AutoKillButton.Size = UDim2.new(0, 210, 0, 30)
AutoKillButton.Text = "Auto Kill All (OFF)"
AutoKillButton.BackgroundColor3 = Color3.fromRGB(255, 100, 0)
AutoKillButton.Font = Enum.Font.FredokaOne
AutoKillButton.TextSize = 18
AutoKillButton.TextColor3 = Color3.new(1, 1, 1)
Instance.new("UICorner", AutoKillButton)

-- Botão Auto Clicker
local AutoClickerButton = Instance.new("TextButton", MainFrame)
AutoClickerButton.Position = UDim2.new(0, 10, 0, 140)
AutoClickerButton.Size = UDim2.new(0, 210, 0, 30)
AutoClickerButton.Text = "Ativar Auto Clicker"
AutoClickerButton.BackgroundColor3 = Color3.fromRGB(80, 160, 250)
AutoClickerButton.Font = Enum.Font.FredokaOne
AutoClickerButton.TextSize = 18
AutoClickerButton.TextColor3 = Color3.new(1, 1, 1)
Instance.new("UICorner", AutoClickerButton)

-- Botão FPS Boost
local FpsBoostButton = Instance.new("TextButton", MainFrame)
FpsBoostButton.Position = UDim2.new(0, 10, 0, 180)
FpsBoostButton.Size = UDim2.new(0, 210, 0, 30)
FpsBoostButton.Text = "FPS Boost (OFF)"
FpsBoostButton.BackgroundColor3 = Color3.fromRGB(150, 150, 150)
FpsBoostButton.Font = Enum.Font.FredokaOne
FpsBoostButton.TextSize = 18
FpsBoostButton.TextColor3 = Color3.new(1, 1, 1)
Instance.new("UICorner", FpsBoostButton)

-- Aplicar Hitbox
local function aplicarHitbox(tamanho)
	for _, p in pairs(Players:GetPlayers()) do
		if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
			local hrp = p.Character.HumanoidRootPart
			hrp.Size = Vector3.new(tamanho, tamanho, tamanho)
			hrp.Transparency = fpsBoost and 1 or 0.5
			hrp.Material = Enum.Material.ForceField
			hrp.CanCollide = false
		end
	end
end

-- Noclip
RunService.Stepped:Connect(function()
	if autoKillAll and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
		for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
			if part:IsA("BasePart") then
				part.CanCollide = false
			end
		end
	end
end)

-- Auto Kill Loop
task.spawn(function()
	while true do
		if autoKillAll then
			for _, target in pairs(Players:GetPlayers()) do
				if target ~= LocalPlayer and target.Character and target.Character:FindFirstChild("Humanoid") and target.Character:FindFirstChild("HumanoidRootPart") then
					LocalPlayer.Character.HumanoidRootPart.CFrame = target.Character.HumanoidRootPart.CFrame + Vector3.new(0, 2, 0)
					task.wait(0.2)
					target.Character.Humanoid.Health = 0
				end
			end
		end
		task.wait(2)
	end
end)

-- Auto Clicker Loop
task.spawn(function()
	while true do
		if autoClickerEnabled then
			local mouseLocation = UserInputService:GetMouseLocation()
			VirtualInputManager:SendMouseButtonEvent(mouseLocation.X, mouseLocation.Y, 0, true, game, 0)
			wait(0.05)
			VirtualInputManager:SendMouseButtonEvent(mouseLocation.X, mouseLocation.Y, 0, false, game, 0)
		end
		wait(1)
	end
end)

-- Botão +
PlusButton.MouseButton1Click:Connect(function()
	hitboxSize += 1
	ValueLabel.Text = "Tamanho: " .. hitboxSize
	aplicarHitbox(hitboxSize)
end)

-- Botão -
MinusButton.MouseButton1Click:Connect(function()
	hitboxSize = math.max(1, hitboxSize - 1)
	ValueLabel.Text = "Tamanho: " .. hitboxSize
	aplicarHitbox(hitboxSize)
end)

-- Fechar
CloseButton.MouseButton1Click:Connect(function()
	MainFrame.Visible = false
	OpenButton.Visible = true
end)

-- Abrir
OpenButton.MouseButton1Click:Connect(function()
	MainFrame.Visible = true
	OpenButton.Visible = false
end)

-- Auto Kill Toggle
AutoKillButton.MouseButton1Click:Connect(function()
	autoKillAll = not autoKillAll
	AutoKillButton.Text = "Auto Kill All (" .. (autoKillAll and "ON" or "OFF") .. ")"
	if autoKillAll then
		hitboxSize = 500
		ValueLabel.Text = "Tamanho: " .. hitboxSize
		aplicarHitbox(hitboxSize)
	end
end)

-- Auto Clicker Toggle
AutoClickerButton.MouseButton1Click:Connect(function()
	autoClickerEnabled = not autoClickerEnabled
	if autoClickerEnabled then
		AutoClickerButton.Text = "Desativar Auto Clicker"
		AutoClickerButton.BackgroundColor3 = Color3.fromRGB(250, 100, 100)
	else
		AutoClickerButton.Text = "Ativar Auto Clicker"
		AutoClickerButton.BackgroundColor3 = Color3.fromRGB(80, 160, 250)
	end
end)

-- FPS Boost Toggle
FpsBoostButton.MouseButton1Click:Connect(function()
	fpsBoost = not fpsBoost
	FpsBoostButton.Text = "FPS Boost (" .. (fpsBoost and "ON" or "OFF") .. ")"
	FpsBoostButton.BackgroundColor3 = fpsBoost and Color3.fromRGB(0, 200, 255) or Color3.fromRGB(150, 150, 150)
	aplicarHitbox(hitboxSize)
end)

-- Atualizar hitbox a cada 3 segundos
while true do
	aplicarHitbox(hitboxSize)
	wait(3)
end
]])()