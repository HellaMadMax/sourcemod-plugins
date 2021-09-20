public void AdminMenu_Speed(TopMenu topmenu, TopMenuAction action, TopMenuObject object_id, int param, char[] buffer, int maxlength) {
	if (action == TopMenuAction_DisplayOption) {
		Format(buffer, maxlength, "%T", "Set player speed", param)
	} else if (action == TopMenuAction_SelectOption) {
		DisplaySpeedAmountMenu(param)
	}
}

void DisplaySpeedAmountMenu(int client) {
	char title[100]
	Format(title, sizeof(title), "%T:", "Speed amount", client)
	Menu menu = new Menu(MenuHandler_SpeedAmount)
	menu.SetTitle(title)
	menu.ExitBackButton = true

	menu.AddItem("0.1", "0.1")
	menu.AddItem("0.25", "0.25")
	menu.AddItem("0.50", "0.50")
	menu.AddItem("0.75", "0.75")
	menu.AddItem("1.0", "1.0")
	menu.AddItem("2.0", "2.0")
	menu.AddItem("3.0", "3.0")

	menu.AddItem("4.0", "4.0")
	menu.AddItem("5.0", "5.0")
	menu.AddItem("6.0", "6.0")
	menu.AddItem("7.0", "7.0")
	menu.AddItem("8.0", "8.0")
	menu.AddItem("9.0", "9.0")
	menu.AddItem("10.0", "10.0")

	menu.Display(client, MENU_TIME_FOREVER)
}

float g_SpeedAmount[MAXPLAYERS+1]
void DisplaySpeedTargetMenu(int client) {
	char title[100]
	Format(title, sizeof(title), "%T: %.2f speed", "Set player speed", client, g_SpeedAmount[client])
	Menu menu = new Menu(MenuHandler_Speed)
	menu.SetTitle(title)
	menu.ExitBackButton = true

	AddTargetsToMenu(menu, client, true, true)

	menu.Display(client, MENU_TIME_FOREVER)
}

public int MenuHandler_SpeedAmount(Menu menu, MenuAction action, int param1, int param2) {
	if (action == MenuAction_End) {
		delete menu
	} else if (action == MenuAction_Cancel) {
		if (param2 == MenuCancel_ExitBack && hTopMenu) {
			hTopMenu.Display(param1, TopMenuPosition_LastCategory)
		}
	} else if (action == MenuAction_Select) {
		char info[32]
		menu.GetItem(param2, info, sizeof(info))
		g_SpeedAmount[param1] = StringToFloat(info)
		DisplaySpeedTargetMenu(param1)
	}
}

void PerformSpeed(int client, int target, float amount) {
	playerstate[client].setSpeed = amount
	SetEntPropFloat(target, Prop_Data, "m_flLaggedMovementValue", amount)
	LogAction(client, target, "\"%L\" set the speed for \"%L\" to \"%.2f\"", client, target, amount)
}

public int MenuHandler_Speed(Menu menu, MenuAction action, int param1, int param2) {
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
			PerformSpeed(param1, target, g_SpeedAmount[param1])
			ShowActivity2(param1, "[SM] ", "%t", "Set speed for target", "_s", name, g_SpeedAmount[param1])
		}
		DisplaySpeedTargetMenu(param1)
	}
}

public Action Command_Speed(int client, int args) {
	if (args < 2) {
		ReplyToCommand(client, "[SM] Usage: sm_speed <#userid|name> [0.01-99.99]")
		return Plugin_Handled
	}

	char arg[65], arg2[11]
	GetCmdArg(1, arg, sizeof(arg))
	GetCmdArg(2, arg2, sizeof(arg2))
	float amount = StringToFloat(arg2)
	if (amount <= 0 || amount > 99) {
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
		PerformSpeed(client, target_list[i], amount)
	}

	if (tn_is_ml) {
		ShowActivity2(client, "[SM] ", "%t", "Set speed for target", target_name, amount)
	} else {
		ShowActivity2(client, "[SM] ", "%t", "Set speed for target", "_s", target_name, amount)
	}
	return Plugin_Handled
}