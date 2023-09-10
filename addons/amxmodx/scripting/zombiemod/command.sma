public Command::Init()
{
	register_concmd("zm_human", "CmdHuman", ADMIN_BAN);
	register_concmd("zm_zombie", "CmdZombie", ADMIN_BAN);
	register_concmd("zm_nemesis", "CmdNemesis", ADMIN_BAN);
	register_concmd("zm_gmonster", "CmdGmonster", ADMIN_BAN);
	register_concmd("zm_leader", "CmdLeader", ADMIN_BAN);
	register_concmd("zm_supporter", "CmdSupporter", ADMIN_BAN);
	register_concmd("zm_boomer", "CmdBoomer", ADMIN_BAN);
	register_concmd("zm_combiner", "CmdCombiner", ADMIN_BAN);
	register_concmd("zm_morpheus", "CmdMorpheus", ADMIN_BAN);
	register_concmd("zm_set_money", "CmdSetMoney", ADMIN_BAN);
	register_concmd("zm_set_level", "CmdSetLevel", ADMIN_BAN);
	register_concmd("zm_set_gun_level", "CmdSetGunLevel", ADMIN_BAN);
	register_concmd("zm_respawn", "CmdRespawn", ADMIN_BAN);
	register_concmd("shake", "CmdShake", ADMIN_BAN);
}

public CmdHuman(id, level, cid)
{
	if (!cmd_access(id, level, cid, 2))
		return PLUGIN_HANDLED;
	
	new arg[32];
	read_argv(1, arg, charsmax(arg));
	
	new player = cmd_target(id, arg, CMDTARGET_ONLY_ALIVE|CMDTARGET_ALLOW_SELF);
	if (!player)
		return PLUGIN_HANDLED;
	
	humanizePlayer(player);
	return PLUGIN_HANDLED;
}

public CmdZombie(id, level, cid)
{
	if (!cmd_access(id, level, cid, 2))
		return PLUGIN_HANDLED;
	
	new arg[32];
	read_argv(1, arg, charsmax(arg));
	
	new player = cmd_target(id, arg, CMDTARGET_ONLY_ALIVE|CMDTARGET_ALLOW_SELF);
	if (!player)
		return PLUGIN_HANDLED;
	
	infectPlayer(player, 0);
	return PLUGIN_HANDLED;
}

public CmdNemesis(id, level, cid)
{
	if (!cmd_access(id, level, cid, 3))
		return PLUGIN_HANDLED;
	
	new arg[32], arg2[6];
	read_argv(1, arg, charsmax(arg));
	read_argv(2, arg2, charsmax(arg2));
	
	new player = cmd_target(id, arg, CMDTARGET_ONLY_ALIVE|CMDTARGET_ALLOW_SELF);
	if (!player)
		return PLUGIN_HANDLED;
	
	setNemesis(player, str_to_num(arg2));
	infectPlayer(player, 0);
	return PLUGIN_HANDLED;
}

public CmdGmonster(id, level, cid)
{
	if (!cmd_access(id, level, cid, 3))
		return PLUGIN_HANDLED;
	
	new arg[32], arg2[6];
	read_argv(1, arg, charsmax(arg));
	read_argv(2, arg2, charsmax(arg2));
	
	new player = cmd_target(id, arg, CMDTARGET_ONLY_ALIVE|CMDTARGET_ALLOW_SELF);
	if (!player)
		return PLUGIN_HANDLED;
	
	setGmonster(player, str_to_num(arg2));
	infectPlayer(player, 0);
	return PLUGIN_HANDLED;
}

public CmdCombiner(id, level, cid)
{
	if (!cmd_access(id, level, cid, 2))
		return PLUGIN_HANDLED;
	
	new arg[32];
	read_argv(1, arg, charsmax(arg));
	
	new player = cmd_target(id, arg, CMDTARGET_ONLY_ALIVE|CMDTARGET_ALLOW_SELF);
	if (!player)
		return PLUGIN_HANDLED;
	
	setCombiner(player, true);
	infectPlayer(player, 0);
	return PLUGIN_HANDLED;
}

public CmdMorpheus(id, level, cid)
{
	if (!cmd_access(id, level, cid, 2))
		return PLUGIN_HANDLED;
	
	new arg[32];
	read_argv(1, arg, charsmax(arg));
	
	new player = cmd_target(id, arg, CMDTARGET_ONLY_ALIVE|CMDTARGET_ALLOW_SELF);
	if (!player)
		return PLUGIN_HANDLED;
	
	setMorpheus(player, true);
	infectPlayer(player, 0);
	return PLUGIN_HANDLED;
}

