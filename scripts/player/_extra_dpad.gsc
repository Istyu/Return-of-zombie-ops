/*=======================================================================================
Return of the Zombie Ops - Mod
Modded by Lefti & 3aGl3
=========================================================================================
Player init
=======================================================================================*/
#include scripts\_utility;
#include scripts\_weapon_key;

init()
{
	level.laserUsage = xDvarInt( "scr_weapon_laser", 1, 0, 2 );			//0 - no laser at all, 1 - allow laser for special weapons, 2 - allow laser for all weapons
	
	thread onPlayerConnect();
}

onPlayerConnect()
{
	for(;;)
	{
		level waittill( "connected", player );
		
		//player execClientCmd( "exec custombuttons" );
		//player openMenu( game["menu_team"] );														// The exec closes the menu but this is not the very best way
		
		player.xDpadKey[0] = "8";
		player.xDpadKey[1] = "9";
		player.xDpadKey[2] = "0";
		
		player thread onPlayerSpawned();
	}
}

onPlayerSpawned()
{
	self endon("disconnect");
	
	for(;;)
	{
		self waittill( "spawned_player" );
		
	//	self unsetActionSlot( 5 );
	//	self unsetActionSlot( 6 );
	//	self unsetActionSlot( 7 );
		
		if( self.pers["team"] != "allies" )
			return;
		
		self thread monitorButtons();
		
		self thread laserWeaponWaiter();
	}
}

monitorButtons()
{
	self endon("disconnect");
	self endon( "death" );

	for(;;)
	{
		self waittill( "menuresponse", menu, response );
	
		if( response == "dp5button" )
			self notify( "toggle_dpad5" );
		
		if( response == "dp6button" )
			self notify( "toggle_dpad6" );
		
		if( response == "dp7button" )
			self notify( "toggle_dpad7" );
	}
}

laserWeaponWaiter()
{
	self endon( "death" );
	self endon( "disconnect" );
	
	for(;;)
	{
		if( isLaserWeapon(self _getCurrentWeapon()) )
		{
			self _setActionSlot( 5, "laser" );
			self thread scripts\player\weapons\_laser::laserThink( self.xDpadKey[0] );
		}
		else
		{
			self unsetActionSlot( 5 );
			self scripts\player\weapons\_laser::disableLaser();
		}
		
		self waittill( "weapon_change" );
	}
}
