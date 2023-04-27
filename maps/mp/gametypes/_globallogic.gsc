/*=======================================================================================
Return of the Zombie Ops - Mod
Modded by Lefti & 3aGl3
=========================================================================================
Zombie Globallogic by 3aGl3
=======================================================================================*/
#include scripts\_utility;
#include scripts\_weapon_key;
#include maps\mp\gametypes\_hud_util;

init()
{
	// hack to allow maps with no scripts to run correctly
	if ( !isDefined( level.tweakablesInitialized ) )
		maps\mp\gametypes\_tweakables::init();
		
	SetDvarIfUninitialized( "scr_player_sprinttime", 4 );
	
	level.splitscreen = isSplitScreen();						// ToDo: Figure out all resulting errors after remove
	
	level.script = toLower( getDvar( "mapname" ) );
	level.gametype = toLower( getDvar( "g_gametype" ) );
	
	level.otherTeam["allies"] = "axis";							// usefull for if team != tema etc
	level.otherTeam["axis"] = "allies";
	
	level.teamBased = false;
	
	level.overrideTeamScore = false;
	level.overridePlayerScore = false;
	level.displayHalftimeText = false;
	level.displayRoundEndText = true;
	
	level.endGameOnScoreLimit = true;
	level.endGameOnTimeLimit = true;
	
	level.placement["allies"] = [];
	level.placement["axis"] = [];
	level.placement["all"] = [];
	
	level.customLoadout = false;
	
	level.lastSlowProcessFrame = 0;
	
	level.placement["allies"] = [];
	level.placement["axis"] = [];
	level.placement["all"] = [];
	
	level.postRoundTime = 8.0;
	
	level.inOvertime = false;

	level.dropTeam = getdvarint( "sv_maxclients" );
	
	registerDvars();
	
	precacheModel( "tag_origin" );
	
	precacheShader( "faction_128_usmc" );						// using stock materials, changing iwi
	precacheShader( "faction_128_ussr" );
}

registerDvars()
{
	SetDvarIfUninitialized( "scr_oldschool", 0 );
	makeDvarServerInfo( "scr_oldschool" );

	setDvar( "ui_bomb_timer", 0 );
	makeDvarServerInfo( "ui_bomb_timer" );
	
	SetDvarIfUninitialized( "scr_show_unlock_wait", 0.1 );
	SetDvarIfUninitialized( "scr_intermission_time", 5.0 );
}

SetupCallbacks()
{
	level.spawnClient = ::spawnClient;
	level.spawnSpectator = ::spawnSpectator;
	level.spawnIntermission = ::spawnIntermission;
		
	level.onSpawnPlayer = ::blank;
	level.onSpawnSpectator = ::default_onSpawnSpectator;
	level.onSpawnIntermission = ::default_onSpawnIntermission;
	
	level.onPrecacheGametype = ::blank;
	level.onStartGameType = ::blank;
	level.onPlayerConnect = ::blank;
	level.onPlayerDisconnect = ::blank;
	level.onPlayerDamage = ::blank;
	level.onPlayerKilled = ::blank;

	level.onStartWave = ::blank;
	level.onEndWave = ::blank;
	level.onEndGame = ::blank;
	
	level.waitForEndGame = ::waitForEndGame;
	level.spawn = ::menuSpawn;
	level.endGame = ::endGame;
}

Callback_StartGameType()
{
	level.intermission = false;
	
	if ( !isDefined( game["gamestarted"] ) )
	{
		// overwriting in pure zombie maps
		game["allies"] = "marines";
		game["axis"] = "russian";

		if ( !isDefined( game["state"] ) )
			game["state"] = "playing";
		
		precacheStatusIcon( "hud_status_dead" );
		precacheStatusIcon( "hud_status_connecting" );
		
		precacheShader( "white" );
		precacheShader( "black" );
		
		game["strings"]["press_to_spawn"] = &"PLATFORM_PRESS_TO_SPWAN";
		game["strings"]["spawn_next_round"] = &"MP_SPAWN_NEXT_ROUND";
		
		// game end strings
		game["strings"]["target_reached"] = &"ZMB_TARGET_REACHED";
		game["strings"]["survivors_died"] = &"ZMB_SURVIVORS_DEAD";
		game["strings"]["last_wave_done"] = &"ZMB_WE_ARE_SAVE";
		// gampvote strings
		game["strings"]["mapvote_header"] = &"ZMB_MAPVOTE_TITLE";
		game["strings"]["mapvote_hint"] = &"ZMB_MAPVOTE_HINT";
		game["strings"]["mapvote_time"] = &"ZMB_MAPVOTE_TIME";
		
		// Team setup
		game["icons"]["allies"] = "faction_128_usmc";
		game["colors"]["allies"] = (0,0,0);
		//game["voice"]["allies"] = "US_1mc_";		//not sure if used
		setDvar( "scr_allies", "sas" );
		makeDvarServerInfo( "scr_allies" );
		
		game["icons"]["axis"] = "faction_128_ussr";
		game["colors"]["axis"] = (0.52,0.28,0.28);
		//game["voice"]["axis"] = "RU_1mc_";
		setDvar( "scr_axis", "ussr" );
		makeDvarServerInfo( "scr_axis" );
		
		// music setup
		game["music"]["spawn"] = "mp_spawn";
		game["music"]["victory"] = "mp_victory";
		game["music"]["defeat"] = "mp_defeat";
		
		game["music"]["suspense"] = [];																// ToDo: remove these if a player music system works
		game["music"]["suspense"][game["music"]["suspense"].size] = "mp_suspense_01";
		game["music"]["suspense"][game["music"]["suspense"].size] = "mp_suspense_02";
		game["music"]["suspense"][game["music"]["suspense"].size] = "mp_suspense_03";
		game["music"]["suspense"][game["music"]["suspense"].size] = "mp_suspense_04";
		game["music"]["suspense"][game["music"]["suspense"].size] = "mp_suspense_05";
		game["music"]["suspense"][game["music"]["suspense"].size] = "mp_suspense_06";
		
		// game dialogs -- do we need a battlechater?
		game["dialog"]["last_alive"] = "lastalive";
		
		[[level.onPrecacheGameType]]();
		
		game["gamestarted"] = true;
		
		game["teamScores"]["allies"] = 0;															// ToDo: doubt we need these but I bet the menus do, if not delete
		game["teamScores"]["axis"] = 0;
		
		level.players = [];
	}
	
	if(!isdefined(game["timepassed"]))
		game["timepassed"] = 0;

	if(!isdefined(game["roundsplayed"]))
		game["roundsplayed"] = 0;
		
	level.skipVote = false;
	level.gameEnded = false;

	level.objIDStart = 0;
	level.forcedEnd = false;
	level.hostForcedEnd = false;
//	level.everSpawnedSurvivor = false;
	
	SetDvarIfUninitialized( "scr_zombie_teamDamagePunish", 3 );
	level.minimumAllowedTeamDamage = getDvarInt( "scr_zombie_teamDamagePunish" );
	
	if( getdvar( "r_reflectionProbeGenerate" ) == "1" )												// not sure if really needed
		level waittill( "eternity" );
	
//	thread contentCheck();
	
	// INIT scripts
	thread maps\mp\gametypes\_persistence::init();
	thread maps\mp\gametypes\_menus::init();
	thread maps\mp\gametypes\_hud::init();
	thread maps\mp\gametypes\_serversettings::init();
	thread maps\mp\gametypes\_clientids::init();
	thread maps\mp\gametypes\_weapons::init();
	thread maps\mp\gametypes\_scoreboard::init();
	thread maps\mp\gametypes\_shellshock::init();
	thread maps\mp\gametypes\_damagefeedback::init();
	thread maps\mp\gametypes\_health::init();
	thread maps\mp\gametypes\_spectating::init();
	thread maps\mp\gametypes\_objpoints::init();
	thread maps\mp\gametypes\_gameobjects::init();
	thread maps\mp\gametypes\_spawnlogic::init();
//	thread maps\mp\gametypes\_battlechatter_mp::init();												// do we need a battlechatter?
//	thread maps\mp\gametypes\_friendicons::init();
	thread maps\mp\gametypes\_hud::init();
	thread maps\mp\gametypes\_hud_message::init();
	thread maps\mp\gametypes\_quickmessages::init();
	thread maps\mp\gametypes\_hardpoints::init();
//	thread scripts\level\_levelsetup::init();
	thread scripts\game\_mapsystem::init();
	thread scripts\game\_servermessages::init();
	thread scripts\game\_waves::init();
	thread scripts\player\init::init();
	thread scripts\zombie\_zombies::init();
	
	stringNames = getArrayKeys( game["strings"] );
	for ( index = 0; index < stringNames.size; index++ )
		precacheString( game["strings"][stringNames[index]] );
	
	//level.activePlayers = [];
	//level.inPrematchPeriod = true;
	
	[[level.onStartGameType]]();
	
	thread maps\mp\gametypes\_dev::init();
		
	thread startGame();
}

