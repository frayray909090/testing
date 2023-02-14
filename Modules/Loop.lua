local Loop = {
    Loops = {},
    Add = function(self, name)
        assert(name, "A name is needed for this loop.")
        assert(not self.Loops[name], ("%s already exists as a loop."):format(name))
        self.Loops[name] = {
            Name = name,
            Remove = function(self, player)
                if not player or not self.Players[player] then return end
                -- assert(player, "A player is needed.")
                -- assert(self.Players[player], ("%s doesn't have a connection."):format(player.Name))
                self.Players[player]:Disconnect()
                self.Players[player] = nil
            end,
            Append = function(self, player, connection)
                assert(connection, "A connection is needed.")
                if self.Players[player] then
                    self.Players[player]:Disconnect()
                end
                -- assert(not self.Players[player], ("%s already has a connection."):format(player.Name))

                self.Players[player] = connection
            end,
            Players = {}
        }

        return self.Loops[name]
    end
}

return Loop