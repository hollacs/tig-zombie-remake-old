new const MUSIC_DEFAULT[] = "sound/zombiemod/Raccoon_City.mp3";
new const Float:MUSIC_DEFAULT_TIME = 107.0

new const MUSIC_GMONSTER[] = "sound/zombiemod/The_First_Malformation_of_G.mp3";
new Float:MUSIC_GMONSTER_TIME = 125.0;

new const MUSIC_GMONSTER2[] = "sound/zombiemod/The_Second_Malformation_of_G.mp3";
new Float:MUSIC_GMONSTER2_TIME = 97.0;

new const MUSIC_GMONSTER3[] = "sound/zombiemod/The_Third_Malformation_of_G.mp3";
new Float:MUSIC_GMONSTER3_TIME = 137.0;

new const MUSIC_NEMESIS[][] = {"sound/zombiemod/Unstoppable_Nemesis.mp3", "sound/zombiemod/Menacing_Nemesis.mp3"};
new Float:MUSIC_NEMESIS_TIME[] = {108.0, 90.0}

new const MUSIC_NEMESIS2[] = "sound/zombiemod/Nemesis_Final_Metamorphosis.mp3";
new Float:MUSIC_NEMESIS2_TIME = 220.0;

new const MUSIC_FINAL[] = "sound/zombiemod/Final_Battle.mp3";
new Float:MUSIC_FINAL_TIME = 107.0;

new const SOUND_EVENT[] = "zombiemod/event.wav";
new const SOUND_DESTORYED[] = "zombiemod/destoryed.wav";
new const SOUND_DETECTED[] = "zombiemod/detected.wav";
new const SOUND_STARTUP[] = "zombiemod/gamestartup.wav";
new const SOUND_WINZOMBIE[][] = {"zombiemod/win_zombie1.wav", "zombiemod/win_zombie2.wav", "zombiemod/win_zombie3.wav"};
new const SOUND_WINHUMAN[] = "zombiemod/win_human.wav";

new bool:g_isGameStarted;
new bool:g_allowRespawn;
new g_bossPlayerId;
new g_leaderPlayerId;
new g_gameMode;
new g_winStatus;

public GameRules::Precache()
{
	precache_sound(SOUND_STARTUP);
	precache_sound(SOUND_EVENT);
	precache_sound(SOUND_DESTORYED);
	precache_sound(SOUND_DETECTED);
	precache_sound(SOUND_WINHUMAN);
	
	for (new i = 0; i < sizeof SOUND_WINZOMBIE; i++)
		precache_sound(SOUND_WINZOMBIE[i]);
	
	precache_generic(MUSIC_GMONSTER);
	precache_generic(MUSIC_GMONSTER2);
	precache_generic(MUSIC_GMONSTER3);
	precache_generic(MUSIC_NEMESIS2);
	precache_generic(MUSIC_FINAL);
	precache_generic(MUSIC_DEFAULT);
	
	for (new i = 0; i < sizeof MUSIC_NEMESIS; i++)
		precache_generic(MUSIC_NEMESIS[i]);
	
	OrpheuRegisterHook(OrpheuGetFunction("InstallGameRules"), "OnInstallGameRules_P", OrpheuHookPost);
	
	// Create fog
	new ent = create_entity("env_fog");
	DispatchKeyValue(ent, "density", "0.0013");
	DispatchKeyValue(ent, "rendercolor", "90 70 70");
	DispatchSpawn(ent);
}

public GameRules::Init()
{
	register_message(get_user_msgid("SendAudio"), "OnMsgSendAudio");
	register_message(get_user_msgid("TextMsg"), "OnMsgTextMsg");
	
	OrpheuRegisterHookFromObject(g_pGameRules, "Think", "CGameRules", "OnGameRulesThink_P", OrpheuHookPost);
	OrpheuRegisterHookFromObject(g_pGameRules, "CheckWinConditions", "CGameRules", "OnCheckWinConditions");
	OrpheuRegisterHookFromObject(g_pGameRules, "FPlayerCanRespawn", "CGameRules", "OnPlayerCanRespawn");
}

public OnInstallGameRules_P()
{
	g_pGameRules = OrpheuGetReturn();
}

