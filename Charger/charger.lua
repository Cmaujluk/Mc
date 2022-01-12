local component = require("component")
local IWCS = component.industrial_wand_charging_station
local gpu = component.gpu
local chest = component.crystal
local os = require("os")  
local interface_charger = component.proxy("e1787a92-9c89-4537-b3ca-804a149473c4")
local interface_getter = component.proxy("4396b0e4-7aab-4259-bb72-1cfd8384c59a")

local charging = false

local WAND_SLOT = 1

local wand=nil
local timeToCharge=0
local TIME_CHECK_CHARGING=2

local toCharge=nil



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
	local loot=chest.getAllStacks()

	for k,v in pairs(loot) do
		local fingerprint = v.basic()

		if fingerprint.id=="Thaumcraft:WandCasting" then 

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
				print("charging")
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
						
					print ("charged!")
					break
				end
				print("check")
				timeToCharge=timeToCharge-1
			end
       
		end
	end
end

function StartChargingWand()
	GetWandToCharge()
	ChargingProcess()
end

StartChargingWand()
