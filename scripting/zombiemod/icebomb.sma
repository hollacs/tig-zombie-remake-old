const Float:ICE_EXPLOSION_RADIUS = 240.0;

const Float:ICE_DURATION_MAX = 4.0;
const Float:ICE_DURATION_MIN = 2.0;

const Float:ICE2_DURATION_MAX = 5.0;
const Float:ICE2_DURATION_MIN = 3.0;

new const SOUND_ICE_EXPLODE[] = "zombiemod/frostnova.wav";
new const SOUND_FROZEN[] = "zombiemod/impalehit.wav";
new const SOUND_UNFROZEN[] = "zombiemod/impalelaunch1.wav";

new bool:g_isFrozen[33];
new Float:g_frozenDuration[33];

public IceBomb::Precache()
{
	precache_sound(SOUND_ICE_EXPLODE);
	precache_sound(SOUND_FROZEN);
	precache_sound(SOUND_UNFROZEN);
}

public IceBomb::SetModel(ent, const model[])
{
	if (!pev_valid(ent))
		return;
	
	if (equal(model[7], "w_flashbang.mdl"))
	{
		new Float:dmgTime;
		pev(ent, pev_dmgtime, dmgTime);
		
		if (dmgTime == 0.0)
			return;
		
		new owner = pev(ent, pev_owner);
		if (isZombie(owner))
			return;
		
		if (getLeader(owner) || getSupporter(owner))
		{
			message_begin(MSG_BROADCAST, SVC_TEMPENTITY);
			write_byte(TE_BEAMFOLLOW);
			write_short(ent); // entity
			write_short(g_sprTrail) // sprite
			write_byte(10) // life
			write_byte(10) // width
			write_byte(50) // r
			write_byte(100) // g
			write_byte(200) // b
			write_byte(200) // brightness
			message_end()
			
			set_rendering(ent, kRenderFxGlowShell, 50, 100, 200, kRenderNormal, 16);
			
			set_pev(ent, PEV_NADE_TYPE, NADE_ICE_SUPER);
		}
		else
		{
			message_begin(MSG_BROADCAST, SVC_TEMPENTITY);
			write_byte(TE_BEAMFOLLOW);
			write_short(ent); // entity
			write_short(g_sprTrail) // sprite
			write_byte(10) // life
			write_byte(10) // width
			write_byte(0) // r
			write_byte(100) // g
			write_byte(200) // b
			write_byte(200) // brightness
			message_end()
			
			set_rendering(ent, kRenderFxGlowShell, 0, 100, 200, kRenderNormal, 16);
			
			set_pev(ent, PEV_NADE_TYPE, NADE_ICE);
		}
	}
}

public IceBomb::GrenadeThink(ent)
{
	if (!pev_valid(ent))
		HOOK_RETURN(HAM_IGNORED);

	new Float:gameTime = get_gametime();
	
	new Float:dmgTime;
	pev(ent, pev_dmgtime, dmgTime);
	
	if (gameTime < dmgTime)
		HOOK_RETURN(HAM_IGNORED);
		
	if (pev(ent, PEV_NADE_TYPE) == NADE_ICE || pev(ent, PEV_NADE_TYPE) == NADE_ICE_SUPER)
	{
		iceExplode(ent);
		HOOK_RETURN(HAM_SUPERCEDE);
	}
	
	HOOK_RETURN(HAM_IGNORED);
}

public IceBomb::PlayerJump(id)
{
	if (g_isFrozen[id])
	{
		new oldButtons = pev(id, pev_oldbuttons);
		if(~oldButtons & IN_JUMP)
			set_pev(id, pev_oldbuttons, oldButtons | IN_JUMP)
	}
}

public IceBomb::ResetMaxSpeed(id)
{
	if (g_isFrozen[id])
		set_user_maxspeed(id, 1.0);
}

public IceBomb::Killed(id)
{
	if (g_isFrozen[id])
		removeFreeze(id)
}

public IceBomb::Humanize(id)
{
	if (g_isFrozen[id])
		removeFreeze(id)
}

public IceBomb::Disconnect(id)
{
	g_isFrozen[id] = false;
	g_frozenDuration[id] = 0.0;
	
	remove_task(id + TASK_FROZEN);
}

public RemoveFreeze(taskId)
{
	new id = taskId - TASK_FROZEN;
	removeFreeze(id);
}

