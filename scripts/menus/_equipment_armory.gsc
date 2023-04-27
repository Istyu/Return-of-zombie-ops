/*=======================================================================================
Return of the Zombie Ops - Mod
Modded by Lefti & 3aGl3
=========================================================================================
Equipment Armory Menu - Script
=======================================================================================*/
#include scripts\_utility;
#include scripts\_weapon_key;

//init()		--> scripts/level/equipment_armory.gsc

responseHandler( response )
{
	if( issubstr( response, "escape" ) )
	{
		self escapeMenu(response);
	}
	else if( isSubStr( response, "category" ) )
	{
		
	}
	else if( isSubStr( response, "buy" ) )
	{
		self buy( response );
	}
}

escapeMenu( response )
{
	toks = strTok( response, "#" );
	
	if( toks.size <= 1 || toks[1] == "select" )
	{
		self closeMenus();
	}
	else if( toks[1] != "select" )
	{
		self setClientDvar( "armory", "select" );
	}
}

buy( response )
{
	respTok = strTok( response, "#" );
	item = int(respTok[1]);
	
	part = "perks";
	switch( item )
	{
		case 58:
			part = "c4";
			break;
		case 59:
			part = "claymore";
			break;
		case 54:
			part = "gl";
			break;
		case 55:
			part = "rpg";
			break;
		case 178:
			part = "supply";
			break;
		case 179:
			part = "sentry";
			break;
		case 180:
			part = "mk19";
			break;
		case 62:
		case 63:
		case 171:
		case 172:
		case 174:
		case 175:
			part = "grenade";
			break;
		case 64:
		case 65:
		case 66:
		case 173:
		case 176:
		case 177:
			part = "sgrenade";
			break;
		default:
			part = "perks";
			break;
	}
	
	
	if( self.points >= level.eShopCost[part] )
	{
		switch( part )
		{
			case "grenade":
				self buyGrenade( item, "grenade" );
				break;
			case "sgrenade":
				self buyGrenade( item, "sgrenade" );
				break;
			case "perk":
				self buyPerk( item );
				break;
			case "c4":
			case "claymore":
			case "rpg":
			case "gl":
				self buyWeapon( part );
				break;
			case "sentry":
				self buyHardpoint( maps\mp\gametypes\_hardpoints::getHardpointID( "sentry_gun" ) );
				break;
			case "mk19":
				self buyHardpoint( maps\mp\gametypes\_hardpoints::getHardpointID( "sentry_mk19" ) );
				break;
			case "supply":
				self buyHardpoint( maps\mp\gametypes\_hardpoints::getHardpointID( "carepackage" ) );
				break;
			default:
				iprintln( part );
				break;
		}
		
		self scripts\player\_points::takePoints( level.eShopCost[part] );
		self playLocalSound( "mp_ingame_summary" );
	}
	else
	{
		self iPrintLn( &"ZMB_NOT_ENOUGH_POINTS_N", level.eShopCost[part] );
	}
	
	self closeMenus();
}

buyWeapon( weapon )
{
	if( weapon == "rpg" )
		ammo = 2;
	else if( weapon == "gl" )
		ammo = 4;
	else
		ammo = 5;
	
	if( self _hasWeapon(weapon) )
	{
		currentAmmo = self _getAmmoCount(weapon);

		self setWeaponAmmoOverall( weapon, currentAmmo+ammo );
		
		if( _weaponInventoryType(weapon) != "primary" )
			self _setActionSlot( 2, "weapon", weapon );
	}
	else
	{
		if( _weaponInventoryType(weapon) == "primary" )
		{
			if( self primaryCount() >= 2 )
				self takeWeapon( self getCurrentWeapon() );
		}
		else
			self _setActionSlot( 2, "weapon", weapon );
		
		self _giveWeapon( weapon );
		self setWeaponAmmoOverall( weapon, ammo );
		
		if( _weaponInventoryType(weapon) == "primary" )
			self _switchToWeapon( weapon );
	}
}

buyGrenade( stat, category )
{
	name = tableLookup( "mp/statsTable.csv", 0, stat, 4 );		// script name of the grenade
	weapon = getGrenadeFile( name );			// console name of the grenade
	
	ammo = 2;																						// ToDo: Get ammo from players current grenade level
	
	if( self _hasWeapon(weapon) && self.loadout[category] == name )
	{
		currentAmmo = self _getAmmoCount(weapon);

		self setWeaponAmmoOverall( weapon, currentAmmo+ammo );
	}
	else
	{
		if( self.loadout[category] != "none" )
			self _takeWeapon(self.loadout[category]);
		
		self.loadout[category] = name;
		self _giveWeapon(weapon);
		self setWeaponAmmoOverall( weapon, ammo );
		
		if( category == "grenade" )
			self _SwitchToOffhand( self.loadout["grenade"] );
		else
			self setOffhandSecondaryClass("flash");
	}
}

buyPerk( stat )
{
	
}

buyHardpoint( ID )
{
	self endon( "disconnect" );
	
	if( isDefined(self.pers["hardPointItem"]) )
		self.hardpoints[self.hardpoints.size] = self.pers["hardPointItem"];

	self maps\mp\gametypes\_hardpoints::giveHardpoint( ID, 1 );

	notifyData = spawnStruct();
	notifyData.textLabel = &"MP_STREAK_N_IS_READY";
	notifyData.notifyText = level.hardpoints[ID]["title"];
	notifyData.textIsString = true;
	notifyData.sound = level.hardpoints[ID]["inform"];
	notifyData.iconName = level.hardpoints[ID]["icon"];

	self maps\mp\gametypes\_hud_message::notifyMessage( notifyData );
}