-- Five Nights Hunted Cheat Script
-- Ersteller: [Dein Name]
-- Version: 1.0

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

-- UI Variablen
local ScreenGui = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local TitleLabel = Instance.new("TextLabel")
local SpeedSlider = Instance.new("TextButton")
local NoClipButton = Instance.new("TextButton")
local ESPButton = Instance.new("TextButton")
local JumpButton = Instance.new("TextButton")
local FullbrightButton = Instance.new("TextButton")
local TargetFollowButton = Instance.new("TextButton")
local MinimizeButton = Instance.new("TextButton")
local CloseButton = Instance.new("TextButton")
local FlyButton = Instance.new("TextButton")w


-- Zustandsvariablen
local isUIVisible = true
local isNoClip = false
local isESP = false
local isFullbright = false
local isTargetFollow = false
local targetPlayer = nil
local speedMultiplier = 1
local jumpMultiplier = 1.5
local espObjects = {}
local moderatorNames = {"Admin", "Moderator", "Dev", "Owner"} -- Erweiterbare Moderator-Namensliste
local originalLightingSettings = {}

-- Target Follow UI Elemente (am Anfang mit den anderen UI-Variablen hinzufügen)
local TargetFollowFrame = Instance.new("Frame")
local PlayerListFrame = Instance.new("ScrollingFrame")
local PlayerListLayout = Instance.new("UIListLayout")
local selectedPlayerButton = nil -- Variable, um den ausgewählten Button zu speichern

local noJumpCooldown = false



-- UI Setup
ScreenGui.Parent = game:GetService("CoreGui")
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.new(0, 0, 0)
MainFrame.BorderColor3 = Color3.new(0.5, 0, 1)
MainFrame.BorderSizePixel = 2
MainFrame.Position = UDim2.new(0.1, 0, 0.3, 0)
MainFrame.Size = UDim2.new(0, 300, 0, 400)
MainFrame.Active = true
MainFrame.Draggable = true

TitleLabel.Parent = MainFrame
TitleLabel.BackgroundColor3 = Color3.new(0, 0, 0)
TitleLabel.BorderColor3 = Color3.new(0.5, 0, 1)
TitleLabel.BorderSizePixel = 1
TitleLabel.Position = UDim2.new(0, 0, 0, 0)
TitleLabel.Size = UDim2.new(1, 0, 0, 30)
TitleLabel.Font = Enum.Font.SourceSansBold
TitleLabel.Text = "Five Nights Hunted Cheat"
TitleLabel.TextColor3 = Color3.new(0.5, 0, 1)
TitleLabel.TextSize = 18

-- ... (im UI Setup Bereich)
TargetFollowFrame.Parent = ScreenGui
TargetFollowFrame.BackgroundColor3 = Color3.new(0, 0, 0)
TargetFollowFrame.BorderColor3 = Color3.new(0.5, 0, 1)
TargetFollowFrame.BorderSizePixel = 2
TargetFollowFrame.Position = UDim2.new(0.5, -150, 0.5, -100)
TargetFollowFrame.Size = UDim2.new(0, 300, 0, 200)
TargetFollowFrame.Visible = false -- Standardmäßig unsichtbar
TargetFollowFrame.Active = true
TargetFollowFrame.Draggable = true

PlayerListFrame.Parent = TargetFollowFrame
PlayerListFrame.BackgroundColor3 = Color3.new(0.05, 0, 0.2)
PlayerListFrame.BorderSizePixel = 0
PlayerListFrame.Position = UDim2.new(0, 10, 0, 40)
PlayerListFrame.Size = UDim2.new(0, 280, 0, 150)
PlayerListFrame.ScrollBarThickness = 5

PlayerListLayout.Parent = PlayerListFrame
PlayerListLayout.SortOrder = Enum.SortOrder.Name

