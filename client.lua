local Tunnel = module("vrp","lib/Tunnel");
local Proxy  = module("vrp","lib/Proxy");

vRP     = Proxy.getInterface("vRP");
vServer = Tunnel.getInterface("clothes");

-- VARIABLES

quantity_Box = 0;
index        = 0;
pos_Location = 1;

open_Doors    = false;
closed_Doors  = true;
default_Doors = true;

protection_Door = true; 
loadTruck_Stage = true;

route_Generator = math.random(1,#location_Items.routes_Locations);

player_Ped = PlayerPedId();

local reduce_Loop;

local verify_Door;
local verify_Stage;
local verify_Distance_Spawn;
local verify_Distance_ToCoords;
local verify_Reload;

local time_Sleep;

local deliver_All; 
local reload_Truck;
local truck_ClosedDoors;

local player_onNui;
local player_Distance;
local player_Distance_Sell;
local player_Working;
local player_Carrying;
local player_onRoute;
local player_onReload;

local ped_Distance;
local active_Ped; 

local posX, posY, posZ;
local sellX, sellY, sellZ;

local veh_posX, veh_posY, veh_posZ;

local npc_posX, npc_posY, npc_posZ;
local to_X, to_Y, to_Z;

-- ARRAY VARIABLE

drawMarker_Locations = location_Items.drawMarker_Locations;

spawnCar_Locations = location_Items.spawnCar_Locations;
model_Vehicle      = location_Items.spawnCar_Locations['car_Model'][1]

pickUpBox_Locations  = location_Items.pickUpBox_Locations;
prop_Type            = location_Items.pickUpBox_Locations['Prop_Type'][1];
animation_pickUpBox  = location_Items.pickUpBox_Locations['Animation'][1][1];
animation_Bell       = location_Items.pickUpBox_Locations['Animation'][2][1];
animation_catchItems = location_Items.pickUpBox_Locations['Animation'][3][1];

dict, anim, prop, flag, hand  = table.unpack(location_Items.pickUpBox_Locations['Moviment'][1]);

props_Locations = location_Items.props_Locations;
types_Props     = location_Items.types_Props;

routes_Locations = location_Items.routes_Locations;
bell_Locations   = location_Items.routes_Locations.bell_Locations;

npc_Model = location_Items.routes_Locations.npc_Model[1];

npc_Employee_SpawnCoords = location_Items.routes_Locations.npc_Employee_SpawnCoords; 
npc_Employee_ToCoords    = location_Items.routes_Locations.npc_Employee_ToCoords;
npc_Employee_Heading     = location_Items.routes_Locations.npc_Employee_ToCoords.npc_Employee_Heading;

npc_posX, npc_posY, npc_posZ = npc_Employee_SpawnCoords[route_Generator]['x'], npc_Employee_SpawnCoords[route_Generator]['y'], npc_Employee_SpawnCoords[route_Generator]['z'];
to_X, to_Y, to_Z = npc_Employee_ToCoords[route_Generator]['x'], npc_Employee_ToCoords[route_Generator]['y'], npc_Employee_ToCoords[route_Generator]['z'];

ware_X, ware_Y, ware_Z = location_Items.reload_Warehouse[route_Generator]['x'], location_Items.reload_Warehouse[route_Generator]['y'], location_Items.reload_Warehouse[route_Generator]['z'];
draw_X, draw_Y, draw_Z = location_Items.reload_Warehouse.drawMarker_Warehouse[route_Generator]['x'], location_Items.reload_Warehouse.drawMarker_Warehouse[route_Generator]['y'], location_Items.reload_Warehouse.drawMarker_Warehouse[route_Generator]['z'];

CreateThread(function()

    for k,v in pairs(location_Items.blips_List) do
    
        vRP._addBlip(v[1],v[2],v[3],v[4],v[5],v[6],v[7],v[8]);
    
    end
    
    repeat  
    
        time_Sleep = 1000;
        posX, posY, posZ    = drawMarker_Locations[1]['x'], drawMarker_Locations[1]['y'], drawMarker_Locations[1]['z'];
        sellX, sellY, sellZ = drawMarker_Locations[2]['x'], drawMarker_Locations[2]['y'], drawMarker_Locations[2]['z']

        player_Distance_Sell = GetDistanceBetweenCoords(GetEntityCoords(player_Ped), sellX, sellY, sellZ, true);
        player_Distance      = GetDistanceBetweenCoords(GetEntityCoords(player_Ped), posX, posY, posZ, true);

        if not player_Working and player_Distance <= 16 then

            time_Sleep = 1;

            DrawMarker(23, posX, posY, posZ-0.96, 0, 0, 0, 0, 0, 0, 1.5, 1.5, 1.5,0,250,154, 180, 0, 0, 0, 0);

            DrawText3D(posX, posY, posZ, "Pressione [~g~E~w~] para entrar em ~g~SERVIÇO~w~.");

            if IsControlJustPressed(0, 46) and player_Distance <= 1 then 
                
                player_Working = true ;

                TriggerEvent('leftService');
                verifyVehicle(createVehicle);
                Fade(1000);
                loadTruck(animation_pickUpBox, dict, anim, prop, flag, hand);
                
            end

        elseif player_Distance_Sell <= 16 then

            time_Sleep = 1;

            DrawMarker(23, sellX, sellY, sellZ-0.96, 0, 0, 0, 0, 0, 0, 1.5, 1.5, 1.5,0,250,154, 180, 0, 0, 0, 0);
            DrawText3D(sellX, sellY, sellZ, "Pressione [~g~E~w~] para entrar no painel de vendas.");

            if IsControlJustPressed(0, 46) and player_Distance_Sell <= 1 and not player_onNui then

                player_onNui = true;

                if player_onNui then

                    SetNuiFocus(true, true);

                    SendNUIMessage({

                        isOpen = true; 

                    });

                end

            end

        end

        Wait(time_Sleep);

    until false

end)

function loadTruck(animation, dict, anim, prop, flag, hand)

    while player_Working do

        time_Sleep = 1000;

        veh_posX, veh_posY, veh_posZ = table.unpack(GetOffsetFromEntityInWorldCoords(vehicle_isLoading,0.0, -1.0, 1.0)); 

        player_Distance = GetDistanceBetweenCoords(GetEntityCoords(player_Ped), veh_posX, veh_posY, veh_posZ, true);

        if not IsPedInAnyVehicle(player_Ped) and player_Distance <= 10 and default_Doors then

            time_Sleep = 1;
            DrawText3D(veh_posX, veh_posY, veh_posZ,"Pressione [~g~E~w~] para abrir as ~g~PORTAS~w~.");

            if IsControlJustPressed(0,46) and player_Distance <= 6 then

                open_Doors    = true;
                closed_Doors  = false;
                default_Doors = false;
                SetVehicleDoorOpen(vehicle_isLoading, 2);
                SetVehicleDoorOpen(vehicle_isLoading, 3);

            end

        end

        posX, posY, posZ = pickUpBox_Locations['x'], pickUpBox_Locations['y'], pickUpBox_Locations['z'];
        player_Distance = GetDistanceBetweenCoords(GetEntityCoords(player_Ped), posX, posY, posZ, true);

        if open_Doors and player_Distance <= 200 and not IsPedInAnyVehicle(ped) then

            time_Sleep = 1
            DrawMarker(21,posX, posY, posZ, 0, 0, 0, 0, 0, 0, 0.90, 0.90, 0.90,0,250,154, 180, 1, 0, 0, 0);
            drawTxt('Pegue as caixas e coloque dentro do ~g~CAMINHÃO~w~\n'.."Você colocou ".. quantity_Box .." de ~g~10 CAIXAS!",8,0.5,0.92,0.35,255,255,255,255);
            
            if IsControlJustPressed(0,46) and not player_Carrying and player_Distance <= 0.8 then
                
                vRP.playAnim(false,{animation},false);
                FreezeEntityPosition(player_Ped, true);

                SetTimeout(3000,function()

                    player_Carrying = true;

                    FreezeEntityPosition(player_Ped, false);
                    ResetPedMovementClipset(player_Ped,0);
                    SetRunSprintMultiplierForPlayer(PlayerId(),1.0);
                    
                    vRP.CarregarObjeto(dict, anim, prop, flag, hand);

                end)
                
            end
            
        end
        
        player_Distance = GetDistanceBetweenCoords(GetEntityCoords(player_Ped), veh_posX, veh_posY, veh_posZ, true);

        if player_Distance <= 12 and open_Doors and player_Carrying and loadTruck_Stage then

            DrawText3D(veh_posX, veh_posY, veh_posZ, "Pressione [~g~E~w~] para colocar as ~g~CAIXAS~w~.");
            posX, posY, posZ = props_Locations[index]['x'], props_Locations[index]['y'], props_Locations[index]['z'];

            for i = 0, 10 do 

                if IsControlJustPressed(0, 46) and player_Distance <= 5 and quantity_Box == i and player_Carrying then
                    
                    types_Props[i] = CreateObject(GetHashKey(prop_Type), posX, posY, posZ-0.99, true, true ,true);
                    
                    attach_Prop    = location_Items.types_Props.attach_Prop[index];
                    propPos_1, propPos_2, propPos_3, propPos_4, propPos_5, propPos_6, propPos_7 = table.unpack(attach_Prop);
                    
                    AttachEntityToEntity(types_Props[index],vehicle_isLoading, propPos_1, propPos_2, propPos_3, propPos_4, propPos_5, propPos_6, propPos_7,false,false,true,false,2,true);
                    FreezeEntityPosition(types_Props[index],true);
                    
                    vRP.DeletarObjeto();
                    
                    player_Carrying = false; 
                    quantity_Box += 1;
                    index += 1;
                    
                end
                
            end
            
        end
        
        if quantity_Box == 1 and player_Distance <= 12.0 and not player_Carrying and open_Doors and protection_Door == true then

            open_Doors  = false;
            verify_Door = nil;
            loadTruck_Stage = false;

            while not verify_Door do

                DrawText3D(veh_posX, veh_posY, veh_posZ, "Pressione [~g~F~w~] para fechar as ~g~PORTAS~w~.");
        
                if IsControlJustPressed(0, 23) and player_Distance <= 6.5 then
        
                    SetVehicleDoorShut(vehicle_isLoading, 2);
                    SetVehicleDoorShut(vehicle_isLoading, 3);
        
                    closed_Doors = true;
                    verify_Door  = true;

                    protection_Door = false; 

                    onRoutes();

                end
        
                Wait(1)
        
            end

        end

        Wait(time_Sleep)
    end

end


function onRoutes() 

    posX, posY, posZ = routes_Locations[route_Generator]['x'], routes_Locations[route_Generator]['y'], routes_Locations[route_Generator]['z'];
    
    createBlip(posX, posY, posZ);

    player_onRoutes = false;
    
    while not player_onRoutes do 
        
        posX, posY, posZ = routes_Locations[route_Generator]['x'], routes_Locations[route_Generator]['y'], routes_Locations[route_Generator]['z'];
        
        player_Distance  = GetDistanceBetweenCoords(GetEntityCoords(player_Ped), posX, posY, posZ, true);

        if closed_Doors then

            if not IsPedInAnyVehicle(player_Ped) and GetVehiclePedIsIn(player_Ped, false) ~= vehicle_isLoading then

                drawTxt("Entre dentro do ~g~CAMINHÃO~w~ e siga as próxima instruções",8,0.5,0.92,0.35,255,255,255,255);

            elseif GetVehiclePedIsIn(player_Ped, false) ~= vehicle_isLoading then

                drawTxt("Apenas será possível fazer a entrega dentro do ~g~CAMINHÃO~w~ .",8,0.5,0.92,0.35,255,255,255,255);

            else

                drawTxt("Vá para a localização marcada no ~g~GPS~w~ e saia do carro ao chegar na localização.",8,0.5,0.92,0.35,255,255,255,255);

            end
            
            if player_Distance <= 9 and not IsPedInAnyVehicle(ped) then
                
                RemoveBlip(blips);
                callingPed(animation_Bell)
                player_onRoutes = true;

            end

        end
        
        Wait(1);
    end

end

function callingPed(animation)

    active_Ped = false;

    while not active_Ped do 
        
        posX, posY, posZ = bell_Locations[route_Generator]['x'], bell_Locations[route_Generator]['y'], bell_Locations[route_Generator]['z'];

        time_Sleep = 1000
        
        player_Distance = GetDistanceBetweenCoords(GetEntityCoords(player_Ped), posX, posY, posZ, true);
        
        if player_Distance <= 20 and not player_onRoutes and closed_Doors then

            time_Sleep = 1;

            DrawText3D(posX, posY, posZ, "Pressione [~g~E~w~] para chamar o ~g~FUNCIONÁRIO~w~.");
            DrawMarker(23, posX, posY, posZ-0.96, 0, 0, 0, 0, 0, 0, 1.5, 1.5, 1.5,0,250,154, 180, 0, 0, 0, 0);

            if IsControlJustPressed(0, 46) and player_Distance <= 2.5 then

                vRP.playAnim(true, {animation}, false);

                active_Ped = true; 
                
                SetTimeout(2000, function()
                    
                    createPed(npc_Model, npc_posX, npc_posY, npc_posZ, to_X, to_Y, to_Z);
                    openDoors(); 
                    
                end)

            end

        end

        Wait(time_Sleep)
    end

end

function openDoors() 

    open_Doors = false

    while not open_Doors do

        time_Sleep = 1000;

        posX, posY, posZ = table.unpack(GetOffsetFromEntityInWorldCoords(vehicle_isLoading,0.0, -1.0, 1.0));
        player_Distance  = GetDistanceBetweenCoords(GetEntityCoords(player_Ped), posX, posY, posZ);

        if closed_Doors and player_Distance <= 15 then

            time_Sleep = 1;

            DrawText3D(posX, posY, posZ, "Pressione [~g~E~w~] abrir as portas do caminhão");
            drawTxt("Abra as portas do ~g~CAMINHÃO~w~",8,0.5,0.92,0.35,255,255,255,255);

            if IsControlJustPressed(0,46) and player_Distance <= 5 and not open_Doors then

                SetVehicleDoorOpen(vehicle_isLoading, 2);
                SetVehicleDoorOpen(vehicle_isLoading, 3);
                
                open_Doors   = true;
                closed_Doors = false;

                SetTimeout(1000, function()

                    deliverToPed();

                end)
                
            end

        end

        Wait(time_Sleep)
    end

end

function deliverToPed()

    deliver_All = false;

    while not deliver_All do 

        posX, posY, posZ             = table.unpack(GetEntityCoords(npc_Employee));
        veh_posX, veh_posY, veh_posZ = table.unpack(GetOffsetFromEntityInWorldCoords(vehicle_isLoading,0.0, -1.0, 1.0));

        ped_Distance    = GetDistanceBetweenCoords(GetEntityCoords(player_Ped), posX, posY, posZ);
        player_Distance = GetDistanceBetweenCoords(GetEntityCoords(player_Ped), veh_posX, veh_posY, veh_posZ);

        verify_Distance_ToCoords = GetDistanceBetweenCoords(GetEntityCoords(npc_Employee), to_X, to_Y, to_Z);
        verify_Distance_Spawn    = GetDistanceBetweenCoords(GetEntityCoords(npc_Employee), npc_posX, npc_posY, npc_posZ);

        if quantity_Box ~= 0 then  

            drawTxt("Entregue todas as caixas para o ~g~FUNCIONÁRIO~w~",8,0.5,0.92,0.35,255,255,255,255)
        
        else

            drawTxt("Pegue o que sobrou com o ~g~FUNCIONÁRIO~w~",8,0.5,0.92,0.35,255,255,255,255);

        end

        if player_Distance <= 8 and not player_Carrying and quantity_Box ~= 0 then
            
            DrawText3D(veh_posX, veh_posY, veh_posZ, "Pressione [~g~E~w~] para retirar uma caixa.");
            
            for i = 0, 10 do
 
                if IsControlJustPressed(0, 46) and player_Distance <= 5 and quantity_Box == i then

                    reduce_Loop = i - 1

                    if DoesEntityExist(types_Props[reduce_Loop]) then

                        player_Carrying = true;

                        FreezeEntityPosition(player_Ped, false);
                        ResetPedMovementClipset(player_Ped,0);
                        SetRunSprintMultiplierForPlayer(PlayerId(),1.0);

                        vRP.CarregarObjeto(dict, anim, prop, flag, hand);
                            
                        TriggerServerEvent("trydeleteobj",ObjToNet(types_Props[reduce_Loop]));
                        DetachEntity(types_Props[reduce_Loop], false, false);

                    end

                end
    
            end

        end

        if ped_Distance <= 15 and player_Carrying and verify_Distance_ToCoords <= 3 and not verify_Stage then

            DrawText3D(posX, posY, posZ, "Pressione [~g~E~w~] para me entregar as caixas");

            if IsControlJustPressed(0,46) and ped_Distance <= 2.5 then

                playAnim(npc_Employee, dict, anim, prop, flag, hand);
                TaskPlayAnim(npc_Employee, dict, anim, 3.0, 3.0, 10000, 1, 0.0,0.0,0.0);

                TaskGoToCoordAnyMeans(npc_Employee, npc_posX, npc_posY, npc_posZ,4.0,0,0,786603, 0xbf800000);
                
                vRP.DeletarObjeto();

                player_Carrying = false;
                verify_Stage = true;

            end

        end

        if verify_Stage and verify_Distance_Spawn <= 2 then

            TaskGoToCoordAnyMeans(npc_Employee, to_X, to_Y, to_Z, 4.0,0,0,786603, 0xbf800000);
            removeObject(npc_Employee);
            verify_Stage = false;
            quantity_Box -= 1;                

        end

        if quantity_Box == 0 and verify_Distance_ToCoords <= 2.5 then

            DrawText3D(posX, posY, posZ, "Pressione [~g~E~w~] para pegar o que sobrou das caixas");

            if IsControlJustPressed(0,46) and ped_Distance <= 2.5 then 

                TaskPlayAnim(npc_Employee, animation_catchItems[1],animation_catchItems[2], 3.0, 3.0, 2000, 1, 0.0,0.0,0.0);
                vRP.playAnim(true,{animation_catchItems},false);
                deliver_All = true;

                SetTimeout(1000, function()

                    SetEntityAsNoLongerNeeded(npc_Employee);
                    vServer.giveItem();

                    closedDoors();
                
                end)

            end

        end
        
        Wait(1);

    end

end

function closedDoors()

    open_Doors  = false;
    truck_ClosedDoors = false;

    while not truck_ClosedDoors do

        player_Distance = GetDistanceBetweenCoords(GetEntityCoords(player_Ped), veh_posX, veh_posY, veh_posZ, true);

        drawTxt("Fecha as portas ~g~CAMINHÃO~w~",8,0.5,0.92,0.35,255,255,255,255);
        DrawText3D(veh_posX, veh_posY, veh_posZ, "Pressione [~g~F~w~] para fechar as ~g~PORTAS~w~.");

        if IsControlJustPressed(0, 23) and player_Distance <= 6.5 then

            SetVehicleDoorShut(vehicle_isLoading, 2);
            SetVehicleDoorShut(vehicle_isLoading, 3);

            closed_Doors = true;
            truck_ClosedDoors = true;
            generateRoutes();

            
        end

        Wait(1)

    end

end

function generateRoutes()

    player_onReload = false;

    createBlip(ware_X, ware_Y, ware_Z);
    
    while not player_onReload do 
        
        player_Distance  = GetDistanceBetweenCoords(GetEntityCoords(player_Ped), ware_X, ware_Y, ware_Z, true);

        if closed_Doors then

            if not IsPedInAnyVehicle(player_Ped) and GetVehiclePedIsIn(player_Ped, false) ~= vehicle_isLoading then

                drawTxt("Entre dentro do ~g~CAMINHÃO~w~ e siga as próxima instruções",8,0.5,0.92,0.35,255,255,255,255);

            elseif GetVehiclePedIsIn(player_Ped, false) ~= vehicle_isLoading then

                drawTxt("Apenas será possível fazer a entrega dentro do ~g~CAMINHÃO~w~ .",8,0.5,0.92,0.35,255,255,255,255);

            else

                drawTxt("Vá para a localização marcada no ~g~GPS~w~ e saia do carro ao chegar na localização.",8,0.5,0.92,0.35,255,255,255,255);

            end
            
            
        end

        if player_Distance <= 11 and not IsPedInAnyVehicle(ped) then
            
            RemoveBlip(blips);
            player_onReload = true;
            verify_Reload   = false;

        end

        Wait(1);

    end

    while not verify_Reload do

        posX, posY, posZ = table.unpack(GetOffsetFromEntityInWorldCoords(vehicle_isLoading,0.0, -1.0, 1.0));
        player_Distance  = GetDistanceBetweenCoords(GetEntityCoords(player_Ped), posX, posY, posZ);

        drawTxt("Abra as portas do ~g~CAMINHÃO~w~",8,0.5,0.92,0.35,255,255,255,255);
        
        if closed_Doors and player_Distance <= 20 and not IsPedInAnyVehicle(player_Ped) then
            
            DrawText3D(posX, posY, posZ, "Pressione [~g~E~w~] abrir as portas do caminhão");

            if IsControlJustPressed(0,46) and player_Distance <= 5 and not open_Doors then

                SetVehicleDoorOpen(vehicle_isLoading, 2);
                SetVehicleDoorOpen(vehicle_isLoading, 3);
                
                open_Doors   = true;
                closed_Doors = false;
                verify_Reload = true;

                reload_Truck = false;
                reloadTruck(animation_pickUpBox, dict, anim, prop, flag, hand);

            end

        end

        Wait(1)
    end

end

function reloadTruck(animation, dict, anim, prop, flag, hand)

    index = 0;

    while not reload_Truck do

        time_Sleep = 1000

        player_Distance  = GetDistanceBetweenCoords(GetEntityCoords(player_Ped), draw_X, draw_Y, draw_Z);
        
        if player_Distance <= 30 and open_Doors then

            time_Sleep = 1;

            DrawMarker(23, draw_X, draw_Y, draw_Z-0.96, 0, 0, 0, 0, 0, 0, 1.5, 1.5, 1.5,0,250,154, 180, 0, 0, 0, 0);
            DrawText3D(draw_X, draw_Y, draw_Z, "Pressione [~g~E~w~] para pegar as caixas.");

            if IsControlJustPressed(0, 46) and player_Distance <= 0.5 and not player_Carrying then

                vRP.playAnim(false,{animation},false);
                FreezeEntityPosition(player_Ped, true);

                SetTimeout(3000,function()

                    player_Carrying = true;

                    FreezeEntityPosition(player_Ped, false);
                    ResetPedMovementClipset(player_Ped,0);
                    SetRunSprintMultiplierForPlayer(PlayerId(),1.0);
                    
                    vRP.CarregarObjeto(dict, anim, prop, flag, hand);

                end)

            end

        end

        player_Distance = GetDistanceBetweenCoords(GetEntityCoords(player_Ped), veh_posX, veh_posY, veh_posZ, true);

        if player_Distance <= 20 and open_Doors then

            drawTxt('Pegue as caixas e coloque dentro do ~g~CAMINHÃO~w~\n'.."Você colocou ".. quantity_Box .." de ~g~10 CAIXAS!",8,0.5,0.92,0.35,255,255,255,255);

        end   
        
        
        if player_Distance <= 12 and open_Doors and player_Carrying then
            
            DrawText3D(veh_posX, veh_posY, veh_posZ, "Pressione [~g~E~w~] para colocar as ~g~CAIXAS~w~.");

            posX, posY, posZ = props_Locations[index]['x'], props_Locations[index]['y'], props_Locations[index]['z'];

            for i = 0, 10 do 

                if IsControlJustPressed(0, 46) and player_Distance <= 5 and quantity_Box == i and player_Carrying then
                    
                    types_Props[i] = CreateObject(GetHashKey(prop_Type), posX, posY, posZ-0.99, true, true ,true);
                    
                    attach_Prop    = location_Items.types_Props.attach_Prop[index];
                    propPos_1, propPos_2, propPos_3, propPos_4, propPos_5, propPos_6, propPos_7 = table.unpack(attach_Prop);
                    
                    AttachEntityToEntity(types_Props[index],vehicle_isLoading, propPos_1, propPos_2, propPos_3, propPos_4, propPos_5, propPos_6, propPos_7,false,false,true,false,2,true);
                    FreezeEntityPosition(types_Props[index],true);
                    
                    vRP.DeletarObjeto();
                    
                    player_Carrying = false; 
                    quantity_Box += 1;
                    index += 1;
                    
                end
    
            end

        end

        if quantity_Box == 1 and player_Distance <= 20 and not player_Carrying and open_Doors then

            open_Doors = false;
            reload_Truck = true;

            verify_Door = false;

            while not verify_Door do

                DrawText3D(veh_posX, veh_posY, veh_posZ, "Pressione [~g~F~w~] para fechar as ~g~PORTAS~w~.");

                if IsControlJustPressed(0, 23) and player_Distance <= 6.5 then

                    SetVehicleDoorShut(vehicle_isLoading, 2);
                    SetVehicleDoorShut(vehicle_isLoading, 3);

                    route_Generator = math.random(1,#location_Items.routes_Locations);

                    npc_posX, npc_posY, npc_posZ = npc_Employee_SpawnCoords[route_Generator]['x'], npc_Employee_SpawnCoords[route_Generator]['y'], npc_Employee_SpawnCoords[route_Generator]['z'];
                    to_X, to_Y, to_Z = npc_Employee_ToCoords[route_Generator]['x'], npc_Employee_ToCoords[route_Generator]['y'], npc_Employee_ToCoords[route_Generator]['z'];

                    ware_X, ware_Y, ware_Z = location_Items.reload_Warehouse[route_Generator]['x'], location_Items.reload_Warehouse[route_Generator]['y'], location_Items.reload_Warehouse[route_Generator]['z'];
                    draw_X, draw_Y, draw_Z = location_Items.reload_Warehouse.drawMarker_Warehouse[route_Generator]['x'], location_Items.reload_Warehouse.drawMarker_Warehouse[route_Generator]['y'], location_Items.reload_Warehouse.drawMarker_Warehouse[route_Generator]['z'];

                    closed_Doors = true;
                    verify_Door_3  = true;

                    player_onRoutes = false;
                    active_Ped      = false;

                    deliver_All = false;

                    player_onReload = false;

                    onRoutes();
                    callingPed(animation_Bell);
                    
                end

                Wait(1)

            end

        end

        Wait(time_Sleep);
    end

end

function verifyVehicle(request) 
            
    while true do

        posX, posY, posZ = spawnCar_Locations[pos_Location]['x'], spawnCar_Locations[pos_Location]['y'], spawnCar_Locations[pos_Location]['z'];
        local check_VehiclePos = GetClosestVehicle(posX, posY, posZ,3.001,0,71);

        if DoesEntityExist(check_VehiclePos) then

            pos_Location += 1;
            
            if pos_Location > #spawnCar_Locations then

                pos_Location = -1;
                TriggerEvent("Notify","importante","Todas as vagas estão ocupadas no momento.",10000);
                break;

            end

        else

            break;

        end

        Wait(1)

    end

    if pos_Location ~= -1 then
        
        request(posX, posY, posZ, 270.05, model_Vehicle, player_Ped);

    else

        pos_Location = 1;
    
    end
end

function createVehicle(x,y,z,heading, model_Vehicle, ped)
    
    local loading_Car = GetHashKey(model_Vehicle);

    repeat 

        RequestModel(model_Vehicle);
        Wait(1);

    until HasModelLoaded(model_Vehicle)

    SetTimeout(1000, function()

        vehicle_isLoading = CreateVehicle(model_Vehicle, x, y, z, heading, true, true) --270.05
        SetVehicleIsStolen(vehicle_isLoading, false)
        SetVehicleOnGroundProperly(vehicle_isLoading)
        SetEntityInvincible(vehicle_isLoading, false)
        SetVehicleNumberPlateText(vehicle_isLoading,vRP.getRegistrationNumber())
        Citizen.InvokeNative(0xAD738C3085FE7E11,vehicle_isLoading,true,true)
        SetVehicleHasBeenOwnedByPlayer(vehicle_isLoading,true)
        SetVehicleDirtLevel(vehicle_isLoading,0.0)
        SetVehRadioStation(vehicle_isLoading,"OFF")
        SetVehicleEngineOn(GetVehiclePedIsIn(ped, false), true)
        SetModelAsNoLongerNeeded(loading_Car)
            
    end)
end

function createPed(model, spawnX, spawnY, spawnZ, x, y, z)

    modelRequest(model);
    npc_Employee = CreatePed(4, GetHashKey(model), spawnX, spawnY, spawnZ, true, false);
    SetEntityInvincible(npc_Employee,true);
    SetBlockingOfNonTemporaryEvents(npc_Employee,true);
    SetPedSeeingRange(npc_Employee,0.0);
    SetPedHearingRange(npc_Employee,0.0);
    SetPedFleeAttributes(npc_Employee,0,false);
    SetPedKeepTask(npc_Employee,true);
    SetEntityInvincible(npc_Employee,true);
    SetPedDiesWhenInjured(npc_Employee,false);
    SetPedCombatMovement(npc_Employee,false);
    SetPedDesiredHeading(npc_Employee, 179);
    TaskGoToCoordAnyMeans(npc_Employee,x,y,z,1.0,0,0,786603, 0xbf800000);

end

function playAnim(npc,dict,anim,prop,flag,hand,pos1,pos2,pos3,pos4,pos5,pos6)

    RequestModel(GetHashKey(prop))

    while not HasModelLoaded(GetHashKey(prop)) do

        Citizen.Wait(10)

    end

    if pos1 then

        local coords = GetOffsetFromEntityInWorldCoords(npc,0.0,0.0,-5.0);
        object = CreateObject(GetHashKey(prop),coords.x,coords.y,coords.z,true,true,true);

        SetEntityCollision(object,false,false);
        AttachEntityToEntity(object,npc,GetPedBoneIndex(npc,hand),pos1,pos2,pos3,pos4,pos5,pos6,true,true,false,true,1,true);

    else

        vRP.CarregarAnim(dict);
        TaskPlayAnim(npc,dict,anim,3-.0,3.0,-1,flag,0,0,0,0);

        local coords = GetOffsetFromEntityInWorldCoords(npc,0.0,0.0,-5.0);
        object = CreateObject(GetHashKey(prop),coords.x,coords.y,coords.z,true,true,true);

        SetEntityCollision(object,false,false);
        AttachEntityToEntity(object,npc,GetPedBoneIndex(npc,hand),0.0,0.0,0.0,0.0,0.0,0.0,false,false,false,false,2,true);

    end

    Citizen.InvokeNative(0xAD738C3085FE7E11,object,true,true);

end

function stopAnim(ped, upper)

    anims = {}

    if upper then

        ClearPedSecondaryTask(ped);

    else

        ClearPedTasks(ped);

    end

end

function removeObject(ped)

    stopAnim(ped, true)
    TriggerEvent("binoculos")

    if DoesEntityExist(object) then

        TriggerServerEvent("trydeleteobj",ObjToNet(object));
        object = nil;

    end

end

--NUI CALLBACK

RegisterNUICallback("close", function(data)

    if data.isOpen == "close" then

        player_onNui = false;
        
        SetNuiFocus(false, false);

    end

    if data.tissueClicked then

        vServer.checkPayment_Tissues(data.isOpen);

    end

    if data.needleClicked then

        vServer.checkPayment_Needle(data.isOpen) 

    end

    if data.buttonsClicked then
    
        vServer.checkPayment_Buttons(data.isOpen) 

    end

    if not isOpen then

        player_onNui = false;
        SetNuiFocus(false, false);

    end

end)

-- FUNCTIONS WIDESPREAD

function Fade(time)

    DoScreenFadeOut(1000)
    Wait(time)
    DoScreenFadeIn(1000)

end

function DrawText3D(x,y,z, text)

    local onScreen,_x,_y=World3dToScreen2d(x,y,z);
    local px,py,pz=table.unpack(GetGameplayCamCoords());

    SetTextScale(0.4, 0.4);
    SetTextFont(5);
    SetTextProportional(1);
    SetTextColour(255, 255, 255, 154);
    SetTextEntry("STRING");
    SetTextCentre(1);
    AddTextComponentString(text);

    DrawText(_x,_y);
    local factor = (string.len(text)) / 370;
    DrawRect(_x,_y+0.0125, 0.005+ factor, 0.03, 41, 11, 41, 68);

end

function drawTxt(text,font,x,y,scale,r,g,b,a)

	SetTextFont(font);
	SetTextScale(scale,scale);
	SetTextColour(r,g,b,a);
	SetTextOutline();
	SetTextCentre(1);
	SetTextEntry("STRING");
	AddTextComponentString(text);
	DrawText(x,y);

end


function createBlip(x,y,z)

	blips = AddBlipForCoord(x,y,z);
	SetBlipSprite(blips,1);
	SetBlipColour(blips,2);
	SetBlipScale(blips,0.4);
	SetBlipAsShortRange(blips,false);
    SetBlipRoute(blips,true);
	BeginTextCommandSetBlipName("STRING");
	AddTextComponentString("Destino");
	EndTextCommandSetBlipName(blips);

end

-- EVENTS
RegisterNetEvent('leftService')
AddEventHandler('leftService',function()

    while player_Working do

        if IsControlJustPressed(0,168) then

            quantity_Box = 0;
            index        = 0;
            pos_Location = 1;

            open_Doors    = true;
            closed_Doors  = true;
            default_Doors = true;

            reduce_Loop = nil;

            verify_Door   = true;

            verify_Stage  = nil;
            verify_Reload = true;

            verify_Distance_Spawn    = nil;
            verify_Distance_ToCoords = nil;

            time_Sleep = nil;

            deliver_All  = true; 
            reload_Truck = true;

            player_Working  = nil;
            player_Carrying = nil;
            player_onRoutes = true;
            player_onReload = true;

            ped_Distance = nil;
            active_Ped   = true; 

            protection_Door = true;
            loadTruck_Stage = true;

            truck_ClosedDoors = true;

            route_Generator = math.random(1,#location_Items.routes_Locations);

            RemoveBlip(blips);
            TriggerEvent('Notify','importante','Você saiu de serviço!');

            SetEntityAsNoLongerNeeded(npc_Employee);

            Fade(1000);

            if DoesEntityExist(vehicle_isLoading) then

                TriggerServerEvent("trydeleteveh",VehToNet(vehicle_isLoading));

            end

            for i = 0, 10 do

                if DoesEntityExist(types_Props[i]) then

                    DetachEntity(types_Props[i],false,false);
                    TriggerServerEvent("trydeleteobj",ObjToNet(types_Props[i]));

                end

            end

            return

        end
        Wait(5)
    end
    
end)