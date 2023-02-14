-- duck likes men

------------ Services ------------

local Players           = game:GetService("Players")
local TeleportService   = game:GetService("TeleportService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

------------ Modules ------------

local Admin      = Import("Admin")
local Loop       = Import("Loop")
local Siren      = Import("Siren")
local GunSystem  = Import("GunSystem")
local CarSystem  = Import("CarSystem")

------------ Loops ------------

local Bean       = Loop:Add("Bean")
local RLeg       = Loop:Add("RLeg")
local LLeg       = Loop:Add("LLeg")
local RArm       = Loop:Add("RArm")
local LArm       = Loop:Add("LArm")
local RJoint     = Loop:Add("RJoint")
local LoopKill   = Loop:Add("Kill")

------------ Gun System ------------

local StunGun = GunSystem:Add("Disable", function(Data)
    local Shot = Data.Shot
    local Character = Shot and Shot.Character

    local HRPart = Character and Character:FindFirstChild("HumanoidRootPart")
    local RootJoint = HRPart and HRPart:FindFirstChild("RootJoint")

    Siren:Disable(RootJoint)
end)

local OneShot = GunSystem:Add("Oneshot", function(Data)
    local Shot = Data.Shot
    local Character = Shot and Shot.Character

    if Character:FindFirstChild("Humanoid") and Character.Humanoid.Health == 0 then return end

    local Torso = Character and Character:FindFirstChild("Torso")
    local Neck = Torso and Torso:WaitForChild("Neck")

    Siren:Disable(Neck)
end)

local HostileShot = GunSystem:Add("Hostile", function(Data)
    local Shot = Data.Shot
    local Status = Shot and Shot:FindFirstChild("Status")

    if Status.isHostile.Value then return end

    Siren:Bool(Status.isHostile, true)
end)

local InnocentGun = GunSystem:Add("Innocent", function(Data)
    local Shot = Data.Shot
    local Status = Shot and Shot.Status

    if not Status.isHostile.Value then return end

    Siren:Bool(Status.isHostile, false)
end)

------------ Car System ------------

local CarDamage = GunSystem:Add("CarDamage", CarSystem.CarDamageHandler)

for _, Player in next, Players:GetPlayers() do
    CarDamage:Add(Player)
end

Players.PlayerAdded:Connect(function(Player)
    CarDamage:Add(Player)
end)

Players.PlayerRemoving:Connect(function(Player)
    CarDamage:Remove(Player)
end)

local GunBanConnection = {}

function GunBan(v, dontPersistOnDeath)
    if v.Character then
        for i, tool in next, v.Character:GetChildren() do
            if tool:IsA("Tool") then
                pcall(function()
                    local t = tick()
                    repeat task.wait() until tool:FindFirstChildOfClass("Script") or tick() - t > 1
                    if tool:FindFirstChildOfClass("Script").Enabled == false then return end
                    Siren:Disable(tool:FindFirstChildOfClass("Script"))
                    Siren:Disable(tool:FindFirstChildOfClass("LocalScript"))
                end)
            end
        end
    end
    
    if v.Backpack then
        for i, tool in next, v.Backpack:GetChildren() do
            pcall(function()
                local t = tick()
                repeat task.wait() until tool:FindFirstChildOfClass("Script") or tick() - t > 1
                if tool:FindFirstChildOfClass("Script").Enabled == false then return end
                Siren:Disable(tool:FindFirstChildOfClass("Script"))
                Siren:Disable(tool:FindFirstChildOfClass("LocalScript"))
            end)
        end
    end
    
    if GunBanConnection[v] then return end
    
    if not dontPersistOnDeath then
        GunBanConnection[v] = {
            Disconnect = function(self)
                self.Character:Disconnect()
                self.Backpack:Disconnect()
            end,
            Character = v.CharacterAdded:Connect(function(character)
                if GunBanConnection[v] then
                    GunBanConnection[v].Backpack:Disconnect()
                end
                
                for i, tool in next, v.Backpack:GetChildren() do
                    pcall(function()
                        local t = tick()
                        repeat task.wait() until tool:FindFirstChildOfClass("Script") or tick() - t > 1
                        if tool:FindFirstChildOfClass("Script").Enabled == false then return end
                        Siren:Disable(tool:FindFirstChildOfClass("Script"))
                        Siren:Disable(tool:FindFirstChildOfClass("LocalScript"))
                    end)
                end
                
                GunBanConnection[v].Backpack = v.Backpack.ChildAdded:Connect(function(tool)
                    pcall(function()
                        local t = tick()
                        repeat task.wait() until tool:FindFirstChildOfClass("Script") or tick() - t > 1
                        if tool:FindFirstChildOfClass("Script").Enabled == false then return end
                        Siren:Disable(tool:FindFirstChildOfClass("Script"))
                        Siren:Disable(tool:FindFirstChildOfClass("LocalScript"))
                    end)
                end)
            end),
            Backpack = v.Backpack.ChildAdded:Connect(function(tool)
                pcall(function()
                    local t = tick()
                    repeat task.wait() until tool:FindFirstChildOfClass("Script") or tick() - t > 1
                    if tool:FindFirstChildOfClass("Script").Enabled == false then return end
                    Siren:Disable(tool:FindFirstChildOfClass("Script"))
                    Siren:Disable(tool:FindFirstChildOfClass("LocalScript"))
                end)
            end)
        }
    else
        v.Backpack.ChildAdded:Connect(function(tool)
            pcall(function()
                local t = tick()
                repeat task.wait() until tool:FindFirstChildOfClass("Script") or tick() - t > 1
                if tool:FindFirstChildOfClass("Script").Enabled == false then return end
                Siren:Disable(tool:FindFirstChildOfClass("Script"))
                Siren:Disable(tool:FindFirstChildOfClass("LocalScript"))
            end)
        end)
    end
end

------------ Commands ------------

Admin:SetRank(game.Players.LocalPlayer, math.huge)

Admin:AddCommand({
    Name = {"help", "cmds", "cmd"},
    Rank = 1,
    Description = "A command that will help you understand other commands.",
    Function = function(plr, command)
        if command then
            local CommandData = Admin.Commands[command]
            if not CommandData then return end
            ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer("/w ".. plr.Name .." " .. CommandData.Description , "All");
            return
        end
        local Counter = 0
        local Descriptions = {}
        for Command, CommandData in next, Admin.Commands do
            if CommandData.Rank <= Admin.Admins[plr].Rank and not table.find(Descriptions, CommandData.Description) then
                ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer("/w ".. plr.Name .. " " .. Admin.Admins[plr].Prefix .. Command .. " | " .. CommandData.Description , "All")
                table.insert(Descriptions, CommandData.Description)
                Counter = Counter + 1
                if Counter % 2 == 0 then
                    task.wait(2.5)
                end
            end
        end
    end
})

Admin:AddCommand({
    Name = {"commandwhitelist", "givecommand", "cw"},
    Rank = 2,
    Description = "Makes it so the player can use the specified command.",
    Function = function(plr, player, command)
        for _, Player in next, Admin.GetPlayers(player) do
            local CommandData = Admin.Commands[command]

            if not CommandData.Rank <= Admin.Admins[plr].Rank then return end

            if not table.find(CommandData.Whitelist, Player) then
                table.insert(CommandData.Whitelist, Player)
            end
        end
    end
})

Admin:AddCommand({
    Name = {"gunban", "gb"},
    Rank = 2,
    Description = "Bans the player from using guns.",
    Function = function(plr, player)
        for _, Player in next, Admin.GetPlayers(plr, player) do
            GunBan(Player)
        end
    end
})

Admin:AddCommand({
    Name = {"ungunban", "ungb"},
    Rank = 2,
    Description = "Bans the player from using guns.",
    Function = function(plr, player)
        for _, Player in next, Admin.GetPlayers(plr, player) do
            local Connection = GunBanConnection[Player]
            if Connection then
                Connection:Disconnect()
                break
            end
        end
    end
})

Admin:AddCommand({
    Name = {"uncommandwhitelist", "removecommand", "uncw"},
    Rank = 2,
    Description = "Makes it so the player can't use the specified command if they're whitelisted.",
    Function = function(plr, player, command)
        for _, Player in next, Admin.GetPlayers(player) do
            local CommandData = Admin.Commands[command]

            if not CommandData.Rank <= Admin.Admins[plr].Rank then return end

            local Idx = table.find(CommandData.Whitelist, Player)

            if Idx then
                table.remove(CommandData.Whitelist, Idx)
            end
        end
    end
})

Admin:AddCommand({
    Name = {"stat", "status"},
    Rank = 1,
    Description = "Toggles the status that's specified.",
    Function = function(plr, player, status)
        for _, Player in next, Admin.GetPlayers(player) do
            for _, Status in next, Player.Status:GetChildren() do
                if Status:IsA("BoolValue") and Status.Name:match(status) then
                    Siren:Bool(Status, not Status.Value)
                end
            end
        end
    end
})

Admin:AddCommand({
    Name = {"rejoin", "rj"},
    Rank = 25,
    Description = "Rejoins the server.",
    Function = function(plr, ...)
       TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, plr)
    end
})

