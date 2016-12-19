public HudInfo::Init()
{
	set_task(0.5, "UpdateHudInfoTask", TASK_HUDINFO, .flags="b")
}

public UpdateHudInfoTask()
{
	for (new i = 1; i <= g_maxClients; i++)
	{
		if (is_user_connected(i))
			showHudInfo(i);
	}
}

showHudInfo(id)
{
	new player = id;
	if (!is_user_alive(player))
	{
		player = pev(id, pev_iuser2);
		
		if (!is_user_alive(player))
			return;
	}
	
	new color[3];
	new class[32];
	new additional[64];
	
	if (isZombie(player))
	{
		if (getGmonster(player))
		{
			color = {200, 0, 100};
			formatex(class, charsmax(class), "G-%d", getGmonster(player));
		}
		else if (getNemesis(player))
		{
			color = {255, 0, 0};
			formatex(class, charsmax(class), "N-%d", getNemesis(player));
		}
		else if (getCombiner(player))
		{
			color = {100, 200, 0};
			formatex(class, charsmax(class), "Combiner");
		}
		else if (getMorpheus(player))
		{
			color = {255, 0, 0};
			formatex(class, charsmax(class), "Morpheus");
		}
		else if (getBoomer(player))
		{
			color = {200, 75, 0};
			formatex(class, charsmax(class), "Boomer");
		}
		else
		{
			color = {200, 100, 0};
			formatex(class, charsmax(class), "Zombie - %a", ArrayGetStringHandle(g_zombieName, getZombieType(player)));
		}
	}
	else
	{
		if (getLeader(player))
		{
			color = {0, 100, 200};
			formatex(class, charsmax(class), "Leader");
		}
		else if (getSupporter(player))
		{
			color = {0, 255, 0};
			formatex(class, charsmax(class), "Supporter");
		}
		else
		{
			color = {0, 200, 0};
			formatex(class, charsmax(class), "Survivor");
		}
		
		new weapon = get_user_weapon(player);
		if (isLevelGun(weapon))
		{
			formatex(additional, charsmax(additional), "%s Lv: %d - EXP: %d/%d",
				GUN_NAMES[weapon], getGunLevel(player, weapon), 
				getGunExp(player, weapon), getRequiredGunExp(player, weapon));
		}
	}
	
	if (id != player)
	{
		set_hudmessage(color[0], color[1], color[2], 0.6, 0.7, 0, 0.0, 1.1, 0.0, 0.0, 4);
		show_hudmessage(id, "HP: %d | Armor: %d | Class: %s^nRS: %d | $%d | Level: %d | EXP: %d/%d^n%s", 
			get_user_health(player), get_user_armor(player), class, 
			getResource(player), getMoney(player), getPlayerLevel(player), getPlayerExp(player), getRequiredExp(player), 
			additional
		);
	}
	else
	{
		set_hudmessage(color[0], color[1], color[2], 0.6, 0.85, 0, 0.0, 1.1, 0.0, 0.0, 4);
		show_hudmessage(id, "HP: %d | Armor: %d | Class: %s | RS: %d^nLevel: %d | EXP: %d/%d%s%s", 
			get_user_health(id), get_user_armor(id), class, getResource(id),
			getPlayerLevel(id), getPlayerExp(id), getRequiredExp(id), additional[0] ? " | " : "", additional
		);
	}
}