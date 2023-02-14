local Players = game:GetService("Players")
local Teams = game:GetService("Teams")

local LocalPlayer = Players.LocalPlayer
local Chat = Import("Chat")

local Admin = {
    Admins = {},
    Commands = {},
    Silent = false,
    Ranks = {
        {
            Name = "Owner",
            Description = "The rank given to the person who ran the script.",
            Rank = math.huge
        },
        {
            Name = "Moderator",
            Description = "This rank is the equivalent to the owner rank but doesn't allow commands like rejoin or lock.",
            Rank = 420
        },
        {
            Name = "Admin",
            Description = "The normal rank given to people.",
            Rank = 1
        }
    },
    GetPlayers = function(Player, Name)
        Name = ((Name:gsub(",", ".") or Name):gsub("/", ".") or Name):lower()

        local Found = {}

        if Name:match("(%w+)%s?%.%s?(%w+)") then
            for Name, Name2 in Name:gmatch("(%w+)%s?%.%s?(%w+)") do
                print(Name, Name2)
                if Name == "me" or Name2 == "me" then
                    table.insert(Found, Player)
                end
                
                if Name == "others" or Name2 == "others" then
                    table.foreach(Players:GetPlayers(), function(_, player)
                        if not player == Player then
                            table.insert(Found, player)
                        end
                    end)
                end

                if Name == "all" or Name2 == "all" then
                    table.foreach(Players:GetPlayers(), function(_, player)
                        table.insert(Found, player)
                    end)
                end
                
                if Name == "random" or Name2 == "random" then
                    table.insert(Found, Players:GetPlayers()[math.random(1, #Players:GetPlayers())])
                end

                table.foreach(Teams:GetChildren(), function(_, Team)
                    if Team.Name:lower():match("^(" .. Name .. ")") or Team.Name:lower():match("^(" .. Name2 .. ")") then
                        table.foreach(Team:GetPlayers(), function(_, player)
                            table.insert(Found, player)
                        end)
                    end
                end)

                table.foreach(Players:GetPlayers(), function(_, player)
                    if player.Name:lower():match("^(" .. Name .. ")") or player.Name:lower():match("^(" .. Name2 .. ")") or player.DisplayName:lower():match("^(" .. Name .. ")") or player.DisplayName:lower():match("^(" .. Name2 .. ")") then
                        table.insert(Found, player)
                    end
                end)
            end

            return Found
        end

        if Name == "me" then
            table.insert(Found, Player)
        end
        
        if Name == "others" then
            table.foreach(Players:GetPlayers(), function(_, player)
                if not player == Player then
                    table.insert(Found, player)
                end
            end)
        end

        if Name == "all" then
            table.foreach(Players:GetPlayers(), function(_, player)
                table.insert(Found, player)
            end)
        end
        
        if Name == "random" then
            table.insert(Found, Players:GetPlayers()[math.random(1, #Players:GetPlayers())])
        end

        table.foreach(Teams:GetChildren(), function(_, Team)
            if Team.Name:lower():match("^(" .. Name .. ")") then
                table.foreach(Team:GetPlayers(), function(_, player)
                    table.insert(Found, player)
                end)
            end
        end)

        table.foreach(Players:GetPlayers(), function(_, player)
            if player.Name:lower():match("^(" .. Name .. ")") or player.DisplayName:lower():match("^(" .. Name .. ")") then
                table.insert(Found, player)
            end
        end)

        return Found

    end,
    SetRank = function(self, Player, Rank)
        if not self.Admins[Player] then
            self.Admins[Player] = {
                Rank = Rank,
                Prefix = ";"
            }
            if Player == LocalPlayer then
                LocalPlayer.Chatted:Connect(function(Message)
                    local PlayerData = self.Admins[Player]

                    local Command = Message:lower():match("^" .. PlayerData.Prefix .. "(%w+)%s?")
                    Command = self.Commands[Command]

                    local Args = Message:split(" ")

                    if PlayerData.Prefix:match("%s") then
                        for _ = 1, #PlayerData.Prefix:split(" ") do
                            table.remove(Args, 1)
                        end
                    end

                    table.remove(Args, 1)
                    table.insert(Args, 1, Player)

                    if not Command or Command and not table.find(Command.Whitelisted, Player) and Command.Rank > PlayerData.Rank then return end

                    local ArgCount = debug.getinfo(Command.Callback).numparams

                    if #Args > ArgCount then
                        local tmpArgs = {}
                        for i = 1, #Args - ArgCount do
                            table.insert(tmpArgs, Args[i + ArgCount])
                            table.remove(Args, i + ArgCount)
                        end
                        local Arg = Args[ArgCount] .. " " .. table.concat(tmpArgs, " ")
                        table.remove(Args, ArgCount)
                        table.insert(Args, ArgCount, Arg)
                    end

                    Command.Callback(table.unpack(Args))
                end)
                return
            end
            
            Chat:Connect(Player, function(Data)
                local Message = Data.Message
                
                local PlayerData = self.Admins[Player]

                local Command = Message:lower():match("^" .. PlayerData.Prefix .. "(%w+)%s?")
                Command = self.Commands[Command]

                local Args = Message:split(" ")

                if PlayerData.Prefix:match("%s") then
                    for _ = 1, #PlayerData.Prefix:split(" ") do
                        table.remove(Args, 1)
                    end
                end

                table.remove(Args, 1)
                table.insert(Args, 1, Player)

                if not Command or Command and not table.find(Command.Whitelisted, Player) and Command.Rank > PlayerData.Rank then return end

                local ArgCount = debug.getinfo(Command.Callback).numparams

                if #Args > ArgCount then
                    local tmpArgs = {}
                    for i = 1, #Args - ArgCount do
                        table.insert(tmpArgs, Args[i + ArgCount])
                        table.remove(Args, i + ArgCount)
                    end
                    local Arg = Args[ArgCount] .. " " .. table.concat(tmpArgs, " ")
                    table.remove(Args, ArgCount)
                    table.insert(Args, ArgCount, Arg)
                end

                Command.Callback(table.unpack(Args))
            end)
    end
        if Rank <= 0 then
            Chat:Disconnect(Player)
            self.Admins[Player] = nil
            return
        end
        self.Admins[Player].Rank = Rank
    end,
    AddCommand = function(self, Data)
        if type(Data.Name) == "table" then
            for _, Name in next, Data.Name do 
                assert(Name, "The command requires a name.")
                assert(Data.Rank, ("%s requires a rank"):format(Name))
                assert(Data.Function or Data.Callback, ("%s requires a function or callback"):format(Name))

                Data.Blacklisted = {}
                Data.Whitelisted = {}
                Data.Callback = Data.Function or Data.Callback

                Data.Description = Data.Description or ("No description was given for %s."):format(Name)
                self.Commands[Name] = Data
            end
            return
        end

        assert(Data.Name, "The command requires a name.")
        assert(Data.Rank, ("%s requires a rank"):format(Data.Name))
        assert(Data.Function or Data.Callback, ("%s requires a function or callback"):format(Data.Name))

        Data.Blacklisted = {}
        Data.Whitelisted = {}
        Data.Callback = Data.Function or Data.Callback

        Data.Description = Data.Description or ("No description was given for %s."):format(Data.Name)
        self.Commands[Data.Name] = Data
    end
}

return Admin