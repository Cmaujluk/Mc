local component = require("component")  
local internet = require("internet")
local interface = component.proxy("4396b0e4-7aab-4259-bb72-1cfd8384c59a")
local chestToSale = component.chest
local chest = component.crystal

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
	local items = chestToSale.getAllStacks()
	local i=1
	for _,item in pairs(items) do
		_itemsSaleData[i]=item.all()
		i=i+1
	end

	for i=1,#_itemsSaleData do
		if _itemsSaleData[i].id=="customnpcs:npcMoney" then _itemsSaleData[i].label="Деньги" _itemsSaleData[i].price=0.13 end
		if _itemsSaleData[i].id=="mcs_addons:item.cashback_item_2" then _itemsSaleData[i].label="Морская пыль" _itemsSaleData[i].price=1 end
		if _itemsSaleData[i].id=="customnpcs:npcAmethyst" then _itemsSaleData[i].label="Аметис" _itemsSaleData[i].price=100 end
		if _itemsSaleData[i].id=="customnpcs:npcRuby" then _itemsSaleData[i].label="Рубин" _itemsSaleData[i].price=20 end
		if _itemsSaleData[i].id=="customnpcs:npcSaphire" then _itemsSaleData[i].label="Сапфир" _itemsSaleData[i].price=2 end
		if _itemsSaleData[i].id=="OpenComputers:print" then _itemsSaleData[i].label="1 эм (покупается в сундуке слева) " _itemsSaleData[i].price=1 end
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
				_itemsToSale[i]	= {fingerprint=meItem.fingerprint, price = item.price, label = item.label, stackSize=64,count=10, localId=item.localId}
				i=i+1
			end
		end
	end
end

function shop.GetItemSellCount(itemToCheck)
	GetSellItemsData()
	local items = chest.getAllStacks()
	local count=0
	for _,item in pairs(items) do
		itemData=item.all()
		if itemToCheck.id==itemData.id and itemToCheck.dmg==itemData.dmg  and itemToCheck.nbt_hash == itemData.nbt_hash then
			count=count+itemData.qty
		end
	end
	return count
end

function shop.BuyItem(itemToSell)
	local items = chest.getAllStacks()
	local count=0
	for k,item in pairs(items) do
		itemData=item.all()
		if itemToSell.id==itemData.id and itemToSell.dmg==itemData.dmg  and itemToSell.nbt_hash == itemData.nbt_hash then
			chest.pushItem(1,k)
			count=count+itemData.qty
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
	local count = interface.getItemDetail(fingerprint).all().qty
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

function shop.Init()
	GetItemsFromBD()
	GetItemsFromME()
	ParseItemsToSale()
	GetSellItemsData()
end

return shop