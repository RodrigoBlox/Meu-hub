-- Serviços
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local humanoid = char:WaitForChild("Humanoid")
local cam = workspace.CurrentCamera
local UIS = game:GetService("UserInputService")
local RS = game:GetService("RunService")

-- estado de invisibilidade
local invisivel = false
local originalTransparencies = {}
local originalNameDisplay = humanoid.DisplayDistanceType

-- função para aplicar invisibilidade
local function setInvisibility(on)
	if not player.Character then return end
	local character = player.Character
	if on then
		-- guarda e aplica transparência
		originalTransparencies = {}
		for _, part in pairs(character:GetDescendants()) do
			if part:IsA("BasePart") then
				originalTransparencies[part] = part.Transparency
				part.Transparency = 1
				if part:FindFirstChildOfClass("Decal") then
					for _, d in pairs(part:GetChildren()) do
						if d:IsA("Decal") then
							d.Transparency = 1
						end
					end
				end
			elseif part:IsA("ParticleEmitter") or part:IsA("Trail") then
				part.Enabled = false
			end
		end
		-- esconde nome
		humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
	else
		-- restaura transparência
		for part, orig in pairs(originalTransparencies) do
			if part and part:IsA("BasePart") then
				part.Transparency = orig
				if part:FindFirstChildOfClass("Decal") then
					for _, d in pairs(part:GetChildren()) do
						if d:IsA("Decal") then
							d.Transparency = 0
						end
					end
				end
			end
		end
		-- reativa efeitos simples (não reverte todos os possíveis estados complexos)
		for _, part in pairs(character:GetDescendants()) do
			if part:IsA("ParticleEmitter") or part:IsA("Trail") then
				part.Enabled = true
			end
		end
		humanoid.DisplayDistanceType = originalNameDisplay or Enum.HumanoidDisplayDistanceType.Default
	end
	invisivel = on
end

-- reconectar ao respawn para manter comportamento
player.CharacterAdded:Connect(function(c)
	char = c
	humanoid = char:WaitForChild("Humanoid")
	originalNameDisplay = humanoid.DisplayDistanceType
	if invisivel then
		-- reaplica invisibilidade no novo character
		wait(0.5)
		setInvisibility(true)
	end
end)

-- GUI principal
local gui = Instance.new("ScreenGui", game.CoreGui)
gui.Name = "MeuHub"

local mainFrame = Instance.new("Frame", gui)
mainFrame.Size = UDim2.new(0, 270, 0, 340)
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
scroll.Size = UDim2.new(1, -20, 1, -60)
scroll.Position = UDim2.new(0, 10, 0, 36)
scroll.CanvasSize = UDim2.new(0, 0, 0, 600)
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

-- Fly Gui
local btnFlyGui = criarBotao("Fly Gui", Color3.fromRGB(50, 200, 50))
btnFlyGui.MouseButton1Click:Connect(function()
    local url = "https://rawscripts.net/raw/Universal-Script-fly-gui-v3-46328"
    local sucesso, resultado = pcall(function()
        loadstring(game:HttpGet(url))()
    end)
    if not sucesso then
        warn("Erro ao executar o Fly Gui: " .. tostring(resultado))
    end
end)

-- ESP verde cobrindo todo o player (reimplementado)
local espAtivo = false
local espButton = criarBotao("ESP Verde", Color3.fromRGB(0, 200, 0))
local highlights = {}

-- Garante highlight para o jogador
local function garantirESP(p)
	if p == player then return end
	if not p.Character then return end
	if highlights[p] and highlights[p].Parent and highlights[p].Adornee == p.Character then
		return
	end

	-- Remove antigo se existir
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

-- Remove ESP de um player
local function removerESP(p)
	if highlights[p] then
		highlights[p]:Destroy()
		highlights[p] = nil
	end
end

-- Atualiza todos os jogadores
local function atualizarESPTodos()
	for _, p in pairs(Players:GetPlayers()) do
		if p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
			garantirESP(p)
		else
			removerESP(p)
		end
	end
