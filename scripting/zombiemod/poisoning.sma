#define MAX_POISON_LEVEL 6
#define POISON_MAX_DELAY 1.5
#define POISON_MIN_DELAY 0.25

new g_poisonLevel[33];
new g_poisonAttacker[33];
new Float:g_lastPoisonTime[33];

public Poison::Init()
{
	RegisterHam(Ham_TakeDamage, "player", "Poison@TakeDamage_P", 1);
}

public Poison::TakeDamage_P(id, inflictor, attacker, Float:damage, damageBits)
{
	if (!is_user_connected(attacker) || isZombie(id) == isZombie(attacker))
		return;
	
	if (isZombie(attacker) && inflictor == attacker && get_user_weapon(attacker) == CSW_KNIFE && (damageBits & DMG_BULLET))
	{
		if (getGmonster(attacker))
			return;
		
		if ((!getNemesis(attacker) && !getCombiner(attacker)) && get_user_armor(id) > 0)
			return;
		
		if (OnCanPoison(id, attacker) == PLUGIN_HANDLED)
			return;
		
		addPoisoning(id, attacker, 1);
	}
}

public Poison::PlayerPreThink(id)
{
	if (is_user_alive(id) && g_poisonAttacker[id])
	{
		new Float:currentTime = get_gametime();
		new Float:delay = POISON_MAX_DELAY - ((POISON_MAX_DELAY - POISON_MIN_DELAY) / MAX_POISON_LEVEL * g_poisonLevel[id]);
		if (currentTime < g_lastPoisonTime[id] + delay)
			return;
		
		new health = get_user_health(id);
		if (health - 1 <= 0)
		{
			infectPlayer(id, g_poisonAttacker[id]);
			return;
		}
		
		static Float:lastEmitTime[33];
		if (currentTime >= lastEmitTime[id] + 2.0)
		{
			emit_sound(id, CHAN_VOICE, "player/bhit_flesh-3.wav", 1.0, ATTN_NORM, 0, PITCH_NORM);
			lastEmitTime[id] = currentTime;
		}
		
		set_user_health(id, health - 1);
		sendDamage(id, 0, 0, DMG_POISON, Float:{0.0, 0.0, 0.0});
		sendScreenFade(id, 1.0, 0.0, FFADE_IN, {0, 200, 0}, 150);
		
		g_lastPoisonTime[id] = currentTime;
		//client_print(0, print_center, "delay: %.2f", delay);
	}
}

public Poison::Killed(id)
{
	resetPoisoning(id);
}

public Poison::Infect(id)
{
	resetPoisoning(id);
}

public Poison::Humanize(id)
{
	resetPoisoning(id);
}

public Poison::Disconnect(id)
{
	for (new i = 1; i <= g_maxClients; i++)
	{
		if (g_poisonAttacker[i] == id)
			g_poisonAttacker[i] = i;
	}
	
	resetPoisoning(id);
}

stock addPoisoning(id, attacker, level)
{
	g_poisonAttacker[id] = attacker;
	g_lastPoisonTime[id] = get_gametime();
	g_poisonLevel[id] = min(g_poisonLevel[id] + level, MAX_POISON_LEVEL);
}

stock resetPoisoning(id)
{
	g_poisonAttacker[id] = 0;
	g_poisonLevel[id] = 0;
}

stock getPoisonLevel(id)
{
	return g_poisonLevel[id];
}

stock setPoisonLevel(id, value)
{
	g_poisonLevel[id] = value;
}