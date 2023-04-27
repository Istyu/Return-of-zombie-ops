/*=======================================================================================
return of the zombie ops - mod
developed by Lefti, 3aGl3 & ParadoX
=========================================================================================
sticky weapons script
=======================================================================================*/
#include scripts\_weapon_key;

init()
{
	level._effect["explode_sticky"] = loadFx( "explosions/grenadeexp_default" );
	level.playerExpSound = "grenade_explode_default";
	
	level.semtex_explosion_delay = 2;
	level.bolt_explosion_delay = 2;
	
	thread onPlayerConnect();
}

onPlayerConnect()
{
	for(;;)
	{
		level waittill( "connected", player );
		player thread onPlayerSpawned();
	}
}
onPlayerSpawned()
{
	self endon("disconnect");

	for(;;)
	{
		self waittill( "spawned_player" );
		
		self thread watch_semtex_usage();
		self thread watch_exbolt_usage();
	}
}

watch_semtex_usage()
{
	self endon( "disconnect" );
	self endon( "killed_player" );
	
	for(;;)
	{
		self waittill( "grenade_fire", grenade, weaponName );
		
		if( getScriptName( weaponName ) == "frag_grenade_short" )
			self thread semtex_wait();
	}
}
watch_exbolt_usage()
{
	self endon( "disconnect" );
	self endon( "killed_player" );
	
	for(;;)
	{
		self waittill( "begin_firing" );
		
		if( self _getCurrentWeapon() == "crossbow_explosive" )
			self thread exbolt_wait();
	}
}

semtex_wait()
{
	self endon( "disconnect" );
	self endon( "semtex_explode" );
	
	wait level.semtex_explosion_delay;
	
	self notify( "semtex_explode" );
}
exbolt_wait()
{
	self endon( "disconnect" );
	self endon( "bolt_explode" );
	
	wait level.bolt_explosion_delay;
	
	self notify( "bolt_explode" );
}

semtex_explosion( attacker )
{
	self endon( "disconnect" );
	attacker endon( "disconnect" );
	
	attacker waittill( "semtex_explode" );
	
	self playSound( level.playerExpSound );
	playFx( level._effect["explode_sticky"], self.origin );
	
	phyExpMagnitude = 2; 

	// Modify these values if you have changed your nade properties. 
	minDamage = 55; // keep the min damage the same as a real nade. 
	maxDamage = 200; // keep the max damage the same as a real nade. 
	blastRadius = 256; // keep the radius the same as a real nade. 
	
	// do not pass damage owner if they have disconnected before the nade explodes 
	if ( !isdefined(attacker) ) 
		radiusDamage( self.origin+(0,0,30), blastRadius, maxDamage, minDamage ); 
	else 
		radiusDamage( self.origin+(0,0,30), blastRadius, maxDamage, minDamage, attacker ); 

	physicsExplosionSphere( self.origin + (0,0,30), blastRadius, blastRadius/2, phyExpMagnitude ); 
	self maps\mp\gametypes\_shellshock::grenade_earthQuake(); // do a nade earthquake 
}
bolt_explosion( attacker )
{
	self endon( "disconnect" );
	attacker endon( "disconnect" );
	
	attacker waittill( "bolt_explode" );
	
	self playsound( level.playerExpSound );
	playFx( level._effect["explode_sticky"], self.origin );
	
	phyExpMagnitude = 2; 

	// Modify these values if you have changed your nade properties. 
	minDamage = 40; // keep the min damage the same as a real nade. 
	maxDamage = 120; // keep the max damage the same as a real nade. 
	blastRadius = 256; // keep the radius the same as a real nade. 
	
	// do not pass damage owner if they have disconnected before the nade explodes 
	if ( !isdefined(attacker) ) 
		radiusDamage( self.origin+(0,0,30), blastRadius, maxDamage, minDamage ); 
	else 
		radiusDamage( self.origin+(0,0,30), blastRadius, maxDamage, minDamage, attacker ); 

	physicsExplosionSphere( self.origin + (0,0,30), blastRadius, blastRadius/2, phyExpMagnitude ); 
	self maps\mp\gametypes\_shellshock::grenade_earthQuake(); // do a nade earthquake 
}