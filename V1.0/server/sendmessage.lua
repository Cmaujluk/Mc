local component = require("component")
local modem = require("component").tunnel
local term=require("term")
local sensor = component.openperipheral_sensor
local redstone = component.redstone
local colors = require("colors")
local computer = require("computer")

local _lastTimer=-1

local _tapeMagaz = component.proxy("540ad9de-fcb1-481a-978e-3ab5c3e51cbe")
local _tapeMagazLength=-1
_tapeMagaz.setSpeed(2)

local _tapeEms = component.proxy("88509495-8410-485f-83ee-f8b7f3042572")
local _tapeEmsLength=-1
_tapeEms.setSpeed(2)

local _tapeOres = component.proxy("ef5782d0-f518-4e29-93a3-bed245f6da4d")
local _tapeOresLength=-1
_tapeOres.setSpeed(2)

local _tapeTrade = component.proxy("ad67551f-4f82-4dc1-be07-09972abee96d")
local _tapeTradeLength=-1
_tapeTrade.setSpeed(2)

local _tapeWand = component.proxy("cbc8dfb1-918c-492b-a0ea-a230f24d0ff8")
local _tapeWandLength=-1
_tapeWand.setSpeed(2)



function SoundPlay(message,timer)
	if message == "shop_buy" then
		_tapeMagaz.seek(-9999999)
		_tapeMagaz.play()
		_tapeMagazLength=timer
	end
	
	if message == "shop_ems" then
		_tapeEms.seek(-9999999)
		_tapeEms.play()
		_tapeEmsLength=timer
	end
	
	if message == "trade_ores" then
		_tapeOres.seek(-9999999)
		_tapeOres.play()
		_tapeOresLength=timer
	end
	
	if message == "trade_in" then
		_tapeTrade.seek(-9999999)
		_tapeTrade.play()
		_tapeTradeLength=timer
	end
	
	if message == "wand" then
		_tapeWand.seek(-9999999)
		_tapeWand.play()
		_tapeWandLength=timer
	end
end

function CheckAudio()
	if _tapeMagazLength>0 and _tapeMagazLength~=-1 then 
		_tapeMagazLength=_tapeMagazLength-1
	else 
		if _tapeMagazLength==0 then
			_tapeMagazLength=-1 
			_tapeMagaz.stop()
			_tapeMagaz.seek(-9999999)
		end
	end
	
	if _tapeEmsLength>0 and _tapeEmsLength~=-1 then 
		_tapeEmsLength=_tapeEmsLength-1
	else 
		if _tapeEmsLength==0 then
			_tapeEmsLength=-1 
			_tapeEms.stop()
			_tapeEms.seek(-9999999)
		end
	end
	
	if _tapeOresLength>0 and _tapeOresLength~=-1 then 
		_tapeOresLength=_tapeOresLength-1
	else 
		if _tapeOresLength==0 then
			_tapeOresLength=-1 
			_tapeOres.stop()
			_tapeOres.seek(-9999999)
		end
	end
	
	if _tapeTradeLength>0 and _tapeTradeLength~=-1 then 
		_tapeTradeLength=_tapeTradeLength-1
	else 
		if _tapeTradeLength==0 then
			_tapeTradeLength=-1 
			_tapeTrade.stop()
			_tapeTrade.seek(-9999999)
		end
	end
	
	if _tapeWandLength>0 and _tapeWandLength~=-1 then 
		_tapeWandLength=_tapeWandLength-1
	else 
		if _tapeWandLength==0 then
			_tapeWandLength=-1 
			_tapeWand.stop()
			_tapeWand.seek(-9999999)
		end
	end
end

local _playersNear = 10
function DetectPlayers()
	local playerNear=sensor.getPlayers()
	local playersInArea=0
	if(playerNear~=nil) then
		playersInArea=#playerNear
		for i=1,#playerNear do
			local playerName=playerNear[i].name
			if(playerName~=nil) then
				local player=sensor.getPlayerByName(playerName)
				if(player~=nil) then
					local playerPos=player.basic().position
					local X=playerPos.x
					local Y=playerPos.y
					local Z=playerPos.z
					  
					if Y<=1.5 or X<-2 or Z<-1 or X>3 or Z>4.7 or (X>-0.45 and X<1.7 and Z>3.15 and #playerNear==1) then
						playersInArea=playersInArea-1
					end
				end
			end			
		end
	end
	_playersNear=playersInArea
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