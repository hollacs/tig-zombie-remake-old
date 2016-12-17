#include <amxmodx>
#include <amxmisc>
#include <fun>
#include <cstrike>
#include <engine>
#include <fakemeta>
#include <hamsandwich>
#include <xs>
#include <nvault>
#include <orpheu>
#include <orpheu_stocks>
#include <gamedata_stocks>
#include <weaponammo>

#define VERSION "0.2"

#include "zombiemod/consts.sma"
#include "zombiemod/vars.sma"
#include "zombiemod/hooks.sma"

#include "zombiemod/player.sma"

#include "zombiemod/human.sma"
#include "zombiemod/leader.sma"
#include "zombiemod/supporter.sma"

#include "zombiemod/zombie.sma"
#include "zombiemod/gmonster.sma"
#include "zombiemod/nemesis.sma"
#include "zombiemod/combiner.sma"
#include "zombiemod/morpheus.sma"

#include "zombiemod/gamerules.sma"

#include "zombiemod/firebomb.sma"
#include "zombiemod/icebomb.sma"
#include "zombiemod/flare.sma"
#include "zombiemod/infectbomb.sma"

#include "zombiemod/fatalhit.sma"
#include "zombiemod/poisoning.sma"
#include "zombiemod/buy.sma"
#include "zombiemod/armor.sma"
#include "zombiemod/nightvision.sma"
#include "zombiemod/randomitem.sma"
#include "zombiemod/hudinfo.sma"
#include "zombiemod/music.sma"
#include "zombiemod/menu.sma"
#include "zombiemod/level.sma"
#include "zombiemod/gunlevel.sma"
#include "zombiemod/save.sma"
#include "zombiemod/command.sma"
#include "zombiemod/api.sma"
#include "zombiemod/stocks.sma"

public plugin_precache()
{
	OnPluginPrecache();
}

public plugin_natives()
{
	OnPluginNatives();
}

public plugin_init()
{
	register_plugin("Zombie Mod", VERSION, "penguinux");
	
	OnPluginInit();
}

public plugin_end()
{
	OnPluginEnd();
}

public client_disconnected(id)
{
	OnClientDisconnect(id);
}

public client_putinserver(id)
{
	OnClientPutInServer(id);
}

public client_death(killer, victim, weapon, hit, teamKill)
{
	OnClientDeath(killer, victim, weapon, hit, teamKill);
}