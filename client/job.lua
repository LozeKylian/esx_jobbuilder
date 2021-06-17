ESX = nil
local PlayerData = {}
local stock = {}
local job_menu = "job_menu"
local JobBlip = {}
local open = false

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent(Config.prefixBuilder..':getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end

	while ESX.GetPlayerData().job == nil do
		Citizen.Wait(10)
	end

	PlayerData = ESX.GetPlayerData()
    InitJob()
end)


RegisterNetEvent(Config.prefixBuilder..':setJob')
AddEventHandler(Config.prefixBuilder..':setJob', function(job)
	ESX.PlayerData.job = job
	InitJob()
end)

RegisterNetEvent(Config.prefixBuilder..':ModifJobDetect')
AddEventHandler(Config.prefixBuilder..':ModifJobDetect', function(job)
	JobHere = false
	Zone = {}
	ZoneFarm = {}
	InitJob()
end)


RegisterNetEvent(Config.prefixBuilder..':LoadJobClient')
AddEventHandler(Config.prefixBuilder..':LoadJobClient', function(data)
    LoadJob(data)	
end)

--RegisterNetEvent(Config.prefixBuilder..':addInventoryItem')
--AddEventHandler(Config.prefixBuilder..':addInventoryItem', function(item)
--    table.insert(ESX.PlayerData.inventory, item)
--end) 

RegisterNetEvent(Config.prefixBuilder..':removeInventoryItem')
AddEventHandler(Config.prefixBuilder..':removeInventoryItem', function(item, identifier)
	for i = 1, #ESX.PlayerData.inventory, 1 do
		if ESX.PlayerData.inventory[i].name == item.name then
			ESX.PlayerData.inventory[i].count = ESX.PlayerData.inventory[i].count-identifier
			break
		end
    end
end)


