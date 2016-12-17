const NADE_FLARE = 2349;

public Flare::SetModel(ent, const model[])
{
	if (equal(model[7], "w_smokegrenade.mdl"))
	{
		new Float:dmgTime;
		pev(ent, pev_dmgtime, dmgTime);
		
		if (dmgTime == 0.0)
			return;
		
		new owner = pev(ent, pev_owner);
		if (isZombie(owner))
			return;
		
		set_rendering(ent, kRenderFxGlowShell, 50, 50, 150, kRenderNormal, 16);
		
		// And a colored trail
		message_begin(MSG_BROADCAST, SVC_TEMPENTITY);
		write_byte(TE_BEAMFOLLOW); // TE id
		write_short(ent); // entity
		write_short(g_sprTrail); // sprite
		write_byte(10); // life
		write_byte(10); // width
		write_byte(50); // r
		write_byte(50); // g
		write_byte(150); // b
		write_byte(200); // brightness
		message_end();		
		
		set_pev(ent, PEV_NADE_TYPE, NADE_FLARE);
	}
}

public Flare::GrenadeThink(ent)
{
	if (!pev_valid(ent))
		HOOK_RETURN(HAM_IGNORED);
	
	if (pev(ent, PEV_NADE_TYPE) == NADE_FLARE)
	{
		new Float:gameTime = get_gametime();
		
		new Float:dmgTime;
		pev(ent, pev_dmgtime, dmgTime);
		
		if (gameTime < dmgTime)
			HOOK_RETURN(HAM_IGNORED);
		
		if (!pev(ent, pev_bInDuck))
		{
			emit_sound(ent, CHAN_WEAPON, SOUND_NVG_ON, 1.0, ATTN_NORM, 0, PITCH_NORM);
			
			set_pev(ent, pev_bInDuck, true);
			set_pev(ent, pev_starttime, gameTime);
			set_pev(ent, pev_dmgtime, gameTime + 0.1);
		}
		else
		{
			new Float:explodeTime;
			pev(ent, pev_starttime, explodeTime);
			
			if (gameTime >= explodeTime + 60.0)
			{
				remove_entity(ent);
				HOOK_RETURN(HAM_SUPERCEDE);
			}
			
			new Float:origin[3];
			pev(ent, pev_origin, origin);
			
			message_begin_f(MSG_PAS, SVC_TEMPENTITY, origin);
			write_byte(TE_DLIGHT); // TE id
			write_coord_f(origin[0]); // x
			write_coord_f(origin[1]); // y
			write_coord_f(origin[2]); // z
			write_byte(30); // radius
			write_byte(25); // r
			write_byte(25); // g
			write_byte(100); // b
			write_byte(11); //life
			write_byte(0); //decay rate
			message_end();
			
			message_begin_f(MSG_PVS, SVC_TEMPENTITY, origin);
			write_byte(TE_SPARKS) // TE id
			write_coord_f(origin[0]) // x
			write_coord_f(origin[1]) // y
			write_coord_f(origin[2]) // z
			message_end()
					
			set_pev(ent, pev_dmgtime, gameTime + 1.0);
		}
		
		HOOK_RETURN(HAM_IGNORED);
	}
	
	HOOK_RETURN(HAM_IGNORED);
}