local computer = require "computer"

OnTimer = nil
onTimerInterval = 1
lastSecs=-1
local timer={}
start=false
function CheckTimer()
    if OnTimer == nil then return end
    --print("method ok")
	local time = computer.uptime()
    --print("Time "..time)
    if time%onTimerInterval == 0 and time~=lastSecs then
        -- print("its done"..time)
        -- os.sleep(2)
        lastSecs=time
        OnTimer()
    end
end

function timer.SetTimer(seconds, callback)
    OnTimer = callback
    onTimerInterval = seconds
    while true do
        CheckTimer()
    end
end

return timer