startGame()
{
	level notify( "starting_game" );
}

contentCheck()
{
	for(;;)
	{
		if( getDvar("sv_iwdNames") != "" )
			break;
			
		wait 0.1;
	}
	
	wait 1;
	
	// we now assume everything is wrong
	weapons = false;
	sounds = false;
	images = false;
	number = false;
	
	iwdnames = strTok( getDvar("sv_iwdNames"), " " );
	iwdsizes = strTok( getDvar("sv_iwds"), " " );
	for( i=0; i<iwdnames.size; i++ )
	{
		if( iwdnames[i] == "zz_weapons" && iwdsizes[i] == "594271045" )
			weapons = true;
		else if( iwdnames[i] == "zz_sounds" && iwdsizes[i] == "214453361" )
			sounds = true;
		else if( iwdnames[i] == "zz_images" && iwdsizes[i] == "-488873375" )
			images = true;
	}
	
	if( iwdnames.size == 19 )
		number = true;
	
	if( weapons == false || sounds == false || images == false || number == false )
	{
		iprintlnbold("^1Invalid IWD Detected!"); 
		iprintlnbold("^1DO NOT change the mods IWDs!");
		
		wait 5;
		
		logPrint( "INVALID IWD: Invalid Mod IWD detected.\n" );
		maps\mp\gametypes\_callbacksetup::AbortLevel();
	}
}

