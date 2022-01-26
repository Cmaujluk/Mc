local _component = require("component")  
local _internet = require("internet")


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

function GetBDData()
	getData = _internet.request("https://www.toolbexgames.com/mc_gettradedata.php?")
	local result=""
	local product = {}
	
	for chunk in getData do
		result = result..chunk
	end

	product = parseString(result)

	result = {}
	for i=1,#product/8 do
		local id = (i-1)*8		
		_items[tonumber(product[id+1])]=
		{
			name=product[id+2],
			damage=tonumber(product[id+3]),
			label=product[id+4], 
			priceIn=RoundToPlaces(tonumber(product[id+5]),100), 
			priceOut=RoundToPlaces(tonumber(product[id+6]),100), --> фулл запил
			tradeIn=tonumber(product[id+7]), 
			tradeOut=tonumber(product[id+8]), 
		}
	end
	local j=1
	for i=1, #_items do
		if _items[i].tradeOut == 1 then
			_goodsForTrade[j]=i
			j=j+1
		end
	end

	for i=1, #_items do 
		if _items[i].tradeIn == 1 then
			_goodsForTradeIn[_items[i].name.._items[i].damage]=i
			
		end
		
		if _items[i].tradeOut == 1 then
			_goodsForTradeOut[_items[i].name.._items[i].damage]=i
		end
	end
	
	
	
	_startInfo =8 + ((math.ceil(#_goodsForTrade/5)-1)*2)
end