local component = require("component")
local gpu = component.gpu
local chest = component.crystal
local os = require("os")  
local interface_getter = nil

local changer={}

local _list = {
	{"minecraft:iron_ore",0,"Железная руда","minecraft:iron_ingot",0,"Железный слиток",2,1},
	{"exnihilo:iron_gravel",0,"Железная Гравиевая руда","minecraft:iron_ingot",0,"Железный слиток",2,2},
	{"exnihilo:iron_sand",0,"Железная Песчаная руда","minecraft:iron_ingot",0,"Железный слиток",2,3},
	{"exnihilo:iron_dust",0,"Железная Пыльная руда","minecraft:iron_ingot",0,"Железный слиток",2,4},
	{"IC2:blockOreCopper",0,"Медная руда","ThermalFoundation:material",64,"Медный слиток",2,5},
	{"exnihilo:copper_gravel",0,"Медная Гравиевая руда","ThermalFoundation:material",64,"Медный слиток",2,6},
	{"exnihilo:copper_sand",0,"Медная Песчаная руда","ThermalFoundation:material",64,"Медный слиток",2,7},
	{"copper_dust",0,"Медная Пыльная руда","ThermalFoundation:material",64,"Медный слиток",2,8},
	{"IC2:blockOreTin",0,"Оловянная руда","ThermalFoundation:material",65,"Оловянный слиток",2,9},
	{"exnihilo:tin_gravel",0,"Оловянная Гравиевая руда","ThermalFoundation:material",65,"Оловянный слиток",2,10},
	{"exnihilo:tin_sand",0,"Оловянная Песчаная руда","ThermalFoundation:material",65,"Оловянный слиток",2,11},
	{"exnihilo:tin_dust",0,"Оловянная Пыльная руда","ThermalFoundation:material",65,"Оловянный слиток",2,12}, 
}


function changer.Init(getterAddress)
	interface_getter = component.proxy(getterAddress)
end

function changer.GetAvailableItems()
	local loot=chest.getAllStacks()
	result={}
	for k,v in pairs(loot) do
		local fingerprint = v.all()
			for i=1,#_list do
				if fingerprint.id==_list[i][1] and fingerprint.dmg==_list[i][2]  then 
					if result[_list[i][8]]==nil then result[_list[i][8]]=0 end
					result[_list[i][8]]=result[_list[i][8]]+fingerprint.qty
				end
			end
	end	
	return result
end

function changer.GetDataItems()
	return _list
end


function AmountOfItem(index)
	local itemsME=interface_getter.getAvailableItems()
	for meIndex,meItem in pairs(itemsME) do
		if(_list[index][4]==meItem.fingerprint.id and _list[index][5]==meItem.fingerprint.dmg) then
			return interface_getter.getItemDetail(meItem.fingerprint).all().qty
		end
	end
	return 0
end


function changer.CanChange(id,count)
	
	return AmountOfItem(id)>count
end

function changer.Change(index,count)
	local loot=chest.getAllStacks()
	local toGet=count
	for k,v in pairs(loot) do
		local fingerprint = v.basic()

		local amount=fingerprint.qty
		if fingerprint.id==_list[index][1] and fingerprint.dmg==_list[index][2] then 
			print("Want to get ".._list[index][3].." x"..toGet)
			if(amount<toGet) then
				chest.pushItem(1,k,amount,1)
				print("get k-"..amount)
				toGet=toGet-amount
			else
				chest.pushItem(1,k,toGet,1)
				print("get toGet-"..toGet)
				toGet=toGet-toGet
			end
			if toGet==0 then break end
		end
	end

	local resultCount = (count-toGet)*_list[index][7]
	
	local itemsME=interface_getter.getAvailableItems()

	for meIndex,meItem in pairs(itemsME) do
		if(_list[index][4]==meItem.fingerprint.id and _list[index][5]==meItem.fingerprint.dmg) then
			local data = interface_getter.getItemDetail(meItem.fingerprint)
			fingerprint = data.all()
			break
		end
	end
	
	local resourchesToGive=resultCount
	while resourchesToGive>0 do
		if resourchesToGive>64 then 
			interface_getter.exportItem(fingerprint,2,64)
			resourchesToGive=resourchesToGive-64
		else
			interface_getter.exportItem(fingerprint,2,resourchesToGive)
			resourchesToGive=0
		end
	end
	
	return resultCount
end

return changer
