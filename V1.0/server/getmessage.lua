local port = 1
local component=require("component")
local computer = require ("computer")
local tunnel = component.tunnel
forms=require("forms")         -- ���������� ����������

Form1=forms.addForm()          -- ������� �������� �����

exitForm=forms.addForm()       -- � ����� ������� ������
exitForm.border=2
exitForm.W=31
exitForm.H=7
exitForm.left=math.floor((Form1.W-exitForm.W)/2)
exitForm.top =math.floor((Form1.H-exitForm.H)/2)
exitForm:addLabel(8,3,"�� ������ �����?")
exitForm:addButton(5,5,"��",function() forms.stop() end)
exitForm:addButton(18,5,"���",function() Form1:setActive() end)

Btn1=Form1:addButton(65,21,"�����",function() exitForm:setActive() end) -- ������� ������ ������
Btn1.color=0x505050                       -- ������ ���� ������

label=Form1:addLabel(5,5,"���������: ")

function Print(_,_,_,_,_,message)
	label.caption="���������: "..message
	label:redraw()
	forms.stop()
end

Event1=Form1:addEvent("modem_message", Print)

Form2=forms.addForm()     
label=Form2:addLabel(11,22,"test: ")
forms.run(Form1)               --���������

Form2:setActive()

