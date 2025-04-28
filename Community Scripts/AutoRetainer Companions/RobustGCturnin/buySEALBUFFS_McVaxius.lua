--uldah
--you know what to do to change it to other cities :debug.debug

FirstRun = 1
chars = {
 "char name@server",
 "char name@server",
 "char name@server",
 "char name@server",
 "char name@server"
}

for _, char in ipairs(chars) do
 if FirstRun==0 then
	yield("/echo "..char)
	yield("/ays relog " ..char)
	yield("<wait.85.0>")
	--yield("/waitaddon NowLoading <maxwait.15>")
	yield("/waitaddon NamePlate <maxwait.600><wait.5>")
 end
FirstRun = 0
 --yield("/waitaddon NowLoading <maxwait.15>")
 yield("/waitaddon NamePlate <maxwait.600><wait.5>")

 yield("/tp Ul'dah - Steps of Nald <wait.8>")
 yield("/waitaddon NamePlate <wait.1>")
 yield("<wait.10.0>")
 yield("/target Aetheryte <wait.1>")
 yield("/lockon")
 yield("/automove")
 yield("/send E")
 yield("<wait.0.5>")
 yield("/send E")
 yield("<wait.0.5>")
 yield("/send E")
 yield("<wait.0.5>")
 yield("/send E")
 yield("<wait.0.5>")
 yield("/send E")
 yield("<wait.0.5>")
 yield("/interact")
 yield("/wait 1")
 yield("/callback SelectString true 0")
 yield("/callback TelepotTown false 11 2u")
 yield("/callback TelepotTown false 11 2u")

 yield("<wait.5>")
 yield("/ac Sprint")
 yield("/ac Sprint")
 yield("/ac Sprint")
 yield("/visland execonce GCuld")
 --simple tweaks
 --/tweaks
 --auto equip -> alias /equipguud
 yield("/equipguud")
 yield("/wait 3")
 while IsMoving() == true do
  yield("/wait 1")
 end
 yield("/echo movement stopped - time for GC purchases")
--yield("/waitaddon SelectString <maxwait.120>")
 yield("/visland stop")
 
 --now we buy the buff
	yield("<wait.5>")
	yield("/target OIC Quartermaster")
	yield("/lockon")
	yield("/automove")
	yield("<wait.5>")
	yield("/send NUMPAD0")
	yield("/callback SelectString true 0 <wait.1>")
	yield("/callback SelectString true 0 <wait.1>")

buycount = 0
while (buycount < 15) do
	yield("/callback FreeCompanyExchange false 2 22u")
	yield("<wait.2>")
	buycount = buycount + 1
end

	yield("/send ESCAPE <wait.1.5>")
	yield("/send ESCAPE <wait.1.5>")
	yield("/send ESCAPE <wait.1.5>")
	yield("<wait.5>")


--added 5 second wait here because sometimes they get stuck. altho its been biological life form so far....
yield("<wait.5>")
yield("/tp Estate Hall")
yield("<wait.1>")
--yield("/waitaddon Nowloading <maxwait.15>")
yield("<wait.15>")
yield("/waitaddon NamePlate <maxwait.600><wait.5>")

--walk back to entrance properly
local islanders = {
	['char name'] = '/visland execonce FChalicarnassus',
	['char name'] = '/visland execonce FCmaduin',
	['char name'] = '/visland execonce FCmarilith',
	['char name'] = '/visland execonce FCseraph'
}

if islanders[GetCharacterName()] then
  yield(islanders[GetCharacterName()])
end
 yield("/wait 3")
 while IsMoving() == true do
  yield("/wait 1")
 end
 yield("/echo movement stopped - time for GC turn ins")
yield("/visland stop")
end

yield("/ays multi")
