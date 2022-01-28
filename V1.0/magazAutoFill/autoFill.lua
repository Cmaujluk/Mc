local component = require("component")

local chest = component.diamond
local interface=component.me_interface

local Interfaceitems=interface.getAvailableItems()

addresses = {}
for address in component.list("database") do
  table.insert(addresses, address)
  print(#addresses .. ": " .. address)
end

function ItemFromStackToInterface(fingerprint)
		for i, item in pairs(Interfaceitems) do
			curfingerprint = item.fingerprint
			
			if(curfingerprint.id==fingerprint.id and curfingerprint.dmg==fingerprint.dmg) then
			print("compare "..curfingerprint.id,fingerprint.id)
				return curfingerprint
				
			end
		end
	return nil
end

while true do
	for j=1,#addresses do
		for i=1,81 do
			local bdItem = component.proxy(addresses[j]).get(i)
			
			local need=true
			
			if bdItem then
				local chestItems = chest.getAllStacks()
				
				for _,chestItem in pairs(chestItems) do
					local chestitm=chestItem.all()
					if bdItem.name==chestitm.id and bdItem.damage==chestitm.dmg then
						need=false
						break
					end
				end
				
				if need then		
					print("i need "..bdItem.name)
					local item = ItemFromStackToInterface({id=bdItem.name,dmg=bdItem.damage})
					if item then
						interface.exportItem(item, 2, 1)
					end
				end
			else
				break
			end
		end
	end

os.sleep(5)
end