Admin:AddCommand({
    Name = "prefix",
    Rank = 1,
    Description = "Changes the prefix used for commands.",
    Function = function(plr, prefix)
        if not prefix then
            return
        end
        Admin.Admins[plr].Prefix = prefix
    end
})

Admin:AddCommand({
    Name = "rank",
    Rank = 3,
    Description = "Ranks the player",
    Function = function(plr, name, rank)
        local Rank = tonumber(rank)
        for _, Player in next, Admin.GetPlayers(plr, name) do
           Admin:SetRank(Player, Rank)
        end
    end
})

Admin:AddCommand({
    Name = {"kill", "k"},
    Rank = 2,
    Description = "Player that's specified becomes unalive.", -- epic roblox censor
    Function = function(plr, name)
        for _, Player in next, Admin.GetPlayers(plr, name) do
            Siren:Disable(Player.Character and Player.Character:FindFirstChild("Torso") and Player.Character.Torso:FindFirstChild("Neck"))
        end
    end
})

Admin:AddCommand({
    Name = {"os", "oneshot"},
    Rank = 2,
    Description = "Enables oneshot for the player",
    Function = function(plr, name)
        for _, Player in next, Admin.GetPlayers(plr, name) do
            OneShot:Add(Player)
        end
    end
})

Admin:AddCommand({
    Name = {"unos", "unoneshot"},
    Rank = 2,
    Description = "Disables oneshot for the player",
    Function = function(plr, name)
        for _, Player in next, Admin.GetPlayers(plr, name) do
            OneShot:Remove(Player)
        end
    end
})

