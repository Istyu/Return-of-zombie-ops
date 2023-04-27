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
MW3 Weapon Armory
=======================================================================================*/
#include scripts\_utility;

init()
{
	precacheString( &"MPUI_PRESS_USE_TO_BUY_WEAPONS" );
	
	level.wShopCost["ammo"]		= xDvarInt( "scr_shop_cost_ammo", 750 );
	level.wShopCost["pistol"]	= xDvarInt( "scr_shop_cost_pistol", 250 );
	level.wShopCost["mp"]		= xDvarInt( "scr_shop_cost_mp", 500 );
	level.wShopCost["smg"]		= xDvarInt( "scr_shop_cost_smg", 750 );
	level.wShopCost["shotgun"]	= xDvarInt( "scr_shop_cost_shotgun", 1000 );
	level.wShopCost["sniper"]	= xDvarInt( "scr_shop_cost_sniper", 2000 );
	level.wShopCost["assault"]	= xDvarInt( "scr_shop_cost_assault", 3000 );
	level.wShopCost["lmg"]		= xDvarInt( "scr_shop_cost_lmg", 4000 );
	level.wShopCost["special"]	= xDvarInt( "scr_shop_cost_special", 10000 );
	
	thread onPlayerConnect();
}

onPlayerConnect()
{
	for(;;)
	{
		level waittill( "connected", player );
		
		player setClientDvars( 	"ui_shop_cost_ammo", level.wShopCost["ammo"],
								"ui_shop_cost_pistol", level.wShopCost["pistol"],
								"ui_shop_cost_mp", level.wShopCost["mp"],
								"ui_shop_cost_smg", level.wShopCost["smg"],
								"ui_shop_cost_shotgun", level.wShopCost["shotgun"],
								"ui_shop_cost_sniper", level.wShopCost["sniper"],
								"ui_shop_cost_assault", level.wShopCost["assault"],
								"ui_shop_cost_lmg", level.wShopCost["lmg"] ,
								"ui_shop_cost_special", level.wShopCost["special"] );
	}
}

addArmory( origin, trigger )
{
	printLn( "Creating weapon armory at "+origin );
	
	if( trigger.classname == "trigger_use" || trigger.classname == "trigger_use_touch" )
		trigger setHintString( &"MPUI_PRESS_USE_TO_BUY_WEAPONS" );
	else
		trigger thread fakeHintString( &"MPUI_PRESS_USE_TO_BUY_WEAPONS" );
	
	for(;;)
	{
		trigger waittill( "trigger", user );
		
		if( !isPlayer(user) )
			continue;
		
		if( user.pers["team"] == "allies" )
		{
			if( user usebuttonpressed() )
			{
				user openMenu( game["menu_weaponshop"] );
				
				wait 2;
			}
		}
	}
}