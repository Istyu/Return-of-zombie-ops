//=======================================================================================
// Helicopter Killstreak Script
// Created for Global OPS Mod
//=======================================================================================
#include scripts\_utility;

init()
{
	path_start = getentarray( "heli_start", "targetname" );
	loop_start = getentarray( "heli_loop_start", "targetname" );
	
	if( !path_start.size && !loop_start.size)
		return;
	
	//	precache n stuff
	precacheString( &"ZMB_HELICOPTER" );
	precacheString( &"MP_HELICOPTER_NOT_AVAILABLE" );
	
	//	init vars
	level.helicopterInterval = xDvarInt( "scr_streak_cobra_interval", 180, 60, 420 );			// time helicopters stay
	//level.littlebirdInterval = xDvarInt( "scr_streak_ah6_interval", 240, 90, 480 );
	//level.pavelowInterval = xDvarInt( "scr_streak_pavelow_interval", 180, 60, 420 );
	
	//	model, anims & fx
	level.fx_heli_dust = loadFx( "treadfx/heli_dust_default" );
	level.fx_heli_water = loadFx( "treadfx/heli_water" );
	
	//level.registerHardpoint//( name,			kills,	callThread,			title,					XP,	trigger,	icon,					sound )
	[[level.registerHardpoint]]( "helicopter", xDvarInt( "scr_streak_cobra_kills", 150 ), ::HelicopterThink, &"ZMB_HELICOPTER", "radar_mp", "compass_objpoint_helicopter", "mp_killstreak_heli" );
	
	//registerHardpoint( name, kills, callThread, sound, title, XP, trigger, icon )
	//maps\mp\gametypes\_hardpoints::registerHardpoint( "helicopter_mp", 7, ::HelicopterThink, "mp_killstreak_heli", &"MP_EARNED_HELICOPTER", 2, "helicopter_mp", "compass_objpoint_helicopter" );
	//maps\mp\gametypes\_hardpoints::registerHardpoint( "littlebird_mp", 9, ::LittlebirdThink, "mp_killstreak_ah6", &"MP_EARNED_AH6", 4, "helicopter_mp" );
	//maps\mp\gametypes\_hardpoints::registerHardpoint( "pavelow_mp", 9, ::PavelowThink, "mp_killstreak_mh53", &"MP_EARNED_MH53", 4, "helicopter_mp" );
}

HelicopterThink()
{
	if ( isDefined(level.chopper) )
	{
		self iPrintLnBold( &"MP_HELICOPTER_NOT_AVAILABLE" );
		return false;
	}

	destination = 0;
	random_path = randomint( level.heli_paths[destination].size );
	startnode = level.heli_paths[destination][random_path];

	team = self.pers["team"];
	otherTeam = level.otherTeam[team];


	thread printAllPlayers( &"MP_HELICOPTER_INBOUND", self );


	thread maps\mp\_helicopter::heli_think( self, startnode, self.pers["team"] );
	return true;
}