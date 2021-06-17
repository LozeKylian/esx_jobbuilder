local open = false
local catmenu = "job_builder"
local vehIndex,gradeIndex,vehEditIndex,gradeEditIndex,JobIndex = 1,1,1,1,1
local TrueFalseIndex1 = 1
local TrueFalseIndex2 = 1
local Jobs = {}
local DataJob = {
    name = "",
    label = "",
    blip = true,
    posblip = vector3(0,0,0),
    farm = false,
    posfarmR = vector3(0,0,0),
    posfarmT = vector3(0,0,0),
    posfarmV = vector3(0,0,0),
    pospatron = vector3(0,0,0),
    poscoffre = vector3(0,0,0),
    posvestiaire = vector3(0,0,0),
    posvehM = vector3(0,0,0),
    posvehS = vector3(0,0,0),
    posvehD = vector3(0,0,0),
    venteprix = 5,
    vehicle = {
        {model = "guardian", label = "Véhicule de farm"}
    },
    items = {
        recole = {name = "", label = ""},
        transformation = {name = "", label = ""}
    },
    grade = {
        {id = 1, name = "farmer", label = "Fermier", salaire = 50, stock = true, gestion = false}
    }
}

RMenu.Add(catmenu, 'main', RageUI.CreateMenu("JobBuilder", "~b~Crée ou modifie un job"))
RMenu:Get(catmenu, 'main').Closed = function() open = false end

RMenu.Add(catmenu, 'job_builder_create', RageUI.CreateSubMenu(RMenu:Get(catmenu, 'main'), "Crée un job", "~b~Crée un job"))
RMenu:Get(catmenu, 'job_builder_create').Closed = function()end

RMenu.Add(catmenu, 'job_builder_create_edit_car', RageUI.CreateSubMenu(RMenu:Get(catmenu, 'job_builder_create'), "Modifier un véhicule", "~b~Modifier un véhicule"))
RMenu:Get(catmenu, 'job_builder_create_edit_car').Closed = function()end

RMenu.Add(catmenu, 'job_builder_create_edit_grade', RageUI.CreateSubMenu(RMenu:Get(catmenu, 'job_builder_create'), "Modifier un Grade", "~b~Modifier un Grade"))
RMenu:Get(catmenu, 'job_builder_create_edit_grade').Closed = function()end

RMenu.Add(catmenu, 'job_builder_edit', RageUI.CreateSubMenu(RMenu:Get(catmenu, 'main'), "Modifier un Job", "~b~Modifier un Job"))
RMenu:Get(catmenu, 'job_builder_edit').Closed = function()end

RMenu.Add(catmenu, 'job_builder_edit_main', RageUI.CreateSubMenu(RMenu:Get(catmenu, 'job_builder_edit'), "Modifier un Job", "~b~Modifier un Job"))
RMenu:Get(catmenu, 'job_builder_edit_main').Closed = function()end

RMenu.Add(catmenu, 'job_edit_car', RageUI.CreateSubMenu(RMenu:Get(catmenu, 'job_builder_edit_main'), "Modifier un Véhicule", "~b~Modifier un Job"))
RMenu:Get(catmenu, 'job_edit_car').Closed = function()end

RMenu.Add(catmenu, 'job_edit_grade', RageUI.CreateSubMenu(RMenu:Get(catmenu, 'job_builder_edit_main'), "Modifier un Grade", "~b~Modifier un Job"))
RMenu:Get(catmenu, 'job_edit_grade').Closed = function()end

RegisterNetEvent(Config.prefixBuilder..":GetJobEdit")
AddEventHandler(Config.prefixBuilder..":GetJobEdit",function(job)
    Jobs = job
end)

