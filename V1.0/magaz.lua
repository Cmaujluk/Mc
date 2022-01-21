local graffiti=require("graffiti")
local forms=require("forms")      
local charger=require("charger")   
local component = require("component") 
local gpu = component.gpu
local unicode = require("unicode")
local shop = require("shop")
local changer=require("orechanger")


-------------FORMS------------------
local _mainForm = nil
local _menuForm = nil
local _shopForm = nil
local _wandChargerForm = nil
local _shopSellForm = nil
local _orechangerForm = nil
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
local _shopSelectedSellGoodLabel=nil
local _orechangerSelectedGoodLabel=nil
local _shopDialogLabel = nil
local _shopDialogSellLabel = nil
local _shopCountWantSellGoodLabel = nil
local _shopWantSellGoodLabel = nil
local _shopBalanceEmsSellLabel = nil
local _shopBalanceEmsSellLabel2 = nil
local _shopPriceSellGoodLabel = nil
local _orechangerAvailableGoodLabel = nil
local _shopAvailableSellGoodLabel = nil
-------------LISTS---------------
local _shopList=nil
local _shopSellList=nil
local _orechangerList=nil
------------EDITS----------------
local _shopEditField = nil
----------GLOBALVARS-------------
local _shopSelectedCount = ""
local _playerEms=100
local _items={}
local _lastTextToSort=""

local keyboard = {"１","２","３","４","５","６","７","８","９","Ｃ","０","←"}
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
	_btnEnter =_mainForm:addButton(10,10,"Войти",OpenMainMenu) 
	_btnEnter.color=0x626262   
	_btnEnter.autoSize=false    
	_btnEnter.centered=true    
	_btnEnter.W=20
	_btnEnter.H=3

	label = _mainForm:addLabel(1,5,"Приветствуем на /warp smart")
	label.color=_mainBackgroundColor   
	label.autoSize=false    
	label.centered=true    
	label.W=40
	label.H=3
end

function CreateButton(form,x,y,h,w,label,foo)
	BtnShop=form:addButton(x,y,label,foo) 
	BtnShop.autoSize=false
	BtnShop.centered=true
	BtnShop.H=h
	BtnShop.W=w
	BtnShop.color=0x626262    
end

function ActivateShop()
	gpu.setResolution(90,45)
	_shopForm:setActive()
	SetBalanceView(_playerEms)
	_shopList.index=1
	_shopList:redraw()
	UpdateShopGoodInfo(true)
end

function ActivateSellShop()
	gpu.setResolution(90,45)
	_shopSellForm:setActive()
	SetBalanceSellView(_playerEms)
	_shopSellList.index=1
	_shopSellList:redraw()
	UpdateShopSellGoodInfo()
end

function ActivateOreChanger()
	gpu.setResolution(90,45)
	_orechangerForm:setActive()
	SetBalanceSellView(_playerEms)
	UpdateOrechangerGoodInfo()
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
	labels[2]="Омбен руд 1 на 2 слитка"	
	labels[3]="Обмен ресурсы на ресурсы без эмов"	
	labels[4]="Зарядка жезлов таумкрафт"	
	labels[5]="Купить билеты в казино"	
	labels[6]="Лотерея"	
	labels[7]="Мехи"
	local methods={} 
	methods[1]=AcrivateShopBuyBoughtMenu 
	methods[2]=ActivateOreChanger 
	methods[3]=ActivateShop	
	methods[4]=ActivateWandCharger	
	methods[5]=ActivateShop	
	methods[6]=ActivateShop
	methods[7]=ActivateShop

	local shift=4
	for i=1, #labels do
		CreateButton(_menuForm,20,2+shift*i,3, 40,labels[i],methods[i])
	end
	
	_playerNameLabel=_menuForm:addLabel(3,2,_playerName)
	_playerNameLabel=_menuForm:addLabel(3,4,"Баланс")
	_playerNameLabel=_menuForm:addLabel(3,5,_playerEms.." Эм")
	_playerNameLabel=_menuForm:addLabel(3,6,"0 коинов") -->

	backToEnterMenu=_menuForm:addButton(3,38,"← Назад",OpenEnterMenu) 
	backToEnterMenu.autoSize=false
	backToEnterMenu.centered=true
	backToEnterMenu.H=1
	backToEnterMenu.W=10
	backToEnterMenu.color=_mainBackgroundColor    
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
	UpdateShopGoodInfo(false)
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
	
	UpdateShopGoodInfo(true)
