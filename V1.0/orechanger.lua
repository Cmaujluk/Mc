local component = require("component")
local gpu = component.gpu
local chest = component.crystal
local os = require("os")  
local interface_getter = nil

local changer={}

local _list = {
	{"minecraft:iron_ore",0,"�������� ����","minecraft:iron_ingot",0,"�������� ������",2,1},
	{"exnihilo:iron_sand",0,"�������� �������� ����","minecraft:iron_ingot",0,"�������� ������",2,2}
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

		if fingerprint.id==_list[index][1] and fingerprint.dmg==_list[index][2] then 
			print("Want to get ".._list[index][3].." x"..toGet)
			if(k-toGet<0) then
				chest.pushItem(1,k)
				print("get "..k)
			else
				chest.pushItem(1,toGet)
				print("get "..toGet)
			end

			toGet=toGet-k

			if toGet==0 then break end
		end
	end

	--local resultCount = (count-toGet)*_list[index][7]
	--
	--local itemsME=interface_getter.getAvailableItems()
	--for meIndex,meItem in pairs(itemsME) do
	--	if(_list[index][4]==meItem.fingerprint.all().id and _list[index][5]==meItem.fingerprint.all().dmg) then
	--		fingerprint= meItem.fingerprint.all()
	--		break
	--	end
	--end
	--
	--local resourchesToGive=resultCount
	--while resourchesToGive>0 do
	--	if resourchesToGive>64 then 
	--		interface_getter.exportItem(fingerprint,2,64)
	--		resourchesToGive=resourchesToGive-64
	--	else
	--		interface_getter.exportItem(fingerprint,2,resourchesToGive)
	--		resourchesToGive=0
	--	end
	--end
	--
	--return resultCount
end

return changer