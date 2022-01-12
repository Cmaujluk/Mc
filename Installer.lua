local shell = require("shell")
local fs = require("filesystem")
local prefix = "https://bitbucket.org/Cmaujluk/mc_shop/raw/master/V1.0"
local files = {"/forms.lua","/y.lua"}


for _,v in pairs(files) do
  shell.execute("wget -f "..prefix..v.." /home"..v)
end