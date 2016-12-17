public Menu::Init()
{
	register_clcmd("chooseteam", "CmdChooseTeam");
	register_clcmd("jointeam", "CmdChooseTeam");
	
	register_menucmd(register_menuid("Join Spectator"), 1023, "HandleSpectatorMenu");
}

public CmdChooseTeam(id)
{
	if (1 <= getPlayerData(id, "m_iTeam") <= 2)
	{
		ShowMainMenu(id);
		return PLUGIN_HANDLED;
	}
	
	return PLUGIN_CONTINUE;
}

public ShowMainMenu(id)
{
	new text[64];
	formatex(text, charsmax(text), "Zombie Mod [\w%s\y]", VERSION);
	new menu = menu_create(text, "HandleMainMenu");
	
	menu_additem(menu, "What's new");
	menu_additem(menu, "Buy \dbuy2");
	menu_additem(menu, "Choose Zombie Type \dchoosezombie");
	menu_additem(menu, "Join Spectator");
	
	menu_setprop(menu, MPROP_NUMBER_COLOR, "\y");
	menu_display(id, menu);
}

public HandleMainMenu(id, menu, item)
{
	menu_destroy(menu);
	
	switch (item)
	{
		case 0:
		{
			show_motd(id, "changelog.txt", "What's new");
		}
		case 1:
		{
			ShowBuyMenu(id);
		}
		case 2:
		{
			ShowZombieTypeMenu(id);
		}
		case 3: // Join spectator
		{
			ShowSpectatorMenu(id);
		}
	}
}

public ShowSpectatorMenu(id)
{
	new menu[256];
	formatex(menu, charsmax(menu), "\yAre you sure you want to join spectator?^n^n6. \wYes^n\y0. \wNo");
	
	new keys = MENU_KEY_0|MENU_KEY_6;
	
	show_menu(id, keys, menu, 10, "Join Spectator");
}

public HandleSpectatorMenu(id, key)
{
	if (key == 5)
	{
		if (!(1 <= get_user_team(id) <= 2))
			return;
			
		if (isGameStarted())
		{
			if (is_user_alive(id))
			{
				client_print(id, print_center, "你只能在死後或遊戲開始之前加入");
				return;
			}
		}
			
		if (is_user_alive(id))
			user_kill(id, 1);
		
		engclient_cmd(id, "jointeam", "6");
	}
}