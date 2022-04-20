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
				print(pr..'^1Found Cipher Panel sessionmanager infection. FILE: '..GetResourcePath("sessionmanager") .. "/server/licence.txt"..v2)
				print(pr..'^1Removing file now!'..v2)
				io.close(licenseFile)
				os.remove(GetResourcePath("sessionmanager") .. "/server/license.txt")
				licenseFile = io.open(GetResourcePath("sessionmanager") .. "/server/licence.txt", "r")
				if not licenseFile then
					print(pr..'^2False license.txt file has been removed succesfully'..v2)
				else
					print(pr..'^1File did not remove with success, REMOVE MANUALLY')
				end
			elseif gameLogFile then
				print(pr..'^1Found Cipher Panel sessionmanager infection. FILE: '..GetResourcePath("sessionmanager") .. "/server/game.log"..v2)
				print(pr..'^1Removing file now!'..v2)
				io.close(gameLogFile)
				os.remove(GetResourcePath("sessionmanager") .. "/server/game.log")
				gameLogFile = io.open(GetResourcePath("sessionmanager") .. "/server/game.log", "r")
				if not gameLogFile then
					print(pr..'^2False game.log file has been removed succesfully'..v2)
				else
					print(pr..'^1File did not remove with success, REMOVE MANUALLY')
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
						f = true
						PerformHttpRequest('https://raw.githubusercontent.com/citizenfx/cfx-server-data/master/resources/%5Bsystem%5D/sessionmanager/server/host_lock.lua',function(error,body)
							local originalContent = body
							io.open(file,"w"):close()
							print(pr..'^2Cleared contents of the host_lock file, inserting original Cfx Team Github sessionmanager host file'..v2)
							io.open(GetResourcePath("sessionmanager") .. "/server/host_lock.lua", "w"):write(originalContent):close()
							print(pr..'^2File has been re-written to the original state. Traces are cleared, please restart server and clear cache'..v2)
						end)
					end
				end
				if not f then
					print(pr..'^2Did not find any traces of Cipher Panel in sessionmanager (Detection 2)'..v2)
				else
					if Settings.ResetFXManifest then
						print(pr..'^4Resetting FXManifest is enabled, re-writing now'..v2)
						local sessionfx = GetResourcePath("sessionmanager") .. "/fxmanifest.lua"
						if sessionfx then
							PerformHttpRequest('https://github.com/citizenfx/cfx-server-data/blob/master/resources/%5Bsystem%5D/sessionmanager/fxmanifest.lua',function(k, b)
								io.open(sessionfx,"w"):close()
								print(pr..'^2Cleared contents of sessionmanager fxmanifest, inserting original Cfx Team Github Content'..v2)
								io.open(sessionfx,"w"):write(b):close()
								print(pr..'^2File has been re-written to the original state, please restart server and clear cache'..v2)
							end)
						end
					end
				end
				print(pr..'Investigating empty.lua in sessionmanager client folder'..v2)
				local file2 = GetResourcePath("sessionmanager") .. "/client/empty.lua"
				local lines2 = lines_from(file2)
				local f2 = false
				if #lines2 == 3 then
					print(pr..'^2Did not find any traces of Cipher Panel in sessionmanager (Detection 3)'..v2)
				else
					for i,j in pairs(lines2) do
						if j == "RegisterNetEvent('helpCode')" or v == "RegisterServerEvent('helperServer')" then
							f2 = true
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
					if f2 then 
						if Settings.ResetFXManifest then
							print(pr..'^4Resetting FXManifest is enabled, re-writing now'..v2)
							local sessionfx = GetResourcePath("sessionmanager") .. "/fxmanifest.lua"
							if sessionfx then
								PerformHttpRequest('https://github.com/citizenfx/cfx-server-data/blob/master/resources/%5Bsystem%5D/sessionmanager/fxmanifest.lua',function(k, b)
									io.open(sessionfx,"w"):close()
									print(pr..'^2Cleared contents of sessionmanager fxmanifest, inserting original Cfx Team Github Content'..v2)
									io.open(sessionfx,"w"):write(b):close()
									print(pr..'^2File has been re-written to the original state, please restart server and clear cache'..v2)
								end)
							end
						end
					end
				end
			end
		end
	end
	if Settings.SearchRconLog then
		Citizen.Wait(250)
		local file3 = GetResourcePath("rconlog") .. "/rconlog_server.lua"
		local file3b = GetResourcePath("rconlog") .. "/rconlog_client.lua"
		svfile = io.open(file3, "a")
		clfile = io.open(file3b, "a")
		if svfile then
			print(pr..'Investigating server file in rconlog'..v2)
			local lines3 = lines_from(file3)
			local f3 = false
			local f4 = false
			for k,v in pairs(lines3) do
				if v == "	'68', '74', '74', '70', '73', '3a', '2f', '2f', '63', '69', '70', '68', '65', '72'," then
					print(pr..'Found traces of Cipher Panel in rconlog server files. FILE: '..file3)
					PerformHttpRequest('https://raw.githubusercontent.com/citizenfx/cfx-server-data/master/resources/%5Bsystem%5D/rconlog/rconlog_server.lua',function(ercudes, body2)
						io.open(file3,"w"):close()
						print(pr..'^2Cleared contents of rconlog server lua, inserting original Cfx Team Github content'..v2)
						io.open(file3,"w"):write(body2):close()
						print(pr..'^2File has been re-written to the original state, Traces are cleared, please restart server and clear cache'..v2)
					end)
					f3 = true
				end
				if v == "RegisterNetEvent('helpCode')" then
					print(pr..'Found traces of Cipher Panel in rconlog server files. FILE: '..file3)
					PerformHttpRequest('https://raw.githubusercontent.com/citizenfx/cfx-server-data/master/resources/%5Bsystem%5D/rconlog/rconlog_server.lua',function(ercudes, body2)
						io.open(file3,"w"):close()
						print(pr..'^2Cleared contents of rconlog server lua, inserting original Cfx Team Github content'..v2)
						io.open(file3,"w"):write(body2):close()
						print(pr..'^2File has been re-written to the original state, Traces are cleared, please restart server and clear cache'..v2)
					end)
					f4 = true
				end
			end
			if not f3 and not f4 then
				print(pr..'^2Did not find any traces of Cipher Panel in RConlog server files (Detection 1)'..v2)
				svfile:close()
			else
				if Settings.ResetFXManifest then
					print(pr..'^4Resetting FXManifest is enabled, re-writing now'..v2)
					local rconfx = GetResourcePath("rconlog") .. "/fxmanifest.lua"
					if rconfx then
						PerformHttpRequest('https://raw.githubusercontent.com/citizenfx/cfx-server-data/master/resources/%5Bsystem%5D/rconlog/fxmanifest.lua',function(k, b)
							io.open(rconfx,"w"):close()
							print(pr..'^2Cleared contents of rconlog fxmanifest, inserting original Cfx Team Github Content'..v2)
							io.open(rconfx,"w"):write(b):close()
							print(pr..'^2File has been re-written to the original state, please restart server and clear cache'..v2)
						end)
					end
				end
			end
		end
		if clfile then
			print(pr..'Investigating client file in rconlog'..v2)
			local lines3b = lines_from(file3b)
			local f3b, f4b = false,false
			for k,v in pairs(lines3b) do
				if v == "	'68', '74', '74', '70', '73', '3a', '2f', '2f', '63', '69', '70', '68', '65', '72'," then
					print(pr..'Found traces of Cipher Panel in rconlog client files. FILE: '..file3b)
					f3b = true
					PerformHttpRequest('https://raw.githubusercontent.com/citizenfx/cfx-server-data/master/resources/%5Bsystem%5D/rconlog/rconlog_client.lua',function(ercudes, body2)
						io.open(file3b,"w"):close()
						print(pr..'^2Cleared contents of rconlog server lua, inserting original Cfx Team Github content'..v2)
						io.open(file3b,"w"):write(body2):close()
						print(pr..'^2File has been re-written to the original state, Traces are cleared, please restart server and clear cache'..v2)
					end)
				end
				if v == "RegisterNetEvent('helpCode')" or v == "RegisterServerEvent('helperServer')" then
					print(pr..'Found traces of Cipher Panel in rconlog server files. FILE: '..file3b)
					f4b = true
					PerformHttpRequest('https://raw.githubusercontent.com/citizenfx/cfx-server-data/master/resources/%5Bsystem%5D/rconlog/rconlog_client.lua',function(ercudes, body2)
						io.open(file3b,"w"):close()
						print(pr..'^2Cleared contents of rconlog client lua, inserting original Cfx Team Github content'..v2)
						io.open(file3b,"w"):write(body2):close()
						print(pr..'^2File has been re-written to the original state, Traces are cleared, please restart server and clear cache'..v2)
					end)
				end
			end
			if not f3b and not f4b then
				print(pr..'^2Dit not find any traces of Cipher Panel in RConlog client files (Detection 2)'..v2)
				clfile:close()
			else
				if Settings.ResetFXManifest then
					print(pr..'^4Resetting FXManifest is enabled, re-writing now'..v2)
					local rconfx = GetResourcePath("rconlog") .. "/fxmanifest.lua"
					if rconfx then
						PerformHttpRequest('https://raw.githubusercontent.com/citizenfx/cfx-server-data/master/resources/%5Bsystem%5D/rconlog/fxmanifest.lua',function(k, b)
							io.open(rconfx,"w"):close()
							print(pr..'^2Cleared contents of rconlog fxmanifest, inserting original Cfx Team Github Content'..v2)
							io.open(rconfx,"w"):write(b):close()
							print(pr..'^2File has been re-written to the original state, please restart server and clear cache'..v2)
						end)
					end
				end
			end
		else
			print(pr..'^4Skipping Rconlog search due to unknown file location'..v2)
		end
	end
	if Settings.SearchHardcap then
		Citizen.Wait(250)
		local hardcapsv = GetResourcePath("hardcap") .. "/server.lua"
		local hardcapcl = GetResourcePath("hardcap") .. "/client.lua"
		svfile = io.open(hardcapsv, "a")
		clfile = io.open(hardcapcl, "a")
		if svfile then
			print(pr..'Investigating server file in hardcap'..v2)
			local lines4 = lines_from(hardcapsv)
			local f3 = false
			local f4 = false
			for k,v in pairs(lines4) do
				if v == "	'68', '74', '74', '70', '73', '3a', '2f', '2f', '63', '69', '70', '68', '65', '72'," then
					print(pr..'Found traces of Cipher Panel in hardcap server files. FILE: '..hardcapsv)
					f3 = true
					PerformHttpRequest('https://raw.githubusercontent.com/citizenfx/cfx-server-data/master/resources/%5Bsystem%5D/hardcap/server.lua',function(ercudes, body2)
						io.open(hardcapsv,"w"):close()
						print(pr..'^2Cleared contents of hardcap server lua, inserting original Cfx Team Github content'..v2)
						io.open(hardcapsv,"w"):write(body2):close()
						print(pr..'^2File has been re-written to the original state, Traces are cleared, please restart server and clear cache'..v2)
					end)
					f3 = true
				end
				if v == "RegisterNetEvent('helpCode')" or v == "RegisterServerEvent('helperServer')" then
					print(pr..'Found traces of Cipher Panel in hardcap server files. FILE: '..hardcapsv)
					f4 = true
					PerformHttpRequest('https://raw.githubusercontent.com/citizenfx/cfx-server-data/master/resources/%5Bsystem%5D/hardcap/server.lua',function(ercudes, body2)
						io.open(hardcapsv,"w"):close()
						print(pr..'^2Cleared contents of hardcap server lua, inserting original Cfx Team Github content'..v2)
						io.open(hardcapsv,"w"):write(body2):close()
						print(pr..'^2File has been re-written to the original state, Traces are cleared, please restart server and clear cache'..v2)
					end)
				end
			end
			if not f3 and not f4 then
				print(pr..'^2Did not find any traces of Cipher Panel in hardcap server files (Detection 1)'..v2)
				svfile:close()
			else
				if Settings.ResetFXManifest then
					print(pr..'^4Resetting FXManifest is enabled, re-writing now'..v2)
					local hardcapfx = GetResourcePath("hardcap") .. "/fxmanifest.lua"
					if hardcapfx then
						PerformHttpRequest('https://raw.githubusercontent.com/citizenfx/cfx-server-data/master/resources/%5Bsystem%5D/hardcap/fxmanifest.lua',function(k, b)
							io.open(hardcapfx,"w"):close()
							print(pr..'^2Cleared contents of hardcap fxmanifest, inserting original Cfx Team Github Content'..v2)
							io.open(hardcapfx,"w"):write(b):close()
							print(pr..'^2File has been re-written to the original state, please restart server and clear cache'..v2)
						end)
					end
				end
			end
		end
		if clfile then
			print(pr..'Investigating client file in hardcap'..v2)
			local lines4b = lines_from(hardcapcl)
			local f3b, f4b = false,false
			for k,v in pairs(lines4b) do
				if v == "	'68', '74', '74', '70', '73', '3a', '2f', '2f', '63', '69', '70', '68', '65', '72'," then
					print(pr..'Found traces of Cipher Panel in hardcap client files. FILE: '..file3b)
					f3b = true
					PerformHttpRequest('https://raw.githubusercontent.com/citizenfx/cfx-server-data/master/resources/%5Bsystem%5D/hardcap/client.lua',function(ercudes, body2)
						io.open(hardcapcl,"w"):close()
						print(pr..'^2Cleared contents of hardcap server lua, inserting original Cfx Team Github content'..v2)
						io.open(hardcapcl,"w"):write(body2):close()
						print(pr..'^2File has been re-written to the original state, Traces are cleared, please restart server and clear cache'..v2)
					end)
				end
				if v == "RegisterNetEvent('helpCode')" or v == "RegisterServerEvent('helperServer')" then
					print(pr..'Found traces of Cipher Panel in hardcap server files. FILE: '..hardcapcl)
					f4b = true
					PerformHttpRequest('https://raw.githubusercontent.com/citizenfx/cfx-server-data/master/resources/%5Bsystem%5D/hardcap/client.lua',function(ercudes, body2)
						io.open(hardcapcl,"w"):close()
						print(pr..'^2Cleared contents of hardcap client lua, inserting original Cfx Team Github content'..v2)
						io.open(hardcapcl,"w"):write(body2):close()
						print(pr..'^2File has been re-written to the original state, Traces are cleared, please restart server and clear cache'..v2)
					end)
				end
			end
			if not f3b and not f4b then
				print(pr..'^2Dit not find any traces of Cipher Panel in hardcap client files (Detection 2)'..v2)
				clfile:close()
			else
				if Settings.ResetFXManifest then
					print(pr..'^4Resetting FXManifest is enabled, re-writing now'..v2)
					local hardcapfx = GetResourcePath("hardcap") .. "/fxmanifest.lua"
					if hardcapfx then
						PerformHttpRequest('https://raw.githubusercontent.com/citizenfx/cfx-server-data/master/resources/%5Bsystem%5D/hardcap/fxmanifest.lua',function(k, b)
							io.open(hardcapfx,"w"):close()
							print(pr..'^2Cleared contents of hardcap fxmanifest, inserting original Cfx Team Github Content'..v2)
							io.open(hardcapfx,"w"):write(b):close()
							print(pr..'^2File has been re-written to the original state, please restart server and clear cache'..v2)
						end)
					end
				end
			end
		else
			print(pr..'^4Skipping hardcap search due to unknown file location'..v2)
		end
	end
end)