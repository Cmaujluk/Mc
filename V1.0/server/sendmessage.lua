local component = require("component")
local modem = require("component").tunnel
local term=require("term")
local sensor = component.openperipheral_sensor
local redstone = component.redstone
local colors = require("colors")
local computer = require("computer")

local _tapeMagaz = component.proxy("540ad9de-fcb1-481a-978e-3ab5c3e51cbe")
local _tapeMagazLength=-1
local _lastTimer=-1

local _playersNear = 10
function DetectPlayers()
	local playerNear=sensor.getPlayers()
	local playersInArea=0
	if(playerNear~=nil) then
		playersInArea=#playerNear
		if(playersInArea==1) then
			for i=1,#playerNear do
				local playerName=playerNear[i].name
				if(playerName~=nil) then
					local player=sensor.getPlayerByName(playerName)
					if(player~=nil) then
						local playerPos=player.basic().position
						local X=playerPos.x
						local Z=playerPos.z
						  
						if(X<-4.277 and Z>-0.837 and Z<1.853) then
							playersInArea=playersInArea-1
						end
					end
				end			
			end
		end
	end
	_playersNear=playersInArea
end

function SoundPlay(message,timer)
	if message == "shop_buy" then
		_tapeMagaz.seek(-9999999)
		_tapeMagaz.play()
		_tapeMagazLength=timer
	end
end

function CheckAudio()
	if _tapeMagazLength>0 and _tapeMagazLength~=-1 then 
		_tapeMagazLength=_tapeMagazLength-1
	else 
		if _tapeMagazLength==0 then
			--print("stop")
			_tapeMagazLength=-1 
			_tapeMagaz.stop()
			_tapeMagaz.seek(-9999999)
		end
	end
end

function Timer()
	local timer=computer.uptime()
	--print("check "..timer.." "..timer%2)
	local curTimer=math.floor(timer)
	if _lastTimer~=curTimer then
		_lastTimer=curTimer
		--print("check audio "..curTimer)
		CheckAudio()
	end
end

function Work()
	if(redstone.getBundledInput(4,colors.orange)~=0) then
		modem.send("stop")
	end
	
	DetectPlayers()
	
	modem.send("players".._playersNear)
	
	if(_playersNear==1) then
		redstone.setBundledOutput(4,colors.white,15)
	else
		redstone.setBundledOutput(4,colors.white,0)
	end
	
	local ev,adr,x,y,btn,user=computer.pullSignal(0.01)
	
	if ev=="modem_message" then
		SoundPlay(user,5)
	end
	
	Timer()
end

while true do
	pcall(Work)
end