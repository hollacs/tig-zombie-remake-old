new g_money[33];
new g_resource[33];
new g_knifeMoney[33];
new Float:g_damageTotal[33];

new Float:g_oldModifier;
new Float:g_oldVelocity[3];
new Float:g_oldDamage;

new Float:g_knockBack;
new Float:g_painShock;

public Player::Natives()
{
	register_native("zm_multiplyPainShock", "native_multiplyPainShock", 1);
	register_native("zm_multiplyKnockBack", "native_multiplyKnockBack", 1);
}

public Player::Init()
{
	register_forward(FM_ClientKill, "OnClientKill");
	
	RegisterHam(Ham_TraceAttack, "player", "Player@TraceAttack");
	RegisterHam(Ham_TakeDamage, "player", "Player@TakeDamage");
	RegisterHam(Ham_TakeDamage, "player", "Player@TakeDamage_P", 1);
	
	set_msg_block(get_user_msgid("ClCorpse"), BLOCK_SET);
}

public Player::NewRound()
{
	for (new i = 1; i <= g_maxClients; i++)
	{
		g_knifeMoney[i] = 0;
	}
}

public Player::TraceAttack(id, attacker, Float:damage, Float:direction[3], tr, damageBits)
{
	if (is_user_connected(attacker) && !isZombie(attacker) && isZombie(id))
	{
		new Float:velocity[3];
		pev(id, pev_velocity, velocity);
		
		if (get_user_weapon(attacker) != CSW_KNIFE)
		{
			xs_vec_mul_scalar(direction, damage, direction);
			xs_vec_mul_scalar(direction, 5.0, direction);
			
			// hook
			g_knockBack = 1.0;
			OnKnockBack(id, attacker, damage, direction, tr, damageBits);
			xs_vec_mul_scalar(direction, g_knockBack, direction);
		}
		else
		{
			if (getLeader(attacker))
			{
				if (isKnifeStabbing(attacker))
					xs_vec_mul_scalar(direction, 1000.0, direction);
				else
					xs_vec_mul_scalar(direction, 500.0, direction);
			}
			else if (getSupporter(attacker))
			{
				if (isKnifeStabbing(attacker))
					xs_vec_mul_scalar(direction, 900.0, direction);
			}
			else
			{
				if (isKnifeStabbing(attacker) && !getGmonster(id) && !getNemesis(id))
					xs_vec_mul_scalar(direction, 900.0, direction);
			}
		}
		
		xs_vec_add(direction, velocity, velocity);
		set_pev(id, pev_velocity, velocity);
	}
}

public Player::TakeDamage(id, inflictor, attacker, Float:damage, damageBits)
{
	if (!is_user_connected(attacker) || isZombie(attacker) == isZombie(id))
		return;
	
	if (inflictor == attacker && (damageBits & DMG_BULLET))
	{
		g_damageTotal[attacker] += damage;
		
		if (isZombie(attacker))
		{
			while (g_damageTotal[attacker] > 300)
			{
				addAccount(attacker, 25);
				g_damageTotal[attacker] -= 300.0;
			}
		}
		else
		{
			if (get_user_weapon(attacker) == CSW_KNIFE && isKnifeStabbing(attacker) && g_knifeMoney[attacker] < 2000)
			{
				addAccount(attacker, 100);
				g_knifeMoney[attacker] += 100;
			}
			else
			{
				while (g_damageTotal[attacker] > 400)
				{
					addAccount(attacker, 25);
					setResource(attacker, getResource(attacker) + random_num(1, 3));
					g_damageTotal[attacker] -= 400.0;
				}
			}
		}
	}
	
	// store sth...
	pev(id, pev_velocity, g_oldVelocity);
	
	g_oldModifier = getPlayerDataF(id, "m_flVelocityModifier");
	g_oldDamage = damage;
}

