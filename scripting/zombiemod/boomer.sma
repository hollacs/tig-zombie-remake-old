const BOOMER_HP = 500;
const BOOMER_HP2 = 150;
const Float:BOOMER_GRAVITY = 1.0;
const Float:BOOMER_SPEED = 0.875;
const Float:BOOMER_PAINSHOCK = 1.35;
const Float:BOOMER_KNOCKBACK = 0.25;
new const BOOMER_MODEL[] = "boomer";

const Float:BOOMER_EXPLODE_RADIUS = 260.0;
const Float:BOOMER_EXPLODE_DAMAGE_MAX = 300.0;
const Float:BOOMER_EXPLODE_DAMAGE_MIN = 100.0;

new const SOUND_BOOMER_EXPLODE[][] = {"zombiemod/boom1.wav", "zombiemod/boom2.wav", "zombiemod/boom3.wav"};

new g_boomer[33];

public Boomer::Precache()
{
	precacheMoreSound(SOUND_BOOMER_EXPLODE, sizeof SOUND_BOOMER_EXPLODE);
	
	precache_model("models/zombiemod/v_knife_boomer.mdl");
	precachePlayerModel("boomer");
}

public Boomer::Init()
{
	register_clcmd("drop", "CmdBoomerDrop");
}

public CmdBoomerDrop(id)
{
	if (is_user_alive(id) && isZombie(id) && g_boomer[id])
	{
		user_kill(id, 1);
		return PLUGIN_HANDLED;
	}
	
	return PLUGIN_CONTINUE;
}

public Boomer::NewRound()
{
	arrayset(g_boomer, false, sizeof g_boomer);
}

public Boomer::ResetMaxSpeed(id)
{
	if (isZombie(id) && g_boomer[id])
	{
		set_user_maxspeed(id, get_user_maxspeed(id) * BOOMER_SPEED);
	}
}

public Boomer::KnifeDeploy(id)
{
	if (g_boomer[id])
		set_pev(id, pev_viewmodel2, "models/zombiemod/v_knife_boomer.mdl");
}

public Boomer::Spawn_P(id)
{
}

public Boomer::Killed(id)
{
	if (isZombie(id) && g_boomer[id])
	{
		boomerExplode(id);
	}
}

public Boomer::Killed_P(id)
{
	g_boomer[id] = false;
}

public Boomer::Disconnect(id)
{
	g_boomer[id] = false;
}

public Boomer::Humanize(id)
{
	g_boomer[id] = false;
}

public Boomer::Infect(id)
{
	if (g_boomer[id])
	{
		resetZombie(id);
		g_boomer[id] = true;

		set_user_health(id, BOOMER_HP + (countHumans() * BOOMER_HP2));
		set_pev(id, pev_max_health, float(get_user_health(id)));
		
		set_user_gravity(id, BOOMER_GRAVITY);
		
		cs_set_user_model(id, BOOMER_MODEL);
		
		setZombieType(id, -1);
	}
}

public Boomer::PainShock(id)
{
	if (isZombie(id) && g_boomer[id])
	{
		multiplyPainShock(BOOMER_PAINSHOCK);
	}
}

public Boomer::KnockBack(id)
{
	if (isZombie(id) && g_boomer[id])
	{
		multiplyKnockBack(BOOMER_KNOCKBACK);
	}
}

