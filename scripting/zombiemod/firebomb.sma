const NADE_FIRE = 4863;
const Float:FIRE_EXPLOSION_RADIUS = 240.0;
const Float:BURN_DURATION_MAX = 12.5;
const Float:BURN_DURATION_MIN = 6.25;
const Float:BURN_DAMAGE = 60.0;

new const SOUND_FIRE_EXPLODE[] = "zombiemod/fire_explode.wav";

new bool:g_isBurning[33];
new g_burnAttacker[33];
new Float:g_burnUntil[33];

public FireBomb::Precache()
{
	precache_sound(SOUND_FIRE_EXPLODE);
}

public FireBomb::SetModel(ent, const model[])
{
	if (!pev_valid(ent))
		return;
	
	if (equal(model[7], "w_hegrenade.mdl"))
	{
		new Float:dmgTime;
		pev(ent, pev_dmgtime, dmgTime);
		
		if (dmgTime == 0.0)
			return;
		
		new owner = pev(ent, pev_owner);
		if (isZombie(owner))
			return;
		
		set_pev(ent, PEV_NADE_TYPE, NADE_FIRE);
	}
}

public FireBomb::GrenadeThink(ent)
{
	if (!pev_valid(ent))
		HOOK_RETURN(HAM_IGNORED);
	
	if (pev(ent, PEV_NADE_TYPE) == NADE_FIRE)
	{
		new Float:gameTime = get_gametime();
		
		new Float:dmgTime;
		pev(ent, pev_dmgtime, dmgTime);
		
		if (dmgTime > gameTime)
			HOOK_RETURN(HAM_IGNORED);
		
		fireExplode(ent);
		HOOK_RETURN(HAM_SUPERCEDE);
	}
	
	HOOK_RETURN(HAM_IGNORED);
}

public FireBomb::PlayerPreThink(id)
{
	if (g_isBurning[id])
	{
		new Float:currentTime = get_gametime();
		
		new Float:origin[3];
		pev(id, pev_origin, origin);
		
		if ((pev(id, pev_flags) & FL_INWATER) || currentTime >= g_burnUntil[id])
		{
			message_begin_f(MSG_PVS, SVC_TEMPENTITY, origin);
			write_byte(TE_SMOKE); // TE id
			write_coord_f(origin[0]); // x
			write_coord_f(origin[1]); // y
			write_coord_f(origin[2]-50); // z
			write_short(g_sprSteam); // sprite
			write_byte(random_num(15, 20)); // scale
			write_byte(5); // framerate
			message_end();
			
			g_isBurning[id] = false;
			g_burnUntil[id] = 0.0;
			g_burnAttacker[id] = 0;
			return;
		}
		
		static Float:updateTime[33]
		if (currentTime < updateTime[id])
			return;
		
		message_begin_f(MSG_PVS, SVC_TEMPENTITY, origin);
		write_byte(TE_SPRITE); // TE id
		write_coord_f(origin[0]+random_float(-5.0, 5.0)); // x
		write_coord_f(origin[1]+random_float(-5.0, 5.0)); // y
		write_coord_f(origin[2]+random_float(-10.0, 10.0)); // z
		write_short(g_sprFire); // sprite
		write_byte(random_num(5, 10)); // scale
		write_byte(200); // brightness
		message_end();
		
		new Float:damage = BURN_DAMAGE;
		OnPlayerBurn(id, g_burnAttacker[id], damage);
		
		new attacker = g_burnAttacker[id];
		if (is_user_connected(attacker))
			client_print(attacker, print_chat, "[debug] burn damage = %f", damage);
		
		new Float:health;
		pev(id, pev_health, health);
		
		if (health < damage)
		{
			ExecuteHamB(Ham_Killed, id, attacker, 0);
		}
		else
		{
			set_pev(id, pev_health, health - damage);
			sendDamage(id, 0, floatround(damage), DMG_BURN, origin);
		}
		
		updateTime[id] = currentTime + 0.5;
	}
}

public FireBomb::Killed(id)
{
	g_isBurning[id] = false;
	g_burnAttacker[id] = 0;
	g_burnUntil[id] = 0.0;
}

public FireBomb::Humanize(id)
{
	g_isBurning[id] = false;
	g_burnAttacker[id] = 0;
	g_burnUntil[id] = 0.0;
}

public FireBomb::Disconnect(id)
{
	for (new i = 1; i <= g_maxClients; i++)
	{
		if (g_burnAttacker[i] == id)
			g_burnAttacker[i] = i;
	}
	
	g_isBurning[id] = false;
	g_burnAttacker[id] = 0;
	g_burnUntil[id] = 0.0;
}

fireExplode(ent)
{
	fireBlastEffects(ent);
	
	emit_sound(ent, CHAN_WEAPON, SOUND_FIRE_EXPLODE, 1.0, ATTN_NORM, 0, PITCH_NORM);
	
	new Float:origin[3];
	pev(ent, pev_origin, origin);
	
	new owner = pev(ent, pev_owner);
	new player = FM_NULLENT;
	
	while ((player = find_ent_in_sphere(player, origin, FIRE_EXPLOSION_RADIUS)) != 0)
	{
		if (!is_user_alive(player) || !isZombie(player))
			continue;
		
		new Float:radiusRatio = 1.0 - entity_range(ent, player) / FIRE_EXPLOSION_RADIUS;
		new Float:burnDuration = floatmax(BURN_DURATION_MAX * radiusRatio, BURN_DURATION_MIN);
		new Float:old = burnDuration;
		
		OnFireExplode(ent, player, burnDuration);
		
		client_print(0, print_chat, "[debug] burn druration: old=%f, new=%f", old, burnDuration);
		
		g_isBurning[player] = true;
		g_burnAttacker[player] = owner;
		
		new Float:until = get_gametime() + burnDuration;
		if (until > g_burnUntil[player])
			g_burnUntil[player] = until;
	}
	
	remove_entity(ent);
}

fireBlastEffects(ent)
{
	new Float:origin[3];
	pev(ent, pev_origin, origin);
	
	message_begin_f(MSG_PVS, SVC_TEMPENTITY, origin);
	write_byte(TE_BEAMCYLINDER); // TE id
	write_coord_f(origin[0]); // x
	write_coord_f(origin[1]); // y
	write_coord_f(origin[2] + 16.0); // z
	write_coord_f(origin[0]); // x axis
	write_coord_f(origin[1]); // y axis
	write_coord_f(origin[2] + 250.0); // z axis
	write_short(g_sprShockwave); // sprite
	write_byte(0); // startframe
	write_byte(0); // framerate
	write_byte(5); // life
	write_byte(25); // width
	write_byte(0); // noise
	write_byte(200); // red
	write_byte(50); // green
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
	write_coord_f(origin[2] + 400.0); // z axis
	write_short(g_sprShockwave); // sprite
	write_byte(0); // startframe
	write_byte(0); // framerate
	write_byte(5); // life
	write_byte(25); // width
	write_byte(0); // noise
	write_byte(200); // red
	write_byte(50); // green
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
	write_byte(200); // red
	write_byte(50); // green
	write_byte(0); // blue
	write_byte(6); // life in 0.1's
	write_byte(40) // decay rate in 0.1's
	message_end();
}