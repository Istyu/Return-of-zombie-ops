#include scripts\_weapon_key;
#include maps\mp\_utility;
#include common_scripts\utility;
  
init()
{	
	precacheItem( "flamethrower_mp" );
	
	precacheShellshock( "flamethrower" );
	precacheShellshock( "fire" );
	
//	level.fire_medium_fx = loadFX( "custom/fire_medium_fx" );
//	level.fire_small_fx = loadFX( "custom/fire_small_fx" );
//	level.fire_player_fx = loadFX( "custom/fire_player_fx" );

	level.fire_medium_fx = loadFX( "fire/firelp_med_pm_nodistort" );
	level.fire_small_fx = loadFX( "fire/firelp_small_pm" );
	level.fire_player_fx = loadFX( "fire/firelp_vhc_med_pm_noDlight" );
	
	while( 1 )
	{
		level waittill( "connected", client );
		client thread main();
		client thread ammoMonitor();
	}
}

ammoMonitor()
{
	self endon( "disconnect" );
	level endon( "game_ended" );
	
	for(;;)
	{
		self waittill( "weapon_change" );
		
		if( self _getCurrentWeapon() == "flamethrower" )
			self setClientDvar( "ui_ammo_counter", 1 );
		else
			self setClientDvar( "ui_ammo_counter", 0 );
		
	}
}

main()
{
	self endon( "disconnect" );
	level endon( "game_ended" );
	
	self.isBurning = false;
	
	while( 1 )
	{
		self waittill ( "weapon_fired" );
			
		if( self.sessionstate != "playing" )
			continue;
			
		if( self attackButtonPressed() && self getCurrentWeapon() == "flamethrower_mp" && self getWeaponAmmoClip( "flamethrower_mp" ) > 0 )
		{
			self notify( "flamethrower_fire_start" );
			self thread flamethrower_start_sound();
			self thread flamethrower_loop_sound();
			self thread flamethrower_fire();
			self thread flamethrower_spawn_triggers();
			self thread flamethrower_ammo();
			self flamethrower_shellshock();
			self notify( "flamethrower_fire_end" );
			self thread flamethrower_end_sound();
		}
	}
}

flamethrower_start_sound()
{
	self playLocalSound( "weap_flamethrower_fire_start" );
}

flamethrower_loop_sound()
{
	self endon( "disconnect" );
	level endon( "game_ended" );
	self endon( "death" );
	
	wait( 0.50 );
	
	while( self attackButtonPressed() && self getCurrentWeapon() == "flamethrower_mp" && self getWeaponAmmoClip( "flamethrower_mp" ) > 0 )
	{
		self playLocalSound( "weap_flamethrower_fire_loop" );
		wait( 1.25 );
	}
}

flamethrower_end_sound()
{
	self playLocalSound( "weap_flamethrower_fire_end" );
}

flamethrower_shellshock()
{
	self endon( "disconnect" );
	level endon( "game_ended" );
	self endon( "death" );
	
	while( self attackButtonPressed() && self getCurrentWeapon() == "flamethrower_mp" && self getWeaponAmmoClip( "flamethrower_mp" ) > 0 )
	{
		self shellshock( "flamethrower", 0.25 );
		wait( 0.05 );
	}
}

flamethrower_ammo()
{
	self endon( "disconnect" );
	level endon( "game_ended" );
	self endon( "death" );
	
	while( self attackButtonPressed() && self getCurrentWeapon() == "flamethrower_mp" && self getWeaponAmmoClip( "flamethrower_mp" ) > 0 )
	{
		self setWeaponAmmoClip( "flamethrower_mp", 999 );
		wait( 0.05 );
	}
}

