#if defined _weaponammo_included
	#endinput
#endif
#define _weaponammo_included

enum _:AmmoData
{
	AmmoAmt,
	AmmoCost,
	AmmoMax
};

// {Amount, Cost, Max}
new const AMMO_DATA[][AmmoData] = 
{
	{-1,  -1,  -1},
	{10,  1, 30}, // 338magnum
	{30,  1,  90}, // 762nato
	{30,  1, 200}, // 556natobox
	{30,  1,  90}, // 556nato
	{ 8,  1,  32}, // buckshot
	{12,  1, 100}, // 45acp
	{50,  1, 100}, // 57mm
	{ 1,  2,  1}, // 50ae
	{13,  1,  52}, // 357sig
	{30,  1, 100}, // 9mm
	{ 1,  -1,   2}, // Flashbang
	{ 1,  -1,   2}, // HEGrenade
	{ 1,  -1,   3}, // SmokeGrenade
	{-1,  -1,   1} // C4
};

new const AMMO_NAMES[][] =
{
	"",
	"338magnum",
	"762nato",
	"556natobox",
	"556nato",
	"buckshot",
	"45acp",
	"57mm",
	"50ae",
	"357sig",
	"9mm",
	"Flashbang",
	"HEGrenade",
	"SmokeGrenade",
	"C4"
};

new const WEAPON_AMMOTYPES[] = 
{
	0,
	9, //p228
	0,
	2, //scout
	12, //hegrenade
	5, //xm1014
	14, //c4
	6, //mac10
	4, //aug
	13, //smoke
	10, //elite
	7, //fiveseven
	6, //ump45
	4, //sg550
	4, //galil
	4, //famas
	6, //usp
	10, //glock
	1, //awp
	10, //mp5
	3, //m249
	5, //m3
	4, //m4a1
	10, //tmp
	2, //g3sg1
	11, //flash
	8, //deagle
	4, //sg552
	2, //ak47
	0,
	7 //p90
}

stock wa_getWeaponAmmoType(weapon)
{
	return WEAPON_AMMOTYPES[weapon];
}

stock wa_getAmmoAmount(type)
{
	return AMMO_DATA[type][AmmoAmt];
}

stock wa_getAmmoCost(type)
{
	return AMMO_DATA[type][AmmoCost];
}

stock wa_getAmmoMax(type)
{
	return AMMO_DATA[type][AmmoMax];
}

stock wa_getAmmoName(type, output[], len)
{
	copy(output, len, AMMO_NAMES[type]);
}

stock wa_getEntAmmoType(ent)
{
	if (pev_valid(ent))
		return get_ent_data(ent, "CBasePlayerWeapon", "m_iPrimaryAmmoType");
	
	return 0;
}

stock wa_giveFullAmmo(player, type)
{
	wa_giveAmmo(player, type, AMMO_DATA[type][AmmoMax], AMMO_DATA[type][AmmoMax]);
}

stock wa_giveAmmo(player, type, amount=0, max=0)
{
	if (!amount)
		amount = AMMO_DATA[type][AmmoAmt];
	if (!max)
		max = AMMO_DATA[type][AmmoMax];
	
	new ammo = getPlayerData(player, "m_rgAmmo", type);

	ExecuteHamB(Ham_GiveAmmo, player, amount, AMMO_NAMES[type], max);
	
	if (ammo >= max)
		return false;
	
	return true;
}

stock wa_giveWeaponAmmo(player, weapon, amount=0, max=0)
{
	new type = wa_getWeaponAmmoType(weapon);
	return wa_giveAmmo(player, type, amount, max);
}

stock wa_giveWeaponFullAmmo(player, weapon)
{
	new type = wa_getWeaponAmmoType(weapon);
	wa_giveFullAmmo(player, type);
}