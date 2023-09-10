new const PISTOL_NAME[][] = {"Glock 18", "USP", "P228", "Dual Elites", "Five-seven"};
new const HUMAN_MODEL[][] = {"arctic", "guerilla", "leet", "terror"};

new g_fwHumanizePlayer;
new Float:g_maxArmor[33];

public Human::Init()
{
	g_fwHumanizePlayer = CreateMultiForward("zm_HumanizePlayer", ET_IGNORE, FP_CELL);
}

public Human::Killed(id)
{
	if (!isZombie(id))
		dropWeapons(id, 0);
}

public Human::GiveDefaultItems(id)
{
	if (!isZombie(id))
	{
		strip_user_weapons(id);
		give_item(id, "weapon_knife");
		
		HOOK_RETURN(OrpheuSupercede);
	}
	
	HOOK_RETURN(OrpheuIgnored);
}

public Human::Infect(id)
{
	setPlayerData(id, "m_bNotKilled", false);
}

public Human::Humanize(id)
{	
	set_user_health(id, 100);
	set_user_gravity(id, 1.0);
	
	set_pev(id, pev_max_health, 300.0);
	g_maxArmor[id] = 300.0;
	
	ExecuteHamB(Ham_CS_Player_ResetMaxSpeed, id);
	
	cs_set_user_model(id, HUMAN_MODEL[random(sizeof HUMAN_MODEL)]);
}

public Human::KnifeKnockBack(id, attacker, &Float:power)
{
	if (!isKnifeStabbing(attacker))
		return;
	
	if (getNemesis(id) || getGmonster(id) || getCombiner(id) || getMorpheus(id) || getBoomer(id))
		return;
	
	power = 600.0;
}

public ShowPistolMenu(id)
{
	if (getLeader(id))
		return;
	
	new menu = menu_create("Choose a Pistol", "HandlePistolMenu");
	
	for (new i = 0; i < sizeof PISTOL_NAME; i++)
	{
		menu_additem(menu, PISTOL_NAME[i]);
	}
	
	menu_setprop(menu, MPROP_NUMBER_COLOR, "\y");
	menu_display(id, menu);
}

public HandlePistolMenu(id, menu, item)
{
	menu_destroy(menu);
	
	if (item == MENU_EXIT || !is_user_alive(id) || isZombie(id) || getLeader(id))
		return;
	
	static const weaponClass[][] = 
	{
		"weapon_glock18", "weapon_usp", "weapon_p228", "weapon_elite", "weapon_fiveseven"
	};
	
	dropWeapons(id, 2);
	give_item(id, weaponClass[item]);
	wa_giveWeaponFullAmmo(id, get_weaponid(weaponClass[item]));
}

humanizePlayer(id)
{
	setZombie(id, false);
	setPlayerTeam(id, TEAM_CT);
	checkWinConditions();
	
	OnPlayerHumanize(id);
	
	ExecuteForward(g_fwHumanizePlayer, g_return, id);
}

stock countHumans()
{
	new count = 0;
	for (new i = 1; i <= g_maxClients; i++)
	{
		if (is_user_alive(i) && !isZombie(i))
			count++;
	}
	
	return count;
}

stock Float:getMaxArmor(id)
{
	return g_maxArmor[id];
}

stock setMaxArmor(id, Float:armor)
{
	g_maxArmor[id] = armor;
}