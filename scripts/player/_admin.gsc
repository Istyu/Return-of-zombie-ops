/*=======================================================================================
return of the zombie ops - mod
Modded by Lefti & 3aGl3
=========================================================================================
Admin and developer tweaks
=======================================================================================*/
#include scripts\_utility;

init()
{
// DEVELOPER
	// developer GUID
	level.developerGUID["lefti"] = "794e540544c062106fba4d6f789e28b3";
	level.developerGUID["eagle"] = "a6d4b57ede324128591cd13ce179af2c";
	level.adminGUID = [];
	level.adminModel = [];
	level.vipGUID = [];
	
// ADMIN
	// admin GUIDs
	for( i=0; i<=20; i++ )
	{
		if( getDvar( "scr_admin_guid_"+(i+1) ) != "" )
			level.adminGUID[i] = getDvar( "scr_admin_guid_"+(i+1) );
		else
			break;
	}
	// admin models
	for( i=0; i<level.adminGUID.size ;i++ )
	{
		if( getDvar( "scr_admin_model_"+(i+1) ) != "" )
			level.adminModel[i] = getDvarInt( "scr_admin_model_"+(i+1) );
		else
			level.adminModel[i] = 0;
	}
	
// VIP/MEMBER
	// vip GUIDs
	for( i=0; i<50 ;i++ )
	{
		if( getDvar( "scr_vip_guid_"+i ) != "" )
			level.vipGUID[i] = getDvar( "scr_vip_guid_"+i );
		else
			break;
	}
	
	level.aap["mapname"] = getDvar( "mapname" );
	level.aap["gametype"] = getDvar( "g_gametype" );
	
	thread onPlayerConnect();
}

onPlayerConnect()
{
	for(;;)
	{
		level waittill( "connected", player );
		
		if( !isDefined(level.aap["player"]) )
			level.aap["player"] = getAllPlayers()[0];
		
		if( player clientIsAdmin() )
		{
			player thread updateAAPDvars();	
			player setClientDvar( "ui_isAdmin", 1 );
		}
		else if( player clientIsVIP() )
		{
			player thread updateAAPDvars();	
			player setClientDvar( "ui_isVIP", 1 );
		}
	}
}

responseHandler( response )
{
	self endon( "disconnect" );
	
	if( self clientIsAdmin() == false )
		return;
	
	switch( response )
	{
		case "adminKillAllBots":
			self thread adminKillBots();
			break;
		case "adminMapRotate":
			thread maps\mp\gametypes\_globallogic::endGame( "allies", self.name+" ended the map" );
			break;
		case "adminMapRestart":
			self thread startMap( level.script, level.gametype );
			break;
		case "adminPrevMap":
			cycleMap( "prev" );
			break;
		case "adminNextMap":
			cycleMap( "next" );
			break;
		case "adminPrevGame":
			cycleGametype( "prev" );
			break;
		case "adminNextGame":
			cycleGametype( "next" );
			break;
		case "adminGametypeStart":
			self thread startMap( level.aap["mapname"], level.aap["gametype"] );
			break;
		case "adminGametypeNext":
			self thread setMap( level.aap["mapname"], level.aap["gametype"] );
			break;
		case "adminPrevPlayer":
			cyclePlayer( "prev" );
			break;
		case "adminNextPlayer":
			cyclePlayer( "next" );
			break;
		case "adminSlapPlayer":
			self slapPlayer();
			break;
		case "adminKillPlayer":
			self killPlayer();
			break;
		case "adminPlayerTakeWeapon":
			self takeWeapons();
			break;
		case "adminKickPlayer":
			self kickPlayer();
			break;
		case "adminBanPlayer":
			self banPlayer();
			break;
		case "adminPlayerSpec":
			self moveToSpectator();
			break;
		case "adminPlayerRerank":
			self regainRank();
			break;
		case "adminTeleToPlayer":
			self thread teleToPlayer();
			break;
		case "adminTelePlayer":
			self teleportOrigin( self.origin+(50,0,10) );
			break;
		case "adminPlayerTelePS":
			spawnpoint = maps\mp\gametypes\_spawnlogic::getBestPlayerSpawn();
			self teleportOrigin( spawnpoint.origin, spawnpoint.angles );
			break;
		case "adminPlayerTeleZS":
			if( isDefined(level.maptype) && level.maptype == "rozo_survival" )
				spawnpoint = level.aap["player"] getClosestSpawn(level.playerspawns);
			else
				spawnpoint = level.aap["player"] getClosestSpawn(level.zombiespawns);

			self teleportOrigin( spawnpoint.origin, spawnpoint.angles );
			break;
	}
}

