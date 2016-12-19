new bool:g_isZombie[33];

new Array:g_zombieName;
new Array:g_zombieDesc;
new Array:g_zombieClass;
new Array:g_zombieFlags;
new g_zombieCount;

new g_zombieType[33];
new g_nextZombieType[33] = {-1, ...};
new bool:g_firstZombie[33];
new bool:g_godMode[33];
new Float:g_lastGrenadeTime[33];

public Zombie::Precache()
{
	precachePlayerModel("zombie_source");
	precache_model("models/v_knife_r.mdl");
	precache_model("models/zombiemod/v_knife_zombie.mdl");
}

public Zombie::Init()
{
	register_clcmd("choosezombie", "CmdChooseZombie");
	
	RegisterHam(Ham_TraceAttack, "player", "Zombie@TraceAttack");
	RegisterHam(Ham_TakeDamage, "player", "Zombie@TakeDamage");
}

public CmdChooseZombie(id)
{
	ShowZombieTypeMenu(id);
	return PLUGIN_HANDLED;
}

public Zombie::TraceAttack(id, attacker, Float:damage, Float:direction[3], tr, damageBits)
{
	if (is_user_connected(attacker))
	{
		if (g_isZombie[attacker] && get_user_weapon(attacker) == CSW_KNIFE)
		{
			if (isKnifeStabbing(attacker) && isPlayerInBack(id, attacker))
			{
				SetHamParamFloat(3, 130.0);
				return HAM_HANDLED;
			}
		}
		
		if (!isZombie(attacker) && isZombie(id))
		{
			if (g_godMode[id])
				return HAM_SUPERCEDE;
		}
	}
	
	return HAM_IGNORED;
}

public Zombie::TakeDamage(id, inflictor, attacker, Float:damage, damageBits)
{
	if (is_user_connected(attacker) && !isZombie(attacker) && isZombie(id))
	{
		if (g_godMode[id])
			return HAM_SUPERCEDE;
	}
	
	return HAM_IGNORED;
}

public Zombie::Disconnect(id)
{
	g_isZombie[id] = false;
	g_firstZombie[id] = false;
	g_zombieType[id] = 0;
	g_nextZombieType[id] = -1;
	
	removeGodMode(id);
}

public Zombie::Killed_P(id)
{
	g_firstZombie[id] = false;
	
	removeGodMode(id);
}

public Zombie::Humanize(id)
{
	g_firstZombie[id] = false;
	
	removeGodMode(id);
}

public Zombie::KnifeDeploy_P(id)
{
	if (g_isZombie[id])
	{
		set_pev(id, pev_viewmodel2, "models/zombiemod/v_knife_zombie.mdl");
		set_pev(id, pev_weaponmodel2, "");
		
		OnZombieKnifeDeploy(id);
	}
}

public Zombie::ResetMaxSpeed(id)
{
	if (g_isZombie[id])
	{
		set_user_maxspeed(id, get_user_maxspeed(id) * 0.9);
	}
}

public Zombie::TouchWeapon(ent, toucher)
{
	if (is_user_alive(toucher) && g_isZombie[toucher])
		HOOK_RETURN(HAM_SUPERCEDE);
	
	HOOK_RETURN(HAM_IGNORED);
}

public OrpheuHookReturn:Zombie::GiveDefaultItems(id)
{
	if (g_isZombie[id])
		HOOK_RETURN(OrpheuSupercede);
	
	HOOK_RETURN(OrpheuIgnored);
}

public Zombie::Infect(id, attacker)
{
	g_zombieType[id] = g_nextZombieType[id];
	
	if (g_zombieType[id] == -1)
	{
		g_zombieType[id] = 0;
		ShowZombieTypeMenu(id);
	}
	
	set_user_health(id, 1000);
	set_pev(id, pev_max_health, 1000.0);
	set_user_gravity(id, 0.95);
	set_user_armor(id, 0);
	
	ExecuteHamB(Ham_CS_Player_ResetMaxSpeed, id);
	
	cs_set_user_model(id, "zombie_source");
	
	dropWeapons(id, 0);
	
	strip_user_weapons(id);
	give_item(id, "weapon_knife");
	
	removeGodMode(id);
}

public ShowZombieTypeMenu(id)
{
	new menu = menu_create("Choose your zombie type", "HandleZombieTypeMenu");
	
	for (new i = 0; i < g_zombieCount; i++)
	{
		static buffer[128];
		if (g_nextZombieType[id] == i)
		{
			formatex(buffer, charsmax(buffer), "\d%a %a", 
					ArrayGetStringHandle(g_zombieName, i), 
					ArrayGetStringHandle(g_zombieDesc, i));
		}
		else
		{
			formatex(buffer, charsmax(buffer), "\w%a \y%a", 
					ArrayGetStringHandle(g_zombieName, i), 
					ArrayGetStringHandle(g_zombieDesc, i));
		}
		
		menu_additem(menu, buffer);
	}
	
	menu_setprop(menu, MPROP_NUMBER_COLOR, "\y");
	menu_display(id, menu);
}

