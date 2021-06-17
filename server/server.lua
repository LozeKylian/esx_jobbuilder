ESX = nil

TriggerEvent("esx:getSharedObject", function(obj)
    ESX = obj
end)

local Job = {}
local JobBlip = {}

local function LoadJobsInFile()
    local load = LoadResourceFile(GetCurrentResourceName(), "data/datajob.json")
    Job = json.decode(load)
    for k,v in pairs(Job) do
        TriggerEvent('esx_society:registerSociety', ""..v.name.."", ""..v.label.."", 'society_'..v.name, 'society_'..v.name, 'society_'..v.name, {type = 'public'})
    end
    for k,v in pairs(Job) do
        table.insert(JobBlip, {name = v.label, blip = Job[k].blippos})
    end

end
local function getLicense(source) 
    for k,v in pairs(GetPlayerIdentifiers(source))do      
        if string.sub(v, 1, string.len("license:")) == "license:" then
            return v
        end
    end
    return ""
end


RegisterCommand("jobbuilder", function(source)
    if source == 0 then return end
    local license = getLicense(source)
    if not Config.Authorization[license] then
        return
    end
    TriggerClientEvent(Config.prefixBuilder.."openenu", source)
end, false)

local function RefreshJobsInFile()
    SaveResourceFile(GetCurrentResourceName(), "data/datajob.json", json.encode(Job), -1)
end

Citizen.CreateThread(function()
    LoadJobsInFile()
end)


local function AddJobInBDD(data)
    MySQL.Async.execute([[
        INSERT INTO `addon_account` (name, label, shared) VALUES (@jobSociety, @jobLabel, 1);
        INSERT INTO `datastore` (name, label, shared) VALUES (@jobSociety, @jobLabel, 1);
        INSERT INTO `addon_inventory` (name, label, shared) VALUES (@jobSociety, @jobLabel, 1);
        INSERT INTO `jobs` (`name`, `label`, `whitelisted`) VALUES (@jobName, @jobLabel, 1);
    ]], {
        ['@jobName'] = data.name,
        ['@jobLabel'] = data.label,
        ['@jobSociety'] = 'society_' .. data.name
    }, function(rowsChanged)
        for k,v in pairs(data.grade) do
            MySQL.Async.execute([[
            INSERT INTO `job_grades` (`job_name`, `grade`, `name`, `label`, `salary`, `skin_male`, `skin_female`) VALUES
                (@jobName, @job_grade, @grade_name, @grade_label, @grade_salary, '{}', '{}')            
                ]], {
                ['@jobName'] = data.name,
                ['@job_grade'] = v.id,
                ['@grade_name'] = v.name,
                ['@grade_label'] = v.label,
                ['@grade_salary'] = v.salaire
            })
        end
        MySQL.Async.execute([[
        INSERT INTO `items` (`name`, `label`, `weight`, `rare`, `can_remove`) VALUES
            (@itemName, @ItemLabel, 1,0,1)
        ]], {
            ['@itemName'] = data.items.recole.name,
            ['@ItemLabel'] = data.items.recole.label
        })
        MySQL.Async.execute([[
        INSERT INTO `items` (`name`, `label`, `weight`, `rare`, `can_remove`) VALUES
            (@itemName, @ItemLabel, 1,0,1)
        ]], {
            ['@itemName'] = data.items.transformation.name,
            ['@ItemLabel'] = data.items.transformation.label
        })
    end)
end

function CreateJob(data)

    local JobData = {
        name = data.name,
        label = data.label,
        grades = data.grade,
        item = data.items,
        vehicles = data.vehicle,
        price = data.venteprix,
        vehmenu = data.posvehM,
        vehspawn = data.posvehS,
        deletecar = data.posvehD,
        vestiaire = data.posvestiaire,
        coffre = data.poscoffre,
        patron = data.pospatron,
        blip = data.blip,
        blippos = data.posblip,
        farm = data.farm,
        recoltepos = data.posfarmR,
        transformationpos = data.posfarmT,
        ventepos = data.posfarmV
    }

    Job[data.name] = JobData
    AddJobInBDD(data)
    RefreshJobsInFile()
    LoadJobsInFile()
end

local function IsJobInFile(job)
    if Job[job] ~= nil then
        return true
    else
        return false
    end
end