end

function SetShopList()
	_shopList:clear()
	for i=1, #_items do
		_shopList:insert(_items[i].label,_items[i])
	end
	_shopList:redraw()
end

function SetShopSellList()
	_shopSellList:clear()
	for i=1, #_itemsSaleData do
		_shopSellList:insert(_itemsSaleData[i].label,_itemsSaleData[i])
	end
	_shopSellList:redraw()
end

function SetOrechangerList()
	_orechangerList:clear()

	local data = changer.GetDataItems()

	for i,j in pairs(_itemsOrechanger) do
		_orechangerList:insert(data[i][3],data[i])
	end

	_orechangerList:redraw()
end

function ShopShowImage()
	gpu.setBackground(0x3E3D47)
	gpu.fill(47,10,16,9," ")

	pic=graffiti.load("/home/".._shopList.items[_shopList.index].localId..".png") --debug
	graffiti.draw(pic, 47,21,16,16) --debug картиночки
end

function ShopShowImageSell()
	gpu.setBackground(0x3E3D47)
	gpu.fill(47,10,16,9," ")

	pic=graffiti.load("/home/".._shopSellList.items[_shopSellList.index].img..".png") --debug
	graffiti.draw(pic, 47,21,16,16) --debug картиночки
end

function ShowImageOrechanger()
	gpu.setBackground(0x3E3D47)
	gpu.fill(47,10,16,9," ")

	pic=graffiti.load("/home/".._shopSellList.items[_shopSellList.index].img..".png") --debug
	graffiti.draw(pic, 47,21,16,16) --debug картиночки

	gpu.setBackground(0x3E3D47)
	gpu.fill(47,30,16,9," ")

	pic=graffiti.load("/home/".._shopSellList.items[_shopSellList.index].img..".png") --debug
	graffiti.draw(pic, 47,41,16,16) --debug картиночки
end

function UpdateShopGoodInfo(check)
	if check then
		if #_shopList.items==0 or _shopList.index==nil then return end
	end

	_shopSelectedGoodLabel.caption =_shopList.items[_shopList.index].label
	_shopSelectedGoodLabel.centered =true
	_shopSelectedGoodLabel:redraw()
	
	_shopPriceGoodLabel.caption="Цена: ".._shopList.items[_shopList.index].price.." эм"
	_shopPriceGoodLabel:redraw()

	_shopAvailableGoodLabel.caption="Доступно: "..shop.GetItemCount(_shopList.items[_shopList.index].fingerprint)
	_shopAvailableGoodLabel:redraw()

	_shopEnoughEmsLabel.caption="Хватает на "..math.floor(_playerEms/_shopList.items[_shopList.index].price).." шт"
	_shopEnoughEmsLabel:redraw()
	_shopSelectedCount = ""
	ShopUpdateSelectedGoodsCount()
	ShopShowImage()
end

function UpdateShopSellGoodInfo()


	_shopSelectedSellGoodLabel.caption =_shopSellList.items[_shopSellList.index].label
	_shopSelectedSellGoodLabel.centered =true
	_shopSelectedSellGoodLabel:redraw()
	
	_shopPriceSellGoodLabel.caption="Цена продажи: ".._shopSellList.items[_shopSellList.index].price.." эм"
	_shopPriceSellGoodLabel:redraw()

	
	local itemsCount=shop.GetItemSellCount(_shopSellList.items[_shopSellList.index])

	_shopAvailableSellGoodLabel.caption="У вас есть "..itemsCount.." шт"
	_shopAvailableSellGoodLabel:redraw()

	if itemsCount>0 then
		_shopWantSellGoodLabel.caption="Я хочу продать "..itemsCount.." шт"
		_shopCountWantSellGoodLabel.caption="За "..(itemsCount*_shopSellList.items[_shopSellList.index].price).." эм"

	else
		_shopWantSellGoodLabel.caption=""
		_shopCountWantSellGoodLabel.caption=""
	end

	_shopCountWantSellGoodLabel:redraw()
	_shopWantSellGoodLabel:redraw()

	ShopShowImageSell()
	
