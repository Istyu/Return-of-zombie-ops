/*=======================================================================================
Return of the Zombie Ops - Mod
Modded by Lefti & 3aGl3
=========================================================================================
Zombie functions
=======================================================================================*/
#include scripts\_utility;

setAnim( zAnim )
{
	if( !isDefined(zAnim) || (zAnim != "idle" &&  zAnim != "walk" &&  zAnim != "run" &&  zAnim != "attack") )
		zAnim = "idle";
	
	type = self.animation;
	
	self.speed = level.BotAnim[type][zAnim].speed;
	weapon = level.BotAnim[type][zAnim].weapon;
	
	self takeallweapons();
	self giveweapon( weapon );
	self setspawnweapon( weapon );
	self switchtoweapon( weapon );
}

animMovement()
{
	self.speed = 0;
	if( self.Rage >= 200 )
		self setAnim( "run" );
	else
		self setAnim( "walk" );

}

zombieMelee()
{
	self endon("disconnect");
	self endon("killed_player");
	
	wait .6;
	if( isalive(self))
	{
		self zombieDoDamage( level.zombieDamage );
		self zombieSound( self isDog(), "attack", 0 );
	}
	wait .6;
	
	self setAnim("idle");
}

zombieDoDamage( damage )
{
	level endon( "game_ended" );
	self endon( "disconnect" );
	self endon( "death" );
	
	players = getSurvivors();
	
	for( i=0; i<players.size; i++ )
	{
		if( distance( self.origin, players[i].origin ) > level.zombieAttackRange+8 )
			continue;
		
		ent = players[i];	
		
		if( isDefined(ent.team) && ent.team != self.team && (!isDefined(ent.isTargetable) || isDefined(ent.isTargetable) && ent.isTargetable) )
		{
			ent thread [[level.callbackPlayerDamage]]
			(
				self,						// eInflictor	-The entity that causes the damage.(e.g. a turret)
				self,						// eAttacker	-The entity that is attacking.
				damage,						// iDamage	-Integer specifying the amount of damage done
				0,							// iDFlags		-Integer specifying flags that are to be applied to the damage
				"MOD_RIFLE_BULLET",			// sMeansOfDeath	-Integer specifying the method of death
				"none",						// sWeapon	-The weapon number of the weapon used to inflict the damage
				ent.origin,					// vPoint		-The point the damage is from?
				(0,0,0),					// vDir		-The direction of the damage
				"none",						// sHitLoc	-The location of the hit
				0							// psOffsetTime	-The time offset for the damage
			);
		}
	}
	
	if( isDefined(level.barricades) && level.barricades.size >= 1 )
	{
		for( i=0; i<level.barricades.size; i++ )
		{
			if( self isTouching(level.barricades[i]) )
				level.barricades[i] notify( "damage", damage, self );
		}
	}
}

zombieSound( isDog, prefix, num )
{
	if( isDog )
		prefix = "dog_"+prefix;
	else
		prefix = "zom_"+prefix;
	
	self playSound( prefix+"_"+num );
}