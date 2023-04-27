/*=======================================================================================
Return of the Zombie Ops - Mod
Modded by Lefti & 3aGl3
=========================================================================================
Zombie waypoint include
=======================================================================================*/
#include scripts\_utility;

addDefaultPlayerSpawns( swap )
{
	if( !isdefined(swap) )
		swap = false;
	
	maps\mp\gametypes\_spawnlogic::addPlayerSpawns( "mp_tdm_spawn_allies_start", true );
	
	if( swap )
		maps\mp\gametypes\_spawnlogic::addPlayerSpawns( "mp_sd_spawn_defender", true );
	else
		maps\mp\gametypes\_spawnlogic::addPlayerSpawns( "mp_sd_spawn_attacker", true );
}

addDefaultZombieSpawns()
{
	maps\mp\gametypes\_spawnlogic::addZombieSpawns( "mp_dm_spawn", true );
}

placeShops( weapon, equipment )
{
	if( level.gametype == "arena" )
		return;
	
	weaponArmorys = strTok( weapon, " " );
	equipmentArmorys = strTok( equipment, " " );
	
	wArmoryStructs = scripts\level\_stockmap::useSDTargets();
	wArmoryStructs = scripts\_utility::arrayMerge( wArmoryStructs, scripts\level\_stockmap::useSABTargets() );
	eArmoryStructs = scripts\level\_stockmap::useHQTargets();
	
	for( i=0; i<equipmentArmorys.size; i++ )
	{
		source = level.tradespawns[int(equipmentArmorys[i])];
		
		struct = getFreeStruct( eArmoryStructs, wArmoryStructs );
		if( isDefined(struct) )
		{
			struct.origin = source.origin+(0,0,30);
			struct.angles = source.angles+(0,270,0);
			
			thread scripts\level\_levelsetup::addShop( struct.origin, undefined  );
		}
		else
			iPrintLn( "Could not add equipmentArmory ", i );
	}
	
	for( i=0; i<weaponArmorys.size; i++ )
	{
		source = level.tradespawns[int(weaponArmorys[i])];
		
		struct = getFreeStruct( wArmoryStructs, eArmoryStructs );
		if( isDefined(struct) )
		{
			if( isDefined(struct.trigger) )		// HQ targets got no own trigger, we're using this to indicate what we got
				struct.origin = source.origin;
			else
				struct.origin = source.origin+(0,0,30);
			
			struct.angles = source.angles;
			
			if( isDefined(struct.trigger) )
				struct.trigger.origin = source.origin + struct.trigger.offset;
			//struct.trigger.angles = source.angles;
		
			thread scripts\level\_levelsetup::addWeaponShop( struct.origin, struct.trigger, (0,0,70) );
		}
		else
			iPrintLn( "Could not add weaponArmory ", i );
	}
	
	thread scripts\level\_stockmap::delUnusedTargets( wArmoryStructs, eArmoryStructs );
}

getFreeStruct( structs, additional )
{
	for( i=0; i<structs.size; i++ )
	{
		if( !isDefined(structs[i].used) || structs[i].used == false )
		{
			structs[i].used = true;
			return structs[i];
		}
	}
	
	if( !isDefined(additional) )
		return;
	
	for( i=0; i<additional.size; i++ )
	{
		if( !isDefined(additional[i].used) || additional[i].used == false )
		{
			additional[i].used = true;
			return additional[i];
		}
	}
}

convertWaypoints()
{
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
}


zombieDefaultTarget( origin )
{
	if( !isDefined(level.defaultZombieTargets) )
		level.defaultZombieTargets = [];
	
	ID = level.defaultZombieTargets.size;
	level.defaultZombieTargets[ID] = spawnstruct();
	level.defaultZombieTargets[ID].origin = origin;
}

mapThink()
{
	level.maptype = "rozo_survival";
	//scripts\level\_waypoints::getFromCSV();		-- to give mapper the posibilty to use both types of waypoints
	
	weaponPickups = getEntArray( "weapon_buy", "targetname" );
	
	weaponShops = getEntArray( "weapon_shop", "targetname" );
	weaponShopModels = getEntArray( "weapon_shop_detail", "targetname" );
	
	perkShops = getEntArray( "perk_shop", "targetname" );
	perkShopModels = getEntArray( "perk_shop_detail", "targetname" );
	
	boxLids = getEntArray( "zombie_treasure_lid", "targetname" );
	boxModels = getEntArray( "zombie_treasure_box", "targetname" );
	boxClips = getEntArray( "zombie_treasure_clip", "targetname" );
	boxTrigger = getEntArray( "zombie_treasure_trigger", "targetname" );
	
// delete unused stuff
	delArray = [];
	if( level.weaponShopHandling != 1 || isDefined(level.gamemodeNoShops) )
	{
		delArray = boxLids;
		delArray = arrayMerge( delArray, boxModels );
		delArray = arrayMerge( delArray, boxClips );
		delArray = arrayMerge( delArray, boxTrigger );
	}
	
	if( level.weaponShopHandling != 2 || isDefined(level.gamemodeNoShops) )
	{
		delArray = arrayMerge( delArray, weaponShops );
		delArray = arrayMerge( delArray, weaponShopModels );
	}
	
	if( level.perkShopHandling != 1 && level.perkShopHandling != 2 || isDefined(level.gamemodeNoShops) )
	{
		delArray = arrayMerge( delArray, perkShops );
		delArray = arrayMerge( delArray, perkShopModels );
	}
	
	if( level.weaponPickupHandling != 1 || isDefined(level.gamemodeNoShops) )
	{
		weaponModels = [];
		for( i=0; i<weaponPickups.size; i++ )
			weaponModels[weaponModels.size] = getEnt( weaponPickups[i].target, "targetname" );
		
		delArray = arrayMerge( delArray, weaponPickups );
		delArray = arrayMerge( delArray, weaponModels );
	}
	for( i=0; i<delArray.size; i++ )
		delArray[i] delete();
	
// setup the shops, weapons, and so on
	if( level.weaponShopHandling == 1 && !isDefined(level.gamemodeNoShops) )
	{
		//for( i=0; i<boxTrigger.size; i++ )
		//	thread scripts\level\_levelsetup::addWeaponShop( weaponShops[i].origin, weaponShops[i] );
	}
	
	if( level.weaponShopHandling == 2 && !isDefined(level.gamemodeNoShops) )
	{
		for( i=0; i<weaponShops.size; i++ )
			thread scripts\level\_levelsetup::addWeaponShop( weaponShops[i].origin, weaponShops[i] );
	}
	
	if( !isDefined(level.gamemodeNoShops) && (level.perkShopHandling != 1 || level.perkShopHandling != 2) )
	{
		for( i=0; i<perkShops.size; i++ )
			thread scripts\level\_levelsetup::addShop( perkShops[i].origin, perkShops[i] );
	}
	
	if( level.weaponPickupHandling == 1 && !isDefined(level.gamemodeNoShops) )
	{
		for( i=0; i<weaponPickups.size; i++ )
			weaponPickups[i] thread scripts\level\weapon_pickup::createWeaponPickup();
	}
	
}

setPlayerModels()
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
