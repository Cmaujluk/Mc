local forms=require("forms")      
local charger=require("charger")   
local component = require("component") 
local gpu = component.gpu
local unicode = require("unicode")

-------------FORMS------------------
	_mainForm = nil
	_menuForm = nil
	_shopForm = nil
	_wandChargerForm = nil

	_mainBackgroundColor = nil

	_state=""
-------------USER------------------ 
	_playerName=""  

------------BUTTONS----------------
	_btnEnter=nil
	
	_btnShopToMain=nil
------------LABELS---------------
	_playerNameLabel=nil
	_chargingLabel=nil
	
	_shopSelectedGoodLabel=nil
	_shopAvailableGoodLabel=nil
	_shopPriceGoodLabel=nil
	_shopEnoyghEmsLabel=nil
	_shopBalanceEmsLabel=nil
	_shopWantBuyGoodLabel=nil
	_shopCountWantBuyGoodLabel=nil
-------------LISTS---------------
	_shopList=nil
------------EDITS----------------
	_shopEditField = nil
----------GLOBALVARS-------------
	_shopSelectedCount = ""
	_playerEms=100
------------DEBUG----------------
items={}
items[1]={label="Железо", price=0.8,count=10,stackSize=64}
items[2]={label="Алмаз", price=2.5,count=20,stackSize=64}
items[3]={label="Золото", price=0.8,count=30,stackSize=64}
items[4]={label="Алюминий", price=0.8,count=40,stackSize=64}
items[5]={label="Капсула материи", price=5.0,count=50,stackSize=64}
---------------------------------
	
	
	
function SetState(state)
	_state=state
end

function Init()
	gpu.setResolution(140,40)
	_mainBackgroundColor=0x181D1E
	_mainForm=forms.addForm()       
	_mainForm.W=80
	_mainForm.H=40
	_mainForm.color=_mainBackgroundColor
	
	SetState("enter_menu")
end

function InitCharger()
	local chargerAddress="e1787a92-9c89-4537-b3ca-804a149473c4"
	local getterAddress="4396b0e4-7aab-4259-bb72-1cfd8384c59a"
	charger.Init(chargerAddress,getterAddress)
end

function CreateButtonExit()
	exitForm=forms.addForm()       
	exitForm.border=2
	exitForm.W=31
	exitForm.H=7
	exitForm.left=math.floor((_mainForm.W-exitForm.W)/2)
	exitForm.top =math.floor((_mainForm.H-exitForm.H)/2)
	exitForm:addLabel(8,3,"Вы хотите выйти?")
	exitForm:addButton(5,5,"Да",function() forms.stop() end)
	exitForm:addButton(18,5,"Нет",function() _mainForm:setActive() end)

	BtnExit=_mainForm:addButton(4,2,"Выйти",function() exitForm:setActive() end) 
	BtnExit.color=0x4e7640      
end

function AcrivateMainMenu()
	gpu.setResolution(80,40)
	_menuForm:setActive()
	_playerNameLabel.caption=_playerName
	_playerNameLabel:redraw()
end

function OpenEnterMenu()
	gpu.setResolution(40,20)
	_mainForm:setActive()
end

function OpenMainMenu(obj,userName)
	_playerName=userName
	SetState("main_menu")
	AcrivateMainMenu()
end

function CreateEnterButton()
	_btnEnter =_mainForm:addButton(17,10,"Войти",OpenMainMenu) 
	_btnEnter.color=0x4e7640    
	_btnEnter.autoSize=false    
	_btnEnter.centered=true    
end

function CreateButton(form,x,y,h,w,label,foo)
	BtnShop=form:addButton(x,y,label,foo) 
	BtnShop.autoSize=false
	BtnShop.centered=true
	BtnShop.H=h
	BtnShop.W=w
	BtnShop.color=0x4e7640      
end

function ActivateShop()
	gpu.setResolution(90,45)
	_shopForm:setActive()
end

function ActivateWandCharger()
	gpu.setResolution(90,45)
	_wandChargerForm:setActive()
end

function CreateMainMenu()
	_menuForm=forms.addForm()       
	_menuForm.W=80
	_menuForm.H=40
	_menuForm.color=_mainBackgroundColor

	local labels={}	
	labels[1]="Магазин"	
	labels[2]="Обмен ресурсов"	
	labels[3]="Зарядка жезлов"	
	labels[4]="Билеты казино"	
	labels[5]="Лотерея"	labels[6]="Мехи"
	local methods={} 
	methods[1]=ActivateShop 
	methods[2]=ActivateShop 
	methods[3]=ActivateWandCharger	
	methods[4]=ActivateShop	
	methods[5]=ActivateShop	
	methods[6]=ActivateShop

	local shift=5
	for i=1, #labels do
		CreateButton(_menuForm,20,4+shift*i,3, 40,labels[i],methods[i])
	end
	
	_playerNameLabel=_menuForm:addLabel(1,3,_playerName)
	
	CreateButton(_menuForm,4,2,1,10,"Назад",OpenEnterMenu)
end

function SetLabel(form,x,y,label,w)
	label = form:addLabel(x,y,label)
	label.color = _mainBackgroundColor
	label.centered = true
	label.autoSize  = false
	label.w=40
	return label
end

