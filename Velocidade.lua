local player = game.Players.LocalPlayer
local humanoid = player.Character:FindFirstChild("Humanoid")

if humanoid then
    humanoid.WalkSpeed = humanoid.WalkSpeed == 16 and 32 or 16
end
