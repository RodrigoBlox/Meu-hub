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
scroll.CanvasSize = UDim2.new(0, 0, 0, 300)
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

-- Voo
local btnVoo = criarBotao("Voo")
local voando = false
local bodyVel = Instance.new("BodyVelocity", char:WaitForChild("HumanoidRootPart"))
bodyVel.MaxForce = Vector3.new()
bodyVel.Velocity = Vector3.new()

btnVoo.MouseButton1Click:Connect(function()
	voando = not voando
	bodyVel.MaxForce = voando and Vector3.new(99999, 99999, 99999) or Vector3.new()
	btnVoo.Text = voando and "Desativar Voo" or "Voo"
end)

RS.RenderStepped:Connect(function()
	if voando then
		local dir = Vector3.new()
		if UIS:IsKeyDown(Enum.KeyCode.W) then dir += char.HumanoidRootPart.CFrame.LookVector end
		if UIS:IsKeyDown(Enum.KeyCode.S) then dir -= char.HumanoidRootPart.CFrame.LookVector end
		if UIS:IsKeyDown(Enum.KeyCode.A) then dir -= char.HumanoidRootPart.CFrame.RightVector end
		if UIS:IsKeyDown(Enum.KeyCode.D) then dir += char.HumanoidRootPart.CFrame.RightVector end
		bodyVel.Velocity = dir.Unit * 50
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

-- Frame para controle de velocidade
local speedFrame = Instance.new("Frame")
speedFrame.Name = "SpeedControl"
speedFrame.Size = UDim2.new(0, 200, 0, 50)
speedFrame.Position = UDim2.new(0, 10, 0, 250)
speedFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
speedFrame.Parent = mainFrame
Instance.new("UICorner", speedFrame).CornerRadius = UDim.new(0, 8)

-- Texto da velocidade
local speedLabel = Instance.new("TextLabel")
speedLabel.Size = UDim2.new(0, 100, 1, 0)
speedLabel.Position = UDim2.new(0, 50, 0, 0)
speedLabel.Text = "Velocidade: 16"
speedLabel.TextColor3 = Color3.new(1,1,1)
speedLabel.BackgroundTransparency = 1
speedLabel.TextScaled = true
speedLabel.Font = Enum.Font.SourceSansBold
speedLabel.Parent = speedFrame

-- Botão de diminuir velocidade
local menosBtn = Instance.new("TextButton")
menosBtn.Size = UDim2.new(0, 40, 1, 0)
menosBtn.Position = UDim2.new(0, 0, 0, 0)
menosBtn.Text = "-"
menosBtn.TextColor3 = Color3.new(1,1,1)
menosBtn.BackgroundColor3 = Color3.fromRGB(70,70,70)
menosBtn.Font = Enum.Font.SourceSansBold
menosBtn.TextScaled = true
menosBtn.Parent = speedFrame
Instance.new("UICorner", menosBtn).CornerRadius = UDim.new(0, 6)

-- Botão de aumentar velocidade
local maisBtn = Instance.new("TextButton")
maisBtn.Size = UDim2.new(0, 40, 1, 0)
maisBtn.Position = UDim2.new(0, 160, 0, 0)
maisBtn.Text = "+"
maisBtn.TextColor3 = Color3.new(1,1,1)
maisBtn.BackgroundColor3 = Color3.fromRGB(70,70,70)
maisBtn.Font = Enum.Font.SourceSansBold
maisBtn.TextScaled = true
maisBtn.Parent = speedFrame
Instance.new("UICorner", maisBtn).CornerRadius = UDim.new(0, 6)

-- Variável de controle da velocidade
local currentSpeed = 16
local humanoid = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
if humanoid then humanoid.WalkSpeed = currentSpeed end

-- Funções de aumentar/diminuir
menosBtn.MouseButton1Click:Connect(function()
	currentSpeed = math.max(4, currentSpeed - 2)
	if humanoid then humanoid.WalkSpeed = currentSpeed end
	speedLabel.Text = "Velocidade: " .. tostring(currentSpeed)
end)

maisBtn.MouseButton1Click:Connect(function()
	currentSpeed = math.min(200, currentSpeed + 2)
	if humanoid then humanoid.WalkSpeed = currentSpeed end
	speedLabel.Text = "Velocidade: " .. tostring(currentSpeed)
end)

-- Atualiza caso o personagem morra e respawne
player.CharacterAdded:Connect(function(char)
	repeat wait() until char:FindFirstChildOfClass("Humanoid")
	humanoid = char:FindFirstChildOfClass("Humanoid")
	humanoid.WalkSpeed = currentSpeed
end)
