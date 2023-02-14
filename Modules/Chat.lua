local ChatEvents = game.ReplicatedStorage:WaitForChild("DefaultChatSystemChatEvents");
local Chat = {
    Connections = {}
};

function Chat:Connect(plr, func)
    if plr == game.Players.LocalPlayer then return end
    local ConnectionData = {};
    ConnectionData.Callback = func;
    Chat.Connections[plr.Name] = ConnectionData;
    return ConnectionData;
end
function Chat:Disconnect(plr)
    Chat.Connections[plr.Name] = nil;
end

ChatEvents.OnMessageDoneFiltering.OnClientEvent:Connect(function(data)
    local speaker = data.FromSpeaker;
    if Chat.Connections[speaker] then
        Chat.Connections[speaker].Callback(data);
    end;
end)

return Chat;