flamethrower_fire()
{
	self endon( "disconnect" );
	level endon( "game_ended" );
	self endon( "death" );
	
	while( self attackButtonPressed() && self getCurrentWeapon() == "flamethrower_mp" && self getWeaponAmmoClip( "flamethrower_mp" ) > 0 )
	{	
		org_ = flamethrower_fire_orgs();
		
		if( !org_.size )
		{
			iPrintLn( "^1Error: flamethrower_fire_orgs.size < 1, report this to Bear." );
			return;
		}
		
		switch( randomInt( 4 ) )
		{
			case 0:			
				int = randomInt( org_.size );
				
				fx = spawn( "script_origin", org_[ int ]  + ( randomInt( 10 ), randomInt( 10 ), 0 ) );
				if( bulletTracePassed( org_[ int ] + ( 5, 0, 0 ), org_[ int ], false, fx )
				&& bulletTracePassed( org_[ int ]  - ( 5, 0, 0 ), org_[ int ], false, fx )
				&& bulletTracePassed( org_[ int ]  + ( 0, 5, 0 ), org_[ int ], false, fx )
				&& bulletTracePassed( org_[ int ]  - ( 0, 5, 0 ), org_[ int ], false, fx ) )
					fx.origin = bulletTrace( fx.origin, fx.origin - ( 0, 0, 999999 ), false, fx )["position"];
					
				if( randomInt(1) == 1 )
					playFX( level.fire_medium_fx, fx.origin );
				else
					playFX( level.fire_small_fx, fx.origin );
					
				if( isDefined( fx ) )
					fx delete();
				
			default:
				break;
		}
			
		wait( 0.05 );
	}
}

flamethrower_fire_orgs()
{
	org_ = [];
	
	org_[ org_.size ] = getPos( self getEye(), self getPlayerAngles(), "forwards", 600 );
	org_[ org_.size ] = getPos( self getEye(), self getPlayerAngles(), "forwards", 500 );
	org_[ org_.size ] = getPos( self getEye(), self getPlayerAngles(), "forwards", 400 );
	org_[ org_.size ] = getPos( self getEye(), self getPlayerAngles(), "forwards", 300 );
	org_[ org_.size ] = getPos( self getEye(), self getPlayerAngles(), "forwards", 200 );
	org_[ org_.size ] = getPos( self getEye(), self getPlayerAngles(), "forwards", 100 );
	
	return org_;
}

flamethrower_spawn_triggers()
{
	org_ = flamethrower_fire_orgs();
	
	if( !org_.size )
	{
		iPrintLn( "^1Error: flamethrower_fire_orgs.size < 1, report this to Bear." );
		return;
	}
	
	self.triggers = [];
	
	for( i = 0; i < org_.size; i++ )
	{
		self.triggers[ self.triggers.size ] = spawn( "trigger_radius", org_[ i ] - ( 0, 0, 25 ), 0, 50, 50 );
		self.triggers[ i ].owner = self;
		self.triggers[ i ] thread flamethrower_fire_damage();
	}
	
	self flamethrower_trigger_move();
	
	for( i = 0; i < self.triggers.size; i++ )
	{
		if( isDefined( self.triggers[ i ] ) )
			self.triggers[ i ] delete();
	}
}

flamethrower_fire_damage()
{
	level endon( "game_ended" );
	self endon( "death" );
	
	while( isDefined( self ) )
	{
		self waittill( "trigger", player );
		
		if( isDefined( player.pers["team"] ) && isDefined( self.owner.pers["team"] ) && player.pers["team"] == self.owner.pers["team"] )
			continue;
		
		player thread fire_fx( self.owner, self.origin );
		
		if( isAlive( player ) && player isVisibleFrom( self.owner getEye() ) )
			player dmgPlayer( self.owner, self.owner, 25, "MOD_PISTOL_BULLET", "flamethrower_mp", self.origin, self.origin );
		
		wait( 0.33 );
	}
}

