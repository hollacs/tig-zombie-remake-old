#define Player::%0(%1) 		Player@%0(%1)
#define Human::%0(%1) 		Human@%0(%1)
#define Supporter::%0(%1) 	Supporter@%0(%1)
#define Leader::%0(%1) 		Leader@%0(%1)
#define Zombie::%0(%1) 		Zombie@%0(%1)
#define Gmonster::%0(%1) 	Gmonster@%0(%1)
#define Nemesis::%0(%1) 	Nemesis@%0(%1)
#define Combiner::%0(%1) 	Combiner@%0(%1)
#define Morpheus::%0(%1) 	Morpheus@%0(%1)
#define GameRules::%0(%1) 	GameRules@%0(%1)
#define Buy::%0(%1) 		Buy@%0(%1)
#define HudInfo::%0(%1) 	HudInfo@%0(%1)
#define Armor::%0(%1) 		Armor@%0(%1)
#define Nvg::%0(%1) 		Nvg@%0(%1)
#define Menu::%0(%1) 		Menu@%0(%1)
#define FireBomb::%0(%1) 	FireBomb@%0(%1)
#define IceBomb::%0(%1) 	IceBomb@%0(%1)
#define Flare::%0(%1) 		Flare@%0(%1)
#define InfectBomb::%0(%1) 	InfectBomb@%0(%1)
#define Level::%0(%1) 		Level@%0(%1)
#define Save::%0(%1) 		Save@%0(%1)
#define Poison::%0(%1) 		Poison@%0(%1)
#define Fatal::%0(%1) 		Fatal@%0(%1)
#define RandItem::%0(%1) 	RandItem@%0(%1)
#define Command::%0(%1) 	Command@%0(%1)
#define Api::%0(%1) 		Api@%0(%1)
#define GunLv::%0(%1) 		GunLv@%0(%1)
#define Boomer::%0(%1) 		Boomer@%0(%1)

#define HOOK_RESULT _hookResult
#define HOOK_RETURN(%0) return ((_hookTemp = %0) > _hookResult) ? (_hookResult=_hookTemp) : _hookResult

#define FFADE_IN 		0x0000 // Just here so we don't pass 0 into the function
#define FFADE_OUT 		0x0001 // Fade out (not in)
#define FFADE_MODULATE 	0x0002 // Modulate (don't blend)
#define FFADE_STAYOUT 	0x0004 // ignores the duration, stays faded out until new ScreenFade message received

#define PEV_NADE_TYPE pev_flTimeStepSound

enum
{
	TEAM_UNASSIGNED,
	TEAM_TERRORIST,
	TEAM_CT,
	TEAM_SPECTATOR
};

enum
{
	Event_Target_Bombed = 1,
	Event_VIP_Escaped,
	Event_VIP_Assassinated,
	Event_Terrorists_Escaped,
	Event_CTs_PreventEscape,
	Event_Escaping_Terrorists_Neutralized,
	Event_Bomb_Defused,
	Event_CTs_Win,
	Event_Terrorists_Win,
	Event_Round_Draw,
	Event_All_Hostages_Rescued,
	Event_Target_Saved,
	Event_Hostages_Not_Rescued,
	Event_Terrorists_Not_Escaped,
	Event_VIP_Not_Escaped,
	Event_Game_Commencing,
};

enum
{
	WinStatus_CT = 1,
	WinStatus_Terrorist,
	WinStatus_Draw
};

enum(+=40)
{
	TASK_ROUNDSTART,
	TASK_RESPAWN,
	TASK_MUSIC,
	TASK_HUDINFO,
	TASK_FROZEN,
	TASK_ARMOR,
	TASK_BOOST,
	TASK_GODMODE,
	TASK_LIGHTSTYLE
}

enum(<<= 1)
{
	BUY_TEAM_HUMAN = 1,
	BUY_TEAM_ZOMBIE,
	BUY_TEAM_NEMESIS,
}

enum
{
	BUY_ITEM_INFECTBOMB,
	BUY_ITEM_ANTIDOTE2,
	BUY_ITEM_HEAL,
	BUY_ITEM_ARMOR1,
	BUY_ITEM_ARMOR2,
	BUY_ITEM_FIRSTAID,
	BUY_ITEM_ANTIDOTE,
	BUY_ITEM_FIREBOMB,
	BUY_ITEM_ICEBOMB,
	BUY_ITEM_FLARE,
	BUY_ITEM_NVG,
	BUY_ITEM_FIRST_WPN,
	BUY_ITEM_LAST_WPN = 24,
}

enum
{
	GMONSTER_1ST = 1,
	GMONSTER_2ND,
	GMONSTER_3RD,
}

enum
{
	NEMESIS_1ST = 1,
	NEMESIS_2ND
}

enum
{
	LEADER_MALE = 1,
	LEADER_FEMALE
};

enum
{
	GAMEMODE_NORMAL_G,
	GAMEMODE_NORMAL_N,
	GAMEMODE_GMONSTER,
	GAMEMODE_NEMESIS,
	GAMEMODE_FINAL
};

enum
{
	ATTRIBH_HP = 0,
	ATTRIBH_AP,
	ATTRIBH_STR,
	ATTRIBH_INT,
	ATTRIBH_DEX,
	ATTRIBH_LUK,
	ATTRIBH_FAI,
	ATTRIBH_MAX
}

const NADE_ICE = 8235;
const NADE_ICE_SUPER = 6023;

new const SOUND_MUTATION[] = "zombiemod/mutation.wav";
new const SOUND_NVG_ON[]  = "items/nvg_on.wav";
new const SOUND_NVG_OFF[] = "items/nvg_off.wav";
new const SOUND_ARMOR[][] = {"items/ammopickup1.wav", "items/ammopickup2.wav"};
new const SOUND_MEDKIT[][] = {"items/smallmedkit1.wav", "items/smallmedkit2.wav"};

new const GUN_NAMES[][] = {
	"", "P228", "", "Scout", "", "XM1014", "", "MAC10", "AUG", "", "Elite", "FiveSeven",
	"UMP45", "SG550", "Galil", "Famas", "USP", "Glock18", "AWP", "MP5", "M249", "M3",
	"M4A1", "TMP", "G3SG1", "", "Deagle", "SG552", "AK47", "", "P90"
};