local shell = require("shell")
local fs = require("filesystem")
local prefix = "https://raw.githubusercontent.com/Cmaujluk/Mc/master/V1.0/"
local files = {"/y.lua","/forms.lua"}


for _,v in pairs(files) do
  if not fs.exists(v:match(".*/")) then fs.makeDirectory(v:match(".*/")) end
  shell.execute("wget -f "..prefix..v.." /home/"..v)
end