Callback_PlayerConnect()
{
	thread notifyConnecting();
	
	self.statusicon = "hud_status_connecting";
	self waittill( "begin" );
	waittillframeend;
	self.statusicon = "";
	
	level notify( "connected", self );
	
	if( !isDefined(self.pers["score"]) )
		iPrintLn( &"MP_CONNECTED", self );
		
	selfnum = self getEntityNumber();
	selfguid = self getGuid();
	logPrint( "J;"+selfguid+";"+selfnum+";"+self.name+"\n");
	
	self setClientDvars( "cg_drawCrosshair", 1,
						 "cg_drawCrosshairNames", 0,
						 "cg_hudGrenadeIconMaxRangeFrag", 250 );
	
	self setClientDvars("cg_hudGrenadeIconHeight", "25", 
						"cg_hudGrenadeIconWidth", "25", 
						"cg_hudGrenadeIconOffset", "50", 
						"cg_hudGrenadePointerHeight", "12", 
						"cg_hudGrenadePointerWidth", "25", 
						"cg_hudGrenadePointerPivot", "12 27", 
						"cg_fovscale", "1");
	
	self initPersStat( "score" );
	self.score = self.pers["score"];

	self initPersStat( "deaths" );
	self.deaths = self getPersStat( "deaths" );

	self initPersStat( "suicides" );
	self.suicides = self getPersStat( "suicides" );

	self initPersStat( "kills" );
	self.kills = self getPersStat( "kills" );

	self initPersStat( "headshots" );
	self.headshots = self getPersStat( "headshots" );
	self.waveHeadshots = 0;
	
	self initPersStat( "meleekills" );
	self.meleekills = self getPersStat( "meleekills" );
	self.waveMeleekills = 0;
	
	self initPersStat( "fragkills" );
	self.fragkills = self getPersStat( "fragkills" );
	self.waveFragkills = 0;
	
	self initPersStat( "sidearmkills" );
	self.sidearmkills = self getPersStat( "sidearmkills" );
	self.waveSidearmkills = 0;

	self initPersStat( "assists" );
	self.assists = self getPersStat( "assists" );
	
	self initPersStat( "downs" );
	self.downs = self getPersStat( "downs" );
	
	self.damagedAllies = [];
	self.killedBy = [];
	
	self.cur_kill_streak = 0;
	self.cur_death_streak = 0;
	//self.death_streak = self maps\mp\gametypes\_persistence::statGet( "death_streak" );			// ToDO
	//self.kill_streak = self maps\mp\gametypes\_persistence::statGet( "kill_streak" );
	
	self.hasSpawned = false;
	self.waitingToSpawn = false;
	self.deathCount = 0;
	
	self.wasAliveAtMatchStart = false;
	
	self thread maps\mp\_flashgrenades::monitorFlash();												// ToDo: team flash!
	
	level.players[level.players.size] = self;
	
	self updateScores();
	
	// When joining a game in progress, if the game is at the post game state (scoreboard) the connecting player should spawn into intermission
	if ( game["state"] == "postgame" )
	{
		self.pers["team"] = "spectator";
		self.team = "spectator";

		self setClientDvars( "ui_hud_hardcore", 1,
							 "cg_drawSpectatorMessages", 0 );
		
		[[level.spawnIntermission]]();
		self closeMenu();
		self closeInGameMenu();
		return;
	}

	level endon( "game_ended" );	
	
	if ( !isDefined( self.pers["team"] ) )															// not sure if really possible to connect with set Team
	{
		self.pers["team"] = "spectator";
		self.team = "spectator";
		self.sessionstate = "dead";
		
		self updateObjectiveText();
		
		[[level.spawnSpectator]]();
		
		self setClientDvar( "g_scriptMainMenu", game["menu_team"] );
		self openMenu( game["menu_team"] );
		
		if ( self.pers["team"] == "spectator" )
			self.sessionteam = "spectator";
		
		self.sessionteam = self.pers["team"];
		if ( !isAlive( self ) )
			self.statusicon = "hud_status_dead";
		self thread maps\mp\gametypes\_spectating::setSpectatePermissions();
	}
	else if ( self.pers["team"] == "spectator" )
	{
		self setClientDvar( "g_scriptMainMenu", game["menu_team"] );
		self.sessionteam = "spectator";
		self.sessionstate = "spectator";
		[[level.spawnSpectator]]();
	}
	else
	{
		self.sessionteam = self.pers["team"];
		self.sessionstate = "dead";
		
		self updateObjectiveText();
		
		[[level.spawnSpectator]]();
		
		if ( self.waitingToSpawn )
		{
			self thread [[level.spawnClient]]();			
		}
		else
		{
			self setClientDvar( "g_scriptMainMenu", game["menu_team"] );
			self openMenu( game["menu_team"] );
		}
		
		self thread maps\mp\gametypes\_spectating::setSpectatePermissions();
	}
	
	self notify( "connected" );
}


Callback_PlayerDisconnect()
{
	self removePlayerOnDisconnect();	
	
	
	[[level.onPlayerDisconnect]]();
	
	lpselfnum = self getEntityNumber();
	lpGuid = self getGuid();
	logPrint("Q;" + lpGuid + ";" + lpselfnum + ";" + self.name + "\n");
	
	for ( entry = 0; entry < level.players.size; entry++ )
	{
		if( level.players[entry] == self )
		{
			while( entry < level.players.size-1 )
			{
				level.players[entry] = level.players[entry+1];
				entry++;
			}
			level.players[entry] = undefined;
			break;
		}
	}
		
	if ( level.gameEnded )
		self removeDisconnectedPlayerFromPlacement();
}

removePlayerOnDisconnect()
{
	for( i=0; i<level.players.size; i++ )
	{
		if( level.players[i] == self )
		{
			while( i < level.players.size-1 )
			{
				level.players[i] = level.players[i+1];
				i++;
			}
			level.players[i] = undefined;
			break;
		}
	}
}

removeDisconnectedPlayerFromPlacement()
{
	offset = 0;
	numPlayers = level.placement["all"].size;
	found = false;
	for( i = 0; i < numPlayers; i++ )
	{
		if ( level.placement["all"][i] == self )
			found = true;
		
		if ( found )
			level.placement["all"][i] = level.placement["all"][ i + 1 ];
	}
	if ( !found )
		return;
	
	level.placement["all"][ numPlayers - 1 ] = undefined;
	assert( level.placement["all"].size == numPlayers - 1 );

	/#
	// no longer calling this here because it's possible, due to delayed assist credit,
	// for someone's score to change after updatePlacement() is called.
	//assertProperPlacement();
	#/
	
	updateTeamPlacement();
	
	if( level.teamBased )
		return;
		
	numPlayers = level.placement["all"].size;
	for ( i = 0; i < numPlayers; i++ )
	{
		player = level.placement["all"][i];
		player notify( "update_outcome" );
	}
	
}

updateTeamPlacement()
{
	placement["allies"]    = [];
	placement["axis"]      = [];
	placement["spectator"] = [];
	
	if ( !level.teamBased )
		return;
	
	placementAll = level.placement["all"];
	placementAllSize = placementAll.size;
	
	for ( i = 0; i < placementAllSize; i++ )
	{
		player = placementAll[i];
		team = player.pers["team"];
		
		placement[team][ placement[team].size ] = player;
	}
	
	level.placement["allies"] = placement["allies"];
	level.placement["axis"]   = placement["axis"];
}

/*updateTeamStatus()
{
	// run only once per frame, at the end of the frame.
	level notify("updating_team_status");
	level endon("updating_team_status");
	level endon ( "game_ended" );
	waittillframeend;
	
	wait 0;	// Required for Callback_PlayerDisconnect to complete before updateTeamStatus can execute

	if ( game["state"] == "postgame" )
		return;

	resetTimeout();
	
	prof_begin( "updateTeamStatus" );

	level.playerCount["allies"] = 0;
	level.playerCount["axis"] = 0;
	
	level.lastAliveCount["allies"] = level.aliveCount["allies"];
	level.lastAliveCount["axis"] = level.aliveCount["axis"];
	level.aliveCount["allies"] = 0;
	level.aliveCount["axis"] = 0;
	level.playerLives["allies"] = 0;
	level.playerLives["axis"] = 0;
	level.alivePlayers["allies"] = [];
	level.alivePlayers["axis"] = [];
	level.activePlayers = [];

	players = level.players;
	for ( i = 0; i < players.size; i++ )
	{
		player = players[i];
		
		if ( !isDefined( player ) && level.splitscreen )
			continue;

		team = player.team;
		class = player.class;
		
		if ( team != "spectator" && (level.oldschool || (isDefined( class ) && class != "")) )
		{
			level.playerCount[team]++;
			
			if ( player.sessionstate == "playing" )
			{
				level.aliveCount[team]++;
				level.playerLives[team]++;

				if ( isAlive( player ) )
				{
					level.alivePlayers[team][level.alivePlayers.size] = player;
					level.activeplayers[ level.activeplayers.size ] = player;
				}
			}
			else
			{
				if ( player maySpawn() )
					level.playerLives[team]++;
			}
		}
	}
	
	if ( level.aliveCount["allies"] + level.aliveCount["axis"] > level.maxPlayerCount )
		level.maxPlayerCount = level.aliveCount["allies"] + level.aliveCount["axis"];
	
	if ( level.aliveCount["allies"] )
		level.everExisted["allies"] = true;
	if ( level.aliveCount["axis"] )
		level.everExisted["axis"] = true;
	
	prof_end( "updateTeamStatus" );
	
//	level updateGameEvents();
}*/

