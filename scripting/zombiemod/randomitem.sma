enum
{
	RANDITEM_HEALTH,
	RANDITEM_ARMOR,
	RANDITEM_NVG,
	RANDITEM_FIRE,
	RANDITEM_ICE,
	RANDITEM_FLARE
}

new const RANDITEM_CHANCES[] = {4, 3, 8, 6, 5, 3};

public RandItem::Init()
{
	register_think("dropped_item", "RandItem@Think");
	register_touch("dropped_item", "player", "RandItem@Touch");
}

public RandItem::Killed_P(id)
{
	if (isZombie(id))
	{
		new rand = random(sizeof RANDITEM_CHANCES);
		if (random_num(0, RANDITEM_CHANCES[rand]) == 0)
		{
			createDroppedItem(id, rand);
		}
	}
}

public RandItem::NewRound()
{
	new ent = FM_NULLENT;
	while ((ent = find_ent_by_class(ent, "dropped_item")) != 0)
	{
		if (pev_valid(ent))
			remove_entity(ent);
	}
}

public RandItem::Think(ent)
{
	remove_entity(ent);
}

public RandItem::Touch(ent, player)
{
	if (isZombie(player))
		return;
	
	switch (pev(ent, pev_iuser1))
	{
		case RANDITEM_HEALTH:
		{
			new Float:health, Float:maxHealth, Float:amount;
			pev(player, pev_health, health);
			pev(player, pev_max_health, maxHealth);
			amount = random_float(50.0, 150.0);
			
			set_pev(player, pev_health, floatmin(health + amount, maxHealth));
			
			emit_sound(player, CHAN_ITEM, SOUND_MEDKIT[random(sizeof SOUND_MEDKIT)], VOL_NORM, ATTN_NORM, 0, PITCH_NORM);
			
			client_print(0, print_chat, "%n found HP %.f.", player, amount);
		}
		case RANDITEM_ARMOR:
		{
			new Float:armor, Float:maxArmor, Float:amount;
			pev(player, pev_armorvalue, armor);
			maxArmor = getMaxArmor(player);
			amount = random_float(50.0, 200.0);
			
			set_pev(player, pev_armorvalue, floatmin(armor + amount, maxArmor));
			
			emit_sound(player, CHAN_ITEM, SOUND_ARMOR[random(sizeof SOUND_ARMOR)], VOL_NORM, ATTN_NORM, 0, PITCH_NORM);
			
			client_print(0, print_chat, "%n found Armor %.f.", player, amount);
		}
		case RANDITEM_NVG:
		{
			giveNightVision(player, true);
			client_print(0, print_chat, "%n found Night Vision.", player);
		}
		case RANDITEM_FIRE:
		{
			give_item(player, "weapon_hegrenade");
			client_print(0, print_chat, "%n found Incendiary Grenade.", player);
		}
		case RANDITEM_ICE:
		{
			give_item(player, "weapon_flashbang");
			client_print(0, print_chat, "%n found Nitrogen Grenade.", player);
		}
		case RANDITEM_FLARE:
		{
			new smoke = find_ent_by_owner(-1, "weapon_smokegrenade", player);
			if (pev_valid(smoke))
			{
				if (cs_get_user_bpammo(player, CSW_SMOKEGRENADE) < 2)
				{
					ExecuteHamB(Ham_GiveAmmo, player, 1, "SmokeGrenade", 2);
					emit_sound(player, CHAN_ITEM, "items/9mmclip1.wav", VOL_NORM, ATTN_NORM, 0, PITCH_NORM);
				}
			}
			else
			{
				give_item(player, "weapon_smokegrenade");
			}
			
			client_print(0, print_chat, "%n found Flare.", player);
		}
	}
	
	remove_entity(ent);
}

stock createDroppedItem(player, item)
{
	new Float:origin[3], Float:angles[3];
	pev(player, pev_origin, origin);
	pev(player, pev_angles, angles);
	angles[0] = 0.0;
	
	new ent = create_entity("info_target");
	
	entity_set_origin(ent, origin);
	
	switch (item)
	{
		case RANDITEM_HEALTH, RANDITEM_ARMOR, RANDITEM_NVG:
		{
			entity_set_size(ent, Float:{-1.0, -1.0, -1.0}, Float:{1.0, 1.0, 1.0});
			entity_set_model(ent, "models/w_thighpack.mdl");
		}
		case RANDITEM_FIRE:
		{
			entity_set_size(ent, Float:{-2.0, -2.0, -2.0}, Float:{2.0, 2.0, 2.0});
			entity_set_model(ent, "models/w_hegrenade.mdl");
		}
		case RANDITEM_ICE:
		{
			entity_set_size(ent, Float:{-2.0, -2.0, -2.0}, Float:{2.0, 2.0, 2.0});
			entity_set_model(ent, "models/w_flashbang.mdl");
		}
		case RANDITEM_FLARE:
		{
			entity_set_size(ent, Float:{-2.0, -2.0, -2.0}, Float:{2.0, 2.0, 2.0});
			entity_set_model(ent, "models/w_flashbang.mdl");
		}
	}
	
	set_rendering(ent, kRenderFxGlowShell, 0, 200, 0, kRenderNormal, 16);
	
	set_pev(ent, pev_iuser1, item);
	set_pev(ent, pev_solid, SOLID_TRIGGER);
	set_pev(ent, pev_angles, angles);
	set_pev(ent, pev_classname, "dropped_item");
	set_pev(ent, pev_movetype, MOVETYPE_TOSS);
	set_pev(ent, pev_nextthink, get_gametime() + 30.0);
}