public Player::TakeDamage_P(id, inflictor, attacker, Float:damage, damageBits)
{
	if (is_user_connected(attacker) && isZombie(attacker) != isZombie(id))
	{
		new Float:dmgMultiplier = 1.0;
		
		new hitGroup = get_ent_data(id, "CBaseMonster", "m_LastHitGroup");
		switch (hitGroup)
		{
			case HIT_HEAD:
			{
				g_painShock = 0.4;
				dmgMultiplier = 4.0;
			}
			case HIT_CHEST:
			{
				g_painShock = 0.65;
			}
			case HIT_STOMACH:
			{
				g_painShock = 0.6;
				dmgMultiplier = 1.25;
			}
			case HIT_LEFTLEG, HIT_RIGHTLEG:
			{
				g_painShock = 0.35;
				dmgMultiplier = 0.75;
			}
			default:
			{
				g_painShock = 0.65;
			}
		}
		
		if (g_oldDamage > 0)
		{
			new Float:baseDamage = g_oldDamage / dmgMultiplier;
			
			if (baseDamage > 35)
				g_painShock *= 0.75;
		}
		
		// hook
		OnPainShock(id, inflictor, attacker, damage, damageBits);
		
		g_painShock = floatclamp(g_painShock, 0.0, 1.0);
		
		if (g_painShock < g_oldModifier)
			setPlayerDataF(id, "m_flVelocityModifier", g_painShock);
		else
			setPlayerDataF(id, "m_flVelocityModifier", g_oldModifier);
		
		if (!isZombie(attacker))
		{
			if (inflictor == attacker && (damageBits & DMG_BULLET) && get_user_weapon(attacker) == CSW_KNIFE)
			{
				if (getLeader(attacker) 
				|| (getSupporter(attacker) && isKnifeStabbing(attacker)) 
				|| (isKnifeStabbing(attacker) && !getGmonster(id) && !getNemesis(id)))
					setPlayerDataF(id, "m_flVelocityModifier", 1.0);
			}
		}
		
		set_pev(id, pev_velocity, g_oldVelocity);
	}
}

public Player::MsgMoney(id)
{
	setPlayerData(id, "m_iAccount", g_money[id]);
	set_msg_arg_int(1, ARG_LONG, g_money[id])
}

public Player::Killed_P(id, killer)
{
	if (is_user_connected(killer) && isZombie(id) != isZombie(killer))
	{
		if (isZombie(id))
		{
			if (getGmonster(id))
			{
				addAccount(killer, 3000);
				client_print(0, print_chat, "%n 殺死 G-Virus Monster 獲得 $1000.", killer);
			}
			else if (getNemesis(id))
			{
				addAccount(killer, 3500);
				client_print(0, print_chat, "%n 殺死 Nemesis 獲得 $1100.", killer);
			}
			else if (getCombiner(id))
			{
				addAccount(killer, 2000);
				client_print(0, print_chat, "%n 殺死 Combiner 獲得 $600.", killer);
			}
			else if (getMorpheus(id))
			{
				addAccount(killer, 2250);
				client_print(0, print_chat, "%n 殺死 Morpheus 獲得 $700.", killer);
			}
			else
			{
				addAccount(killer, 250);
			}
			
			setResource(killer, getResource(killer) + random_num(10, 20));
		}
		else
		{
			if (getLeader(id))
			{
				addAccount(killer, 3000);
				client_print(0, print_chat, "%n 殺死 Leader 獲得 $1000.", killer);
			}
			else if (getSupporter(id))
			{
				addAccount(killer, 2000);
				client_print(0, print_chat, "%n 殺死 Supporter 獲得 $600.", killer);
			}
			else
			{
				addAccount(killer, 300);
			}
		}
	}
}

public Player::Infect(id, attacker)
{
	if (is_user_connected(attacker) && isZombie(attacker))
	{
		if (getLeader(id))
		{
			addAccount(attacker, 3000);
			client_print(0, print_chat, "%n 殺死 Leader 獲得 $1000.", attacker);
		}
		else if (getSupporter(id))
		{
			addAccount(attacker, 2000);
			client_print(0, print_chat, "%n 殺死 Supporter 獲得 $600.", attacker);
		}
		else
		{
			addAccount(attacker, 300);
		}
	}
}

public Player::Humanize(id)
{
	g_resource[id] = 300;
}

public Player::Disconnect(id)
{
	g_money[id] = 0;
	g_resource[id] = 0;
	g_damageTotal[id] = 0.0;
	g_knifeMoney[id] = 0;
}

public OnClientKill(id)
{
	if (~get_user_flags(id) & ADMIN_RCON)
		return FMRES_SUPERCEDE;
	
	return FMRES_IGNORED;
}

public native_multiplyPainShock(Float:value)
{
	multiplyPainShock(value);
}

public native_multiplyKnockBack(Float:value)
{
	multiplyKnockBack(value);
}

stock getMoney(id)
{
	return g_money[id];
}

stock setMoney(id, money, bool:update=true)
{
	if (money > 60000)
		money = 60000;
	
	setPlayerData(id, "m_iAccount", money);
	
	static msgMoney;
	msgMoney || (msgMoney = get_user_msgid("Money"));
	
	message_begin(MSG_ONE_UNRELIABLE, msgMoney, _, id);
	write_long(money);
	write_byte(update);
	message_end();
	
	g_money[id] = money;
}

stock addAccount(id, amount, bool:update=true)
{
	setMoney(id, getMoney(id) + amount, update);
}

stock multiplyKnockBack(Float:value)
{
	g_knockBack *= value;
}

stock multiplyPainShock(Float:value)
{
	g_painShock *= value;
}

stock getResource(id)
{
	return g_resource[id];
}

stock setResource(id, value)
{
	g_resource[id] = value;
}