-- Button-Funktion
local function createButton(name, position)
    local button = Instance.new("TextButton")
    button.Parent = MainFrame
    button.BackgroundColor3 = Color3.new(0.1, 0, 0.3)
    button.BorderColor3 = Color3.new(0.5, 0, 1)
    button.BorderSizePixel = 1
    button.Position = position
    button.Size = UDim2.new(0, 280, 0, 30)
    button.Font = Enum.Font.SourceSans
    button.Text = name
    button.TextColor3 = Color3.new(0.5, 0, 1)
    button.TextSize = 14
    return button
end

-- Buttons erstellen
SpeedSlider = createButton("Geschwindigkeit: 1x", UDim2.new(0, 10, 0, 40))
NoClipButton = createButton("NoClip: AUS", UDim2.new(0, 10, 0, 80))
ESPButton = createButton("ESP: AUS", UDim2.new(0, 10, 0, 120))
JumpButton = createButton("Hochspringen: 1.5x", UDim2.new(0, 10, 0, 160))
FullbrightButton = createButton("Fullbright: AUS", UDim2.new(0, 10, 0, 200))
TargetFollowButton = createButton("Target Follow: AUS", UDim2.new(0, 10, 0, 240))
FlyButton = createButton("Fliegen: AUS", UDim2.new(0, 10, 0, 280))

MinimizeButton = createButton("Minimieren (G)", UDim2.new(0, 10, 0, 320))
CloseButton = createButton("Schließen", UDim2.new(0, 10, 0, 360))

-- Geschwindigkeitsänderung
SpeedSlider.MouseButton1Click:Connect(function()
    speedMultiplier = speedMultiplier >= 3 and 1 or speedMultiplier + 0.5
    SpeedSlider.Text = "Geschwindigkeit: " .. speedMultiplier .. "x"
    
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.WalkSpeed = 16 * speedMultiplier
    end
end)

-- NoClip
NoClipButton.MouseButton1Click:Connect(function()
    isNoClip = not isNoClip
    NoClipButton.Text = "NoClip: " .. (isNoClip and "EIN" or "AUS")
    
    if LocalPlayer.Character then
        for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = not isNoClip
            end
        end
    end
end)

-- ESP
ESPButton.MouseButton1Click:Connect(function()
    isESP = not isESP
    ESPButton.Text = "ESP: " .. (isESP and "EIN" or "AUS")
    
    if isESP then
        enableESP()
    else
        disableESP()
    end
end)

function enableESP()
    -- Spieler ESP
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local character = player.Character
            if character and character:FindFirstChild("HumanoidRootPart") then
                local espBox = Instance.new("BoxHandleAdornment")
                espBox.Adornee = character.HumanoidRootPart
                espBox.Size = character.HumanoidRootPart.Size * Vector3.new(2, 3, 2)
                espBox.Color3 = Color3.new(0, 0, 1) -- Blau für Spieler
                espBox.Transparency = 0.7
                espBox.AlwaysOnTop = true
                espBox.ZIndex = 10
                espBox.Parent = character.HumanoidRootPart
                
                local espName = Instance.new("BillboardGui")
                espName.Adornee = character.Head
                espName.Size = UDim2.new(0, 100, 0, 30)
                espName.StudsOffset = Vector3.new(0, 3, 0)
                espName.Parent = character.Head
                
                local nameLabel = Instance.new("TextLabel")
                nameLabel.Size = UDim2.new(1, 0, 1, 0)
                nameLabel.BackgroundTransparency = 1
                nameLabel.Text = player.Name
                nameLabel.TextColor3 = Color3.new(0, 0, 1)
                nameLabel.TextStrokeTransparency = 0
                nameLabel.TextSize = 12
                nameLabel.Font = Enum.Font.SourceSansBold
                nameLabel.Parent = espName
                
                table.insert(espObjects, {box = espBox, name = espName, player = player})
            end
        end
    end
    
    -- Animatronics ESP (Annahme: Animatronics sind in workspace mit bestimmten Namen)
    for _, obj in pairs(workspace:GetChildren()) do
        if string.find(obj.Name:lower(), "animatronic") or string.find(obj.Name:lower(), "monster") then
            if obj:FindFirstChild("HumanoidRootPart") then
                local espBox = Instance.new("BoxHandleAdornment")
                espBox.Adornee = obj.HumanoidRootPart
                espBox.Size = obj.HumanoidRootPart.Size * Vector3.new(2, 3, 2)
                espBox.Color3 = Color3.new(1, 0, 0) -- Rot für Animatronics
                espBox.Transparency = 0.7
                espBox.AlwaysOnTop = true
                espBox.ZIndex = 10
                espBox.Parent = obj.HumanoidRootPart
                
                local espName = Instance.new("BillboardGui")
                espName.Adornee = obj:FindFirstChild("Head") or obj.PrimaryPart
                espName.Size = UDim2.new(0, 100, 0, 30)
                espName.StudsOffset = Vector3.new(0, 3, 0)
                espName.Parent = espName.Adornee
                
                local nameLabel = Instance.new("TextLabel")
                nameLabel.Size = UDim2.new(1, 0, 1, 0)
                nameLabel.BackgroundTransparency = 1
                nameLabel.Text = obj.Name
                nameLabel.TextColor3 = Color3.new(1, 0, 0)
                nameLabel.TextStrokeTransparency = 0
                nameLabel.TextSize = 12
                nameLabel.Font = Enum.Font.SourceSansBold
                nameLabel.Parent = espName

      table.insert(espObjects, {box = espBox, name = espName, obj = obj})
            end
        end
    end
