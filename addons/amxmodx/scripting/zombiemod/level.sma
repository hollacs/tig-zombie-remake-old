const MAX_LEVEL = 30;
const ATTRIBH_POINT_EACH_LVL = 3;

new const ATTRIBH_NAME[][] = {"體力", "耐力", "力量", "智力", "敏捷", "\d幸運", "\d信仰"};
new const MAX_ATTRIBH_LEVEL[] = {30, 30, 30, 25, 20, 0, 0};

new g_level[33];
new g_exp[33];
new Float:g_damageExp[33];

new g_humanAttributes[33][ATTRIBH_MAX];
new bool:g_fastThrow[33];

new Array:g_dataLevel;
new Array:g_dataExp;

public Level::Init()
{
	register_clcmd("attribute1", "CmdHumanAttrib");
	
	RegisterHam(Ham_TakeDamage, "player", "Level@TakeDamage");
	RegisterHam(Ham_Touch, "grenade", "Level@GrenadeTouch");
	
	g_dataLevel = ArrayCreate(1);
	g_dataExp = ArrayCreate(1);
}

public CmdHumanAttrib(id)
{
	ShowHumanAttribMenu(id);
	return PLUGIN_HANDLED;
}

public ShowHumanAttribMenu(id)
{
	new buff[64];
	formatex(buff, charsmax(buff), "Survivor Attributes \w(%d Points)", getAttribPoint(id));
	
	new menu = menu_create(buff, "HandleHumanAttribMenu");
	
	for (new i = 0; i < ATTRIBH_MAX; i++)
	{
		formatex(buff, charsmax(buff), "%s \y(%d/%d)", ATTRIBH_NAME[i], g_humanAttributes[id][i], MAX_ATTRIBH_LEVEL[i]);
		menu_additem(menu, buff);
	}
	
	menu_additem(menu, "重置能力");
	menu_additem(menu, "說明");
	
	menu_setprop(menu, MPROP_NUMBER_COLOR, "\y");
	menu_display(id, menu);
}

public HandleHumanAttribMenu(id, menu, item)
{
	menu_destroy(menu);
	
	if (item == MENU_EXIT)
		return;
	
	if (item == ATTRIBH_MAX)
	{
		arrayset(g_humanAttributes[id], 0, sizeof g_humanAttributes[]);
		client_print(id, print_center, "你重置了能力");
	}
	else if (item == ATTRIBH_MAX + 1)
	{
		show_motd(id, "addons/amxmodx/data/lang/attrib1.txt", "人類能力等級說明")
	}
	else
	{
		new point = getAttribPoint(id);
		if (point < 1)
			client_print(id, print_center, "能力點不足");
		else if (g_humanAttributes[id][item] >= MAX_ATTRIBH_LEVEL[item])
			client_print(id, print_center, "該能力已達至最大等級");
		else
			g_humanAttributes[id][item]++;
	}
	
	ShowHumanAttribMenu(id);
}

public Level::Disconnect(id)
{
	g_level[id] = 0;
	g_exp[id] = 0;
	g_damageExp[id] = 0.0;
	g_fastThrow[id] = false;
	
	arrayset(g_humanAttributes[id], 0, sizeof g_humanAttributes[]);
}

public Level::ResetMaxSpeed(id)
{
	if (!isZombie(id))
	{
		if (g_humanAttributes[id][ATTRIBH_DEX] >= 10)
		{
			new level = g_humanAttributes[id][ATTRIBH_DEX] - 10;

			new Float:maxSpeed = get_user_maxspeed(id);
			maxSpeed *= 1.0 + (0.2 * (level / 10.0));
			
			client_print(id, print_chat, "[debug] maxspeed = %f", maxSpeed);
			
			set_user_maxspeed(id, maxSpeed);
		}
	}
}

public Level::TakeDamage(id, inflictor, attacker, Float:damage, damageBits)
{
	if (!pev_valid(id))
		return;
	
	if (is_user_connected(attacker) && isZombie(attacker) != isZombie(id) && inflictor == attacker && (damageBits & DMG_BULLET))
	{
		g_damageExp[attacker] += damage;
		
		if (isZombie(attacker))
		{
			if (g_damageExp[attacker] > 300)
			{
				g_damageExp[attacker] = 0.0;
				addExp(attacker, 15);
			}
		}
		else
		{
			if (g_damageExp[attacker] > 750)
			{
				g_damageExp[attacker] = 0.0;
				addExp(attacker, 10);
			}
			
			if (get_user_weapon(attacker) == CSW_KNIFE)
			{
				if (g_humanAttributes[attacker][ATTRIBH_STR] > 0)
				{
					new level = min(g_humanAttributes[attacker][ATTRIBH_STR], 15);
					damage *= 1.0 + (2.84 * (level / 15.0));
					client_print(attacker, print_chat, "damage = %f", damage);
					SetHamParamFloat(4, damage);
				}
			}
		}
	}
}

