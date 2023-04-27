/*=======================================================================================
return of the zombie ops - Mod
Modded by Lefti & 3aGl3
=========================================================================================
Zombie Spawnlogic by 3aGl3
=======================================================================================*/
#include scripts\_utility;

init()
{
	if( getDvarInt( "developer" ) >= 1 )
	{
		SetDvarIfUninitialized( "dev_draw_spawnpoints", 0 );
		if( getDvarInt("dev_draw_spawnpoints") == 1)
			thread showSpawnpoints();
	}
	
	thread killtrigger();
}

killtrigger()
{
	for(;;)
	{
		wait 1;
		
		if( isDefined(level.killtriggerZ) && level.killtriggerZ != 9999999 )
			break;
	}
	
	wait 10;
	
	level.killtriggerZ -= 256;
	
	center = (0,0,level.killtriggerZ);
	minimapOrigins = getEntArray( "minimap_corner", "targetname" );
	
	if( miniMapOrigins.size )
	{
		center = (miniMapOrigins[0].origin + miniMapOrigins[1].origin);
		center = (center[0], center[1], level.killtriggerZ);
	}
	
	killtrigger = spawn( "trigger_radius", center, 0, 10240, 128 );
	
	for(;;)
	{
		killtrigger waittill( "trigger", user );
		
		if( isPlayer(user) && isReallyAlive(user) )
		{
			user takeAllWeapons();
			user clearPerks();
			
			user suicide();
		}
	}
}


// Player Spawning

addPlayerSpawns( classname, enabled )
{
	if( !isDefined(level.playerspawns) )
		level.playerspawns = [];
	
	if( !isDefined(level.killtriggerZ) )
		level.killtriggerZ = 9999999;
	
	ents = getEntArray( classname, "classname" );
	
	if( ents.size < 1 )
		printLn( "No spawnpoints for players of classname '"+classname+"' found!" );
	else
	{
		for( i=0; i<ents.size; i++ )
		{
			spawn = ents[i];
			spawn.enabled = enabled;
			
			if( spawn.origin[2] < level.killtriggerZ )
				level.killtriggerZ = spawn.origin[2];
			
			level.playerspawns[level.playerspawns.size] = spawn;
		}
	}
}

waitingForRespawn()
{
	self notify( "end_respawn" );
	
	self endon( "disconnect" );
	self endon( "end_respawn" );
	
	self setLowerMessage( game["strings"]["spawn_next_round"] );
	
	for(;;)
	{
		if( level.waveInProgress == false )
			break;
		
		wait 0.5;
	}

	self clearLowerMessage( 0.05 );
	wait 0.05;
	
	self thread [[level.spawnClient]]();
}

player_spawnClient( origin, angles )
{
	spawnpoint = getBestPlayerSpawn();
	
	if( isDefined(origin) && isDefined(angles) )
		self spawn( origin, angles );
	else
		self spawn( spawnpoint.origin, spawnpoint.angles );
	self thread maps\mp\gametypes\_class::giveLoadout();
}

getBestPlayerSpawn()
{
	assertEx( level.playerspawns.size, "No player spawnpoints defined." );
	
	spawnpoints = [];
	for( i=0; i<level.playerspawns.size; i++ )
	{
		if( level.playerspawns[i].enabled )
			spawnpoints[spawnpoints.size] = level.playerspawns[i];
	}
	
	return spawnpoints[randomInt(spawnpoints.size)];
}

// Bot Spawning

addZombieSpawns( classname, enabled, targetname )
{
	if( !isDefined(level.zombiespawns) )
		level.zombiespawns = [];
	
	if( !isDefined(level.killtriggerZ) )
		level.killtriggerZ = 9999999;
	
	ents = [];
	ents2 = [];
		
	if( isDefined(classname) )
		ents = getEntArray( classname, "classname" );
		
	if( isDefined(targetname) )
		ents2 = getEntArray( targetname, "targetname" );

	ents = arrayMerge( ents, ents2 );

	if( ents.size < 1 )
		printLn( "No spawnpoints for zombies of classname '", classname, "' or targetname '", targetname, "' found!" );
	else
	{
		for( i=0; i<ents.size; i++ )
		{
			spawn = ents[i];
			spawn.enabled = enabled;
			if( spawn.origin[2] < level.killtriggerZ )
				level.killtriggerZ = spawn.origin[2];
			
			level.zombiespawns[level.zombiespawns.size] = spawn;
		}
	}
}

getBestZombieSpawn()
{
	assertEx( level.zombiespawns.size, "No zombies spawns defined! Map can not run with RoZo, try to moddify the gsc files." );
	
	spawnpoints = level.zombiespawns;
	possible_spawnpoints = [];
	survivors = getSurvivors();
	
	for( i=0; i<spawnpoints.size; i++ )
	{
		spawnpoint = spawnpoints[i];
		valid = true;
		
		// check the distance to survivors
		for( j=0; j<survivors.size; j++ )
		{
			if( distance( spawnpoint.origin, survivors[j].origin ) <= 1000 )
				valid = false;
		}
		
		if( valid )
			possible_spawnpoints[possible_spawnpoints.size] = spawnpoint;
	}
	
	if( !isDefined(possible_spawnpoints) || possible_spawnpoints.size == 0 )
		possible_spawnpoints = spawnpoints;
	
	for(;;)
	{
		spawnpoint = possible_spawnpoints[randomInt(possible_spawnpoints.size)];
		
		if( !isDefined(spawnpoint.usage) )
			break;
			
		if( spawnpoint.usage <= getTime()-500 )		// make sure this spawn isn't recently used
			break;
	}
	
	spawnpoint.usage = getTime();

	return spawnpoint;
}

// Debuggin

showSpawnpoints()
{
	for(;;)
	{
		wait .5;
		
		if( isDefined(level.zombiespawns) && isDefined(level.playerspawns) )
			break;
	}
	
	for( i=0; i < level.zombiespawns.size; i++ )
	{
		thread drawBox( level.zombiespawns[i].origin, (1,0,0) );
	}
	
	for( i=0; i < level.playerspawns.size; i++ )
	{
		thread drawBox( level.playerspawns[i].origin, (0,1,0) );
	}
}

drawBox( origin, color )
{
	if( !isDefined(color) )
		color = (1,1,1);
	
	for(;;)
	{
		wait(0.05);
		// bottom
		line( origin+(8,8,0), origin+(8,-8,0), color );
		line( origin+(8,8,0), origin+(-8,8,0), color );
		line( origin+(-8,-8,0), origin+(-8,8,0), color );
		line( origin+(-8,-8,0), origin+(8,-8,0), color );
		
		//top
		line( origin+(8,8,72), origin+(8,-8,72), color );
		line( origin+(8,8,72), origin+(-8,8,72), color );
		line( origin+(-8,-8,72), origin+(-8,8,72), color );
		line( origin+(-8,-8,72), origin+(8,-8,72), color );
		
		//vertical
		line( origin+(8,8,0), origin+(8,8,72), color );
		line( origin+(8,-8,0), origin+(8,-8,72), color );
		line( origin+(-8,8,0), origin+(-8,8,72), color );
		line( origin+(-8,-8,0), origin+(-8,-8,72), color );
	}
}