function InitJob()
	Wait(1500)
    TriggerServerEvent(Config.prefixBuilder..":LoadJobData")
	TriggerServerEvent(Config.prefixBuilder..":AddBlipJob")
	
    function LoadJob(data)
		JobHere = true
		InitMarkerJob()
		if data.grades[ESX.PlayerData.job.grade].gestion then
			RegisterZoneJob({
				name = "patron",
				pos = vector3(data.patron.x,data.patron.y,data.patron.z),
				text = "Appuyer sur ~b~E~s~ pour gêrer la societer.",
				action = function() 
					TriggerEvent('esx_society:openBossMenu', ESX.PlayerData.job.name, function(data, menu)
						menu.close()
					end)
				end
			})
		end
		if data.grades[ESX.PlayerData.job.grade].stock then
			RegisterZoneJob({
				name = "stock",
				pos = vector3(data.coffre.x,data.coffre.y,data.coffre.z),
				text = "Appuyer sur ~b~E~s~ pour ouvrir le stock.",
				action = function()
					stock = {}
					MenuStock()
				end
			})
		end
		RegisterZoneJob({
			name = "vehMenu",
			pos = vector3(data.vehmenu.x,data.vehmenu.y,data.vehmenu.z),
			text = "Appuyer sur ~b~E~s~ pour ouvrir le garage de sociéter.",
			action = function() 
				MenuVeh(data)
			end
		})
		RegisterZoneJob({
			name = "vehDelete",
			pos = vector3(data.deletecar.x, data.deletecar.y, data.deletecar.z),
			text = "Appuyer sur ~b~E~s~ pour ranger le véhicule.",
			action = function()
				if IsPedInAnyVehicle(PlayerPedId(), false) then
					if Config.OneSync then
						local veh = GetVehiclePedIsIn(PlayerPedId(), false)
						if veh ~= nil then TriggerServerEvent("DeleteEntity") end
					else
						local veh = GetVehiclePedIsIn(PlayerPedId(), false)
						if veh ~= nil then DeleteEntity(veh) end
					end
				end
				Action = false
			end
		})
		
		if data.farm then
			RegisterZoneFarm({
				name = "Recolte",
				pos = vector3(data.recoltepos.x, data.recoltepos.y, data.recoltepos.z),
				text = "Appuyer sur ~b~E~s~ pour commencer à Récolter.",
				color = {r = 42, g = 254, b = 0, a = 200},
				action = function()
					TriggerServerEvent(Config.prefixBuilder.."Job:harvest","r")
				end
			})
			table.insert(JobBlip, {name = "1/3 - Récolte", pos = vector3(data.recoltepos.x, data.recoltepos.y, data.recoltepos.z), color = 2})
			RegisterZoneFarm({
				name = "transformation",
				pos = vector3(data.transformationpos.x, data.transformationpos.y, data.transformationpos.z),
				color = {r = 254,g = 165,b = 0, a = 200},
				text = "Appuyer sur ~b~E~s~ pour commencer à Tranformer.",
				action = function()
					TriggerServerEvent(Config.prefixBuilder.."Job:transformation","t")
				end
			})
			table.insert(JobBlip, {name = "2/3 - Transformation", pos = vector3(data.transformationpos.x, data.transformationpos.y, data.transformationpos.z), color = 47})

			
			RegisterZoneFarm({
				name = "vente",
				pos = vector3(data.ventepos.x, data.ventepos.y, data.ventepos.z),
				color = {r = 240,g = 36,b = 0, a = 200},
				text = "Appuyer sur ~b~E~s~ pour commencer à Vendre.",
				action = function()
					TriggerServerEvent(Config.prefixBuilder.."Job:sell","v")
				end
			})
			table.insert(JobBlip, {name = "3/3 - Vente", pos = vector3(data.ventepos.x, data.ventepos.y, data.ventepos.z), color = 49})
			AddBlipPrivate(JobBlip)
		end

        function MenuVeh(data)
			RageUI.Visible(RMenu:Get(job_menu, 'veh_menu'), not RageUI.Visible(RMenu:Get(job_menu, 'veh_menu')))
			if open then return end
			if not open then
				open = true
				Citizen.CreateThread(function()
					while open do
						RageUI.IsVisible(RMenu:Get(job_menu, 'veh_menu'), true, true, true, function()
							for k,v in pairs(data.vehicles) do
								RageUI.ButtonWithStyle(v.label, nil, { RightLabel = "→→" }, true, function(_,_,s)
									if s then
										if not ESX.Game.IsSpawnPointClear(data.vehspawn, 3.5) then ESX.ShowNotification("~r~Point de spawn bloqué") return end
										local hash = GetHashKey(v.model)
										Citizen.CreateThread(function()
											RequestModel(hash)
											while not HasModelLoaded(hash) do Citizen.Wait(10) end
									
											local vehicle = CreateVehicle(hash, data.vehspawn.x,data.vehspawn.y,data.vehspawn.z, 90.0, true, false)
											local getchiffre = math.random(1,999)
											local newPlate = ""..ESX.PlayerData.job.name.."- "..getchiffre..""
											SetVehicleNumberPlateText(vehicle, newPlate)
											TriggerServerEvent('Kylian::0909::esx_vehiclelock:givekey', 'no', newPlate)
											TaskWarpPedIntoVehicle(PlayerPedId(), vehicle, -1)
										end)
									end
								end)
							end
						end,function()
						end)
						Wait(1)
					end
				end)
			end
        end

		RegisterNetEvent(Config.prefixBuilder..":SendSotckJob")
		AddEventHandler(Config.prefixBuilder..":SendSotckJob", function(stocks)
			stock = stocks
		end)

		function MenuStock()
			RageUI.Visible(RMenu:Get(job_menu, 'stock_menu'), not RageUI.Visible(RMenu:Get(job_menu, 'stock_menu')))
			if open then return end
			if not open then
				open = true
				Citizen.CreateThread(function()
					while open do
						RageUI.IsVisible(RMenu:Get(job_menu, 'stock_menu'), true, true, true, function()
							RageUI.ButtonWithStyle("~g~Déposer~s~ un item dans le stock de l'entreprise", nil, { RightLabel = "→→" }, true, function(_,_,s)
								if s then
									
								end
							end, RMenu:Get(job_menu,"stock_menu_deposit"))
							RageUI.ButtonWithStyle("~r~Retirer~s~ un item dans le stock de l'entreprise", nil, { RightLabel = "→→" }, true, function(_,_,s)
								if s then
									TriggerServerEvent(Config.prefixBuilder..":GetStockJob")
								end
							end, RMenu:Get(job_menu,"stock_menu_put"))
						end,function()
						end)
						RageUI.IsVisible(RMenu:Get(job_menu, 'stock_menu_deposit'), true, true, true, function()
							for i = 1, #ESX.PlayerData.inventory, 1 do
								if ESX.PlayerData.inventory[i].count > 0 then
									local invCount = {}
									for i = 1, ESX.PlayerData.inventory[i].count, 1 do
										table.insert(invCount, i)
									end
									RageUI.ButtonWithStyle(ESX.PlayerData.inventory[i].label, nil, {RightLabel = "~b~"..ESX.PlayerData.inventory[i].count.." ~r~→→"}, true, function(_,_,s)
										if s then
											local amount = KeyboardImput("Montant")
											if tonumber(amount) then
												TriggerServerEvent(Config.prefixBuilder..":AddItemToSotck",ESX.PlayerData.inventory[i].name,tonumber(amount))
											else
												ESX.ShowNotification("~r~Merci d'entrée un montant correcte !")
											end
										end
									end)
								end
							end
						end,function()
						end)

						RageUI.IsVisible(RMenu:Get(job_menu, 'stock_menu_put'), true, true, true, function()
							for _,v in pairs(stock) do
								RageUI.ButtonWithStyle(v.label, nil,{RightLabel = "~b~"..v.count.." ~r~→→"},true, function(_,_,s)
									if s then
										local amount = KeyboardImput("Montant")
										if tonumber(amount) then
											TriggerServerEvent(Config.prefixBuilder..":RemoveItemToSotck",v.name,tonumber(amount))
										else
											ESX.ShowNotification("~r~Merci d'entrée un montant correcte !")
										end
									end
								end)
							end
						end,function()
						end)
						Wait(1)
					end
				end)
			end
		end

		function RegisterMenu()
			RMenu.Add(job_menu, 'veh_menu', RageUI.CreateMenu("Garage", "~b~Garage de l'entreprise"))
			RMenu:Get(job_menu, 'veh_menu').Closed = function() open = false end
	
			RMenu.Add(job_menu, 'stock_menu', RageUI.CreateMenu("Stock", "~b~Stock de l'entreprise"))
			RMenu:Get(job_menu, 'stock_menu').Closed = function() open = false end

			RMenu.Add(job_menu, 'stock_menu_deposit', RageUI.CreateSubMenu(RMenu:Get(job_menu, 'stock_menu'),"Stock", "~g~Déposer~s~ un item"))
			RMenu:Get(job_menu, 'stock_menu_deposit').Closed = function()end

			RMenu.Add(job_menu, 'stock_menu_put', RageUI.CreateSubMenu(RMenu:Get(job_menu, 'stock_menu'),"Stock", "~r~Retirer~s~ un item"))
			RMenu:Get(job_menu, 'stock_menu_put').Closed = function() end
		end
		RegisterMenu()
    end
end

RegisterNetEvent(Config.prefixBuilder..":AddBlipJob")
AddEventHandler(Config.prefixBuilder..":AddBlipJob",function(blip)
	AddBlipPublic(blip)
end)