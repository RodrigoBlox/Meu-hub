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

-- botão verde que executa um script remoto
local SCRIPT_URL = "https://raw.githubusercontent.com/RodrigoBlox/Meu-hub/refs/heads/main/Auto%20kill%20players" -- substitua pela URL raw do script desejado

local executarBtn = Instance.new("TextButton", mainFrame) -- assume que mainFrame já existe
executarBtn.Size = UDim2.new(0, 210, 0, 30)
executarBtn.Position = UDim2.new(0, 10, 0, 300) -- ajuste conforme layout
executarBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
executarBtn.TextColor3 = Color3.new(1,1,1)
executarBtn.Font = Enum.Font.FredokaOne
executarBtn.TextSize = 18
executarBtn.Text = "Executar Script"
Instance.new("UICorner", executarBtn).CornerRadius = UDim.new(0, 6)

-- feedback simples
local statusLabel = Instance.new("TextLabel", mainFrame)
statusLabel.Size = UDim2.new(1, -20, 0, 18)
statusLabel.Position = UDim2.new(0, 10, 0, 335)
statusLabel.BackgroundTransparency = 1
statusLabel.TextColor3 = Color3.new(1,1,1)
statusLabel.Font = Enum.Font.SourceSans
statusLabel.TextSize = 14
statusLabel.Text = "Status: aguardando"
statusLabel.TextXAlignment = Enum.TextXAlignment.Left

executarBtn.MouseButton1Click:Connect(function()
	statusLabel.Text = "Status: baixando..."
	local ok, content = pcall(game.HttpGet, game, SCRIPT_URL)
	if not ok then
		statusLabel.Text = "Status: erro no download"
		warn("Falha HttpGet:", content)
		return
	end

	statusLabel.Text = "Status: compilando..."
	local func, err = loadstring(content)
	if not func then
		statusLabel.Text = "Status: erro ao compilar"
		warn("Erro loadstring:", err)
		return
	end

	statusLabel.Text = "Status: executando..."
	local success, execErr = pcall(func)
	if not success then
		statusLabel.Text = "Status: falha na execução"
		warn("Erro na execução:", execErr)
		return
	end

	statusLabel.Text = "Status: script executado"
end)

-- ESP verde cobrindo todo o player
local espAtivo = false
local espButton = criarBotao("ESP Verde", Color3.fromRGB(0, 200, 0))
local highlights = {}

-- Cria ou atualiza highlight de um jogador
local function garantirESP(p)
	if p == player then return end
	if not p.Character then return end
	if highlights[p] and highlights[p].Parent and highlights[p].Adornee == p.Character:FindFirstChildWhichIsA("BasePart") then
		return
	end

	-- limpando antigo se existir
	if highlights[p] then
		highlights[p]:Destroy()
	end

	local highlight = Instance.new("Highlight")
	highlight.Name = "ESPHighlight"
	highlight.FillColor = Color3.fromRGB(0, 255, 0)
	highlight.OutlineColor = Color3.fromRGB(0, 255, 0)
	highlight.FillTransparency = 0.5
	highlight.OutlineTransparency = 0
	highlight.Adornee = p.Character
	highlight.Parent = gui
	highlights[p] = highlight
end

-- Remove ESP de jogador que saiu ou morreu
local function removerESP(p)
	if highlights[p] then
		highlights[p]:Destroy()
		highlights[p] = nil
	end
end

-- Atualiza todos periodicamente
local function atualizarESPTodos()
	for _, p in pairs(Players:GetPlayers()) do
		if p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
			garantirESP(p)
		else
			removerESP(p)
		end
	end
end

-- Conexões para respawn e entrada/saída
Players.PlayerAdded:Connect(function(p)
	p.CharacterAdded:Connect(function()
		repeat wait() until p.Character and p.Character:FindFirstChild("HumanoidRootPart")
		if espAtivo then
			garantirESP(p)
		end
	end)
end)

Players.PlayerRemoving:Connect(function(p)
	removerESP(p)
end)

-- Toggle do ESP
espButton.MouseButton1Click:Connect(function()
	espAtivo = not espAtivo
	espButton.Text = espAtivo and "ESP Verde (ON)" or "ESP Verde"
	if not espAtivo then
		-- limpa tudo
		for p, _ in pairs(highlights) do
			removerESP(p)
		end
	else
		atualizarESPTodos()
	end
end)

-- Loop de atualização a cada segundo enquanto ativo
task.spawn(function()
	while true do
		if espAtivo then
			atualizarESPTodos()
		end
		wait(1)
	end
end)