public CmdBoomer(id, level, cid)
{
	if (!cmd_access(id, level, cid, 2))
		return PLUGIN_HANDLED;
	
	new arg[32];
	read_argv(1, arg, charsmax(arg));
	
	new player = cmd_target(id, arg, CMDTARGET_ONLY_ALIVE|CMDTARGET_ALLOW_SELF);
	if (!player)
		return PLUGIN_HANDLED;
	
	setBoomer(player, true);
	infectPlayer(player, 0);
	return PLUGIN_HANDLED;
}

public CmdLeader(id, level, cid)
{
	if (!cmd_access(id, level, cid, 3))
		return PLUGIN_HANDLED;
	
	new arg[32], arg2[6];
	read_argv(1, arg, charsmax(arg));
	read_argv(2, arg2, charsmax(arg2));
	
	new player = cmd_target(id, arg, CMDTARGET_ONLY_ALIVE|CMDTARGET_ALLOW_SELF);
	if (!player)
		return PLUGIN_HANDLED;
	
	setLeader(player, str_to_num(arg2));
	humanizePlayer(player);
	return PLUGIN_HANDLED;
}

public CmdSupporter(id, level, cid)
{
	if (!cmd_access(id, level, cid, 2))
		return PLUGIN_HANDLED;
	
	new arg[32];
	read_argv(1, arg, charsmax(arg));
	
	new player = cmd_target(id, arg, CMDTARGET_ONLY_ALIVE|CMDTARGET_ALLOW_SELF);
	if (!player)
		return PLUGIN_HANDLED;
	
	setSupporter(player, true);
	humanizePlayer(player);
	return PLUGIN_HANDLED;
}

public CmdSetMoney(id, level, cid)
{
	if (!cmd_access(id, level, cid, 3))
		return PLUGIN_HANDLED;
	
	new arg[32], arg2[32];
	read_argv(1, arg, charsmax(arg));
	read_argv(2, arg2, charsmax(arg2));
	
	new player = cmd_target(id, arg, CMDTARGET_ONLY_ALIVE|CMDTARGET_ALLOW_SELF);
	if (!player)
		return PLUGIN_HANDLED;
	
	setMoney(player, str_to_num(arg2));
	return PLUGIN_HANDLED;
}

public CmdSetLevel(id, level, cid)
{
	if (!cmd_access(id, level, cid, 3))
		return PLUGIN_HANDLED;
	
	new arg[32], arg2[32];
	read_argv(1, arg, charsmax(arg));
	read_argv(2, arg2, charsmax(arg2));
	
	new player = cmd_target(id, arg, CMDTARGET_ONLY_ALIVE|CMDTARGET_ALLOW_SELF);
	if (!player)
		return PLUGIN_HANDLED;
	
	setPlayerLevel(player, str_to_num(arg2));
	return PLUGIN_HANDLED;
}

public CmdSetGunLevel(id, level, cid)
{
	if (!cmd_access(id, level, cid, 4))
		return PLUGIN_HANDLED;
	
	new arg[32], arg2[32], arg3[32];
	read_argv(1, arg, charsmax(arg));
	read_argv(2, arg2, charsmax(arg2));
	read_argv(3, arg3, charsmax(arg3));
	
	new player = cmd_target(id, arg, CMDTARGET_ONLY_ALIVE|CMDTARGET_ALLOW_SELF);
	if (!player)
		return PLUGIN_HANDLED;
	
	format(arg2, charsmax(arg2), "weapon_%s", arg2);

	new weapon = get_weaponid(arg2);
	if (!weapon)
		return PLUGIN_HANDLED;
	
	
	setGunLevel(player, weapon, str_to_num(arg3));
	return PLUGIN_HANDLED;
}

public CmdShake(id)
{
	new arg1[16], arg2[16], arg3[16];
	read_argv(1, arg1, charsmax(arg1));
	read_argv(2, arg2, charsmax(arg2));
	read_argv(3, arg3, charsmax(arg3));
	
	sendScreenShake(id, str_to_float(arg1), str_to_float(arg2), str_to_float(arg3));
	return PLUGIN_HANDLED;
}

public CmdRespawn(id, level, cid)
{
	if (!cmd_access(id, level, cid, 2))
		return PLUGIN_HANDLED;
	
	new arg[32];
	read_argv(1, arg, charsmax(arg));
	
	new player = cmd_target(id, arg, CMDTARGET_ALLOW_SELF);
	if (!player)
		return PLUGIN_HANDLED;
	
	ExecuteHamB(Ham_CS_RoundRespawn, player);
	return PLUGIN_HANDLED;
}