Blip = {}

function KeyboardImput(text)
    local amount = nil
    AddTextEntry("CUSTOM_AMOUNT", text)
    DisplayOnscreenKeyboard(1, "CUSTOM_AMOUNT", '', "", '', '', '', 255)

    while UpdateOnscreenKeyboard() ~= 1 and UpdateOnscreenKeyboard() ~= 2 do
        Citizen.Wait(0)
    end

    if UpdateOnscreenKeyboard() ~= 2 then
        amount = GetOnscreenKeyboardResult()
        Citizen.Wait(1)
    else
        Citizen.Wait(1)
    end
    return amount
end


Zone = {}

function RegisterZoneJob(zone)
	table.insert(Zone, zone)
end

ZoneFarm = {}

function RegisterZoneFarm(zone)
	table.insert(ZoneFarm, zone)
end

function AddBlipPublic(blip)
    for k,v in pairs(blip) do
        local blip = AddBlipForCoord(v.blip.x, v.blip.y, v.blip.z)
        SetBlipSprite (blip, 85)
        SetBlipDisplay(blip, 4)
        SetBlipScale  (blip, 1.0)
        SetBlipColour (blip, 19)
        SetBlipAsShortRange(blip, true)

        BeginTextCommandSetBlipName('STRING')
        AddTextComponentString(v.name)
        EndTextCommandSetBlipName(blip)
        table.insert(Blip, blip)
    end
end

function AddBlipPrivate(blip)
    for k,v in pairs(blip) do
        local blip = AddBlipForCoord(v.pos)
        SetBlipSprite (blip, 392)
        SetBlipDisplay(blip, 4)
        SetBlipScale  (blip, 0.6)
        SetBlipColour (blip, v.color)
        SetBlipAsShortRange(blip, true)

        BeginTextCommandSetBlipName('STRING')
        AddTextComponentString(v.name)
        EndTextCommandSetBlipName(blip)
        table.insert(Blip, blip)
    end
end