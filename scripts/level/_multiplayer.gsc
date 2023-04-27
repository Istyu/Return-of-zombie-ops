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
Multiplayer map module
=======================================================================================*/
#include scripts\_utility_flags;
#include scripts\_utility;

loadMapspecs()
{
	flag_init( "level_defined" );
	
	scripts\level\_levelsetup::init();
	scripts\level\_waypoints::init();
	
	level.type = "multiplayer";
	
	println( "Map loaded as a multiplayer map." );
}

/*=================
Example: loadClassicTeams()
Description: Loads the classic teams as playerskins
=================*/
loadClassicTeams()
{
	switch( game["allies_soldiertype"] )
	{
		case "desert":
			mptype\mptype_ally_cqb::precache();
			mptype\mptype_ally_sniper::precache();
			mptype\mptype_ally_engineer::precache();
			mptype\mptype_ally_rifleman::precache();
			mptype\mptype_ally_support::precache();
	
			game["allies_model"]["SNIPER"] = mptype\mptype_ally_sniper::main;
			game["allies_model"]["SUPPORT"] = mptype\mptype_ally_support::main;
			game["allies_model"]["ASSAULT"] = mptype\mptype_ally_rifleman::main;
			game["allies_model"]["RECON"] = mptype\mptype_ally_engineer::main;
			game["allies_model"]["SPECOPS"] = mptype\mptype_ally_cqb::main;
			break;
		case "urban":
			mptype\mptype_ally_urban_sniper::precache();
			mptype\mptype_ally_urban_support::precache();
			mptype\mptype_ally_urban_assault::precache();
			mptype\mptype_ally_urban_recon::precache();
			mptype\mptype_ally_urban_specops::precache();
	
			game["allies_model"]["SNIPER"] = mptype\mptype_ally_urban_sniper::main;
			game["allies_model"]["SUPPORT"] = mptype\mptype_ally_urban_support::main;
			game["allies_model"]["ASSAULT"] = mptype\mptype_ally_urban_assault::main;
			game["allies_model"]["RECON"] = mptype\mptype_ally_urban_recon::main;
			game["allies_model"]["SPECOPS"] = mptype\mptype_ally_urban_specops::main;
			break;
		default:
			mptype\mptype_ally_woodland_assault::precache();
			mptype\mptype_ally_woodland_recon::precache();
			mptype\mptype_ally_woodland_sniper::precache();
			mptype\mptype_ally_woodland_specops::precache();
			mptype\mptype_ally_woodland_support::precache();
	
			game["allies_model"]["SNIPER"] = mptype\mptype_ally_woodland_sniper::main;
			game["allies_model"]["SUPPORT"] = mptype\mptype_ally_woodland_support::main;
			game["allies_model"]["ASSAULT"] = mptype\mptype_ally_woodland_assault::main;
			game["allies_model"]["RECON"] = mptype\mptype_ally_woodland_recon::main;
			game["allies_model"]["SPECOPS"] = mptype\mptype_ally_woodland_specops::main;
			break;
	}
	
	switch( game["axis_soldiertype"] )
	{
		case "desert":
			mptype\mptype_axis_cqb::precache();
			mptype\mptype_axis_sniper::precache();
			mptype\mptype_axis_engineer::precache();
			mptype\mptype_axis_rifleman::precache();
			mptype\mptype_axis_support::precache();
	
			game["axis_model"]["SNIPER"] = mptype\mptype_axis_sniper::main;
			game["axis_model"]["SUPPORT"] = mptype\mptype_axis_support::main;
			game["axis_model"]["ASSAULT"] = mptype\mptype_axis_rifleman::main;
			game["axis_model"]["RECON"] = mptype\mptype_axis_engineer::main;
			game["axis_model"]["SPECOPS"] = mptype\mptype_axis_cqb::main;
			break;
		case "urban":
			mptype\mptype_axis_urban_sniper::precache();
			mptype\mptype_axis_urban_support::precache();
			mptype\mptype_axis_urban_assault::precache();
			mptype\mptype_axis_urban_engineer::precache();
			mptype\mptype_axis_urban_cqb::precache();
	
			game["axis_model"]["SNIPER"] = mptype\mptype_axis_urban_sniper::main;
			game["axis_model"]["SUPPORT"] = mptype\mptype_axis_urban_support::main;
			game["axis_model"]["ASSAULT"] = mptype\mptype_axis_urban_assault::main;
			game["axis_model"]["RECON"] = mptype\mptype_axis_urban_engineer::main;
			game["axis_model"]["SPECOPS"] = mptype\mptype_axis_urban_cqb::main;
			break;
		default:
			mptype\mptype_axis_woodland_rifleman::precache();
			mptype\mptype_axis_woodland_cqb::precache();
			mptype\mptype_axis_woodland_sniper::precache();
			mptype\mptype_axis_woodland_engineer::precache();
			mptype\mptype_axis_woodland_support::precache();
	
			game["axis_model"]["SNIPER"] = mptype\mptype_axis_woodland_sniper::main;
			game["axis_model"]["SUPPORT"] = mptype\mptype_axis_woodland_support::main;
			game["axis_model"]["ASSAULT"] = mptype\mptype_axis_woodland_rifleman::main;
			game["axis_model"]["RECON"] = mptype\mptype_axis_woodland_engineer::main;
			game["axis_model"]["SPECOPS"] = mptype\mptype_axis_woodland_cqb::main;
			break;
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
Example: convertGametypes()
Description: Converts the gametype objectives and deletes not required things
=================*/
convertGametypes()
{
	delArray = [];
	
	has_sd = false;
	has_sab = false;
	has_koth = false;
	
	// Delete all unneeded stuff
	entitytypes = getentarray();
	for( i=0; i<entitytypes.size; i++ )
	{
		if( isdefined(entitytypes[i].script_gameobjectname) )
		{
			dodelete = true;
			// allow a space-separated list of gameobjectnames
			gameobjectnames = strtok(entitytypes[i].script_gameobjectname, " ");
			for( k=0; k<gameobjectnames.size; k++ )
			{
				if( gameobjectnames[k] == "sab" )
				{
					// sab targets are used as treasure boxes
					dodelete = false;
					has_sab = true;
					break;
				}
				else if( gameobjectnames[k] == "bombzone" )
				{
					// SD targets are used as treasure boxes
					dodelete = false;
					has_sd = true;
					break;
				}
				else if( gameobjectnames[k] == "hq" )
				{
					// HQ Targets are used as vendors mainly
					dodelete = false;
					has_koth = true;
					break;
				}
			}

			if(dodelete)
				delArray[delArray.size] = entitytypes[i];
		}
	}
	
	deleteAll( delArray );
	
	if( has_sab )
	{
		structs = [];
		
		// clean up the unused things
		delArray = getEntArray( "sab_bomb_pickup_trig", "targetname" );
		delArray = arrayMerge( delArray, getEntArray( "sab_bomb", "targetname" ) );
		delArray = arrayMerge( delArray, getEntArray( "sab_bomb_defuse_allies", "targetname" ) );
		delArray = arrayMerge( delArray, getEntArray( "sab_bomb_defuse_axis", "targetname" ) );
		deleteAll( delArray );
		
		allObjects = getGameobjects( "sab" );
		for( i=0; i<allObjects.size; i++ )
			printLn( "SAB Object ", allObjects[i].origin, ";", allObjects[i].classname, ";", allObjects[i].targetname );
		
		for( i=0; i<allObjects.size; i++ )
		{
			if( !isDefined(allObjects[i]) )
				continue;
			
			if( allObjects[i].classname == "script_model" && !isDefined(allObjects[i].used) )
			{
				allObjects[i].used = false;
				structs[structs.size] = allObjects[i];
			}
		}

		for( i=0; i<structs.size; i++ )
		{
			structs[i].detail = [];
			for( j=0; j<allObjects.size; j++ )
			{
				if( distance(allObjects[j].origin, structs[i].origin) < 50 )
				{
					if( allObjects[j].classname == "script_brushmodel" )
					{
						ID = structs[i].detail.size;
						structs[i].detail[ID] = allObjects[j];
						structs[i].detail[ID] linkTo( structs[i] );
					}
					else if( allObjects[j].classname == "trigger_use_touch" )
					{
						structs[i].trigger = allObjects[j];
						structs[i].trigger.offset = structs[i].origin - allObjects[j].origin;
					}
				}
			}
		}
		
		printLn( "^0Struct 0 origin: ", structs[0].origin );
		printLn( "^0Struct 1 origin: ", structs[1].origin );
		
		thread registerPossibleChests( structs, 1 );
		thread registerPossibleVendor( structs, 2 );
	}
	
	if( has_sd )
	{
		structs = [];
	
		// clean up the unused things
		delArray = getEntArray( "bombtrigger", "targetname" );
		delArray = arrayMerge( delArray, getEntArray( "bombzone", "targetname" ) );
		deleteAll( delArray );
		
		allObjects = getGameobjects( "bombzone" );
		for( i=0; i<allObjects.size; i++ )
			printLn( "SD Object ", allObjects[i].origin, ";", allObjects[i].classname, ";", allObjects[i].targetname );
		
		for( i=0; i<allObjects.size; i++ )
		{
			if( !isDefined(allObjects[i]) )
				continue;
			
			if( allObjects[i].classname == "script_model" && !isDefined(allObjects[i].used) )
			{
				allObjects[i].used = false;
				structs[structs.size] = allObjects[i];
			}
		}
	
		
		for( i=0; i<structs.size; i++ )
		{
			structs[i].detail = [];
			for( j=0; j<allObjects.size; j++ )
			{
				if( distance(allObjects[j].origin, structs[i].origin) < 50 )
				{
					if( allObjects[j].classname == "script_brushmodel" )
					{
						ID = structs[i].detail.size;
						structs[i].detail[ID] = allObjects[j];
						structs[i].detail[ID] linkTo( structs[i] );
					}
					else if( allObjects[j].classname == "trigger_use_touch" )
					{
						structs[i].trigger = allObjects[j];
						structs[i].trigger.offset = structs[i].origin - allObjects[j].origin;
					}
				}
			}
		}
		
		printLn( "^0Struct 0 origin: ", structs[0].origin );
		printLn( "^0Struct 1 origin: ", structs[1].origin );
		
		thread registerPossibleChests( structs, 1 );
		thread registerPossibleVendor( structs, 2 );
	}
	
	if( has_koth )
	{
		delArray = getEntArray( "radiotrigger", "targetname" );
		deleteAll( delArray );
		
		hqs = getEntArray( "hq_hardpoint", "targetname" );
		for( i=0; i<hqs.size; i++ )
		{
			hqs[i].OffsetOrigin = (4, -4, 30);
			hqs[i].OffsetAngles = (0, 270, 0);
			hqs[i].detail = [];
		}
		
		details = getGameobjects( "hq" );
		for( i=0; i<details.size; i++ )
		{
			if( isDefined(details[i].targetname) && details[i].targetname == "hq_hardpoint" )
				continue;
				
			parent = details[i] getClosestEntity( "hq_hardpoint" );
			parent.detail[parent.detail.size] = details[i];
			
			details[i] linkto( parent );
		}
		
		thread registerPossibleVendor( hqs, 1 );
		thread registerPossibleChests( hqs, 2 );
	}
	
	//println( "gametypes converted" );
}
deleteAll( delArray )
{	
	if( delArray.size > 0 )
	{
		for( i=0; i<delArray.size; i++ )
		{
			println("DELETED: ", delArray[i].classname, "; GAMEMODE: ", delArray[i].script_gameobjectname );
			delArray[i] delete();
		}
	}
}
registerPossibleChests( chests, priority )
{
	if( !isDefined(level.possibleChests) )
		level.possibleChests = [];
		
	for( i=0; i<chests.size; i++ )
	{
		chest = chests[i];
		if( !isDefined(chest.trigger) )
			chest.trigger = spawn( "trigger_radius", chest.origin, 0, 64, 64 );
		
		if( !isDefined(chest.used) )
			chest.used = false;
		
		chest.chestpriority = priority;
		level.possibleChests[level.possibleChests.size] = chest;
	}
}
registerPossibleVendor( vendors, priority )
{
	if( !isDefined(level.possibleVendors) )
		level.possibleVendors = [];
		
	for( i=0; i<vendors.size; i++ )
	{
		vendor = vendors[i];
		if( !isDefined(vendor.trigger) )
			vendor.trigger = spawn( "trigger_radius", vendor.origin, 0, 64, 64 );
		
		if( !isDefined(vendor.used) )
			vendor.used = false;
		
		vendor.vendorpriority = priority;
		level.possibleVendors[level.possibleVendors.size] = vendor;
	}
}

/*=================
Example: deleteOldschool()
Description: Delets Oldschool weapon and perk pickups
=================*/
deleteOldschool()
{
	pickups = getEntArray( "oldschool_pickup", "targetname" );
	
	for( i=0; i<pickups.size; i++ )
		pickups[i] delete();
}

/*=================
Example: loadSpawnpoints( gamemode )
Required Values: 
Possible Values: <gamemode> name of a valid gamemode (tdm, war, koth, sd, sab, dom)
Description: Loads the spawnpoints of a gamemode for proper use in the mod
=================*/
loadSpawnpoints( gamemode )
{
	if( !isDefined(gamemode) )
		gamemode = "tdm";
	
	if( gamemode == "tdm" || gamemode == "war" || gamemode == "koth" )
	{
		maps\mp\gametypes\_spawnlogic::addPlayerSpawns( "mp_tdm_spawn_allies_start", true );
		maps\mp\gametypes\_spawnlogic::addZombieSpawns( "mp_tdm_spawn", true );
	}
	else if( gamemode == "sd" )
	{
		maps\mp\gametypes\_spawnlogic::addPlayerSpawns( "mp_sd_spawn_defender", true );
		maps\mp\gametypes\_spawnlogic::addZombieSpawns( "mp_sd_spawn_attacker", true );
	}
	else if( gamemode == "sab" )
	{
		maps\mp\gametypes\_spawnlogic::addPlayerSpawns( "mp_sab_spawn_allies_start", true );
		maps\mp\gametypes\_spawnlogic::addZombieSpawns( "mp_sab_spawn_axis", true );
		maps\mp\gametypes\_spawnlogic::addZombieSpawns( "mp_sab_spawn_allies", true );
	}
	else if( gamemode == "dom" )
	{
		maps\mp\gametypes\_spawnlogic::addPlayerSpawns( "mp_dom_spawn_allies_start", true );
		maps\mp\gametypes\_spawnlogic::addZombieSpawns( "mp_dom_spawn", true );
	}
	else
	{
		maps\mp\gametypes\_spawnlogic::addPlayerSpawns( "mp_tdm_spawn_allies_start", true );
		maps\mp\gametypes\_spawnlogic::addZombieSpawns( "mp_tdm_spawn", true );
	}
	
	thread setupDefaultTargets();
}
setupDefaultTargets()
{
	if( !isDefined(level.defaultZombieTargets) )
		level.defaultZombieTargets = [];
	
	for( i=0; i<level.zombiespawns.size; i++ )
		level.defaultZombieTargets[level.defaultZombieTargets.size] = level.zombiespawns[i];
	
	// we just set all the zombies spawns as default locations to move to
	// this is just a rough way to get zombies to work in v0.5,
	// v0.6 will work with attractors
}

setupWeaponVendor( number, vendor1, vendor2, vendor3, vendor4, vendor5 )
{
	level.WeaponVendorCount = number;

	if( !isDefined(level.WeaponVendorPoints) )
		level.WeaponVendorPoints = [];
	
	if( isDefined(vendor1) )
		level.WeaponVendorPoints[0] = vendor1;
	
	if( isDefined(vendor2) )
		level.WeaponVendorPoints[1] = vendor2;
	
	if( isDefined(vendor3) )
		level.WeaponVendorPoints[2] = vendor3;
		
	if( isDefined(vendor4) )
		level.WeaponVendorPoints[3] = vendor4;
		
	if( isDefined(vendor5) )
		level.WeaponVendorPoints[4] = vendor5;
	
	for( i=0; i<level.WeaponVendorCount; i++ )
	{
		vendor = getBestChest();
		if( !isDefined(vendor) )		// no more shops
		{
			if( !isDefined(level.WeaponVendorPoints[i]) )		// we have no location so we can't do anything
				continue;
			
			vendor = spawn( "script_model", level.WeaponVendorPoints[i].origin );
			vendor setmodel( "prop_flag_american" );
			vendor.trigger = spawn( "trigger_radius", level.WeaponVendorPoints[i].origin, 0, 64, 64 );
		}
		
		if( isDefined(level.WeaponVendorPoints[i]) )
		{
			if( isDefined(vendor.OffsetOrigin) )
				vendor.origin = (level.WeaponVendorPoints[i].origin + vendor.OffsetOrigin);
			else
				vendor.origin = level.WeaponVendorPoints[i].origin;
				
			if( isDefined(vendor.OffsetAngles) )
				vendor.angles = (level.WeaponVendorPoints[i].angles + vendor.OffsetAngles);
			else
				vendor.angles = level.WeaponVendorPoints[i].angles;
			
			if( isDefined(vendor.trigger.offset) )
				vendor.trigger.origin = (vendor.origin - vendor.trigger.offset);
			else
				vendor.trigger.origin = vendor.origin;
			//vendor.trigger.angles = vendor.angles;
		}
		
		thread scripts\level\_levelsetup::addWeaponShop( vendor.origin, vendor.trigger, (0,0,70) );
		//vendor thread scripts\level\_weapon_vendor::vendor_think();
		//println( "Weapon Vendor origin: ", vendor.origin, "; angles: ", vendor.angles );
	}
}

setupEquipmentVendor( number, vendor1, vendor2, vendor3, vendor4, vendor5 )
{
	level.EquipmentVendorCount = number;

	if( !isDefined(level.EquipmentVendorPoints) )
		level.EquipmentVendorPoints = [];
	
	if( isDefined(vendor1) )
		level.EquipmentVendorPoints[0] = vendor1;
	
	if( isDefined(vendor2) )
		level.EquipmentVendorPoints[1] = vendor2;
	
	if( isDefined(vendor3) )
		level.EquipmentVendorPoints[2] = vendor3;
		
	if( isDefined(vendor4) )
		level.EquipmentVendorPoints[3] = vendor4;
		
	if( isDefined(vendor5) )
		level.EquipmentVendorPoints[4] = vendor5;
	
	for( i=0; i<level.EquipmentVendorCount; i++ )
	{
		vendor = getBestVendor();
		if( !isDefined(vendor) )		// no free vendor found
		{
			println( "trying to create vendor" );
			if( !isDefined(level.EquipmentVendorPoints[i]) )	// we have no origin, so we can't go on
				continue;
				
			vendor = spawn( "script_model", level.EquipmentVendorPoints[i].origin );
			vendor setmodel( "prop_flag_brit" );
			vendor.trigger = spawn( "trigger_radius", level.EquipmentVendorPoints[i].origin, 0, 64, 64 );
		}
		
		if( isDefined(level.EquipmentVendorPoints[i]) )
		{
			if( isDefined(vendor.OffsetOrigin) )
				vendor.origin = (level.EquipmentVendorPoints[i].origin + vendor.OffsetOrigin);
			else
				vendor.origin = level.EquipmentVendorPoints[i].origin;
				
			if( isDefined(vendor.OffsetAngles) )
				vendor.angles = (level.EquipmentVendorPoints[i].angles + vendor.OffsetAngles);
			else
				vendor.angles = level.EquipmentVendorPoints[i].angles;
			
			if( isDefined(vendor.trigger.offset) )
				vendor.trigger.origin = (vendor.origin - vendor.trigger.offset);
			else
				vendor.trigger.origin = vendor.origin;
			//vendor.trigger.angles = vendor.angles;
		}
		
		thread scripts\level\_levelsetup::addShop( vendor.origin, vendor.trigger );
		//vendor thread scripts\level\_equipment_vendor::vendor_think();
		//println( "Equipment Vendor origin: ", vendor.origin, "; angles: ", vendor.angles );
	}
}

setupWeaponUpgrade( point )
{
	if( isDefined(point) )
		level.WeaponUpgradePoint = point;
	
	level.weaponUpgradeAvailable = true;
}

getClosestEntity( targetname )
{
	ents = getentarray( targetname, "targetname" );
	
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
getBestChest()
{
	chest = undefined;
	
	if( !isDefined(level.possibleChests) )
		return chest;
	
	if( level.type == "multiplayer" )
	{
		hightstPriority = 999;
	
		for( i=0; i<level.possibleChests.size; i++ )
		{
			ch = level.possibleChests[i];
			if( ch.used == false && ch.chestpriority < hightstPriority )
			{
				hightstPriority = ch.chestpriority;
				chest = ch;
			}
		}
		
		chest.used = true;
	}
	else
	{
		for( i=0; i<level.possibleChests.size; i++ )
		{
			ch = level.possibleChests[i];
			if( ch.used == false )
			{
				ch.used = true;
				chest = ch;
				break;	
			}
		}
	}
	
	return chest;
}
getBestVendor()
{
	vendor = undefined;
	
	if( !isDefined(level.possibleVendors) )
		return vendor;
	
	if( level.type == "multiplayer" )
	{
		hightstPriority = 999;
	
		for( i=0; i<level.possibleVendors.size; i++ )
		{
			ve = level.possibleVendors[i];
			if( ve.used == false && ve.vendorpriority < hightstPriority )
			{
				hightstPriority = ve.vendorpriority;
				vendor = ve;
			}
		}
		
		if( isDefined(vendor) )
			vendor.used = true;
	}
	else
	{
		for( i=0; i<level.possibleVendors.size; i++ )
		{
			if( level.possibleVendors[i].used == false )
			{
				vendor = level.possibleVendors[i];
				vendor.used = true;
				break;	
			}
		}
	}
	
	return vendor;
}