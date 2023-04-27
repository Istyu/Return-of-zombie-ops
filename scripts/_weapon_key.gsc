/*=======================================================================================
return of the zombie ops - Mod
Modded by Lefti & 3aGl3
=========================================================================================
Weapon Key for modding projects
=======================================================================================*/

getConsoleName( weapon )
{
	return tableLookup( "mp/weapon_key.csv", 2, weapon, 3 );
}

getScriptName( weapon )
{
	return tableLookup( "mp/weapon_key.csv", 3, weapon, 2 );
}

getWeaponClass( weapon )
{
	return tableLookup( "mp/statsTable.csv", 4, weapon, 2 );
}


// old command workarounds

_getAmmoCount( weapon )
{
	return self getAmmoCount( getConsoleName(weapon) );
}

// SP only?
/*_getWeaponClipModel( weapon )
{
	return getWeaponClipModel( getConsoleName(weapon) );
}*/

_getWeaponModel( weapon, id )
{
	if( !isdefined(id) )
		id = 0;
	
	return getWeaponModel( getConsoleName(weapon), id );
}

_isWeaponClipOnly( weapon )
{
	return isweaponcliponly( getConsoleName(weapon) );
}

_isWeaponDetonationTimed( weapon )
{
	return isweapondetonationtimed( getConsoleName(weapon) );
}

_weaponClass( weapon )
{
	return weaponclass( getConsoleName(weapon) );
}

_weaponClipSize( weapon )
{
	return weaponclipsize( getConsoleName(weapon) );
}

_weaponFireTime( weapon )
{
	return weaponfiretime( getConsoleName(weapon) );
}

_weaponInventoryType( weapon )
{
	return weaponinventorytype( getConsoleName(weapon) );
}

_weaponIsBoltAction( weapon )
{
	return weaponisboltaction( getConsoleName(weapon) );
}

_weaponIsSemiAuto( weapon )
{
	return weaponissemiauto( getConsoleName(weapon) );
}

_weaponMaxAmmo( weapon )
{
	return weaponmaxammo( getConsoleName(weapon) );
}

_weaponStartAmmo( weapon )
{
	return weaponstartammo( getConsoleName(weapon) );
}

_weaponType( weapon )
{
	return weapontype( getConsoleName(weapon) );
}

_precacheItem( weapon )
{
	real = getConsoleName(weapon);
	
	precacheItem( real );
	println( "Precached weapon: "+weapon+" - "+real );
}

_giveweapon( weapon, model )
{
	if( !isDefined(model) )
		model = 0;
	
	self giveweapon( getConsoleName(weapon), model );
}

_giveMaxAmmo( weapon )
{
	self givemaxammo( getConsoleName(weapon) );
}

_takeWeapon( weapon )
{
	self takeweapon( getConsoleName(weapon) );
}

_hasWeapon( weapon )
{
	return self hasWeapon( getConsoleName(weapon) );
}

_getWeaponList()
{
	scriptList =[];
	consoleList = self getweaponslist();
	
	for( i=0; i<consoleList.size; i++ )
	{
		scriptList[scriptList.size] = getScriptName(consoleList[i]);
	}
	
	return scriptList;
}

_setSpawnWeapon( weapon )
{
	self setSpawnWeapon( getConsoleName(weapon) );
}

_SetWeaponAmmoClip( weapon, ammo )
{
	self setweaponammoclip( getConsoleName(weapon), ammo );
}

_switchToWeapon( weapon )
{
	self switchtoweapon( getConsoleName(weapon) );
}

_SwitchToOffhand( weapon )
{
	self switchtooffhand( getConsoleName(weapon) );
}

_getCurrentWeapon()
{
	return getScriptName( self getcurrentweapon() );
}


// additional weapon functions

getGrenadeFile( weapon )
{
	switch( weapon )
	{
		case "frag_grenade_short":
			return "frag_grenade_short";
		case "frag_grenade":
		case "acid_grenade":
		case "energy_grenade":
		case "frost_grenade":
			return "frag_grenade";
		case "flash_grenade":
		case "frezze_grenade":
		case "emp_grenade":
			return "flash_grenade";
		case "smoke_grenade":
		case "tabun_grenade":
		case "flare_grenade":
			return "smoke_grenade";
		case "concussion_grenade":
			return "concussion_grenade";
	}
}

setWeaponAmmoOverall( weapon, amount )
{
	weaponname = getConsoleName(weapon);
	
	if ( isWeaponClipOnly(weaponname) )
	{
		self setWeaponAmmoClip( weaponname, amount );
	}
	else
	{
		self setWeaponAmmoClip( weaponname, amount );
		diff = amount - self getWeaponAmmoClip( weaponname );
		assert( diff >= 0 );
		self setWeaponAmmoStock( weaponname, diff );
	}
}
