local graffiti=require("graffiti")
local forms=require("forms")      
local charger=require("charger")   
local component = require("component") 
local gpu = component.gpu
local unicode = require("unicode")
local shop = require("shop")

-------------FORMS------------------
local _mainForm = nil
local _menuForm = nil
local _shopForm = nil
local _wandChargerForm = nil

local _mainBackgroundColor = nil

local _ShopBuyBoughtForm = nil

local _state=""
-------------USER------------------ 
local _playerName=""  

------------BUTTONS----------------
local _btnEnter=nil

local _btnShopToMain=nil
------------LABELS---------------
local _playerNameLabel=nil
local _chargingLabel=nil

local _shopSelectedGoodLabel=nil
local _shopAvailableGoodLabel=nil
local _shopPriceGoodLabel=nil
local _shopEnoughEmsLabel=nil
local _shopBalanceEmsLabel=nil
local _shopBalanceEmsLabel2=nil
local _shopWantBuyGoodLabel=nil
local _shopCountWantBuyGoodLabel=nil

local _shopDialogLabel = nil
-------------LISTS---------------
local _shopList=nil
------------EDITS----------------
local _shopEditField = nil
----------GLOBALVARS-------------
local _shopSelectedCount = ""
local _playerEms=100
local _items={}
local _lastTextToSort=""
------------DEBUG----------------


---------------------------------
		
function SetState(state)
	_state=state
end

function Init()
	gpu.setResolution(140,40)
	_mainBackgroundColor=0x2B2A33
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
	exitForm.left=math.floor((40-exitForm.W)/2)
	exitForm.top =math.floor((20-exitForm.H)/2)
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
	methods[1]=AcrivateShopBuyBoughtMenu 
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



function ShopUpdateSelectedGoodsCount()
	local count = tonumber(_shopSelectedCount)
	
	if count==nil or count==0 then
		_shopWantBuyGoodLabel.caption=""
		_shopWantBuyGoodLabel:redraw()

		_shopCountWantBuyGoodLabel.caption=""
		_shopCountWantBuyGoodLabel:redraw()
	else

		if count >_shopList.items[_shopList.index].stackSize*27 then 
			count =_shopList.items[_shopList.index].stackSize*27  
		end
		if count > shop.GetItemCount(_shopList.items[_shopList.index].fingerprint) then 
			count = shop.GetItemCount(_shopList.items[_shopList.index].fingerprint)
		end
		_shopSelectedCount=tostring(count)
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
	_shopList:clear()
	local str=_shopEditField.text
	for i=1, #_items do
		if string.find(unicode.lower(_items[i].label), unicode.lower(str)) then			
			_shopList:insert(_items[i].label,_items[i])
		end
	end
	_shopList:redraw()
	UpdateShopGoodInfo()
end

function ListSearchQuick(Edit,text)
	if(text[1]==_lastTextToSort) then return end
	_lastTextToSort=text[1]
	_shopList:clear()
	local str=text[1]
	for i=1, #_items do
		if string.find(unicode.lower(_items[i].label), unicode.lower(str)) then			
			_shopList:insert(_items[i].label,_items[i])
		end
	end
	_shopList:redraw()
	
	--if _shopList==nil then return end
	--if _shopList.items==nil then return end
	--if _shopList.index==nil  then return end
	--if _shopList.items[_shopList.index]==nil  then return end
	
	UpdateShopGoodInfo()
end

function SetShopList()
	_shopList:clear()
	for i=1, #_items do
		_shopList:insert(_items[i].label,_items[i])
	end
	_shopList:redraw()
end