public Level::CanFatalKill(id, attacker)
{
	if (g_humanAttributes[id][ATTRIBH_HP] >= 15)
	{
		new level = g_humanAttributes[id][ATTRIBH_HP] - 15;
		new Float:rand = 0.5 + (0.5 * (level / 15.0));
		if (random_float(0.0, 1.0) <= rand)
			HOOK_RETURN(PLUGIN_HANDLED);
	}
	
	HOOK_RETURN(PLUGIN_CONTINUE);
}

public Level::CanPoison(id, attacker)
{
	if (g_humanAttributes[id][ATTRIBH_AP] >= 10)
	{
		new level = min(g_humanAttributes[id][ATTRIBH_AP] - 10, 10);
		new Float:rand = 0.5 + (0.5 * (level / 10.0));
		if (random_float(0.0, 1.0) <= rand)
			HOOK_RETURN(PLUGIN_HANDLED);
	}

	HOOK_RETURN(PLUGIN_CONTINUE);
}

public Level::KnifeKnockBack(id, attacker, &Float:power)
{
	if (g_humanAttributes[attacker][ATTRIBH_STR] >= 20)
	{
		if (isKnifeStabbing(attacker))
			power = 600.0;
	}
	if (g_humanAttributes[attacker][ATTRIBH_STR] >= 15)
	{
		new level = g_humanAttributes[attacker][ATTRIBH_STR] - 15;
		power *= 1.0 + (0.66666 * (level / 15.0));
	}
}

public Level::IceExplode(ent, player, Float:original, &Float:duration)
{
	new owner = pev(ent, pev_owner);
	
	if (g_humanAttributes[owner][ATTRIBH_INT] >= 10)
	{
		if (duration <= 0)
			duration = original;
	}

	if (g_humanAttributes[owner][ATTRIBH_INT] > 0)
	{
		new level = min(g_humanAttributes[owner][ATTRIBH_INT], 10);
		duration *= 1.0 + (1.0 * (level / 10.0));
	}
}

public Level::FireExplode(ent, player, &Float:burnDuration)
{
	new owner = pev(ent, pev_owner);
	
	if (g_humanAttributes[owner][ATTRIBH_INT] >= 20)
	{
		new level = g_humanAttributes[owner][ATTRIBH_INT] - 20;
		burnDuration *= 1.0 + (0.66666 * (level / 5.0));
	}
}

public Level::PlayerBurn(id, attacker, &Float:damage)
{
	if (is_user_connected(attacker))
	{
		if (g_humanAttributes[attacker][ATTRIBH_INT] >= 10)
		{
			new level = min(g_humanAttributes[attacker][ATTRIBH_INT] - 10, 10);
			damage *= 1.0 + (1.08333 * (level / 10.0));
		}
	}
}

public Level::CmdStart(id, uc)
{
	if (is_user_alive(id) && !isZombie(id))
	{
		new weapon = get_user_weapon(id);
		if (weapon == CSW_HEGRENADE || weapon == CSW_FLASHBANG)
		{
			if (g_humanAttributes[id][ATTRIBH_DEX] >= 15)
			{
				new buttons = get_uc(uc, UC_Buttons);
				new oldButtons = pev(id, pev_oldbuttons);
				if ((~buttons & IN_ATTACK2) && (oldButtons & IN_ATTACK2))
				{
					g_fastThrow[id] = !g_fastThrow[id];
					
					if (g_fastThrow[id])
						client_print(id, print_center, "Fast throw: On");
					else
						client_print(id, print_center, "Fast throw: Off");
				}
			}
		}
	}
}

public Level::GrenadeTouch(ent, toucher)
{
	if (pev_valid(ent))
	{
		if (pev(ent, pev_bInDuck) == 1)
			set_pev(ent, pev_dmgtime, 0.0);
	}
}

public Level::SetModel(ent, const model[])
{
	if (!pev_valid(ent))
		return;
	
	if (equal(model[7], "w_hegrenade.mdl") || equal(model[7], "w_flashbang.mdl"))
	{
		new Float:dmgTime;
		pev(ent, pev_dmgtime, dmgTime);
		
		if (dmgTime == 0.0)
			return;
		
		new owner = pev(ent, pev_owner);
		if (isZombie(owner))
			return;
		
		if (g_humanAttributes[owner][ATTRIBH_DEX] >= 15)
		{
			if (g_fastThrow[owner])
				set_pev(ent, pev_bInDuck, 1);
		}
	}
}

public Level::Killed(id, killer)
{
	if (is_user_connected(killer) && id != killer && isZombie(id) && !isZombie(killer))
		addExp(id, 5);
}

