#include <sourcemod>
#include <sdktools>

public Plugin myinfo = {
	name = "HMM Bots",
	author = "HellaMadMax",
	description = "",
	version = "0.1",
	url = ""
}

ConVar g_botQuota
ConVar g_botEmpty
ConVar g_botStop
public void OnPluginStart() {
	g_botQuota = CreateConVar("hmm_botquota", "16", "How many RCBots to add (minus non-spectator players)", 0, true, 0.0, true, float(MaxClients-1))
	g_botQuota.AddChangeHook(OnBotQuotaChange)
	g_botEmpty = CreateConVar("hmm_botempty", "1", "Keep RCBots on empty server", 0, true, 0.0, true, 1.0)
	g_botStop = FindConVar("rcbot_stop")
	HookEvent("player_team", OnBotTeamChange, EventHookMode_Pre)
}

int bot_quota
public void SetBotQuota() {
	int ent, allies, axis
	while ((ent = FindEntityByClassname(ent, "info_player_allies")) != -1) {
		allies++
	}
	ent = 0
	while ((ent = FindEntityByClassname(ent, "info_player_axis")) != -1) {
		axis++
	}
	int new_quota = g_botQuota.IntValue
	if (new_quota > allies + axis) {
		new_quota = allies + axis - 1
	}
	if (new_quota % 2 != 0) {
		new_quota--
	}
	if (bot_quota == new_quota) {
		return
	}
	bot_quota = new_quota
	LogMessage("Bot quota set to %i (Desired: %i, MaxClients: %i, Total spawns: %i, Allies: %i, Axis: %i)", bot_quota, g_botQuota.IntValue, MaxClients, allies + axis, allies, axis)
}

public void OnBotQuotaChange(ConVar convar, const char[] oldValue, const char[] newValue) {
	if (StrEqual(oldValue, newValue)) {
		return
	}
	SetBotQuota()
}

public void OnConfigsExecuted() {
	SetBotQuota()
}

public void OnBotTeamChange(Event event, const char[] event_name, bool dontBroadcast) {
	int client = GetClientOfUserId(event.GetInt("userid"))
	if (IsFakeClient(client)) {
		event.BroadcastDisabled = true
	}
}

float m_fBotQuotaTimer
public void OnGameFrame() {
	if (m_fBotQuotaTimer < GetEngineTime() - 1) {
		m_fBotQuotaTimer = GetEngineTime()
		int total, inactive, players, bots, team2, team3
		for (int i=1; i <= MaxClients; i++) {
			if (!IsClientConnected(i)) {
				continue
			}
			total++
			if (IsFakeClient(i) && !IsClientSourceTV(i)) {
				bots++
			} else if (!IsClientInGame(i) || GetClientTeam(i) < 2) {
				inactive++
				continue
			} else {
				players++
			}
			if (GetClientTeam(i) == 2) {
				team2++
			} else if (GetClientTeam(i) == 3) {
				team3++
			}
		}
		int quota = bot_quota - players
		if (!g_botEmpty.BoolValue && inactive + players < 1 || quota < 0) {
			quota = 0
			g_botStop.BoolValue = true
		} else {
			g_botStop.BoolValue = false
		}
		if (inactive + players + quota >= MaxClients) {
			quota = quota - ((inactive + players + quota) - MaxClients + 2)
		}
		//PrintToServer("Checking quota (Total: %i, Inactive: %i, Players: %i, Bots: %i, Quota: %i)", total, inactive, players, bots, quota)
		if (quota > bots) {
			int diff = quota - bots
			LogMessage("Adding %i bots (Total: %i, Inactive: %i, Players: %i, Bots: %i, Quota: %i)", diff, total, inactive, players, bots, quota)
			for (int i=1; i <= diff; i++) {
				ServerCommand("rcbotd addbot")
			}
		} else if (bots > quota) {
			int diff = bots - quota
			LogMessage("Kicking %i bots (Total: %i, Inactive: %i, Players: %i, Bots: %i, Quota: %i)", diff, total, inactive, players, bots, quota)
			for (int i=1; i <= MaxClients; i++) {
				if (!IsClientInGame(i) || !IsFakeClient(i) || IsClientSourceTV(i)) {
					continue
				}
				KickClient(i)
				diff--
				if (diff < 1) {
					break
				}
			}
		} else {
			for (int i=1; i <= MaxClients; i++) {
				if (!IsClientInGame(i) || !IsFakeClient(i) || IsClientSourceTV(i) || GetClientTeam(i) < 2) {
					continue
				}
				if (team2 == team3 || (team2 > team3 && team2 - team3 == 1) || (team3 > team2 && team3 - team2 == 1)) {
					return
				}
				if (team2 > team3 && GetClientTeam(i) == 2) {
					ChangeClientTeam(i, 1)
					ChangeClientTeam(i, 3)
					LogMessage("Moving bot to team 3 (Team2: %i, Team3: %i, Diff: %i)", team2, team3, team2 - team3)
					team2--
					team3++
				} else if (team3 > team2 && GetClientTeam(i) == 3) {
					ChangeClientTeam(i, 1)
					ChangeClientTeam(i, 2)
					LogMessage("Moving bot to team 2 (Team2: %i, Team3: %i, Diff: %i)", team2, team3, team3 - team2)
					team3--
					team2++
				}
			}
		}
	}
}