#include <sourcemod>
#include <sdktools>
#include <geoip>

public Plugin myinfo = {
	name = "DOD:S Damage/Kill Log",
	author = "HellaMadMax",
	description = "",
	version = "0.1",
	url = ""
}

public void OnPluginStart() {
	HookEvent("player_hurt", OnPlayerHurt)
}

int GetTeamColour(int client) {
	int team = GetClientTeam(client)
	int colour = 0xCCCCCC
	switch(team) {
		case 2: {
			colour = 0x4D7942
		}
		case 3: {
			colour = 0xFF4040
		}
	}
	return colour
}

public void OnPlayerHurt(Event event, const char[] event_name, bool dontBroadcast) {
	int client = GetClientOfUserId(event.GetInt("userid"))
	if (!client || !IsClientConnected(client)) {
		return
	}
	int attacker = GetClientOfUserId(event.GetInt("attacker"))
	if (!attacker || !IsClientConnected(attacker) || attacker == client) {
		return
	}
	char weapon[65]
	event.GetString("weapon", weapon, sizeof(weapon))
	int damage = event.GetInt("damage")
	int hitgroup = event.GetInt("hitgroup")
	char hitgroup_c[30]
	hitgroup_c = ""
	switch(hitgroup) {
		case 1: {
			hitgroup_c = " in the \x04Head\x01"
		}
		case 2: {
			hitgroup_c = " in the \x04Upper Chest\x01"
		}
		case 3: {
			hitgroup_c = " in the \x04Lower Chest\x01"
		}
		case 4: {
			hitgroup_c = " in the \x04Left Arm\x01"
		}
		case 5: {
			hitgroup_c = " in the \x04Right Arm\x01"
		}
		case 6: {
			hitgroup_c = " in the \x04Left Leg\x01"
		}
		case 7: {
			hitgroup_c = " in the \x04Right Leg\x01"
		}
	}
	int attacker_hp = GetClientHealth(attacker)
	int attacker_colour = GetTeamColour(attacker)
	char attacker_name[MAX_NAME_LENGTH]
	GetClientName(attacker, attacker_name, sizeof(attacker_name))
	int client_hp = event.GetInt("health")
	int client_colour = GetTeamColour(client)
	char client_name[MAX_NAME_LENGTH]
	GetClientName(client, client_name, sizeof(client_name))
	if (client_hp > 0) {
		PrintToChat(client, "\x07%06X%s\x01 (\x04%i\x01 hp) hit \x07%06Xyou\x01 (\x04%i\x01 hp left) with \x04%s\x01 (\x04%i\x01 damage%s)", attacker_colour, attacker_name, attacker_hp, client_colour, client_hp, weapon, damage, hitgroup_c)
	} else {
		PrintToChat(client, "\x07%06X%s\x01 (\x04%i\x01 hp) killed \x07%06Xyou\x01 with \x04%s\x01 (\x04%i\x01 damage%s)", attacker_colour, attacker_name, attacker_hp, client_colour, weapon, damage, hitgroup_c)
	}
}