public OnMsgSendAudio(msgId, msgDest, id)
{
	new audio[32];
	get_msg_arg_string(2, audio, charsmax(audio));
	
	if (equal(audio, "%!MRAD_terwin"))
	{
		g_winStatus = WinStatus_Terrorist;
		playSound(0, SOUND_WINZOMBIE[random(sizeof SOUND_WINZOMBIE)]);
		return PLUGIN_HANDLED;
	}
	else if (equal(audio, "%!MRAD_ctwin"))
	{
		g_winStatus = WinStatus_CT;
		playSound(0, SOUND_WINHUMAN);
		return PLUGIN_HANDLED;
	}
	else if (equal(audio, "%!MRAD_rounddraw"))
	{
		g_winStatus = WinStatus_Draw;
		playSound(0, SOUND_WINHUMAN);
		return PLUGIN_HANDLED;
	}
	
	return PLUGIN_CONTINUE;
}

public OnMsgTextMsg(msgId, msgDest, id)
{
	new message[32];
	get_msg_arg_string(2, message, charsmax(message));
	
	if (equal(message, "#Terrorists_Win"))
	{
		set_dhudmessage(255, 0, 0, -1.0, 0.2, 0, 0.0, 3.0, 1.0, 1.0);
		show_dhudmessage(0, "Zombies Win!");
		
		return PLUGIN_HANDLED;
	}
	else if (equal(message, "#CTs_Win"))
	{
		set_dhudmessage(0, 255, 0, -1.0, 0.2, 0, 0.0, 3.0, 1.0, 1.0);
		show_dhudmessage(0, "Survivors Win!");
		
		return PLUGIN_HANDLED;
	}
	else if (equal(message, "#Target_Saved"))
	{
		set_dhudmessage(0, 255, 0, -1.0, 0.2, 0, 0.0, 3.0, 1.0, 1.0);
		show_dhudmessage(0, "Humans have been survived...");
		
		return PLUGIN_HANDLED;
	}
	
	return PLUGIN_CONTINUE;
}

public OnGameRulesThink_P()
{
	// Check if round time has expired
	if (!getGameRules2("m_bFreezePeriod") && !getGameRules("m_iRoundWinStatus") && timeRemaining() < 1)
	{
		// Not enough players
		if (!getGameRules("m_bFirstConnected"))
		{
			terminateRound2(5.0, WinStatus_Draw, Event_Round_Draw, "#Round_Draw", "rounddraw");
		}
		else
		{
			if (g_bossPlayerId && g_leaderPlayerId && !countLeaders())
				terminateRound2(5.0, WinStatus_Terrorist, Event_Terrorists_Win, "#Terrorists_Win", "terwin", true);
			else if (countHumans())
				terminateRound2(5.0, WinStatus_CT, Event_CTs_Win, "#Target_Saved", "ctwin", true);
		}
		
		setGameRulesF("m_fRoundCount", getGameRulesF("m_fRoundCount") + 60.0);
	}
}

public OrpheuHookReturn:OnCheckWinConditions()
{
	if (getGameRules("m_bFirstConnected") && getGameRules("m_iRoundWinStatus"))
		return OrpheuSupercede;
	
	countTeamPlayers();
	
	new numTerrorists = getGameRules("m_iNumSpawnableTerrorist");
	new numCts = getGameRules("m_iNumSpawnableCT");
	
	if (numTerrorists + numCts < 3)
	{
		setGameRules("m_bFirstConnected", false);
	}
	
	if (!getGameRules("m_bFirstConnected") && numTerrorists + numCts >= 3)
	{
		server_print("test ...");
		log_message("World triggered ^"Game_Commencing^"");
		
		setGameRules2("m_bFreezePeriod", false);
		setGameRules("m_bCompleteReset", true);
		
		terminateRound2(3.0, WinStatus_Draw, Event_Round_Draw, "#Game_Commencing");
		setGameRules("m_bFirstConnected", true);
	
		return OrpheuSupercede;
	}
	
	if (getGameRules("m_iRoundWinStatus"))
		return OrpheuSupercede;
	
	if (g_isGameStarted)
	{
		new deadZombies;
		for (new i = 1; i <= g_maxClients; i++)
		{
			if (is_user_connected(i) && !is_user_alive(i) && isZombie(i))
				deadZombies++;
		}
		
		if (!countHumans())
		{
			terminateRound2(5.0, WinStatus_Terrorist, Event_Terrorists_Win, "#Terrorists_Win", "terwin", true);
		}
		else if ((!g_allowRespawn && !countZombies()) || (!countZombies() && !deadZombies))
		{
			terminateRound2(5.0, WinStatus_CT, Event_CTs_Win, "#CTs_Win", "ctwin", true);
		}
	}
	else if (!countHumans())
	{
		terminateRound2(5.0, WinStatus_Draw, Event_Round_Draw, "#Round_Draw", "rounddraw");
	}
	
	return OrpheuSupercede;
}

