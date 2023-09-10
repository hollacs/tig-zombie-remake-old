const COMBINER_HP  = 3000;
const COMBINER_HP2 = 1500;
const Float:COMBINER_GRAVITY = 0.8;
const Float:COMBINER_SPEED = 1.0;
const Float:COMBINER_PAINSHOCK = 1.15;
const Float:COMBINER_KNOCKBACK = 0.75;
new const COMBINER_MODEL[] = "combiner";

new g_combiner[33];

public Combiner::Precache()
{
	precache_model("models/zombiemod/v_knife_combiner.mdl");
	precachePlayerModel("combiner");
}

public Combiner::Init()
{
}

public Combiner::NewRound()
{
	arrayset(g_combiner, false, sizeof g_combiner);
}

public Combiner::ResetMaxSpeed(id)
{
	if (isZombie(id) && g_combiner[id])
	{
		set_user_maxspeed(id, get_user_maxspeed(id) * COMBINER_SPEED);
	}
}

public Combiner::KnifeDeploy(id)
{
	if (g_combiner[id])
		set_pev(id, pev_viewmodel2, "models/zombiemod/v_knife_combiner.mdl");
}

public Combiner::PlayerPreThink(id)
{
	if (isZombie(id) && g_combiner[id])
	{
		if (get_gametime() >= getLastGrenadeTime(id) + 30.0)
		{
			give_item(id, "weapon_hegrenade");
		}
	}
}

public Combiner::Killed_P(id)
{
	g_combiner[id] = false;
}

public Combiner::Disconnect(id)
{
	g_combiner[id] = false;
}

public Combiner::Humanize(id)
{
	g_combiner[id] = false;
}

public Combiner::Infect(id)
{
	if (g_combiner[id])
	{
		resetZombie(id);
		g_combiner[id] = true;
		
		set_user_health(id, COMBINER_HP + (countHumans() * COMBINER_HP2));
		set_pev(id, pev_max_health, float(get_user_health(id)));
		
		set_user_gravity(id, COMBINER_GRAVITY);
		
		cs_set_user_model(id, COMBINER_MODEL);
		
		setZombieType(id, -1);
	}
}

public Combiner::PainShock(id)
{
	if (isZombie(id) && g_combiner[id])
	{
		multiplyPainShock(COMBINER_PAINSHOCK);
	}
}

public Combiner::KnockBack(id)
{
	if (isZombie(id) && g_combiner[id])
	{
		multiplyKnockBack(COMBINER_KNOCKBACK);
	}
}

stock getCombiner(id)
{
	return g_combiner[id];
}

stock setCombiner(id, value)
{
	g_combiner[id] = value;
}

stock countCombiners()
{
	new count = 0;
	for (new i = 1; i <= g_maxClients; i++)
	{
		if (is_user_alive(i) && isZombie(i) && g_combiner[i])
			count++;
	}
	
	return count;
}