end

function disableESP()
    for _, obj in pairs(espObjects) do
        if obj.box then obj.box:Destroy() end
        if obj.name then obj.name:Destroy() end
    end
    espObjects = {}
end

-- Höher springen (ROBUSTE VERSION)
JumpButton.MouseButton1Click:Connect(function()
    jumpMultiplier = jumpMultiplier >= 3 and 1.5 or jumpMultiplier + 0.5
    JumpButton.Text = "Hochspringen: " .. jumpMultiplier .. "x"
    
    -- Diese Funktion setzt die Sprungkraft und stellt sicher, dass sie beibehalten wird
    local function applyJumpPower()
        local character = LocalPlayer.Character
        if character and character:FindFirstChild("Humanoid") then
            local humanoid = character.Humanoid
            humanoid.JumpPower = 50 * jumpMultiplier
            
            -- Das ist der entscheidende Teil: Wir fangen das "Landed"-Event ab.
            -- Jedes Mal, wenn der Charakter landet, setzen wir die Sprungkraft neu.
            -- Das verhindert, dass das Spiel sie zurücksetzt.
            humanoid.StateChanged:Connect(function(oldState, newState)
                if newState == Enum.HumanoidStateType.Landed then
                    -- Kleine Verzögerung, um sicherzustellen, dass das Spiel seinen Wert zuerst setzt
                    wait(0.1)
                    humanoid.JumpPower = 50 * jumpMultiplier
                end
            end)
        end
    end

    -- 1. Sofort anwenden, wenn der Charakter bereits existiert
    applyJumpPower()

    -- 2. Einen Event-Listener erstellen, der die Funktion jedes Mal aufruft,
    --    wenn der Charakter neu geladen wird (z.B. nach dem Tod)
    LocalPlayer.CharacterAdded:Connect(function(newCharacter)
        -- Warte kurz, bis der Humanoid geladen ist
        newCharacter:WaitForChild("Humanoid")
        applyJumpPower()
    end)
end)

-- Fullbright
FullbrightButton.MouseButton1Click:Connect(function()
    isFullbright = not isFullbright
    FullbrightButton.Text = "Fullbright: " .. (isFullbright and "EIN" or "AUS")
    
    local lighting = game:GetService("Lighting")
    if isFullbright then
        originalLightingSettings.Brightness = lighting.Brightness
        originalLightingSettings.ClockTime = lighting.ClockTime
        originalLightingSettings.FogEnd = lighting.FogEnd
        originalLightingSettings.Ambient = lighting.Ambient
        
        lighting.Brightness = 2
        lighting.ClockTime = 14
        lighting.FogEnd = 100000
        lighting.Ambient = Color3.new(1, 1, 1)
    else
        lighting.Brightness = originalLightingSettings.Brightness or 1
        lighting.ClockTime = originalLightingSettings.ClockTime or 12
        lighting.FogEnd = originalLightingSettings.FogEnd or 1000
        lighting.Ambient = originalLightingSettings.Ambient or Color3.new(0.5, 0.5, 0.5)
    end
end)