RegisterNetEvent(Config.prefixBuilder..":CreateJob")
AddEventHandler(Config.prefixBuilder..":CreateJob", function(data)
    local _src = source
    local xPlayer = ESX.GetPlayerFromId(_src)
    local license = getLicense(_src)
    if not Config.Authorization[license] then
        return
    else
        if not IsJobInFile(data.name) then
            CreateJob(data)
            xPlayer.showNotification("~g~Job crée, \n~r~Un reboot est obligatoire pour crée le job")

        else
            xPlayer.showNotification('~r~Le job existe déjà !')
        end
    end
end)

RegisterNetEvent(Config.prefixBuilder..":LoadJobData")
AddEventHandler(Config.prefixBuilder..":LoadJobData", function()
    local _src = source
    local xPlayer = ESX.GetPlayerFromId(_src)
    local license = getLicense(_src)
    if not Config.Authorization[license] then
        return
    else
        if IsJobInFile(xPlayer.job.name) then
            TriggerClientEvent(Config.prefixBuilder..":LoadJobClient",_src,Job[xPlayer.job.name])
        end
    end
end)

RegisterNetEvent(Config.prefixBuilder..":AddItemToSotck")
AddEventHandler(Config.prefixBuilder..":AddItemToSotck",function(item, amount)
    local _src = source
    local xPlayer = ESX.GetPlayerFromId(_src)

    local sourceItem = xPlayer.getInventoryItem(item)
    TriggerEvent('esx_addoninventory:getSharedInventory', 'society_'..xPlayer.job.name, function(inventory)
        if sourceItem.count >= amount and amount > 0 then
            xPlayer.removeInventoryItem(item, amount)
            inventory.addItem(item, amount)
            xPlayer.showNotification("Vous avez déposer un item : ~g~"..ESX.GetItemLabel(item).."  ~r~X "..amount.." !")
        else
            xPlayer.showNotification("~r~Quantité invalide")
        end
    end)
end)

RegisterNetEvent(Config.prefixBuilder..":RemoveItemToSotck")
AddEventHandler(Config.prefixBuilder..":RemoveItemToSotck",function(item, amount)
    local _src = source
    local xPlayer = ESX.GetPlayerFromId(_src)
    TriggerEvent('esx_addoninventory:getSharedInventory', 'society_'..xPlayer.job.name, function(inventory)
        local inventoryItem = inventory.getItem(item)

        if inventoryItem.count >= amount and inventoryItem.count > 0 then
            if xPlayer.canCarryItem(item, amount) then
                inventory.removeItem(item, amount)
                xPlayer.addInventoryItem(item, amount)
                xPlayer.showNotification("Vous avez retiré ~b~"..inventoryItem.label.." x ~r~"..amount.." !")
                TriggerEvent('esx_addoninventory:getSharedInventory', 'society_'..xPlayer.job.name, function(inventory)
                    TriggerClientEvent(Config.prefixBuilder..":SendSotckJob", _src, inventory.items)
                end)
            else
                xPlayer.showNotification("~r~Quantité invalide, vous êtes full (poids)")
            end
        else
            xPlayer.showNotification("~r~Quantité invalide")
        end
    end)
end)

RegisterNetEvent(Config.prefixBuilder..":GetStockJob")
AddEventHandler(Config.prefixBuilder..":GetStockJob",function()
    local _src = source
    local xPlayer = ESX.GetPlayerFromId(_src)
	TriggerEvent('esx_addoninventory:getSharedInventory', 'society_'..xPlayer.job.name, function(inventory)
        TriggerClientEvent(Config.prefixBuilder..":SendSotckJob", _src, inventory.items)
	end)
end)

local PlayerInZoneFarmR = {}
local PlayerInZoneFarmT = {}
local PlayerInZoneFarmV = {}