Admin:AddCommand({
    Name = {"stungun", "sg"},
    Rank = 2,
    Description = "Enables stungun for the player",
    Function = function(plr, name)
        for _, Player in next, Admin.GetPlayers(plr, name) do
            StunGun:Add(Player)
        end
    end
})

Admin:AddCommand({
    Name = {"unsg", "unstungun"},
    Rank = 2,
    Description = "Disables stungun for the player",
    Function = function(plr, name)
        for _, Player in next, Admin.GetPlayers(plr, name) do
            StunGun:Remove(Player)
        end
    end
})

Admin:AddCommand({
    Name = {"corruptcop", "cc"},
    Rank = 2,
    Description = "Enables corruptcop for the player",
    Function = function(plr, name)
        for _, Player in next, Admin.GetPlayers(plr, name) do
            HostileShot:Add(Player)
        end
    end
})

Admin:AddCommand({
    Name = {"uncorruptcop", "uncc"},
    Rank = 2,
    Description = "Disables corruptcop for the player",
    Function = function(plr, name)
        for _, Player in next, Admin.GetPlayers(plr, name) do
            HostileShot:Remove(Player)
        end
    end
})

Admin:AddCommand({
    Name = {"is", "innocentshot"},
    Rank = 2,
    Description = "Enables innocentshot for the player",
    Function = function(plr, name)
        for _, Player in next, Admin.GetPlayers(plr, name) do
            InnocentGun:Add(Player)
        end
    end
})

Admin:AddCommand({
    Name = {"unis", "uninnocentshot"},
    Rank = 2,
    Description = "Disables innocentshot for the player",
    Function = function(plr, name)
        for _, Player in next, Admin.GetPlayers(plr, name) do
            InnocentGun:Remove(Player)
        end
    end
})

