new const SOUND_INFECT_EXPLODE[] = "zombiemod/infect_explode.wav";

const NADE_INFECT = 7259;
const NADE_INFECT2 = 5283;

const Float:INFECT_EXPLODE_RADIUS = 240.0;

//const Float:INFECTBOMB_MIN_DAMAGE = 40.0;
const Float:INFECTBOMB_MAX_DAMAGE = 100.0;

//const Float:INFECTBOMB2_MIN_DAMAGE = 70.0;
const Float:INFECTBOMB2_MAX_DAMAGE = 200.0;

public InfectBomb::Precache()
{
	precache_sound(SOUND_INFECT_EXPLODE);
}

public InfectBomb::SetModel(ent, const model[])
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
		if (!isZombie(owner))
			return;
		
		if (getGmonster(owner))
		{
			message_begin(MSG_BROADCAST, SVC_TEMPENTITY);
			write_byte(TE_BEAMFOLLOW);
			write_short(ent); // entity
			write_short(g_sprTrail) // sprite
			write_byte(10) // life
			write_byte(10) // width
			write_byte(200) // r
			write_byte(0) // g
			write_byte(100) // b
			write_byte(200) // brightness
			message_end()
			
			set_rendering(ent, kRenderFxGlowShell, 200, 0, 100, kRenderNormal, 16);
			
			set_pev(ent, PEV_NADE_TYPE, NADE_INFECT2);
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
			write_byte(200) // g
			write_byte(0) // b
			write_byte(200) // brightness
			message_end()
			
			set_rendering(ent, kRenderFxGlowShell, 0, 200, 0, kRenderNormal, 16);
			
			set_pev(ent, PEV_NADE_TYPE, NADE_INFECT);
		}
		
		setLastGrenadeTime(owner, get_gametime());
	}
}

public InfectBomb::GrenadeThink(ent)
{
	if (!pev_valid(ent))
		HOOK_RETURN(HAM_IGNORED);
	
	new Float:gameTime = get_gametime();
	
	new Float:dmgTime;
	pev(ent, pev_dmgtime, dmgTime);
	
	if (gameTime < dmgTime)
		HOOK_RETURN(HAM_IGNORED);
	
	if (pev(ent, PEV_NADE_TYPE) == NADE_INFECT || pev(ent, PEV_NADE_TYPE) == NADE_INFECT2)
	{
		infectionExplode(ent);
		HOOK_RETURN(HAM_SUPERCEDE);
	}
	
	HOOK_RETURN(HAM_IGNORED);
}

infectionExplode(ent)
{
	new Float:origin[3];
	pev(ent, pev_origin, origin);
	
	infectionBlastEffect(ent);
	
	emit_sound(ent, CHAN_WEAPON, SOUND_INFECT_EXPLODE, 1.0, ATTN_NORM, 0, PITCH_NORM);
	
	new owner = pev(ent, pev_owner);
	new player = FM_NULLENT;
	
	while ((player = find_ent_in_sphere(player, origin, INFECT_EXPLODE_RADIUS)) != 0)
	{
		if (!is_user_alive(player))
			continue;
		
		if (!isZombie(player))
		{
			new Float:damage;
			if (pev(ent, PEV_NADE_TYPE) == NADE_INFECT)
				damage = INFECTBOMB_MAX_DAMAGE;
			else
				damage = INFECTBOMB2_MAX_DAMAGE;
			
			new Float:armor;
			pev(player, pev_armorvalue, armor);
			
			if (armor >= damage)
			{
				set_pev(player, pev_armorvalue, armor - damage);
				
				emit_sound(player, CHAN_VOICE, "player/bhit_helmet-1.wav", 1.0, ATTN_NORM, 0, PITCH_NORM);
			}
			else
			{
				infectPlayer(player, owner);
			}
			
			sendScreenShake(player, 5.0, 5.0, 1.5);
			sendDamage(player, 0, 0, DMG_ACID, Float:{0.0, 0.0, 0.0});
			setPlayerDataF(player, "m_flVelocityModifier", 0.5);
		}
		else
		{
			new Float:ratio, Float:maxAdd;
			if (pev(ent, PEV_NADE_TYPE) == NADE_INFECT)
			{
				ratio = 1.5;
				maxAdd = 1250.0;
			}
			else
			{
				ratio = 2.0;
				maxAdd = 2000.0;
			}
			
			new Float:health;
			pev(player, pev_health, health);
			
			if (health * ratio > health + maxAdd)
				health += maxAdd;
			else
				health *= ratio;
			
			set_pev(player, pev_health, health);
		}
	}
	
	remove_entity(ent);
}

infectionBlastEffect(ent)
{
	new Float:origin[3];
	pev(ent, pev_origin, origin);
	
	if (pev(ent, PEV_NADE_TYPE) == NADE_INFECT)
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
		write_coord_f(origin[2] + 400.0); // z axis
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
		write_byte(200); // red
		write_byte(0); // green
		write_byte(100); // blue
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
		write_byte(0); // green
		write_byte(100); // blue
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
		write_byte(0); // green
		write_byte(100); // blue
		write_byte(6); // life in 0.1's
		write_byte(40) // decay rate in 0.1's
		message_end();
	}
	
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