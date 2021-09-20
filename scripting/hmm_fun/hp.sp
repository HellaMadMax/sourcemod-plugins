public void AdminMenu_HP(TopMenu topmenu, TopMenuAction action, TopMenuObject object_id, int param, char[] buffer, int maxlength) {
	if (action == TopMenuAction_DisplayOption) {
		Format(buffer, maxlength, "%T", "Set player HP", param)
	} else if (action == TopMenuAction_SelectOption) {
		DisplayHPAmountMenu(param)
	}
}

void DisplayHPAmountMenu(int client) {
	char title[100]
	Format(title, sizeof(title), "%T:", "HP amount", client)
	Menu menu = new Menu(MenuHandler_HPAmount)
	menu.SetTitle(title)
	menu.ExitBackButton = true

	menu.AddItem("1", "1")
	menu.AddItem("25", "25")
	menu.AddItem("50", "50")
	menu.AddItem("75", "75")
	menu.AddItem("100", "100")
	menu.AddItem("200", "200")
	menu.AddItem("400", "400")

	menu.AddItem("800", "800")
	menu.AddItem("1600", "1600")
	menu.AddItem("3200", "3200")
	menu.AddItem("6400", "6400")
	menu.AddItem("12800", "12800")
	menu.AddItem("25600", "25600")
	menu.AddItem("2147483647", "2147483647")

	menu.Display(client, MENU_TIME_FOREVER)
}

int g_HPAmount[MAXPLAYERS+1]
void DisplayHPTargetMenu(int client) {
	char title[100]
	Format(title, sizeof(title), "%T: %d hp", "Set player HP", client, g_HPAmount[client])
	Menu menu = new Menu(MenuHandler_HP)
	menu.SetTitle(title)
	menu.ExitBackButton = true

	AddTargetsToMenu(menu, client, true, true)

	menu.Display(client, MENU_TIME_FOREVER)
}

public int MenuHandler_HPAmount(Menu menu, MenuAction action, int param1, int param2) {
	if (action == MenuAction_End) {
		delete menu
	} else if (action == MenuAction_Cancel) {
		if (param2 == MenuCancel_ExitBack && hTopMenu) {
			hTopMenu.Display(param1, TopMenuPosition_LastCategory)
		}
	} else if (action == MenuAction_Select) {
		char info[32]
		menu.GetItem(param2, info, sizeof(info))
		g_HPAmount[param1] = StringToInt(info)
		DisplayHPTargetMenu(param1)
	}
}

void PerformHP(int client, int target, int amount) {
	SetEntityHealth(target, amount)
	LogAction(client, target, "\"%L\" set the hp for \"%L\" to \"%i\"", client, target, amount)
}

public int MenuHandler_HP(Menu menu, MenuAction action, int param1, int param2) {
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
		} else if (!IsPlayerAlive(target)) {
			ReplyToCommand(param1, "[SM] %t", "Player has since died");
		} else {
			char name[MAX_NAME_LENGTH]
			GetClientName(target, name, sizeof(name))
			PerformHP(param1, target, g_HPAmount[param1])
			ShowActivity2(param1, "[SM] ", "%t", "Set HP for target", "_s", name, g_HPAmount[param1])
		}
		DisplayHPTargetMenu(param1)
	}
}

public Action Command_HP(int client, int args) {
	if (args < 2) {
		ReplyToCommand(client, "[SM] Usage: sm_hp <#userid|name> [1-2147483647]")
		return Plugin_Handled
	}

	char arg[65], arg2[11]
	GetCmdArg(1, arg, sizeof(arg))
	GetCmdArg(2, arg2, sizeof(arg2))
	int amount = StringToInt(arg2) // max 2147483647
	if (amount < 1) {
		ReplyToCommand(client, "[SM] %t", "Invalid Amount", arg2)
		return Plugin_Handled
	}

	char target_name[MAX_TARGET_LENGTH]
	int target_list[MAXPLAYERS], target_count
	bool tn_is_ml
	if ((target_count = ProcessTargetString(arg, client, target_list, MAXPLAYERS, COMMAND_FILTER_ALIVE, target_name, sizeof(target_name), tn_is_ml)) <= 0) {
		ReplyToTargetError(client, target_count)
		return Plugin_Handled
	}

	for (int i = 0; i < target_count; i++) {
		PerformHP(client, target_list[i], amount)
	}

	if (tn_is_ml) {
		ShowActivity2(client, "[SM] ", "%t", "Set HP for target", target_name, amount)
	} else {
		ShowActivity2(client, "[SM] ", "%t", "Set HP for target", "_s", target_name, amount)
	}
	return Plugin_Handled
}