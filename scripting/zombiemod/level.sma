#define MAX_LEVEL 30

new g_level[33];
new g_exp[33];
new g_damageExp[33];

new Array:g_dataLevel;
new Array:g_dataExp;

public Level::Init()
{
	RegisterHam(Ham_TakeDamage, "player", "Level@TakeDamage");
	
	g_dataLevel = ArrayCreate(1);
	g_dataExp = ArrayCreate(1);
}

public Level::Disconnect(id)
{
	g_level[id] = 0;
	g_exp[id] = 0;
	g_damageExp[id] = 0;
}

public Level::TakeDamage(id, inflictor, attacker, Float:damage, damageBits)
{
	if (is_user_connected(attacker) && isZombie(attacker) && !isZombie(id))
	{
		if (inflictor == attacker && (damageBits & DMG_BULLET))
		{
			g_damageExp[attacker] += damage;
			
			if (g_damageExp[attacker] > 300)
			{
				g_damageExp[attacker] = 0;
				addExp(attacker, 15);
			}
		}
	}
}

public Level::Killed(id, killer)
{
	if (is_user_connected(killer) && isZombie(killer) != isZombie(id))
	{
		if (isZombie(killer))
			addExp(killer, 25);
		else
			addExp(id, 10);
	}
}

public Level::Infect(id, attacker)
{
	if (is_user_connected(attacker) && isZombie(attacker))
	{
		addExp(attacker, 20);
	}
	
	new Float:maxHealth;
	pev(id, pev_max_health, maxHealth);
	
	if (getNemesis(id) || getGmonster(id) || getMorpheus(id) || getCombiner(id))
		set_pev(id, pev_health, float(get_user_health(id)) + (maxHealth * (0.01 * g_level[id])));
	else
		set_pev(id, pev_health, float(get_user_health(id)) + (maxHealth * (0.05 * g_level[id])));
}

public Level::Save(id, index)
{
	if (index == getDataSize())
	{
		ArrayPushCell(g_dataLevel, g_level[id]);
		ArrayPushCell(g_dataExp, g_exp[id]);
	}
}

public Level::Load(id, index)
{
	g_level[id] = ArrayGetCell(g_dataLevel, index);
	g_exp[id] = ArrayGetCell(g_dataExp, index);
}

stock addExp(id, amount)
{
	g_exp[id] += amount;
	
	while (g_level[id] < MAX_LEVEL && g_exp[id] >= getRequiredExp(id))
	{
		g_exp[id] -= getRequiredExp(id);
		g_level[id]++;
		
		client_print(0, print_chat, "%n 的 Zombie Level 達到 %d 等級!", id, g_level[id]);
	}
	
	set_hudmessage(200, 200, 0, -1.0, 0.8, 0, 0.0, 1.0, 1.0, 1.0, 3);
	show_hudmessage(id, "+ %d Zombie EXP", amount);
}

stock getRequiredExp(id)
{
	return getExpForLevel(g_level[id]);
}

stock getExpForLevel(level)
{
	return 100 + (level * 10);
}

stock getZombieLevel(id)
{
	return g_level[id];
}

stock getZombieExp(id)
{
	return g_exp[id];
}