public OrpheuHookReturn:OnPlayerCanRespawn(this, id)
{
	if (getPlayerData(id, "m_iNumSpawns") > 0)
		return OrpheuIgnored;
	
	if (!g_isGameStarted && (1 <= getPlayerData(id, "m_iTeam") <= 2) && !isJoiningTeam(id))
		OrpheuSetReturn(true);
	else
		OrpheuSetReturn(false);
	
	return OrpheuOverride;
}

public GameRules::EntSpawn(ent)
{
	static const objectiveClasses[][] = 
	{
		"func_bomb_target",
		"info_bomb_target",
		"info_vip_start",
		"func_vip_safetyzone",
		"func_escapezone",
		"hostage_entity",
		"monster_scientist",
		"func_hostage_rescue",
		"info_hostage_rescue",
		"func_buyzone"
	};
	
	if (pev_valid(ent))
	{
		static className[32];
		pev(ent, pev_classname, className, charsmax(className));
		
		for (new i = 0; i < sizeof objectiveClasses; i++)
		{
			if (equal(className, objectiveClasses[i]))
			{
				remove_entity(ent);
				HOOK_RETURN(FMRES_SUPERCEDE);
			}
		}
	}
	
	HOOK_RETURN(FMRES_IGNORED);
}

public GameRules::NewRound()
{
	g_isGameStarted = false;
	g_allowRespawn = false;
	g_bossPlayerId = 0;
	g_winStatus = 0;
	
	setLights("");
	
	remove_task(TASK_ROUNDSTART);
	stopMusic(0);
	
	if (getGameRules("m_bCompleteReset"))
	{
		g_gameMode = GAMEMODE_NORMAL_G;
	}
	
	for (new i = 1; i < g_maxClients; i++)
	{
		if (is_user_connected(i))
			setZombie(i, false);
	}
}

public GameRules::RoundStart()
{
	set_dhudmessage(0, 255, 0, -1.0, 0.2, 0, 0.0, 5.0, 1.0, 1.0);
	show_dhudmessage(0, "The game will begin in 15 seconds...");
	
	set_task(15.0, "MakeGameStart", TASK_ROUNDSTART);
}

