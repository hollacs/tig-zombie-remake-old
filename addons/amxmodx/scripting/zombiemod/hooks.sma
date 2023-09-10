public OnPluginPrecache()
{
	precache_sound("weapons/rocket1.wav");
	precache_sound("weapons/rocketfire1.wav");
	precache_sound("player/bhit_helmet-1.wav");
	precache_sound(SOUND_MUTATION);
	precache_sound("player/bhit_flesh-3.wav");
	
	for (new i = 0; i < sizeof SOUND_ARMOR; i++)
		precache_sound(SOUND_ARMOR[i]);
	
	for (new i = 0; i < sizeof SOUND_MEDKIT; i++)
		precache_sound(SOUND_MEDKIT[i]);
	
	g_modelGlass = precache_model("models/glassgibs.mdl");
	precache_model("models/rpgrocket.mdl");
	
	g_sprTrail = precache_model("sprites/laserbeam.spr");
	g_sprFire = precache_model("sprites/fire.spr");
	g_sprSteam = precache_model("sprites/steam1.spr");
	g_sprShockwave = precache_model("sprites/shockwave.spr");
	g_sprEExplo = precache_model("sprites/eexplo.spr");
	g_sprFExplo = precache_model("sprites/fexplo.spr");
	
	g_fwKeyValue = register_forward(FM_KeyValue, "OnKeyValue");
	g_fwEntSpawn = register_forward(FM_Spawn, "OnEntSpawn");
	
	GameRules::Precache();
	Leader::Precache();
	Zombie::Precache();
	Gmonster::Precache();
	Nemesis::Precache();
	Combiner::Precache();
	Morpheus::Precache();
	Boomer::Precache();
	FireBomb::Precache();
	IceBomb::Precache();
	InfectBomb::Precache();
	Armor::Precache();
	Nvg::Precache();
}

public OnPluginNatives()
{
	register_library("zombiemod");
	
	Player::Natives();
	Zombie::Natives();
	Buy::Natives();
}

public OnPluginInit()
{
	register_event("HLTV", "OnEventNewRound", "a", "1=0", "2=0");
	register_event("ScreenFade", "OnEventScreenFade", "ab", "7>0");
	
	register_message(get_user_msgid("Money"), "OnMsgMoney");
	
	register_logevent("OnEventRoundStart", 2, "1=Round_Start");
	register_logevent("OnEventRoundEnd", 2, "1=Round_End");
	
	register_forward(FM_CmdStart, "OnCmdStart");
	register_forward(FM_ClientPutInServer, "OnClientPutInServer_P", 1);
	register_forward(FM_PlayerPreThink, "OnPlayerPreThink");
	register_forward(FM_LightStyle, "OnLightStyle");
	register_forward(FM_SetModel, "OnSetModel");
	unregister_forward(FM_KeyValue, g_fwKeyValue);
	unregister_forward(FM_Spawn, g_fwEntSpawn);
	
	RegisterHam(Ham_Spawn, "player", "OnPlayerSpawn");
	RegisterHam(Ham_Spawn, "player", "OnPlayerSpawn_P", 1);
	RegisterHam(Ham_CS_Player_ResetMaxSpeed, "player", "OnPlayerResetMaxSpeed_P", 1);
	RegisterHam(Ham_Killed, "player", "OnPlayerKilled");
	RegisterHam(Ham_Killed, "player", "OnPlayerKilled_P", 1);
	RegisterHam(Ham_Player_Jump, "player", "OnPlayerJump");
	
	RegisterHam(Ham_Item_Deploy, "weapon_knife", "OnKnifeDeploy_P", 1);
	
	RegisterHam(Ham_Touch, "weaponbox", "OnWeaponTouch");
	RegisterHam(Ham_Touch, "weapon_shield", "OnWeaponTouch");
	RegisterHam(Ham_Touch, "armoury_entity", "OnWeaponTouch");
	
	RegisterHam(Ham_Think, "grenade", "OnGrenadeThink");
	
	OrpheuRegisterHook(OrpheuGetFunction("GiveDefaultItems", "CBasePlayer"), "OnGiveDefaultItems");
	
	g_maxClients = get_maxplayers();
	
	Player::Init();
	Human::Init();
	Supporter::Init();
	Leader::Init();
	Zombie::Init();
	Gmonster::Init();
	Nemesis::Init();
	Combiner::Init();
	Morpheus::Init();
	Boomer::Init();
	Fatal::Init();
	GameRules::Init();
	Poison::Init();
	Buy::Init();
	Nvg::Init();
	Armor::Init();
	Level::Init();
	GunLv::Init();
	RandItem::Init();
	HudInfo::Init();
	Menu::Init();
	Save::Init();
	Command::Init();
	Api::Init();
}

public OnPluginEnd()
{
	Save::PluginEnd();
}

public OnKeyValue(ent, kvd)
{
	Buy::KeyValue(ent);
}

public OnEntSpawn(ent)
{
	HOOK_RESULT = FMRES_IGNORED;
	Buy::EntSpawn(ent);
	GameRules::EntSpawn(ent);
	return HOOK_RESULT;
}