-- Fliegen
local flySpeed = 50
local isFlying = false
local flyControlPart = nil
local flyConnection = nil

FlyButton.MouseButton1Click:Connect(function()
    isFlying = not isFlying
    FlyButton.Text = "Fliegen: " .. (isFlying and "EIN" or "AUS")
    
    if isFlying then
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            -- Deaktiviere die Schwerkraft und das Fallen
            LocalPlayer.Character.Humanoid.PlatformStand = true
            
            -- Erstelle einen unsichtbaren Teil zur Steuerung
            flyControlPart = Instance.new("BodyVelocity")
            flyControlPart.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
            flyControlPart.Velocity = Vector3.new(0, 0, 0)
            flyControlPart.Parent = LocalPlayer.Character.HumanoidRootPart
            
            -- Steuerung per Tastatur
            flyConnection = UserInputService.InputBegan:Connect(function(input)
                if not flyControlPart or not flyControlPart.Parent then return end
                
                local direction = Vector3.new(0, 0, 0)
                if input.KeyCode == Enum.KeyCode.W then direction = direction + Camera.CFrame.LookVector end
                if input.KeyCode == Enum.KeyCode.S then direction = direction - Camera.CFrame.LookVector end
                if input.KeyCode == Enum.KeyCode.A then direction = direction - Camera.CFrame.RightVector end
                if input.KeyCode == Enum.KeyCode.D then direction = direction + Camera.CFrame.RightVector end
                if input.KeyCode == Enum.KeyCode.Space then direction = direction + Vector3.new(0, 1, 0) end
                if input.KeyCode == Enum.KeyCode.LeftShift then direction = direction - Vector3.new(0, 1, 0) end
                
                flyControlPart.Velocity = direction.Unit * flySpeed
            end)
        end
    else
        -- Fliegen beenden
        if LocalPlayer.Character and LocalPlayer.Character.Humanoid then
            LocalPlayer.Character.Humanoid.PlatformStand = false
        end
        if flyControlPart then
            flyControlPart:Destroy()
            flyControlPart = nil
        end
        if flyConnection then
            flyConnection:Disconnect()
            flyConnection = nil
        end
    end
end)

-- Kein Jump Cooldown Button (füge diesen Button ebenfalls im UI-Setup hinzu, wenn du einen willst)
-- Beispiel: local NoJumpCooldownButton = createButton("Kein Jump Cooldown: AUS", UDim2.new(0, 10, 0, 320))
-- Dann den Klick-Handler hier hinzufügen:
-- NoJumpCooldownButton.MouseButton1Click:Connect(function()
--     noJumpCooldown = not noJumpCooldown
--     NoJumpCooldownButton.Text = "Kein Jump Cooldown: " .. (noJumpCooldown and "EIN" oder "AUS")
-- end)

-- Für den Test kannst du es einfach so aktivieren:
noJumpCooldown = true -- Setzt den Cheat automatisch auf AN beim Laden des Skripts

-- Sicherstellen, dass das Fliegen beim Tod/Respawn deaktiviert wird
LocalPlayer.CharacterAdded:Connect(function()
    isFlying = false
    FlyButton.Text = "Fliegen: AUS"
    if flyControlPart then flyControlPart:Destroy() end
    if flyConnection then flyConnection:Disconnect() end
end)