Callback_PlayerDamage(eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, timeOffset)
{
	if( self.sessionteam == "spectator" )
		return;
	
	if(isDefined(self.godmode) && self.godmode) 
		return;
	
	// Sticky Semtexes
	if( getScriptName( sWeapon ) == "frag_grenade_short" && sMeansOfDeath == "MOD_IMPACT" )
	{
		eInflictor.origin = eInflictor.origin+(0, 0, -100000); // Throw the original nade away so it wont cause a 2nd explostion
	
		eAttacker playlocalSound("c4_bounce_default");
		eAttacker playlocalSound("mp_last_stand");

		self thread scripts\player\weapons\_sticky::semtex_explosion( eAttacker );
		return;
	}
	
	// Crossbow Bolts
	if( getScriptName( sWeapon ) == "crossbow_explosive" && sMeansOfDeath == "MOD_IMPACT") 
	{
		eInflictor.origin = eInflictor.origin+(0, 0, -100000);	 // Throw the original bolt away so it wont cause a 2nd explostion
		
		eAttacker playlocalSound("c4_bounce_default");
		eAttacker playlocalSound("mp_last_stand");

		self thread scripts\player\weapons\_sticky::bolt_explosion( eAttacker );
		return;
	}
	
/*	if( !isDefined(self.attackers) )
		self.attackers = [];*/
	
	if( self.pers["team"] == "axis" && self isBulletproof() && (sMeansOfDeath == "MOD_RIFLE_BULLET" || sMeansOfDeath == "MOD_PISTOL_BULLET") && sWeapon != getConsoleName("crossbow") )
		return;
	
	// Helicopters
	if( isDefined(eAttacker) && isDefined(eAttacker.owner) )
		eAttacker = eAttacker.owner;
	
	//printLn( sHitLoc+";"+vPoint+";"+self.origin );
	
	if( isDefined(level.points["type"]) )
	{
		if( level.points["type"] == 1 )
		{
			if( iDamage > self.health )
				points = self.health;
			else
				points = iDamage;
		}
		else if( level.points["type"] == 2 )
			points = iDamage;
		else
			points = 10;
	}
	else
		points = 10;
	
	if( isHeadShot( sWeapon, sHitLoc, sMeansOfDeath, vPoint, self ) )
	{
		sMeansOfDeath = "MOD_HEAD_SHOT";
		
		if( self isTank() )
		{
			if( caliberHigh(sWeapon) )
				iDamage = self.maxhealth+10;
			else if( caliberMed(sWeapon) )
				iDamage = iDamage*2;
		}
		else
		{
			if( caliberMed(sWeapon) )
				iDamage = self.maxhealth+10;		// we make this a kill, no matter what
			else
				iDamage = iDamage*2;
		}
	}
	else
	{
		// This is only calculated if we got NO headshot!
		
		// damage tweaks of perks etc.
		if( self.pers["team"] == "allies" )
		{
			// specialty_armorvest
			if( sMeansOfDeath == "MOD_EXPLOSIVE" )
			{
				if( self hasPerkX("specialty_armorvest") )
					iDamage = int(iDamage*0.75);
				else if( self hasPerkX("specialty_armorvest_two") )
					iDamage = int(iDamage*0.50);
				else if( self hasPerkX("specialty_armorvest_pro") )
					iDamage = int(iDamage*0.35);
			}
		}
	}
	
	if( isPlayer(eAttacker) )
	{
		if( isDefined(eAttacker) && eAttacker == self || self.team == eAttacker.team )		// self damage
			return;
		else if( isDefined(eAttacker) && isDefined(eAttacker.pers["team"]) && eAttacker.pers["team"] != self.pers["team"] && eAttacker != self )
		{
			// for assists
			attackdata["attacker"] = eAttacker;
			attackdata["damage"] = iDamage;
			
		//	self.attackers[self.attackers.size] = attackdata;
	
			self finishPlayerDamage( eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, timeOffset );
			self notify( "increaseRage", iDamage*10, eAttacker );
			
			eAttacker scripts\player\_points::givePoints( points );
		}
	}
	else
	{
		self finishPlayerDamage( eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, timeOffset );
		self notify( "damaged", eAttacker );
	}
	
	if( isdefined(eAttacker) && eAttacker != self )
	{
		hasBodyArmor = false;
		isTank = false;
		if( isDefined(self.loadout) && isDefined(self.loadout["armor"]) && self.loadout["armor"] != "armor_none" )
			hasBodyArmor = true;
		else if( isDefined(self.zombie["type"]) && self isTank() )
			isTank = true;
		
		if ( iDamage > 0 )
			eAttacker thread maps\mp\gametypes\_damagefeedback::updateDamageFeedback( isTank, hasBodyArmor );
	}
}


isHeadShot( sWeapon, sHitLoc, sMeansOfDeath, vPoint, victim )
{
	if( sMeansOfDeath == "MOD_MELEE" || sMeansOfDeath == "MOD_IMPACT" )
		return false;
	
	if( sWeapon == "knife_mp" || sWeapon == "flamethrower_mp" )		// ofc those weapons won't do a Headshot
		return false;
	
	if( sHitLoc == "head" || sHitLoc == "helmet" )
		return true;

	if( !isDefined(vPoint) )		// if the point isn't givven we need to asume that it's no headshot
		return false;

	eye = victim getTagOrigin( "j_head" );
	
	if( distance( eye, vPoint ) <= 6 )
		return true;
	
	return false;
}