Admin:AddCommand({
    Name = {"lk", "loopkill"},
    Rank = 2,
    Description = "Loop kills the player that is specified",
    Function = function(plr, name)
        for _, Player in next, Admin.GetPlayers(plr, name) do
            local Character = Player.Character
            local Torso = Character and Character:FindFirstChild("Torso")
            local Neck = Torso and Torso:FindFirstChild("Neck")

            Siren:Disable(Neck)

            LoopKill:Append(Player, Player.CharacterAdded:Connect(function(Character)
                repeat task.wait() until Character:FindFirstChild("Torso") and Character.Torso:FindFirstChild("Neck")

                if not (Character:FindFirstChild("Torso") and Character.Torso:FindFirstChild("Neck")) then return end

                Siren:Disable(Player.Character.Torso.Neck)
            end))
        end
    end
})

Admin:AddCommand({
    Name = {"unlk", "unloopkill"},
    Rank = 2,
    Description = "Stops the loopkill on the player.",
    Function = function(plr, name)
        for _, Player in next, Admin.GetPlayers(plr, name) do
            LoopKill:Remove(Player)
        end
    end
})

Admin:AddCommand({
    Name = {"lb", "loopbean"},
    Rank = 2,
    Description = "Loop beans the player that is specified",
    Function = function(plr, name)
        for _, Player in next, Admin.GetPlayers(plr, name) do
            local Character = Player.Character
            local Torso = Character and Character:FindFirstChild("Torso")
            
            local RHip = Torso and Torso:FindFirstChild("Right Hip")
            local LHip = Torso and Torso:FindFirstChild("Left Hip")
            local RShoulder = Torso and Torso:FindFirstChild("Right Shoulder")
            local LShoulder = Torso and Torso:FindFirstChild("Left Shoulder")

            Siren:Disable(RShoulder)
            Siren:Disable(LShoulder)
            Siren:Disable(RHip)
            Siren:Disable(LHip)

            Bean:Append(Player, Player.CharacterAdded:Connect(function(Character)
                repeat task.wait() until Character:FindFirstChild("Torso") and Character.Torso:FindFirstChild("Left Shoulder") and Character.Torso:FindFirstChild("Right Shoulder") and Torso:FindFirstChild("Right Hip") and Torso:FindFirstChild("Left Hip")

                if not Character:FindFirstChild("Torso") then return end

                local Torso = Character and Character:FindFirstChild("Torso")

                local RHip = Torso and Torso:FindFirstChild("Right Hip")
                local LHip = Torso and Torso:FindFirstChild("Left Hip")
                local RShoulder = Torso and Torso:FindFirstChild("Right Shoulder")
                local LShoulder = Torso and Torso:FindFirstChild("Left Shoulder")

                Siren:Disable(RShoulder)
                Siren:Disable(LShoulder)
                Siren:Disable(RHip)
                Siren:Disable(LHip)
            end))
        end
    end
})

Admin:AddCommand({
    Name = {"unlb", "unloopbean"},
    Rank = 2,
    Description = "Stops the loop bean on the player.",
    Function = function(plr, name)
        for _, Player in next, Admin.GetPlayers(plr, name) do
            Bean:Remove(Player)
        end
    end
})

Admin:AddCommand({
    Name = {"lrl", "looprightleg"},
    Rank = 2,
    Description = "Loop removes the player's right leg.",
    Function = function(plr, name)
        for _, Player in next, Admin.GetPlayers(plr, name) do
            local Character = Player.Character
            local Torso = Character and Character:FindFirstChild("Torso")
            
            local RHip = Torso and Torso:FindFirstChild("Right Hip")

            Siren:Disable(RHip)

            RLeg:Append(Player, Player.CharacterAdded:Connect(function(Character)
                repeat task.wait() until Character:FindFirstChild("Torso") and Character.Torso:FindFirstChild("Right Hip")

                if not Character:FindFirstChild("Torso") then return end

                local Torso = Character and Character:FindFirstChild("Torso")

                local RHip = Torso and Torso:FindFirstChild("Right Hip")

                Siren:Disable(RHip)
            end))
        end
    end
})

Admin:AddCommand({
    Name = {"unlrl", "unlooprightleg"},
    Rank = 2,
    Description = "Stops the right leg loop on the player.",
    Function = function(plr, name)
        for _, Player in next, Admin.GetPlayers(plr, name) do
            RLeg:Remove(Player)
        end
    end
})

