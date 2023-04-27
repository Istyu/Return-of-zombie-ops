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
MW3 Equipment Armory
=======================================================================================*/
#include scripts\_utility;

init()
{
	precacheString( &"MPUI_PRESS_USE_TO_BUY_UPGRADES" );
	
	level.eShopCost["grenade"]	= xDvarInt( "scr_shop_cost_grenade", 750, 75 );
	level.eShopCost["sgrenade"]	= xDvarInt( "scr_shop_cost_sgrenade", 1000, 100 );
	level.eShopCost["perks"]	= xDvarInt( "scr_shop_cost_perks", 2500, 100 );
	level.eShopCost["c4"]		= xDvarInt( "scr_shop_cost_c4",	1500, 150 );
	level.eShopCost["claymore"]	= xDvarInt( "scr_shop_cost_claymore", 1000 );
	level.eShopCost["gl"]		= xDvarInt( "scr_shop_cost_ex41", 3000, 300 );
	level.eShopCost["rpg"]		= xDvarInt( "scr_shop_cost_rpg", 2000, 200 );
	level.eShopCost["supply"]	= xDvarInt( "scr_shop_cost_carepackage", 3000, 300 );
	level.eShopCost["sentry"]	= xDvarInt( "scr_shop_cost_sentry", 3000, 300 );
	level.eShopCost["mk19"]		= xDvarInt( "scr_shop_cost_mk19", 4000, 400 );
	
	thread onPlayerConnect();																				// ToDo: Unsure if this is called twice!
}

onPlayerConnect()
{
	for(;;)
	{
		level waittill( "connected", player );
		
		player setClientDvars( 	"scr_shop_cost_grenade", level.eShopCost["grenade"],
								"scr_shop_cost_sgrenade", level.eShopCost["sgrenade"],
								"scr_shop_cost_perks", level.eShopCost["perks"],
								"scr_shop_cost_c4", level.eShopCost["c4"],
								"scr_shop_cost_claymore", level.eShopCost["claymore"],
								"scr_shop_cost_ex41", level.eShopCost["gl"],
								"scr_shop_cost_rpg", level.eShopCost["rpg"],
								"scr_shop_cost_carepackage", level.eShopCost["supply"],
								"scr_shop_cost_sentry", level.eShopCost["sentry"],
								"scr_shop_cost_mk19", level.eShopCost["mk19"] );
	}
}

addArmory( origin, trigger )
{
	level endon( "game_ended" );
	
	//printLn( "Creating equipment armory at "+origin );
	
	if( trigger.classname == "trigger_use" || trigger.classname == "trigger_use_touch" )
		trigger setHintString( &"MPUI_PRESS_USE_TO_BUY_UPGRADES" );
	else
		trigger thread fakeHintString( &"MPUI_PRESS_USE_TO_BUY_UPGRADES" );
	
	for(;;)
	{
		trigger waittill( "trigger", user );
		
		if( !isPlayer(user) )
			continue;
		
		if( user.pers["team"] == "allies" )
		{
			if( user usebuttonpressed() )
			{
				user openMenu( game["menu_addonshop"] );
				
				wait .5;
			}
		}
	}
}