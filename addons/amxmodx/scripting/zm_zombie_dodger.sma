#include <amxmodx>
#include <fun>
#include <fakemeta>
#include <cstrike>

#include <zombiemod>

#define ZOMBIE_NAME "Dodger"
#define ZOMBIE_DESC "Negative knockback"
#define ZOMBIE_CLASS "zombie_dodger"
#define ZOMBIE_FLAGS 0

#define ZOMBIE_HEALTH 2000
#define ZOMBIE_GRAVITY 1.0
#define ZOMBIE_SPEED 1.0
#define ZOMBIE_PAINSHOCK 1.1
#define ZOMBIE_KNOCKBACK -2.0

new g_type;

public plugin_precache()
{
	precache_model("models/player/zombie_source/zombie_source.mdl");
}

public plugin_init()
{
	register_plugin("[ZM] Zombie: Dodger", "0.1", "penguinux");
	
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
		
		cs_set_user_model(id, "zombie_source");
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