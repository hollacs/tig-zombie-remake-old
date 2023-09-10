#if defined _gamedata_stocks_included
	#endinput
#endif
#define _gamedata_stocks_included

stock any:getPlayerData(entity, const member[], element = 0)
{
	return get_ent_data(entity, "CBasePlayer", member, element);
}

stock setPlayerData(entity, const member[], any:value, element = 0)
{
	set_ent_data(entity, "CBasePlayer", member, value, element);
}

stock Float:getPlayerDataF(entity, const member[], element = 0)
{
	return get_ent_data(entity, "CBasePlayer", member, element);
}

stock setPlayerDataF(entity, const member[], Float:value, element = 0)
{
	set_ent_data(entity, "CBasePlayer", member, value, element);
}

stock any:getPlayerDataEnt(entity, const member[], element = 0)
{
	return get_ent_data_entity(entity, "CBasePlayer", member, element);
}

stock any:getWeaponData(entity, const member[], element = 0)
{
	return get_ent_data(entity, "CBasePlayerWeapon", member, element);
}

stock setWeaponData(entity, const member[], any:value, element = 0)
{
	set_ent_data(entity, "CBasePlayerWeapon", member, value, element);
}

stock any:getGameRules2(const member[], element = 0)
{
	return get_gamerules_int("CGameRules", member, element);
}

stock setGameRules2(const member[], any:value, element = 0)
{
	set_gamerules_int("CGameRules", member, value, element);
}

stock Float:getGameRulesF2(const member[], element = 0)
{
	return get_gamerules_float("CGameRules", member, element);
}

stock setGameRulesF2(const member[], Float:value, element = 0)
{
	set_gamerules_float("CGameRules", member, value, element);
}

stock any:getGameRules(const member[], element = 0)
{
	return get_gamerules_int("CHalfLifeMultiplay", member, element);
}

stock setGameRules(const member[], any:value, element = 0)
{
	set_gamerules_int("CHalfLifeMultiplay", member, value, element);
}

stock Float:getGameRulesF(const member[], element = 0)
{
	return get_gamerules_float("CHalfLifeMultiplay", member, element);
}

stock setGameRulesF(const member[], Float:value, element = 0)
{
	set_gamerules_float("CHalfLifeMultiplay", member, value, element);
}