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

local btnAimbot = criarBotao("Aimbot + ESP")
local aimbotAtivo = false
local aimbotConnection

btnAimbot.MouseButton1Click:Connect(function()
	aimbotAtivo = not aimbotAtivo
	btnAimbot.Text = aimbotAtivo and "Desativar Aimbot" or "Aimbot + ESP"

	if aimbotAtivo and not aimbotConnection then
		aimbotConnection = RS.RenderStepped:Connect(function()
			local closest = nil
			local shortest = math.huge

			for _, p in ipairs(Players:GetPlayers()) do
				if p ~= player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
					local dist = (p.Character.HumanoidRootPart.Position - char.HumanoidRootPart.Position).Magnitude
					if dist < shortest then
						shortest = dist
						closest = p
					end

					-- ESP Verde (atualiza mesmo se reiniciar)
					if not p.Character:FindFirstChild("ESPBox") then
						local box = Instance.new("BoxHandleAdornment")
						box.Name = "ESPBox"
						box.Adornee = p.Character.HumanoidRootPart
						box.Size = Vector3.new(4, 5, 2)
						box.Color3 = Color3.new(0, 1, 0)
						box.AlwaysOnTop = true
						box.ZIndex = 5
						box.Transparency = 0.3
						box.Parent = p.Character
					end
				end
			end

			-- Aimbot travar câmera no jogador mais próximo
			if closest and closest.Character and closest.Character:FindFirstChild("Head") then
				cam.CFrame = CFrame.new(cam.CFrame.Position, closest.Character.Head.Position)
			end
		end)
	elseif not aimbotAtivo and aimbotConnection then
		aimbotConnection:Disconnect()
		aimbotConnection = nil
	end
end)

-- Atualiza ESP para novos jogadores automaticamente
Players.PlayerAdded:Connect(function(plr)
	plr.CharacterAdded:Connect(function(char)
		repeat wait() until char:FindFirstChild("HumanoidRootPart")
		local box = Instance.new("BoxHandleAdornment")
		box.Name = "ESPBox"
		box.Adornee = char:FindFirstChild("HumanoidRootPart")
		box.Size = Vector3.new(4, 5, 2)
		box.Color3 = Color3.new(0, 1, 0)
		box.AlwaysOnTop = true
		box.ZIndex = 5
		box.Transparency = 0.3
		box.Parent = char
	end)
end)