public OnMsgMoney(msgId, msgDest, id)
{
	Player::MsgMoney(id);
}

public OnEventNewRound()
{
	GameRules::NewRound();
	Player::NewRound();
	Supporter::NewRound();
	Leader::NewRound();
	Gmonster::NewRound();
	Nemesis::NewRound();
	Combiner::NewRound();
	Morpheus::NewRound();
	Boomer::NewRound();
	Nvg::NewRound();
	RandItem::NewRound();
}

public OnEventScreenFade(id)
{
	Nvg::ScreenFade(id);
}

public OnEventRoundStart()
{
	GameRules::RoundStart();
}

public OnEventRoundEnd()
{
	GameRules::RoundEnd();
}

public OnClientPutInServer(id)
{
}

public OnClientPutInServer_P(id)
{
	Nvg::ClientPutInServer_P(id);
	Save::PutInServer_P(id);
}

public OnClientDeath(killer, victim, weapon, hit, teamKill)
{
	GunLv::ClientDeath(killer, victim, weapon, hit, teamKill);
}

public OnCmdStart(id, uc)
{
	Nemesis::CmdStart(id, uc);
	Level::CmdStart(id, uc);
}

public OnPlayerPreThink(id)
{
	Gmonster::PlayerPreThink(id);
	Nemesis::PlayerPreThink(id);
	Combiner::PlayerPreThink(id);
	Nvg::PlayerPreThink(id);
	FireBomb::PlayerPreThink(id);
	Poison::PlayerPreThink(id);
}

public OnLightStyle(style, const lights[])
{
	Nvg::LightStyle(style, lights);
}

public OnSetModel(ent, const model[])
{
	Supporter::SetModel(ent, model);
	Leader::SetModel(ent, model);
	FireBomb::SetModel(ent, model);
	IceBomb::SetModel(ent, model);
	Flare::SetModel(ent, model);
	InfectBomb::SetModel(ent, model);
	Level::SetModel(ent, model);
}

public OnPlayerSpawn(id)
{
	if (!pev_valid(id))
		return;
	
	GameRules::PlayerSpawn(id);
}

public OnPlayerSpawn_P(id)
{
	if (!pev_valid(id))
		return;	

	Nvg::PlayerSpawn_P(id);
	GameRules::PlayerSpawn_P(id);
	Boomer::Spawn_P(id);
}

public OnPlayerResetMaxSpeed_P(id)
{
	if (!pev_valid(id))
		return;

	Supporter::ResetMaxSpeed(id);
	Leader::ResetMaxSpeed(id);
	Zombie::ResetMaxSpeed(id);
	Gmonster::ResetMaxSpeed(id);
	Nemesis::ResetMaxSpeed(id);
	Combiner::ResetMaxSpeed(id);
	Morpheus::ResetMaxSpeed(id);
	Boomer::ResetMaxSpeed(id);
	IceBomb::ResetMaxSpeed(id);
	Armor::ResetMaxSpeed(id);
	Level::ResetMaxSpeed(id);
	Api::ResetMaxSpeed(id);
}

public OnPlayerKilled(id, killer, shouldGib)
{
	if (!pev_valid(id))
		return;

	Human::Killed(id);
	Boomer::Killed(id);
	GameRules::Killed(id);
	FireBomb::Killed(id);
	IceBomb::Killed(id);
	Armor::Killed(id);
	Poison::Killed(id);
	Buy::Killed(id, killer);
	Level::Killed(id, killer);
}

public OnPlayerKilled_P(id, killer, shouldGib)
{
	if (!pev_valid(id))
		return;
	
	GameRules::Killed_P(id, killer);
	Player::Killed_P(id, killer);
	Supporter::Killer_P(id);
	Leader::Killer_P(id);
	Zombie::Killed_P(id);
	Gmonster::Killed_P(id);
	Nemesis::Killed_P(id);
	Combiner::Killed_P(id);
	Morpheus::Killed_P(id);
	Boomer::Killed_P(id);
	Nvg::Killed_P(id);
	RandItem::Killed_P(id);
}

public OnPlayerJump(id)
{
	if (!pev_valid(id))
		return;
	
	IceBomb::PlayerJump(id);
}

public OnKnifeDeploy_P(ent)
{
	if (!pev_valid(ent))
		return;
	
	new id = get_ent_data_entity(ent, "CBasePlayerItem", "m_pPlayer");
	if (pev_valid(id))
	{
		Zombie::KnifeDeploy_P(id);
	}
}

public OnWeaponTouch(ent, toucher)
{
	if (!pev_valid(ent) || !pev_valid(toucher))
		return HAM_IGNORED;
	
	HOOK_RESULT = HAM_IGNORED;
	Zombie::TouchWeapon(ent, toucher);
	return HOOK_RESULT;
}

public OnGrenadeThink(ent)
{
	if (!pev_valid(ent))
		return HAM_IGNORED;
	
	HOOK_RESULT = HAM_IGNORED;
	FireBomb::GrenadeThink(ent);
	IceBomb::GrenadeThink(ent);
	Flare::GrenadeThink(ent);
	InfectBomb::GrenadeThink(ent);
	
	return HOOK_RESULT;
}

