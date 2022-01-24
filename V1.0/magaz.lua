local graffiti=require("graffiti")
local forms=require("forms")      
local charger=require("charger")   
local component = require("component") 
local gpu = component.gpu
local unicode = require("unicode")
local shop = require("shop")
local changer=require("orechanger")
local internet = require("internet")

local _tapeMagaz

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
local _chargingDialogLabel = nil
local _shopDialogSellLabel = nil
local _orechangerDialogLabel = nil
local _shopCountWantSellGoodLabel = nil
local _shopWantSellGoodLabel = nil
local _shopBalanceEmsSellLabel = nil
local _shopBalanceEmsSellLabel2 = nil
local _shopBalanceEmsChangerLabel = nil
local _shopBalanceEmsChangerLabel2 = nil
local _shopPriceSellGoodLabel = nil
local _orechangerAvailableGoodLabel = nil
local _shopAvailableSellGoodLabel = nil
local _orechangerTradeGoodLabel = nil
-------------LISTS---------------
local _shopList=nil
local _shopSellList=nil
local _orechangerList=nil
------------EDITS----------------
local _shopEditField = nil
----------GLOBALVARS-------------
local _shopSelectedCount = ""
local _playerEms=0
local _items={}
local _lastTextToSort=""

local keyboard = {"１","２","３","４","５","６","７","８","９","Ｃ","０","←"}
------------DEBUG----------------


---------------------------------
function VoiceSay(message)
	if message == "shop_buy" then
		_tapeMagaz.seek(-9999999)
		_tapeMagaz.play()
	end
end


		
function SetState(state)
	_state=state
end

function Init()
	gpu.setResolution(40,20)
	_mainBackgroundColor=0x2B2A33
	_mainForm=forms.addForm()       
	_mainForm.W=90
	_mainForm.H=50
	_mainForm.color=_mainBackgroundColor

	SetState("enter_menu")
end

function InitCharger()
	local chargerAddress="fdef5243-78b2-4bc8-ae95-3c4d20ed7a19"
	local getterAddress="63dbdd6d-78a9-4fdd-aecd-22c0eb789bda"
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

function RoundToPlaces(value, divisor)
    return (value * divisor) / divisor
end

function AcrivateMainMenu(obj, name)
		gpu.setResolution(80,40)
		_menuForm:setActive()
end

function OpenEnterMenu()
	gpu.setResolution(140,40)
	_mainForm:setActive()
end

function Login(name)
	local loginName=name
	local result = ""
	
	--_mainGPU.setBackground(_backColor)
	--_mainGPU.setForeground(0xffcc00) 
	--_mainGPU.fill(1,1,w,1," ")
	--_mainGPU.set(1,1,"Соединение с базой данных...")
	
	getdata = internet.request("https://toolbexgames.com/mc_getdata.php?name="..loginName)
	
	for chunk in getdata do
		result = result..chunk
		result = string.gsub(result , "\n", "")
		result = string.gsub(result , " ", "")
		if result ~= "error" then
			_playerEms=tonumber(result)
			_playerName = loginName
			_playerLoggined=true
		else
			result = ""
			setdata = internet.request("https://toolbexgames.com/mc_setdata.php?name="..loginName.."&score=0&spent=0")
			for chunk in setdata do
				result = result..chunk
				result = string.gsub(result , "\n", "")
				result = string.gsub(result , " ", "")
				if result ~= "error" then
					_playerEms=0
					_playerLoggined=true
					_playerName = loginName
				end
			end
		end
	end
end

function OpenMainMenu(obj,userName)
	--_playerName=userName
	SetState("main_menu")
	Login(userName)
	_playerNameLabel.caption=_playerName
	_playerNameLabel:redraw()
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

function ActivateShop(obj,name)
	if(CheckLogin(name)) then
		gpu.setResolution(90,45)
		_shopForm:setActive()
		SetBalanceView(_playerEms)
		_shopList.index=1
		_shopList:redraw()
		UpdateShopGoodInfo(true)
	end