// self = killed player
Callback_PlayerKilled(eInflictor, eAttacker, iDamage, sMeansOfDeath, sWeapon, vDir, sHitLoc, timeOffset, deathAnimDuration)	// ToDo: Rework this function
{
	self endon( "spawned" );
	self notify( "killed_player" );
	
	if( self.sessionteam == "spectator" )
		return;

	// Helicopters
	if( isDefined(eAttacker.owner) && !isPlayer(eAttacker) )
		eAttacker = eAttacker.owner;
	
	if( isHeadShot( sWeapon, sHitLoc, sMeansOfDeath, self.origin, self ) )
		sMeansOfDeath = "MOD_HEAD_SHOT";
	
	self.sessionstate = "dead";
	self.statusicon = "hud_status_dead"; 
	
	if( !isDefined(self.reviveInProgress) || self.reviveInProgress == false )
	{
		self.killedPlayersCurrent = [];
		
		self.deathCount++;
		self incPersStat( "deaths", 1 );
		self.deaths = self getPersStat( "deaths" );
		
		self.cur_death_streak++;
		self.cur_kill_streak = 0;
	}
	
	/*for( i=0; i<self.attackers.size; i++ )
	{
		assist = self.attackers[i];
		if( !isDefined(assist["attacker"]) || !isPlayer(assist["attacker"]) || assist["attacker"] == eAttacker )
			continue;
		
		if( assist["damage"] > (self.maxhealth/4)*3 )
			points = "assist_75";
		else if( assist["damage"] > (self.maxhealth/2) )
			points = "assist_50";
		else
			points = "assist_25";
		
		assist["attacker"] incPersStat( "assists", 1 );
		assist["attacker"].assists = getPersStat( "assists" );
		assist["attacker"] thread maps\mp\gametypes\_rank::giveRankXP( points );
	}*/
	
	if( self.pers["team"] == "allies" || level.zomFX["explo"] == false )
	{
		if( !isDefined(self.reviveInProgress) || self.reviveInProgress == false )
		{
			body = self clonePlayer( deathAnimDuration );
			if( self isOnLadder() || self isMantling() )
				body startRagDoll();
			
			thread delayStartRagdoll( body, sHitLoc, vDir, sWeapon, eInflictor, sMeansOfDeath );
			
			self.body = body;
			thread scripts\player\perks\tier1\_scavenger::makePickup( self.body );
		}
	}
	
	if( self.pers["team"] == "axis" )	// zombie
	{
		level.zombiesAlive--;
		level.zombiesKilled++;
		level notify( "zombie_died", self );
		
		//iPrintLn(sWeapon);
		if( isDefined(sWeapon) && sWeapon != "" )
		{
			if( sWeapon == "none" || sWeapon == "cobra_20mm_mp" )
			{
				if( self isSpecial() && isPlayer(eAttacker) && eAttacker.pers["team"] == "allies" )
					thread printAllPlayers( &"ZMB_KILLED_ZOM", eAttacker, level.zmbTypes[self.zombie["type"]].killfeed );
			}
			else
			{
				weapontok = strTok( getScriptName(sWeapon), "_" );
				if( weapontok[0] == "turret" )
					weapon = &"WEAPON_TURRET";
				else if( weapontok[0] == "helicopter" )
					weapon = &"WEAPON_HELICOPTER";
				else
					weapon = tableLookupIString( "mp/statsTable.csv", 4, weapontok[0], 3 );
				
				if( sMeansOfDeath == "MOD_MELEE" )
					weapon = &"WEAPON_KNIFE";
				
				if( sMeansOfDeath == "MOD_GRENADE_SPLASH" )
					weapon = &"WEAPON_EXPLOSION";
				
				if( self isSpecial() && isPlayer(eAttacker) && eAttacker.pers["team"] == "allies" )
					thread printAllPlayers( &"ZMB_KILLED_ZOM_WITH_A", eAttacker, level.zmbTypes[self.zombie["type"]].killfeed, weapon );
			}
		}

		self thread scripts\zombie\_zombies::onZombieKilled(eInflictor, eAttacker, iDamage, sMeansOfDeath, sWeapon, vDir, sHitLoc, timeOffset, deathAnimDuration);
	}
	self thread [[level.onPlayerKilled]](eInflictor, eAttacker, iDamage, sMeansOfDeath, sWeapon, vDir, sHitLoc, timeOffset, deathAnimDuration);
	
	if( isPlayer(eAttacker) && eAttacker != self )
	{
		eAttacker incPersStat( "kills", 1 );
		eAttacker.kills = eAttacker getPersStat( "kills" );
		
		if( isHeadShot( sWeapon, sHitLoc, sMeansOfDeath, self.origin, self ) )
		{
			eAttacker incPersStat( "headshots", 1 );
			eAttacker.headshots = eAttacker getPersStat( "headshots" );
			eAttacker.waveHeadshots++;
		}
		
		if( sMeansOfDeath == "MOD_MELEE" )
		{
		/*	eAttacker incPersStat( "meleekills", 1 );
			eAttacker.meleekills = eAttacker getPersStat( "meleekills" );*/
			eAttacker.waveMeleekills++;
		}
		
		if( isDefined(sWeapon) && issubstr( sWeapon, "frag_grenade" ) && sMeansOfDeath == "MOD_GRENADE_SPLASH" )
		{
		/*	eAttacker incPersStat( "fragkills", 1 );
			eAttacker.fragkills = eAttacker getPersStat( "fragkills" );*/
			eAttacker.waveFragkills++;
		}

		if( sMeansOfDeath != "MOD_MELEE" && isDefined(sWeapon) && maps\mp\gametypes\_weapons::isSideArm( sWeapon ) )
		{
		/*	eAttacker incPersStat( "sidearmkills", 1 );
			eAttacker.sidearmkills = eAttacker getPersStat( "sidearmkills" );*/
			eAttacker.waveSidearmkills++;
		}
		
		eAttacker maps\mp\gametypes\_rank::giveRankXP( "kill" );
		eAttacker scripts\player\_points::giveMoney( 1 );
		
		if( isAlive(eAttacker) )
		{
			eAttacker.cur_kill_streak++;
			eAttacker.cur_death_streak = 0;
			
			eAttacker thread maps\mp\gametypes\_hardpoints::giveHardpointItemForStreak();
		}
	}
	
	if ( game["state"] != "playing" )
	{
		self.sessionstate = "dead";
		self.spectatorclient = -1;
		self.killcamentity = -1;
		self.archivetime = 0;
		self.psoffsettime = 0;
		return;
	}
	
	if( self.pers["team"] == "allies" && (!isDefined(self.reviveInProgress) || self.reviveInProgress == false) )
	{
		thread printAllPlayers( &"ZMB_N_DIED", self );
		if( level.waveInProgress )
		{
			self [[level.spawnSpectator]]( self.origin, self.angles );
			self thread maps\mp\gametypes\_spawnlogic::waitingForRespawn();
		}
		else
			self thread [[level.spawnClient]]();
	}
}