public GameRules::RoundEnd()
{
	switch (g_gameMode)
	{
		case GAMEMODE_NORMAL_G:
		{
			if (g_winStatus == WinStatus_CT)
			{
				if (g_bossPlayerId)
				{
					if (countGmonsters())
						g_gameMode = GAMEMODE_GMONSTER;
					else
						g_gameMode = GAMEMODE_NORMAL_N;
				}
				else
					g_gameMode = GAMEMODE_NORMAL_G;
			}
			else if (getGameRules("m_iRoundWinStatus") == WinStatus_Terrorist)
			{
				g_gameMode = GAMEMODE_NORMAL_G;
			}
		}
		case GAMEMODE_NORMAL_N:
		{
			if (g_winStatus == WinStatus_CT)
			{
				if (g_bossPlayerId)
				{
					if (countNemesis())
						g_gameMode = GAMEMODE_NEMESIS;
					else
						g_gameMode = GAMEMODE_FINAL;
				}
				else
					g_gameMode = GAMEMODE_NORMAL_N;
			}
			else if (g_winStatus == WinStatus_Terrorist)
			{
				g_gameMode = GAMEMODE_NORMAL_G;
			}
		}
		case GAMEMODE_GMONSTER:
		{
			if (g_winStatus == WinStatus_CT)
			{
				if (countGmonsters())
					g_gameMode = GAMEMODE_NORMAL_G;
				else
					g_gameMode = GAMEMODE_NORMAL_N;
			}
			else if (g_winStatus == WinStatus_Terrorist)
			{
				g_gameMode = GAMEMODE_NORMAL_G;
			}
		}
		case GAMEMODE_NEMESIS:
		{
			if (g_winStatus == WinStatus_CT)
			{
				if (countNemesis())
					g_gameMode = GAMEMODE_NORMAL_N;
				else
					g_gameMode = GAMEMODE_FINAL;
			}
			else if (g_winStatus == WinStatus_Terrorist)
			{
				g_gameMode = GAMEMODE_NORMAL_G;
			}
		}
		case GAMEMODE_FINAL:
		{
			if (g_winStatus == WinStatus_CT)
			{
				new g = countGmonsters();
				new n = countNemesis();
				
				if (g && n)
					g_gameMode = GAMEMODE_FINAL;
				else if (n)
					g_gameMode = GAMEMODE_NEMESIS;
				else if (g)
					g_gameMode = GAMEMODE_GMONSTER;
				else
					g_gameMode = GAMEMODE_FINAL;
			}
			else if (g_winStatus == WinStatus_Terrorist)
			{
				g_gameMode = GAMEMODE_NORMAL_G;
			}
		}
	}
	
	new addMoney, exp;
	
	if (g_winStatus == WinStatus_CT)
	{
		if (g_gameMode == GAMEMODE_FINAL)
		{
			// Boss died
			if (!countGmonsters() || !countNemesis())
			{
				addMoney = 1000;
				exp = 75;
			}
			else
			{
				addMoney = 800;
				exp = 60;
			}
		}
		else
		{
			// Boss appeared
			if (g_bossPlayerId)
			{
				// Boss died
				if (!countGmonsters() && !countNemesis())
				{
					addMoney = 700;
					exp = 50;
				}
				else
				{
					addMoney = 600;
					exp = 40;
				}
			}
			else
			{
				addMoney = 500;
				exp = 30;
			}
		}
		
		for (new i = 1; i <= g_maxClients; i++)
		{
			if (is_user_alive(i) && !isZombie(i))
			{
				addAccount(i, addMoney);
				addExp(i, exp);
			}
		}
		
		client_print(0, print_chat, "* 所有生還者獲得 $%d 及 %dEXP.", addMoney, exp);
	}
	else if (g_winStatus == WinStatus_Terrorist)
	{
		addMoney = 500;
		exp = 35;
		
		for (new i = 1; i <= g_maxClients; i++)
		{
			if (is_user_alive(i) && isZombie(i))
			{
				addAccount(i, addMoney);
				addExp(i, exp)
			}
		}
		
		client_print(0, print_chat, "* 所有喪屍獲得 $%d 及 %dEXP.", addMoney, exp);
	}
	
	stopMusic(0);
}

public GameRules::PlayerSpawn(id)
{
	if (1 <= getPlayerData(id, "m_iTeam") <= 2)
	{
		if (isZombie(id))
			setPlayerData(id, "m_iTeam", TEAM_TERRORIST);
		else
			setPlayerData(id, "m_iTeam", TEAM_CT);
	}
}

public GameRules::PlayerSpawn_P(id)
{
	if (is_user_alive(id))
	{
		if (isZombie(id))
			infectPlayer(id);
		else
			humanizePlayer(id);
	}
}

public GameRules::Killed(id)
{
	if (getGmonster(id))
	{
		set_dhudmessage(50, 100, 200, -1.0, 0.25, 0, 0.0, 3.0, 1.0, 1.0);
		show_dhudmessage(0, "G-Virus Monster 被消滅");
		
		playSound(0, SOUND_DESTORYED);
		
		if (g_gameMode == GAMEMODE_GMONSTER || g_gameMode == GAMEMODE_NORMAL_G)
		{
			g_allowRespawn = false;
			
			stopMusic(0);
			playMusicTask(3.0);
		}
	}
	else if (getNemesis(id))
	{
		set_dhudmessage(50, 100, 200, -1.0, 0.25, 0, 0.0, 3.0, 1.0, 1.0);
		show_dhudmessage(0, "Nemesis 已死亡");
		
		playSound(0, SOUND_DESTORYED);
		
		if (g_gameMode == GAMEMODE_NEMESIS || g_gameMode == GAMEMODE_NORMAL_N)
		{
			g_allowRespawn = false;
			
			stopMusic(0);
			playMusicTask(3.0);
		}
	}
	else if (getLeader(id))
	{
		set_dhudmessage(50, 100, 200, -1.0, 0.25, 0, 0.0, 3.0, 1.0, 1.0);
		show_dhudmessage(0, "Leader 已死亡");
		
		playSound(0, SOUND_DESTORYED);
	}
}

