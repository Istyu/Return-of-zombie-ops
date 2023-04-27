/*=======================================================================================
                        __________      __________      
                        \______   \ ____\____    /____  
                         |       _//  _ \ /     //  _ \ 
                         |    |   (  <_> )     /(  <_> )
                         |____|_  /\____/_______ \____/ 
                                \/              \/      

=========================================================================================
return of the zombie ops - mod
developed by mod-team-germany
=========================================================================================
zombiemode map module
=======================================================================================*/
#include scripts\_utility_flags;
#include scripts\_utility;

loadMapspecs()
{
	flag_init( "level_defined" );
	level.type = "zombiemode";
	
	level.classicTeamsAvailable = false;
	level.weaponUpgradeAvailable = false;
	
	level.possibleChests = [];
	level.possibleVendors = [];
	level.possiblePickups = [];
	level.possibleArmorys = [];
	
	level.Barricades = [];
	level.Blocker = [];
	
	thread scripts\level\barricades::init();
	
	println( "Map loaded as a zombiemode map." );
}

/*=================
Example: registerDefaultZombieSpawns( targetname );
Required Values: <targetname> The targetname of the spawns
Possible Values: -
Description: Registers the default zombie spawns, they are active from the start of the map.
=================*/
registerPlayerStart( targetname )
{
	assertEx( isDefined(targetname), "No targetname defined for default player spawns." );
	
	spawns = getEntArray( targetname, "targetname" );
//	assertEx( spawns.size > 0, "No spawnpoints for players found by targetname ", targetname );
	
	if( !isDefined(level.playerspawns) )
		level.playerspawns = [];
		
	for( i=0; i<spawns.size; i++ )
	{
		ID = level.playerspawns.size;
		
		level.playerspawns[ID] = spawns[i];
		level.playerspawns[ID].enabled = true;		// player starts will always be enabled
	}
	
	printLn( "Playerspawn count: "+level.playerspawns.size );
}

/*=================
Example: registerDefaultZombieSpawns( targetname );
Required Values: <targetname>
Possible Values: -
Description: Registers the default zombie spawns, they are active from the start of the map.
=================*/
registerDefaultZombieSpawns( targetname )
{
	assertEx( isDefined(targetname), "No targetname defined for default zombie spawns." );
	
	spawns = getEntArray( targetname, "targetname" );
//	assertEx( spawns.size > 0, "No spawnpoints for zombies found by targetname ", targetname );
	
	if( !isDefined(level.zombiespawns) )
		level.zombiespawns = [];
	
	for( i=0; i<spawns.size; i++ )
	{
		ID = level.zombiespawns.size;
		
		level.zombiespawns[ID] = spawns[i];
		level.zombiespawns[ID].enabled = true;			// is ths spawn active
		level.zombiespawns[ID].priority = 1;			// priority of the spawn, changes with more spawns unlocked, etc.
	}

	printLn( "Zombiespawn count: "+level.zombiespawns.size );
}

/*=================
Example: registerTreasureChests();
Required Values: -
Possible Values: -
Description: Registers the default treasure chests
=================*/
registerTreasureChests()
{
	chests = getEntArray( "zombie_treasure_box", "targetname" );
	
	if( chests.size == 0 )
		return;
	
	for( i=0; i<chests.size; i++ )
	{
		chests[i] registerTreasureChest();
	}
}
registerTreasureChest()
{
	self.trigger = self getClosestEntity( "zombie_treasure_trigger" );
	self.lid = self getClosestEntity( "zombie_treasure_lid" );
	self.clip = self getClosestEntity( "zombie_treasure_clip" );
	
	self hidePart( "tag_lid" );
	self.lid hidePart( "tag_box" );
	
	self.used = false;
	
	level.possibleChests[level.possibleChests.size] = self;
}