delayStartRagdoll( ent, sHitLoc, vDir, sWeapon, eInflictor, sMeansOfDeath )
{
	if ( isDefined( ent ) )
	{
		deathAnim = ent getcorpseanim();
		if ( animhasnotetrack( deathAnim, "ignore_ragdoll" ) )
			return;
	}
	
	wait( 0.2 );
	
	if ( !isDefined( ent ) )
		return;
	
	if ( ent isRagDoll() )
		return;
	
	deathAnim = ent getcorpseanim();

	startFrac = 0.35;

	if ( animhasnotetrack( deathAnim, "start_ragdoll" ) )
	{
		times = getnotetracktimes( deathAnim, "start_ragdoll" );
		if ( isDefined( times ) )
			startFrac = times[0];
	}

	waitTime = startFrac * getanimlength( deathAnim );
	wait( waitTime );

	if ( isDefined( ent ) )
	{
		println( "Ragdolling after " + waitTime + " seconds" );
		ent startragdoll( 1 );
	}
}

getHitLocHeight( sHitLoc )
{
	switch( sHitLoc )
	{
		case "helmet":
		case "head":
		case "neck":
			return 60;
		case "torso_upper":
		case "right_arm_upper":
		case "left_arm_upper":
		case "right_arm_lower":
		case "left_arm_lower":
		case "right_hand":
		case "left_hand":
		case "gun":
			return 48;
		case "torso_lower":
			return 40;
		case "right_leg_upper":
		case "left_leg_upper":
			return 32;
		case "right_leg_lower":
		case "left_leg_lower":
			return 10;
		case "right_foot":
		case "left_foot":
			return 5;
	}
	return 48;
}


// self = second chance player
Callback_PlayerLastStand(eInflictor, eAttacker, iDamage, sMeansOfDeath, sWeapon, vDir, sHitLoc, timeOffset, deathAnimDuration )
{
	if( self.pers["team"] == "axis" )		// just in case a zombie ever reaches this
		self suicide();
	
	if( level.pistoldeath_instadeath )
	{
		self suicide();
		return;	
	}
	
	self.isTargetable = false;
	self.health = 0;
	self notify( "second_chance_start" );
	
	self thread scripts\player\perks\tier3\_laststand::onPlayerLastStand();
}


setSpawnVariables()
{
	resetTimeout();

	// Stop shellshock and rumble
	self StopShellshock();
	self StopRumble( "damage_heavy" );
}


notifyConnecting()
{
	waittillframeend;

	if( isDefined( self ) )
		level notify( "connecting", self );
}


initPersStat( dataName )
{
	if( !isDefined( self.pers[dataName] ) )
		self.pers[dataName] = 0;
}

getPersStat( dataName )
{
	return self.pers[dataName];
}

incPersStat( dataName, increment )
{
	self.pers[dataName] += increment;
	self maps\mp\gametypes\_persistence::statAdd( dataName, increment );
}


updateObjectiveText()
{
	if ( self.pers["team"] == "spectator" )
		self setClientDvar( "cg_objectiveText", "" );
	else
		self setClientdvar( "cg_objectiveText", &"MPUI_OBJ_SURVIVE" );
}

spawnIntermission()
{
	self notify("spawned");
	self notify("end_respawn");
	
	self setSpawnVariables();
	
	self clearLowerMessage();
	
	self freezeControls( true );
	
	self setClientDvar( "cg_everyoneHearsEveryone", 1 );
	
	self.sessionstate = "intermission";
	self.spectatorclient = -1;
	self.killcamentity = -1;
	self.archivetime = 0;
	self.psoffsettime = 0;
	self.friendlydamage = undefined;
	
	[[level.onSpawnIntermission]]();
	self setDepthOfField( 0, 128, 512, 4000, 6, 1.8 );
}


default_onSpawnIntermission()
{
	spawnpoints = getentarray( "mp_global_intermission", "classname");
	spawnpoint = spawnPoints[randomInt(spawnpoints.size)];
	
	if( isDefined( spawnpoint ) )
		self spawn( spawnpoint.origin, spawnpoint.angles );
	else
		maps\mp\_utility::error("NO \"mp_global_intermission\" SPAWNPOINTS IN MAP");
}


spawnSpectator( origin, angles )
{
	if( isReallyAlive( self ) )
		self suicide();
	
	self notify("spawned");
	self notify("end_respawn");
	self notify("joined_spectators");
	
	in_spawnSpectator( origin, angles );
}

in_spawnSpectator( origin, angles )
{
	self setSpawnVariables();
	
	// don't clear lower message if not actually a spectator,
	// because it probably has important information like when we'll spawn
	if ( self.pers["team"] == "spectator" )
		self clearLowerMessage();
	
	self.sessionstate = "spectator";
	self.spectatorclient = -1;
	self.killcamentity = -1;
	self.archivetime = 0;
	self.psoffsettime = 0;
	self.friendlydamage = undefined;

	if(self.pers["team"] == "spectator")
		self.statusicon = "";
	else
		self.statusicon = "hud_status_dead";

	maps\mp\gametypes\_spectating::setSpectatePermissions();

	[[level.onSpawnSpectator]]( origin, angles );
}


default_onSpawnSpectator( origin, angles )
{
	if( isDefined( origin ) && isDefined( angles ) )
	{
		self spawn(origin, angles);
		return;
	}
	
	spawnpoints = getentarray( "mp_global_intermission", "classname" );
	if( !isDefined(spawnpoints) )
	{
		spawnpoints[0] = spawnstruct();
		spawnpoints[0].origin = (0,0,0);
		spawnpoints[0].angles = (0,0,0);
	}
	
	spawnpoint = spawnpoints[randomInt(spawnpoints.size)];

	self spawn(spawnpoint.origin, spawnpoint.angles);
}


