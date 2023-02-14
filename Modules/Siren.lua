local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local Remote = workspace:WaitForChild("Remote")
local toggleSiren = Remote:WaitForChild("ItemHandler")
local sirenToggleScript = toggleSiren:WaitForChild("sirenToggleScript")
local Prison_ITEMS = workspace:WaitForChild("Prison_ITEMS")

local sirenLib = {
    DisabledQueue = {},
    Loop = function(self, instance)
        toggleSiren:FireServer({
            Part4 = {
                Part_Weld = true,
                l = instance
            },
            Part3 = {
                Part_Weld = true,
                l = instance
            },
            Part2 = {
                Part_Weld = true,
                l = instance
            },
            Part1 = {
                Part_Weld = true,
                l = instance
            },
            isOn = LocalPlayer.Status.isArrested,
            Speaker = {
                Part_Weld = true,
                Sound = self.GetSound()
            }
        })
    end,
    Lock = function(self, instance)
        local InstanceDisabled;
        local Locked;

        task.delay(1, function()
            if InstanceDisabled then
                InstanceDisabled:Disconnect();
            end
            if not Locked and instance and instance.Enabled then
                Locked = false
            end
        end)

        InstanceDisabled = instance:GetPropertyChangedSignal("Enabled"):Connect(function()
            InstanceDisabled:Disconnect();
            Locked = true
        end)

        task.wait(1.5);

        if Locked or Locked == nil then return Locked end
        if ServerLocked then return true end

        self:Loop(instance)

        game:GetService('TeleportService'):TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
    end,
    Enable = function (self, instance)
        local Connection;
        
        Connection = sirenToggleScript:GetPropertyChangedSignal("Enabled"):Connect(function()
            local Enabled = sirenToggleScript.Enabled
            
            if Enabled then
                if instance.Enabled then
                    Connection:Disconnect()
                    return
                end
                self:Loop(instance)
                Connection:Disconnect()
            end
        end)
    end,
    Bool = function(instance, bool)
        local Connection
        
        Connection = sirenToggleScript:GetPropertyChangedSignal("Enabled"):Connect(function()
            local enabled = sirenToggleScript.Enabled
            
            if enabled then
                if instance.Value == bool then
                    Connection:Disconnect()
                    return
                end
                toggleSiren:FireServer({
                    isOn = instance
                })
            end
        end)
    end,
    BreakJoints = function(self, Model)
        for _, Weld in next, Model:GetDescendants() do
            if Weld:IsA("JointInstance") then
                table.insert(self.Disabled, Weld)
            end
        end
    end,
    Play = function(self, sound)
        if sound.IsPlaying then return end
        toggleSiren:FireServer({
            isOn = LocalPlayer.Status.isArrested,
            Speaker = {
                Part_Weld = true,
                Sound = sound
            }
        })
    end,
    Stop = function(self, sound)
        if not sound.IsPlaying then return end
        toggleSiren:FireServer({
            isOn = LocalPlayer.Status.isArrested,
            Speaker = {
                Part_Weld = true,
                Sound = sound
            }
        })
    end,
    Disable = function(self, instance)
        task.spawn(function()
            local stop = false

            local Connection

            if not instance then return end

            task.delay(0.3, function()
                stop = true
                if not instance or not instance.Parent or not instance.Parent.Parent then return end
                Connection:Disconnect()
                task.wait(0.5)
                if not instance or not instance.Parent or not instance.Enabled then return end
                print("not disabled", instance:GetFullName())
                self:Disable(instance)
            end)
        
            Connection = sirenToggleScript:GetPropertyChangedSignal("Enabled"):Connect(function()
                local enabled = sirenToggleScript.Enabled
                
                if enabled then
                    repeat
                        if not instance or not instance.Parent or not instance.Parent.Parent or stop or not instance.Enabled then
                            Connection:Disconnect()
                            break
                        end

                        task.spawn(function()
                            if not instance or not instance.Parent or not instance.Parent.Parent or stop or not instance.Enabled then
                                Connection:Disconnect()
                                return
                            end
                            toggleSiren:FireServer({
                                Part1 = {
                                    Part_Weld = true,
                                    l = instance
                                },
                                isOn = LocalPlayer.Status.isArrested,
                                Speaker = {
                                    Part_Weld = true,
                                    Sound = self.GetSound()
                                }
                            })
                        end)
                        RunService.RenderStepped:Wait()
                    until false
                end
            end)
        end)
    end
}

sirenLib.DisableQueue = coroutine.create(function()
    while true do task.wait()
        for i, instance in next, sirenLib.DisabledQueue do
            if i % 5 == 0 then task.wait(0.15) end
            if instance then
                sirenLib:Disable(instance)
            end
            table.remove(sirenLib.DisabledQueue, i)
        end
    end
end)

local Locked = sirenLib:Lock(sirenToggleScript)

if Locked and not ServerLocked then
    StarterGui:SetCore("SendNotification", {
        Title = "Server successfully locked!",
        Text = "This server was successfully locked." .. (Import and "The prefix is \";\""),
    })
    coroutine.resume(sirenLib.DisableQueue)
    getgenv().ServerLocked = true
elseif not Locked and sirenToggleScript.Enabled == false and not ServerLocked then
    getgenv().ServerLocked = true
    StarterGui:SetCore("SendNotification", {
        Title = "Server is disabled!",
        Text = "This server is disabled, join a different server or crash this one.",
    })
end

return sirenLib
