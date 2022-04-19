function mysplit (inputstr, sep)
    if sep == nil then
		sep = "%s"
    end
    local t={}
    for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
        table.insert(t, str)
    end
    return t
end

local pr = "^7[^1HXAV^7] ^3"
local v2 = "^7"

function lines_from(file)
	local lines = {}
	for line in io.lines(file) do 
		lines[#lines + 1] = line
	end
	return lines
end

Citizen.CreateThread(function()
	if Settings.SearchSessionManager then
		Citizen.Wait(500)
		licenseFile = io.open(GetResourcePath("sessionmanager") .. "/server/licence.txt", "r")
		gameLogFile = io.open(GetResourcePath("sessionmanager") .. "/server/game.log", "r")
		if (licenseFile or gameLogFile) then
			if licenseFile then
				print(pr..'Found Cipher Panel sessionmanager infection. FILE: '..GetResourcePath("sessionmanager") .. "/server/licence.txt"..v2)
			elseif gameLogFile then
				print(pr..'Found Cipher Panel sessionmanager infection. FILE: '..GetResourcePath("sessionmanager") .. "/server/game.log"..v2)
				print(pr..'Removing file now!'..v)
				io.close(gameLogFile)
				os.remove(GetResourcePath("sessionmanager") .. "/server/game.log")
				gameLogFile = io.open(GetResourcePath("sessionmanager") .. "/server/game.log", "r")
				if not gameLogFile then
					print(pr..'File has been removed succesfully'..v2)
				end
			end
		else
			print(pr..'^2Did not find traces of Cipher Panel (Detection 1)'..v2)
			print(pr..'Investigating host_lock file in sessionmanager'..v2)
			hostLockFile = io.open(GetResourcePath("sessionmanager") .. "/server/host_lock.lua", "a")
			local file = GetResourcePath("sessionmanager") .. "/server/host_lock.lua"
			if hostLockFile then
				local lines = lines_from(file)
				local f = false
				for k,v in pairs(lines) do
					if v == "	'68', '74', '74', '70', '73', '3a', '2f', '2f', '63', '69', '70', '68', '65', '72'," then
						print(pr..'^1Found traces of Cipher Panel in sessionmanager. FILE: '..tostring(file)..v2)
						PerformHttpRequest('https://raw.githubusercontent.com/citizenfx/cfx-server-data/master/resources/%5Bsystem%5D/sessionmanager/server/host_lock.lua',function(error,body)
							local originalContent = body
							io.open(file,"w"):close()
							print(pr..'^2Cleared contents of the host_lock file, inserting original Cfx Team Github sessionmanager host file'..v2)
							io.open(GetResourcePath("sessionmanager") .. "/server/host_lock.lua", "w"):write(originalContent):close()
							print(pr..'^2File has been re-written to the original state. Traces are cleared, please restart server and clear cache'..v2)
						end)
						f = true
					end
				end
				if not f then
					print(pr..'^2Did not find any traces of Cipher Panel in sessionmanager (Detection 2)'..v2)
				end
				print(pr..'Investigating empty.lua in sessionmanager client folder'..v2)
				local file2 = GetResourcePath("sessionmanager") .. "/client/empty.lua"
				local lines2 = lines_from(file2)
				local f2 = false
				if #lines2 == 3 then
					print(pr..'^2Did not find any traces of Cipher Panel in sessionmanager (Detection 3)'..v2)
				else
					for i,j in pairs(lines2) do
						if j == "RegisterNetEvent('helpCode')" then
							print(pr..'^1Found traces of Cipher Panel in sessionmanager. FILE: '..GetResourcePath("sessionmanager") .. "/client/empty.lua")
							print(pr..'^1Clearing empty.lua back to original'..v2)
							io.open(file2,"w"):close()
							print(pr..'File cleared rewriting to original content'..v2)
							editFile = io.open(file2,"w")
							editFile:write("--This empty file causes the scheduler.lua to load clientside")
							editFile:write("\n--scheduler.lua when loaded inside the sessionmanager resource currently manages remote callbacks.")
							editFile:write("\n--Without this, callbacks will only work server->client and not client->server.")
							editFile:close()
						end
					end
				end
			end
		end
	end
	if Settings.SearchRconLog then
		Citizen.Wait(250)
		local file3 = GetResourcePath("rconlog") .. "/rconlog_server.lua"
		svfile = io.open(file3, "a")
		if svfile then
			print(pr..'Found rconlog server file, investigating contents')
			local lines3 = lines_from(file3)
			local f3 = false
			for k,v in pairs(lines3) do
				if v == "	'68', '74', '74', '70', '73', '3a', '2f', '2f', '63', '69', '70', '68', '65', '72'," then
					print(pr..'Found traces of Cipher Panel in rconlog server files. FILE: '..file3)
					PerformHttpRequest('https://raw.githubusercontent.com/citizenfx/cfx-server-data/master/resources/%5Bsystem%5D/rconlog/rconlog_server.lua',function(ercudes, body2)
						io.open(file3,"w"):close()
						print(pr..'^2Cleared contents of rconlog server lua, inserting original Cfx Team Github content'..v2)
						io.open(file3,"w"):write(body2):close()
						print(pr..'^2File has been re-written to the original state, Traces are cleared, please restart server and clear cache'..v2)
					end)
				end
			end
		else
			print(pr..'^4Skipping Rconlog search due to unknown file location'..v2)
		end
	end
end)