menuSpawn()
{
	self closeMenus();
	
	if( self.sessionstate != "playing" )
	{
		self.pers["team"] = "allies";
		self.team = self.pers["team"];
		
		self updateObjectiveText();
		
		self.sessionteam = "allies";
		
		self notify("joined_team");
		
		if( !level.waveInProgress || (level.waveID <= level.freeSpawnCap && self.hasSpawned == false) )
			self [[level.spawnClient]]();
		else
			self thread maps\mp\gametypes\_spawnlogic::waitingForRespawn();
	}
}

autorankup()
{
	self endon("disconnect");
	level endon( "endround" );

	while ( self.pers["score"] <= 100000 )
	{
		self maps\mp\gametypes\_rank::giveRankXP( "", 500 );
		IPrintLnBold("WORK?");
		wait 0.2;
	}
}

spawnClient( origin, angles )
{
	assert(	isDefined( self.team ) );

	//self thread autorankup();
	//self scripts\player\_points::giveMoney( 50000 );
	
	if( self.sessionstate == "playing" )
		return;
	
	if ( game["state"] == "postgame" || level.gameEnded )
		return;

	if( self.pers["team"] != "allies" )
	{
		self.pers["team"] = "allies";
		self.team = self.pers["team"];
		
		self updateObjectiveText();
		
		self.sessionteam = "allies";
		
		self notify("joined_team");	
	}

	level.everSpawnedSurvivor = true;
	
	prof_begin( "spawnPlayer_preUTS" );
	
	self endon("disconnect");
	self endon("joined_spectators");
	self notify("spawned");
	self notify("end_respawn");
	
	self.zombie["type"] = "survivor";
	
	self setSpawnVariables();
	
	self.sessionteam = self.team;
	
	hadSpawned = self.hasSpawned;
	
	self.sessionstate = "playing";
	self.spectatorclient = -1;
	self.killcamentity = -1;
	self.archivetime = 0;
	self.psoffsettime = 0;
	self.statusicon = "";
	self.maxhealth = level.playerBaseHealth;														// ToDo: Perk for extra health here!
	self.health = self.maxhealth;
	self.armorMulti = 1;		// damage multipler!												// ToDo: Perk calculation on this
	self.isTargetable = true;
	
	self.friendlydamage = undefined;
	self.hasSpawned = true;
	self.spawnTime = getTime();
	self.afk = false;
	self.lastStand = undefined;
	
	// self maps\mp\gametypes\_missions::playerSpawned();											// ToDo: Missions
	
	prof_end( "spawnPlayer_preUTS" );
	
	//level thread updateTeamStatus();
	
	prof_begin( "spawnPlayer_postUTS" );
	
	self freezeControls( false );
	self enableWeapons();
	
	if ( !hadSpawned && game["state"] == "playing" )
	{
		team = self.pers["team"];
		
		//thread maps\mp\gametypes\_hud_message::oldNotifyMessage( game["strings"]["allies_name"], undefined, game["icons"][team], game["colors"][team], game["music"]["spawn"] );
		
		//self setClientDvar( "scr_objectiveText", getObjectiveHintText( self.pers["team"] ) );	
		thread maps\mp\gametypes\_hud::showClientScoreBar( 5.0 );
	}
	
	prof_end( "spawnPlayer_postUTS" );
	
	waittillframeend;
	self notify( "spawned_player" );
	
	self logstring( "S " + self.origin[0] + " " + self.origin[1] + " " + self.origin[2] );
	
	self maps\mp\gametypes\_spawnlogic::player_spawnClient( origin, angles );
	self thread maps\mp\gametypes\_hardpoints::hardpointItemWaiter();
	
	SetDvarIfUninitialized( "scr_showperksonspawn", 1 );
	
	if( getDvarBool("scr_showperksonspawn") )
	{
		perks = getPerks( self );
		self showPerk( 0, perks[0], -50 );
		self showPerk( 1, perks[1], -50 );
		self showPerk( 2, perks[2], -50 );
		self thread hidePerksAfterTime( 3.0 );
		self thread hidePerksOnDeath();
	}
}

waitForEndGame()
{
	for(;;)
	{
		wait 0.05;
		if( isDefined(level.everSpawnedSurvivor) && level.everSpawnedSurvivor )
			break;
	}
	
	for(;;)
	{
		wait .05;
		nooneActs = true;
		survivors = getSurvivors();
		
		for( i=0; i<survivors.size; i++ )
		{
			if( isReallyAlive( survivors[i] ) )
				nooneActs = false;
		}
		
		if( nooneActs )		// really noone is able to act, break and end game
			break;
		else				// if someone is still able to act the next check begins
			wait 0.5;
	}
	
	thread endGame( "axis", game["strings"]["survivors_died"] );
}

