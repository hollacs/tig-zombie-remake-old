Fatal::Init()
{
	RegisterHam(Ham_TakeDamage, "player", "Fatal@TakeDamage");
}

public Fatal::TakeDamage(id, inflictor, attacker, Float:damage, damageBits)
{
	if (!is_user_connected(attacker) || isZombie(attacker) == isZombie(id))
		return;
	
	if (!isZombie(id) && inflictor == attacker && get_user_weapon(attacker) == CSW_KNIFE && (damageBits & DMG_BULLET))
	{
		if (!isKnifeStabbing(attacker))
			return;
		
		if (OnCanFatalKill(id, attacker) == PLUGIN_HANDLED)
			return;
		
		if (getGmonster(attacker) == GMONSTER_1ST)
		{
			set_hudmessage(200, 0, 100, -1.0, 0.3, 1, 0.0, 3.0, 1.0, 1.0, 2);
			show_hudmessage(0, "G-1 使用致命一擊!");
			
			SetHamParamFloat(4, damage * 100.0);
		}
		else if (getNemesis(attacker) == NEMESIS_2ND)
		{
			if (random_num(0, 2) != 0)
				return;
			
			set_hudmessage(200, 0, 0, -1.0, 0.3, 1, 0.0, 3.0, 1.0, 1.0, 2);
			show_hudmessage(0, "N-2 使用致命一擊!");
			
			SetHamParamFloat(4, damage * 100.0);
		}
		else if (getMorpheus(attacker))
		{
			set_hudmessage(200, 0, 0, -1.0, 0.3, 1, 0.0, 3.0, 1.0, 1.0, 2);
			show_hudmessage(0, "Morpheus 使用致命一擊!");
			
			SetHamParamFloat(4, damage * 100.0);
		}
	}
}