function UpdateShopGoodInfo()
	--_shopSelectedGoodLabel:show()
	if _shopList.index then
		_shopSelectedGoodLabel.caption =_shopList.items[_shopList.index].label
		_shopSelectedGoodLabel.centered =true
		_shopSelectedGoodLabel:redraw()
	end
	--Label3:paint()
	
	_shopPriceGoodLabel.caption="Цена: ".._shopList.items[_shopList.index].price.." эм"
	_shopPriceGoodLabel:redraw()

	_shopAvailableGoodLabel.caption="Доступно: "..shop.GetItemCount(_shopList.items[_shopList.index].fingerprint)
	_shopAvailableGoodLabel:redraw()

	_shopEnoughEmsLabel.caption="Хватает на "..math.floor(_playerEms/_shopList.items[_shopList.index].price).." шт"
	_shopEnoughEmsLabel:redraw()
	_shopSelectedCount = ""
	ShopUpdateSelectedGoodsCount()

	gpu.setBackground(0x3E3D47)
	gpu.fill(51,10,12,6," ")

	
	--pic=graffiti.load("/home/img2.png") --debug
	--graffiti.draw(pic, 51,19,12,12) --debug картиночки
end

function InitShop()
	_items=shop.GetItemsToSale()
end

function SetBalanceView(count)
	local str=tostring(count)
	local add=""
	for i=1, #str do
		add=add.." "
	end

	_shopBalanceEmsLabel.caption="Баланс: "..add.." эм"
	_shopBalanceEmsLabel2.caption=str
	_shopBalanceEmsLabel:redraw()
	_shopBalanceEmsLabel2:redraw()
end

function CreateShop()
	local xStart=48
	local xShift=16
	
	_shopForm=forms.addForm()
	_shopForm.W=90
	_shopForm.H=45
	_shopForm.color=_mainBackgroundColor
	
	backToMain=_shopForm:addButton(5,43,"← Назад",OpenMainMenu) 
	backToMain.autoSize=false
	backToMain.centered=true
	backToMain.H=1
	backToMain.W=10
	backToMain.color=_mainBackgroundColor    

	frame=_shopForm:addFrame(36,1,1) 
	frame.W=24
	frame.H=3 
	frame.color= _mainBackgroundColor


	
	label=_shopForm:addLabel(42,2,"Магазин") 
	label.fontColor =0xFFE600
	label.color=_mainBackgroundColor
	
	local keyboard = {"１","２","３","４","５","６","７","８","９","Ｃ","０","←"}
	
	_shopList=_shopForm:addList(5,8,UpdateShopGoodInfo) --обработка клика в скролле
	_shopList.W=40
	_shopList.H=29
	_shopList.color=0x42414D
	_shopList.selColor=0x2E7183
	_shopList.sfColor=0xffffff
	
	local label = _shopForm:addLabel(5,6,"Выберите товар")
	label.color = _mainBackgroundColor
	label.centered = true
	label.autoSize  = false
	label.W=40

	local label = _shopForm:addLabel(xStart-1,17,"Наберите кол-во товара")
	label.color = _mainBackgroundColor
	label.centered = true
	label.autoSize  = false
	label.W=40
	
	_shopSelectedGoodLabel=_shopForm:addLabel(xStart,8,"1")
	_shopSelectedGoodLabel.color=0x009999
	_shopSelectedGoodLabel.fontColor=0xffd875
	_shopSelectedGoodLabel.color = _mainBackgroundColor
	_shopSelectedGoodLabel.centered = true
	_shopSelectedGoodLabel.autoSize  = false
	_shopSelectedGoodLabel.W=40
	
	_shopAvailableGoodLabel=_shopForm:addLabel(xStart+xShift,10,"2")
	_shopAvailableGoodLabel.color = _mainBackgroundColor
		
	_shopPriceGoodLabel=_shopForm:addLabel(xStart+xShift,12,"3")
	_shopPriceGoodLabel.color = _mainBackgroundColor

	
	_shopEnoughEmsLabel=_shopForm:addLabel(xStart+xShift,14,"4")
	_shopEnoughEmsLabel.color = _mainBackgroundColor

	_shopBalanceEmsLabel=_shopForm:addLabel(2,2,"")
	_shopBalanceEmsLabel.color = _mainBackgroundColor
	_shopBalanceEmsLabel.fontColor = 0xFFB950
	_shopBalanceEmsLabel2=_shopForm:addLabel(10,2,"")
	_shopBalanceEmsLabel2.color = _mainBackgroundColor
	_shopBalanceEmsLabel2.fontColor = 0x7DFF50
	SetBalanceView(20.4)
	
	_shopWantBuyGoodLabel=_shopForm:addLabel(xStart,35,"6")
	_shopWantBuyGoodLabel.color = _mainBackgroundColor
	_shopWantBuyGoodLabel.centered = true
	_shopWantBuyGoodLabel.autoSize  = false
	_shopWantBuyGoodLabel.W=40
	
	_shopCountWantBuyGoodLabel=_shopForm:addLabel(xStart,36,"7")
	_shopCountWantBuyGoodLabel.color = _mainBackgroundColor
	_shopCountWantBuyGoodLabel.centered = true
	_shopCountWantBuyGoodLabel.autoSize  = false
	_shopCountWantBuyGoodLabel.W=40
	
	buyButton= _shopForm:addButton(56,38,"Купить",function() 
		local count = tonumber(_shopSelectedCount)
		if count==nil or count ==0 then return end
		shop.GetItems(_shopList.items[_shopList.index],count)
		ShowShopBuyDialog("Вы успешно купили "..count.." ".._shopList.items[_shopList.index].label) -- тут проверка на бабки
		
	end) 
	buyButton.color=0x5C9A47
	buyButton.W=20
	buyButton.H=3
	
	
	for i=1, 12 do
		local toWrite=keyboard[i]
		local xSpace=8
		local ySpace=7
		button=_shopForm:addButton(56+((i-1)*xSpace%(xSpace*3)),19+math.floor((i-1)/3)*4,toWrite,function() 
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
		end) 
		if i==10 or i==12 then
			button.color=0x42AECB
		else
			button.color=0xD26262 
		end
		
		button.H=3
		button.W=6
		button.border=0
	end
	
	SetShopList()
	-------------------------------------
	_shopEditField=_shopForm:addEdit(5,38,ListSearch,ListSearchQuick)
	_shopEditField.W=40
	_shopEditField.h=3
	_shopEditField.border=0
	_shopEditField.color=0x42414D
	--_shopSelectedGoodLabel:hide()
