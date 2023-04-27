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
Treasure Chest weapon definition
=======================================================================================*/

loadWeapons()
{
	// Handguns
	addWeapon( "beretta" );
	addWeapon( "usp" );
	addWeapon( "deserteagle" );
	
	// Machine Pistols
	addWeapon( "g18" );
	addWeapon( "mp5k" );
	
	// Sub Machine Guns
	addWeapon( "mp5" );
	addWeapon( "ump" );
	addWeapon( "vector" );
	addWeapon( "ak47u" );
	addWeapon( "p90" );
	
	// Assault Rifles
	addWeapon( "ak47" );
	addWeapon( "m4" );
	addWeapon( "aug" );
	addWeapon( "g3" );
	addWeapon( "acr" );
	addWeapon( "m14" );
	addWeapon( "fad" );
	
	// Light Machine Guns
	addWeapon( "saw" );
	addWeapon( "m60e4" );
	
	// Shotguns
	addWeapon( "winchester1200" );
	addWeapon( "m1014" );
	addWeapon( "aa12_xmag" );
	
	// Sniper
	addWeapon( "m40a3_acog" );
	addWeapon( "m21" );
	addWeapon( "remington700_acog" );
	addWeapon( "barrett" );
	
	// Special
	addWeapon( "crossbow" );
	addWeapon( "rpg" );
	addWeapon( "knife" );
	
	// Wonderweapons
	addWeapon( "raygun" );
	addWeapon( "tesla" );
	addWeapon( "minigun" );
	
	// Grenades
	//addWeapon( "frag_grenade" );
	
/*=======================================================================================
NOTE
Delete anything then the following part if you want ALL weapons in the treasure chest.
Then remove the slashes (//) in front of each line!
=======================================================================================*/

//	weapons = 92;

//	for( i=0; i<=weapons; i++ )
//	{
//		weapon = tableLookup( "mp/weapon_key.csv", 0, i, 2 );
//		
//		if( isDefined(weapon) && weapon != "" )
//			addWeapon(weapon);
//	}
}

/*=======================================================================================
NOTE
DO NOT CHANGE THIS FUNCTION!
=======================================================================================*/
addWeapon( weapon )
{
	level.treasureWeapons[level.treasureWeapons.size] = weapon;
}