public HandleZombieTypeMenu(id, menu, item)
{
	menu_destroy(menu);
	
	if (item == MENU_EXIT)
		return;
	
	g_nextZombieType[id] = item;
	client_print(id, print_chat, "Your next zombie type will be: %a", ArrayGetStringHandle(g_zombieName, item));
}

public RemoveGodMode(taskId)
{
	new id = taskId - TASK_GODMODE;
	removeGodMode(id);
}

public Zombie::Natives()
{
	register_native("zm_isZombie", "native_isZombie", 1);
	register_native("zm_createZombieType", "native_createZombieType", 1);
	register_native("zm_getZombieType", "native_getZombieType", 1);
	
	g_zombieName = ArrayCreate(32);
	g_zombieDesc = ArrayCreate(64);
	g_zombieClass = ArrayCreate(32);
	g_zombieFlags = ArrayCreate(1);
}

public native_isZombie(id)
{
	return g_isZombie[id];
}

public native_createZombieType(name[32], desc[64], class[32], flags)
{
	param_convert(1);
	param_convert(2);
	param_convert(3);
	
	ArrayPushString(g_zombieName, name);
	ArrayPushString(g_zombieDesc, desc);
	ArrayPushString(g_zombieClass, class);
	ArrayPushCell(g_zombieFlags, flags);
	
	g_zombieCount++;
	return g_zombieCount - 1;
}

public native_getZombieType(id)
{
	return g_zombieType[id];
}

infectPlayer(id, attacker=0)
{
	if (is_user_connected(attacker))
	{
		set_user_frags(attacker, get_user_frags(attacker) + 1);
		updateScoreInfo(attacker);
		
		setPlayerData(id, "m_iDeaths", getPlayerData(id, "m_iDeaths") + 1);
		updateScoreInfo(id);
		
		sendDeathMsg(attacker, id, 0, "infection");
		setScoreAttrib(id, 0);
	}
	
	g_isZombie[id] = true;
	setPlayerTeam(id, TEAM_TERRORIST);
	checkWinConditions();
	
	OnPlayerInfect(id, attacker);
}

stock resetZombie(id)
{
	setCombiner(id, false);
	setMorpheus(id, false);
	setBoomer(id, false);
	setGmonster(id, 0);
	setNemesis(id, 0);
}

stock countZombies()
{
	new count = 0;
	for (new i = 1; i <= g_maxClients; i++)
	{
		if (is_user_alive(i) && g_isZombie[i])
			count++;
	}
	
	return count;
}

stock getGodMode(id)
{
	return g_godMode[id];
}

stock setGodMode(id, Float:duration, bool:rendering)
{
	g_godMode[id] = true;
	
	if (rendering)
	{
		if (getGmonster(id))
			set_rendering(id, kRenderFxGlowShell, 200, 0, 100, kRenderNormal, 16);
		else if (getNemesis(id))
			set_rendering(id, kRenderFxGlowShell, 200, 0, 0, kRenderNormal, 16);
		else if (getMorpheus(id))
			set_rendering(id, kRenderFxGlowShell, 200, 0, 0, kRenderNormal, 16);
		else
			set_rendering(id, kRenderFxGlowShell, 0, 200, 0, kRenderNormal, 16);
	}
	
	remove_task(id + TASK_GODMODE);
	set_task(duration, "RemoveGodMode", id + TASK_GODMODE);
}

stock removeGodMode(id)
{
	if (g_godMode[id])
	{
		g_godMode[id] = false;
		set_rendering(id);
	}
}

stock setZombie(id, bool:value)
{
	g_isZombie[id] = value;
}

stock bool:isZombie(id)
{
	return g_isZombie[id];
}

stock bool:isFirstZombie(id)
{
	return g_firstZombie[id];
}

stock setFirstZombie(id, bool:value)
{
	g_firstZombie[id] = value;
}

stock getZombieType(id)
{
	return g_zombieType[id];
}

stock setZombieType(id, value)
{
	g_zombieType[id] = value;
}

stock Float:getLastGrenadeTime(id)
{
	return g_lastGrenadeTime[id];
}

stock setLastGrenadeTime(id, Float:time)
{
	g_lastGrenadeTime[id] = time;
}