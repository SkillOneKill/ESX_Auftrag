ESX = exports['es_extended']:getSharedObject()

local playerMissionsToday = {}

local missionTypes = {
    {
        name = 'Stromkasten sabotieren',
        item = 'sabotage_kit',
        locations = {
            vector3(712.86, -964.15, 30.4),
            vector3(1151.21, -1529.62, 34.84),
            vector3(-330.14, -147.79, 39.01)
        }
    },
    {
        name = 'ATM demolieren',
        item = 'crowbar',
        locations = {
            vector3(-386.733, 6045.953, 31.501),
            vector3(1172.145, 2702.059, 38.175),
            vector3(-56.193, -1752.053, 29.421)
        }
    },
    {
        name = 'Tresor aufknacken',
        item = 'lockpick',
        locations = {
            vector3(28.24, -1339.61, 29.5),
            vector3(-43.42, -1748.2, 29.42),
            vector3(378.17, 333.42, 103.57)
        }
    }
}

RegisterNetEvent('auftrag:start', function()
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    local job = xPlayer.getJob().name

    if not Config.AllowedJobs[job] then
        TriggerClientEvent('ox_lib:notify', src, {
            title = 'Auftrag',
            description = 'Dein Job darf keine Aufträge machen.',
            type = 'error'
        })
        return
    end

    if Config.DailyLimitEnabled then
        local current = playerMissionsToday[src] or 0
        if current >= Config.MaxMissionsPerDay then
            TriggerClientEvent('ox_lib:notify', src, {
                title = 'Limit erreicht',
                description = 'Du hast dein Tageslimit erreicht.',
                type = 'error'
            })
            return
        end
        playerMissionsToday[src] = current + 1
    end

    local selectedMissionType = missionTypes[math.random(#missionTypes)]
    local selectedCoords = selectedMissionType.locations[math.random(#selectedMissionType.locations)]

    xPlayer.addInventoryItem(selectedMissionType.item, 1)
    TriggerClientEvent('auftrag:client:start', src, selectedCoords, selectedMissionType.name)
end)

RegisterNetEvent('auftrag:giveProofItem', function()
    local xPlayer = ESX.GetPlayerFromId(source)
    xPlayer.addInventoryItem(Config.ProofItem, 1)
end)

RegisterNetEvent('auftrag:complete', function()
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)

    -- Überprüfe, ob der Spieler existiert
    if not xPlayer then
        print('[auftrag:complete] Fehler: Spieler nicht gefunden für ID ' .. tostring(src))
        return
    end

    -- Überprüfe, ob der Beweisgegenstand korrekt konfiguriert ist
    if not Config.ProofItem then
        print('[auftrag:complete] Fehler: Config.ProofItem ist nicht gesetzt!')
        return
    end

    -- Beweisgegenstand prüfen
    local proofItem = xPlayer.getInventoryItem(Config.ProofItem)
    if not proofItem or proofItem.count <= 0 then
        TriggerClientEvent('ox_lib:notify', src, {
            title = 'Fehler',
            description = 'Dir fehlt der Beweisgegenstand!',
            type = 'error'
        })
        return
    end

    -- Beweisgegenstand entfernen
    xPlayer.removeInventoryItem(Config.ProofItem, 1)

    -- Missions-Item entfernen (z. B. sabotage_kit, crowbar, lockpick)
    if missionTypes and type(missionTypes) == "table" then
        for _, mission in ipairs(missionTypes) do
            local item = mission.item
            if item then
                local invItem = xPlayer.getInventoryItem(item)
                if invItem and invItem.count > 0 then
                    xPlayer.removeInventoryItem(item, 1)
                end
            end
        end
    else
        print('[auftrag:complete] Warnung: missionTypes ist nicht definiert oder kein Table.')
    end

    -- Belohnung geben
    local reward = math.random(1000, 2000)
    xPlayer.addMoney(reward)

    -- Erfolgsmeldung
    TriggerClientEvent('ox_lib:notify', src, {
        title = 'Auftrag abgeschlossen',
        description = 'Du hast $' .. reward .. ' erhalten.',
        type = 'success'
    })
end)


-- Polizei benachrichtigen bei Nähe zum Missionsziel
RegisterNetEvent('auftrag:policeAlert', function(coords, missionName)
    for _, playerId in ipairs(GetPlayers()) do
        local xPlayer = ESX.GetPlayerFromId(playerId)
        if xPlayer and xPlayer.job.name == 'police' then
            TriggerClientEvent('ox_lib:notify', playerId, {
                title = 'Polizeialarm',
                description = 'Verdächtige Aktivität bei: ' .. missionName,
                type = 'error'
            })

            -- Blip senden
            TriggerClientEvent('auftrag:client:policeBlip', playerId, coords)
        end
    end
end)