end

function ActivateSellShop(obj,name)
	if(CheckLogin(name)) then
		gpu.setResolution(90,45)
		_shopSellForm:setActive()
		SetBalanceSellView(_playerEms)
		_shopSellList.index=1
		_shopSellList:redraw()
		UpdateShopSellGoodInfo()
	end
end

function ActivateOreChanger(obj,name)
	if(CheckLogin(name)) then
		gpu.setResolution(90,45)
		_orechangerForm:setActive()
		SetBalanceSellView(_playerEms)
		_orechangerList.index=0
		SetOrechangerList()
		UpdateOrechangerGoodInfo()
	end
end


function ActivateWandCharger(obj,name)
	if(CheckLogin(name)) then
		gpu.setResolution(90,45)
		SetBalanceChargerView(_playerEms)
		_wandChargerForm:setActive()
		_chargingLabel.caption=""
		_chargingLabel:redraw()
	end
end

function CreateMainMenu()
	_menuForm=forms.addForm()       
	_menuForm.W=80
	_menuForm.H=40
	_menuForm.color=_mainBackgroundColor

	local labels={}	
	labels[1]="Магазин"	
	labels[2]="Обмен руд 1 к 2"	
	labels[3]="Обмен ресурсы на ресурсы без эмов"	
	labels[4]="Зарядка жезлов таумкрафт"	
	labels[5]="Купить билеты в казино"	
	--labels[6]="Лотерея"	
	--labels[7]="Мехи"
	local methods={} 
	methods[1]=AcrivateShopBuyBoughtMenu 
	methods[2]=ActivateOreChanger 
	methods[3]=ActivateShop	
	methods[4]=ActivateWandCharger	
	methods[5]=ActivateShop	
	--methods[6]=ActivateShop
	--methods[7]=ActivateShop

	local shift=4
	for i=1, #labels do
		CreateButton(_menuForm,20,8+shift*i,3, 40,labels[i],methods[i])
	end
	
	_playerNameLabel=_menuForm:addLabel(3,2,_playerName)
	_playerNameLabel.color=_mainBackgroundColor   
	_playerNameLabel.fontColor=0xFFC34E   

	label=_menuForm:addLabel(3,4,"Баланс")
	label.color=_mainBackgroundColor   
	label.fontColor=0xFFE9BD  
	_menuPlayerEmsLabel=_menuForm:addLabel(3,5,_playerEms.." Эм")
	_menuPlayerEmsLabel.color=_mainBackgroundColor   
	_menuPlayerEmsLabel.fontColor=0xFFE9BD  
	label=_menuForm:addLabel(3,6,"20 коинов") -->
	label.color=_mainBackgroundColor   
	label.fontColor=0xFFE9BD  

	backToEnterMenu=_menuForm:addButton(3,38,"← Назад",OpenEnterMenu) 
	backToEnterMenu.autoSize=false
	backToEnterMenu.centered=true
	backToEnterMenu.H=1
	backToEnterMenu.W=10
	backToEnterMenu.color=_mainBackgroundColor    
end

function ChangeBDValue(name,value, spent)
	local loginName=name
	local result = ""
	if name~=_playerName then return end
	setdata = internet.request("https://toolbexgames.com/mc_setdata.php?name="..loginName.."&score="..value.."&spent="..spent)
	for chunk in setdata do
		result = result..chunk
		result = string.gsub(result , "\n", "")
		result = string.gsub(result , " ", "")
		if result ~= "error" then
			return true
		else
			return false
		end
	end
end

function AddCurrency(value)
    if(value<=0) then return end
	if(ChangeBDValue(_playerName,_playerEms+value,-1)) then
	
		_playerEms=_playerEms+value
	end
end


