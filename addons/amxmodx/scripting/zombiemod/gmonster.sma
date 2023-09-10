#define G1_MUTATION 0.3
#define G2_MUTATION 0.4

new const GMONSTER_HP[3]  = {3000, 2750, 4000};
new const GMONSTER_HP2[3] = {1250, 1000, 1500};
new const Float:GMONSTER_GRAVITY[3] = {0.95, 0.9, 0.7};
new const Float:GMONSTER_SPEED[3] = {0.95, 1.1, 1.25};
new const GMONSTER_MODEL[3][] = {"birkin1", "birkin2", "birkin3"};
new const Float:GMONSTER_PAINSHOCK[3] = {1.0, 1.2, 1.4};
new const Float:GMONSTER_KNOCKBACK[3] = {1.0, 0.6, 0.4};

new g_gmonster[33];

public Gmonster::Precache()
{
	precache_model("models/zombiemod/v_knife_birkin.mdl");
	precachePlayerModel("birkin1");
	precachePlayerModel("birkin2");
	precachePlayerModel("birkin3");
}

public Gmonster::Init()
{
	RegisterHam(Ham_TakeDamage, "player", "Gmonster@TakeDamage");
	RegisterHam(Ham_TakeDamage, "player", "Gmonster@TakeDamage_P", 1);
}

public Gmonster::NewRound()
{
	arrayset(g_gmonster, false, sizeof g_gmonster);
}

public Gmonster::PlayerPreThink(id)
{
	if (is_user_alive(id) && isZombie(id))
	{
		if (g_gmonster[id] == GMONSTER_1ST)
		{
			if (get_user_health(id) <= pev(id, pev_max_health) * G1_MUTATION)
			{
				set_hudmessage(200, 0, 100, -1.0, 0.2, 1, 0.0, 3.0, 1.0, 1.0, 1);
				show_hudmessage(0, "G-2 Detected!");
				
				g_gmonster[id] = GMONSTER_2ND;
				infectPlayer(id);
				setGodMode(id, 3.0, true);
				
				emit_sound(id, CHAN_VOICE, SOUND_MUTATION, 1.0, ATTN_NORM, 0, PITCH_NORM);
			}
		}
		else if (g_gmonster[id] == GMONSTER_2ND)
		{
			if (get_user_health(id) <= pev(id, pev_max_health) * G2_MUTATION)
			{
				set_hudmessage(200, 0, 100, -1.0, 0.2, 1, 0.0, 3.0, 1.0, 1.0, 1);
				show_hudmessage(0, "G-3 Detected!");
				
				g_gmonster[id] = GMONSTER_3RD;
				infectPlayer(id);
				setGodMode(id, 3.0, true);
				
				emit_sound(id, CHAN_VOICE, SOUND_MUTATION, 1.0, ATTN_NORM, 0, PITCH_NORM);
			}
			
			if (!user_has_weapon(id, CSW_HEGRENADE))
			{
				if (get_gametime() >= getLastGrenadeTime(id) + 30.0)
				{
					give_item(id, "weapon_hegrenade");
				}
			}
		}
		else if (g_gmonster[id] == GMONSTER_3RD)
		{
			if (!user_has_weapon(id, CSW_HEGRENADE))
			{
				if (get_gametime() >= getLastGrenadeTime(id) + 25.0)
				{
					give_item(id, "weapon_hegrenade");
				}
			}
		}
	}
}

public Gmonster::TakeDamage(id, inflictor, attacker, Float:damage, damageBits)
{
	if (!is_user_connected(attacker) || isZombie(attacker) == isZombie(id))
		return HAM_IGNORED;
	
	if (!isZombie(id) && inflictor == attacker && get_user_weapon(attacker) == CSW_KNIFE && (damageBits & DMG_BULLET))
	{
		if (g_gmonster[attacker] == GMONSTER_3RD)
		{
			SetHamParamFloat(4, damage * 2.5);
			return HAM_HANDLED;
		}
	}
	
	return HAM_IGNORED;
}

public Gmonster::TakeDamage_P(id, inflictor, attacker, Float:damage, damageBits)
{
	if (!isZombie(id) && is_user_connected(attacker) && isZombie(attacker) && inflictor == attacker && get_user_weapon(attacker) == CSW_KNIFE)
	{
		if (g_gmonster[attacker] == GMONSTER_2ND)
		{
			if (get_user_armor(id) <= 0)
				infectPlayer(id, attacker);
		}
	}
}

public Gmonster::ResetMaxSpeed(id)
{
	if (isZombie(id) && g_gmonster[id])
	{
		new g = g_gmonster[id]-1;
		set_user_maxspeed(id, get_user_maxspeed(id) * GMONSTER_SPEED[g]);
	}
}

public Gmonster::PainShock(id)
{
	if (isZombie(id) && g_gmonster[id])
	{
		new g = g_gmonster[id]-1;
		multiplyPainShock(GMONSTER_PAINSHOCK[g]);
	}
}

public Gmonster::KnockBack(id)
{
	if (isZombie(id) && g_gmonster[id])
	{
		new g = g_gmonster[id]-1;
		multiplyKnockBack(GMONSTER_KNOCKBACK[g]);
	}
}

public Gmonster::KnifeDeploy(id)
{
	if (g_gmonster[id])
	{
		set_pev(id, pev_viewmodel2, "models/zombiemod/v_knife_birkin.mdl");
	}
}

public Gmonster::Killed_P(id)
{
	g_gmonster[id] = false;
}

public Gmonster::Disconnect(id)
{
	g_gmonster[id] = false;
}

public Gmonster::Humanize(id)
{
	g_gmonster[id] = false;
}

public Gmonster::Infect(id)
{
	if (g_gmonster[id])
	{
		new g = g_gmonster[id]-1;
		
		resetZombie(id);
		g_gmonster[id] = g + 1;
		
		set_user_health(id, GMONSTER_HP[g] + (countHumans() * GMONSTER_HP2[g]));
		set_pev(id, pev_max_health, float(get_user_health(id)));
		
		set_user_gravity(id, GMONSTER_GRAVITY[g]);
		
		cs_set_user_model(id, GMONSTER_MODEL[g]);
		
		setZombieType(id, -1);
		
		if (g_gmonster[id] != GMONSTER_1ST)
			give_item(id, "weapon_hegrenade");
	}
}

stock getGmonster(id)
{
	return g_gmonster[id];
}

stock setGmonster(id, value)
{
	g_gmonster[id] = value;
}

stock countGmonsters()
{
	new count = 0;
	for (new i = 1; i <= g_maxClients; i++)
	{
		if (is_user_alive(i) && isZombie(i) && g_gmonster[i])
			count++;
	}
	
	return count;
}