function MenuOpenJob()
    if open then open = false end
    if not open then
        open = true
        Citizen.CreateThread(function()
            while open do
                RageUI.IsVisible(RMenu:Get(catmenu, 'main'), true, true, true, function()

                    RageUI.ButtonWithStyle("~b~Crée un Job", nil, { RightLabel = "→→" }, true, function()
                    end, RMenu:Get(catmenu, 'job_builder_create'))

                    RageUI.ButtonWithStyle("~g~Réinitialiser la création du job", nil, { RightLabel = "→→" }, true, function(_,_,s)
                        if s then
                            DataJob = {
                                name = "",
                                label = "",
                                blip = true,
                                posblip = vector3(0,0,0),
                                farm = false,
                                posfarmR = vector3(0,0,0),
                                posfarmT = vector3(0,0,0),
                                posfarmV = vector3(0,0,0),
                                pospatron = vector3(0,0,0),
                                poscoffre = vector3(0,0,0),
                                posvestiaire = vector3(0,0,0),
                                posvehM = vector3(0,0,0),
                                posvehS = vector3(0,0,0),
                                posvehD = vector3(0,0,0),
                                venteprix = 5,
                                vehicle = {
                                    {model = "guardian", label = "Véhicule de farm"}
                                },
                                items = {
                                    recole = {name = "", label = ""},
                                    transformation = {name = "", label = ""}
                                },
                                grade = {
                                    {id = 1, name = "farmer", label = "Fermier", salaire = 50, stock = true, gestion = false}
                                }
                            }
                        end
                    end)

                    RageUI.ButtonWithStyle("~b~Modifier un job", nil, { RightLabel = "→→" }, true, function(_,_,s)
                        if s then
                            TriggerServerEvent(Config.prefixBuilder..":GetJobEdit")
                        end
                    end, RMenu:Get(catmenu, 'job_builder_edit'))

                end,function()
                end)

                RageUI.IsVisible(RMenu:Get(catmenu, 'job_builder_create'), true, true, true, function()
                    local pCoords = GetEntityCoords(PlayerPedId())

                    RageUI.Separator("")


                    RageUI.ButtonWithStyle("→ Nom du job", nil, { RightLabel = ""..DataJob.name.."" }, true, function(_,_,s)
                        if s then
                            local text = KeyboardImput("Job : Nom")
                            if text ~= nil then
                                DataJob.name = text
                            end
                        end
                    end)

                    RageUI.ButtonWithStyle("→ Label du job", nil, { RightLabel = ""..DataJob.label.."" }, true, function(_,_,s)
                        if s then
                            local text = KeyboardImput("Job : Label")
                            if text ~= nil then
                                DataJob.label = text
                            end
                        end
                    end)

                    RageUI.Separator("")

                    RageUI.List("→ Blip", {"Oui","Non"}, TrueFalseIndex1, "~g~Entrez~s~ pour validez", {}, true, function(_, _, s, Index)
                        if s then
                            if TrueFalseIndex1 == 1 then
                                DataJob.blip = true
                            else
                                DataJob.blip = false
                            end
                        end
                        TrueFalseIndex1 = Index
                    end)

                    if DataJob.blip then
                        RageUI.ButtonWithStyle("→ Pos du Blip", "~g~Entrez~s~ pour validez", { RightLabel = ""..DataJob.posblip.."" }, true, function(_,_,s)
                            if s then
                                DataJob.posblip = pCoords
                            end
                        end)
                    end
                    RageUI.Separator("")
                    
                    RageUI.List("→ Farm", {"Oui","Non"}, TrueFalseIndex2, "~g~Entrez~s~ pour validez", {}, true, function(_, _, s, Index)
                        if s then
                            if TrueFalseIndex2 == 1 then
                                DataJob.farm = true
                            else
                                DataJob.farm = false
                            end
                        end
                        TrueFalseIndex2 = Index
                    end)

                    if DataJob.farm then
                        RageUI.ButtonWithStyle("→ Pos Farm Récolte", nil, { RightLabel = ""..DataJob.posfarmR.."" }, true, function(_,_,s)
                            if s then
                                DataJob.posfarmR = pCoords
                            end
                        end)

                        RageUI.ButtonWithStyle("→ Pos Farm Transformation", nil, { RightLabel = ""..DataJob.posfarmT.."" }, true, function(_,_,s)
                            if s then
                                DataJob.posfarmT = pCoords
                            end
                        end)

                        RageUI.ButtonWithStyle("→ Pos Farm Vente", nil, { RightLabel = ""..DataJob.posfarmV.."" }, true, function(_,_,s)
                            if s then
                                DataJob.posfarmV = pCoords
                            end
                        end)

                        RageUI.Separator("")


                        RageUI.ButtonWithStyle("→ Prix de la vente", nil, { RightLabel = ""..DataJob.venteprix.."" }, true, function(_,_,s)
                            if s then
                                local text = KeyboardImput("Job : prix de la vente")
                                if tonumber(text) then
                                    DataJob.venteprix = tonumber(text)
                                else
                                    ESX.ShowNotification("~r~Veuillez entrez des chiffres")
                                end
                            end
                        end)


                        RageUI.ButtonWithStyle("→ Item Récolte", nil, { RightLabel = ""..DataJob.items.recole.label.."" }, true, function(_,_,s)
                            if s then
                                local text = KeyboardImput("Job : item Récolte Name")
                                if text ~= nil then
                                    DataJob.items.recole.name = text
                                    local text1 = KeyboardImput("Job : item Récolte Label")
                                    if text1 ~= nil then
                                        DataJob.items.recole.label = text1
                                    end
                                end
                            end
                        end)

                        RageUI.ButtonWithStyle("→ Item Transformation", nil, { RightLabel = ""..DataJob.items.transformation.label.."" }, true, function(_,_,s)
                            if s then
                                local text = KeyboardImput("Job : item Transformation Name")
                                if text ~= nil then
                                    DataJob.items.transformation.name = text
                                    local text1 = KeyboardImput("Job : item Transformation Label")
                                    if text1 ~= nil then
                                        DataJob.items.transformation.label = text1
                                    end
                                end
                            end
                        end)
                    end

                    RageUI.Separator("")


                    RageUI.ButtonWithStyle("~g~→ Ajoutée un grade", nil, { RightLabel = "" }, true, function(_,_,s)
                        if s then
                            local text = KeyboardImput("Name du grade")
                            if text ~= nil then
                                local text2 = KeyboardImput("Label du grade")
                                if text2 ~= nil then
                                    local text3 = KeyboardImput("Salaire du grade")
                                    if text3 ~= nil then
                                        table.insert(DataJob.grade, {id = #DataJob.grade+1,name = text, label = text2, salaire = tonumber(text3), stock = false, gestion = false})
                                    end
                                end
                            end
                        end
                    end)
                    

                    for k,v in pairs(DataJob.grade) do
                        RageUI.ButtonWithStyle("[~b~"..v.id.."~s~] - "..v.label.." (~g~ "..v.salaire.." ~s~$)",nil, {}, true, function(_,_,s)
                            if s then
                                gradeIndex = k
                            end
                        end, RMenu:Get(catmenu, 'job_builder_create_edit_grade'))
                    end

                    RageUI.Separator("")
                    
                    RageUI.ButtonWithStyle("→ Pos Patron", nil, { RightLabel = ""..DataJob.pospatron.."" }, true, function(_,_,s)
                        if s then
                            DataJob.pospatron = pCoords
                        end
                    end)

                    RageUI.ButtonWithStyle("→ Pos Coffre", nil, { RightLabel = ""..DataJob.poscoffre.."" }, true, function(_,_,s)
                        if s then
                            DataJob.poscoffre = pCoords
                        end
                    end)


                    RageUI.ButtonWithStyle("→ Pos Vestiaire", nil, { RightLabel = ""..DataJob.posvestiaire.."" }, true, function(_,_,s)
                        if s then
                            DataJob.posvestiaire = pCoords
                        end
                    end)
                    
                    RageUI.Separator("")


                    RageUI.ButtonWithStyle("→ Pos Véhicule menu", nil, { RightLabel = ""..DataJob.posvehM.."" }, true, function(_,_,s)
                        if s then
                            DataJob.posvehM = pCoords
                        end
                    end)

                    RageUI.ButtonWithStyle("→ Pos Véhicule Spawn", nil, { RightLabel = ""..DataJob.posvehS.."" }, true, function(_,_,s)
                        if s then
                            DataJob.posvehS = pCoords
                        end
                    end)
                    
                    RageUI.ButtonWithStyle("→ Pos Delete Véhicule", nil, { RightLabel = ""..DataJob.posvehD.."" }, true, function(_,_,s)
                        if s then
                            DataJob.posvehD = pCoords
                        end
                    end)

                    RageUI.Separator("")

                    RageUI.ButtonWithStyle("~g~→ Ajoutée un véhicule", nil, { RightLabel = "" }, true, function(_,_,s)
                        if s then
                            local text = KeyboardImput("Model du véhicule")
                            if text ~= nil then
                                local text2 = KeyboardImput("Label du véhicule")
                                if text2 ~= nil then
                                    table.insert(DataJob.vehicle, {model = text, label = text2})
                                end
                            end
                        end
                    end)

                    for k,v in pairs(DataJob.vehicle) do
                        RageUI.ButtonWithStyle("[~o~"..v.model.."~s~] - "..v.label.."",nil, {}, true, function(_,_,s)
                            if s then
                                vehIndex = k
                            end
                        end, RMenu:Get(catmenu, 'job_builder_create_edit_car'))
                    end

                    RageUI.Separator("")

                    RageUI.ButtonWithStyle("~g~→ Crée le job", nil, { RightLabel = "" }, true, function(_,_,s)
                        if s then
                            TriggerServerEvent(Config.prefixBuilder..":CreateJob",DataJob)
                        end
                    end)

                end,function()
                end)

                RageUI.IsVisible(RMenu:Get(catmenu, 'job_builder_create_edit_car'), true, true, true, function()
                    local self = DataJob.vehicle[vehIndex]
                    RageUI.ButtonWithStyle("→ Model", nil, {RightLabel = "("..tostring(self.model)..")"}, true, function(_,_,s)
                        if s then
                            local text = KeyboardImput("Model")
                            if text ~= nil then
                                self.model = text
                            end
                        end
                    end)
                    RageUI.ButtonWithStyle("→ Label", nil, {RightLabel = "("..tostring(self.label)..")"}, true, function(_,_,s)
                        if s then
                            local text = KeyboardImput("Label")
                            if text ~= nil then
                                self.label = text
                            end
                        end
                    end)
                end,function()
                end)

                RageUI.IsVisible(RMenu:Get(catmenu, 'job_builder_create_edit_grade'), true, true, true, function()
                    local self = DataJob.grade[gradeIndex]
                    RageUI.ButtonWithStyle("→ ID Grade", nil, {RightLabel = "~b~ "..tostring(self.id)..""}, true, function(_,_,s)
                        if s then
                            local text = KeyboardImput("Grade: ID")
                            if text ~= nil then
                                self.grade = tonumber(text)
                            end
                        end
                    end)

                    RageUI.ButtonWithStyle("→ Name", nil, {RightLabel = "~o~ "..tostring(self.name)..""}, true, function(_,_,s)
                        if s then
                            local text = KeyboardImput("Grade: Name")
                            if text ~= nil then
                                self.name = text
                            end
                        end
                    end)
                    RageUI.ButtonWithStyle("→ Label", nil, {RightLabel = "~r~ "..tostring(self.label)..""}, true, function(_,_,s)
                        if s then
                            local text = KeyboardImput("Grade: Label")
                            if text ~= nil then
                                self.label = text
                            end
                        end
                    end)
                    RageUI.ButtonWithStyle("→ Salaire", nil, {RightLabel = "~g~ "..tostring(self.salaire)..""}, true, function(_,_,s)
                        if s then
                            local text = KeyboardImput("Grade: salaire")
                            if text ~= nil then
                                self.salaire = tonumber(text)
                            end
                        end
                    end)

                    RageUI.List("→ Accès gestion", {"Oui","Non"}, TrueFalseIndex1, "~g~Entrez~s~ pour validez", {}, true, function(_, _, s, Index)
                        if s then
                            if TrueFalseIndex1 == 1 then
                                self.gestion = true
                            else
                                self.gestion = false
                            end
                        end
                        TrueFalseIndex1 = Index
                    end)

                    RageUI.List("→ Accès coffre", {"Oui","Non"}, TrueFalseIndex2, "~g~Entrez~s~ pour validez", {}, true, function(_, _, s, Index)
                        if s then
                            if TrueFalseIndex2 == 1 then
                                self.stock = true
                            else
                                self.stock = false
                            end
                        end
                        TrueFalseIndex2 = Index
                    end)
                end,function()
                end)

                RageUI.IsVisible(RMenu:Get(catmenu, 'job_builder_edit'), true, true, true, function()
                    for k,v in pairs(Jobs) do
                        RageUI.ButtonWithStyle(v.label, nil, {RightLabel = ""}, true, function(_,_,s)
                            if s then
                                JobIndex = k
                            end
                        end, RMenu:Get(catmenu,"job_builder_edit_main"))
                    end
                end,function()
                end)

                RageUI.IsVisible(RMenu:Get(catmenu, 'job_builder_edit_main'), true, true, true, function()
                    local self = Jobs[JobIndex]
                    local pCoords = GetEntityCoords(PlayerPedId())
                    RageUI.Separator("~o~"..self.name.."")
                    RageUI.Separator("~o~"..self.label.."")

                    RageUI.Separator("~b~Position Entreprise")
                    RageUI.ButtonWithStyle("Changer la position de l'action Patron", nil, {RightLabel = ""}, true, function(_,_,s)
                        if s then
                            self.patron = pCoords
                        end
                    end)

                    RageUI.ButtonWithStyle("Changer la position du Stock", nil, {RightLabel = ""}, true, function(_,_,s)
                        if s then
                            self.coffre = pCoords
                        end
                    end)

                    if self.blip then
                        RageUI.Separator("~b~Position blip")
                        RageUI.ButtonWithStyle("Changer la position du blip", nil, {RightLabel = ""}, true, function(_,_,s)
                            if s then
                                self.blippos = pCoords
                            end
                        end)
                    end

                    RageUI.Separator("~b~Position véhicule")
                    RageUI.ButtonWithStyle("Changer la position du menu véhicule", nil, {RightLabel = ""}, true, function(_,_,s)
                        if s then
                            self.vehmenu = pCoords
                        end
                    end)

                    RageUI.ButtonWithStyle("Changer la position du spawn de véhicule", nil, {RightLabel = ""}, true, function(_,_,s)
                        if s then
                            self.vehspawn = pCoords
                        end
                    end)

                    RageUI.ButtonWithStyle("Changer la position du delete de véhicule", nil, {RightLabel = ""}, true, function(_,_,s)
                        if s then
                            self.deletecar = pCoords
                        end
                    end)

                    if self.farm then
                        RageUI.Separator("~b~Position Farm")
                        RageUI.ButtonWithStyle("Changer la position de récolte", nil, {RightLabel = ""}, true, function(_,_,s)
                            if s then
                                self.recoltepos = pCoords
                            end
                        end)

                        RageUI.ButtonWithStyle("Changer la position de transformation", nil, {RightLabel = ""}, true, function(_,_,s)
                            if s then
                                self.transformationpos = pCoords
                            end
                        end)

                        RageUI.ButtonWithStyle("Changer la position de vente", nil, {RightLabel = ""}, true, function(_,_,s)
                            if s then
                                self.ventepos = pCoords
                            end
                        end)

                        RageUI.Separator("~b~Véhicule")

                        for k,v in pairs(self.vehicles) do
                            RageUI.ButtonWithStyle("[~o~"..v.model.."~s~] - "..v.label.."",nil, {}, true, function(_,_,s)
                                if s then
                                    vehEditIndex = k
                                end
                            end, RMenu:Get(catmenu, 'job_edit_car'))
                        end

                        RageUI.Separator("~b~Grades")

                        for k,v in pairs(self.grades) do
                            RageUI.ButtonWithStyle(""..v.id.." - [~b~"..v.name.."~s~] - "..v.label.."",nil, {}, true, function(_,_,s)
                                if s then
                                    gradeEditIndex = k
                                end
                            end, RMenu:Get(catmenu, 'job_edit_grade'))
                        end

                        RageUI.ButtonWithStyle("~g~Validée la modification du job", nil, {RightLabel = ""}, true, function(_,_,s)
                            if s then
                                TriggerServerEvent(Config.prefixBuilder..":ModificationJob", JobIndex,self)
                            end
                        end)
                    end
                end,function()
                end)

                RageUI.IsVisible(RMenu:Get(catmenu, 'job_edit_car'), true, true, true, function()
                    local self = Jobs[JobIndex].vehicles[vehEditIndex]
                    RageUI.ButtonWithStyle("[~o~"..self.model.."~s~]",nil, {}, true, function(_,_,s)
                        if s then
                            local name = KeyboardImput("Model du véhicule")
                            if name ~= nil then
                                self.model = name
                            end
                        end
                    end)

                    RageUI.ButtonWithStyle("[~b~"..self.label.."~s~]",nil, {}, true, function(_,_,s)
                        if s then
                            local name = KeyboardImput("Model du véhicule")
                            if name ~= nil then
                                self.label = name
                            end
                        end
                    end)
                end,function()
                end)

                
                RageUI.IsVisible(RMenu:Get(catmenu, 'job_edit_grade'), true, true, true, function()
                    local self = Jobs[JobIndex].grades[gradeEditIndex]
                    RageUI.Separator("~o~"..self.id.."")
                    RageUI.Separator("~b~"..self.name.."")
                    RageUI.Separator("~g~"..self.label.."")

                    RageUI.List("→ Accès gestion", {"Oui","Non"}, TrueFalseIndex1, "~g~Entrez~s~ pour validez", {}, true, function(_, _, s, Index)
                        if s then
                            if TrueFalseIndex1 == 1 then
                                self.gestion = true
                            else
                                self.gestion = false
                            end
                        end
                        TrueFalseIndex1 = Index
                    end)

                    RageUI.List("→ Accès stock", {"Oui","Non"}, TrueFalseIndex2, "~g~Entrez~s~ pour validez", {}, true, function(_, _, s, Index)
                        if s then
                            if TrueFalseIndex2 == 1 then
                                self.stock = true
                            else
                                self.stock = false
                            end
                        end
                        TrueFalseIndex2 = Index
                    end)
                end,function()
                end)
                Wait(1)
            end
        end)
    end
end

RegisterNetEvent(Config.prefixBuilder.."openenu")
AddEventHandler(Config.prefixBuilder.."openenu", function()
    MenuOpenJob()
    RageUI.Visible(RMenu:Get(catmenu, 'main'), not RageUI.Visible(RMenu:Get(catmenu, 'main')))
end)