/*=================
Example: registerWeaponPickups();
Required Values: -
Possible Values: -
Description: Registers the weapon pickups on the map
=================*/
registerWeaponPickups()
{
	pickups = getEntArray( "weapon_buy", "targetname" );
	
	if( pickups.size == 0 )
		return;
	
	for( i=0; i<pickups.size; i++ )
	{
		pickups[i] registerWeaponPickup();
	}
}
registerWeaponPickup()
{
	self.visual = getEnt( self.target, "targetname" );
	
	level.possiblePickups[level.possiblePickups.size] = self;
}

registerSupportVendors()
{
	ents = getEntArray( "air_support_shop", "targetname" );
	
	if( ents.size == 0 )
		return;
	
	for( i=0; i<ents.size; i++ )
	{
		vendor = ents[i];
		vendor.trigger = vendor getClosestEntity( ents[i].target );		// perk_shop_trig
		vendor.detail = [];
		last = vendor.trigger;
		
		while( isDefined(last.target) )
		{
			dID = vendor.detail.size;
			vendor.detail[dID] = last getClosestEntity( last.target );
			last = vendor.detail[dID];
		}
				
		level.possibleVendors[level.possibleVendors.size] = vendor;
	}
}

/*=================
Example: registerPerkVendors();
Required Values: -
Possible Values: -
Description: Registers the perk vendors / equipment vendors on the map
=================*/
registerPerkVendors()
{
	ents = getEntArray( "perk_vendor", "targetname" );
	
	if( ents.size == 0 )
		return;
	
	for( i=0; i<ents.size; i++ )
	{
		vendor = ents[i];
		registerVendor( vendor );
		level.possibleVendors[level.possibleVendors.size] = vendor;
	}
}

registerEquipmentVendors()
{
	ents = getEntArray( "perk_shop", "targetname" );
	
	if( ents.size == 0 )
		return;
	
	for( i=0; i<ents.size; i++ )
	{
		vendor = ents[i];
		registerVendor( vendor );
		level.possibleVendors[level.possibleVendors.size] = vendor;
	}
}
registerVendor( vendor )
{
	vendor.trigger = vendor getClosestEntity( vendor.target );
	vendor.detail = [];
	last = vendor.trigger;
	
	while( isDefined(last.target) )
	{
		dID = vendor.detail.size;
		vendor.detail[dID] = last getClosestEntity( last.target );
		last = vendor.detail[dID];
	}
}


/*=================
Example: registerWeaponVendors();
Required Values: -
Possible Values: -
Description: Registers the weapon armorys on the map
=================*/
registerWeaponVendors()
{
	ents = getEntArray( "weapon_shop", "targetname" );
	
	if( ents.size == 0 )
		return;
	
	for( i=0; i<ents.size; i++ )
	{
		vendor = ents[i];
		vendor.trigger = vendor getClosestEntity( ents[i].target );		// perk_shop_trig
		vendor.detail = [];
		last = vendor.trigger;
		
		while( isDefined(last.target) )
		{
			dID = vendor.detail.size;
			vendor.detail[dID] = last getClosestEntity( last.target );
			last = vendor.detail[dID];
		}
				
		level.possibleArmorys[level.possibleArmorys.size] = vendor;
	}
}

/*=================
Example: registerWeaponUpgrade();
Required Values: -
Possible Values: -
Description: Registers the pack o punch machine
=================*/
registerWeaponUpgrade()
{
	weapon = getEnt( "weapon_upgrade_weapon", "targetname" );
	trig = getEnt( "weapon_upgrade", "targetname" );
	detail = getEntArray( "weapon_upgrade_detail", "targetname" );
	
	level.possibleUpgrade = weapon;
	level.possibleUpgrade.trigger = trig;
	level.possibleUpgrade.detail = detail;
}

/*=================
Example: defaultExpFog( 500, 600, 0, 0, 0 );
Required Values:<start> the start of the expfog
				<half> the halfway of the expfog
				<r>	red value of the expfog
				<g> green value of the expfog
				<b> blue value of the expfog
Possible Values: -
Description: Registers the ExpFog Values for the default waves
=================*/
defaultExpFog( start, half, r, g, b )
{
	setExpFog( start, half, r, g, b );
	
	level.defaultExpFog = [];
	level.defaultExpFog["start"	] = start;
	level.defaultExpFog["half"	] = half;
	level.defaultExpFog["red"	] = r;
	level.defaultExpFog["green"	] = g;
	level.defaultExpFog["blue"	] = b;
}

