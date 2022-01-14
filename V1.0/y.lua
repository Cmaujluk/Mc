forms=require("forms")         -- подключаем библиотеку
local component = require("component") 
local gpu = component.gpu
local unicode = require("unicode")

gpu.setResolution(90,45)

local _mainBackgroundColor=0x181D1E

Form1=forms.addForm()          -- создаем основную форму 
Form1.color=_mainBackgroundColor

local selectedLabel =""

local List1=nil

local Label3=nil
local Label4=nil
local Label1_1=nil
local Label5 = nil
local _editField = nil
local _count=""
local Label8=nil
local Label7=nil
local Label6=nil
local _ems=100

local shopCalculatorForm=nil

local items={}
items[1]={label="Железо", price=0.8,count=10,stackSize=64}
items[2]={label="Алмаз", price=2.5,count=20,stackSize=64}
items[3]={label="Золото", price=0.8,count=30,stackSize=64}
items[4]={label="Алюминий", price=0.8,count=40,stackSize=64}
items[5]={label="Капсула материи", price=5.0,count=50,stackSize=64}

local keyboard = {"１","２","３","４","５","６","７","８","９","Ｃ","０","←"}
function SetShopList()
	List1:clear()
	

	for i=1, #items do
		List1:insert(items[i].label,items[i])
	end

	List1:redraw()
end

function SetShopLabel()
	shopCalculatorForm.visible=true
	Label3.caption =List1.items[List1.index].label
	Label3.centered =true
	Label3:redraw()
	Label3:paint()

	Label4.caption="Цена: "..List1.items[List1.index].price.." эм"
	Label4:redraw()

	Label1_1.caption="Доступно: "..List1.items[List1.index].count
	Label1_1:redraw()

	Label5.caption="Хватает на "..math.floor(_ems/List1.items[List1.index].price).." шт"
	Label5:redraw()

	_count=""
	
	UpdateCount()

	
end

local ss=0

function ListSearch()
	ss=ss+1 --debug
	local str=_editField.text
	List1:clear()
	for i=1, #items do
		if string.find(unicode.lower(items[i].label), unicode.lower(str)) then			
			List1:insert(items[i].label.. " text = "..str..";"..ss,items[i])
		end
	end

	List1:redraw()
end

function ListSearchText(Edit,text)
	if(text==nil) then return end
	if(#text==0) then return end
	ss=ss+1 --debug
	local str=text[1]
	List1:clear()

	for i=1, #items do
		if string.find(unicode.lower(items[i].label), unicode.lower(str)) then			
			List1:insert(unicode.lower(items[i].label).. " text = "..unicode.lower(str)..";"..ss,items[i])
		end
	end

	List1:redraw()
end


function UpdateCount()
	local count = tonumber(_count)

	if count==nil or count==0 then
		Label7.caption=""
		Label7:redraw()

		Label8.caption=""
		Label8:redraw()
	else

		if count >List1.items[List1.index].stackSize*27 then count =List1.items[List1.index].stackSize*27  end
		local price=count*List1.items[List1.index].price

		if price>_ems then
			Label7.fontColor=0xff3333
			Label8.fontColor=0xff3333
		else
			Label7.fontColor=0x33ff66
			Label8.fontColor=0x33ff66
		end

		Label7.caption="Я хочу купить: "..count.." шт"
		Label7:redraw()

		Label8.caption="за "..(count*List1.items[List1.index].price).." эм"
		Label8:redraw()

	end
end



function InitShopFrame ()
	exitForm=forms.addForm()       
	exitForm.border=2
	exitForm.W=31
	exitForm.H=7
	exitForm.left=math.floor((Form1.W-exitForm.W)/2)
	exitForm.top =math.floor((Form1.H-exitForm.H)/2)
	exitForm:addLabel(8,3,"Вы хотите выйти?")
	exitForm:addButton(5,5,"Да",function() forms.stop() end)
	exitForm:addButton(18,5,"Нет",function() Form1:setActive() end)
	--------------------------------------
	Btn1=Form1:addButton(2,1,"< Назад",function() exitForm:setActive() end)
	Btn1.color=0x505050                       
	--------------------------------------

	List1=Form1:addList(5,8,SetShopLabel) 
	List1.W=40
	List1.H=26

	List1.color=0x626262

	------------------------------------
	shopCalculatorForm=Form1:addLabel(1,1,"")
	------------------------------------
	SetShopList()
	
	-------------------------------------

	Label1=Form1:addLabel(5,6,"Выберите товар")
	Label1.color=_mainBackgroundColor
	Label1.centered =true
	Label1.autoSize  =false
	Label1.W=40

	Frame1=Form1:addFrame(39,1,1)
	Frame1.W=12
	Frame1.H=3
	Frame1.color= _mainBackgroundColor

	Label2=Form1:addLabel(42,2,"Магазин")
	Label2.fontColor =0xFFE600
	Label2.color=_mainBackgroundColor


	-------------------------------------

	local xStart=48

	Label3=Form1:addLabel(xStart,8,selectedLabel)
	Label3.color=0x009999
	Label3.frontColor=0xffd875
	Label3.centered =true
	Label3.autoSize  =false


	Label3.W=40
	

	Label1_1=Form1:addLabel(xStart,10,"")
	Label1_1.color=_mainBackgroundColor
	Label1_1.W=40
	Label1_1.centered =true
	Label1_1.autoSize  =false


	Label4=Form1:addLabel(xStart,12,"")
	Label4.color=_mainBackgroundColor
	Label4.centered =true
	Label4.autoSize  =false
	Label4.W=40

	Label5=Form1:addLabel(xStart,14,"")
	Label5.color=_mainBackgroundColor
	Label5.centered =true
	Label5.autoSize  =false
	Label5.W=40

	Label6=Form1:addLabel(xStart,16,"Баланс ".._ems.." эм")
	Label6.color=_mainBackgroundColor
	Label6.centered =true
	Label6.autoSize  =false
	Label6.W=40

	Label7=Form1:addLabel(xStart,39,"")
	Label7.color=_mainBackgroundColor
	Label7.centered =true
	Label7.autoSize  =false
	Label7.W=40

	Label8=Form1:addLabel(xStart,40,"")
	Label8.color=_mainBackgroundColor
	Label8.centered =true
	Label8.autoSize  =false
	Label8.W=40 

	UpdateCount()
	--------------------------------------
	Btn2=Form1:addButton(60,43,"Купить",function() exitForm:setActive() end) 
	Btn2.color=0x4e7640      --->

	-------------------------------------
	for i=1, 12 do

		local toWrite=keyboard[i]
		local xSpace=8
		Btn1=Form1:addButton(56+((i-1)*xSpace%(xSpace*3)),19+math.floor((i-1)/3)*(xSpace/2),toWrite,function() 
		local j=i
		if(i<10) then _count=_count..j.."" end
		if i==10 then _count=""end
		if i==11 then _count=_count.."0"end
		if i==12 then
			if(unicode.len(_count)>0) then
				_count= _count:sub(1, -2)
			else
				_count=""
			end
		end
		
		UpdateCount()
		end) 
		Btn1.color=0xD26262 
		Btn1.H=3
		Btn1.W=6
		Btn1.border=0
	end
	-------------------------------------

	_editField=Form1:addEdit(5,36,ListSearch,ListSearchText) --тут я передаю OnChange

	shopCalculatorForm.visible=false
end

InitShopFrame()

forms.run(Form1)              