iceExplode(ent)
{
	new Float:origin[3];
	pev(ent, pev_origin, origin);
	
	iceBlastEffects(ent);
	
	emit_sound(ent, CHAN_WEAPON, SOUND_ICE_EXPLODE, 1.0, ATTN_NORM, 0, PITCH_NORM);
	
	new player = FM_NULLENT;
	
	while ((player = find_ent_in_sphere(player, origin, ICE_EXPLOSION_RADIUS)) != 0)
	{
		if (!is_user_alive(player) || !isZombie(player))
			continue;
		
		new Float:radiusRatio = 1.0 - (entity_range(ent, player) / ICE_EXPLOSION_RADIUS);
		
		new Float:original, Float:duration;
		if (pev(ent, PEV_NADE_TYPE) == NADE_ICE)
		{
			original = floatmax(ICE_DURATION_MAX * radiusRatio, ICE_DURATION_MIN);
			
			if (getGmonster(player) > GMONSTER_1ST || getNemesis(player))
				duration = 0.0;
			else
				duration = original;
		}
		else // Super ICE
		{
			original = floatmax(ICE2_DURATION_MAX * radiusRatio, ICE2_DURATION_MIN);
			duration = original;

			if (getGodMode(player))
				duration *= 0.0;	
		}

		OnIceExplode(ent, player, original, duration);
		
		client_print(0, print_chat, "[debug] freeze duration: original=%f, new=%f", original, duration);
		
		if (g_isFrozen[player] && g_frozenDuration[player] > duration)
			duration = g_frozenDuration[player];
		
		freezePlayer(player, duration);
		
		emit_sound(player, CHAN_BODY, SOUND_FROZEN, 1.0, ATTN_NORM, 0, PITCH_NORM);
	}
	
	remove_entity(ent);
}

iceBlastEffects(ent)
{
	new Float:origin[3];
	pev(ent, pev_origin, origin);
	
	if (pev(ent, PEV_NADE_TYPE) == NADE_ICE)
	{
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
		write_byte(0); // red
		write_byte(100); // green
		write_byte(200); // blue
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
		write_byte(0); // red
		write_byte(75); // green
		write_byte(150); // blue
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
		write_byte(75); // green
		write_byte(150); // blue
		write_byte(6); // life in 0.1's
		write_byte(40) // decay rate in 0.1's
		message_end();
	}
	else
	{
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
		write_byte(100); // red
		write_byte(150); // green
		write_byte(200); // blue
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
		write_byte(100); // red
		write_byte(150); // green
		write_byte(250); // blue
		write_byte(200); // brightness
		write_byte(0); // speed
		message_end();
		
		message_begin_f(MSG_PVS, SVC_TEMPENTITY, origin);
		write_byte(TE_DLIGHT);
		write_coord_f(origin[0]); // position.x
		write_coord_f(origin[1]); // position.y
		write_coord_f(origin[2]); // position.z
		write_byte(30); // radius in 10's
		write_byte(100); // red
		write_byte(150); // green
		write_byte(200); // blue
		write_byte(6); // life in 0.1's
		write_byte(40) // decay rate in 0.1's
		message_end();
	}
}

stock freezePlayer(id, Float:duration)
{
	g_isFrozen[id] = true;
	g_frozenDuration[id] = duration;
	
	ExecuteHamB(Ham_CS_Player_ResetMaxSpeed, id);
	
	sendScreenFade(id, 1.0, duration, FFADE_IN, {0, 100, 200}, 120, true);
	sendDamage(id, 0, 0, DMG_DROWN, Float:{0.0, 0.0, 0.0});
	
	set_rendering(id, kRenderFxGlowShell, 0, 100, 200, kRenderNormal, 16);
	
	set_task(duration, "RemoveFreeze", id + TASK_FROZEN);
	
	OnPlayerFreeze(id);
}

stock removeFreeze(id)
{
	remove_task(id + TASK_FROZEN);
	
	emit_sound(id, CHAN_BODY, SOUND_UNFROZEN, 1.0, ATTN_NORM, 0, PITCH_NORM);
	
	g_isFrozen[id] = false;
	g_frozenDuration[id] = 0.0;
	
	ExecuteHamB(Ham_CS_Player_ResetMaxSpeed, id);
	set_rendering(id);
	
	new Float:origin[3];
	pev(id, pev_origin, origin);
	
	message_begin_f(MSG_PVS, SVC_TEMPENTITY, origin);
	write_byte(TE_BREAKMODEL); // TE id
	write_coord_f(origin[0]); // x
	write_coord_f(origin[1]); // y
	write_coord_f(origin[2] + 24.0); // z
	write_coord(10); // size x
	write_coord(10); // size y
	write_coord(10); // size z
	write_coord(random_num(-50, 50)); // velocity x
	write_coord(random_num(-50, 50)); // velocity y
	write_coord(25); // velocity z
	write_byte(10); // random velocity
	write_short(g_modelGlass); // model
	write_byte(10); // count
	write_byte(25); // life
	write_byte(0x01); // flags
	message_end();
}

stock bool:isFrozen(id)
{
	return g_isFrozen[id];
}