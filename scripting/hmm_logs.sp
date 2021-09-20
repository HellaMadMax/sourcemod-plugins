#include <sourcemod>
#include <sdktools>
#include <geoip>

public Plugin myinfo = {
	name = "Connect/Disconnect/Chat Log",
	author = "HellaMadMax",
	description = "",
	version = "0.1",
	url = ""
}

public void OnPluginStart() {
	HookEventEx("player_connect_client", OnPlayerConnectClient, EventHookMode_Pre)
	HookEvent("player_connect", OnPlayerConnect, EventHookMode_Pre)
	HookEvent("player_disconnect", OnPlayerDisconnect, EventHookMode_Pre)
	HookEvent("player_changename", OnPlayerNameChange, EventHookMode_Pre)
}

public void OnPlayerConnectClient(Event event, const char[] event_name, bool dontBroadcast) {
	event.BroadcastDisabled = true
}

public void OnPlayerConnect(Event event, const char[] event_name, bool dontBroadcast) {
	event.BroadcastDisabled = true
	char name[MAX_NAME_LENGTH], networkid[32], ip[45], country[45]
	event.GetString("name", name, sizeof(name))
	event.GetString("networkid", networkid, sizeof(networkid))
	event.GetString("address", ip, sizeof(ip))
	if (!GeoipCountry(ip, country, sizeof(country))) {
		country = "Unknown Country"
	}
	if (StrEqual(networkid, "BOT")) {
		return
	}
	LogMessage("Player %s (%s) joined the game from %s [%s]", name, networkid, country, ip)
	PrintToChatAll("\x01Player \x04%s\x01 (\x04%s\x01) joined the game from \x04%s\x01", name, networkid, country)
}

public void OnClientAuthorized(int client, const char[] steamid) {
	if (IsFakeClient(client)) {
		return
	}
	char name[MAX_NAME_LENGTH]
	GetClientName(client, name, sizeof(name))
	LogMessage("Player %s (%s) is authenticated with Steam", name, steamid)
}

public void OnClientPutInServer(int client) {
	if (IsFakeClient(client)) {
		return
	}
	char name[MAX_NAME_LENGTH], steamid[32], ip[45], country[45]
	GetClientName(client, name, sizeof(name))
	GetClientAuthId(client, AuthId_Engine, steamid, sizeof(steamid), false)
	GetClientIP(client, ip, sizeof(ip))
	if (!GeoipCountry(ip, country, sizeof(country))) {
		country = "Unknown Country"
	}
	LogMessage("Player %s (%s) connected from %s [%s]", name, steamid, country, ip)
	PrintToChatAll("\x01Player \x04%s\x01 (\x04%s\x01) connected from \x04%s\x01", name, steamid, country)
}

public void OnPlayerDisconnect(Event event, const char[] event_name, bool dontBroadcast) {
	event.BroadcastDisabled = true
	char name[MAX_NAME_LENGTH], networkid[32], reason[256]
	event.GetString("name", name, sizeof(name))
	event.GetString("networkid", networkid, sizeof(networkid))
	if (StrEqual(networkid, "BOT")) {
		return
	}
	event.GetString("reason", reason, sizeof(reason))
	LogMessage("Player %s (%s) left the game (%s)", name, networkid, reason)
	PrintToChatAll("\x01Player \x04%s\x01 (\x04%s\x01) left the game (\x04%s\x01)", name, networkid, reason)
}

public void OnClientSayCommand_Post(int client, const char[] command, const char[] sArgs) {
	char name[MAX_NAME_LENGTH], steamid[32]
	GetClientName(client, name, sizeof(name))
	GetClientAuthId(client, AuthId_Engine, steamid, sizeof(steamid), false)
	LogMessage("%s (%s) %s '%s'", name, steamid, command, sArgs)
}

public void OnPlayerNameChange(Event event, const char[] event_name, bool dontBroadcast) {
	event.BroadcastDisabled = true
	int client = GetClientOfUserId(event.GetInt("userid"))
	if (client && IsFakeClient(client)) {
		return
	}
	char oldname[MAX_NAME_LENGTH], name[MAX_NAME_LENGTH], steamid[32]
	event.GetString("oldname", oldname, sizeof(oldname))
	event.GetString("newname", name, sizeof(name))
	GetClientAuthId(client, AuthId_Engine, steamid, sizeof(steamid), false)
	LogMessage("Player %s (%s) changed name to %s", oldname, steamid, name)
	PrintToChatAll("\x01Player \x04%s\x01 (\x04%s\x01) changed name to \x04%s\x01", oldname, steamid, name)
}