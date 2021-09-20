public void AdminMenu_God(TopMenu topmenu, TopMenuAction action, TopMenuObject object_id, int param, char[] buffer, int maxlength) {
	if (action == TopMenuAction_DisplayOption) {
		Format(buffer, maxlength, "%T", "God player", param)
	} else if (action == TopMenuAction_SelectOption) {
		DisplayGodMenu(param)
	}
}

void DisplayGodMenu(int client) {
	char title[100]
	Format(title, sizeof(title), "%T:", "God player", client)
	Menu menu = new Menu(MenuHandler_God)
	menu.SetTitle(title)
	menu.ExitBackButton = true

	AddTargetsToMenu(menu, client, true, false)

	menu.Display(client, MENU_TIME_FOREVER)
}

void PerformGod(int client, int target, bool enable) {
	if (enable) {
		playerstate[client].setGod = true
		SetEntProp(target, Prop_Data, "m_takedamage", 0, 1)
		LogAction(client, target, "\"%L\" enabled godmode for \"%L\"", client, target)
	} else {
		playerstate[client].setGod = false
		SetEntProp(target, Prop_Data, "m_takedamage", 2, 1)
		LogAction(client, target, "\"%L\" disabled godmode for \"%L\"", client, target)
	}
}

public int MenuHandler_God(Menu menu, MenuAction action, int param1, int param2) {
	if (action == MenuAction_End) {
		delete menu
	} else if (action == MenuAction_Cancel) {
		if (param2 == MenuCancel_ExitBack && hTopMenu) {
			hTopMenu.Display(param1, TopMenuPosition_LastCategory)
		}
	} else if (action == MenuAction_Select) {
		char info[32]
		menu.GetItem(param2, info, sizeof(info))

		int userid, target
		userid = StringToInt(info)
		if ((target = GetClientOfUserId(userid)) == 0) {
			PrintToChat(param1, "[SM] %t", "Player no longer available")
		} else if (!CanUserTarget(param1, target)) {
			PrintToChat(param1, "[SM] %t", "Unable to target")
		} else {
			char name[MAX_NAME_LENGTH]
			GetClientName(target, name, sizeof(name))
			bool enable = GetEntProp(target, Prop_Data, "m_takedamage") != 0
			PerformGod(param1, target, enable)
			if (enable) {
				ShowActivity2(param1, "[SM] ", "%t", "Enabled godmode for target", "_s", name)
			} else {
				ShowActivity2(param1, "[SM] ", "%t", "Disabled godmode for target", "_s", name)
			}
		}
		DisplayGodMenu(param1)
	}
}

public Action Command_God(int client, int args) {
	if (args < 1) {
		ReplyToCommand(client, "[SM] Usage: sm_god <#userid|name>")
		return Plugin_Handled
	}

	char arg[65]
	GetCmdArg(1, arg, sizeof(arg))

	char target_name[MAX_TARGET_LENGTH]
	int target_list[MAXPLAYERS], target_count
	bool tn_is_ml
	if ((target_count = ProcessTargetString(arg, client, target_list, MAXPLAYERS, COMMAND_FILTER_ALIVE, target_name, sizeof(target_name), tn_is_ml)) <= 0) {
		ReplyToTargetError(client, target_count)
		return Plugin_Handled
	}

	for (int i = 0; i < target_count; i++) {
		PerformGod(client, target_list[i], true)
	}

	if (tn_is_ml) {
		ShowActivity2(client, "[SM] ", "%t", "Enabled godmode for target", target_name)
	} else {
		ShowActivity2(client, "[SM] ", "%t", "Enabled godmode for target", "_s", target_name)
	}
	return Plugin_Handled
}

public Action Command_UnGod(int client, int args) {
	if (args < 1) {
		ReplyToCommand(client, "[SM] Usage: sm_ungod <#userid|name>")
		return Plugin_Handled
	}

	char arg[65]
	GetCmdArg(1, arg, sizeof(arg))

	char target_name[MAX_TARGET_LENGTH]
	int target_list[MAXPLAYERS], target_count
	bool tn_is_ml
	if ((target_count = ProcessTargetString(arg, client, target_list, MAXPLAYERS, COMMAND_FILTER_ALIVE, target_name, sizeof(target_name), tn_is_ml)) <= 0) {
		ReplyToTargetError(client, target_count)
		return Plugin_Handled
	}

	for (int i = 0; i < target_count; i++) {
		PerformGod(client, target_list[i], false)
	}

	if (tn_is_ml) {
		ShowActivity2(client, "[SM] ", "%t", "Disabled godmode for target", target_name)
	} else {
		ShowActivity2(client, "[SM] ", "%t", "Disabled godmode for target", "_s", target_name)
	}
	return Plugin_Handled
}