public GameRules::Killed_P(id, killer)
{
	if (canPlayerRespawn(id))
	{
		remove_task(id + TASK_RESPAWN);
		set_task(5.0, "RespawnPlayer", id + TASK_RESPAWN);
	}
}

public GameRules::Disconnect(id)
{
	if (g_bossPlayerId == id)
		g_bossPlayerId = 0;
	
	if (g_leaderPlayerId == id)
		g_leaderPlayerId = 0;
	
	remove_task(id + TASK_RESPAWN);
}

public GameRules::Infect(id)
{
	if (getGmonster(id))
	{
		switch (getGmonster(id))
		{
			case GMONSTER_2ND:
			{
				playSound(0, SOUND_DETECTED);
				
				if (g_gameMode == GAMEMODE_GMONSTER || g_gameMode == GAMEMODE_NORMAL_G)
				{
					stopMusic(0);
					playMusicTask(5.0);
				}
			}
			case GMONSTER_3RD:
			{
				playSound(0, SOUND_DETECTED);
				
				if (g_gameMode == GAMEMODE_GMONSTER || g_gameMode == GAMEMODE_NORMAL_G)
				{
					stopMusic(0);
					playMusicTask(5.0);
				}
			}
		}
	}
	else if (getNemesis(id))
	{
		if (getNemesis(id) == NEMESIS_2ND)
		{
			playSound(0, SOUND_DETECTED);
			
			if (g_gameMode == GAMEMODE_NEMESIS || g_gameMode == GAMEMODE_NORMAL_N)
			{
				stopMusic(0);
				playMusicTask(5.0);
			}
		}
	}
}

public GameRules::PlayMusic(&Float:delay)
{
	switch (g_gameMode)
	{
		case GAMEMODE_NORMAL_G, GAMEMODE_GMONSTER:
		{
			if (!is_user_alive(g_bossPlayerId))
			{
				playMusic(0, MUSIC_DEFAULT);
				delay = MUSIC_DEFAULT_TIME;
			}
			else
			{
				new player = g_bossPlayerId;
				
				switch (getGmonster(player))
				{
					case GMONSTER_1ST:
					{
						playMusic(0, MUSIC_GMONSTER);
						delay = MUSIC_GMONSTER_TIME;
					}
					case GMONSTER_2ND:
					{
						playMusic(0, MUSIC_GMONSTER2);
						delay = MUSIC_GMONSTER2_TIME;
					}
					case GMONSTER_3RD:
					{
						playMusic(0, MUSIC_GMONSTER3);
						delay = MUSIC_GMONSTER3_TIME;
					}
				}
			}
		}
		case GAMEMODE_NORMAL_N, GAMEMODE_NEMESIS:
		{
			if (!is_user_alive(g_bossPlayerId))
			{
				playMusic(0, MUSIC_DEFAULT);
				delay = MUSIC_DEFAULT_TIME;
			}
			else
			{
				new player = g_bossPlayerId;
				
				switch (getNemesis(player))
				{
					case NEMESIS_1ST:
					{
						new rand = random(sizeof MUSIC_NEMESIS);
						playMusic(0, MUSIC_NEMESIS[rand]);
						delay = MUSIC_NEMESIS_TIME[rand];
					}
					case NEMESIS_2ND:
					{
						playMusic(0, MUSIC_NEMESIS2);
						delay = MUSIC_NEMESIS2_TIME;
					}
				}
			}
		}
		case GAMEMODE_FINAL:
		{
			playMusic(0, MUSIC_FINAL);
			delay = MUSIC_FINAL_TIME;
		}
	}
}