end

function UpdateOrechangerGoodInfo()-->


	_shopSelectedSellGoodLabel.caption =_shopSellList.items[_shopSellList.index].label
	_shopSelectedSellGoodLabel.centered =true
	_shopSelectedSellGoodLabel:redraw()
	
	_shopPriceSellGoodLabel.caption="Цена продажи: ".._shopSellList.items[_shopSellList.index].price.." эм"
	_shopPriceSellGoodLabel:redraw()

	
	local itemsCount=shop.GetItemSellCount(_shopSellList.items[_shopSellList.index])

	_shopAvailableSellGoodLabel.caption="У вас есть "..itemsCount.." шт"
	_shopAvailableSellGoodLabel:redraw()

	if itemsCount>0 then
		_shopWantSellGoodLabel.caption="Я хочу продать "..itemsCount.." шт"
		_shopCountWantSellGoodLabel.caption="За "..(itemsCount*_shopSellList.items[_shopSellList.index].price).." эм"

	else
		_shopWantSellGoodLabel.caption=""
		_shopCountWantSellGoodLabel.caption=""
	end

	_shopCountWantSellGoodLabel:redraw()
	_shopWantSellGoodLabel:redraw()

	ShowImageOrechanger()
	
end


function InitShop()
	_items=shop.GetItemsToSale()
end

function InitSaleShop()
	_itemsSaleData=shop.GetItemsSaleData()
end

function InitOrechanger()
	_itemsOrechanger=changer.GetAvailableItems()
end

function SetBalanceView(count)
	local str=tostring(count)
	local add=""
	for i=1, #str do
		add=add.." "
	end

	_shopBalanceEmsLabel.caption="Баланс: "..add.." эм ♦"
	_shopBalanceEmsLabel2.caption=str
	_shopBalanceEmsLabel:redraw()
	_shopBalanceEmsLabel2:redraw()
end

function SetBalanceSellView(count)
	local str=tostring(count)
	local add=""
	for i=1, #str do
		add=add.." "
	end

	_shopBalanceEmsSellLabel.caption="Баланс: "..add.." эм ♦"
	_shopBalanceEmsSellLabel2.caption=str
	_shopBalanceEmsSellLabel:redraw()
	_shopBalanceEmsSellLabel2:redraw()
end

