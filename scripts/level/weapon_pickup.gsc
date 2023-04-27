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
BO Weapon Pickup
=======================================================================================*/
#include scripts\_utility;
#include scripts\_weapon_key;

init()
{
	precacheString( &"MPUI_PRESS_USE_TO_BUY_WEAPON" );			// Press ^3[USE]^7 to buy &&1 [Cost: &&2]
	precacheString( &"MPUI_PRESS_USE_TO_BUY_WEAPON2" );			// Press ^3[USE]^7 Weapon[&&1], Ammo[&&2]
	precacheString( &"MPUI_PRESS_USE_TO_BUY_WEAPON3" );			// Press ^3[{+activate}]^7 to buy Weapon[&&1]	-	used for oldschool pickups

	SetDvarMinMax( "scr_pickup_oldschool", 0, 0, 1 );		// use oldschool pickups as weapon pickups?

	level.defaultPickupCost = xDvarInt( "scr_pickup_cost", 500, 1 );
	level.applyRandomCamo = xDvarBool( "scr_pickup_camo", 1 );
	level.weaponPickups = [];

	if( getEntArray("oldschool_pickup", "targetname").size )
		thread buildPickupsFromOldschool();
}

buildPickupsFromOldschool()
{
	pickups = getEntArray( "oldschool_pickup", "targetname" );

	if( getDvarInt("scr_pickup_type") == 0 || getDvarInt("scr_pickup_oldschool") == 0 || level.gametype == "arena" )
	{
		for( i=0; i<pickups.size; i++ )
		{
			pickup = pickups[i];

			if( isDefined(pickup.target) )
			{
				trig = pickup scripts\level\_levelsetup::getClosestEntity( pickup.target );
				trig delete();
			}
			pickup delete();
		}

		return;
	}

	for( i=0; i<pickups.size; i++ )
	{
		pickup = pickups[i];

		if( pickup.classname == "script_model" )		// a perk pickup
		{
			trig = pickup scripts\level\_levelsetup::getClosestEntity( pickup.target );
			trig delete();
			pickup delete();
		}
		else
		{
			ID = level.weaponPickups.size;
			level.weaponPickups[ID] = spawnstruct();
			level.weaponPickups[ID] thread createOldschoolPickup( pickup );
		}
	}
}

createOldschoolPickup( weapon )
{
	level endon( "game_ended" );

	self.origin = weapon.origin;
	self.angles = weapon.angles;
	self.weapon = strTok( weapon.classname, "_" )[1];
	if( level.applyRandomCamo )
		self.camo = randomInt( 7 );
	else
		self.camo = 0;

	self.trigger = spawn( "trigger_radius", self.origin, 0, 16, 16 );
	self.trigger thread fakeHintString( &"MPUI_PRESS_USE_TO_BUY_WEAPON3", level.defaultPickupCost, "allies" );

	self.visible = spawn( "script_model", self.origin );
	self.visible setModel( _getWeaponModel( self.weapon ), self.camo );
	//self.visible thread rotateModel();
	//self.visible thread bounceModel();

	if( isDefined(weapon) )
		weapon delete();

	for(;;)
	{
		self.trigger waittill( "trigger", user );

		if( !isplayer(user) || user.team == "axis" )
			continue;


	}
}

createWeaponPickup()
{
	//self.script_noteworthy = weapon script name
	//self.script_threshold = money

	self.weapon = self.script_noteworthy;
	self.wcost = int(self.script_threshold);
	self.acost = int(self.script_threshold/2);
	self.visual = getEnt( self.target, "targetname" );
	self.visual hide();

	if( isSubStr( self.weapon, "grenade" ) )
		weaponname = tableLookupIString( "mp/statsTable.csv", 4, self.weapon, 3 );
	else
		weaponname = tableLookupIString( "mp/statsTable.csv", 4, strTok(self.weapon, "_")[0], 3 );
	self setHintString( &"MPUI_PRESS_USE_TO_BUY_WEAPON", weaponname, self.wcost );
	self thread weapon_think();
}

weapon_think()
{
	bought = false;

	for(;;)
	{
		self waittill( "trigger", user );

		if( !isDefined(user) || !isPlayer(user) || !isReallyAlive(user) || !isDefined(user.team) || user.team != "allies" )
			continue;

		if( user _hasWeapon(self.weapon) )
		{
			if( user.points >= self.acost )
			{
				if( !bought )
				{
					self.visual show();
					self setHintString( &"MPUI_PRESS_USE_TO_BUY_WEAPON2", self.wcost, self.acost );
				}

				user _giveMaxAmmo(self.weapon);
				user scripts\player\_points::takePoints( self.acost );
			}
			else
				user iPrintLn( &"ZMB_NOT_ENOUGH_POINTS_N", self.acost );
		}
		else
		{
			if( user.points >= self.wcost )
			{
				if( !bought )
				{
					self.visual show();
					self setHintString( &"MPUI_PRESS_USE_TO_BUY_WEAPON2", self.wcost, self.acost );
				}

				if( user primaryCount() >= 2 )
					user takeWeapon( user getCurrentWeapon() );

				user _giveWeapon( self.weapon );
				user _switchToWeapon( self.weapon );

				user scripts\player\_points::takePoints( self.wcost );
			}
			else
				user iPrintLn( &"ZMB_NOT_ENOUGH_POINTS_N", self.wcost );
		}
	}
}