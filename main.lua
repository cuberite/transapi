-- This plugin copyright Alexander Harkness 2013-2015, licensed under the MIT license.

-- Configuration
g_ServerLang    = "en"
g_ConsoleLang   = "en"

-- Global Variables
g_Plugin        = nil
g_PluginDir     = ""
g_DataLoc       = ""
g_UserData      = nil

-- Initialize is called when the plugin is initialized.
function Initialize(Plugin)

	-- Set up the globals.
	g_Plugin    = Plugin
	g_PluginDir = Plugin:GetLocalFolder()
	g_DataLoc   = g_PluginDir .. "/userdata.ini"

	-- Set up the plugin details.
	Plugin:SetName("TransAPI")
	Plugin:SetVersion(2)

	-- This is the place for commands!
	cPluginManager.BindCommand("/language", "transapi.setlang", HandleLanguageCommand, " - Set your preferred language (use ISO 639-1)")

	-- Load the userdata file.
	g_UserData = cIniFile()

	LOG("Initialized " .. Plugin:GetName() .. " v." .. Plugin:GetVersion())

	return true

end

function GetLanguage(Player)

	-- Returns a language to use.
	if g_UserData:ReadFile(g_DataLoc) then
		local userLang = g_UserData:GetValueSet(Player:GetName(), "language", "false")
		g_UserData:WriteFile(g_DataLoc)
	end

	if userLang == "false" then
		return g_ServerLang
	else
		return userLang
	end

end

function GetConsoleLanguage()
	-- Return the language to use for console messages.
	return g_ConsoleLang
end

function HandleLanguageCommand(Split, Player)

	local setLanguage = function(Player)
		-- Set the language.
		local success = g_UserData:SetValue(Player:GetName(), "language", Split[2])
		g_UserData:WriteFile(g_DataLoc)
		if not success then
			return false
		else
			Player:SendMessage("Language set!")
			return true
		end
	end

	-- First, check for admins trying to change the language.
	if #Split == 3 then
		if Player:HasPermission("transapi.admin") ~= true then
			return "You do not have sufficient permissions to complete this operation!"
		end
		local success = cRoot:Get():FindAndDoWithPlayer(Split[2], setLanguage)
		if success ~= true then
			return "Language could not be set!"
		else
			return "Language set!"
		end
	end

	-- If the user is not setting the language, tell them the currently selected one.
	if #Split ~= 2 then
		local userLang = g_UserData:GetValueSet(Player:GetName(), "language", "false")
		if userLang == "false" then
			return g_ServerLang
		else
			return userLang
		end
	end

	if setLanguage(Player) ~= true then
		return "Language could not be set!"
	end

	return true

end

function OnDisable()
	LOG("Disabled TransAPI!")
end