function CreateShop()
	local xStart=48
	local xShift=17
	local yStart=1
	
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

	frame=_shopForm:addFrame(32,1,1) 
	frame.W=25
	frame.H=3 
	frame.color= _mainBackgroundColor


	
	label=_shopForm:addLabel(42,2,"Магазин") 
	label.fontColor =0xFFE600
	label.color=_mainBackgroundColor
	
	_shopList=_shopForm:addList(5,8,function()UpdateShopGoodInfo(false) end) --обработка клика в скролле
	_shopList.W=40
	_shopList.H=29
	_shopList.color=0x42414D
	_shopList.selColor=0x2E7183
	_shopList.sfColor=0xffffff
	_shopList.border=1
	
	
	local label = _shopForm:addLabel(5,6,"Выберите товар")
	label.color = _mainBackgroundColor
	label.centered = true
	label.autoSize  = false
	label.W=40

	local label = _shopForm:addLabel(xStart-1,yStart+19,"Наберите кол-во товара")
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
	
	_shopAvailableGoodLabel=_shopForm:addLabel(xStart+xShift,11,"2")
	_shopAvailableGoodLabel.color = _mainBackgroundColor
		
	_shopPriceGoodLabel=_shopForm:addLabel(xStart+xShift,13,"3")
	_shopPriceGoodLabel.color = _mainBackgroundColor

	
	_shopEnoughEmsLabel=_shopForm:addLabel(xStart+xShift,15,"4")
	_shopEnoughEmsLabel.color = _mainBackgroundColor

	_shopBalanceEmsLabel=_shopForm:addLabel(2,2,"")
	_shopBalanceEmsLabel.color = _mainBackgroundColor
	_shopBalanceEmsLabel.fontColor = 0xFFB950
	_shopBalanceEmsLabel2=_shopForm:addLabel(10,2,"")
	_shopBalanceEmsLabel2.color = _mainBackgroundColor
	_shopBalanceEmsLabel2.fontColor = 0x7DFF50
	SetBalanceView(_playerEms)
	
	_shopWantBuyGoodLabel=_shopForm:addLabel(xStart,yStart+37,"6")
	_shopWantBuyGoodLabel.color = _mainBackgroundColor
	_shopWantBuyGoodLabel.centered = true
	_shopWantBuyGoodLabel.autoSize  = false
	_shopWantBuyGoodLabel.W=40
	
	_shopCountWantBuyGoodLabel=_shopForm:addLabel(xStart,yStart+38,"7")
	_shopCountWantBuyGoodLabel.color = _mainBackgroundColor
	_shopCountWantBuyGoodLabel.centered = true
	_shopCountWantBuyGoodLabel.autoSize  = false
	_shopCountWantBuyGoodLabel.W=40
	
	buyButton= _shopForm:addButton(56,yStart+40,"Купить",function() 
		local count = tonumber(_shopSelectedCount)
		if count==nil or count ==0 then return end

		local cost = _shopList.items[_shopList.index].price*count
		if(cost<=_playerEms) then
			shop.GetItems(_shopList.items[_shopList.index],count)
			_playerEms=_playerEms-cost
			ShowShopBuyDialog("Вы успешно купили "..count.." ".._shopList.items[_shopList.index].label,true)
			SetBalanceView(_playerEms)
		else
			ShowShopBuyDialog("Не хватает "..(cost-_playerEms).." эм на покупку "..count.." ".._shopList.items[_shopList.index].label,false) 
		end
	end) 
	buyButton.color=0x5C9A47
	buyButton.W=20
	buyButton.H=3
	
	
	for i=1, 12 do
		local toWrite=keyboard[i]
		local xSpace=8
		local ySpace=7
		button=_shopForm:addButton(56+((i-1)*xSpace%(xSpace*3)),yStart+21+math.floor((i-1)/3)*4,toWrite,function() 
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

function CreateShopSell()
	local xStart=48
	local xShift=17
	
	_shopSellForm=forms.addForm()
	_shopSellForm.W=90
	_shopSellForm.H=45
	_shopSellForm.color=_mainBackgroundColor
	
	backToMain=_shopSellForm:addButton(5,43,"← Назад",OpenMainMenu) 
	backToMain.autoSize=false
	backToMain.centered=true
	backToMain.H=1
	backToMain.W=10
	backToMain.color=_mainBackgroundColor    

	frame=_shopSellForm:addFrame(32,1,1) 
	frame.W=25
	frame.H=3 
	frame.color= _mainBackgroundColor

	label=_shopSellForm:addLabel(37,2,"Пополнение счета") 
	label.fontColor =0xFFE600
	label.color=_mainBackgroundColor
	
	_shopSellList=_shopSellForm:addList(5,10,UpdateShopSellGoodInfo)  --обработка клика в скролле
	_shopSellList.W=40
	_shopSellList.H=29
	_shopSellList.color=0x42414D
	_shopSellList.selColor=0x2E7183
	_shopSellList.sfColor=0xffffff 
	
	local label = _shopSellForm:addLabel(4,5,"Сложите вещи на продажу в левый сундук")
	label.color = _mainBackgroundColor
	label.centered = true
	label.autoSize  = false
	label.W=40

	local label = _shopSellForm:addLabel(4,6,"и выберите товар на продажу из списка")
	label.color = _mainBackgroundColor
	label.centered = true
	label.autoSize  = false
	label.W=40

	local label = _shopSellForm:addLabel(4,7,"если нужно нажмите кнопку “обновить”")
	label.color = _mainBackgroundColor
	label.centered = true
	label.autoSize  = false
	label.W=40

	_shopSelectedSellGoodLabel=_shopSellForm:addLabel(xStart,8,"1")
	_shopSelectedSellGoodLabel.color=0x009999
	_shopSelectedSellGoodLabel.fontColor=0xffd875
	_shopSelectedSellGoodLabel.color = _mainBackgroundColor
	_shopSelectedSellGoodLabel.centered = true
	_shopSelectedSellGoodLabel.autoSize  = false
	_shopSelectedSellGoodLabel.W=40  

	_shopPriceSellGoodLabel=_shopSellForm:addLabel(xStart+xShift,12,"3")
	_shopPriceSellGoodLabel.color = _mainBackgroundColor 
	
	_shopAvailableSellGoodLabel=_shopSellForm:addLabel(xStart+xShift,14,"2")
	_shopAvailableSellGoodLabel.color = _mainBackgroundColor
		
	
	local label=_shopSellForm:addLabel(xStart+xShift,15,"(в левом сундуке)")
	label.color = _mainBackgroundColor 

	_shopBalanceEmsSellLabel=_shopSellForm:addLabel(2,2,"")
	_shopBalanceEmsSellLabel.color = _mainBackgroundColor
	_shopBalanceEmsSellLabel.fontColor = 0xFFB950
	_shopBalanceEmsSellLabel2=_shopSellForm:addLabel(10,2,"")
	_shopBalanceEmsSellLabel2.color = _mainBackgroundColor
	_shopBalanceEmsSellLabel2.fontColor = 0x7DFF50 
	
	
	
	_shopWantSellGoodLabel=_shopSellForm:addLabel(xStart,20,"Я хочу продать 0 шт") 
	_shopWantSellGoodLabel.color = _mainBackgroundColor
	_shopWantSellGoodLabel.centered = true
	_shopWantSellGoodLabel.autoSize  = false
	_shopWantSellGoodLabel.W=40
	_shopWantSellGoodLabel.fontColor=0x33ff66
	
	_shopCountWantSellGoodLabel=_shopSellForm:addLabel(xStart,21,"За 0 эм")
	_shopCountWantSellGoodLabel.color = _mainBackgroundColor
	_shopCountWantSellGoodLabel.centered = true
	_shopCountWantSellGoodLabel.autoSize  = false
	_shopCountWantSellGoodLabel.W=40 
	_shopCountWantSellGoodLabel.fontColor=0x33ff66
	
	buyButton= _shopSellForm:addButton(56,24,"Продать",function()  

		local soldCount=shop.BuyItem(_shopSellList.items[_shopSellList.index])
		if soldCount>0 then
			ShowShopSellDialog("Вы успешно продали "..soldCount.." товаров на сумму "..(soldCount*_shopSellList.items[_shopSellList.index].price).." эм",true)
			_playerEms=_playerEms+soldCount
			SetBalanceSellView(_playerEms) 
		else
			ShowShopSellDialog("В сундуке не хватает ".._shopSellList.items[_shopSellList.index].label,false) 
		end

		UpdateShopSellGoodInfo()
	end) 
	buyButton.color=0x5C9A47
	buyButton.W=23
	buyButton.H=3-->

	buyButton= _shopSellForm:addButton(56,30,"Продать всё что есть",function()  

		local soldCount=0
		local priceAll=0
		for i=1, #_shopSellList.items do
			local iterationCount=shop.BuyItem(_shopSellList.items[i])
			soldCount=soldCount+iterationCount
			priceAll=priceAll+iterationCount*_shopSellList.items[i].price
		end
		
		if soldCount>0 then
			ShowShopSellDialog("Вы успешно продали "..soldCount.." товаров на сумму "..priceAll.." эм",true)
			_playerEms=_playerEms+priceAll
			SetBalanceSellView(_playerEms) 
		else
			ShowShopSellDialog("В сундуке не хватает предметов для продажи",false) 
		end

		UpdateShopSellGoodInfo()
	end) 
	buyButton.color=0x5C9A47
	buyButton.W=23
	buyButton.H=3

	buyButton= _shopSellForm:addButton(56,36,"Обновить",function()  
		UpdateShopSellGoodInfo()
	end) 
	buyButton.color=0x9A9247
	buyButton.W=23
	buyButton.H=3
	
	SetBalanceSellView(_playerEms) 

	SetShopSellList()
end

function CreateOrechanger()
	local xStart=48
	local xShift=17
	
	_orechangerForm=forms.addForm()
	_orechangerForm.W=90
	_orechangerForm.H=45
	_orechangerForm.color=_mainBackgroundColor
	
	backToMain=_orechangerForm:addButton(5,43,"← Назад",OpenMainMenu) 
	backToMain.autoSize=false
	backToMain.centered=true
	backToMain.H=1
	backToMain.W=10
	backToMain.color=_mainBackgroundColor    

	frame=_orechangerForm:addFrame(32,1,1) 
	frame.W=25
	frame.H=3 
	frame.color= _mainBackgroundColor

	label=_orechangerForm:addLabel(37,2,"Обмен руд") 
	label.fontColor =0xFFE600
	label.color=_mainBackgroundColor
	
	_orechangerList=_orechangerForm:addList(5,10,UpdateOrechangerGoodInfo) --> --обработка клика в скролле
	_orechangerList.W=40
	_orechangerList.H=29
	_orechangerList.color=0x42414D
	_orechangerList.selColor=0x2E7183
	_orechangerList.sfColor=0xffffff 
	
	local label = _orechangerForm:addLabel(4,5,"Сложите руды на обмен в левый сундук")
	label.color = _mainBackgroundColor
	label.centered = true
	label.autoSize  = false
	label.W=40

	local label = _orechangerForm:addLabel(4,6,"и выберите их в списке для обмена")
	label.color = _mainBackgroundColor
	label.centered = true
	label.autoSize  = false
	label.W=40

	local label = _orechangerForm:addLabel(4,7,"если нужно нажмите кнопку “обновить”")
	label.color = _mainBackgroundColor
	label.centered = true
	label.autoSize  = false
	label.W=40-->

	_orechangerSelectedGoodLabel=_orechangerForm:addLabel(xStart,8,"1")
	_orechangerSelectedGoodLabel.color=0x009999
	_orechangerSelectedGoodLabel.fontColor=0xffd875
	_orechangerSelectedGoodLabel.color = _mainBackgroundColor
	_orechangerSelectedGoodLabel.centered = true
	_orechangerSelectedGoodLabel.autoSize  = false
	_orechangerSelectedGoodLabel.W=40  

	_orechangerAvailableGoodLabel=_orechangerForm:addLabel(xStart+xShift,13,"У вас есть 10 шт")
	_orechangerAvailableGoodLabel.color = _mainBackgroundColor 
	
	--_shopAvailableSellGoodLabel=_orechangerForm:addLabel(xStart+xShift,14,"2")
	--_shopAvailableSellGoodLabel.color = _mainBackgroundColor
		
	
	local label=_orechangerForm:addLabel(xStart+xShift,15,"(в левом сундуке)")
	label.color = _mainBackgroundColor 
	
	
	--_shopWantSellGoodLabel=_orechangerForm:addLabel(xStart,20,"Я хочу продать 0 шт") 
	--_shopWantSellGoodLabel.color = _mainBackgroundColor
	--_shopWantSellGoodLabel.centered = true
	--_shopWantSellGoodLabel.autoSize  = false
	--_shopWantSellGoodLabel.W=40
	--_shopWantSellGoodLabel.fontColor=0x33ff66
	--
	--_shopCountWantSellGoodLabel=_orechangerForm:addLabel(xStart,21,"За 0 эм")
	--_shopCountWantSellGoodLabel.color = _mainBackgroundColor
	--_shopCountWantSellGoodLabel.centered = true
	--_shopCountWantSellGoodLabel.autoSize  = false
	--_shopCountWantSellGoodLabel.W=40 
	--_shopCountWantSellGoodLabel.fontColor=0x33ff66
	
	buyButton= _orechangerForm:addButton(56,36,"Обменять",function()  

		local soldCount=shop.BuyItem(_shopSellList.items[_shopSellList.index])
		if soldCount>0 then
			ShowShopSellDialog("Вы успешно продали "..soldCount.." товаров на сумму "..(soldCount*_shopSellList.items[_shopSellList.index].price).." эм",true)
			_playerEms=_playerEms+soldCount
			SetBalanceSellView(_playerEms) 
		else
			ShowShopSellDialog("В сундуке не хватает ".._shopSellList.items[_shopSellList.index].label,false) 
		end

		--UpdateShopSellGoodInfo()
	end) 
	buyButton.color=0x5C9A47
	buyButton.W=23
	buyButton.H=3-->

	buyButton= _orechangerForm:addButton(56,42,"Обновить",function()  
		--UpdateShopSellGoodInfo()
	end) 
	buyButton.color=0x9A9247
	buyButton.W=23
	buyButton.H=3


	SetOrechangerList()
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

	toShopButton= _ShopBuyBoughtForm:addButton(20,15,"Купить",function() 
		ActivateShop()		
	end) 
	toShopButton.color=0x626262 
	toShopButton.W=40
	toShopButton.H=3

	toSellButton= _ShopBuyBoughtForm:addButton(20,20,"Пополнить счёт",function() 
		ActivateSellShop()		
	end) 
	toSellButton.color=0x626262 
	toSellButton.W=40
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
	dialogForm.W=70
	dialogForm.H=7
	dialogForm.left=math.floor(10)
	dialogForm.top =math.floor(19)
	_shopDialogLabel=dialogForm:addLabel(3,3,"")
	_shopDialogLabel.autoSize=false
	_shopDialogLabel.centered=true
	_shopDialogLabel.W=64
	_shopDialogLabel.fontColor=0x92DEA3
	_shopDialogLabel.color=0x333145
	btn=dialogForm:addButton(30,5,"Ок",function() 
		_shopForm:setActive() 
		UpdateShopGoodInfo(false)	
	end)
	btn.color=0xC1C1C1
	dialogForm.color=0x333145
end

function ShowShopBuyDialog(string,enough)

	dialogForm:setActive()
	_shopDialogLabel.caption=string
	if enough then
		_shopDialogLabel.fontColor=0x92DEA3
	else
		_shopDialogLabel.fontColor=0xdb7093
	end
	_shopDialogLabel:redraw()
end

function CreateDialogWindowSellShopForm()
	dialogSellForm=forms.addForm()       
	dialogSellForm.border=1
	dialogSellForm.W=70
	dialogSellForm.H=7
	dialogSellForm.left=math.floor(10)
	dialogSellForm.top =math.floor(19)
	_shopDialogSellLabel=dialogSellForm:addLabel(3,3,"")
	_shopDialogSellLabel.autoSize=false
	_shopDialogSellLabel.centered=true
	_shopDialogSellLabel.W=64
	_shopDialogSellLabel.fontColor=0x92DEA3
	_shopDialogSellLabel.color=0x333145
	btn=dialogSellForm:addButton(30,5,"Ок",function() 
		_shopSellForm:setActive() 
		--UpdateShopGoodInfo(false)	 -->Просчет остатка в на продажу
	end)
	btn.color=0xC1C1C1
	dialogSellForm.color=0x333145
end

function ShowShopSellDialog(string,enough)

	dialogSellForm:setActive()
	_shopDialogSellLabel.caption=string
	if enough then
		_shopDialogSellLabel.fontColor=0x92DEA3
	else
		_shopDialogSellLabel.fontColor=0xdb7093
	end
	_shopDialogSellLabel:redraw()
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
shop.Init()-->сделать ввод ид мехов
changer.Init("4396b0e4-7aab-4259-bb72-1cfd8384c59a")
InitOrechanger()
CreateOrechanger()
InitCharger()
CreateShopBuyBought()	
CreateDialogWindowBuyShopForm()
CreateDialogWindowSellShopForm()
InitShop()
InitSaleShop()
CreateButtonExit()
CreateEnterButton()
CreateMainMenu()
CreateShop()
CreateShopSell()
CreateWandCharger()
RunForm()