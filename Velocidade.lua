-- GUI com UICorner, ScrollingFrame, Voo, Pulo Duplo, Velocidade, Fechar e Drag

local player = game.Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local humanoid = char:WaitForChild("Humanoid")
local UIS = game:GetService("UserInputService")
local RS = game:GetService("RunService")

-- GUI Principal
local gui = Instance.new("ScreenGui", game.CoreGui)
gui.Name = "MeuHub"

local mainFrame = Instance.new("Frame", gui)
mainFrame.Size = UDim2.new(0, 270, 0, 230)
mainFrame.Position = UDim2.new(0, 100, 0, 100)
mainFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)

local mainCorner = Instance.new("UICorner", mainFrame)
mainCorner.CornerRadius = UDim.new(0, 12)

-- Drag (arrastar o menu)
local dragging = false
local dragInput, dragStart, startPos

mainFrame.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = true
		dragStart = input.Position
		startPos = mainFrame.Position
		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then
				dragging = false
			end
		end)
	end
end)

mainFrame.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement then
		dragInput = input
	end
end)

UIS.InputChanged:Connect(function(input)
	if input == dragInput and dragging then
		local delta = input.Position - dragStart
		mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
	end
end)

-- Botão de fechar
local btnFechar = Instance.new("TextButton", mainFrame)
btnFechar.Size = UDim2.new(0, 24, 0, 24)
btnFechar.Position = UDim2.new(1, -30, 0, 6)
btnFechar.Text = "X"
btnFechar.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
btnFechar.TextColor3 = Color3.new(1,1,1)
btnFechar.Font = Enum.Font.SourceSansBold
btnFechar.TextSize = 16

local closeCorner = Instance.new("UICorner", btnFechar)
closeCorner.CornerRadius = UDim.new(0, 8)

btnFechar.MouseButton1Click:Connect(function()
	gui:Destroy()
end)

-- ScrollingFrame
local scroll = Instance.new("ScrollingFrame", mainFrame)
scroll.Size = UDim2.new(1, -20, 1, -50)
scroll.Position = UDim2.new(0, 10, 0, 40)
scroll.CanvasSize = UDim2.new(0, 0, 0, 300)
scroll.ScrollBarThickness = 6
scroll.BackgroundTransparency = 1

local layout = Instance.new("UIListLayout", scroll)
layout.Padding = UDim.new(0, 10)

-- Criar botões com UICorner
local function criarBotao(nome, cor)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1, 0, 0, 40)
	btn.Text = nome
	btn.BackgroundColor3 = cor or Color3.fromRGB(70, 130, 180)
	btn.TextColor3 = Color3.new(1, 1, 1)
	btn.Font = Enum.Font.SourceSansBold
	btn.TextSize = 18
	btn.Parent = scroll

	local corner = Instance.new("UICorner", btn)
	corner.CornerRadius = UDim.new(0, 8)

	return btn
end

-- 🛫 VOO
local btnVoo = criarBotao("Ativar Voo", Color3.fromRGB(85, 170, 255))
local voando = false
local bodyVel = Instance.new("BodyVelocity")
bodyVel.MaxForce = Vector3.new(0, 0, 0)
bodyVel.Velocity = Vector3.new(0, 0, 0)
bodyVel.Parent = char:WaitForChild("HumanoidRootPart")

btnVoo.MouseButton1Click:Connect(function()
	voando = not voando
	bodyVel.MaxForce = voando and Vector3.new(99999, 99999, 99999) or Vector3.new(0, 0, 0)
	btnVoo.Text = voando and "Desativar Voo" or "Ativar Voo"
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

-- 🦘 PULO DUPLO
local btnPulo = criarBotao("Ativar Pulo Duplo", Color3.fromRGB(120, 180, 90))
local pulos = 0
local maxPulos = 2

btnPulo.MouseButton1Click:Connect(function()
	humanoid.UseJumpPower = true
	humanoid.JumpPower = 50
	pulos = 0

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

-- ⚡ VELOCIDADE DUPLA
local btnSpeed = criarBotao("Ativar Velocidade X2", Color3.fromRGB(255, 180, 60))
local speedNormal = 16
local speedRapido = 32
local usandoSpeed = false

btnSpeed.MouseButton1Click:Connect(function()
	usandoSpeed = not usandoSpeed
	humanoid.WalkSpeed = usandoSpeed and speedRapido or speedNormal
	btnSpeed.Text = usandoSpeed and "Velocidade Normal" or "Ativar Velocidade X2"
end)
-- CONTINUAÇÃO DO SCRIPT ANTERIOR
-- Adicionando botão de reabrir via ImageButton

-- Botão flutuante para reabrir a GUI
local openButton = Instance.new("ImageButton")
openButton.Parent = gui
openButton.Size = UDim2.new(0, 40, 0, 40)
openButton.Position = UDim2.new(0, 10, 0, 10)
openButton.Image = "rbxassetid://100696306384924" -- ícone de engrenagem ⚙️
openButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
openButton.Visible = false
Instance.new("UICorner", openButton).CornerRadius = UDim.new(1, 0)

-- Botão de fechar (agora ele esconde)
closeBtn.MouseButton1Click:Connect(function()
	mainFrame.Visible = false
	openButton.Visible = true
end)

-- Clicar no ImageButton reabre a GUI
openButton.MouseButton1Click:Connect(function()
	mainFrame.Visible = true
	openButton.Visible = false
end)
