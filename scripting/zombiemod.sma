/*
 * [人類技能]
 *
 * 體力(30): 
 * - 提升HP上限(1~30體)
 * - 抗屍王致命一擊(15體或以上)
 *
 * 耐力(30): 
 * - 提升AP上限(1~30耐)
 * - 抗毒(10耐或以上)
 *
 * 力量(30): 
 * - 小刀攻擊力(1~15力)
 * - 擊退強化(15~30力)
 * - 擊退屍王(20力或以上)
 *
 * 智力(25): 
 * - 增加冰彈時間(1~10智)
 * - 冰彈冰住屍王(10智或以上)
 * - 增加火彈傷害(10智或以上)
 * - 增加火彈時間(20或以上)
 *
 * 敏捷(20): 
 * - 跳躍強化(1~10敏)
 * - 速度強化(10~20敏)
 * - 快速投擲(15敏或以上)
 *
 * 幸運(10): 
 * - 小刀攻擊增加HP(幸+體)
 * - 小刀攻擊增加AP(幸+耐)
 *
 * 信仰(20):
 * - 恢復HP (信+10體或以上)
 * - 恢復AP (信+10耐或以上)
 * - 行走中恢復 (10信或以上)
 *
 * 未決定: 增加槍械擊退/緩衝, 光彈對喪屍有特殊能力, 小刀攻擊距離, 小刀多重攻擊
 *
 * [喪屍技能]
 * 體力: 提升HP上限
 * 耐力: 提升抗擊退/緩衝能力
 * 力量: 提升近身攻擊力
 * 速度: 提升速度
 * 跳躍: 提升跳躍力
 */

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

#define VERSION "0.3"

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
#include "zombiemod/boomer.sma"

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