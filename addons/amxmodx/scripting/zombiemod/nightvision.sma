new Float:g_nextScreenFade[33];
new Float:g_screenFadeUntil[33];
new bool:g_nightVisionOn[33];
new bool:g_hasNightVision[33];

new g_lights[32];
new g_defaultLights[32];

public Nvg::Precache()
{
	precache_sound(SOUND_NVG_ON);
	precache_sound(SOUND_NVG_OFF);
}

public Nvg::Init()
{
	register_clcmd("nightvision", "CmdNightVision");
}

public Nvg::NewRound()
{
	arrayset(g_hasNightVision, false, sizeof g_hasNightVision);
}

public Nvg::ScreenFade(id)
{
	new flags = read_data(3);
	if (flags != FFADE_STAYOUT)
	{
		new Float:fadeTime = read_data(1) / float(1 << 12);
		new Float:holdTime = read_data(2) / float(1 << 12);
		
		g_screenFadeUntil[id] = get_gametime() + fadeTime + holdTime;
	}
	else
	{
		g_screenFadeUntil[id] = get_gametime() + 999999.0;
	}
}

public Nvg::LightStyle(style, const lights[])
{
	if (style == 0)
		copy(g_defaultLights, charsmax(g_defaultLights), lights);
}

public Nvg::PlayerPreThink(id)
{
	if (g_nightVisionOn[id])
	{
		new Float:gameTime = get_gametime();
		
		if (gameTime >= g_nextScreenFade[id] && gameTime >= g_screenFadeUntil[id])
		{
			if (!is_user_alive(id))
				sendScreenFade(id, 1.0, 1.0, FFADE_IN, {0, 100, 200}, 100);
			else if (isZombie(id))
				sendScreenFade(id, 1.0, 1.0, FFADE_IN, {200, 0, 0}, 100);
			else
				sendScreenFade(id, 1.0, 1.0, FFADE_IN, {0, 200, 0}, 100);
			
			g_nextScreenFade[id] = gameTime + 1.0;
		}
		
		static Float:nextLightTime[33];
		
		if (is_user_alive(id) && !isZombie(id))
		{
			if (gameTime < nextLightTime[id])
				return;
			
			new Float:origin[3];
			pev(id, pev_origin, origin);
			
			new Float:vector[3];
			velocity_by_aim(id, 250, vector);
			xs_vec_add(origin, vector, origin);
			
			message_begin(MSG_ONE_UNRELIABLE, SVC_TEMPENTITY, _, id);
			write_byte(TE_DLIGHT);
			write_coord_f(origin[0]); // position.x
			write_coord_f(origin[1]); // position.y
			write_coord_f(origin[2]); // position.z
			write_byte(50); // radius in 10's
			write_byte(30); // red
			write_byte(100); // green
			write_byte(30); // blue
			write_byte(3); // life in 0.1's
			write_byte(0) // decay rate in 0.1's
			message_end();
			
			nextLightTime[id] = gameTime + 0.1;
		}
	}
}

public Nvg::ClientPutInServer_P(id)
{
	set_task(0.1, "FixLightStyle", id + TASK_LIGHTSTYLE);
}

public Nvg::Disconnect(id)
{
	remove_task(id + TASK_LIGHTSTYLE);
	
	g_hasNightVision[id] = false;
	g_nightVisionOn[id] = false;
}

public Nvg::PlayerSpawn_P(id)
{
	nightVisionToggle(id, false, false);
}

public Nvg::Killed_P(id)
{
	g_hasNightVision[id] = false;
	nightVisionToggle(id, false, false);
}

public Nvg::Infect(id)
{
	g_hasNightVision[id] = false;
	nightVisionToggle(id, true, false);
}

public Nvg::Humanize(id)
{
	nightVisionToggle(id, false, false);
}

public CmdNightVision(id)
{
	if (is_user_alive(id) && !isZombie(id) && !g_hasNightVision[id])
		return PLUGIN_HANDLED;
	
	if (g_nightVisionOn[id])
	{
		nightVisionToggle(id, false, true);
	}
	else
	{
		nightVisionToggle(id, true, true);
	}
	
	return PLUGIN_HANDLED;
}

public FixLightStyle(taskId)
{
	new id = taskId - TASK_LIGHTSTYLE;
	sendLightStyle(id, 0, g_lights);
}

stock nightVisionToggle(id, bool:toggle, bool:sound=true)
{
	if (toggle)
	{
		if (!is_user_alive(id) || isZombie(id))
			sendLightStyle(id, 0, "#");
		else if (sound)
			emit_sound(id, CHAN_ITEM, SOUND_NVG_ON, 1.0, ATTN_NORM, 0, PITCH_NORM);
		
		g_nextScreenFade[id] = get_gametime();
		g_nightVisionOn[id] = true;
	}
	else
	{
		if (is_user_alive(id) && !isZombie(id) && sound)
			emit_sound(id, CHAN_ITEM, SOUND_NVG_OFF, 1.0, ATTN_NORM, 0, PITCH_NORM);
		
		sendLightStyle(id, 0, g_lights);
		sendScreenFade(id, 0.0, 0.0, FFADE_IN, {0, 0, 0}, 0);
		g_nightVisionOn[id] = false;
	}
}

stock setLights(const lights[])
{
	if (!lights[0])
		copy(g_lights, charsmax(g_lights), g_defaultLights);
	else
		copy(g_lights, charsmax(g_lights), lights);
	
	set_lights(g_lights);
	
	for (new i = 1; i <= g_maxClients; i++)
	{
		if (g_nightVisionOn[i])
		{
			if (!is_user_alive(i) || isZombie(i))
				sendLightStyle(i, 0, "#");
		}
	}
}

stock giveNightVision(id, bool:toggle)
{
	g_hasNightVision[id] = toggle;
}