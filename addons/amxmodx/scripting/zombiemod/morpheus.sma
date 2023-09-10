const MORPHEUS_HP  = 3000;
const MORPHEUS_HP2 = 1250;
const Float:MORPHEUS_GRAVITY = 0.9;
const Float:MORPHEUS_SPEED = 0.825;
const Float:MORPHEUS_PAINSHOCK = 1.0;
const Float:MORPHEUS_KNOCKBACK = 0.6;
new const MORPHEUS_MODEL[] = "morpheus";

new g_morpheus[33];

public Morpheus::Precache()
{
	precache_model("models/zombiemod/v_knife_combiner.mdl");
	precachePlayerModel("morpheus");
}

public Morpheus::Init()
{
}

public Morpheus::NewRound()
{
	arrayset(g_morpheus, false, sizeof g_morpheus);
}

public Morpheus::ResetMaxSpeed(id)
{
	if (isZombie(id) && g_morpheus[id])
	{
		set_user_maxspeed(id, get_user_maxspeed(id) * MORPHEUS_SPEED);
	}
}

public Morpheus::KnifeDeploy(id)
{
	if (g_morpheus[id])
		set_pev(id, pev_viewmodel2, "models/zombiemod/v_knife_combiner.mdl");
}

public Morpheus::Killed_P(id)
{
	g_morpheus[id] = false;
}

public Morpheus::Disconnect(id)
{
	g_morpheus[id] = false;
}

public Morpheus::Humanize(id)
{
	g_morpheus[id] = false;
}

public Morpheus::Infect(id)
{
	if (g_morpheus[id])
	{
		resetZombie(id);
		g_morpheus[id] = true;

		set_user_health(id, MORPHEUS_HP + (countHumans() * MORPHEUS_HP2));
		set_pev(id, pev_max_health, float(get_user_health(id)));
		
		set_user_gravity(id, MORPHEUS_GRAVITY);
		
		cs_set_user_model(id, MORPHEUS_MODEL);
		
		setZombieType(id, -1);
	}
}

public Morpheus::PainShock(id)
{
	if (isZombie(id) && g_morpheus[id])
	{
		multiplyPainShock(MORPHEUS_PAINSHOCK);
	}
}

public Morpheus::KnockBack(id)
{
	if (isZombie(id) && g_morpheus[id])
	{
		multiplyKnockBack(MORPHEUS_KNOCKBACK);
	}
}

stock getMorpheus(id)
{
	return g_morpheus[id];
}

stock setMorpheus(id, value)
{
	g_morpheus[id] = value;
}

stock countMorpheus()
{
	new count = 0;
	for (new i = 1; i <= g_maxClients; i++)
	{
		if (is_user_alive(i) && isZombie(i) && g_morpheus[i])
			count++;
	}
	
	return count;
}