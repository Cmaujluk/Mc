local shell = require("shell")
local fs = require("filesystem")
local prefix = "https://raw.githubusercontent.com/Cmaujluk/Mc/master/V1.0/mcImgs/"

local imagesCount=16


for i=1,imagesCount do
  shell.execute("wget -f "..prefix..i..".png /home/"..i..".png")
end