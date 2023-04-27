/*=======================================================================================
Return of the Zombie Ops - Mod
Modded by Lefti & 3aGl3
=========================================================================================
Ghost Perk script
=======================================================================================*/
#include scripts\_utility;

init()
{
	precacheString( &"ZMB_CLOAK_ACTIVE" );
	precacheString( &"ZMB_CLOAK_INACTIVE" );
}

main( perk )
{
	self.cloak = 0;
	
	thread cloak_think();
	thread disable_move();
	thread disable_shoot();
	thread disable_grenade();
}

cloak_think()
{
	self endon( "disconnect" );
	self endon( "killed_player" );
	
	for(;;)
	{
		self.cloak++;
		//iprintln( self.cloak );
		if( self.cloak >= 5 )		// number in seconds cloak needs to activate
		{
			self iPrintLnBold( &"ZMB_CLOAK_ACTIVE" );		// show player he's cloaked
			self.isTargetable = false;		// make him invisible for zombies
			
			self waittill( "remove_cloak" );
			
			self iPrintLnBold( &"ZMB_CLOAK_INACTIVE" );		// show the player he's uncloaked
			self.isTargetable = true;		// make him visible for zombies
		}
		
		wait 1;
	}
}

// watch movement and stance of the player
disable_move()
{
	self endon( "disconnect" );
	self endon( "killed_player" );
	
	oldOrigin = self.origin;
	for(;;)
	{
		wait .5;
		if( oldOrigin != self.origin )
		{
			self notify( "remove_cloak" );
			self.cloak = 0;
			oldOrigin = self.origin;
		}
		else if( self getStance() != "prone" || self meleeButtonPressed() )
		{
			self notify( "remove_cloak" );
			self.cloak = 0;
		}
	}
}

// watch shooting
disable_shoot()
{
	self endon( "disconnect" );
	self endon( "killed_player" );
	
	for(;;)
	{
		self waittill( "begin_firing" );
		self disableCloakWhileFire();
	}
}
disableCloakWhileFire()
{
	self endon( "end_firing" );
	
	for(;;)
	{
		self notify( "remove_cloak" );
		self.cloak = 0;
		wait .5;
	}
}

disable_grenade()
{
	self endon( "disconnect" );
	self endon( "killed_player" );
	
	for(;;)
	{
		self waittill( "grenade_fire" );
				
		self notify( "remove_cloak" );
		self.cloak = 0;
	}
}