public MakeGameStart()
{
	new players[32], numPlayers;
	
	// Store player in array
	for (new i = 1; i <= g_maxClients; i++)
	{
		if (!is_user_connected(i))
			continue;
		
		if ((1 <= getPlayerData(i, "m_iTeam") <= 2) && !isJoiningTeam(i))
			players[numPlayers++] = i;
	}
	
	// Not enough players
	if (numPlayers < 3)
	{
		set_task(2.0, "TaskCountPlayers", TASK_ROUNDSTART, .flags="b");
		return;
	}
	
	OnGameStart();
	
	// Respawn all dead players
	for (new i = 0; i < numPlayers; i++)
	{
		new player = players[i];
		
		if (!is_user_alive(player))
			ExecuteHam(Ham_CS_RoundRespawn, player);
	}
	
	new rands[32], numRands;
	rands = players;
	numRands = numPlayers;
	
	if (numPlayers >= 6)
	{
		if (g_gameMode == GAMEMODE_FINAL)
		{
			new player1 = getRandomPlayer(rands, numRands);
			setLeader(player1, LEADER_MALE);
			humanizePlayer(player1);
			
			new player2 = getRandomPlayer(rands, numRands);
			setLeader(player2, LEADER_FEMALE);
			humanizePlayer(player2);
			
			g_leaderPlayerId = 33;
			
			set_hudmessage(50, 100, 200, 0.025, 0.3, 0, 0.0, 3.0, 1.0, 1.0, 2);
			show_hudmessage(0, "%n 成為 Leader^n%n 成為 Leader", player1, player2);
		}
		else
		{
			new player = getRandomPlayer(rands, numRands);
			
			setLeader(player, random_num(LEADER_MALE, LEADER_FEMALE));
			humanizePlayer(player);
			
			g_leaderPlayerId = player;
			
			set_hudmessage(50, 100, 200, 0.025, 0.3, 0, 0.0, 3.0, 1.0, 1.0, 2);
			show_hudmessage(0, "%n 成為 Leader", player);
		}
	}
	
	switch (g_gameMode)
	{
		case GAMEMODE_NORMAL_G, GAMEMODE_NORMAL_N:
		{
			// Start the game
			new numZombies = 0;
			new maxZombies = floatround(numPlayers * 0.25);
					
			while (numZombies < maxZombies)
			{
				new player = getRandomPlayer(rands, numRands);
				
				setFirstZombie(player, true);
				infectPlayer(player);
				
				give_item(player, "weapon_hegrenade");
				set_pev(player, pev_health, pev(player, pev_health) * 3.0);
				
				numZombies++;
			}
			
			setLights("d");
			
			playSound(0, SOUND_STARTUP);
			playMusicTask(3.0);
			
			set_dhudmessage(200, 100, 0, -1.0, 0.2, 0, 0.0, 4.0, 1.0, 1.0);
			show_dhudmessage(0, "Resident Evil");
			
			g_allowRespawn = true;
			g_isGameStarted = true;
		}
		case GAMEMODE_GMONSTER:
		{
			new player = getRandomPlayer(rands, numRands);
			
			setGmonster(player, GMONSTER_1ST);
			infectPlayer(player);
			g_bossPlayerId = player;
			
			setLights("c");
			
			playSound(0, SOUND_EVENT);
			playMusicTask(8.0);
			
			set_dhudmessage(200, 0, 100, -1.0, 0.2, 0, 0.0, 4.0, 1.0, 1.0);
			show_dhudmessage(0, "G-Virus Monster Appeared!");
			
			g_allowRespawn = true;
			g_isGameStarted = true;
		}
		case GAMEMODE_NEMESIS:
		{
			new player = getRandomPlayer(rands, numRands);
			
			setNemesis(player, NEMESIS_1ST);
			infectPlayer(player);
			g_bossPlayerId = player;
				
			setLights("c");
			
			playSound(0, SOUND_EVENT);
			playMusicTask(8.0);
			
			set_dhudmessage(255, 0, 0, -1.0, 0.2, 0, 0.0, 4.0, 1.0, 1.0);
			show_dhudmessage(0, "Nemesis Appeared!");
			
			g_allowRespawn = true;
			g_isGameStarted = true;
		}
		case GAMEMODE_FINAL:
		{
			new player = getRandomPlayer(rands, numRands);
			setGmonster(player, GMONSTER_1ST);
			setZombie(player, true);
			
			player = getRandomPlayer(rands, numRands);
			setNemesis(player, NEMESIS_1ST);
			setZombie(player, true);
			
			for (new i = 0; i < numPlayers; i++)
			{
				new player = players[i];
				if (isZombie(player))
					infectPlayer(player);
			}
			
			g_bossPlayerId = 33;
			
			setLights("b");
			
			playSound(0, SOUND_EVENT);
			playMusicTask(8.0);
			
			set_dhudmessage(50, 100, 200, -1.0, 0.2, 0, 0.0, 4.0, 1.0, 1.0);
			show_dhudmessage(0, "G-Virus Monster & Nemesis Appeared!");
			
			g_allowRespawn = false;
			g_isGameStarted = true;
		}
	}
	
	new numSuppoters = 0;
	new maxSuppoters = floatround(numPlayers * 0.25);
			
	while (numSuppoters < maxSuppoters)
	{
		new player = getRandomPlayer(rands, numRands);
		
		setSupporter(player, true);
		humanizePlayer(player);
		
		numSuppoters++;
	}
}

