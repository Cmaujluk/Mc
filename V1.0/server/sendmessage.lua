local modem = require("component").tunnel
local term=require("term")

while true do
	print("¬ведите сообщение")
	message = io.read()
	modem.send(message)
	term.clear()
end