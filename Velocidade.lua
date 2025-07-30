-- Criar GUI simples com botão para velocidade
local player = game.Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local humanoid = char:WaitForChild("Humanoid")

-- Criar a GUI
local gui = Instance.new("ScreenGui", game.CoreGui)
gui.Name = "VelocidadeGui"

-- Criar o fundo (frame)
local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 200, 0, 100)
frame.Position = UDim2.new(0, 100, 0, 100)
frame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
frame.BorderSizePixel = 0

-- Criar o botão
local button = Instance.new("TextButton", frame)
button.Size = UDim2.new(1, -20, 0, 40)
button.Position = UDim2.new(0, 10, 0, 30)
button.Text = "Ativar velocidade"
button.BackgroundColor3 = Color3.fromRGB(70, 130, 180)
button.TextColor3 = Color3.new(1, 1, 1)
button.Font = Enum.Font.SourceSansBold
button.TextSize = 18

-- Lógica do botão
local speedNormal = 16
local speedFast = 32
local usandoRapido = false

button.MouseButton1Click:Connect(function()
    if humanoid then
        usandoRapido = not usandoRapido
        humanoid.WalkSpeed = usandoRapido and speedFast or speedNormal
        button.Text = usandoRapido and "Velocidade normal" or "Ativar velocidade"
    end
end)
