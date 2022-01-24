local Tunnel = module("vrp","lib/Tunnel")
local Proxy = module("vrp","lib/Proxy")
local Tools = module("vrp","lib/Tools")
vRP = Proxy.getInterface("vRP")
vRPclient = Tunnel.getInterface("vRP")

local idgens = Tools.newIDGenerator()
local blips = {}
vServer = {}
Tunnel.bindInterface("clothes",vServer)

quantity_Items = location_Items.items_List.quantity_Items;
quantity_Money = location_Items.items_List.quantity_Money;
quantity_Tool  = math.random(quantity_Items[1][1], quantity_Items[1][2]);

items_Min = location_Items.items_List.items_Min[1];

tissue_Item = location_Items.items_List[1][1];
needle_Item = location_Items.items_List[2][1];
button_Item = location_Items.items_List[3][1]; 

function vServer.giveItem()
    
    for k,v in ipairs(location_Items.items_List) do

        
        local source  = source;
        local user_ID = vRP.getUserId(source);

        if vRP.getInventoryWeight(user_ID) + vRP.getItemWeight(v[1]) * quantity_Tool <= vRP.getInventoryMaxWeight(user_ID) then
            
            vRP.giveInventoryItem(user_ID, v[1], quantity_Tool);

            TriggerClientEvent('Notify',source,'sucesso', 'Você recebeu o que continha na caixa.');
            TriggerClientEvent("itensNotify",source,"usar","Pegou",""..v[1].."");

        else

            TriggerClientEvent('Notify',source,'negado', 'Você está sem espaço na mochila');

        end

    end

end

function vServer.checkPayment_Tissues(close_Menu) 

    local source  = source;
    local user_ID = vRP.getUserId(source);

    local quantity_Items = vRP.getInventoryItemAmount(user_ID, tissue_Item);
    
    if quantity_Items > items_Min then

        local money_Random = math.random(quantity_Money[1][1], quantity_Money[1][2]);

        vRP.tryGetInventoryItem(user_ID,tissue_Item, vRP.getInventoryItemAmount(user_ID, tissue_Item));
        vRP.giveBankMoney(user_ID, money_Random * quantity_Items);

        TriggerClientEvent('Notify',source,'sucesso', 'Você recebeu '.. money_Random * quantity_Items..' pelos tecidos');


    else

        TriggerClientEvent('Notify',source,'negado', 'Você não tem itens suficientes para vender. <br>A quantidade de item mínima para vender os <b>TECIDOS</b> é: <b>'..items_Min..'</b>');
        close_Menu = false;

    end

end

function vServer.checkPayment_Needle(close_Menu) 

    local source  = source;
    local user_ID = vRP.getUserId(source);

    local quantity_Items = vRP.getInventoryItemAmount(user_ID, needle_Item);
    
    if quantity_Items > items_Min then

        local money_Random = math.random(quantity_Money[1][1], quantity_Money[1][2]);

        vRP.tryGetInventoryItem(user_ID,needle_Item, vRP.getInventoryItemAmount(user_ID, needle_Item));
        vRP.giveBankMoney(user_ID, money_Random * quantity_Items);

        TriggerClientEvent('Notify',source,'sucesso', 'Você recebeu '.. money_Random*quantity_Items..' pelas agulhas');


    else

        TriggerClientEvent('Notify',source,'negado', 'Você não tem itens suficientes para vender. <br>A quantidade de item mínima para vender as <b>AGULHAS</b> é: <b>'..items_Min..'</b>');
        close_Menu = false;

    end

end

function vServer.checkPayment_Buttons(close_Menu) 

    local source  = source;
    local user_ID = vRP.getUserId(source);

    local quantity_Items = vRP.getInventoryItemAmount(user_ID, button_Item);
    
    if quantity_Items > items_Min then

        local money_Random = math.random(quantity_Money[1][1], quantity_Money[1][2]);

        vRP.tryGetInventoryItem(user_ID, button_Item, vRP.getInventoryItemAmount(user_ID, button_Item));
        vRP.giveBankMoney(user_ID, money_Random * quantity_Items);

        TriggerClientEvent('Notify',source,'sucesso', 'Você recebeu '.. money_Random*quantity_Items..' pelos botões');


    else

        TriggerClientEvent('Notify',source,'negado', 'Você não tem itens suficientes para vender. <br>A quantidade de item mínima para vender os <b>BOTÕES</b> é: <b>'..items_Min..'</b>');
        close_Menu = false;

    end

end


