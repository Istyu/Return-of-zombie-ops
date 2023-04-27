/*=======================================================================================
                        __________      __________      
                        \______   \ ____\____    /____  
                         |       _//  _ \ /     //  _ \ 
                         |    |   (  <_> )     /(  <_> )
                         |____|_  /\____/_______ \____/ 
                                \/              \/      

=========================================================================================
Return of the Zombie Ops - Mod
Modded by Lefti & 3aGl3
=========================================================================================
Zombie Arena-Gamemode
=======================================================================================*/
#include scripts\_utility;
#include scripts\_weapon_key;
/*
	Arena
	Objective: 	Survive all waves.
	Map ends:	When all survivors are down, or the last wave is survived.
	Respawning:	Between zombie waves
*/

main()
{
	maps\mp\gametypes\_globallogic::init();
	maps\mp\gametypes\_callbacksetup::SetupCallbacks();
	maps\mp\gametypes\_globallogic::SetupCallbacks();
		
	SetDvarMinMax( "scr_arena_timelimit", 360, 0, 3600 );		// 60 Mins
	SetDvarMinMax( "scr_arena_wavelimit", 24, 0, 99 );			// results in wave 25 as the last, max is 100
	SetDvarMinMax( "scr_arena_wavetime", 60, 0, 360 );			// 1 Minute, 60 is max.
	SetDvarMinMax( "scr_arena_wavezombies", 50, 0, 1000 );		// 50 Zombies, 1000 is max.
	SetDvarIfUninitialized( "scr_arena_weapon1", "mp5" );
	SetDvarIfUninitialized( "scr_arena_weapon2", "m1014" );
	SetDvarIfUninitialized( "scr_arena_weapon3", "m4" );
	SetDvarIfUninitialized( "scr_arena_weapon4", "saw" );
	SetDvarIfUninitialized( "scr_arena_weapon5", "m60e4" );

	level.teamBased = true;
	level.customLoadout = true;
	level.gamemodeNoShops = true;
	level.onPrecacheGametype = :: onPrecacheGametype;
	level.onStartGameType = ::onStartGameType;
	level.onEndWave = ::onEndWave;
	
	thread [[level.waitForEndGame]]();		// ends the game when there are no more survivors
	initLoadout();
}

onStartGameType()
{
	setClientNameMode("auto_change");

	allowed[0] = "arena";
	maps\mp\gametypes\_gameobjects::main(allowed);
}

onPrecacheGametype()
{
	precacheString( &"ZMB_ARENA_WAVE_N_OVER" );
	precacheString( &"ZMB_ARENA_N_ZOMBIES_KILLED" );
	precacheString( &"ZMB_ARENA_TIME_FOR_WEAPON" );
}

onEndWave()
{
	notifyData = spawnstruct();
	
	notifyData.titleLabel = &"ZMB_ARENA_WAVE_N_OVER";
	notifyData.titleText = level.waveID;
	notifyData.textLabel = &"ZMB_ARENA_N_ZOMBIES_KILLED";
	notifyData.notifyText = level.zombiesKilled;
	
	if( isNewWeaponWave() )
	{
		notifyData.notifyText2 = &"ZMB_ARENA_TIME_FOR_WEAPON";
		updateLoadout();
	}
	
	players = getSurvivors();
	
	for( i=0; i<players.size; i++ )
	{
		players[i] thread maps\mp\gametypes\_hud_message::notifyMessage( notifyData );
		players[i] thread updatePlayersLoadout();
	}
}

initLoadout()
{
	level.loadout = [];
	level.loadout["primary"] = getDvar("scr_arena_weapon1");
	level.loadout["pattachment"] = "none";
	level.loadout["secondary"] = "none";
	level.loadout["sattachment"] = "none";
	level.loadout["camo"] = randomInt( 6 );
	level.loadout["grenade"] = "none";
	level.loadout["sgrenade"] = "none";
	level.loadout["armor"] = "none";																// ToDo: Get the right values?
	level.loadout["medikit"] = "none";
	level.loadout["perk1"] = "specialty_scavenger";
	level.loadout["perk2"] = "specialty_fastreload";
	level.loadout["perk3"] = "specialty_pistoldeath";
	level.loadout["equipment"] = "none";
}

updateLoadout()
{
	dvarId = (level.waveID/5)+1;
	if( getDvar( "scr_arena_weapon"+dvarId ) != "" )
	{
		newPrimary = getDvar( "scr_arena_weapon"+dvarId );
		newSecondary = level.loadout["primary"];
	}
	else
	{
		newPrimary = level.loadout["primary"];
		newSecondary = level.loadout["secondary"];
	}

	level.loadout["primary"] = newPrimary;
	level.loadout["secondary"] = newSecondary;
}

updatePlayersLoadout()
{
	wait 2;
	self maps\mp\gametypes\_class::giveLoadout();
	self _givemaxammo( level.loadout["primary"] );
	
	if( level.loadout["secondary"] != "none" )
		self _givemaxammo(level.loadout["secondary"]);
}

isNewWeaponWave()
{
	if( (level.waveID % 5) == 0 )
		return true;
	
	return false;
}