function SetMainEms()
	_menuPlayerEmsLabel.caption= RoundToPlaces(_playerEms,_playerEms).." Эм"
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
		local price=count*tonumber(_shopList.items[_shopList.index].price)

		if price>tonumber(_playerEms) then
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
	InitOrechanger()
	local data = changer.GetDataItems()

	for i,j in pairs(_itemsOrechanger) do
		data[i][10]=j
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
	if(#_orechangerList.items>0) then
		gpu.setBackground(0x3E3D47)
		gpu.fill(47,10,16,9," ")

		pic=graffiti.load("/home/".._shopSellList.items[_shopSellList.index].img..".png") --debug
		graffiti.draw(pic, 47,21,16,16) --debug картиночки

		gpu.setBackground(0x3E3D47)
		gpu.fill(47,22,16,9," ")

		pic=graffiti.load("/home/".._shopSellList.items[_shopSellList.index].img..".png") --debug
		graffiti.draw(pic, 47,45,16,16) --debug картиночки
	else
		_orechangerForm:redraw()
	end
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


	--_shopSelectedSellGoodLabel.caption =_shopSellList.items[_shopSellList.index].label
	--_shopSelectedSellGoodLabel.centered =true
	--_shopSelectedSellGoodLabel:redraw()
	--
	--_shopPriceSellGoodLabel.caption="Цена продажи: ".._shopSellList.items[_shopSellList.index].price.." эм"
	--_shopPriceSellGoodLabel:redraw()
	--
	--
	--local itemsCount=shop.GetItemSellCount(_shopSellList.items[_shopSellList.index])
	--
	--_shopAvailableSellGoodLabel.caption="У вас есть "..itemsCount.." шт"
	--_shopAvailableSellGoodLabel:redraw()
	--
	--if itemsCount>0 then
	--	_shopWantSellGoodLabel.caption="Я хочу продать "..itemsCount.." шт"
	--	_shopCountWantSellGoodLabel.caption="За "..(itemsCount*_shopSellList.items[_shopSellList.index].price).." эм"
	--
	--else
	--	_shopWantSellGoodLabel.caption=""
	--	_shopCountWantSellGoodLabel.caption=""
	--end
	--
	--_shopCountWantSellGoodLabel:redraw()
	--_shopWantSellGoodLabel:redraw()

	if(#_orechangerList.items>0) then
		_orechangerTradeGoodLabel.caption=(_orechangerList.items[_orechangerList.index][10]*_orechangerList.items[_orechangerList.index][7]).." ".._orechangerList.items[_orechangerList.index][6]
		_orechangerSelectedGoodLabel.caption=_orechangerList.items[_orechangerList.index][3]
		_orechangerAvailableGoodLabel.caption="У вас есть ".._orechangerList.items[_orechangerList.index][10].." шт"
		_orechangerLeftChestLabel:show()
		_orechangerYouWillGetLabel:show()
	else
		_orechangerTradeGoodLabel.caption=""
		_orechangerSelectedGoodLabel.caption=""
		_orechangerAvailableGoodLabel.caption=""
		_orechangerLeftChestLabel:hide()
		_orechangerYouWillGetLabel:hide()
	end

	_orechangerTradeGoodLabel:redraw()
	_orechangerSelectedGoodLabel:redraw()
	_orechangerAvailableGoodLabel:redraw()

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

	local score=tonumber(add)
	if score==nil then score=0 end

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
	local score=tonumber(add)
	if score==nil then score=0 end

	_shopBalanceEmsSellLabel.caption="Баланс: "..add.." эм ♦"
	_shopBalanceEmsSellLabel2.caption=str
	_shopBalanceEmsSellLabel:redraw()
	_shopBalanceEmsSellLabel2:redraw()
end

function SetBalanceChargerView(count)
	local str=tostring(count)
	local add=""
	for i=1, #str do
		add=add.." "
	end

	local score=tonumber(add)
	if score==nil then score=0 end

	_shopBalanceEmsChangerLabel.caption="Баланс: "..add.." эм ♦"
	_shopBalanceEmsChangerLabel2.caption=str
	_shopBalanceEmsChangerLabel:redraw()
	_shopBalanceEmsChangerLabel2:redraw()
end

function ActivateBuyWindow(obj,name)
	if(CheckLogin(name)) then
	
		local count = tonumber(_shopSelectedCount)
		if count==nil or count ==0 then return end

		local cost = tonumber(_shopList.items[_shopList.index].price)*count
		if cost<=_playerEms then
			if ChangeBDValue(name,_playerEms-cost,cost) then
				_playerEms=_playerEms-cost
				shop.GetItems(_shopList.items[_shopList.index],count)
				ShowShopBuyDialog("Вы успешно купили "..count.." ".._shopList.items[_shopList.index].label,true)
				VoiceSay("shop_buy")
				SetBalanceView(_playerEms)
			end
		else
			ShowShopBuyDialog("Не хватает "..(cost-_playerEms).." эм на покупку "..count.." ".._shopList.items[_shopList.index].label,false) 
		end
	end
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
	
	buyButton= _shopForm:addButton(56,yStart+40,"Купить",ActivateBuyWindow) 
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
		
	
	local label =_shopSellForm:addLabel(xStart+xShift,15,"(в левом сундуке)")
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
			AddCurrency(soldCount)

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
			AddCurrency(priceAll)
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

	_orechangerAvailableGoodLabel=_orechangerForm:addLabel(xStart+xShift,14,"У вас есть 10 шт")
	_orechangerAvailableGoodLabel.color = _mainBackgroundColor 
	
	_orechangerTradeGoodLabel=_orechangerForm:addLabel(xStart+xShift,26,"")
	_orechangerTradeGoodLabel.color = _mainBackgroundColor
		
	
	_orechangerLeftChestLabel=_orechangerForm:addLabel(xStart+xShift,15,"(в левом сундуке)")
	_orechangerLeftChestLabel.color = _mainBackgroundColor 
	_orechangerLeftChestLabel:hide()

	_orechangerYouWillGetLabel=_orechangerForm:addLabel(xStart+xShift,25,"Вы получите:")
	_orechangerYouWillGetLabel.color = _mainBackgroundColor 
	_orechangerYouWillGetLabel:hide()
	
	buyButton= _orechangerForm:addButton(56,36,"Обменять",function(obj,name)
	if(CheckLogin(name)) then  
		if changer.CanChange(_orechangerList.items[_orechangerList.index][8],_orechangerList.items[_orechangerList.index][10]) then

			local soldCount=changer.Change(_orechangerList.items[_orechangerList.index][8],_orechangerList.items[_orechangerList.index][10])
			if soldCount>0 then
				ShowOrechangerDialog("Вы успешно обменяли ".._orechangerList.items[_orechangerList.index][10].." ".._orechangerList.items[_orechangerList.index][3],true)
			end
		else
			ShowOrechangerDialog("В сундуке не хватает ".._orechangerList.items[_orechangerList.index][3],false) 
		end
		SetOrechangerList()
	end
	end) 
	buyButton.color=0x5C9A47
	buyButton.W=23
	buyButton.H=3

	buyButton= _orechangerForm:addButton(56,42,"Обновить",function()  
		SetOrechangerList()
		_orechangerList.index=0
		UpdateOrechangerGoodInfo()
	end) 
	buyButton.color=0x9A9247
	buyButton.W=23
	buyButton.H=3


	SetOrechangerList()
end

function AcrivateShopBuyBoughtMenu(obj,name)
	if(CheckLogin(name)) then
		gpu.setResolution(80,40)
		_ShopBuyBoughtForm:setActive()
	end
end

function CreateShopBuyBought()	
	_ShopBuyBoughtForm=forms.addForm()
	_ShopBuyBoughtForm.W=80
	_ShopBuyBoughtForm.H=40
	_ShopBuyBoughtForm.color=_mainBackgroundColor

	toShopButton= _ShopBuyBoughtForm:addButton(20,15,"Купить",	ActivateShop) 
	toShopButton.color=0x626262 
	toShopButton.W=40
	toShopButton.H=3

	toSellButton= _ShopBuyBoughtForm:addButton(20,20,"Пополнить счёт",ActivateSellShop) 
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

function CreateDialogWindowChargingForm()
	dialogChargingForm=forms.addForm()       
	dialogChargingForm.border=1
	dialogChargingForm.W=70
	dialogChargingForm.H=7
	dialogChargingForm.left=math.floor(10)
	dialogChargingForm.top =math.floor(19)
	_chargingDialogLabel=dialogChargingForm:addLabel(3,3,"")
	_chargingDialogLabel.autoSize=false
	_chargingDialogLabel.centered=true
	_chargingDialogLabel.W=64
	_chargingDialogLabel.fontColor=0x92DEA3
	_chargingDialogLabel.color=0x333145
	btn=dialogChargingForm:addButton(30,5,"Ок",function() 
		_wandChargerForm:setActive() 
	end)
	btn.color=0xC1C1C1
	dialogChargingForm.color=0x333145
end

function ShowChargingDialog(string,enough)

	dialogChargingForm:setActive()
	_chargingDialogLabel.caption=string
	if enough then
		_chargingDialogLabel.fontColor=0x92DEA3
	else
		_chargingDialogLabel.fontColor=0xdb7093
	end
	_chargingDialogLabel:redraw()
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



function CreateDialogWindowOrechangerForm()
	dialogOrechangerForm=forms.addForm()       
	dialogOrechangerForm.border=1
	dialogOrechangerForm.W=70
	dialogOrechangerForm.H=7
	dialogOrechangerForm.left=math.floor(10)
	dialogOrechangerForm.top =math.floor(19)
	_orechangerDialogLabel=dialogOrechangerForm:addLabel(3,3,"")
	_orechangerDialogLabel.autoSize=false
	_orechangerDialogLabel.centered=true
	_orechangerDialogLabel.W=64
	_orechangerDialogLabel.fontColor=0x92DEA3
	_orechangerDialogLabel.color=0x333145
	btn=dialogOrechangerForm:addButton(30,5,"Ок",function() 
		_orechangerForm:setActive() 
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

function ShowOrechangerDialog(string,enough)
	dialogOrechangerForm:setActive()
	_orechangerDialogLabel.caption=string
	if enough then
		_orechangerDialogLabel.fontColor=0x92DEA3
	else
		_orechangerDialogLabel.fontColor=0xdb7093
	end
	_orechangerDialogLabel:redraw()
end


function ShowChargingStatus(str)
	_chargingLabel.caption="Статус: "..str
	_chargingLabel:redraw()
end

function ChargingWand(obj,name)
	if(CheckLogin(name)) then

		if charger.HasWand() then
			if _playerEms>=15 then
				if(ChangeBDValue(_playerName,_playerEms-15,15)) then
					ShowChargingStatus("Зарядка жезла...") 
					_playerEms=_playerEms-15
					SetBalanceChargerView(_playerEms)
					local status = charger.StartChargingWand()
					ShowChargingStatus(status) 
				end
			else
				ShowChargingDialog("Не хватает "..(15-_playerEms).." эм на зарядку жезла",false) 
			end
		else
			ShowChargingDialog("Жезл в левом сундуке не обнаружен",false) 
		end
		
	end	
end


function CreateWandCharger()
	_wandChargerForm = forms.addForm()
	_wandChargerForm.W=90
	_wandChargerForm.H=45
	_wandChargerForm.color=_mainBackgroundColor
	
	backToMain=_wandChargerForm:addButton(5,43,"← Назад",OpenMainMenu) 
	backToMain.autoSize=false
	backToMain.centered=true
	backToMain.H=1
	backToMain.W=10
	backToMain.color=_mainBackgroundColor  
	
	frame=_wandChargerForm:addFrame(33,1,1) frame.W=22 frame.H=3 frame.color= _mainBackgroundColor
	
	label=_wandChargerForm:addLabel(39,2,"Зарядка жезлов") label.fontColor =0xFFE600 label.color=_mainBackgroundColor
	
	_chargingLabel=_wandChargerForm:addLabel(20,30,"")
	_chargingLabel.fontColor =0xFFE600 
	_chargingLabel.color=_mainBackgroundColor
	_chargingLabel.autoSize=false
	_chargingLabel.centered=true
	_chargingLabel.W=50

	local label=_wandChargerForm:addLabel(15,10,"Зарядка стоит 15 эм вне зависимости от жезла") 
	label.color=_mainBackgroundColor
	label.centered = true
	label.autoSize  = false
	label.W=60 

	label=_wandChargerForm:addLabel(15,12,"1. Положите жезл в левый сундук") 
	label.color=_mainBackgroundColor
	label.centered = true
	label.autoSize  = false
	label.W=60  

	label=_wandChargerForm:addLabel(15,13,"2. Нажмите кнопку 'Зарядить мою палку'") 
	label.color=_mainBackgroundColor
	label.centered = true
	label.autoSize  = false
	label.W=60  

	label=_wandChargerForm:addLabel(15,14,"3. Дождитесь зарядки, на экране отображен статус") 
	label.color=_mainBackgroundColor
	label.centered = true
	label.autoSize  = false
	label.W=60  

	label=_wandChargerForm:addLabel(15,15,"4. Заберите заряженный жезл в правом сундуке") 
	label.color=_mainBackgroundColor
	label.centered = true
	label.autoSize  = false
	label.W=60  

	label=_wandChargerForm:addLabel(15,17,"Если не хватает эмов, пополните через кнопку сверху") 
	label.color=_mainBackgroundColor
	label.centered = true
	label.autoSize  = false
	label.W=60  

	backToMain=_wandChargerForm:addButton(2,4,"Пополнить",ActivateSellShop) 
	backToMain.autoSize=false
	backToMain.centered=true
	backToMain.H=1
	backToMain.W=10
	backToMain.color=_mainBackgroundColor  

	_shopBalanceEmsChangerLabel=_wandChargerForm:addLabel(2,2,"")
	_shopBalanceEmsChangerLabel.color = _mainBackgroundColor
	_shopBalanceEmsChangerLabel.fontColor = 0xFFB950
	_shopBalanceEmsChangerLabel2=_wandChargerForm:addLabel(10,2,"")
	_shopBalanceEmsChangerLabel2.color = _mainBackgroundColor
	_shopBalanceEmsChangerLabel2.fontColor = 0x7DFF50 

	SetBalanceChargerView(_playerEms)
	
	charge=_wandChargerForm:addButton(20,40,"Зарядить мою палку",ChargingWand) 

	charge.autoSize=false
	charge.centered=true
	charge.H=3
	charge.W=50
	charge.color=0x5C9A47
end

function CheckMessages(_,_,_,_,_,message)
	if message == "stop" or message == "shutdown" then
		forms.stop()
	end
end

function InitRemoveControl()
	Event1=_mainForm:addEvent("modem_message", CheckMessages)
end


------------------------------------
function RunForm()
	forms.run(_mainForm) 
end

function CheckLogin(name)
	if(_playerName~=name) then 
		OpenEnterMenu()
		return false
	end
	return true
end

------------------------------------
Init()
_tapeMagaz = component.proxy("540ad9de-fcb1-481a-978e-3ab5c3e51cbe")
shop.Init("63dbdd6d-78a9-4fdd-aecd-22c0eb789bda")
changer.Init("63dbdd6d-78a9-4fdd-aecd-22c0eb789bda")
InitOrechanger()
CreateOrechanger()
InitCharger()
CreateShopBuyBought()	
CreateDialogWindowBuyShopForm()
CreateDialogWindowChargingForm()
CreateDialogWindowSellShopForm()
CreateDialogWindowOrechangerForm()
InitShop()
InitSaleShop()
CreateButtonExit()
CreateEnterButton()
CreateMainMenu()
CreateShop()
CreateShopSell()
CreateWandCharger()
InitRemoveControl()
RunForm()