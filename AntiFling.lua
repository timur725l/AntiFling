local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

local lastSafePosition = nil
local MAX_SAFE_DISTANCE = 50000 
local MAX_VELOCITY = 250
local function startTracking(character)
    local rootPart = character:WaitForChild("HumanoidRootPart", 5)
    if not rootPart then return end

    local connection
    connection = RunService.Heartbeat:Connect(function()
        if not character:IsDescendantOf(workspace) then
            connection:Disconnect()
            return
        end

        local currentPos = rootPart.Position
        
        -- 1. Жёсткий контроль скорости (Не дает улететь даже на метр)
        if rootPart.Velocity.Magnitude > MAX_VELOCITY then
            rootPart.Velocity = Vector3.new(0, 0, 0)
        end

        if currentPos.Magnitude < MAX_SAFE_DISTANCE and math.abs(currentPos.Y) < 5000 then
            if rootPart.Velocity.Magnitude < 50 then
                lastSafePosition = currentPos
            end
        else
            rootPart.Velocity = Vector3.new(0, 0, 0)
            rootPart.RotVelocity = Vector3.new(0, 0, 0)
            if lastSafePosition then
                rootPart.CFrame = CFrame.new(lastSafePosition + Vector3.new(0, 3, 0))
            end
        end

        for _, part in ipairs(character:GetChildren()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end)
end

if LocalPlayer.Character then task.spawn(startTracking, LocalPlayer.Character) end
LocalPlayer.CharacterAdded:Connect(function(newCharacter) task.spawn(startTracking, newCharacter) end)
