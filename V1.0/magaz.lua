local forms=require("forms")         
local component = require("component") 
local gpu = component.gpu
local unicode = require("unicode")

-------------FORMS------------------
	_mainForm = nil
	_menuForm = nil

	_mainBackgroundColor = nil

	_state=""
-----------------------------------
-------------USER------------------
	_playerName="Cmaujluk"

------------BUTTONS----------------
	_btnEnter=nil
----------------------------------

function SetState(state)
	_state=state
end

function Init()
	gpu.setResolution(40,20)
	_mainBackgroundColor=0x181D1E
	_mainForm=forms.addForm()       
	_mainForm.W=80
	_mainForm.H=40
	_mainForm.color=_mainBackgroundColor
	
	SetState("enter_menu")
end

function CreateButtonExit()
	exitForm=forms.addForm()       -- и форму диалога выхода
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

function OpenMainMenu(userName)
	SetState("main_menu")
	_btnEnter:hide() 
	AcrivateMainMenu()
end


function CreateEnterButton()
	_btnEnter =_mainForm:addButton(17,10,"Войти",OpenMainMenu) 
	_btnEnter.color=0x4e7640    
	_btnEnter.autoSize=false    
	_btnEnter.centered=true    
end

function CreateMenuButton(x,y,w,h,label,foo)
	BtnShop=_menuForm:addButton(x,y,label,label,foo) 
	BtnShop.autoSize=false
	BtnShop.centered=true
	BtnShop.H=w
	BtnShop.W=h
	BtnShop.color=0x4e7640      
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
	labels[5]="Лотерея"
	labels[6]="Мехи"

	local shift=5
	for i=1, #labels do
		CreateMenuButton(20,4+shift*i,3, 40,labels[i],function() exitForm:setActive() end)
	end
end

function AcrivateMainMenu()
	gpu.setResolution(80,40)
	_menuForm:setActive()
end

------------------------------------

function RunForm()
	forms.run(_mainForm) 
end

--==============================----
Init()
CreateButtonExit()
CreateEnterButton()
CreateMainMenu()
RunForm()