-- Funktion zum Füllen der Spielerliste
local function updatePlayerList()
    for _, child in pairs(PlayerListFrame:GetChildren()) do
        if child:IsA("TextButton") then
            child:Destroy()
        end
    end

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local playerButton = Instance.new("TextButton")
            playerButton.Parent = PlayerListFrame
            playerButton.BackgroundColor3 = Color3.new(0.1, 0, 0.3)
            playerButton.BorderSizePixel = 1
            playerButton.Size = UDim2.new(0, 270, 0, 25)
            playerButton.Font = Enum.Font.SourceSans
            playerButton.Text = player.Name
            playerButton.TextColor3 = Color3.new(0.5, 0, 1)
            playerButton.TextSize = 14
            playerButton.Name = player.Name -- Wichtig, um den Button später wiederzufinden

            playerButton.MouseButton1Click:Connect(function()
                -- Alte Auswahl aufheben
                if selectedPlayerButton then
                    selectedPlayerButton.BackgroundColor3 = Color3.new(0.1, 0, 0.3)
                end
                
                -- Neue Auswahl setzen und markieren
                targetPlayer = player
                selectedPlayerButton = playerButton
                playerButton.BackgroundColor3 = Color3.new(0.3, 0, 0.5) -- Markierungsfarbe
                
                -- Text des Hauptbuttons aktualisieren, aber UI nicht schließen
                TargetFollowButton.Text = "Target Follow: " .. targetPlayer.Name
            end)
            
            -- Prüfen, ob dieser Spieler der aktuell ausgewählte ist, und ihn markieren
            if targetPlayer and player.Name == targetPlayer.Name then
                selectedPlayerButton = playerButton
                playerButton.BackgroundColor3 = Color3.new(0.3, 0, 0.5)
            end
        end
    end
end

-- Target Follow Button Logik (nur zum Umschalten von AN/AUS)
TargetFollowButton.MouseButton1Click:Connect(function()
    isTargetFollow = not isTargetFollow
    if not isTargetFollow then
        TargetFollowButton.Text = "Target Follow: AUS"
    else
        if targetPlayer then
            TargetFollowButton.Text = "Target Follow: " .. targetPlayer.Name
        else
            -- Wenn kein Ziel ausgewählt ist, aber AN gedrückt wird, einfach AN anzeigen
            TargetFollowButton.Text = "Target Follow: AN"
        end
    end
end)

-- Spielerliste beim Start und wenn neue Spieler beitreten aktualisieren
updatePlayerList()
Players.PlayerAdded:Connect(updatePlayerList)
Players.PlayerRemoving:Connect(updatePlayerList)

-- UI Steuerung
MinimizeButton.MouseButton1Click:Connect(function()
    isUIVisible = not isUIVisible
    MainFrame.Visible = isUIVisible
end)

CloseButton.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

-- UI Steuerung mit Taste P
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == Enum.KeyCode.P then
        isUIVisible = not isUIVisible
        MainFrame.Visible = isUIVisible
        -- Target Follow UI ebenfalls minimieren/maximieren
        TargetFollowFrame.Visible = isUIVisible
    end
end)

-- NoClip Loop
RunService.Stepped:Connect(function()
    if isNoClip and LocalPlayer.Character then
        for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end
end)

-- Kein Jump Cooldown
RunService.Heartbeat:Connect(function()
    if noJumpCooldown and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.Jump = false -- Setzt den internen Jump-Zustand zurück
        LocalPlayer.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, true)
    end
end)

-- Target Follow Loop
RunService.Heartbeat:Connect(function()
    if isTargetFollow and targetPlayer and targetPlayer.Character then
        local targetPosition = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
        if targetPosition then
            local humanoid = LocalPlayer.Character:FindFirstChild("Humanoid")
            if humanoid then
                humanoid:MoveTo(targetPosition.Position)
            end
        end
    end
end)

-- Moderator-Erkennung (DEAKTIVIERT zur Sicherheit)
local function checkForModerators()
    -- Die Funktion wurde deaktiviert, da sie zu viele Fehlalarme verursacht
    -- und Spieler ohne Grund gekickt hat. Nur aktivieren, wenn eine
    -- zuverlässige Erkennungsmethode bekannt ist.
    return false
end

