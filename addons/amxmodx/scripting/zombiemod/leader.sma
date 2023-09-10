new g_leader[33];

public Leader::Precache()
{
	precachePlayerModel("leaderm");
	precachePlayerModel("leaderf");
}

public Leader::Init()
{
	RegisterHam(Ham_TakeDamage, "player", "Leader@TakeDamage");
	
	RegisterHam(Ham_Spawn, "weapon_deagle", "Leader@DeagleSpawn_P", 1);
	RegisterHam(Ham_Weapon_Reload, "weapon_deagle", "Leader@DeagleReload");
}

public Leader::NewRound()
{	
	arrayset(g_leader, false, sizeof g_leader);
	
	for (new i = 1; i <= g_maxClients; i++)
	{
		if (is_user_alive(i) && user_has_weapon(i, CSW_DEAGLE))
			engclient_cmd(i, "drop", "weapon_deagle");
	}
}

public Leader::DeagleSpawn_P(ent)
{
	setWeaponData(ent, "m_iDefaultAmmo", 0);
}

public Leader::DeagleReload(ent)
{
	if (cs_get_weapon_ammo(ent) > 0)
	{
		new player = get_ent_data_entity(ent, "CBasePlayerItem", "m_pPlayer");
		sendWeaponAnim(player, 0);
		return HAM_SUPERCEDE;
	}
	
	return HAM_IGNORED;
}

public Leader::SetModel(ent, const model[])
{
	if (!pev_valid(ent))
		return;
	
	new className[32];
	pev(ent, pev_classname, className, charsmax(className));
	
	if (equal(className, "weaponbox"))
	{
		if (equal(model[7], "w_deagle.mdl") || equal(model[7], "w_ak47.mdl"))
			set_pev(ent, pev_nextthink, get_gametime());
	}
}

public Leader::TakeDamage(id, inflictor, attacker, Float:damage, damageBits)
{
	if (!is_user_connected(attacker) || isZombie(attacker) == isZombie(id))
		return HAM_IGNORED;
	
	if (!isZombie(attacker) && inflictor == attacker && (damageBits & DMG_BULLET))
	{
		if (get_user_weapon(attacker) == CSW_AK47)
		{
			SetHamParamFloat(4, damage * 2.0);
			return HAM_HANDLED;
		}
		else if (get_user_weapon(attacker) == CSW_DEAGLE)
		{
			if (!getNemesis(id) && !getGmonster(id) && !getCombiner(id) && !getMorpheus(id) && !isFirstZombie(id))
			{
				SetHamParamFloat(4, damage * 9999.0);
				return HAM_HANDLED;
			}
		}
	}
	
	return HAM_IGNORED;
}

public Leader::Humanize(id)
{
	if (g_leader[id])
	{
		// Male
		if (g_leader[id] == LEADER_MALE)
		{
			set_user_health(id, 500);
			set_pev(id, pev_max_health, float(get_user_health(id)));
			
			set_user_armor(id, 300);
			setMaxArmor(id, 300.0);
			
			set_user_gravity(id, 0.95);
			
			cs_set_user_model(id, "leaderm");
		}
		else // Female
		{
			set_user_health(id, 400);
			set_pev(id, pev_max_health, float(get_user_health(id)));
			
			set_user_armor(id, 400);
			setMaxArmor(id, 400.0);
			
			set_user_gravity(id, 0.9);
			
			cs_set_user_model(id, "leaderf");
		}
		
		strip_user_weapons(id);
		
		give_item(id, "weapon_ak47");
		wa_giveWeaponFullAmmo(id, CSW_AK47);
		
		give_item(id, "weapon_deagle");
		
		give_item(id, "weapon_knife");
		
		give_item(id, "weapon_hegrenade");
		give_item(id, "weapon_flashbang");
		give_item(id, "weapon_smokegrenade");
		
		setResource(id, 500);
	}
}

public Leader::ResetMaxSpeed(id)
{
	if (!isZombie(id) && g_leader[id])
	{
		if (g_leader[id] == LEADER_MALE)
			set_user_maxspeed(id, get_user_maxspeed(id) * 1.15);
		else
			set_user_maxspeed(id, get_user_maxspeed(id) * 1.175);
	}
}

public Leader::Killer_P(id)
{
	g_leader[id] = false;
}

public Leader::Infect(id)
{
	g_leader[id] = false;
}

public Leader::Disconnect(id)
{
	g_leader[id] = false;
}

public Leader::KnifeKnockBack(id, attacker, &Float:power)
{
	if (!g_leader[attacker])
		return;
	
	if (isKnifeStabbing(attacker))
		power = 700.0;
	else
		power = 400.0;
}

stock getLeader(id)
{
	return g_leader[id];
}

stock setLeader(id, value)
{
	g_leader[id] = value;
}

stock countLeaders()
{
	new count = 0;
	for (new i = 1; i <= g_maxClients; i++)
	{
		if (is_user_alive(i) && !isZombie(i) && g_leader[i])
			count++;
	}
	
	return count;
}