#define N1_MUTATION 0.3

new const NEMESIS_HP[2]  = {3000, 4000};
new const NEMESIS_HP2[2] = {1250, 1500};
new const Float:NEMESIS_GRAVITY[2] = {0.95, 0.7};
new const Float:NEMESIS_SPEED[2] = {1.0, 1.25};
new const NEMESIS_MODEL[2][] = {"nemesis", "nemesis2"};
new const Float:NEMESIS_PAINSHOCK[2] = {1.4, 1.2};
new const Float:NEMESIS_KNOCKBACK[2] = {0.4, 0.5};

const Float:NEMESIS_ROCKET_RADIUS = 240.0;
const Float:NEMESIS_ROCKET_DAMAGE = 350.0;

new g_nemesis[33];

new Float:g_rpgLastFireTime = -99999.0;
new bool:g_isRpgReloaded;

public Nemesis::Precache()
{
	precache_model("models/zombiemod/v_knife_nemesis.mdl");
	precache_model("models/zombiemod/v_knife_nemesis2.mdl");
	precache_model("models/zombiemod/p_knife_nemesis.mdl");
	precachePlayerModel("nemesis");
	precachePlayerModel("nemesis2");
}

public Nemesis::Init()
{
	RegisterHam(Ham_TakeDamage, "player", "Nemesis@TakeDamage");
	
	register_touch("rpgrocket", "*", "Nemesis@RocketTouch");
	register_think("rpgrocket", "Nemesis@RocketThink");
}

public Nemesis::NewRound()
{
	arrayset(g_nemesis, false, sizeof g_nemesis);
	
	new ent = FM_NULLENT;
	
	while ((ent = find_ent_by_class(ent, "rpgrocket")) != 0)
	{
		if (pev_valid(ent))
			nemesisRocketKill(ent);
	}
}

public Nemesis::PlayerPreThink(id)
{
	if (is_user_alive(id) && isZombie(id))
	{
		if (g_nemesis[id] == NEMESIS_1ST)
		{
			if (get_user_health(id) <= pev(id, pev_max_health) * N1_MUTATION)
			{
				set_hudmessage(255, 0, 0, -1.0, 0.2, 1, 0.0, 3.0, 1.0, 1.0, 1);
				show_hudmessage(0, "N-2 Detected!");
				
				g_nemesis[id] = NEMESIS_2ND;
				infectPlayer(id);
				setGodMode(id, 3.0, true);
				
				emit_sound(id, CHAN_VOICE, SOUND_MUTATION, 1.0, ATTN_NORM, 0, PITCH_NORM);
			}
		}
	}
}

public Nemesis::CmdStart(id, uc)
{
	if (is_user_alive(id) && g_nemesis[id] == NEMESIS_1ST)
	{
		if (!g_isRpgReloaded)
		{
			if (get_gametime() >= g_rpgLastFireTime + 30.0)
			{
				g_isRpgReloaded = true;
				client_print(0, print_center, "Nemesis' rocket launcher has been reloaded.");
			}
		}
		else if ((get_uc(uc, UC_Buttons) & IN_USE) && (~pev(id, pev_oldbuttons) & IN_USE))
		{
			nemesisRocketLaunch(id);
		}
	}
}

public Nemesis::RocketTouch(rocket, toucher)
{
	new owner = pev(rocket, pev_owner);
	
	new Float:origin[3];
	pev(rocket, pev_origin, origin);
	
	new ent = FM_NULLENT;
	
	while ((ent = find_ent_in_sphere(ent, origin, NEMESIS_ROCKET_RADIUS)) != 0)
	{
		if (!pev_valid(ent))
			continue;
		
		static Float:takeDamage;
		pev(ent, pev_takedamage, takeDamage);
		
		if (takeDamage == DAMAGE_NO)
			continue;
		
		if (is_user_alive(ent) && isZombie(ent))
			continue;
		
		new Float:radius = entity_range(rocket, ent);
		new Float:ratio  = (1.0 - radius / NEMESIS_ROCKET_RADIUS);
		new Float:damage = ratio * NEMESIS_ROCKET_DAMAGE;
		new damageBit = DMG_GRENADE;
		
		if (ent == toucher)
		{
			if (isEntBreakable(ent))
			{
				force_use(rocket, ent);
				continue;
			}
			else
			{
				damage = NEMESIS_ROCKET_DAMAGE;
				damageBit |= DMG_ALWAYSGIB;
			}
		}
		
		if (is_user_alive(ent))
			sendScreenShake(ent, (ratio * 15.0), (ratio * 7.5), 1.0 + (ratio * 4.0));
		
		ExecuteHamB(Ham_TakeDamage, ent, rocket, owner, damage, damageBit);
	}
	
	new Float:pos[3];
	pos = origin; pos[2] += 30.0;
	
	message_begin_f(MSG_PAS, SVC_TEMPENTITY, pos);
	write_byte(TE_EXPLOSION);
	write_coord_f(pos[0]);
	write_coord_f(pos[1]);
	write_coord_f(pos[2]);
	write_short(g_sprFExplo); // spr
	write_byte(25); // scale
	write_byte(30); // framerate
	write_byte(TE_EXPLFLAG_NONE); // flags
	message_end();
	
	message_begin_f(MSG_PAS, SVC_TEMPENTITY, pos);
	write_byte(TE_EXPLOSION);
	write_coord_f(pos[0] + random_float(-64.0, 64.0));
	write_coord_f(pos[1] + random_float(-64.0, 64.0));
	write_coord_f(pos[2]);
	write_short(g_sprEExplo); // spr
	write_byte(30); // scale
	write_byte(30); // framerate
	write_byte(TE_EXPLFLAG_NONE); // flags
	message_end();
	
	nemesisRocketKill(rocket);
}

