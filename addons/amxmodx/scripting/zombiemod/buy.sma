new const BUY_ITEM_NAME[][] = 
{
	"Infection Bomb", "Antidote", "Heal",
	"Armor 100", "Armor 300", "Medical Kit", "Antidote", "Incendiary Grenade", "Nitrogen Grenade", "Flare", "Night Vision",
	"M3", "XM1014",
	"MP5", "UMP45", "P90",
	"Galil", "Famas", "SG552", "AUG",
	"G3SG1", "SG550", "Scout", "AWP",
	"M249"
};

new const BUY_ITEM_DESC[][] = 
{
	"", "Human", "(+1500HP)",
	"", "", "+120 HP", "解毒", "Fire", "Frozen", "Light", "",
	"", "",
	"", "", "",
	"", "", "", "",
	"", "", "", "",
	""
};

new const BUY_ITEM_TEAM[] = 
{
	BUY_TEAM_ZOMBIE, BUY_TEAM_ZOMBIE, BUY_TEAM_NEMESIS,
	BUY_TEAM_HUMAN, BUY_TEAM_HUMAN, BUY_TEAM_HUMAN, BUY_TEAM_HUMAN,
	BUY_TEAM_HUMAN, BUY_TEAM_HUMAN, BUY_TEAM_HUMAN, BUY_TEAM_HUMAN,
	BUY_TEAM_HUMAN, BUY_TEAM_HUMAN,
	BUY_TEAM_HUMAN, BUY_TEAM_HUMAN, BUY_TEAM_HUMAN,
	BUY_TEAM_HUMAN, BUY_TEAM_HUMAN, BUY_TEAM_HUMAN, BUY_TEAM_HUMAN,
	BUY_TEAM_HUMAN, BUY_TEAM_HUMAN, BUY_TEAM_HUMAN, BUY_TEAM_HUMAN,
	BUY_TEAM_HUMAN
};

new const BUY_ITEM_COST[] = 
{
	2500, 4000, 5000,
	300, 550, 600, 300, 600, 500, 300, 1000,
	1500, 2000,
	1250, 1000, 1400,
	1500, 1500, 2500, 2500,
	3500, 3250, 1000, 3000,
	4000,
};

new const BUY_ITEM_RS[] = 
{
	0, 0, 0,
	10, 18, 20, 9, 40, 30, 20, 50,
	30, 35,
	30, 25, 32,
	35, 35, 40, 40,
	55, 50, 10, 45,
	60
};

new Array:g_buyItemName;
new Array:g_buyItemDesc;
new Array:g_buyItemTeam;
new Array:g_buyItemCost;
new Array:g_buyItemRsrc;
new g_buyItemCount;

new g_infectBombAmt;
new g_antidoteKill[33];

new g_mapParamEnt;

public Buy::Precache()
{
	precache_sound("items/9mmclip1.wav");
}

public Buy::KeyValue(ent)
{
	if (!pev_valid(ent))
		return;
	
	new className[32];
	pev(ent, pev_classname, className, charsmax(className));
	
	if (equal(className, "info_map_parameters"))
	{
		DispatchKeyValue(ent, "buying", "3");
		g_mapParamEnt = ent;
	}
}

public Buy::EntSpawn(ent)
{
	if (!g_mapParamEnt)
	{
		new ent = create_entity("info_map_parameters");
		DispatchKeyValue(ent, "buying", "3");
		DispatchSpawn(ent);
		
		g_mapParamEnt = ent;
	}
}

public Buy::Natives()
{
	g_buyItemName = ArrayCreate(32);
	g_buyItemDesc = ArrayCreate(64);
	g_buyItemTeam = ArrayCreate(1);
	g_buyItemCost = ArrayCreate(1);
	g_buyItemRsrc = ArrayCreate(1);
}

public Buy::Init()
{
	register_clcmd("buy2", "CmdBuy2");
	register_clcmd("buyammo1", "CmdBuyAmmo1");
	register_clcmd("buyammo2", "CmdBuyAmmo2");
	
	for (new i = 0; i < sizeof BUY_ITEM_NAME; i++)
	{
		addBuyItem(BUY_ITEM_NAME[i], BUY_ITEM_DESC[i], BUY_ITEM_TEAM[i], BUY_ITEM_COST[i], BUY_ITEM_RS[i]);
	}
}

