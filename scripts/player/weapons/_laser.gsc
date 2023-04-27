/*=======================================================================================
Return of the Zombie Ops - Mod
Modded by Lefti & 3aGl3
=========================================================================================
Player init
=======================================================================================*/
#include scripts\_utility;
#include scripts\_weapon_key;

laserThink( key )
{
	self endon( "disconnect" );
	self endon( "death" );
	self endon( "weapon_change" );
	
	laserOn = false;
	
	for(;;)
	{
		self waittill( "toggle_dpad5" );
		if( laserOn )
		{
			self disableLaser();
			laserOn = false;
		}
		else
		{
			self enableLaser();
			laserOn = true;
		}
		
		wait .5;
	}
}

disableLaser()
{
	self setClientDvar( "cg_LaserforceOn", 0 );
	self setClientDvar( "cg_drawCrosshair", 1 );
	self laserOff();
}

enableLaser()
{
	self setClientDvar( "cg_LaserforceOn", 1 );
	self setClientDvar( "cg_drawCrosshair", 0 );
	self laserOn();
}