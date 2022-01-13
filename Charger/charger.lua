local component = require("component")
local IWCS = component.industrial_wand_charging_station
local gpu = component.gpu
local chest = component.crystal
local os = require("os")  
local interface_charger = nil
local interface_getter = nil

local charging = false

local WAND_SLOT = 1

local wand=nil
local timeToCharge=0
local TIME_CHECK_CHARGING=2
local toCharge=nil
local wandFound
local charger={}

function ItemFromStackToInterface(fingerprint,interface)
	
	local items=interface.getAvailableItems()

		for i, item in pairs(items) do
			curfingerprint = item.fingerprint

			if(curfingerprint.id==fingerprint.id) then

				return curfingerprint
				
			end
		end
	return nil
end

function GetWandToCharge()
	wandFound=false
	local loot=chest.getAllStacks()

	for k,v in pairs(loot) do
		local fingerprint = v.basic()

		if fingerprint.id=="Thaumcraft:WandCasting" then 
			wandFound=true
			chest.pushItem(1,k)

			local item=ItemFromStackToInterface(fingerprint,interface_charger)
		
			if item~= nil then
				charging=true
				interface_charger.exportItem(item, 4, 1, 1)
				break;
			end
		end
	end
end


function ChargingProcess()
	while charging do
		if wand == nil then
			wand = IWCS.getStackInSlot(WAND_SLOT)
			timeToCharge=TIME_CHECK_CHARGING
		else
			os.sleep(1)
			if wand.nbt_hash ~= IWCS.getStackInSlot(WAND_SLOT).nbt_hash then
        		wand = IWCS.getStackInSlot(WAND_SLOT)
				--print("charging")
				timeToCharge=TIME_CHECK_CHARGING
			else
				if(timeToCharge<=0)then
				
					local fingerprint=IWCS.getStackInSlot(WAND_SLOT)

					IWCS.pushItem(3,1)

					local item = ItemFromStackToInterface(fingerprint,interface_getter)
					if item~= nil then
						charging=false
						interface_getter.exportItem(curfingerprint, 2, 1, 1)
						break
					end
					--print ("charged!")
					break
				end
				--print("check")
				timeToCharge=timeToCharge-1
			end
       
		end
	end
end

function charger.Init(chargerAddress,getterAddress)
	interface_charger = component.proxy(chargerAddress)
	interface_getter = component.proxy(getterAddress)
end

function charger.StartChargingWand()
	GetWandToCharge()
	ChargingProcess()
	if(not wandFound) then return "I don't see ur wand bro" else
	return "Charged" end
end


return charger