JobHere = false
IsInMarker = false
check = 0
local name = nil
function InitMarkerJob()
    Citizen.CreateThread(function()
        while JobHere do
            local InZone = false
            local pCoords = GetEntityCoords(PlayerPedId())
            for k,v in pairs(Zone) do
                local dst = GetDistanceBetweenCoords(pCoords, v.pos, true)
                if dst < 20.0 then
                    InZone = true
                    DrawMarker(21, v.pos.x, v.pos.y, v.pos.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.5, 0.5, 0.5, 255, 255, 255, 200, 0, 1, 2, 0, nil, nil, 0)
                    if dst < 2.0 then
                        if v.text ~= nil then
                            RageUI.Text({message = v.text})
                        end
                        if IsControlJustReleased(1, 38) then
                            v.action(v.data)
                        end
                    end
                end
            end

            for k,v in pairs(ZoneFarm) do
                local dst = GetDistanceBetweenCoords(pCoords, v.pos, true)
                if dst < 20.0 then
                    InZone = true
                    check = 0
                    if not IsInMarker then
                        DrawMarker(22, v.pos.x, v.pos.y, v.pos.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.5, 0.5, 0.5, v.color.r, v.color.g, v.color.b, v.color.a, 200, 0, 1, 2, 0, nil, nil, 0)
                    end
                    if dst < 4.0 then
                        if v.text ~= nil and not IsInMarker then
                            RageUI.Text({message = v.text})
                        end
                        if IsControlJustReleased(1, 38) then
                            IsInMarker = true
                            name = v.name
                            InitAnimaction()
                            v.action(v.data)
                        end
                    elseif dst > 5.0 then
                        if name == v.name and IsInMarker then
                            IsInMarker = false
                            check = check + 1
                            if check <= 5 then
                                TriggerServerEvent(Config.prefixBuilder..":onMarkerType", v.name)
                            end
                        end
                    end
                end
            end
            if not InZone then
                Wait(500)
            else
                Wait(1)
            end
        end
    end)    
end

local dict = "anim@mp_snowball"
local anim = "pickup_snowball"
local flag = 1
function InitAnimaction()
    Citizen.CreateThread(function()
        while IsInMarker do
            RageUI.Text({message = "Pour stopper l'action, Appuyer sur X"})
            if IsControlPressed(1, 73) then
                IsInMarker = false
                TriggerServerEvent(Config.prefixBuilder..":onMarkerType", name)
                ClearPedTasks(GetPlayerPed(-1))
            end
            Wait(1)
        end
    end)
    
    Citizen.CreateThread(function()
        while IsInMarker do
            if not IsEntityPlayingAnim(GetPlayerPed(-1), dict, anim, flag) then
                Animation(dict, anim, flag)
            end
            Wait(0)
        end
    end)
end

function Animation(dict, anim, flag, blendin, blendout, playbackRate, duration)
	if blendin == nil then blendin = 1.0 end
	if blendout == nil then blendout = 1.0 end
	if playbackRate == nil then playbackRate = 1.0 end
	if duration == nil then duration = -1 end
	RequestAnimDict(dict)
	while not HasAnimDictLoaded(dict) do Wait(1) print("Waiting for "..dict) end
	TaskPlayAnim(GetPlayerPed(-1), dict, anim, blendin, blendout, duration, flag, playbackRate, 0, 0, 0)
	RemoveAnimDict(dict)
end