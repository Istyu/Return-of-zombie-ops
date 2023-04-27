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
reign of the undead zombies map module
=======================================================================================*/
#include scripts\_utility_flags;
#include scripts\_weapon_key;
#include scripts\_utility;

// GENERAL SCRIPTS
waittillStart()
{
	flag_init( "level_defined" );
	level.type = "rotu";
	
	level.possibleChests = [];
	level.possibleVendors = [];
	level.possiblePickups = [];
	
	level.Barricades = [];
	level.weaponUpgradeAvailable = false;
	
	level.WeaponVendorPoints = [];
	level.EquipmentVendorPoints = [];
	
	scripts\level\barricades::init();
	scripts\level\_levelsetup::init();
	scripts\level\_waypoints::init();
	
	thread scripts\level\_zombiemode::loadWaypointsCSV();
	println( "Map detected as a rotu map" );
}
startSurvWaves() 
{
	if( !isDefined(level.playerspawns) || level.playerspawns.size == 0 )
	{
		level.playerspawns = [];
		
		spawns = getEntArray( "mp_tdm_spawn", "classname" );
		spawns = arrayMerge( spawns, getEntArray( "mp_tdm_spawn_allies_start", "classname" ));
		spawns = arrayMerge( spawns, getEntArray( "mp_tdm_spawn_axis_start", "classname" ));
		
		for( i=0; i<spawns.size; i++ )
		{
			ID = level.playerspawns.size;
			
			level.playerspawns[ID] = spawns[i];
			level.playerspawns[ID].enabled = true;
		}
		printLn( "Playerspawn count: "+level.playerspawns.size );
	}
	
	flag_set( "level_defined" );
}

// SPAWNS
setPlayerSpawns( targetname )
{
	scripts\level\_zombiemode::registerPlayerStart( targetname );
}
buildSurvSpawn(targetname, priority) // Loading spawns for survival mode (incomming waves)
{
	scripts\level\_zombiemode::registerDefaultZombieSpawns( targetname );
	
	ents = getEntArray( targetname, "targetname" );
	attractor = undefined;
	for( i=0; i<ents.size; i++ )
	{
		if( isDefined(ents[i].target) )
		{
			attractor = getEnt( ents[i].target, "targetname" );
			break;
		}
	}
	
	if( !isDefined(level.defaultZombieTargets) )
		level.defaultZombieTargets = [];
	
	if( isDefined(attractor) )
		level.defaultZombieTargets[level.defaultZombieTargets.size] = attractor;
}

// SHOPS
buildAmmoStock( targetname, loadtime )
{
	chests = getEntArray( targetname, "targetname" );
	
	for( i=0; i<chests.size; i++ )
	{
		if( isSubStr( chests[i].classname, "trigger" ) )
		{
			chest = spawn( "script_origin", chests[i].origin );
			chest.trigger = chests[i];
		}
		else
		{
			chest = chests[i];
			chest.trigger = spawn( "trigger_radius", chests[i].origin, 0, 64, 64 );
		}

		thread scripts\level\_levelsetup::addWeaponShop( chest.origin, chest.trigger );
	}
}
buildWeaponUpgrade( targetname )
{
	shops = getEntArray( targetname, "targetname" );
	
	for( i=0; i<shops.size; i++ )
	{
		if( isSubStr( shops[i].classname, "trigger" ) )
		{
			shop = spawn( "script_origin", shops[i].origin );
			shop.trigger = shops[i];
		}
		else
		{
			shop = shops[i];
			shop.trigger = spawn( "trigger_radius", shops[i].origin, 0, 64, 64 );
		}
		
		thread scripts\level\_levelsetup::addShop( shop.origin, shop.trigger );
	}
}
buildWeaponPickup(targetname, itemtext, weapon, type)
{
	ents = getentarray( targetname, "targetname" );
	for( i=0; i<ents.size; i++ )
	{
		ent = ents[i];
		
		if( !isSubStr( ent.classname, "trigger" ) )
			continue;
		
		ent.weapon = getScriptName( weapon );
		ent.weaponType = getWeaponClass( ent.weapon );
		
		level.possiblePickups[level.possiblePickups.size] = ent;
	}
}

// BARRICADES
buildBarricade(targetname, parts, health, deathFx, buildFx, dropAll)
{
	ents = getEntArray( targetname, "targetname" );
	for (i=0; i<ents.size; i++)
	{
		ent = ents[i];
		
		ent.deathFx = deathFx;
		ent.buildFx = buildFx;
		ent.parthealth = int(health/parts);
		
		ent.parts = [];
		for( j=0; j<parts; j++ )
		{
			ent.parts[ent.parts.size] = ent getClosestEntity( ent.target + j );
		}
		
		level.barricades[level.barricades.size] = ent;
		ent thread scripts\level\barricades::barricade_create();
	}
}

// START LOADOUT
setSpawnWeapons(primary, secondary)
{
//	level.spawnPrimary = primary;
//	level.spawnSecondary = secondary;
}

// UNUSED
setGameMode(mode)
{

}
setWeaponHandling(id)
{

}
setWorldVision( vision, transitiontime )
{

}
buildParachutePickup(targetname)
{

}
beginZomSpawning()
{

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