public Level::Infect(id, attacker)
{
	new Float:maxHp;
	pev(id, pev_max_health, maxHp);
	
	if (getZombieType(id) == -1)
		set_pev(id, pev_max_health, maxHp * (1.0 + (0.3 * (g_level[id] / float(MAX_LEVEL)))) );
	else
		set_pev(id, pev_max_health, maxHp * (1.0 + (2.0 * (g_level[id] / float(MAX_LEVEL)))) );
	
	new Float:hp;
	pev(id, pev_health, hp);
	pev(id, pev_max_health, maxHp);
	
	if (hp < maxHp)
		set_pev(id, pev_health, maxHp);
	
	g_damageExp[id] = 0.0;
}

public Level::Humanize(id)
{
	if (g_humanAttributes[id][ATTRIBH_HP] > 0)
	{
		// HP Skill
		new Float:maxHp, Float:hpToAdd;
		pev(id, pev_max_health, maxHp);
		
		if (getLeader(id))
			hpToAdd = 100.0;
		else
			hpToAdd = 200.0;
		
		set_pev(id, pev_max_health, maxHp + (hpToAdd * (g_humanAttributes[id][ATTRIBH_HP] / 30.0)) );
		
		new Float:hp;
		pev(id, pev_health, hp);
		pev(id, pev_max_health, maxHp);
		
		if (hp < maxHp)
		{
			hpToAdd = maxHp - hp;
			set_pev(id, pev_health, hp + (hpToAdd * (g_humanAttributes[id][ATTRIBH_HP] / 30.0)) );
		}
		
	}
	if (g_humanAttributes[id][ATTRIBH_AP] > 0)
	{
		// AP Skill
		new Float:maxAp, Float:apToAdd;
		maxAp = getMaxArmor(id);
		
		if (getLeader(id))
			apToAdd = 100.0;
		else
			apToAdd = 200.0;
		
		setMaxArmor(id, maxAp + (apToAdd * (g_humanAttributes[id][ATTRIBH_AP] / 30.0)) );
		
		new Float:ap;
		pev(id, pev_armorvalue, ap);
		maxAp = getMaxArmor(id);
		
		if (ap < maxAp)
		{
			apToAdd = maxAp - ap;
			set_pev(id, pev_armorvalue, ap + (apToAdd * (g_humanAttributes[id][ATTRIBH_AP] / 30.0)) );
		}
	}
	if (g_humanAttributes[id][ATTRIBH_DEX] > 0)
	{
		new level = min(g_humanAttributes[id][ATTRIBH_DEX], 10);
		
		new Float:gravity;
		pev(id, pev_gravity, gravity);
		
		if (gravity > 0.7)
		{
			new Float:diff = gravity - 0.7;
			gravity -= diff * (level / 10.0);
			set_pev(id, pev_gravity, gravity);
		}
	}
	
	g_damageExp[id] = 0.0;
}

public Level::Save(id, index)
{
	if (index == getDataSize())
	{
		ArrayPushCell(g_dataLevel, g_level[id]);
		ArrayPushCell(g_dataExp, g_exp[id]);
	}
}

public Level::Load(id, index)
{
	g_level[id] = ArrayGetCell(g_dataLevel, index);
	g_exp[id] = ArrayGetCell(g_dataExp, index);
}

stock addExp(id, amount)
{
	g_exp[id] += amount;
	
	while (g_level[id] < MAX_LEVEL && g_exp[id] >= getRequiredExp(id))
	{
		g_exp[id] -= getRequiredExp(id);
		g_level[id]++;
		
		client_print(0, print_chat, "%n 升級至 %d 等級!", id, g_level[id]);
	}
	
	if (isZombie(id))
		set_hudmessage(200, 200, 0, -1.0, 0.8, 0, 0.0, 1.0, 1.0, 1.0, 3);
	else
		set_hudmessage(0, 255, 0, -1.0, 0.8, 0, 0.0, 1.0, 1.0, 1.0, 3);
	
	show_hudmessage(id, "+ %d EXP", amount);
}

stock getAttribPoint(id)
{
	new point = g_level[id] * ATTRIBH_POINT_EACH_LVL;
	
	for (new i = 0; i < ATTRIBH_MAX; i++)
	{
		point -= g_humanAttributes[id][i];
	}
	
	return point;
}

stock getRequiredExp(id)
{
	return getExpForLevel(g_level[id]);
}

stock getExpForLevel(level)
{
	return 100 + (level * 25);
}

stock getPlayerLevel(id)
{
	return g_level[id];
}

stock getPlayerExp(id)
{
	return g_exp[id];
}

stock setPlayerLevel(id, value)
{
	g_level[id] = value;
	arrayset(g_humanAttributes[id], 0, sizeof g_humanAttributes[]);
}

stock getHumanAttrib(id, index)
{
	return g_humanAttributes[id][index];
}