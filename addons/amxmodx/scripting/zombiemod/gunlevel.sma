const LEVEL_GUNS = (1<<CSW_GLOCK18)|(1<<CSW_USP)|(1<<CSW_P228)|(1<<CSW_FIVESEVEN)|(1<<CSW_ELITE)|
				(1<<CSW_M3)|(1<<CSW_XM1014)|
				(1<<CSW_TMP)|(1<<CSW_MAC10)|(1<<CSW_MP5NAVY)|(1<<CSW_UMP45)|(1<<CSW_P90)|
				(1<<CSW_GALIL)|(1<<CSW_FAMAS)|(1<<CSW_SG552)|(1<<CSW_AUG)|
				(1<<CSW_G3SG1)|(1<<CSW_SG550)|(1<<CSW_AWP)|(1<<CSW_SCOUT)|
				(1<<CSW_M249);

new g_gunLevel[33][CSW_P90+1];
new g_gunExp[33][CSW_P90+1];
new Float:g_gunDamage[33][CSW_P90+1];

new Array:g_dataGunLevel;
new Array:g_dataGunExp;

public GunLv::Init()
{
	RegisterHam(Ham_TakeDamage, "player", "GunLv@TakeDamage");
		
	g_dataGunLevel = ArrayCreate(CSW_P90+1);
	g_dataGunExp = ArrayCreate(CSW_P90+1);
}

public GunLv::Disconnect(id)
{
	for (new i = CSW_P228; i <= CSW_P90; i++)
	{
		g_gunDamage[id][i] = 0.0;
		g_gunLevel[id][i] = 0;
		g_gunExp[id][i] = 0;
	}
}

public GunLv::TakeDamage(id, inflictor, attacker, Float:damage, damageBits)
{
	if (is_user_connected(attacker) && isZombie(id) && !isZombie(attacker) && (damageBits & DMG_BULLET) && inflictor == attacker)
	{
		new weapon = get_user_weapon(attacker);
		if ((1 << weapon) & LEVEL_GUNS)
		{
			g_gunDamage[attacker][weapon] += damage;
			
			if (g_gunDamage[attacker][weapon] >= 750)
			{
				g_gunDamage[attacker][weapon] = 0.0;
				addGunExp(attacker, weapon, 10);
			}
		}
		
		damage += damage * (g_gunLevel[attacker][weapon] * 0.03333);
		SetHamParamFloat(4, damage);
	}
}

public GunLv::ClientDeath(killer, victim, weapon, hit, teamKill)
{
	if (killer != victim && !teamKill && !isZombie(killer))
	{
		if ((1 << weapon) & LEVEL_GUNS)
		{
			addGunExp(killer, weapon, 15, false);
		}
	}
}

public GunLv::Save(id, index)
{
	new level[CSW_P90+1], exp[CSW_P90+1];
	level = g_gunLevel[id];
	exp = g_gunExp[id];
	
	if (index == getDataSize())
	{
		ArrayPushArray(g_dataGunLevel, level);
		ArrayPushArray(g_dataGunExp, exp);
	}
	else
	{
		ArraySetArray(g_dataGunLevel, index, level);
		ArraySetArray(g_dataGunExp, index, exp);
	}
}


public GunLv::Load(id, index)
{
	ArrayGetArray(g_dataGunLevel, index, g_gunLevel[id]);
	ArrayGetArray(g_dataGunExp, index, g_gunExp[id]);
}

stock addGunExp(id, weapon, amount, bool:show=true)
{
	g_gunExp[id][weapon] += amount;
	
	while (g_gunExp[id][weapon] >= getRequiredGunExp(id, weapon))
	{
		g_gunExp[id][weapon] -= getRequiredGunExp(id, weapon);
		g_gunLevel[id][weapon]++;
		
		client_print(0, print_chat, "%n 的 %s 達到 %d 等級!", id, GUN_NAMES[weapon], g_gunLevel[id][weapon]);
	}

	if (show)
	{
		set_hudmessage(0, 255, 0, -1.0, 0.8, 0, 0.0, 1.0, 1.0, 1.0, 3);
		show_hudmessage(id, "+ %d %s EXP", amount, GUN_NAMES[weapon]);
	}
}

stock getRequiredGunExp(id, weapon)
{
	return gunGunExpForLevel(g_gunLevel[id][weapon]);
}

stock gunGunExpForLevel(level)
{
	return 100 + (level * 10);
}

stock bool:isLevelGun(weapon)
{
	return bool:((1 << weapon) & LEVEL_GUNS);
}

stock getGunLevel(id, weapon)
{
	return g_gunLevel[id][weapon];
}

stock setGunLevel(id, weapon, value)
{
	g_gunLevel[id][weapon] = value;
}

stock getGunExp(id, weapon)
{
	return g_gunExp[id][weapon];
}