getClosestSpawn( spawnpoints )
{
	nearestEnt = undefined;
	nearestDistance = 9999999999;
	
	for( i=0; i<spawnpoints.size; i++ )
	{
		ent = spawnpoints[i];
		distance = Distance(self.origin, ent.origin);
		
		if(distance < nearestDistance)
		{
			nearestDistance = distance;
			nearestEnt = ent;
		}
	}

	return nearestEnt;
}

responseHandlerVIP( response )
{
	self endon( "disconnect" );
	
	if( self clientIsVIP() == false )
		return;
	
	switch( response )
	{
		case "adminPrevPlayer":
			cyclePlayer( "prev" );
			break;
		case "adminNextPlayer":
			cyclePlayer( "next" );
			break;
		case "adminSlapPlayer":
			self slapPlayer();
			break;
		case "adminKillPlayer":
			self killPlayer();
			break;
		case "adminKickPlayer":
			self kickPlayer();
			break;
		case "adminPlayerSpec":
			self moveToSpectator();
			break;
	}
}

// Server actions

adminKillBots()
{
	zombies = getZombies();
	for( i=0; i<zombies.size; i++ )
		zombies[i] suicide();
	
	printAllPlayers( self.name, " killed all remaining zombies." );
}

startMap( mapname, gametype )
{
	level.skipMapvote = true;
	
	level.mapvote["level"] = mapname;
	level.mapvote["gametype"] = gametype;
	
	thread maps\mp\gametypes\_globallogic::endGame( "allies", self.name+" ended the map" );
}

setMap( mapname, gametype )
{
	level.skipMapvote = true;
	
	level.mapvote["level"] = mapname;
	level.mapvote["gametype"] = gametype;
}

cycleMap( dir )
{
	maps = strTok( getDvar( "scr_mapvote_"+level.aap["gametype"]+"_maps" ), " " );		// "mp_bloc mp_bog mp_crossfire ..."
	
	new = 0;
	for( i=0; i<maps.size; i++ )
	{
		if( maps[i] == level.aap["mapname"] )
		{
			if( dir == "next" )
				new = i+1;
			else
				new = i-1;
				
			if( new >= maps.size )
				new = 0;
			else if( new < 0 )
				new = maps.size-1;
				
			break;
		}
	}
	
	level.aap["mapname"] = maps[new];
	
	players = getSurvivors();
	for( i=0; i<players.size; i++ )
		if( players[i] clientIsVIP() )
			players[i] thread updateAAPDvars();
}

cycleGametype( dir )
{
	gametypes = strTok( getDvar( "scr_mapvote_gametypes" ), " " );		// "war arena"
	
	new = 0;
	for( i=0; i<gametypes.size; i++ )
	{
		if( gametypes[i] == level.aap["gametype"] )
		{
			if( dir == "next" )
				new = i+1;
			else
				new = i-1;
				
			if( new >= gametypes.size )
				new = 0;
			else if( new < 0 )
				new = gametypes.size-1;
				
			break;
		}
	}
	
	level.aap["gametype"] = gametypes[new];
	
	players = getSurvivors();
	for( i=0; i<players.size; i++ )
		if( players[i] clientIsVIP() )
			players[i] thread updateAAPDvars();
}


// player functions

cyclePlayer( dir )
{
	players = getSurvivors();
	
	new = 0;
	for( i=0; i<players.size; i++ )
	{
		if( players[i] == level.aap["player"] )
		{
			if( dir == "next" )
				new = i+1;
			else
				new = i-1;
				
			if( new >= players.size )
				new = 0;
			else if( new < 0 )
				new = players.size-1;
				
			break;
		}
	}
	
	level.aap["player"] = players[new];
	
	for( i=0; i<players.size; i++ )
		if( players[i] clientIsVIP() )
			players[i] thread updateAAPDvars();
}

