public Action Command_RenderFX(int client, int args) {
	if (args < 2) {
		ReplyToCommand(client, "[SM] Usage: sm_renderfx <#userid|name> [RenderFX]")
		return Plugin_Handled
	}

	char arg[65], arg2[30]
	GetCmdArg(1, arg, sizeof(arg))
	GetCmdArg(2, arg2, sizeof(arg2))
	RenderFx render
	if (StrEqual(arg2, "NONE")) {
		render = RENDERFX_NONE
	} else if (StrEqual(arg2, "PULSE_SLOW")) {
		render = RENDERFX_PULSE_SLOW
	} else if (StrEqual(arg2, "PULSE_FAST")) {
		render = RENDERFX_PULSE_FAST
	} else if (StrEqual(arg2, "PULSE_SLOW_WIDE")) {
		render = RENDERFX_PULSE_SLOW_WIDE
	} else if (StrEqual(arg2, "PULSE_FAST_WIDE")) {
		render = RENDERFX_PULSE_FAST_WIDE
	} else if (StrEqual(arg2, "FADE_SLOW")) {
		render = RENDERFX_FADE_SLOW
	} else if (StrEqual(arg2, "FADE_FAST")) {
		render = RENDERFX_FADE_FAST
	} else if (StrEqual(arg2, "SOLID_SLOW")) {
		render = RENDERFX_SOLID_SLOW
	} else if (StrEqual(arg2, "SOLID_FAST")) {
		render = RENDERFX_SOLID_FAST
	} else if (StrEqual(arg2, "STROBE_SLOW")) {
		render = RENDERFX_STROBE_SLOW
	} else if (StrEqual(arg2, "STROBE_FAST")) {
		render = RENDERFX_STROBE_FAST
	} else if (StrEqual(arg2, "STROBE_FASTER")) {
		render = RENDERFX_STROBE_FASTER
	} else if (StrEqual(arg2, "FLICKER_SLOW")) {
		render = RENDERFX_FLICKER_SLOW
	} else if (StrEqual(arg2, "FLICKER_FAST")) {
		render = RENDERFX_FLICKER_FAST
	} else if (StrEqual(arg2, "NO_DISSIPATION")) {
		render = RENDERFX_NO_DISSIPATION
	} else if (StrEqual(arg2, "DISTORT")) {
		render = RENDERFX_DISTORT
	} else if (StrEqual(arg2, "HOLOGRAM")) {
		render = RENDERFX_HOLOGRAM
	} else if (StrEqual(arg2, "EXPLODE")) {
		render = RENDERFX_EXPLODE
	} else if (StrEqual(arg2, "GLOWSHELL")) {
		render = RENDERFX_GLOWSHELL
	} else if (StrEqual(arg2, "PULSE_FAST_WIDER")) {
		render = RENDERFX_PULSE_FAST_WIDER
	} else if (StrEqual(arg2, "MAX")) {
		render = RENDERFX_MAX
	} else {
		ReplyToCommand(client, "[SM] %t", "Invalid RenderFx")
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
		SetEntityRenderFx(target_list[i], render)
		LogAction(client, target_list[i], "\"%L\" set the RenderFx for \"%L\" to \"%i\"", client, target_list[i], arg2)
	}

	if (tn_is_ml) {
		ShowActivity2(client, "[SM] ", "%t", "Set RenderFx for target", target_name, arg2)
	} else {
		ShowActivity2(client, "[SM] ", "%t", "Set RenderFx for target", "_s", target_name, arg2)
	}
	return Plugin_Handled
}

public Action Command_Model(int client, int args) {
	if (args < 2) {
		ReplyToCommand(client, "[SM] Usage: sm_model <#userid|name> [model]")
		return Plugin_Handled
	}

	char arg[65], arg2[255]
	GetCmdArg(1, arg, sizeof(arg))
	GetCmdArg(2, arg2, sizeof(arg2))
	if (!IsModelPrecached(arg2) && (!FileExists(arg2) || PrecacheModel(arg2) == 0)) {
		ReplyToCommand(client, "[SM] %t", "Invalid Model", arg2)
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
		SetEntityModel(target_list[i], arg2)
		LogAction(client, target_list[i], "\"%L\" set the model for \"%L\" to \"%s\"", client, target_list[i], arg2)
	}

	if (tn_is_ml) {
		ShowActivity2(client, "[SM] ", "%t", "Set model for target", target_name, arg2)
	} else {
		ShowActivity2(client, "[SM] ", "%t", "Set model for target", "_s", target_name, arg2)
	}
	return Plugin_Handled
}