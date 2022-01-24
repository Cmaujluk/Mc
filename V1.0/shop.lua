local component = require("component")  
local internet = require("internet")
local bd = component.database
local chest = component.crystal
local interface

local _itemsBD={}
local _itemsSaleData={}
local _itemsME={}
local _itemsToSale={}
local shop={}

function parseString (inputString)
  local result = {}
  for value in string.gmatch(inputString, '".-":".-"') do
	table.insert(result, (string.gsub(value, '"(.-)":"(.-)"', "%2")))
  end
  return result
end

function RoundToPlaces(value, divisor)
	return (value * divisor) / divisor
end

function GetItemsFromBD()
	getData = internet.request("https://www.toolbexgames.com/mc_getshopdata.php?")
	local result=""
	local product = {}
	for chunk in getData do
			result = result..chunk
	end
	product = parseString(result)
	result = {}
	for i=1,#product/8 do
		local id = (i-1)*8
		_itemsBD[tonumber(product[id+1])]={name=product[id+2], label=product[id+3], info=product[id+4], damage=tonumber(product[id+5]), price=RoundToPlaces(tonumber(product[id+6]),100), stackSize=tonumber(product[id+7]), itemId=product[id+8], localId=tonumber(product[id+1])}
	end
end

function GetSellItemsData()
	for i=1,6 do
		local item = bd.get(i)
		_itemsSaleData[i]= {id = item.name, dmg = item.damage}
	end

	for i=1,#_itemsSaleData do
		if _itemsSaleData[i].id=="OpenComputers:print" then _itemsSaleData[i].label="1 эм (покупается в сундуке слева)" _itemsSaleData[i].price=1 _itemsSaleData[i].img = "sell_1"end
		if _itemsSaleData[i].id=="customnpcs:npcMoney" then _itemsSaleData[i].label="Деньги" _itemsSaleData[i].price=0.13 _itemsSaleData[i].img = "sell_3"  end
		if _itemsSaleData[i].id=="mcs_addons:item.cashback_item_2" then _itemsSaleData[i].label="Морская пыль" _itemsSaleData[i].price=1 _itemsSaleData[i].img = "sell_2"    end
		if _itemsSaleData[i].id=="customnpcs:npcAmethyst" then _itemsSaleData[i].label="Аметис" _itemsSaleData[i].price=100 _itemsSaleData[i].img = "sell_6"   end
		if _itemsSaleData[i].id=="customnpcs:npcRuby" then _itemsSaleData[i].label="Рубин" _itemsSaleData[i].price=20 _itemsSaleData[i].img = "sell_5"   end
		if _itemsSaleData[i].id=="customnpcs:npcSaphire" then _itemsSaleData[i].label="Сапфир" _itemsSaleData[i].price=2 _itemsSaleData[i].img = "sell_4"    end
	end



	return _itemsSaleData
end

function GetItemsFromME()
	_itemsME=interface.getAvailableItems()
end



function ParseItemsToSale()
	i=1
	for index,item in pairs(_itemsBD) do
		for meIndex,meItem in pairs(_itemsME) do 
			if(item.name==meItem.fingerprint.id and item.damage==meItem.fingerprint.dmg) then
				_itemsToSale[i]	= {fingerprint=meItem.fingerprint, price = item.price, label = item.label, stackSize=64, localId=item.localId}
				i=i+1
			end
		end
	end
end

function shop.GetItemSellCount(itemToCheck)
	local items = chest.getAllStacks()
	local count=0
	for _,item in pairs(items) do
		itemData=item.all()
		local f=true
		if itemToCheck.id==itemData.id and itemToCheck.dmg==itemData.dmg then
			if tostring(itemData.nbt_hash)~="nil" then
				if tostring(itemData.nbt_hash)~="ee301c7839c41b237451f9fbbb6b237b" and tostring(itemData.nbt_hash)~="d3cd7ef0c447e90b294fe32b35d6b235" then
					f=false
				end
			end

			if f then
				count=count+itemData.qty
			end
		end
	end
	return count
end

function shop.BuyItem(itemToSell)
	local items = chest.getAllStacks()
	local count=0
	for k,item in pairs(items) do
		itemData=item.all()
		local f=true
		if itemToSell.id==itemData.id and itemToSell.dmg==itemData.dmg then
			if tostring(itemData.nbt_hash)~="nil" then
				if tostring(itemData.nbt_hash)~="ee301c7839c41b237451f9fbbb6b237b" and tostring(itemData.nbt_hash)~="d3cd7ef0c447e90b294fe32b35d6b235" then
					f=false
				end
			end

			if f then
				chest.pushItem(1,k)
				count=count+itemData.qty
			end
		end
	end
	return count
end

function shop.GetItemDetails(fingerprint)
	return interface.getItemDetail(fingerprint).all()
end

function shop.GetItemCount(fingerprint)
	local data = interface.getItemDetail(fingerprint)
	if data == nil then return 0 end
	local count = data.all().qty
	if count ==nil then count = 0 end
	return count
end

function shop.GetItems(item,count)
	local resourchesToGive=count
	while resourchesToGive>0 do
		if resourchesToGive>item.stackSize then 
			interface.exportItem(item.fingerprint,2,item.stackSize)
			resourchesToGive=resourchesToGive-item.stackSize
		else
			interface.exportItem(item.fingerprint,2,resourchesToGive)
			resourchesToGive=0
		end

	end
end

function shop.GetItemsToSale()
	return _itemsToSale
end

function shop.GetItemsSaleData()
	return _itemsSaleData
end

function shop.Init(address)
	interface = component.proxy(address)
	GetItemsFromBD()
	GetItemsFromME()
	ParseItemsToSale()
	GetSellItemsData()
end

return shop