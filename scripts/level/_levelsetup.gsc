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
Zombie map setup
=======================================================================================*/
#include scripts\_utility;

init()
{
	precacheString( &"ZMB_NOT_ENOUGH_POINTS_N" );
	precacheShader( "hud_weapons" );
	precacheShader( "hud_ammo" );
	
	level.barricades = [];																			// ToDo!
	
	level.weaponShopHandling = xDvarInt( "scr_shop_type", 1, 0, 2 );			// 0 - disabled; 1 - treasure chest; 2 - weapon armory
	level.perkShopHandling	= xDvarInt( "scr_perk_type", 1, 0, 2 );				// 0 - disabled; 1 - perk vendor; 2 - equipment armory
	level.weaponPickupHandling = xDvarInt( "scr_pickup_type", 1, 0, 1 );		// 0 - disabled; 1 - enabled
	
//	thread scripts\level\barricades::init();
	thread scripts\level\weapon_pickup::init();
	
	if( level.gametype == "arena" || level.gametype == "dm" )
		return;
	
	if( level.weaponShopHandling == 1 )
		thread scripts\level\treasure_chest::init();
	else
		thread scripts\level\weapon_armory::init();
	
	if( level.perkShopHandling == 1 )
		thread scripts\level\perk_vendor::init();
	else
		thread scripts\level\equipment_armory::init();
}

addWeaponShop( origin, trigger, offset )	// Treasure Chest / Weapon Armory
{
	if( level.weaponShopHandling != 1 && level.weaponShopHandling != 2  || isDefined(level.gamemodeNoShops) )
	{
		if( isDefined(trigger) )
			trigger delete();
	}
	else
	{
		if( !isDefined(offset) )
			offset = (0,0,0);
		
		if( !isDefined(trigger) )
			trigger = spawn( "trigger_radius", origin, 0, 32, 64 );
		
		if( level.weaponShopHandling == 1 )
			thread scripts\level\treasure_chest::addTreasureChest( origin, trigger, offset );
		else
			thread scripts\level\weapon_armory::addArmory( origin, trigger );
			
		maps\mp\gametypes\_objpoints::createTeamObjpoint( "weapon_armory", origin+(0,0,72), "allies", "hud_weapons", 1, 8 );
	}
}

addShop( origin, trigger )		// Perk Vendor / Equipment Armory
{
	if( level.perkShopHandling != 1 && level.perkShopHandling != 2  || isDefined(level.gamemodeNoShops) )
	{
		if( isDefined(trigger) )
			trigger delete();
	}
	else
	{
		if( !isDefined(trigger) )
			trigger = spawn( "trigger_radius", origin, 0, 32, 64 );
		
		if( level.perkShopHandling == 1 )
			thread scripts\level\perk_vendor::addVendor( origin, trigger );
		else
			thread scripts\level\equipment_armory::addArmory( origin, trigger );
		
		maps\mp\gametypes\_objpoints::createTeamObjpoint( "equipment_armory", origin+(0,0,72), "allies", "hud_ammo", 1, 8 );
	}
}

addBarricade( complex, entity, health, deathFx, buildFx, parts )
{
	if( !isDefined(level.barricades) )
		level.barricades = [];
		
	entity.maxhealth = health;
	entity.health = entity.maxhealth;
	entity.team = "allies";
	entity.partsSize = parts;
	entity.deathFx = deathFx;
	entity.buildFx = buildFx;
	
	if( complex )
		entity.parts = getAllParts();
	else
	{
		for( i=0; i<parts; i++ )
			entity.parts[i] = entity getClosestEntity( entity.target+i );
	}
	
	for( i=0; i<parts; i++ )
		entity.parts[i].hidden = false;
	
	level.barricades[level.barricades.size] = entity;
	
	entity thread scripts\level\barricades::barricade_create();
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

getAllParts()
{
	parts = [];
	
	ent = self;
	while( isDefined(ent.target) )
	{
		parts[parts.size] = getClosestEntity( self.target );
		ent = parts[parts.size];
	}
	
	return parts;
}