end

-- Conexões para respawn/entrada/saída
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
		for p in pairs(highlights) do
			removerESP(p)
		end
	else
		atualizarESPTodos()
	end
end)

-- Loop para manter atualizado
task.spawn(function()
	while true do
		if espAtivo then
			atualizarESPTodos()
		end
		wait(1)
	end
end)

-- Invisibilidade
local btnInvisivel = criarBotao("Invisível", Color3.fromRGB(0, 200, 0))
btnInvisivel.MouseButton1Click:Connect(function()
	setInvisibility(not invisivel)
	btnInvisivel.Text = invisivel and "Visível" or "Invisível"
end)

-- Ajuste Dinâmico de WalkSpeed display
local speedAtual = humanoid.WalkSpeed
local labelTitulo = Instance.new("TextLabel")
labelTitulo.Size = UDim2.new(1, 0, 0, 30)
labelTitulo.BackgroundTransparency = 1
labelTitulo.Text = "Walkspeed"
labelTitulo.TextColor3 = Color3.new(1, 1, 1)
labelTitulo.Font = Enum.Font.FredokaOne
labelTitulo.TextSize = 22
labelTitulo.TextStrokeTransparency = 0.6
labelTitulo.Parent = scroll

local labelSpeed = Instance.new("TextLabel")
labelSpeed.Size = UDim2.new(1, 0, 0, 30)
labelSpeed.BackgroundTransparency = 1
labelSpeed.Text = "Velocidade: " .. speedAtual
labelSpeed.TextColor3 = Color3.new(1, 1, 1)
labelSpeed.Font = Enum.Font.FredokaOne
labelSpeed.TextSize = 18
labelSpeed.Parent = scroll

local btnAumentar = criarBotao("Aumentar Velocidade")
btnAumentar.MouseButton1Click:Connect(function()
	speedAtual += 2
	humanoid.WalkSpeed = speedAtual
	labelSpeed.Text = "Velocidade: " .. speedAtual
end)

local btnDiminuir = criarBotao("Diminuir Velocidade")
btnDiminuir.MouseButton1Click:Connect(function()
	speedAtual = math.max(4, speedAtual - 2)
	humanoid.WalkSpeed = speedAtual
	labelSpeed.Text = "Velocidade: " .. speedAtual
end)

-- Tp Tool
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

-- Trazer todos
local btnTrazer = criarBotao("Trazer Todos", Color3.fromRGB(0, 200, 0))
btnTrazer.MouseButton1Click:Connect(function()
    local localPlayer = Players.LocalPlayer
    local myChar = localPlayer.Character
    if not myChar or not myChar:FindFirstChild("HumanoidRootPart") then return end
    local targetPos = myChar.HumanoidRootPart.Position + Vector3.new(0, 5, 0)
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= localPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
            plr.Character.HumanoidRootPart.CFrame = CFrame.new(targetPos + Vector3.new(math.random(-5, 5), 0, math.random(-5, 5)))
        end
    end
end)

-- NoClip
local noclipAtivo = false
local conexaoNoclip = nil
local btnNoclip = criarBotao("Atravessar Paredes", Color3.fromRGB(0, 200, 0))
btnNoclip.MouseButton1Click:Connect(function()
	noclipAtivo = not noclipAtivo
	if noclipAtivo then
		btnNoclip.Text = "NoClip: Ativado"
		conexaoNoclip = game:GetService("RunService").Stepped:Connect(function()
			local character = game.Players.LocalPlayer.Character
			if character then
				for _, parte in pairs(character:GetDescendants()) do
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
local SCRIPT_URL = "https://raw.githubusercontent.com/RodrigoBlox/Meu-hub/refs/heads/main/Auto%20kill%20players"
local executarBtn = Instance.new("TextButton", mainFrame)
executarBtn.Size = UDim2.new(0, 210, 0, 30)
executarBtn.Position = UDim2.new(0, 10, 0, 300)
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
		statusLabel.Text = "Status: erro"