flamethrower_trigger_move()
{
	self endon( "disconnect" );
	level endon( "game_ended" );
	self endon( "death" );
	
	while( self attackButtonPressed() && self getCurrentWeapon() == "flamethrower_mp" && self getWeaponAmmoClip( "flamethrower_mp" ) > 0 )
	{
		org_ = flamethrower_fire_orgs();
	
		if( !org_.size )
		{
			iPrintLn( "^1Error: flamethrowe_fire_orgs.size < 1, report this to Bear." );
			continue;
		}
		
		for( i = 0; i < self.triggers.size; i++ )
			self.triggers[ i ].origin = ( flamethrower_fire_orgs()[ i ] );
		
		wait( 0.05 );
	}
}

fire_fx( attacker, origin )
{
	self endon( "disconnect" );
	level endon( "game_ended" );
	self endon( "death" );
	
	if( self.isBurning )
		return;
		
	self.isBurning = true;
	
	tags = fire_tags();
	
	if( !tags.size )
	{
		iPrintLn( "^1Error: fire_tags.size < 1, report this to Bear." );
		return;
	}
	
	for( i = 0; i < 5; i++ )
	{
		x = randomInt( tags.size );
		wait( 0.05 );
		playFXOnTag( level.fire_player_fx, self, tags[ x ] );
	}
	
	for( i = 0; i < 5; i++ )
	{
		if( isAlive( self ) )
		{
			self dmgPlayer( attacker, attacker, 5, "MOD_PISTOL_BULLET", "flamethrower_mp", origin, origin );
			self shellshock( "fire", 1 );
		}
		wait( 1.00 );
	}
	
	self.isBurning = false;
}

fire_tags()
{
	tags = [];
	tags[ tags.size ] = "j_wristtwist_ri";
	tags[ tags.size ] = "j_wristtwist_le";
	tags[ tags.size ] = "j_elbow_bulge_ri";
	tags[ tags.size ] = "j_elbow_bulge_le";
	tags[ tags.size ] = "j_shoulder_ri";
	tags[ tags.size ] = "j_shoulder_le";
	tags[ tags.size ] = "j_spineupper";
	tags[ tags.size ] = "j_ankle_ri";
	tags[ tags.size ] = "j_ankle_le";
	tags[ tags.size ] = "j_knee_ri";
	tags[ tags.size ] = "j_knee_le";
	tags[ tags.size ] = "j_hiptwist_ri";
	tags[ tags.size ] = "j_hiptwist_le";
	tags[ tags.size ] = "j_spinelower";
	return tags;
}

// FROM _UTILITY.GSC ...

getPos( org, ang, dir, dist )
{
	if( dir == "forwards" )
		x = dist;
	else
	if( dir == "backwards" )
		x = ( dist - ( dist *2 ) );
	else
		return ( 0, 0, 0 );
		
	trace = bulletTrace( org, org + vector_scale( anglesToForward( ang ), x ), false, undefined );
	ent = trace["entity"];
	pos = trace["position"];
	return pos;
}

dmgPlayer( eInflictor, eAttacker, iDamage, sMeansOfDeath, sWeapon, damagepos, damagedir )
{
	self.damageOrigin = damagepos;
	self thread [[level.callbackPlayerDamage]](
		eInflictor, // eInflictor The entity that causes the damage.(e.g. a turret)
		eAttacker, // eAttacker The entity that is attacking.
		iDamage, // iDamage Integer specifying the amount of damage done
		0, // iDFlags Integer specifying flags that are to be applied to the damage
		sMeansOfDeath, // sMeansOfDeath Integer specifying the method of death
		sWeapon, // sWeapon The weapon number of the weapon used to inflict the damage
		damagepos, // vPoint The point the damage is from?
		damagedir, // vDir The direction of the damage
		"none", // sHitLoc The location of the hit
		0 // psOffsetTime The time offset for the damage
	);
}

isVisibleFrom( org )
{
	if( sightTracePassed( org , self.origin + ( 0, 0, 50 ), false, undefined ) )
		return true;
	else
		return false;
}