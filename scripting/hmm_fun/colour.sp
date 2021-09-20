public void AdminMenu_Colour(TopMenu topmenu, TopMenuAction action, TopMenuObject object_id, int param, char[] buffer, int maxlength) {
	if (action == TopMenuAction_DisplayOption) {
		Format(buffer, maxlength, "%T", "Set player colour", param)
	} else if (action == TopMenuAction_SelectOption) {
		DisplayColourAmountMenu(param)
	}
}

void DisplayColourAmountMenu(int client) {
	char title[100]
	Format(title, sizeof(title), "%T:", "Colour name", client)
	Menu menu = new Menu(MenuHandler_ColourAmount)
	menu.SetTitle(title)
	menu.ExitBackButton = true

	AddTranslatedMenuItem(menu, "255,255,255,255", "Normal", client)
	AddTranslatedMenuItem(menu, "0,0,0,255", "Black", client)
	AddTranslatedMenuItem(menu, "192,192,192,255", "Silver", client)
	AddTranslatedMenuItem(menu, "255,0,0,255", "Red", client)
	AddTranslatedMenuItem(menu, "128,0,128,255", "Purple", client)
	AddTranslatedMenuItem(menu, "0,255,0,255", "Green", client)
	AddTranslatedMenuItem(menu, "255,255,0,255", "Yellow", client)

	AddTranslatedMenuItem(menu, "0,0,255,255", "Blue", client)
	AddTranslatedMenuItem(menu, "0,255,255,255", "Aqua", client)
	AddTranslatedMenuItem(menu, "255,165,128,255", "Orange", client)
	AddTranslatedMenuItem(menu, "255,215,0,255", "Gold", client)
	AddTranslatedMenuItem(menu, "255,0,255,255", "Pink", client)
	AddTranslatedMenuItem(menu, "255,255,255,127", "Half-Invisible", client)
	AddTranslatedMenuItem(menu, "255,255,255,0", "Invisible", client)

	menu.Display(client, MENU_TIME_FOREVER)
}

char g_ColourAmount[MAXPLAYERS+1][32]
void DisplayColourTargetMenu(int client) {
	char title[100]
	Format(title, sizeof(title), "%T: RGB(%s)", "Set player colour", client, g_ColourAmount[client])
	Menu menu = new Menu(MenuHandler_Colour)
	menu.SetTitle(title)
	menu.ExitBackButton = true

	AddTargetsToMenu(menu, client, true, false)

	menu.Display(client, MENU_TIME_FOREVER)
}

public int MenuHandler_ColourAmount(Menu menu, MenuAction action, int param1, int param2) {
	if (action == MenuAction_End) {
		delete menu
	} else if (action == MenuAction_Cancel) {
		if (param2 == MenuCancel_ExitBack && hTopMenu) {
			hTopMenu.Display(param1, TopMenuPosition_LastCategory)
		}
	} else if (action == MenuAction_Select) {
		char info[32]
		menu.GetItem(param2, info, sizeof(info))
		g_ColourAmount[param1] = info
		DisplayColourTargetMenu(param1)
	}
}

void PerformColour(int client, int target, int red, int green, int blue, int alpha) {
	if (alpha < 255) {
		SetEntityRenderMode(target, RENDER_TRANSCOLOR)
	} else {
		SetEntityRenderMode(target, RENDER_NORMAL)
	}
	SetEntityRenderColor(target, red, green, blue, alpha)
	LogAction(client, target, "\"%L\" set the colour of \"%L\" to RGB(%i,%i,%i,%i)", client, target, red, green, blue, alpha)
}

public int MenuHandler_Colour(Menu menu, MenuAction action, int param1, int param2) {
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
			char name[MAX_NAME_LENGTH], sColor[16][4]
			GetClientName(target, name, sizeof(name))
			ExplodeString(g_ColourAmount[param1], ",", sColor, sizeof(sColor), sizeof(sColor[]))
			int red, green, blue, alpha
			red = StringToInt(sColor[0])
			green = StringToInt(sColor[1])
			blue = StringToInt(sColor[2])
			alpha = StringToInt(sColor[3])
			PerformColour(param1, target, red, green, blue, alpha)
			ShowActivity2(param1, "[SM] ", "%t", "Set colour for target", "_s", name, red, green, blue, alpha)
		}
		DisplayColourTargetMenu(param1)
	}
}

public Action Command_Colour(int client, int args) {
	if (args < 4) {
		ReplyToCommand(client, "[SM] Usage: sm_colour <#userid|name> [Red:0-255] [Green:0-255] [Blue:0-255] [Alpha:0-255]")
		return Plugin_Handled
	}

	char arg[65], arg2[4], arg3[4], arg4[4], arg5[4]
	GetCmdArg(1, arg, sizeof(arg))
	GetCmdArg(2, arg2, sizeof(arg2))
	GetCmdArg(3, arg3, sizeof(arg3))
	GetCmdArg(4, arg4, sizeof(arg4))
	GetCmdArg(5, arg5, sizeof(arg5))
	int red = StringToInt(arg2)
	if (args < 2 || red > 255) {
		red = 255
	} else if (red < 0) {
		red = 0
	}
	int green = StringToInt(arg3)
	if (args < 3 || green > 255) {
		green = 255
	} else if (green < 0) {
		green = 0
	}
	int blue = StringToInt(arg4)
	if (args < 4 || blue > 255) {
		blue = 255
	} else if (blue < 0) {
		blue = 0
	}
	int alpha = StringToInt(arg5)
	if (args < 5 || alpha > 255) {
		alpha = 255
	} else if (alpha < 0) {
		alpha = 0
	}

	char target_name[MAX_TARGET_LENGTH]
	int target_list[MAXPLAYERS], target_count
	bool tn_is_ml
	if ((target_count = ProcessTargetString(arg, client, target_list, MAXPLAYERS, COMMAND_FILTER_ALIVE, target_name, sizeof(target_name), tn_is_ml)) <= 0) {
		ReplyToTargetError(client, target_count)
		return Plugin_Handled
	}

	for (int i = 0; i < target_count; i++) {
		PerformColour(client, target_list[i], red, green, blue, alpha)
	}

	if (tn_is_ml) {
		ShowActivity2(client, "[SM] ", "%t", "Set colour for target", target_name, red, green, blue, alpha)
	} else {
		ShowActivity2(client, "[SM] ", "%t", "Set colour for target", "_s", target_name, red, green, blue, alpha)
	}
	return Plugin_Handled
}