Admin:AddCommand({
    Name = {"lll", "loopleftleg"},
    Rank = 2,
    Description = "Loop removes the player's left leg.",
    Function = function(plr, name)
        for _, Player in next, Admin.GetPlayers(plr, name) do
            local Character = Player.Character
            local Torso = Character and Character:FindFirstChild("Torso")
            
            local LHip = Torso and Torso:FindFirstChild("Left Hip")

            Siren:Disable(LHip)

            LLeg:Append(Player, Player.CharacterAdded:Connect(function(Character)
                repeat task.wait() until Character:FindFirstChild("Torso") and Character.Torso:FindFirstChild("Left Hip")

                if not Character:FindFirstChild("Torso") then return end

                local Torso = Character and Character:FindFirstChild("Torso")

                local LHip = Torso and Torso:FindFirstChild("Left Hip")

                Siren:Disable(LHip)
            end))
        end
    end
})

Admin:AddCommand({
    Name = {"unlll", "unloopleftleg"},
    Rank = 2,
    Description = "Stops the left leg loop on the player.",
    Function = function(plr, name)
        for _, Player in next, Admin.GetPlayers(plr, name) do
            LLeg:Remove(Player)
        end
    end
})

Admin:AddCommand({
    Name = {"lla", "loopleftarm"},
    Rank = 2,
    Description = "Loop removes the player's left arm.",
    Function = function(plr, name)
        for _, Player in next, Admin.GetPlayers(plr, name) do
            local Character = Player.Character
            local Torso = Character and Character:FindFirstChild("Torso")
            
            local LShoulder = Torso and Torso:FindFirstChild("Left Shoulder")

            Siren:Disable(LShoulder)

            LArm:Append(Player, Player.CharacterAdded:Connect(function(Character)
                repeat task.wait() until Character:FindFirstChild("Torso") and Character.Torso:FindFirstChild("Left Shoulder")

                if not Character:FindFirstChild("Torso") then return end

                local Torso = Character and Character:FindFirstChild("Torso")

                local LShoulder = Torso and Torso:FindFirstChild("Left Shoulder")

                Siren:Disable(LShoulder)
            end))
        end
    end
})

Admin:AddCommand({
    Name = {"unlla", "unloopleftarm"},
    Rank = 2,
    Description = "Stops the left arm loop on the player.",
    Function = function(plr, name)
        for _, Player in next, Admin.GetPlayers(plr, name) do
            LArm:Remove(Player)
        end
    end
})

Admin:AddCommand({
    Name = {"lra", "looprightarm"},
    Rank = 2,
    Description = "Loop removes the player's right arm.",
    Function = function(plr, name)
        for _, Player in next, Admin.GetPlayers(plr, name) do
            local Character = Player.Character
            local Torso = Character and Character:FindFirstChild("Torso")
            
            local RShoulder = Torso and Torso:FindFirstChild("Right Shoulder")

            Siren:Disable(RShoulder)

            RArm:Append(Player, Player.CharacterAdded:Connect(function(Character)
                repeat task.wait() until Character:FindFirstChild("Torso") and Character.Torso:FindFirstChild("Right Shoulder")

                if not Character:FindFirstChild("Torso") then return end

                local Torso = Character and Character:FindFirstChild("Torso")

                local RShoulder = Torso and Torso:FindFirstChild("Right Shoulder")

                Siren:Disable(RShoulder)
            end))
        end
    end
})

Admin:AddCommand({
    Name = {"unlla", "unlooprightarm"},
    Rank = 2,
    Description = "Stops the right arm loop on the player.",
    Function = function(plr, name)
        for _, Player in next, Admin.GetPlayers(plr, name) do
            RArm:Remove(Player)
        end
    end
})

Admin:AddCommand({
    Name = {"lr", "looproot"},
    Rank = 2,
    Description = "Loop removes the player's root joint.",
    Function = function(plr, name)
        for _, Player in next, Admin.GetPlayers(plr, name) do
            local Character = Player.Character
            local HRPart = Character and Character:FindFirstChild("HumanoidRootPart")
            
            local RootJoint = HRPart and HRPart:FindFirstChild("RootJoint")

            Siren:Disable(RootJoint)

            RJoint:Append(Player, Player.CharacterAdded:Connect(function(Character)
                repeat task.wait() until Character:FindFirstChild("HumanoidRootPart") and Character.HumanoidRootPart:FindFirstChild("RootJoint")

                if not Character:FindFirstChild("HumanoidRootPart") then return end

                local HRPart = Character and Character:FindFirstChild("HumanoidRootPart")

                local RootJoint = HRPart and HRPart:FindFirstChild("RootJoint")

                Siren:Disable(RootJoint)
            end))
        end
    end
})

