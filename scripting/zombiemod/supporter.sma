new g_supporter[33];

public Supporter::Init()
{
	RegisterHam(Ham_TakeDamage, "player", "Supporter@TakeDamage");
}

public Supporter::NewRound()
{
	arrayset(g_supporter, false, sizeof g_supporter);
}

public Supporter::TakeDamage(id, inflictor, attacker, Float:damage, damageBits)
{
	if (isZombie(id) && is_user_connected(attacker) && !isZombie(attacker) 
	&& inflictor == attacker && (damageBits & DMG_BULLET) && get_user_weapon(attacker) == CSW_M4A1)
	{
		SetHamParamFloat(4, damage * 1.5);
		return HAM_HANDLED;
	}
	
	return HAM_IGNORED;
}

public Supporter::Humanize(id)
{
	if (g_supporter[id])
	{
		set_user_health(id, 200);
		set_pev(id, pev_max_health, 300.0);
		
		set_user_armor(id, 300);
		setMaxArmor(id, 300.0);
		
		set_user_gravity(id, 0.95);
		
		cs_reset_user_model(id);
		
		give_item(id, "weapon_m4a1");
		wa_giveWeaponFullAmmo(id, CSW_M4A1);
		
		give_item(id, "weapon_knife");
		
		give_item(id, "weapon_flashbang");
		
		setResource(id, 400);
	}
}

public Supporter::ResetMaxSpeed(id)
{
	if (!isZombie(id) && g_supporter[id])
	{
		set_user_maxspeed(id, get_user_maxspeed(id) * 1.125);
	}
}

public Supporter::Killer_P(id)
{
	g_supporter[id] = false;
}

public Supporter::Infect(id)
{
	g_supporter[id] = false;
}

public Supporter::Disconnect(id)
{
	g_supporter[id] = false;
}

public Supporter::SetModel(ent, const model[])
{
	if (!pev_valid(ent))
		return;
	
	new className[32];
	pev(ent, pev_classname, className, charsmax(className));
	
	if (equal(className, "weaponbox"))
	{
		if (equal(model[7], "w_m4a1.mdl"))
			set_pev(ent, pev_nextthink, get_gametime());
	}
}

public Supporter::KnifeKnockBack(id, attacker, &Float:power)
{
	if (!g_supporter[attacker])
		return;
	
	if (!isKnifeStabbing(attacker))
		return;
	
	if (getNemesis(id) || getGmonster(id))
		return;
	
	power = 650.0;
}

stock getSupporter(id)
{
	return g_supporter[id];
}

stock setSupporter(id, value)
{
	g_supporter[id] = value;
}

stock countSupporter()
{
	new count = 0;
	for (new i = 1; i <= g_maxClients; i++)
	{
		if (is_user_alive(i) && !isZombie(i) && g_supporter[i])
			count++;
	}
	
	return count;
}