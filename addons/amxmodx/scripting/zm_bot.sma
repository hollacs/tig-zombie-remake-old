#include <amxmodx>
#include <fun>
#include <cstrike>

#include <zombiemod>

new const PRIMARY_WEAPONS[] = 
{
	CSW_M3,	CSW_XM1014,
	CSW_MP5NAVY, CSW_UMP45, CSW_P90,
	CSW_GALIL, CSW_FAMAS, CSW_AK47, CSW_M4A1, CSW_SG552, CSW_AUG,
	CSW_G3SG1, CSW_SG550, CSW_AWP, CSW_M249
};

new const SECONDARY_WEAPONS[] = 
{
	CSW_GLOCK18,
	CSW_USP,
	CSW_P228,
	CSW_FIVESEVEN,
	CSW_ELITE
}

public plugin_init()
{
	register_plugin("[ZM] Bot", "0.1", "penguinux");
}

public zm_HumanizePlayer(id)
{
	if (is_user_bot(id))
	{
		strip_user_weapons(id);
		
		new weaponName[32];
		new weapon;
		
		// Give pistols
		weapon = SECONDARY_WEAPONS[random(sizeof SECONDARY_WEAPONS)];
		get_weaponname(weapon, weaponName, charsmax(weaponName));
		
		give_item(id, weaponName);
		cs_set_user_bpammo(id, weapon, 99999);
		
		// Give primary weapon
		weapon = PRIMARY_WEAPONS[random(sizeof PRIMARY_WEAPONS)];
		get_weaponname(weapon, weaponName, charsmax(weaponName));
		
		give_item(id, weaponName);
		cs_set_user_bpammo(id, weapon, 99999);
		
		give_item(id, "weapon_knife");
	}
}