/*=================
Example: buildBarricade( "barricade", health, level._effects["barricade_dest"], level._effects["barricade_build"] );
Required Values:<targetname> Targetname of the trigger
				<health> health per piece
				<deathFx> fx played at vanish of one piece
				<buildFx> fx played at restore of one piece
Possible Values: -
Description: Adds barricades to the map
=================*/
registerBarricade( targetname, health, deathFx, buildFx )
{
	if( !isDefined(level.barricades) )
		level.barricades = [];
	
	ents = getEntArray( targetname, "targetname" );
	for( i=0; i<ents.size; i++)
	{
		ent = ents[i];
		
		ent.deathFx = deathFx;
		ent.buildFx = buildFx;
		ent.parthealth = health;
		
		ent.parts = [];
		
		start = ent;
		for( j=0; j<20; j++ )
		{
			if( !isDefined(start.target) )
				break;
				
			part = start getClosestEntity( start.target );
			ent.parts[j] = part;
			
			start = part;
		}
		
		level.barricades[level.barricades.size] = ent;
		ent thread scripts\level\barricades::barricade_create();
	}
}

/*=================
Example: buildBlocker( "zombie_blocker", level._effects["barricade_build"] );
Required Values:<targetname> targetname of the trigger
				<deathFx> fx played at opening
Possible Values: -
Description: Adds blocker to the map
=================*/
buildBlocker( targetname, deathFx )
{
	if( !isDefined(level.blocker) )
		level.blocker = [];
	
	ents = getEntArray( targetname, "targetname" );
	for( i=0; i<ents.size; i++)
	{
		ent = ents[i];
		
		ent.debris = getEntArray( ent.target, "targetname" );
		ent.playerspawns = getEntArray( "player_spawn_"+ent.script_noteworthy, "targetname" );
		ent.zombiespawns = getEntArray( "zombie_spawn"+ent.script_noteworthy, "targetname" );
		
		if( isDefined(ent.script_threshold) )
			ent.cost = ent.script_threshold;
		else
			ent.cost = 1000;
		ent.deathFx = deathFx;
		
		for( j=0; j<ent.playerspawns; j++ )
		{
			ID = level.playerspawns.size;
		
			level.playerspawns[ID] = ent.playerspawns[j];
			level.playerspawns[ID].enabled = false;					// will become active later
		}
		
		for( j=0; j<ent.zombiespawns; j++ )
		{
			ID = level.zombiespawns.size;
		
			level.zombiespawns[ID] = ent.zombiespawns[j];
			level.zombiespawns[ID].enabled = false;					// will become active later
		}
		
		level.blocker[level.blocker.size] = ent;
		ent thread scripts\level\_blocker::blocker_think();
	}
}

