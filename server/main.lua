-- Locals
local Teams = {}
local JoinRequests = {}

-- Events
RegisterNetEvent("alpha-pings:CreateTeam", function()
    local src = source
    if Teams[src] then
        TriggerClientEvent("QBCore:Notify", src, "You already have a team!", "error")
        return
    end

    Teams[src] = { owner = src, members = { src } }
    TriggerClientEvent("QBCore:Notify", src, "Team created successfully!", "success")
end)

RegisterNetEvent("alpha-pings:JoinTeam", function(TargetTeamID)
    local src = source
    if not TargetTeamID or not Teams[TargetTeamID] then
        TriggerClientEvent("QBCore:Notify", src, "No team was found with the specified ID.", "error")
        return
    end

    if Teams[src] then
        TriggerClientEvent("QBCore:Notify", src, "You already have a team!", "error")
        return
    end

    JoinRequests[src] = TargetTeamID
    local ownerId = Teams[TargetTeamID].owner
    TriggerClientEvent("QBCore:Notify", src, "A request to join the team has been sent.", "success")
    TriggerClientEvent("QBCore:Notify", ownerId, ("Player [%d] wants to join your team. You can accept it with /aaccept %d."):format(src, src), "primary")
end)

RegisterNetEvent("alpha-pings:AcceptRequest", function(NewMemberID)
    local src = source
    if not Teams[src] then
        TriggerClientEvent("QBCore:Notify", src, "You don't own a team.", "error")
        return
    end

    if not JoinRequests[NewMemberID] or JoinRequests[NewMemberID] ~= src then
        TriggerClientEvent("QBCore:Notify", src, "This player has not sent a request to join the team.", "error")
        return
    end

    table.insert(Teams[src].members, NewMemberID)
    JoinRequests[NewMemberID] = nil
    TriggerClientEvent("QBCore:Notify", src, ("Player [%d] has joined the team!"):format(NewMemberID), "success")
    TriggerClientEvent("QBCore:Notify", NewMemberID, ("You have joined team [%d]!"):format(src), "success")
end)

RegisterNetEvent("alpha-pings:SendPing", function(coords)
    local src = source
    for TeamID, TeamData in pairs(Teams) do
        if table.hasValue(TeamData.members, src) then
            for _, memberId in ipairs(TeamData.members) do
                TriggerClientEvent("alpha-pings:ReceivePing", memberId, src, coords)
            end
            return
        end
    end
    TriggerClientEvent("QBCore:Notify", src, "You are not a member of a team!", "error")
end)

RegisterNetEvent("alpha-pings:DeletePing", function(player)
    local src = source

    for TeamID, TeamData in pairs(Teams) do
        if table.hasValue(TeamData.members, src) then
            for _, memberId in ipairs(TeamData.members) do
                TriggerClientEvent("alpha-pings:DeletePing", memberId, player)
            end
            return
        end
    end
end)

RegisterNetEvent("alpha-pings:LeaveTeam", function()
    local src = source
    for TeamID, TeamData in pairs(Teams) do
        if TeamData.owner == src then
            TriggerClientEvent("QBCore:Notify", src, "You cannot leave the team because you are the team owner!", "error")
            return
        end

        if table.hasValue(TeamData.members, src) then
            for i, memberId in ipairs(TeamData.members) do
                if memberId == src then
                    table.remove(TeamData.members, i)
                    TriggerClientEvent("QBCore:Notify", src, "You have successfully left the team!", "success")
                    return
                end
            end
        end
    end
    TriggerClientEvent("QBCore:Notify", src, "You are not a member of a team!", "error")
end)

RegisterNetEvent("alpha-pings:DeleteTeam", function()
    local src = source
    if Teams[src] then
        Teams[src] = nil
        TriggerClientEvent("QBCore:Notify", src, "Team deleted successfully!", "success")
    else
        TriggerClientEvent("QBCore:Notify", src, "You don't own a team!", "error")
    end
end)

-- Functions
table.hasValue = function(tab, val)
    for _, v in ipairs(tab) do
        if v == val then
            return true
        end
    end
    return false
end
