#include <sourcemod>
#include <ripext>

public Plugin myinfo = {
	name = "Discord Chat Log",
	author = "HellaMadMax",
	description = "",
	version = "0.1",
	url = ""
}

public void OnPluginStart() {
	HookEvent("player_changename", OnPlayerNameChange)
}

public void OnClientSayCommand(int client, const char[] command, const char[] sArgs) {
	char name[MAX_NAME_LENGTH], steamid[32]
	GetClientName(client, name, sizeof(name))
	GetClientAuthId(client, AuthId_Engine, steamid, sizeof(steamid), false)
}

public void OnClientSayCommand_Post(int client, const char[] command, const char[] sArgs) {
	char name[MAX_NAME_LENGTH], steamid[32]
	GetClientName(client, name, sizeof(name))
	GetClientAuthId(client, AuthId_Engine, steamid, sizeof(steamid), false)
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
}