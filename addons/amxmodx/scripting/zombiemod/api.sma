new g_fwInfectPlayer;
new g_fwZombieKnifeDeploy;
new g_fwResetMaxSpeed;
new g_fwPainShock;
new g_fwKnockBack;

public Api::Init()
{
	g_fwInfectPlayer = CreateMultiForward("zm_InfectPlayer", ET_IGNORE, FP_CELL, FP_CELL);
	g_fwZombieKnifeDeploy = CreateMultiForward("zm_ZombieKnifeDeploy", ET_IGNORE, FP_CELL);
	g_fwResetMaxSpeed = CreateMultiForward("zm_ResetMaxSpeed", ET_IGNORE, FP_CELL);
	g_fwPainShock = CreateMultiForward("zm_PainShock", ET_IGNORE, FP_CELL, FP_CELL, FP_CELL, FP_FLOAT, FP_CELL);
	g_fwKnockBack = CreateMultiForward("zm_KnockBack", ET_IGNORE, FP_CELL, FP_CELL, FP_FLOAT, FP_ARRAY, FP_CELL, FP_CELL);
}

public Api::ResetMaxSpeed(id)
{
	ExecuteForward(g_fwResetMaxSpeed, g_return, id);
}

public Api::InfectPlayer(id, attacker)
{
	ExecuteForward(g_fwInfectPlayer, g_return, id, attacker);
}

public Api::ZombieKnifeDeploy(id)
{
	ExecuteForward(g_fwZombieKnifeDeploy, g_return, id);
}

public Api::PainShock(id, inflictor, attacker, Float:damage, damageBits)
{
	ExecuteForward(g_fwPainShock, g_return, id, inflictor, attacker, damage, damageBits);
}

public Api::KnockBack(id, attacker, Float:damage, Float:direction[3], tr, damageBits)
{
	new array = PrepareArray(_:direction, 3, 1);
	ExecuteForward(g_fwKnockBack, g_return, id, attacker, damage, array, tr, damageBits);
}