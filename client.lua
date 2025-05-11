local ESX = exports['es_extended']:getSharedObject()

local missionActive = false
local missionBlip = nil
local missionCoords = nil
local missionName = nil
local lastPoliceAlert = 0

-- NPC erstellen
CreateThread(function()
    local npcModel = 's_m_m_highsec_01'
    local npcCoords = vector4(892.0764, -2174.3442, 32.2863, 179.7975)

    RequestModel(npcModel)
    while not HasModelLoaded(npcModel) do Wait(0) end

    local npc = CreatePed(0, npcModel, npcCoords.x, npcCoords.y, npcCoords.z - 1, npcCoords.w, false, true)
    FreezeEntityPosition(npc, true)
    SetEntityInvincible(npc, true)
    SetBlockingOfNonTemporaryEvents(npc, true)

    exports.ox_target:addBoxZone({
        coords = vec3(npcCoords.x, npcCoords.y, npcCoords.z),
        size = vec3(1.5, 1.5, 2.0),
        rotation = npcCoords.w,
        debug = false,
        options = {
            {
                label = '📋 Auftrag annehmen',
                icon = 'fa-solid fa-clipboard',
                onSelect = function()
                    if not missionActive then
                        TriggerServerEvent('auftrag:start')
                    else
                        lib.notify({ title = 'Auftrag', description = 'Du hast bereits einen Auftrag.', type = 'error' })
                    end
                end
            },
            {
                label = '✅ Auftrag abgeben',
                icon = 'fa-solid fa-check',
                onSelect = function()
                    if not missionActive then
                        TriggerServerEvent('auftrag:complete')
                    else
                        lib.notify({ title = 'Auftrag', description = 'Beende zuerst deine aktive Mission.', type = 'error' })
                    end
                end
            },
            {
                label = '❌ Auftrag abbrechen',
                icon = 'fa-solid fa-ban',
                onSelect = function()
                    if missionActive then
                        missionActive = false
                        RemoveBlip(missionBlip)
                        missionBlip = nil
                        missionCoords = nil
                        missionName = nil
                        lib.notify({ title = 'Abgebrochen', description = 'Du hast den Auftrag abgebrochen.', type = 'error' })
                    else
                        lib.notify({ title = 'Auftrag', description = 'Du hast keinen aktiven Auftrag.', type = 'error' })
                    end
                end
            }
        }
    })
end)

RegisterNetEvent('auftrag:client:start', function(coords, mission)
    missionActive = true
    missionCoords = coords
    missionName = mission

    -- Erstelle den Blip für die Koordinaten
    missionBlip = AddBlipForCoord(coords)
    SetBlipSprite(missionBlip, 161)  -- Blip-Symbol setzen
    SetBlipColour(missionBlip, 5)    -- Blip-Farbe setzen (grün)
    SetBlipScale(missionBlip, 1.0)   -- Blip-Skalierung setzen
    SetBlipRoute(missionBlip, true)  -- Route zum Ziel setzen
    SetBlipRouteColour(missionBlip, 5)

    -- Blip einen Namen geben
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentSubstringPlayerName(missionName)  -- Hier den Namen des Auftrags setzen
    EndTextCommandSetBlipName(missionBlip)

    -- Nur eigene Notification
    lib.notify({ title = 'Auftrag', description = 'Mission gestartet: Ziel auf Karte markiert.', type = 'inform' })
end)

local function addMissionTarget(coords, mission)
    exports.ox_target:addBoxZone({
        coords = coords,
        size = vec3(2.0, 2.0, 3.0),
        rotation = 0.0,
        debug = false,
        options = {
            {
                label = '🔧 ' .. mission.name,
                icon = mission.icon,
                onSelect = function()
                    if missionActive and missionName == mission.name then
                        lib.notify({ title = 'Auftrag', description = mission.name .. ' erledigt. Zurück zum Auftraggeber.', type = 'success' })
                        TriggerServerEvent('auftrag:giveProofItem')
                        RemoveBlip(missionBlip)
                        missionActive = false
                        missionBlip = nil
                        missionCoords = nil
                        missionName = nil
                    else
                        lib.notify({ title = 'Fehler', description = 'Du hast keinen passenden Auftrag.', type = 'error' })
                    end
                end
            }
        }
    })
end

-- Alle Missionsziele
CreateThread(function()
    -- Zugriff auf die Missionsziele aus der config.lua
    for _, mission in ipairs(Config.MissionLocations) do
        addMissionTarget(mission.coords, mission)
    end
end)

-- Spieler nähert sich Missionsort – Polizei benachrichtigen
CreateThread(function()
    while true do
        Wait(1000)
        if missionActive and missionCoords then
            local dist = #(GetEntityCoords(PlayerPedId()) - missionCoords)
            if dist < 20.0 and (GetGameTimer() - lastPoliceAlert > 30000) then
                TriggerServerEvent('auftrag:policeAlert', missionCoords, missionName)
                lastPoliceAlert = GetGameTimer()
            end
        end
    end
end)

-- Polizeiblip empfangen
RegisterNetEvent('auftrag:client:policeBlip', function(coords)
    local blip = AddBlipForCoord(coords)
    SetBlipSprite(blip, 161) -- rotes Ausrufezeichen
    SetBlipScale(blip, 1.2)
    SetBlipColour(blip, 1)
    SetBlipAsShortRange(blip, true)

    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("💣 Illegale Aktivität") -- <- Hier änderst du den Blipnamen
    EndTextCommandSetBlipName(blip)

    Wait(60000)
    RemoveBlip(blip)
end)


RegisterCommand("abbrechen", function()
    if missionActive then
        missionActive = false
        RemoveBlip(missionBlip)
        missionBlip = nil
        missionCoords = nil
        missionName = nil
        lib.notify({ title = 'Auftrag', description = 'Du hast den Auftrag abgebrochen.', type = 'error' })
    end
end)

RegisterKeyMapping('abbrechen', 'Auftrag abbrechen', 'keyboard', 'F5')