public Buy::NewRound()
{
	g_infectBombAmt = 0;
	arrayset(g_antidoteKill, 0, sizeof g_antidoteKill);
}

public Buy::GameStart()
{
	g_infectBombAmt = floatround(countHumans() * 0.4);
}

public Buy::BuyMenu(id, item)
{
	if (item == BUY_ITEM_INFECTBOMB)
	{
		formatex(g_additionalText, charsmax(g_additionalText), "\y(%d)", g_infectBombAmt);
	}
	else if (item == BUY_ITEM_ANTIDOTE2)
	{
		formatex(g_additionalText, charsmax(g_additionalText), "\d%d/%d", g_antidoteKill[id], 2);
	}
}

public Buy::Killed(id, attacker)
{
	if (is_user_connected(attacker) && isZombie(attacker) && !isZombie(id))
	{
		g_antidoteKill[attacker]++;
	}
	
	if (isZombie(id))
	{
		g_antidoteKill[id] = 0;
	}
}

public Buy::Infect(id, attacker)
{
	if (is_user_connected(attacker) && isZombie(attacker))
	{
		g_antidoteKill[attacker]++;
	}
}

public Buy::Humanize(id)
{
	g_antidoteKill[id] = 0;
}

public CmdBuy2(id)
{
	ShowBuyMenu(id);
	return PLUGIN_HANDLED;
}

public CmdBuyAmmo1(id)
{
	if (isZombie(id) || !is_user_alive(id))
		return PLUGIN_HANDLED;
	
	buyGunAmmo(id, 1);
	return PLUGIN_HANDLED;
}

public CmdBuyAmmo2(id)
{
	if (isZombie(id) || !is_user_alive(id))
		return PLUGIN_HANDLED;
	
	buyGunAmmo(id, 2);
	return PLUGIN_HANDLED;
}

public ShowBuyMenu(id)
{
	new menu = menu_create("Buy", "HandleBuyMenu");
	
	for (new i = 0; i < g_buyItemCount; i++)
	{
		new team = ArrayGetCell(g_buyItemTeam, i);
		if ((isZombie(id) && !getNemesis(id) && !(team & BUY_TEAM_ZOMBIE))
		|| (getNemesis(id) && !(team & BUY_TEAM_NEMESIS))
		|| (!isZombie(id) && !(team & BUY_TEAM_HUMAN)))
			continue;
		
		static buffer[128], info[16];
		formatex(buffer, charsmax(buffer), "%a \d%a ", ArrayGetStringHandle(g_buyItemName, i), ArrayGetStringHandle(g_buyItemDesc, i));
		
		g_additionalText[0] = 0;
		OnShowBuyMenu(id, i);
		
		if (g_additionalText[0])
			add(buffer, charsmax(buffer), g_additionalText);
		
		add(buffer, charsmax(buffer), "\R");
		
		if (ArrayGetCell(g_buyItemCost, i))
			format(buffer, charsmax(buffer), "%s \y$%d", buffer, ArrayGetCell(g_buyItemCost, i));
		
		if (ArrayGetCell(g_buyItemRsrc, i))
			format(buffer, charsmax(buffer), "%s \r%dRS", buffer, ArrayGetCell(g_buyItemRsrc, i));
		
		num_to_str(i, info, charsmax(info));
		menu_additem(menu, buffer, info);
	}
	
	menu_setprop(menu, MPROP_NUMBER_COLOR, "\y");
	menu_display(id, menu);
}

