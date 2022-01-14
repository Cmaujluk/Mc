local component = require("component")  
local internet = require("internet")
local interface = component.me_interface

local _itemsBD={}
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
		_itemsBD[tonumber(product[id+1])]={name=product[id+2], label=product[id+3], info=product[id+4], damage=tonumber(product[id+5]), price=RoundToPlaces(tonumber(product[id+6]),100), stackSize=tonumber(product[id+7]), itemId=product[id+8]}
	end
end

function GetItemsFromME()
	_itemsME=interface.getAvailableItems()
end

function ParseItemsToSale()
	i=1
	for index,item in pairs(_itemsBD) do
		for meIndex,meItem in pairs(_itemsME) do 
			if(item.name==meItem.fingerprint.id and item.damage==meItem.fingerprint.dmg) then
				_itemsToSale[i]	= {fingerprint=item.fingerprint, price = item.price, label = item.label, stackSize=64,count=10}
				i=i+1
			end
		end
	end
end

function shop.GetItemsToSale()
	return _itemsToSale
end

function shop.Init()
	GetItemsFromBD()
	GetItemsFromME()
	ParseItemsToSale()
end

return shop