slapPlayer()
{
	level.aap["player"] finishPlayerDamage( self, self, 10, 1, "MOD_MELEE", "admin_slap", level.aap["player"].origin, level.aap["player"].angles, "j_head", 0 );
	level.aap["player"] ShellShock( "frag_grenade_mp", 0.1 );
	level.aap["player"] iPrintLnBold( self.name, " slapped you!" );
}

killPlayer()
{
	level.aap["player"] suicide();
	level.aap["player"] iPrintLnBold( self.name, " killed you as a punishment!" );
	thread printAllPlayers( "&&1 killed &&2 as a punishment!", self, level.aap["player"] );
}

takeWeapons()
{
	level.aap["player"] takeAllWeapons();
	level.aap["player"] clearPerks();
	level.aap["player"] iPrintLn( self.name, " took all your weapons as a punishment!" );
}

kickPlayer()
{
	player = level.aap["player"];
	cyclePlayer( "next" );
	
	thread printAllPlayers( "&&1 kicked &&2!", self, player );
	kick( player getEntityNumber() );
}

banPlayer()
{
	player = level.aap["player"];
	cyclePlayer( "next" );
	
	thread printAllPlayers( "&&1 banned &&2!", self, player );
	ban( player getEntityNumber() );
}

moveToSpectator()
{
	level.aap["player"] suicide();
	level.aap["player"] [[level.spawnSpectator]]( level.aap["player"].origin, level.aap["player"].angles );
	level.aap["player"] iPrintLnBold( "You've been moved to spectator by ", self.name );
}

regainRank()
{
	player = level.aap["player"];
	if( isDefined(player) )
	{
		newRank = player.pers["rank"];
		player.pers["rank"] = 0;
		player.pers["rankxp"] = 0;

		lastXp = 0;
		for( index = 0; index <= newRank; index++ )		
		{
			newXp = maps\mp\gametypes\_rank::getRankInfoMinXP( index );
			player thread maps\mp\gametypes\_rank::giveRankXP( "kill", newXp - lastXp );
			lastXp = newXp;
			wait ( 0.25 );
			player notify ( "cancel_notify" );
		}
	}
}

teleToPlayer()
{
	self setOrigin( level.aap["player"].origin+(-50,0,10) );
	self iPrintLnBold( "You teleported to ", level.aap["player"].name, "." );
}

teleportOrigin( origin, angles )
{
	player = level.aap["player"];
	player setOrigin( origin );
	if( isDefined(angles) )
		player setPlayerAngles( angles );
		
	if( isDefined(player.revivetrigger) )
		player.revivetrigger.origin = player.origin;
	
	if( isDefined(player.hud["reviveNote"]) )
	{
		player.hud["reviveNote"].x = player.origin[0];
		player.hud["reviveNote"].y = player.origin[1];
		player.hud["reviveNote"].z = player.origin[2]+35;
	}
	
	level.aap["player"] iPrintLnBold( self.name, " teleported you." );
}


// Misc functions

updateAAPDvars()
{
	self setClientDvars(	"ui_aap_mapname", level.aap["mapname"],
							"ui_aap_gametype", level.aap["gametype"],
							"ui_aap_playername", level.aap["player"].name );
}


// Check functions for script

clientIsDeveloper()
{
	if( self getGuid() == level.developerGUID["lefti"] )
		return true;
	else if( self getGuid() == level.developerGUID["eagle"] )
		return true;
	else
		return false;
}

clientIsAdmin()
{
	guid = self getGuid();
	for( i=0; i<level.adminGUID.size; i++ )
	{
		if( guid == level.adminGUID[i] )
			return true;
	}
	
	return false;
}

clientAdmin()
{
	guid = self getGuid();
	for( i=0; i<level.adminGUID.size; i++ )
	{
		if( guid == level.adminGUID[i] )
			return i;
	}
	
	return 0;
}

clientIsVIP()
{
	if( self clientIsAdmin() )
		return true;

	guid = self getGuid();
	for( i=0; i<level.vipGUID.size; i++ )
	{
		if( guid == level.vipGUID[i] )
			return true;
	}
	
	return false;
}