function ShopUpdateSelectedGoodsCount()
	local count = tonumber(_shopSelectedCount)
	
	if count==nil or count==0 then
		_shopWantBuyGoodLabel.caption=""
		_shopWantBuyGoodLabel:redraw()

		_shopCountWantBuyGoodLabel.caption=""
		_shopCountWantBuyGoodLabel:redraw()
	else

		if count >_shopList.items[_shopList.index].stackSize*27 then count =_shopList.items[_shopList.index].stackSize*27  end
		local price=count*_shopList.items[_shopList.index].price

		if price>_playerEms then
			_shopWantBuyGoodLabel.fontColor=0xff3333
			_shopCountWantBuyGoodLabel.fontColor=0xff3333
		else
			_shopWantBuyGoodLabel.fontColor=0x33ff66
			_shopCountWantBuyGoodLabel.fontColor=0x33ff66
		end

		_shopWantBuyGoodLabel.caption="Я хочу купить: "..count.." шт"
		_shopWantBuyGoodLabel:redraw()

		_shopCountWantBuyGoodLabel.caption="за "..(count*_shopList.items[_shopList.index].price).." эм"
		_shopCountWantBuyGoodLabel:redraw()

	end
	
	
end

function ListSearch()
	local str=_shopEditField.text
	_shopList:clear()
	for i=1, #items do
		if string.find(unicode.lower(items[i].label), unicode.lower(str)) then			
			_shopList:insert(items[i].label.. " text = "..str..";"..ss,items[i])
		end
	end
	_shopList:redraw()
end

function SetShopList()
	_shopList:clear()
	for i=1, #items do
		_shopList:insert(items[i].label,items[i])
	end
	_shopList:redraw()
end

function CreateShop()
	local xStart=48
	
	_shopForm=forms.addForm()
	_shopForm.W=90
	_shopForm.H=45
	_shopForm.color=_mainBackgroundColor
	
	CreateButton(_shopForm,4,2,1,10,"Назад",OpenMainMenu)
	frame=_shopForm:addFrame(39,1,1) 
	frame.W=12 
	frame.H=3 
	frame.color= _mainBackgroundColor
	
	label=_shopForm:addLabel(42,2,"Магазин") 
	label.fontColor =0xFFE600 
	label.color=_mainBackgroundColor
	
	local keyboard = {"1","2","3","4","5","6","7","8","9","C","0","<"}
	
	_shopList=_shopForm:addList(5,8,function() end) --обработка клика в скролле
	_shopList.W=40
	_shopList.H=26
	_shopList.color=0x626262
	
	SetLabel(_shopForm,5,6,"Выберите товар",40)
	
	_shopSelectedGoodLabel=SetLabel(_shopForm,xStart,8,"1",40)
	_shopSelectedGoodLabel.color=0x009999
	_shopSelectedGoodLabel.frontColor=0xffd875
	
	_shopAvailableGoodLabel=SetLabel(_shopForm,xStart,10,"2",40)
	
	_shopPriceGoodLabel=SetLabel(_shopForm,xStart,12,"3",40)
	
	_shopEnoyghEmsLabel=SetLabel(_shopForm,xStart,14,"4",40)
	
	_shopBalanceEmsLabel=SetLabel(_shopForm,xStart,16,"5",40)
	
	_shopWantBuyGoodLabel=SetLabel(_shopForm,xStart,39,"6",40)
	
	_shopCountWantBuyGoodLabel=SetLabel(_shopForm,xStart,40,"7",40)
	
	button=_shopForm:addButton(60,43,"Купить",function() exitForm:setActive() end) 
	button.color=0x4e7640      
	
	
	for i=1, 12 do
		local toWrite=keyboard[i]
		local xSpace=8
		button=_shopForm:addButton(56+((i-1)*xSpace%(xSpace*3)),19+math.floor((i-1)/3)*(xSpace/2),toWrite,function() 
			local j=i
			if(i<10) then _shopSelectedCount=_shopSelectedCount..j.."" end
			if i==10 then _shopSelectedCount=""end
			if i==11 then _shopSelectedCount=_shopSelectedCount.."0"end
			if i==12 then
				if(unicode.len(_shopSelectedCount)>0) then
					_shopSelectedCount = _shopSelectedCount:sub(1, -2)
				else
					_shopSelectedCount = ""
				end
			end
			ShopUpdateSelectedGoodsCount()
			
			_shopAvailableGoodLabel.caption=""..j --дебаг
			_shopAvailableGoodLabel:redraw()
		end) 
		button.color=0xD26262 
		button.H=3
		button.W=6
		button.border=0
	end
	
	SetShopList()
	-------------------------------------
	_shopEditField=_shopForm:addEdit(5,36,ListSearcht)
end

function ShowChargingStatus(str)
	_chargingLabel.caption="Статус: "..str
	_chargingLabel:redraw()
end

function CreateWandCharger()
	_wandChargerForm = forms.addForm()
	_wandChargerForm.W=90
	_wandChargerForm.H=45
	_wandChargerForm.color=_mainBackgroundColor
	
	CreateButton(_wandChargerForm ,4,2,1,10,"Назад",OpenMainMenu)
	
	frame=_wandChargerForm:addFrame(33,1,1) frame.W=22 frame.H=3 frame.color= _mainBackgroundColor
	
	label=_wandChargerForm:addLabel(39,2,"Зарядка жезлов") label.fontColor =0xFFE600 label.color=_mainBackgroundColor
	
	_chargingLabel=_wandChargerForm:addLabel(39,30,"Подготовка") _chargingLabel.fontColor =0xFFE600 _chargingLabel.color=_mainBackgroundColor
	
	CreateButton(_wandChargerForm,20,40,3,50,"Зарядить мою палку",function()ShowChargingStatus("Charging") ShowChargingStatus(charger.StartChargingWand()) end)--
end
------------------------------------
function RunForm()
	forms.run(_mainForm) 
end

------------------------------------
Init()
InitCharger()
CreateButtonExit()
CreateEnterButton()
CreateMainMenu()
CreateShop()
CreateWandCharger()
RunForm()