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
BO Treasure Chest
=======================================================================================*/
#include scripts\_utility;
#include scripts\_weapon_key;

init()
{
	precacheString( &"MPUI_PRESS_USE_TO_ROLL_WEAPON" );
	
	level.treasureChestCost	= xDvarInt( "scr_shop_cost_treasure", 750 );	// defines the cost for treasure box
	
	level.treasureWeapons = [];
	scripts\level\_treasure_weapons::loadWeapons();
}

addTreasureChest( origin, trigger, offset )
{
	if( trigger.classname == "trigger_radius" )
		trigger thread fakeHintString( &"MPUI_PRESS_USE_TO_ROLL_WEAPON", level.treasureChestCost );
	else
		trigger setHintString( &"MPUI_PRESS_USE_TO_ROLL_WEAPON", level.treasureChestCost );
	
	trigger treasureThink( origin, offset );
}

treasureThink( origin, offset )
{
	movetime = 5;
	lifetime = 15;
	
	for(;;)
	{
		self waittill( "trigger", user );
		
		if( !isPlayer(user) )
			continue;
			
		if( user.pers["team"] != "allies" )
			continue;
			
		if( user usebuttonpressed() )
		{
			if( user.points >= level.treasureChestCost )
			{
				if( !isDefined(user.treasureContent) || user.treasureContent == "" )
				{
					self playSoundToPlayer( "treasure_chest_sound", user );
					user.treasureContent = level.treasureWeapons[randomInt(level.treasureWeapons.size)];
					
					if( isDefined(user.treasureModel) )
						user.treasureModel delete();
					
					user.treasureModel = spawn( "script_model", origin+offset );
					user.treasureModel hide();
					user.treasureModel setModel( _getWeaponModel(user.treasureContent) );
					user.treasureModel showToPlayer( user );
					user moveAndChange( movetime, user.treasureContent );
					user thread resetTreasureAfterTime( lifetime );
				}
				else
				{
					if( user _hasWeapon(user.treasureContent) && user.points >= level.treasureChestCost )
					{
						user _giveMaxAmmo( user.treasureContent );
						user scripts\player\_points::takePoints( level.treasureChestCost );
												
						user notify( "treasure_chest_bought" );
						user.treasureContent = undefined;
						if( isDefined(user.treasureModel) )
							user.treasureModel delete();
					}
					else if( user _hasWeapon(user.treasureContent) == false && user.points >= level.treasureChestCost )
					{
						if( _weaponInventoryType(user.treasureContent) == "primary" )
						{
							if( user primaryCount() >= 2 )
								user takeWeapon( user getCurrentWeapon() );
							
							user _giveWeapon( user.treasureContent );
							user _switchToWeapon( user.treasureContent );
						}
						else
						{
							user _giveWeapon( user.treasureContent );
						}
						
						user scripts\player\_points::takePoints( level.treasureChestCost );
						
						user notify( "treasure_chest_bought" );
						user.treasureContent = undefined;
						if( isDefined(user.treasureModel) )
							user.treasureModel delete();
					}
					else
					{
						user iPrintLn( &"ZMB_NOT_ENOUGH_POINTS_N", level.treasureChestCost );
					}
				}
			}
			else
			{
				user iPrintLn( &"ZMB_NOT_ENOUGH_POINTS_N", level.treasureChestCost );
			}
			wait 0.5;		// Release time, needed ba radius triggers
		}
	}
}

moveAndChange( movetime, final )
{
	self endon( "treasure_chest_bought" );
	self.treasureModel moveTo( self.treasureModel.origin+(0,0,30), movetime, movetime/100, movetime/2 );
	
	for( i=0; i<=(movetime*2); i++ )
	{
		wait 0.5;
		
		self.treasureContent = level.treasureWeapons[randomInt(level.treasureWeapons.size)];
		self.treasureModel setModel( _getWeaponModel(self.treasureContent) );
	}
}

resetTreasureAfterTime( time )
{
	self endon( "treasure_chest_bought" );
	wait time;
	
	self.treasureContent = "";
	if( isDefined(self.treasureModel) )
		self.treasureModel delete();
}