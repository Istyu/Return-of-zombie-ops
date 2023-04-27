/*=======================================================================================
Return of the Zombie Ops - Mod
Modded by Lefti & 3aGl3
=========================================================================================
Warlord Perk script
=======================================================================================*/
#include scripts\_utility;

init()
{
	level._effect["expBullet_hit"] = loadFx( "explosions/exp_ammo_impact" );
}

main( perk )
{
	self endon( "disconnect" );
	self endon( "death" );
	
	self notify( "activePerkWaiter2_start" );
	self endon( "activePerkWaiter2_start" );
	
	self _setActionSlot( 6, "specialammo", "specialty_explosivedamage" );
	self.ammoCooldown = undefined;
	self.explodingBullets = false;		// we currently firing explosive bullets?
	self.explosiveBullets = 0;			// how many bullets are left
	
	for(;;)
	{
		self waittill( "toggle_dpad6" );
		
		if( isDefined(self.ammoCooldown) )
		{
			self iPrintLnBold( &"ZMB_ABILITY_ON_COOLDOWN" );
		}
		else
		{
			self thread doExplosiveClip( perk );
		}
	}
}

doExplosiveClip( perk )
{
	self endon( "disconnect" );
	self endon( "death" );
	
	self.ammoCooldown = true;
	self.explodingBullets = true;
	
	weapon = self getCurrentWeapon();
	self.explosiveBullets = weaponClipSize( weapon );
	if( self getammocount(weapon) != self.explosiveBullets )
	{
		self execClientCmd( "+reload" );
		wait .05;
		self execClientCmd( "-reload" );
	}
	
	if( self.explosiveBullets > 50 )
		self.explosiveBullets = 50;
	
	self thread pauseBulletsWeaponswitch( weapon );
	
	for(;;)
	{
		self waittill( "weapon_fired" ); 
		
		if( self.explodingBullets )
		{
			vec = anglestoforward(self getPlayerAngles()); 
			end = (vec[0] * 200000, vec[1] * 200000, vec[2] * 200000); 
			SPLOSIONlocation = BulletTrace( self getEyeOrigin(), self getEyeOrigin()+end, 0, self)[ "position" ];
			
			playfx( level._effect["expBullet_hit"], SPLOSIONlocation );
			RadiusDamage( SPLOSIONlocation, 64, 500, 400, self );
			earthquake( 0.3, 1, SPLOSIONlocation, 100 );
			self.explosiveBullets--;
		}
		
		if( self.explosiveBullets <= 0 )
			break;
	}
	self notify( "stop_ebullet_tracking" );
	
	if( perk == "specialty_warlord" )
		self thread gotoCooldown( 240 );
	else
		self thread gotoCooldown( 120 );
}

gotoCooldown( time )
{
	wait time;
	
	if( isDefined(self) )
	{
		self.ammoCooldown = undefined;
		self iPrintLn( &"ZMB_ABILITY_N_READY", &"PERKS_WARLORD" );	
	}
}

pauseBulletsWeaponswitch( weapon )
{
	self endon( "disconnect" );
	self endon( "death" );
	self endon( "stop_ebullet_tracking" );
	
	for(;;)
	{
		self waittill( "weapon_change" );
		currentWeapon = self getCurrentWeapon();
		
		if( currentWeapon != weapon )
			self.explodingBullets = false;
		else if( currentWeapon == weapon )
			self.explodingBullets = true;
	}
}