public OrpheuHookReturn:OnGiveDefaultItems(id)
{
	HOOK_RESULT = OrpheuIgnored;
	Human::GiveDefaultItems(id);
	Zombie::GiveDefaultItems(id);
	return HOOK_RESULT;
}

public OnClientDisconnect(id)
{
	Save::Disconnect(id);
	Player::Disconnect(id);
	Supporter::Disconnect(id);
	Leader::Disconnect(id);
	Zombie::Disconnect(id);
	Gmonster::Disconnect(id);
	Nemesis::Disconnect(id);
	Combiner::Disconnect(id);
	Morpheus::Disconnect(id);
	Boomer::Disconnect(id);
	GameRules::Disconnect(id);
	FireBomb::Disconnect(id);
	IceBomb::Disconnect(id);
	Poison::Disconnect(id);
	Armor::Disconnect(id);
	Level::Disconnect(id);
	GunLv::Disconnect(id);
	Nvg::Disconnect(id);
}

// --------------------------------------

public OnPlayerHumanize(id)
{
	Player::Humanize(id);
	Human::Humanize(id);
	Supporter::Humanize(id);
	Leader::Humanize(id);
	Zombie::Humanize(id);
	Gmonster::Humanize(id);
	Nemesis::Humanize(id);
	Combiner::Humanize(id);
	Morpheus::Humanize(id);
	Boomer::Humanize(id);
	Nvg::Humanize(id);
	FireBomb::Humanize(id);
	IceBomb::Humanize(id);
	Poison::Humanize(id);
	Armor::Humanize(id);
	Buy::Humanize(id);
	Level::Humanize(id);
	
	ShowPistolMenu(id);
}

public OnPlayerInfect(id, attacker)
{
	Player::Infect(id, attacker);
	Human::Infect(id);
	Supporter::Infect(id);
	Leader::Infect(id);
	Zombie::Infect(id, attacker);
	Gmonster::Infect(id);
	Nemesis::Infect(id);
	Combiner::Infect(id);
	Morpheus::Infect(id);
	Boomer::Infect(id);
	Poison::Infect(id);
	GameRules::Infect(id);
	Armor::Infect(id);
	Nvg::Infect(id);
	Buy::Infect(id, attacker);
	Api::InfectPlayer(id, attacker);
	Level::Infect(id, attacker);
}

public OnPlayerFreeze(id)
{
	Armor::PlayerFreeze(id);
}

public OnZombieKnifeDeploy(id)
{
	Gmonster::KnifeDeploy(id);
	Nemesis::KnifeDeploy(id);
	Combiner::KnifeDeploy(id);
	Morpheus::KnifeDeploy(id);
	Boomer::KnifeDeploy(id);
	Api::ZombieKnifeDeploy(id);
}

public OnPainShock(id, inflictor, attacker, Float:damage, damageBits)
{
	Gmonster::PainShock(id);
	Nemesis::PainShock(id);
	Combiner::PainShock(id)
	Morpheus::PainShock(id);
	Boomer::PainShock(id);
	Armor::PainShock(id, inflictor, attacker, damage, damageBits);
	Api::PainShock(id, inflictor, attacker, damage, damageBits);
}

public OnKnockBack(id, attacker, Float:damage, Float:direction[3], tr, damageBits)
{
	Gmonster::KnockBack(id);
	Nemesis::KnockBack(id);
	Combiner::KnockBack(id);
	Morpheus::KnockBack(id);
	Boomer::KnockBack(id);
	Armor::KnockBack(id);
	Api::KnockBack(id, attacker, damage, direction, tr, damageBits);
}

public OnPlayMusic(&Float:delay)
{
	GameRules::PlayMusic(delay);
}

public OnGameStart()
{
	Buy::GameStart();
}

public OnShowBuyMenu(id, item)
{
	Buy::BuyMenu(id, item);
}

public OnSave(id, index)
{
	Level::Save(id, index);
	GunLv::Save(id, index);
}

public OnLoad(id, index)
{
	Level::Load(id, index);
	GunLv::Load(id, index);
}

public OnCanFatalKill(id, attacker)
{
	HOOK_RESULT = PLUGIN_CONTINUE;
	Level::CanFatalKill(id, attacker);
	return HOOK_RESULT;
}

public OnCanPoison(id, attacker)
{
	HOOK_RESULT = PLUGIN_CONTINUE;
	Level::CanPoison(id, attacker);
	return HOOK_RESULT;
}

public OnKnifeKnockBack(id, attacker, Float:damage, &Float:power)
{
	Human::KnifeKnockBack(id, attacker, power);
	Supporter::KnifeKnockBack(id, attacker, power);
	Leader::KnifeKnockBack(id, attacker, power);
	Level::KnifeKnockBack(id, attacker, power);
}

public OnIceExplode(ent, player, Float:original, &Float:duration)
{
	Level::IceExplode(ent, player, original, duration);
}

public OnFireExplode(ent, player, &Float:burnDuration)
{
	Level::FireExplode(ent, player, burnDuration);
}

public OnPlayerBurn(id, attacker, &Float:damage)
{
	Level::PlayerBurn(id, attacker, damage);
}