end

function AcrivateShopBuyBoughtMenu()
	gpu.setResolution(80,40)
	_ShopBuyBoughtForm:setActive()
end

function CreateShopBuyBought()	
	_ShopBuyBoughtForm=forms.addForm()
	_ShopBuyBoughtForm.W=80
	_ShopBuyBoughtForm.H=40
	_ShopBuyBoughtForm.color=_mainBackgroundColor

	toShopButton= _ShopBuyBoughtForm:addButton(30,14,"Купить",function() 
		ActivateShop()		
	end) 
	toShopButton.color=0x5C9A47
	toShopButton.W=20
	toShopButton.H=3

	toSellButton= _ShopBuyBoughtForm:addButton(30,26,"Продать",function() 
		ActivateShop()		
	end) 
	toSellButton.color=0x5C9A47
	toSellButton.W=20
	toSellButton.H=3

	backToMain=_ShopBuyBoughtForm:addButton(5,38,"← Назад",OpenMainMenu) 
	backToMain.autoSize=false
	backToMain.centered=true
	backToMain.H=1
	backToMain.W=10
	backToMain.color=_mainBackgroundColor    
end

function CreateDialogWindowBuyShopForm()
	dialogForm=forms.addForm()       
	dialogForm.border=1
	dialogForm.W=31
	dialogForm.H=7
	dialogForm.left=math.floor((40-dialogForm.W)/2)
	dialogForm.top =math.floor((20-dialogForm.H)/2)
	_shopDialogForm=dialogForm:addLabel(8,3,"")
	dialogForm:addButton(18,5,"Ок",function() _shopForm:setActive() end)
end

function ShowShopBuyDialog(string)

	dialogForm:setActive()
	_shopDialogLabel.caption=string
	_shopDialogLabel:redraw()
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
shop.Init()
InitCharger()
CreateShopBuyBought()	
CreateDialogWindowBuyShopForm()
InitShop()
CreateButtonExit()
CreateEnterButton()
CreateMainMenu()
CreateShop()
CreateWandCharger()
RunForm()