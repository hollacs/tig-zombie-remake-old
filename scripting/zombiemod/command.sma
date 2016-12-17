public Command::Init()
{
	register_concmd("zm_human", "CmdHuman", ADMIN_RCON);
	register_concmd("zm_zombie", "CmdZombie", ADMIN_RCON);
	register_concmd("zm_nemesis", "CmdNemesis", ADMIN_RCON);
	register_concmd("zm_gmonster", "CmdGmonster", ADMIN_RCON);
	register_concmd("zm_leader", "CmdLeader", ADMIN_RCON);
	register_concmd("zm_supporter", "CmdSupporter", ADMIN_RCON);
	register_concmd("zm_set_money", "CmdSetMoney", ADMIN_RCON);
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
	
	setMoney(id, str_to_num(arg2));
	return PLUGIN_HANDLED;
}