public HandleBuyMenu(id, menu, item)
{
	if (item == MENU_EXIT)
	{
		menu_destroy(menu);
		return;
	}
	
	new info[10], dummy;
	menu_item_getinfo(menu, item, dummy, info, charsmax(info), _, _, dummy);
	menu_destroy(menu);
	
	if (!is_user_alive(id))
		return;
	
	new index = str_to_num(info);
	new team = ArrayGetCell(g_buyItemTeam, index);
	if ((isZombie(id) && !getNemesis(id) && !(team & BUY_TEAM_ZOMBIE))
	|| (getNemesis(id) && !(team & BUY_TEAM_NEMESIS))
	|| (!isZombie(id) && !(team & BUY_TEAM_HUMAN)))
		return;
	
	new cost = ArrayGetCell(g_buyItemCost, index);
	new rsCost = ArrayGetCell(g_buyItemRsrc, index);
	
	new money = getMoney(id);
	if (money < cost)
	{
		client_print(id, print_center, "#Cstrike_TitlesTXT_Not_Enough_Money");
		return;
	}
	
	new rs = getResource(id);
	if (rs < rsCost)
	{
		client_print(id, print_center, "You have not enough resource point.");
		return;
	}
	
	switch (index)
	{
		case BUY_ITEM_ANTIDOTE2:
		{
			if (g_antidoteKill[id] < 2)
			{
				client_print(id, print_center, "You must kill at least 2 humans.");
				return;
			}
			
			if (getNemesis(id) || getGmonster(id) || getCombiner(id) || getMorpheus(id))
			{
				client_print(id, print_center, "You cannot use this item.");
				return;
			}
			
			humanizePlayer(id);
			emit_sound(id, CHAN_ITEM, SOUND_MEDKIT[random(sizeof SOUND_MEDKIT)], VOL_NORM, ATTN_NORM, 0, PITCH_NORM);
			client_print(0, print_chat, "%n 使用 Antidote 變回人類.", id);
		}
		case BUY_ITEM_INFECTBOMB:
		{
			if (!g_infectBombAmt)
			{
				client_print(id, print_center, "Out of stock.");
				return;
			}
			
			if (getNemesis(id) || getGmonster(id) || getCombiner(id) || getMorpheus(id))
			{
				client_print(id, print_center, "You cannot use this item.");
				return;
			}
			
			if (user_has_weapon(id, CSW_HEGRENADE))
			{
				client_print(id, print_center, "#Cstrike_TitlesTXT_Cannot_Carry_Anymore");
				return;
			}
			
			give_item(id, "weapon_hegrenade");
			g_infectBombAmt--;
		}
		case BUY_ITEM_HEAL:
		{
			if (getNemesis(id) != NEMESIS_1ST)
				return;
			
			set_user_health(id, get_user_health(id) + 1500);
		}
		case BUY_ITEM_ARMOR1:
		{
			new Float:armor, Float:maxArmor;
			pev(id, pev_armorvalue, armor);
			maxArmor = getMaxArmor(id);
			
			if (armor >= maxArmor)
			{
				client_print(id, print_center, "#Cstrike_TitlesTXT_Cannot_Carry_Anymore");
				return;
			}
			
			set_pev(id, pev_armorvalue, floatmin(armor + 100.0, maxArmor));
			
			emit_sound(id, CHAN_ITEM, SOUND_ARMOR[random(sizeof SOUND_ARMOR)], VOL_NORM, ATTN_NORM, 0, PITCH_NORM);
		}
		case BUY_ITEM_ARMOR2:
		{
			new Float:armor, Float:maxArmor;
			pev(id, pev_armorvalue, armor);
			maxArmor = getMaxArmor(id);
			
			if (armor >= maxArmor)
			{
				client_print(id, print_center, "#Cstrike_TitlesTXT_Cannot_Carry_Anymore");
				return;
			}
			
			set_pev(id, pev_armorvalue, floatmin(armor + 300.0, maxArmor));
			
			emit_sound(id, CHAN_ITEM, SOUND_ARMOR[random(sizeof SOUND_ARMOR)], VOL_NORM, ATTN_NORM, 0, PITCH_NORM);
		}
		case BUY_ITEM_FIRSTAID:
		{
			new Float:health, Float:maxHealth;
			pev(id, pev_health, health);
			pev(id, pev_max_health, maxHealth);
			
			if (health >= maxHealth)
			{
				client_print(id, print_center, "#Cstrike_TitlesTXT_Cannot_Carry_Anymore");
				return;
			}
			
			set_pev(id, pev_health, floatmin(health + 120.0, maxHealth));
			
			emit_sound(id, CHAN_ITEM, SOUND_MEDKIT[random(sizeof SOUND_MEDKIT)], VOL_NORM, ATTN_NORM, 0, PITCH_NORM);
		}
		case BUY_ITEM_ANTIDOTE:
		{
			new Float:health, Float:maxHealth;
			pev(id, pev_health, health);
			pev(id, pev_max_health, maxHealth);
			
			set_pev(id, pev_health, floatmin(health + 50.0, maxHealth));
			
			new level = getPoisonLevel(id);
			if (level - 2 <= 0)
				resetPoisoning(id);
			else
				setPoisonLevel(id, level - 2);
				
			emit_sound(id, CHAN_ITEM, SOUND_MEDKIT[random(sizeof SOUND_MEDKIT)], VOL_NORM, ATTN_NORM, 0, PITCH_NORM);
		}
		case BUY_ITEM_FIREBOMB:
		{
			if (user_has_weapon(id, CSW_HEGRENADE))
			{
				client_print(id, print_center, "#Cstrike_TitlesTXT_Cannot_Carry_Anymore");
				return;
			}
			
			give_item(id, "weapon_hegrenade");
		}
		case BUY_ITEM_ICEBOMB:
		{
			if (user_has_weapon(id, CSW_FLASHBANG))
			{
				client_print(id, print_center, "#Cstrike_TitlesTXT_Cannot_Carry_Anymore");
				return;
			}
			
			give_item(id, "weapon_flashbang");
		}
		case BUY_ITEM_FLARE:
		{
			new ent = find_ent_by_owner(-1, "weapon_smokegrenade", id);
			if (pev_valid(ent))
			{
				if (cs_get_user_bpammo(id, CSW_SMOKEGRENADE) >= 2)
				{
					client_print(id, print_center, "#Cstrike_TitlesTXT_Cannot_Carry_Anymore");
					return;
				}
				
				ExecuteHamB(Ham_GiveAmmo, id, 1, "SmokeGrenade", 2);
				emit_sound(id, CHAN_ITEM, "items/9mmclip1.wav", VOL_NORM, ATTN_NORM, 0, PITCH_NORM);
			}
			else
			{
				give_item(id, "weapon_smokegrenade");
			}
		}
		case BUY_ITEM_NVG:
		{
			giveNightVision(id, true);
		}
		case BUY_ITEM_FIRST_WPN .. BUY_ITEM_LAST_WPN:
		{
			static const weaponClasses[][] = 
			{
				"weapon_m3", "weapon_xm1014", 
				"weapon_mp5navy", "weapon_ump45", "weapon_p90", 
				"weapon_galil", "weapon_famas", "weapon_sg552", "weapon_aug",
				"weapon_g3sg1", "weapon_sg550", "weapon_scout", "weapon_awp",
				"weapon_m249"
			};
			
			new index2 = index - BUY_ITEM_FIRST_WPN;
			
			dropWeapons(id, 1);
			give_item(id, weaponClasses[index2]);
		}
	}
	
	setMoney(id, money - cost);
	setResource(id, rs - rsCost);
}

