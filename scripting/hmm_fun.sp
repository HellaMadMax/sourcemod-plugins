#include <sourcemod>
#include <sdktools>
#include <adminmenu>

public Plugin myinfo = {
	name = "HMM Fun Commands",
	author = "HellaMadMax",
	description = "",
	version = "0.1",
	url = ""
}

enum struct PlayerState {
	bool setGod
	float setSpeed
}
PlayerState playerstate[MAXPLAYERS+1]

TopMenu hTopMenu
#include "hmm_fun/god.sp"
#include "hmm_fun/hp.sp"
#include "hmm_fun/speed.sp"
#include "hmm_fun/colour.sp"
#include "hmm_fun/other.sp"

ConVar g_SpeedScale
ConVar g_GodAll
public void OnPluginStart() {
	LoadTranslations("common.phrases")
	LoadTranslations("hmm.phrases")
	g_SpeedScale = CreateConVar("hmm_speedscale", "1", "Speed scale for all players", 0, true, 0.01, true, 99.99)
	g_SpeedScale.AddChangeHook(OnSpeedScaleChange)
	g_GodAll = CreateConVar("hmm_god", "0", "God all players", 0, true, 0.0, true, 1.0)
	g_GodAll.AddChangeHook(OnGodAllChange)
	RegAdminCmd("sm_god", Command_God, ADMFLAG_SLAY, "sm_god <#userid|name>")
	RegAdminCmd("sm_ungod", Command_UnGod, ADMFLAG_SLAY, "sm_ungod <#userid|name>")
	RegAdminCmd("sm_hp", Command_HP, ADMFLAG_SLAY, "sm_hp <#userid|name> [1-2147483647]")
	RegAdminCmd("sm_speed", Command_Speed, ADMFLAG_SLAY, "sm_speed <#userid|name> [0.01-99.99]")
	RegAdminCmd("sm_colour", Command_Colour, ADMFLAG_SLAY, "sm_colour <#userid|name> [Red:0-255] [Green:0-255] [Blue:0-255] [Alpha:0-255]")
	RegAdminCmd("sm_color", Command_Colour, ADMFLAG_SLAY, "sm_color <#userid|name> [Red:0-255] [Green:0-255] [Blue:0-255] [Alpha:0-255]")
	RegAdminCmd("sm_renderfx", Command_RenderFX, ADMFLAG_SLAY, "sm_renderfx <#userid|name> [RenderFX]")
	RegAdminCmd("sm_model", Command_Model, ADMFLAG_SLAY, "sm_model <#userid|name> [model]")
	HookEvent("player_spawn", OnPlayerSpawn)
	TopMenu topmenu
	if (LibraryExists("adminmenu") && ((topmenu = GetAdminTopMenu()) != null)) {
		OnAdminMenuReady(topmenu)
	}
}

public void OnClientConnected(int client, char[] rejectmsg, int maxlen) {
	playerstate[client].setGod = false
	playerstate[client].setSpeed = 1.0
}

public void OnSpeedScaleChange(ConVar convar, const char[] oldValue, const char[] newValue) {
	for (int i=1; i <= MaxClients; i++) {
		if (!IsClientConnected(i) || GetClientTeam(client) < 2) {
			continue
		}
		if (playerstate[client].setSpeed == 1.0) {
			SetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue", g_SpeedScale.FloatValue)
		}
	}
}

public void OnGodAllChange(ConVar convar, const char[] oldValue, const char[] newValue) {
	for (int i=1; i <= MaxClients; i++) {
		if (!IsClientConnected(i) || GetClientTeam(client) < 2) {
			continue
		}
		if (g_GodAll.BoolValue) {
			SetEntProp(client, Prop_Data, "m_takedamage", 0, 1)
		} else {
			SetEntProp(client, Prop_Data, "m_takedamage", 2, 1)
		}
	}
}

public void OnPlayerSpawn(Event event, const char[] event_name, bool dontBroadcast) {
	int client = GetClientOfUserId(event.GetInt("userid"))
	if (GetClientTeam(client) < 2) {
		return
	}
	if (playerstate[client].setGod || g_GodAll.BoolValue) {
		SetEntProp(client, Prop_Data, "m_takedamage", 0, 1)
	}
	if (playerstate[client].setSpeed != 1.0) {
		SetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue", playerstate[client].setSpeed)
	} else if (g_SpeedScale.FloatValue != 1.0) {
		SetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue", g_SpeedScale.FloatValue)
	}
}

public void OnAdminMenuReady(Handle aTopMenu) {
	TopMenu topmenu = TopMenu.FromHandle(aTopMenu)
	if (topmenu == hTopMenu) {
		return
	}
	hTopMenu = topmenu
	TopMenuObject player_commands = hTopMenu.FindCategory(ADMINMENU_PLAYERCOMMANDS)
	if (player_commands != INVALID_TOPMENUOBJECT) {
		hTopMenu.AddItem("sm_god", AdminMenu_God, player_commands, "sm_god", ADMFLAG_SLAY)
		hTopMenu.AddItem("sm_hp", AdminMenu_HP, player_commands, "sm_hp", ADMFLAG_SLAY)
		hTopMenu.AddItem("sm_speed", AdminMenu_Speed, player_commands, "sm_speed", ADMFLAG_SLAY)
		hTopMenu.AddItem("sm_colour", AdminMenu_Colour, player_commands, "sm_colour", ADMFLAG_SLAY)
	}
}

void AddTranslatedMenuItem(Menu menu, const char[] opt, const char[] phrase, int client) {
	char buffer[128]
	Format(buffer, sizeof(buffer), "%T", phrase, client)
	menu.AddItem(opt, buffer)
}