/*=================
Example: loadWaypoints( ::waypoint_script )
Required Values: <waypoint_script> function pointer to the waypoints
Description: Loads the waypoints from a gsc file
=================*/
loadWaypoints( waypoint_script )
{
	// original RoZo waypoint scrips return the waypoints as an array
	waypoints = [[waypoint_script]]();
	if( isDefined(waypoints) && waypoints != "" )
	{
		level.waypoints = waypoints;
		level.waypointCount = level.waypoints.size;
	}
	
	for( i=0; i<level.waypointCount; i++ )
	{
		waypoint = level.waypoints[i];
		
		waypoint.ID = i;
		waypoint.isLinking = false;
		
		if( isDefined(waypoint.childCount) && waypoint.childCount > 0 )
		{
			waypoint.linkedCount = waypoint.childCount;
			
			for( y=0; y<waypoint.linkedCount; y++ )
				waypoint.linked[y] = level.waypoints[waypoint.children[y]];
				
			waypoint.childCount = undefined;
			waypoint.children = undefined;
		}
	}
	printLn( "Waypoint Count: "+level.waypointCount );
}
/*=================
Example: loadWaypointsCSV();
Required Values: -
Description: Loads the waypoints from a csv file
=================*/
loadWaypointsCSV()
{
	fileName =  "waypoints/"+ tolower(getdvar("mapname")) + "_wp.csv";
	
	printLn( "Getting waypoints from csv: "+fileName );

	level.waypointCount = int( tableLookup(fileName, 0, 0, 1) );
	for (i=0; i<level.waypointCount; i++)
	{
		waypoint = spawnstruct();
		origin = TableLookup(fileName, 0, i+1, 1);
		orgToks = strtok( origin, " " );
		
		waypoint.origin = ( float(orgToks[0]), float(orgToks[1]), float(orgToks[2]));
		waypoint.isLinking = false;
		waypoint.ID = i;
		
		level.waypoints[i] = waypoint;
	}
	for (x=0; x<level.waypointCount; x++)
	{
		waypoint = level.waypoints[x]; 
		
		strLnk = TableLookup(fileName, 0, x+1, 2);
		tokens = strtok(strLnk, " ");
		
		waypoint.linkedCount = tokens.size;
		
		for (y=0; y<tokens.size; y++)
			waypoint.linked[y] = level.waypoints[ int(tokens[y]) ];
	}
	
	printLn( "Waypoint Count: "+level.waypointCount );
}

/*=================
Mapper functions, in this version of RoZo these are only for debugging
=================*/
initPowerSwitch( targetname )
{
	if( isDefined(getEnt( targetname, "targetname" )) )
		logPrint( "Powerswitch initialized with targetname '", targetname, "'.\n" );
	else
		logPrint( "No powerswitch found with targetname '", targetname, "'.\n" );
}

registerBlocker( type, targetname, deathFx )
{
	if( !isDefined(level.blocker) )
		level.blocker = [];
	
	if( !isDefined(type) )
		type = "vanish";
	
	ents = getEntArray( targetname, "targetname" );
	for( i=0; i<ents.size; i++)
	{
		ent = ents[i];
		
		ent.type = type;
		ent.debris = getEntArray( ent.target, "targetname" );
		ent.playerspawns = [];
		ent.zombiespawns = [];
		ent.cost = 0;
		
		if( isDefined(ent.script_noteworthy) )
		{
			ent.playerspawns = getEntArray( "player_spawn_"+ent.script_noteworthy, "targetname" );
			ent.zombiespawns = getEntArray( "zombie_spawn_"+ent.script_noteworthy, "targetname" );
		}
		
		if( isDefined(ent.script_threshold) )
			ent.cost = ent.script_threshold;
		else
			ent.cost = 1000;
		
		if( type == "vanish" && isDefined(deathFx) )
			ent.deathFx = deathFx;
		
		for( j=0; j<ent.playerspawns.size; j++ )
		{
			ID = level.playerspawns.size;
		
			level.playerspawns[ID] = ent.playerspawns[j];
			level.playerspawns[ID].active = false;					// will become active later
		}
		
		for( j=0; j<ent.zombiespawns.size; j++ )
		{
			ID = level.zombiespawns.size;
		
			level.zombiespawns[ID] = ent.zombiespawns[j];
			level.zombiespawns[ID].active = false;					// will become active later
		}
		
		level.blocker[level.blocker.size] = ent;
	}
	
	
}

getClosestEntity( value, key )
{
	if( !isDefined(key) )
		key = "targetname";
	
	ents = getentarray( value, key );
	
	nearestEnt = undefined;
	nearestDistance = 9999999999;
	
	for( i=0; i<ents.size; i++ )
	{
		ent = ents[i];
		distance = Distance(self.origin, ent.origin);
		
		if(distance < nearestDistance)
		{
			nearestDistance = distance;
			nearestEnt = ent;
		}
	}

	return nearestEnt;
}