local type = {
    ["harvest"] = function(source,item)
        SetTimeout(Config.TimeToHarvest, function()
            if PlayerInZoneFarmR[source] then
                local xPlayer = ESX.GetPlayerFromId(source)
                if xPlayer.getInventoryItem(item) ~= nil then
                    if xPlayer.getInventoryItem(item).count <= 100 then
                        xPlayer.addInventoryItem(item, 1)
                        StartType("harvest", source, item)
                    else
                        PlayerInZoneFarmR[source] = false
                        xPlayer.showNotification("~r~Vous portez trop de chose sur vous !")
                    end
                end
            end
        end)
    end,

    ["transformation"] = function(source,item, itemRemove)
        SetTimeout(Config.TimeToTransformation, function()
            if PlayerInZoneFarmT[source] then
                local xPlayer = ESX.GetPlayerFromId(source)
                if xPlayer.getInventoryItem(item) ~= nil then
                    if xPlayer.getInventoryItem(item).count <= Config.MaxItemToTransformation then
                        xPlayer.removeInventoryItem(itemRemove, 1)
                        xPlayer.addInventoryItem(item, 1)
                        StartType("transformation", source, item,itemRemove)
                    else
                        PlayerInZoneFarmT[source] = false
                        xPlayer.showNotification("~r~Vous portez trop de chose sur vous !")
                    end
                end
            end
        end)
    end,

    ["sell"] = function(source, item)
        SetTimeout(Config.TimeToVente, function()
            if PlayerInZoneFarmV[source] then
                local xPlayer = ESX.GetPlayerFromId(source)
                if xPlayer.getInventoryItem(item) ~= nil then
                    if xPlayer.getInventoryItem(item).count ~= 0 then
                        xPlayer.removeInventoryItem(item, 1)
                        xPlayer.showNotification("Vous avez gagner ~g~"..Job[xPlayer.job.name].price.."~s~$ !")
                        xPlayer.addMoney(tonumer(Job[xPlayer.job.name].price))
                        StartType("sell", source, item)
                    end
                end
            end
        end)
    end,
}

function StartType(types,_src,item,items)
    for k,v in pairs(type) do
        if k == types then
            v(_src, item,items)
        end
    end
end

for k,v in pairs(type) do
    RegisterNetEvent(Config.prefixBuilder.."Job:"..k)
    AddEventHandler(Config.prefixBuilder.."Job:"..k, function(types)
        local _src = source
        local xPlayer = ESX.GetPlayerFromId(_src)
        if types == "r" then
            if not PlayerInZoneFarmR[_src] then
                PlayerInZoneFarmR[_src] = true
                v(_src, Job[xPlayer.job.name].item.recole.name)
            end
        elseif types == "t" then
            if not PlayerInZoneFarmT[_src] then
                PlayerInZoneFarmT[_src] = true
                v(_src, Job[xPlayer.job.name].item.transformation.name, Job[xPlayer.job.name].item.recole.name)
            end
        else
            if not PlayerInZoneFarmV[_src] then
                PlayerInZoneFarmV[_src] = true
                v(_src, Job[xPlayer.job.name].item.transformation.name)
            end
        end
    end)
end

RegisterNetEvent(Config.prefixBuilder..":onMarkerType")
AddEventHandler(Config.prefixBuilder..":onMarkerType", function(types)
    local _src = source
    if types == "Recolte" then
        if PlayerInZoneFarmR[_src] then
            PlayerInZoneFarmR[_src] = false
        end
    elseif types == "transformation" then
        if PlayerInZoneFarmT[_src] then
            PlayerInZoneFarmT[_src] = false
        end
    else
        if PlayerInZoneFarmV[_src] then
            PlayerInZoneFarmV[_src] = false
        end
    end
end)

RegisterNetEvent(Config.prefixBuilder..":GetJobEdit")
AddEventHandler(Config.prefixBuilder..":GetJobEdit",function()
    local _src = source
    local license = getLicense(_src)
    if not Config.Authorization[license] then
        return
    else
        TriggerClientEvent(Config.prefixBuilder..":GetJobEdit", _src, Job)
    end
end)

function UpdateJobModif(index, data)
    Job[index] = data
    RefreshJobsInFile()
    LoadJobsInFile()
    TriggerClientEvent(Config.prefixBuilder..":ModifJobDetect", -1,Job)
end

RegisterNetEvent(Config.prefixBuilder..":ModificationJob")
AddEventHandler(Config.prefixBuilder..":ModificationJob",function(index, modif)
    local _src = source
    local license = getLicense(_src)
    if not Config.Authorization[license] then
        return
    else
        UpdateJobModif(index, modif)
    end
end)


RegisterNetEvent(Config.prefixBuilder..":AddBlipJob")
AddEventHandler(Config.prefixBuilder..":AddBlipJob",function()
    local _src = source
    TriggerClientEvent(Config.prefixBuilder..":AddBlipJob", _src, JobBlip)
end)