public TaskCountPlayers()
{
	new count = 0;
	for (new i = 1; i <= g_maxClients; i++)
	{
		if (!is_user_connected(i))
			continue;
		
		if ((1 <= getPlayerData(i, "m_iTeam") <= 2) && !isJoiningTeam(i))
			count++;
	}
	
	if (count >= 3)
		remove_task(TASK_ROUNDSTART);
	else
		client_print(0, print_center, "Looking for %d more players...", 3 - count);
}

public RespawnPlayer(taskid)
{
	new id = taskid - TASK_RESPAWN;
	
	if (canPlayerRespawn(id))
	{
		randomRespawnAs(id)
		ExecuteHam(Ham_CS_RoundRespawn, id);
		setGodMode(id, 3.0, true);
	}
}

randomRespawnAs(id)
{
	enum
	{
		TYPE_GMONSTER = 1,
		TYPE_NEMESIS,
		TYPE_COMBINER,
		TYPE_MORPHEUS,
		TYPE_BOOMER
	};
	
	new types[5] = {1, 2, 3, 4, 5}, numTypes = 5;
	
	while (numTypes)
	{
		new rand = random(numTypes);
		new type = types[rand];
		
		// Remove from the list
		types[rand] = types[--numTypes];
		
		switch (type)
		{
			case TYPE_GMONSTER:
			{
				if (g_gameMode != GAMEMODE_NORMAL_G)
					continue;
				
				if (g_bossPlayerId)
					continue;
				
				new chance = 18;
				if (timeRemaining() <= 110.0)
					chance = 5;
				
				if (random_num(0, chance) != 0)
					continue;
				
				setGmonster(id, GMONSTER_1ST);
				
				g_bossPlayerId = id;
				playSound(0, SOUND_EVENT);
				
				stopMusic(0);
				playMusicTask(8.0);
				
				set_dhudmessage(200, 0, 100, -1.0, 0.2, 1, 0.0, 4.0, 1.0, 1.0);
				show_dhudmessage(0, "G-Virus Monster Appeared!");
				
				break;
			}
			case TYPE_NEMESIS:
			{
				if (g_gameMode != GAMEMODE_NORMAL_N)
					continue;
				
				if (g_bossPlayerId)
					continue;
				
				new chance = 20;
				if (timeRemaining() <= 110.0)
					chance = 6;
				
				if (random_num(0, chance) != 0)
					continue;
				
				setNemesis(id, NEMESIS_1ST);
				
				g_bossPlayerId = id;
				playSound(0, SOUND_EVENT);
				
				stopMusic(0);
				playMusicTask(8.0);
				
				set_dhudmessage(255, 0, 0, -1.0, 0.2, 1, 0.0, 4.0, 1.0, 1.0);
				show_dhudmessage(0, "Nemesis Appeared!");
				
				break;
			}
			case TYPE_COMBINER:
			{
				if (countCombiners())
					continue;
				
				if (random_num(0, 15) != 0)
					continue;
				
				setCombiner(id, true);
				playSound(0, SOUND_DETECTED);
				
				set_hudmessage(200, 100, 0, 0.025, 0.3, 1, 0.0, 3.0, 1.0, 1.0, 1);
				show_hudmessage(0, "Combiner Appeared!");
				
				break;
			}
			case TYPE_MORPHEUS:
			{
				if (countMorpheus())
					continue;
				
				if (random_num(0, 16) != 0)
					continue;
				
				setMorpheus(id, true);
				playSound(0, SOUND_DETECTED);
				
				set_hudmessage(255, 0, 0, 0.025, 0.3, 1, 0.0, 3.0, 1.0, 1.0, 1);
				show_hudmessage(0, "Morpheus Appeared!");
				
				break;
			}
			case TYPE_BOOMER:
			{
				if (countBoomer())
					continue;
				
				if (random_num(0, 17) != 0)
					continue;
				
				setBoomer(id, true);
				playSound(0, SOUND_DETECTED);
				
				set_hudmessage(200, 200, 0, 0.025, 0.3, 1, 0.0, 3.0, 1.0, 1.0, 1);
				show_hudmessage(0, "Boomer Appeared!");
				
				break;
			}
		}
	}
	
	setZombie(id, true);
}

