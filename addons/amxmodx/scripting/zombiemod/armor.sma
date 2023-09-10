#define ARMOR_RATIO 0.0
#define ARMOR_BONUS 1.0

new const SOUND_BOOST[] = "zombiemod/boost.wav";

new Float:g_boost[33];

public Armor::Precache()
{
	precache_sound(SOUND_BOOST);
}

public Armor::Init()
{
	register_clcmd("drop", "CmdDrop");
	
	RegisterHam(Ham_TakeDamage, "player", "Armor@TakeDamage");
	
	set_task(1.0, "ArmorTask", TASK_ARMOR, _, _, "b");
}

public CmdDrop(id)
{
	if (is_user_alive(id) && isZombie(id))
	{
		new amount = 300;
		if (getZombieType(id) == -1)
			amount = 1000;
			
		new armor = get_user_armor(id);
		if (armor < amount)
		{
			client_print(id, print_center, "你的 AP 未滿 %d", amount);
			return PLUGIN_HANDLED;
		}
		
		if (isFrozen(id))
		{
			client_print(id, print_center, "現在不能使用");
			return PLUGIN_HANDLED;
		}
		
		if (g_boost[id] > 0)
		{
			client_print(id, print_center, "暴衝狀態中...")
			return PLUGIN_HANDLED;
		}
			
		boostPlayer(id, 6.0, 1.5);
		set_user_armor(id, armor - amount);
		
		return PLUGIN_HANDLED;
	}
	
	return PLUGIN_CONTINUE;
}

public Armor::TakeDamage(id, inflictor, attacker, Float:damage, damageBits)
{
	if (GetHamReturnStatus() == HAM_SUPERCEDE)
		return HAM_IGNORED;
	
	if (!pev_valid(id))
		return HAM_IGNORED;
	
	if (is_user_connected(attacker) && isZombie(attacker) != isZombie(id))
	{
		if (!isZombie(id))
		{
			if (damageBits & (DMG_DROWN | DMG_FALL))
				return HAM_IGNORED;
			
			new Float:armor;
			pev(id, pev_armorvalue, armor);
			
			if (armor <= 0.0 || getNemesis(attacker))
				return HAM_IGNORED;
			
			new Float:armorRatio = ARMOR_RATIO;
			new Float:armorBonus = ARMOR_BONUS;
			
			if (getCombiner(attacker))
			{
				armorRatio = 0.5;
				armorBonus = 0.5;
			}
			
			new Float:newDamage = armorRatio * damage;
			new Float:armorDamage = (damage - newDamage) * armorBonus;
			
			if (armorDamage > armor)
			{
				armorDamage -= armor;
				armorDamage *= (1 / armorBonus);
				newDamage += armorDamage;
				
				set_pev(id, pev_armorvalue, 0.0);
			}
			else
			{
				set_pev(id, pev_armorvalue, armor - armorDamage);
			}
			
			SetHamParamFloat(4, newDamage);
			return HAM_HANDLED;
		}
		else
		{
			if (getZombieType(id) == -1)
			{
				new Float:armor;
				pev(id, pev_armorvalue, armor);
				
				armor += damage * 0.18;
				set_pev(id, pev_armorvalue, floatmin(armor, 2000.0));
			}
			else
			{
				new Float:armor;
				pev(id, pev_armorvalue, armor);
				
				armor += damage * 0.3;
				set_pev(id, pev_armorvalue, floatmin(armor, 1000.0));
			}
		}
	}
	
	return HAM_IGNORED;
}

public Armor::PainShock(id, inflictor, attacker, Float:damage, damageBits)
{
	if (is_user_connected(attacker) && isZombie(attacker) != isZombie(id))
	{
		if (!isZombie(id))
		{
			if ((~damageBits & (DMG_DROWN | DMG_FALL)) && get_user_armor(id) > 0)
				multiplyPainShock(1.2);
		}
		else
		{
			if (g_boost[id])
				multiplyPainShock(2.0);
		}
	}
}

public Armor::KnockBack(id)
{
	if (g_boost[id])
		multiplyKnockBack(0.25);
}

public Armor::ResetMaxSpeed(id)
{
	if (g_boost[id] > 0)
		set_user_maxspeed(id, get_user_maxspeed(id) * g_boost[id]);
}

public Armor::Killed(id)
{
	if (g_boost[id] > 0)
		removeBoost(id);
}

public Armor::Humanize(id)
{
	if (g_boost[id] > 0)
		removeBoost(id);
}

public Armor::Infect(id)
{
	if (g_boost[id] > 0)
		removeBoost(id);
}

public Armor::PlayerFreeze(id)
{
	g_boost[id] = 0.0;
}

public Armor::Disconnect(id)
{
	g_boost[id] = 0.0;
}

public ArmorTask()
{
	for (new i = 1; i <= g_maxClients; i++)
	{
		new id = i;
		if (!is_user_alive(id) || !isZombie(id))
			continue;
		
		if (getZombieType(id) == -1)
			set_user_armor(id, min(get_user_armor(id) + 10, 2000));
	}
}

public RemoveBoost(taskId)
{
	new id = taskId - TASK_BOOST;
	removeBoost(id);
}

stock getBoost(id)
{
	return g_boost[id];
}

stock boostPlayer(id, Float:duration, Float:speed)
{
	g_boost[id] = speed;
	ExecuteHamB(Ham_CS_Player_ResetMaxSpeed, id);
	
	if (getGmonster(id))
		set_rendering(id, kRenderFxGlowShell, 200, 0, 100, kRenderNormal, 16);
	else if (getNemesis(id))
		set_rendering(id, kRenderFxGlowShell, 200, 0, 0, kRenderNormal, 16);
	else if (getMorpheus(id))
		set_rendering(id, kRenderFxGlowShell, 200, 0, 0, kRenderNormal, 16);
	else
		set_rendering(id, kRenderFxGlowShell, 0, 200, 0, kRenderNormal, 16);

	emit_sound(id, CHAN_VOICE, SOUND_BOOST, 1.0, ATTN_NORM, 0, PITCH_NORM);
	
	remove_task(id + TASK_BOOST);
	set_task(duration, "RemoveBoost", id + TASK_BOOST);
}

stock removeBoost(id)
{
	g_boost[id] = 0.0;
	ExecuteHamB(Ham_CS_Player_ResetMaxSpeed, id);
	
	set_rendering(id);
}