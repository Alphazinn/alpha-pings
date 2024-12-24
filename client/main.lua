-- Locals
local QBCore = exports["qb-core"]:GetCoreObject()
local CurrentMarkers = {}
local TimeSinceLastAction = 0
local HoldingButtonTime = 0
local LastPingTime = 0

-- Functions
local function CalculateForwardVector(rotation)
    local RadX, RadZ = math.rad(rotation.x), math.rad(rotation.z)
    local CosX = math.cos(RadX)
    return vector3(-math.sin(RadZ) * CosX, math.cos(RadZ) * CosX, math.sin(RadX))
end

local function GetCoordinatesFromCrosshair()
    local PlayerPed = PlayerPedId()
    local CamCoords = GetGameplayCamCoord()
    local ForwardVector = CalculateForwardVector(GetGameplayCamRot(0))

    local RayEnd = CamCoords + (ForwardVector * 1000.0)
    local RayHandle = StartExpensiveSynchronousShapeTestLosProbe(CamCoords.x, CamCoords.y, CamCoords.z, RayEnd.x, RayEnd.y, RayEnd.z, -1, PlayerPed, 7)
    local _, Hit, EndCoords = GetShapeTestResult(RayHandle)

    return Hit == 1 and EndCoords or nil
end

local function DrawPing(x, y, z, text)
    local OnScreen, _x, _y = World3dToScreen2d(x, y, z)
    if OnScreen then
        SetTextScale(0.35, 0.35)
        SetTextFont(4)
        SetTextProportional(1)
        SetTextColour(255, 255, 255, 215)
        SetTextDropShadow(0, 0, 0, 55)
        SetTextEdge(0, 0, 0, 150)
        SetTextDropShadow()
        SetTextOutline()
        SetTextEntry("STRING")
        SetTextCentre(1)
        AddTextComponentString(text)
        DrawText(_x, _y)
    end
end

local function DrawMarkerAndText(coords)
    if coords then
        DrawPing(coords.x, coords.y, coords.z, Config.PingIcon)
    end
end

-- Threads
CreateThread(function()
    while true do
        Wait(0)

        for Player, Coords in pairs(CurrentMarkers) do
            DrawMarkerAndText(Coords)

            -- Time check to delete the marker
            TimeSinceLastAction = TimeSinceLastAction + GetFrameTime() * 1000
            if TimeSinceLastAction >= Config.MarkerTimeout then
                TriggerServerEvent("alpha-pings:DeletePing", Player)
                CurrentMarkers[Player] = nil
            end
        end

        -- Hold Key to delete the marker
        if IsControlPressed(0, Config.Key) then
            HoldingButtonTime = HoldingButtonTime + GetFrameTime() * 1000
            if HoldingButtonTime >= Config.ButtonHoldTime then
                TriggerServerEvent("alpha-pings:DeletePing", GetPlayerServerId(PlayerId()))
                HoldingButtonTime = 0
            end
        else
            HoldingButtonTime = 0
        end

        -- Press Key to create a marker
        if IsPlayerFreeAiming(PlayerId()) and IsControlJustPressed(0, Config.Key) then
            local CurrentTime = GetGameTimer()
            if CurrentTime - LastPingTime >= Config.DelayTime then
                local coords = GetCoordinatesFromCrosshair()
                if coords then
                    TriggerServerEvent("alpha-pings:SendPing", coords)
                    LastPingTime = CurrentTime
                    TimeSinceLastAction = 0
                    HoldingButtonTime = 0
                    if Config.PlaySound then
                        PlaySoundFrontend(-1, Config.SoundName, Config.SoundSetName)
                    end
                else
                    QBCore.Functions.Notify("Can't find a surface.", "error")
                end
            else
                QBCore.Functions.Notify("Please wait before pinging again!", "error")
            end
        end
    end
end)

-- Events
RegisterNetEvent("alpha-pings:ReceivePing", function(player, coords)
    CurrentMarkers[player] = coords
    TimeSinceLastAction = 0
end)

RegisterNetEvent("alpha-pings:DeletePing", function(player)
    if CurrentMarkers[player] then
        CurrentMarkers[player] = nil
    -- else
        -- print("No ping found for player " .. player)  -- Debug: No ping found
    end
end)

-- Commands
RegisterCommand("apcreateteam", function()
    TriggerServerEvent("alpha-pings:CreateTeam")
end)

RegisterCommand("apjointeam", function(source, args)
    local TeamID = tonumber(args[1])
    if not TeamID then
        QBCore.Functions.Notify("Invalid team ID!", "error")
        return
    end
    TriggerServerEvent("alpha-pings:JoinTeam", TeamID)
end)

RegisterCommand("apaccept", function(source, args)
    local PlayerID = tonumber(args[1])
    if not PlayerID then
        QBCore.Functions.Notify("Invalid player ID!", "error")
        return
    end
    TriggerServerEvent("alpha-pings:AcceptRequest", PlayerID)
end)

RegisterCommand("apleaveteam", function()
    TriggerServerEvent("alpha-pings:LeaveTeam")
end)

RegisterCommand("apdeleteteam", function()
    TriggerServerEvent("alpha-pings:DeleteTeam")
end)