countTeamPlayers()
{
	setGameRules("m_iNumCT", 0);
	setGameRules("m_iNumTerrorist", 0);
	setGameRules("m_iNumSpawnableCT", 0);
	setGameRules("m_iNumSpawnableTerrorist", 0);
	
	for (new i = 1; i <= g_maxClients; i++)
	{
		if (!is_user_connected(i))
			continue;
		
		switch (getPlayerData(i, "m_iTeam"))
		{
			case 1:
			{
				if (!isJoiningTeam(i))
					setGameRules("m_iNumSpawnableTerrorist", getGameRules("m_iNumSpawnableTerrorist") + 1);
				
				setGameRules("m_iNumTerrorist", getGameRules("m_iNumTerrorist") + 1);
			}
			case 2:
			{
				if (!isJoiningTeam(i))
					setGameRules("m_iNumSpawnableCT", getGameRules("m_iNumSpawnableCT") + 1);
				
				setGameRules("m_iNumCT", getGameRules("m_iNumCT") + 1);
			}
		}
	}
}

stock bool:isGameStarted()
{
	return g_isGameStarted;
}

stock bool:canPlayerRespawn(id)
{
	if (!g_allowRespawn)
		return false;
	
	if (getGameRules("m_iRoundWinStatus") > 0)
		return false;
	
	if (!(1 <= getPlayerData(id, "m_iTeam") <= 2) || isJoiningTeam(id))
		return false;
	
	if (is_user_alive(id))
		return false;
	
	return true;
}

stock getRandomPlayer(players[32], &numPlayers, bool:remove=true)
{
	new rand = random(numPlayers);
	new player = players[rand];
	
	if (remove)
		players[rand] = players[--numPlayers];
	
	return player;
}

stock checkWinConditions()
{
	static OrpheuFunction:func;
	func || (func = OrpheuGetFunction("CheckWinConditions", "CHalfLifeMultiplay"));
	
	OrpheuCallSuper(func, g_pGameRules);
}

stock terminateRound(Float:delay, status)
{
	setGameRules("m_iRoundWinStatus", status);
	setGameRules("m_bRoundTerminating", true);
	setGameRulesF("m_fTeamCount", get_gametime() + delay);
}

stock terminateRound2(Float:delay, status, event, const message[], const audio[]="", bool:score=true)
{
	if (audio[0])
	{
		new code[32] = "%!MRAD_";
		add(code, charsmax(code), audio);
		sendAudioMsg(0, 0, code, 100);
	}
	
	if (score && status != WinStatus_Draw)
	{
		if (status == WinStatus_Terrorist)
			setGameRules("m_iNumTerroristWins", getGameRules("m_iNumTerroristWins") + 1);
		else if (status == WinStatus_CT)
			setGameRules("m_iNumCTWins", getGameRules("m_iNumCTWins") + 1);
		
		updateTeamScores();
	}
	
	endRoundMessage(message, event);
	terminateRound(delay, status);
}

stock endRoundMessage(const message[], event)
{
	static OrpheuFunction:func;
	func || (func = OrpheuGetFunction("EndRoundMessage"));
	
	OrpheuCall(func, message, event);
}

stock updateTeamScores()
{
	static msgTeamScore;
	msgTeamScore || (msgTeamScore = get_user_msgid("TeamScore"));
	
	emessage_begin(MSG_BROADCAST, msgTeamScore);
	ewrite_string("CT");
	ewrite_short(getGameRules("m_iNumCTWins"));
	emessage_end();
	
	emessage_begin(MSG_BROADCAST, msgTeamScore);
	ewrite_string("TERRORIST");
	ewrite_short(getGameRules("m_iNumTerroristWins"));
	emessage_end();
}

stock sendAudioMsg(id, sender, const audio[], pitch)
{
	static msgSendAudio;
	msgSendAudio || (msgSendAudio = get_user_msgid("SendAudio"));
	
	emessage_begin(id ? MSG_ONE_UNRELIABLE : MSG_BROADCAST, msgSendAudio, _, id);
	ewrite_byte(sender);
	ewrite_string(audio);
	ewrite_short(pitch);
	emessage_end();
}

stock Float:timeRemaining()
{
	return float(getGameRules("m_iRoundTimeSecs")) - get_gametime() + getGameRulesF("m_fRoundCount");
}