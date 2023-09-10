#include <amxmodx>
#include <fun>
#include <fakemeta>
#include <cstrike>

#include <zombiemod>

#define ZOMBIE_NAME "Fast"
#define ZOMBIE_DESC "Move faster"
#define ZOMBIE_CLASS "zombie_fast"
#define ZOMBIE_FLAGS 0

#define ZOMBIE_HEALTH 1500
#define ZOMBIE_GRAVITY 1.0
#define ZOMBIE_SPEED 1.3
#define ZOMBIE_PAINSHOCK 0.9
#define ZOMBIE_KNOCKBACK 1.5

new g_type;

public plugin_precache()
{
	precache_model("models/player/zombie_fast/zombie_fast.mdl");
}

public plugin_init()
{
	register_plugin("[ZM] Zombie: Fast", "0.1", "penguinux");
	
	g_type = zm_createZombieType(ZOMBIE_NAME, ZOMBIE_DESC, ZOMBIE_CLASS, ZOMBIE_FLAGS);
}

public zm_ResetMaxSpeed(id)
{
	if (zm_isZombie(id) && zm_getZombieType(id) == g_type)
	{
		set_user_maxspeed(id, get_user_maxspeed(id) * ZOMBIE_SPEED);
	}
}

public zm_InfectPlayer(id)
{
	if (zm_getZombieType(id) == g_type)
	{
		set_user_health(id, ZOMBIE_HEALTH);
		set_pev(id, pev_max_health, float(ZOMBIE_HEALTH));
		set_user_gravity(id, ZOMBIE_GRAVITY);
		
		cs_set_user_model(id, "zombie_fast");
	}
}

public zm_PainShock(id)
{
	if (zm_isZombie(id) && zm_getZombieType(id) == g_type)
	{
		zm_multiplyPainShock(ZOMBIE_PAINSHOCK);
	}
}

public zm_KnockBack(id)
{
	if (zm_isZombie(id) && zm_getZombieType(id) == g_type)
	{
		zm_multiplyKnockBack(ZOMBIE_KNOCKBACK);
	}
}