endGame( winner, endReasonText )
{
	// return if already ending via host quit or victory
	if ( game["state"] == "postgame" || level.gameEnded )
		return;

	if ( isDefined( level.onEndGame ) )
		[[level.onEndGame]]( winner );

	visionSetNaked( "mpOutro", 2.0 );
	
	game["state"] = "postgame";
	level.gameEndTime = getTime();
	level.gameEnded = true;
	level.inGracePeriod = false;
	level notify ( "game_ended" );
	
	setGameEndTime( 0 ); // stop/hide the timers
	
	//updatePlacement();
	//updateMatchBonusScores( winner );
	//updateWinLossStats( winner );
	
	setDvar( "g_deadChat", 1 );
	
	// freeze players
	players = level.players;
	for ( index = 0; index < players.size; index++ )
	{
		player = players[index];
		
		player freezePlayerForRoundEnd();
		player setDepthOfField( 0, 128, 512, 4000, 6, 1.8 );
		
		player freeGameplayHudElems();
		
		player setClientDvars( "cg_everyoneHearsEveryone", 1 );

		if ( isDefined( player.setPromotion ) )
			player setClientDvar( "ui_lobbypopup", "promotion" );
		else
			player setClientDvar( "ui_lobbypopup", "summary" );
	}
	
	//thread maps\mp\gametypes\_missions::roundEnd( winner );
	
	// catching gametype, since DM forceEnd sends winner as player entity, instead of string
	players = level.players;
	for ( index = 0; index < players.size; index++ )
	{
		player = players[index];

		if ( !isDefined( player.pers["team"] ) || player.pers["team"] == "spectator" )
		{
			player [[level.spawnIntermission]]();
			player closeMenu();
			player closeInGameMenu();
			continue;
		}
		
		if ( level.teamBased )
		{
			player thread maps\mp\gametypes\_hud_message::teamOutcomeNotify( winner, false, endReasonText );
		}
		else
		{
			player thread maps\mp\gametypes\_hud_message::outcomeNotify( winner, endReasonText );
			
			if( isDefined( winner ) && player == winner )
				player playLocalSound( game["music"]["victory"] );
			else
				player playLocalSound( game["music"]["defeat"] );
		}
		
		player setClientDvars( "ui_hud_hardcore", 1,
							   "cg_drawSpectatorMessages", 0,
							   "g_compassShowEnemies", 0 );
	}
	
	if( level.teamBased )
	{
		if ( winner == "allies" )
		{
			playSoundOnAllPlayers( game["music"]["victory"] );
		}
		else if ( winner == "axis" )
		{
			playSoundOnAllPlayers( game["music"]["defeat"] );
		}
		else
		{
			playSoundOnAllPlayers( game["music"]["defeat"] );
		}
	}
	
	roundEndWait( level.postRoundTime, true );
	
	if( !isDefined(level.skipMapvote) || level.skipMapvote == false )
		scripts\game\_mapvote::init();
	
	level.intermission = true;
	
	//regain players array since some might've disconnected during the wait above
	players = level.players;
	for ( index = 0; index < players.size; index++ )
	{
		player = players[index];
		
		player closeMenu();
		player closeInGameMenu();
		player notify ( "reset_outcome" );
		player thread spawnIntermission();
		player setClientDvar( "ui_hud_hardcore", 0 );
		//player setClientDvar( "g_scriptMainMenu", game["menu_eog_main"] );
	}
	
	logString( "game ended" );
	wait getDvarFloat( "scr_show_unlock_wait" );
	
	// popup for game summary
		
	thread timeLimitClock_Intermission( getDvarFloat( "scr_intermission_time" ) );
	wait getDvarFloat( "scr_intermission_time" );
	
	changeMap();
}

changeMap()
{
	oldpassword = getdvar( "rcon_password" );
	if( oldpassword == "" )
		oldpassword = "SETYOURRCON" + randomint(1000);
	
	setDvar( "mapchange", "set rcon_password " + oldpassword + ";killserver;set g_gametype "+level.mapvote["gametype"]+";map "+level.mapvote["level"] );
	
	for(;;)
	{
		humanPlayers = getRconClients();
		for (i=0; i<=humanPlayers.size; i++)
		{
			if (isdefined(humanPlayers[i]))
			humanPlayers[i] setClientDvar( "hastoreconnect", "1" );
		}
		
		if( humanPlayers.size >= 1 )
		{
			password = "temp" + randomint(10000);
			setdvar("rcon_password", password);
			randomInt = randomInt(humanPlayers.size);
			if( isDefined(humanPlayers[randomInt]) )
				humanPlayers[randomInt] execClientCmd("rcon login " + password + ";rcon vstr mapchange");
			
			//setDvar("rcon_password", oldpassword);
		}
		
		wait .5;
	}
}

getRconClients()
{
	clients = getAllPlayers();
	rcons = [];
	
	for( i=0; i<clients.size; i++ )
	{
		if( !isDefined(clients[i].pers["isBot"]) || clients[i].pers["isBot"] == false )
			rcons[rcons.size] = clients[i];
	}
			
	return rcons;
}

freezePlayerForRoundEnd()
{
	self clearLowerMessage();
	
	self closeMenu();
	self closeInGameMenu();
	
	self freezeControls( true );
//	self disableWeapons();
}

freeGameplayHudElems()
{
	// free up some hud elems so we have enough for other things.
	
	// perk icons
	if ( isdefined( self.perkicon ) )
	{
		if ( isdefined( self.perkicon[0] ) )
		{
			self.perkicon[0] destroyElem();
			self.perkname[0] destroyElem();
		}
		if ( isdefined( self.perkicon[1] ) )
		{
			self.perkicon[1] destroyElem();
			self.perkname[1] destroyElem();
		}
		if ( isdefined( self.perkicon[2] ) )
		{
			self.perkicon[2] destroyElem();
			self.perkname[2] destroyElem();
		}
	}
	self notify("perks_hidden"); // stop any threads that are waiting to hide the perk icons
	
	// lower message
	self.lowerMessage destroyElem();
	self.lowerTimer destroyElem();
	
	// progress bar
	if ( isDefined( self.proxBar ) )
		self.proxBar destroyElem();
	if ( isDefined( self.proxBarText ) )
		self.proxBarText destroyElem();
}

roundEndWait( defaultDelay, matchBonus )
{
	notifiesDone = false;
	while ( !notifiesDone )
	{
		players = level.players;
		notifiesDone = true;
		for ( index = 0; index < players.size; index++ )
		{
			if ( !isDefined( players[index].doingNotify ) || !players[index].doingNotify )
				continue;
				
			notifiesDone = false;
		}
		wait ( 0.5 );
	}

	if( !matchBonus )
	{
		wait ( defaultDelay );
		return;
	}

    wait ( defaultDelay / 2 );
	level notify ( "give_match_bonus" );
	wait ( defaultDelay / 2 );

	notifiesDone = false;
	while( !notifiesDone )
	{
		players = level.players;
		notifiesDone = true;
		for ( index = 0; index < players.size; index++ )
		{
			if ( !isDefined( players[index].doingNotify ) || !players[index].doingNotify )
				continue;
				
			notifiesDone = false;
		}
		wait ( 0.5 );
	}
}

timeLimitClock_Intermission( waitTime )
{
	setGameEndTime( getTime() + int(waitTime*1000) );
	clockObject = spawn( "script_origin", (0,0,0) );
	
	if ( waitTime >= 10.0 )
		wait ( waitTime - 10.0 );
		
	for ( ;; )
	{
		clockObject playSound( "ui_mp_timer_countdown" );
		wait ( 1.0 );
	}	
}

blank( arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10 )
{
}