stock boomerExplode(id)
{
	new Float:origin[3];
	pev(id, pev_origin, origin);
	
	boomerBlastEffect(origin);
	
	emitRandomSound(id, CHAN_WEAPON, SOUND_BOOMER_EXPLODE, sizeof SOUND_BOOMER_EXPLODE, 1.0, ATTN_NORM, 0, PITCH_NORM);

	new player = FM_NULLENT;
	while ((player = find_ent_in_sphere(player, origin, BOOMER_EXPLODE_RADIUS)) != 0)
	{
		if (!is_user_alive(player) || id == player)
			continue;
		
		if (!isZombie(player))
		{
			new Float:damage =  floatmax((1.0 - entity_range(id, player) / BOOMER_EXPLODE_RADIUS) * BOOMER_EXPLODE_DAMAGE_MAX, BOOMER_EXPLODE_DAMAGE_MIN)
			
			new Float:armor;
			pev(player, pev_armorvalue, armor);
			
			if (armor >= damage)
			{
				set_pev(player, pev_armorvalue, armor - damage);
				emit_sound(player, CHAN_VOICE, "player/bhit_helmet-1.wav", 1.0, ATTN_NORM, 0, PITCH_NORM);
			}
			else
			{
				infectPlayer(player, id);
			}
			
			sendDamage(player, 0, 0, DMG_ACID, Float:{0.0, 0.0, 0.0});
			setPlayerDataF(player, "m_flVelocityModifier", 0.5);
		}
		else
		{
			const Float:ratio = 1.5;
			const Float:maxAdd = 1500.0;
			
			new Float:health;
			pev(player, pev_health, health);
			
			if (health * ratio > health + maxAdd)
				health += maxAdd;
			else
				health *= ratio;
			
			set_pev(player, pev_health, health);
		}
	}
}

stock boomerBlastEffect(Float:origin[3])
{
	message_begin_f(MSG_PVS, SVC_TEMPENTITY, origin);
	write_byte(TE_BEAMCYLINDER); // TE id
	write_coord_f(origin[0]); // x
	write_coord_f(origin[1]); // y
	write_coord_f(origin[2] + 16.0); // z
	write_coord_f(origin[0]); // x axis
	write_coord_f(origin[1]); // y axis
	write_coord_f(origin[2] + 280.0); // z axis
	write_short(g_sprShockwave); // sprite
	write_byte(0); // startframe
	write_byte(0); // framerate
	write_byte(5); // life
	write_byte(25); // width
	write_byte(0); // noise
	write_byte(0); // red
	write_byte(200); // green
	write_byte(0); // blue
	write_byte(200); // brightness
	write_byte(0); // speed
	message_end();
	
	message_begin_f(MSG_PVS, SVC_TEMPENTITY, origin);
	write_byte(TE_BEAMCYLINDER); // TE id
	write_coord_f(origin[0]); // x
	write_coord_f(origin[1]); // y
	write_coord_f(origin[2] + 16.0); // z
	write_coord_f(origin[0]); // x axis
	write_coord_f(origin[1]); // y axis
	write_coord_f(origin[2] + 450.0); // z axis
	write_short(g_sprShockwave); // sprite
	write_byte(0); // startframe
	write_byte(0); // framerate
	write_byte(5); // life
	write_byte(25); // width
	write_byte(0); // noise
	write_byte(0); // red
	write_byte(200); // green
	write_byte(0); // blue
	write_byte(200); // brightness
	write_byte(0); // speed
	message_end();
	
	message_begin_f(MSG_PVS, SVC_TEMPENTITY, origin);
	write_byte(TE_DLIGHT);
	write_coord_f(origin[0]); // position.x
	write_coord_f(origin[1]); // position.y
	write_coord_f(origin[2]); // position.z
	write_byte(30); // radius in 10's
	write_byte(0); // red
	write_byte(200); // green
	write_byte(0); // blue
	write_byte(6); // life in 0.1's
	write_byte(40) // decay rate in 0.1's
	message_end();
	
	message_begin_f(MSG_PVS, SVC_TEMPENTITY, origin);
	write_byte(TE_PARTICLEBURST);
	write_coord_f(origin[0]);
	write_coord_f(origin[1]);
	write_coord_f(origin[2]);
	write_short(75); // radius
	write_byte(63); // particle color
	write_byte(4) // duration * 10 (will be randomized a bit)
	message_end();
}

stock getBoomer(id)
{
	return g_boomer[id];
}

stock setBoomer(id, value)
{
	g_boomer[id] = value;
}

stock countBoomer()
{
	new count = 0;
	for (new i = 1; i <= g_maxClients; i++)
	{
		if (is_user_alive(i) && isZombie(i) && g_boomer[i])
			count++;
	}
	
	return count;
}