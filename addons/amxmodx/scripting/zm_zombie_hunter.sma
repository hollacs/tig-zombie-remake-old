#include <amxmodx>
#include <fun>
#include <cstrike>
#include <fakemeta>
#include <hamsandwich>
#include <xs>

#include <zombiemod>

#define ZOMBIE_NAME "Hunter"
#define ZOMBIE_DESC "Leap"
#define ZOMBIE_CLASS "zombie_hunter"
#define ZOMBIE_FLAGS 0

#define ZOMBIE_HEALTH 1000
#define ZOMBIE_GRAVITY 0.5
#define ZOMBIE_SPEED 0.95
#define ZOMBIE_PAINSHOCK 0.8
#define ZOMBIE_KNOCKBACK 2.0

new const SOUND_LEAP[][] = {"zombiemod/hunter_leap1.wav", "zombiemod/hunter_leap2.wav"}

new g_type;

new Float:g_lastLeapTime[33];

public plugin_precache()
{
	precache_model("models/player/zombie_hunter/zombie_hunter.mdl");
	
	precache_sound(SOUND_LEAP[0]);
	precache_sound(SOUND_LEAP[1]);
}

public plugin_init()
{
	register_plugin("[ZM] Zombie: Fast", "0.1", "penguinux");
	
	RegisterHam(Ham_Player_Jump, "player", "OnPlayerJump");
	
	g_type = zm_createZombieType(ZOMBIE_NAME, ZOMBIE_DESC, ZOMBIE_CLASS, ZOMBIE_FLAGS);
}

public OnPlayerJump(id)
{
	if (!zm_isZombie(id) || zm_getZombieType(id) != g_type)
		return;
	
	if ((pev(id, pev_button) & IN_DUCK) && (pev(id, pev_flags) & FL_ONGROUND) && get_gametime() >= g_lastLeapTime[id] + 1.5)
	{
		new Float:velocity[3], Float:angles[3], Float:vector[3];
		pev(id, pev_velocity, velocity);
		pev(id, pev_v_angle, angles);
		
		if (angles[0] > -25.0)
			angles[0] = -25.0;
		
		angle_vector(angles, ANGLEVECTOR_FORWARD, vector);
		
		xs_vec_mul_scalar(vector, 450.0, vector);
		xs_vec_add(velocity, vector, velocity);
		
		set_pev(id, pev_velocity, velocity);
		
		emit_sound(id, CHAN_VOICE, SOUND_LEAP[random(sizeof SOUND_LEAP)], 1.0, ATTN_NORM, 0, PITCH_NORM);
		
		g_lastLeapTime[id] = get_gametime();
	}
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
		set_pev(id, pev_max_health, ZOMBIE_HEALTH * 1.0);
		set_user_gravity(id, ZOMBIE_GRAVITY);
		
		cs_set_user_model(id, "zombie_hunter");
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