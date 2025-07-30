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
scroll.CanvasSize = UDim2.new(0, 0, 0, 400)
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
	particle.Color = ColorSequence.new(Color3.fromRGB(0, 255, 0))
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
