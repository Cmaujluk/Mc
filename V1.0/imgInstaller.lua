local shell = require("shell")
local fs = require("filesystem")
local prefix = "https://raw.githubusercontent.com/Cmaujluk/Mc/master/V1.0/mcImgs/"

local internet = require("internet")

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

local _itemsBD = {}

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
	shell.execute("wget -f "..prefix..product[id+1]..".png /home/"..product[id+1]..".png")
end