Admin:AddCommand({
    Name = {"unlr", "unlooproot"},
    Rank = 2,
    Description = "Stops the root joint loop on the player.",
    Function = function(plr, name)
        for _, Player in next, Admin.GetPlayers(plr, name) do
            RJoint:Remove(Player)
        end
    end
})

Admin:AddCommand({
    Name = {"rleg", "noleg"},
    Rank = 1,
    Description = "Disables the hip joints.",
    Function = function(plr, name)
        for _, Player in next, Admin.GetPlayers(plr, name) do
            local Character = Player.Character
            local Torso = Character and Character:FindFirstChild("Torso")
            
            local RHip = Torso and Torso:FindFirstChild("Right Hip")
            local LHip = Torso and Torso:FindFirstChild("Left Hip")

            Siren:Disable(RHip)
            Siren:Disable(LHip)
        end
    end
})

Admin:AddCommand({
    Name = {"rroot", "noroot"},
    Rank = 1,
    Description = "Disables the players movement",
    Function = function(plr, name)
        for _, Player in next, Admin.GetPlayers(plr, name) do
            local Character = Player.Character
            local HRPart = Character and Character:FindFirstChild("HumanoidRootPart")

            Siren:Disable(HRPart:FindFirstChild("RootJoint"))
        end
    end
})

Admin:AddCommand({
    Name = {"rarm", "noarm"},
    Rank = 1,
    Description = "Disables the shoulder joints.",
    Function = function(plr, name)
        for _, Player in next, Admin.GetPlayers(plr, name) do
            local Character = Player.Character
            local Torso = Character and Character:FindFirstChild("Torso")
            
            local RShoulder = Torso and Torso:FindFirstChild("Right Shoulder")
            local LShoulder = Torso and Torso:FindFirstChild("Left Shoulder")

            Siren:Disable(RShoulder)
            Siren:Disable(LShoulder)
        end
    end
})

Admin:AddCommand({
    Name = {"rlimb", "nolimb"},
    Rank = 1,
    Description = "Disables all of the joints.",
    Function = function(plr, name)
        for _, Player in next, Admin.GetPlayers(plr, name) do
            local Character = Player.Character
            local Torso = Character and Character:FindFirstChild("Torso")
            
            local RHip = Torso and Torso:FindFirstChild("Right Hip")
            local LHip = Torso and Torso:FindFirstChild("Left Hip")
            local RShoulder = Torso and Torso:FindFirstChild("Right Shoulder")
            local LShoulder = Torso and Torso:FindFirstChild("Left Shoulder")

            Siren:Disable(RShoulder)
            Siren:Disable(LShoulder)
            Siren:Disable(RHip)
            Siren:Disable(LHip)

        end
    end
})

Admin:AddCommand({
    Name = {"nohat", "rhat"},
    Rank = 1,
    Description = "Removes the player's hat.",
    Function = function(plr, name)
        for _, Player in next, Admin.GetPlayers(plr, name) do
            for _, Child in next, Player.Character:GetChildren() do
                if Child:IsA("Accessory") then
                    for _, Weld in next, Child:GetDescendants() do
                    if Weld:IsA("JointInstance") then
                        Siren:Disable(Weld)
                    end
                    end
                end
            end
            end
    end
})


Admin:AddCommand({
    Name = {"uncar", "breakcar", "bc", "unc"},
    Rank = 2,
    Description = "Breaks the car that the player is driving.",
    Function = function(plr, name)
        for _, Player in next, Admin.GetPlayers(plr, name) do
            local Character = Player.Character
            local Humanoid = Character and Character:FindFirstChild("Humanoid")

            local Seat = Humanoid and Humanoid.SeatPart

            if not Seat then return end

            for _, Car in next, workspace.CarContainer:GetChildren() do
                if Seat:IsDescendantOf(Car) then
                    Siren:BreakJoints(Car)
                end
            end
        end
    end
})