public Nemesis::RocketThink(ent)
{
	nemesisRocketKill(ent);
}

public Nemesis::TakeDamage(id, inflictor, attacker, Float:damage, damageBits)
{
	if (!is_user_connected(attacker) || isZombie(attacker) == isZombie(id))
		return;
	
	if (isZombie(attacker))
	{
		// Not knife
		if (inflictor != attacker || get_user_weapon(attacker) != CSW_KNIFE || (~damageBits & DMG_BULLET))
			return;
		
		if (g_nemesis[attacker] == NEMESIS_2ND)
		{
			SetHamParamFloat(4, damage * 1.2);
		}
	}
}

public Nemesis::ResetMaxSpeed(id)
{
	if (isZombie(id) && g_nemesis[id])
	{
		new n = g_nemesis[id]-1;
		set_user_maxspeed(id, get_user_maxspeed(id) * NEMESIS_SPEED[n]);
	}
}

public Nemesis::PainShock(id)
{
	if (isZombie(id) && g_nemesis[id])
	{
		new n = g_nemesis[id]-1;
		multiplyPainShock(NEMESIS_PAINSHOCK[n]);
	}
}

public Nemesis::KnockBack(id)
{
	if (isZombie(id) && g_nemesis[id])
	{
		new n = g_nemesis[id]-1;
		multiplyKnockBack(NEMESIS_KNOCKBACK[n]);
	}
}

public Nemesis::KnifeDeploy(id)
{
	if (g_nemesis[id] == NEMESIS_1ST)
	{
		set_pev(id, pev_viewmodel2, "models/zombiemod/v_knife_nemesis.mdl");
		set_pev(id, pev_weaponmodel2, "models/zombiemod/p_knife_nemesis.mdl");
	}
	else if (g_nemesis[id] == NEMESIS_2ND)
	{
		set_pev(id, pev_viewmodel2, "models/zombiemod/v_knife_nemesis2.mdl");
	}
}

public Nemesis::Killed_P(id)
{
	g_nemesis[id] = false;
}

public Nemesis::Disconnect(id)
{
	g_nemesis[id] = false;
}

public Nemesis::Humanize(id)
{
	g_nemesis[id] = false;
}

public Nemesis::Infect(id)
{
	if (g_nemesis[id])
	{
		new n = g_nemesis[id]-1;
		
		resetZombie(id);
		g_nemesis[id] = n + 1;

		set_user_health(id, NEMESIS_HP[n] + (countHumans() * NEMESIS_HP2[n]));
		set_pev(id, pev_max_health, float(get_user_health(id)));
		
		set_user_gravity(id, NEMESIS_GRAVITY[n]);
		
		cs_set_user_model(id, NEMESIS_MODEL[n]);
		
		setZombieType(id, -1);
		
		g_rpgLastFireTime = -99999.0;
	}
}

nemesisRocketLaunch(id)
{
	new Float:vector[3];
	pev(id, pev_punchangle, vector);
	vector[0] -= random_float(5.0, 10.0);
	vector[1] += random_float(-2.5, 2.5);
	vector[2] += random_float(-2.5, 2.5);
	set_pev(id, pev_punchangle, vector);
	
	emit_sound(id, CHAN_WEAPON, "weapons/rocketfire1.wav", 1.0, ATTN_NORM, 0, PITCH_NORM);
	
	new ent = create_entity("info_target");
	
	entity_set_model(ent, "models/rpgrocket.mdl");
	entity_set_size(ent, Float:{-2.0, -2.0, -2.0}, Float:{2.0, 2.0, 2.0});
	
	set_pev(ent, pev_classname, "rpgrocket");
	set_pev(ent, pev_solid, SOLID_BBOX);
	set_pev(ent, pev_effects, pev(ent, pev_effects) | EF_LIGHT);
	set_pev(ent, pev_movetype, MOVETYPE_FLY);
	set_pev(ent, pev_owner, id);
	
	ExecuteHam(Ham_EyePosition, id, vector);
	entity_set_origin(ent, vector);
	
	pev(id, pev_v_angle, vector);
	set_pev(ent, pev_angles, vector);
	
	velocity_by_aim(id, 1000, vector);
	set_pev(ent, pev_velocity, vector);
	
	set_pev(ent, pev_nextthink, get_gametime() + 10.0);
	
	//emit_sound(ent, CHAN_VOICE, "weapons/rocket1.wav", 1.0, ATTN_NORM, 0, PITCH_NORM);
	
	message_begin(MSG_BROADCAST, SVC_TEMPENTITY);
	write_byte(TE_BEAMFOLLOW);
	write_short(ent); // entity
	write_short(g_sprTrail); // sprite
	write_byte(10); // life
	write_byte(5); // width
	write_byte(100); // r
	write_byte(100); // g
	write_byte(100); // b
	write_byte(200); // brightness
	message_end();
	
	g_isRpgReloaded = false;
	g_rpgLastFireTime = get_gametime();
}

nemesisRocketKill(ent)
{
	//emit_sound(ent, CHAN_VOICE, "weapons/rocket1.wav", 1.0, ATTN_NORM, SND_STOP, PITCH_NORM);
	remove_entity(ent);
}

stock getNemesis(id)
{
	return g_nemesis[id];
}

stock setNemesis(id, value)
{
	g_nemesis[id] = value;
}

stock countNemesis()
{
	new count = 0;
	for (new i = 1; i <= g_maxClients; i++)
	{
		if (is_user_alive(i) && isZombie(i) && g_nemesis[i])
			count++;
	}
	
	return count;
}