stock buyGunAmmo(id, slot)
{
	new money = getMoney(id);
	new boughtAmmo, canBuy;
	
	// find player items
	new weapon = getPlayerDataEnt(id, "m_rgpPlayerItems", slot);
	
	while (weapon > 0)
	{
		// each ammo type can only buy once
		new ammoId = getWeaponData(weapon, "m_iPrimaryAmmoType");
		if (ammoId > 0 && (~boughtAmmo & (1 << ammoId)))
		{
			// ammo not full
			new max = wa_getAmmoMax(ammoId);
			if (getPlayerData(id, "m_rgAmmo", ammoId) < max)
			{
				new cost = wa_getAmmoCost(ammoId);
				if (money >= cost)
				{
					new amount = wa_getAmmoAmount(ammoId);
					new ammoName[32];
					wa_getAmmoName(ammoId, ammoName, charsmax(ammoName));
					
					if (ExecuteHamB(Ham_GiveAmmo, id, amount, ammoName, max) > -1)
					{
						boughtAmmo |= (1 << ammoId);
						money -= cost;
					}
				}
				canBuy = true;
			}
		}
		
		weapon = get_ent_data_entity(weapon, "CBasePlayerItem", "m_pNext");
	}
	
	if (boughtAmmo)
	{
		emit_sound(id, CHAN_ITEM, "items/9mmclip1.wav", VOL_NORM, ATTN_NORM, 0, PITCH_NORM);
		setMoney(id, money);
	}
	else if (canBuy)
	{
		client_print(id, print_center, "#Cstrike_TitlesTXT_Not_Enough_Money");
	}
}

stock addBuyItem(const name[], const desc[], team, cost, rs)
{
	ArrayPushString(g_buyItemName, name);
	ArrayPushString(g_buyItemDesc, desc);
	ArrayPushCell(g_buyItemTeam, team);
	ArrayPushCell(g_buyItemCost, cost);
	ArrayPushCell(g_buyItemRsrc, rs);
	g_buyItemCount++;
	
	return g_buyItemCount - 1;
}