-- Cooldown-Anzeige für Schläge
local cooldownGui = Instance.new("ScreenGui")
cooldownGui.Parent = game:GetService("CoreGui")
cooldownGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local function createCooldownGui(player)
    local playerFrame = Instance.new("Frame")
    playerFrame.Parent = cooldownGui
    playerFrame.BackgroundColor3 = Color3.new(0, 0, 0)
    playerFrame.BorderColor3 = Color3.new(0.5, 0, 1)
    playerFrame.BorderSizePixel = 1
    playerFrame.Position = UDim2.new(0, 10, 0, 50 + #cooldownGui:GetChildren() * 35)
    playerFrame.Size = UDim2.new(0, 200, 0, 30)
    
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Parent = playerFrame
    nameLabel.BackgroundColor3 = Color3.new(0, 0, 0)
    nameLabel.BorderSizePixel = 0
    nameLabel.Position = UDim2.new(0, 5, 0, 0)
    nameLabel.Size = UDim2.new(0, 100, 1, 0)
    nameLabel.Font = Enum.Font.SourceSans
    nameLabel.Text = player.Name
    nameLabel.TextColor3 = Color3.new(0.5, 0, 1)
    nameLabel.TextSize = 14
    nameLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    local cooldownBar = Instance.new("Frame")
    cooldownBar.Parent = playerFrame
    cooldownBar.BackgroundColor3 = Color3.new(0.5, 0, 1)
    cooldownBar.BorderSizePixel = 0
    cooldownBar.Position = UDim2.new(0, 110, 0, 5)
    cooldownBar.Size = UDim2.new(0, 85, 0, 20)
    
    local cooldownTimer = Instance.new("TextLabel")
    cooldownTimer.Parent = cooldownBar
    cooldownTimer.BackgroundTransparency = 1
    cooldownTimer.Size = UDim2.new(1, 0, 1, 0)
    cooldownTimer.Font = Enum.Font.SourceSans
    cooldownTimer.Text = "0.0s"
    cooldownTimer.TextColor3 = Color3.new(1, 1, 1)
    cooldownTimer.TextSize = 12
    
    return {frame = playerFrame, bar = cooldownBar, timer = cooldownTimer, player = player, cooldown = 0}
end

local playerCooldowns = {}

-- Spieler-Cooldowns initialisieren
Players.PlayerAdded:Connect(function(player)
    if player ~= LocalPlayer then
        table.insert(playerCooldowns, createCooldownGui(player))
    end
end)

for _, player in pairs(Players:GetPlayers()) do
    if player ~= LocalPlayer then
        table.insert(playerCooldowns, createCooldownGui(player))
    end
end

-- Cooldown-Update-Loop
RunService.Heartbeat:Connect(function(deltaTime)
    -- Moderator-Erkennung
    checkForModerators()
    
    -- Cooldown-Anzeigen aktualisieren
    for _, cooldownData in pairs(playerCooldowns) do
        if cooldownData.cooldown > 0 then
            cooldownData.cooldown = math.max(0, cooldownData.cooldown - deltaTime)
            local percentage = cooldownData.cooldown / 5 -- Annahme: 5 Sekunden Cooldown
            cooldownData.bar.Size = UDim2.new(0, 85 * percentage, 0, 20)
            cooldownData.timer.Text = string.format("%.1fs", cooldownData.cooldown)
        else
            cooldownData.bar.Size = UDim2.new(0, 0, 0, 20)
            cooldownData.timer.Text = "0.0s"
        end
    end
end)

-- Schläge erkennen und Cooldown setzen
local function onPlayerHit(player)
    for _, cooldownData in pairs(playerCooldowns) do
        if cooldownData.player == player then
            cooldownData.cooldown = 5 -- Annahme: 5 Sekunden Cooldown
            break
        end
    end
end

-- Event-Listener für Schläge (je nach Spiel angepasst)
-- Beispiel: LocalPlayer.Character.Touched:Connect(function(part) ... end)

print("Five Nights Hunted Cheat Script geladen!")
print("Drücke P zum Minimieren/Maximieren der UI")
