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
Zombie Sentry Turrets
=======================================================================================*/
#include scripts\_utility;
#include maps\mp\_utility;

init()
{
	precacheString( &"ZMB_ARMORY_SENTRY" );
	precacheString( &"ZMB_ARMORY_MK19" );
	precacheString( &"ZMB_SENTRYGUN_PICKUP_HINT" );			// Press {USE} to pick up turret.
	precacheString( &"ZMB_SENTRYGUN_NO_SPACE_HINT" );		// Can't place turret here.
	precacheString( &"ZMB_ALREADY_N_OF_N_TURRETS" );		// You already got &&1 of &&2 turrets!
	precacheString( &"ZMB_SENTRYGUN_PLACE_HINT" );			// Press {Fire} to place turret, hold {ADS} to abort.
	
	level.sentryTurretModel = "weapon_sentry_turret";
	precacheModel( level.sentryTurretModel );
	
	level.sentryTurretTags[0] = "tag_bipod";
	level.sentryTurretTags[1] = "tag_swivel";
	level.sentryTurretTags[2] = "tag_gun";
	level.sentryTurretTags[3] = "tag_grenade";
	
	// global effects
	level._effect["turret_death"] = loadFx( "explosions/grenadeExp_metal" );
	level._effect["turret_spark"] = loadFx( "misc/rescuesaw_sparks" );
	level._effect["turret_heat"] = loadFx( "smoke/heli_engine_smolder" );
	
	level._effect["bturret_flash"] = loadFx( "muzzleflashes/minigun_flash_view" );
	level._effect["bturret_shell"] = loadFx( "misc/mw2_sentry_turret_shellEject" );
	level._effect["bturret_trace"] = loadFx( "misc/mw2_sentry_turret_tracer" );
	level._effect["bturret_impact"] = loadFx( "impacts/large_metalhit_1" );
	level._effect["bturret_hit"] = loadFx( "impacts/flesh_hit_body_fatal_exit" );
	
	level._effect["gturret_flash"] = level._effect["bturret_flash"];
	level._effect["gturret_shell"] = loadFx( "shellejects/m203" );
	level._effect["gturret_tail"] = loadFx( "smoke/smoke_geotrail_m203" );
	level._effect["gturret_impact"] = loadFx( "explosions/grenadeexp_default" );
	
	level._effect["lturret_flash"] = loadFx( "raygun/raygun_muzzle_w" );
	level._effect["lturret_tail"] = loadFx( "raygun/trail_raygun_geotrail" );
	level._effect["lturret_impact"] = loadFx( "raygun/raygun_impact" );
	
	level.sentryVanishType = xDvar( "scr_streak_sentry_vanish", "time" );		// 'time' or 'clip'
	
	level.turretSpeed = 60;
	level.sentryOverheat = xDvarInt( "scr_streak_sentry_overheat", 80, 0, 600 );
	level.sentryHealth = xDvarInt( "scr_streak_sentry_health", 500, 100, 1000 );
	level.maxTurrets = xDvarInt( "scr_streak_turrets_plr", 1, 1, 5 );
	level.maxTurretsAll = xDvarInt( "scr_streak_turrets_max", 10, 1, 25 );
	
	level.sentryClipSize = xDvarInt( "scr_streak_sentry_clip", 5000, 100, 999999 );		// used when vanishtype = 'clip' -> bullets to shoot before shutdown
	level.sentryLifetime = xDvarFloat( "scr_streak_sentry_time", 60, 30, 240 );				// used when vanishtype = 'time' -> time before shutdown
	
	level.sentryTurrets = [];
	
	//level.registerHardpoint//( name,			kills,	callThread,			title,					XP,	trigger,	icon,					sound )
	if( !isDefined(level.indoorMap) || level.indoorMap == false )
	{
		[[level.registerHardpoint]]( "sdrop_gun", xDvarInt( "scr_streak_bturret_kills", 50, 0 ), ::callSentryTurret, &"ZMB_ARMORY_SENTRY", "location_selector_mp", "hud_icon_sentry_gun" );
		[[level.registerHardpoint]]( "sdrop_ray", xDvarInt( "scr_streak_lturret_kills", 125, 0 ), ::callLaserTurret, &"ZMB_LASER_TURRET", "location_selector_mp", "hud_icon_sentry_gun" );
//		[[level.registerHardpoint]]( "sdrop_203", xDvarInt( "scr_streak_gturret_kills", 250, 0 ), ::callGrenadeTurret, &"ZMB_ARMORY_MK19", "location_selector_mp", "hud_icon_sentry_gun" );
		[[level.registerHardpoint]]( "sentry_gun", 0, ::tryPlaceSentryTurret, &"ZMB_ARMORY_SENTRY", "radar_mp", "hud_icon_sentry_gun" );
		[[level.registerHardpoint]]( "sentry_ray", 0, ::tryPlaceLaserTurret, &"ZMB_LASER_TURRET", "radar_mp", "hud_icon_sentry_gun" );
//		[[level.registerHardpoint]]( "sentry_203", 0, ::tryPlaceGrenadeTurret, &"ZMB_ARMORY_MK19", "radar_mp", "hud_icon_sentry_gun" );
	}
	else
	{
		[[level.registerHardpoint]]( "sentry_gun", xDvarInt( "scr_streak_bturret_kills", 50, 0 ), ::tryPlaceSentryTurret, &"ZMB_ARMORY_SENTRY", "radar_mp", "hud_icon_sentry_gun" );
		[[level.registerHardpoint]]( "sentry_ray", xDvarInt( "scr_streak_lturret_kills", 125, 0 ), ::tryPlaceLaserTurret, &"ZMB_LASER_TURRET", "radar_mp", "hud_icon_sentry_gun" );
//		[[level.registerHardpoint]]( "sentry_203", xDvarInt( "scr_streak_gturret_kills", 250, 0 ), ::tryPlaceGrenadeTurret, &"ZMB_ARMORY_MK19", "radar_mp", "hud_icon_sentry_gun" );
	}
}

callSentryTurret()
{
	return self scripts\player\hardpoints\_airdrop::setCarePackagePoint( "sentry_gun" );
}
callLaserTurret()
{
	return self scripts\player\hardpoints\_airdrop::setCarePackagePoint( "sentry_ray" );
}
callGrenadeTurret()
{
	return self scripts\player\hardpoints\_airdrop::setCarePackagePoint( "sentry_203" );
}

tryPlaceSentryTurret()
{
	if( isDefined(self.sentryTurrets) && self.sentryTurrets >= level.maxTurrets /*|| level.sentryTurrets.size >= level.maxTurretsAll*/ )
	{
		self iPrintLnBold( &"ZMB_ALREADY_N_OF_N_TURRETS", self.sentryTurrets, level.maxTurrets );
		return false;
	}
	
	return self tryPlaceTurret( "bturret" );
}

tryPlaceLaserTurret()
{
	if( isDefined(self.sentryTurrets) && self.sentryTurrets >= level.maxTurrets )
	{
		self iPrintLnBold( &"ZMB_ALREADY_N_OF_N_TURRETS", self.sentryTurrets, level.maxTurrets );
		return false;
	}
	
	return self tryPlaceTurret( "lturret" );
}

tryPlaceGrenadeTurret()
{
	if( isDefined(self.sentryTurrets) && self.sentryTurrets >= level.maxTurrets )
	{
		self iPrintLnBold( &"ZMB_ALREADY_N_OF_N_TURRETS", self.sentryTurrets, level.maxTurrets );
		return false;
	}
	
	return self tryPlaceTurret( "gturret" );
}

tryPlaceTurret( type )
{
	self disableWeapons( true );
	self iPrintLnBold( &"ZMB_SENTRYGUN_PLACE_HINT" );
	
	carry = spawn( "script_model", self.origin );
	carry setModel( level.sentryTurretModel );
	carry hidePartExpect( level.sentryTurretTags, "tag_bipod" );
	carry linkTo( self, "tag_origin", (50,0,0), (0,0,0) );
	carry.swivel = spawn( "script_model", carry.origin );
	carry.swivel setModel( level.sentryTurretModel );
	carry.swivel hidePartExpect( level.sentryTurretTags, "tag_swivel" );
	carry.swivel linkTo( carry, "j_swivel", (0,0,0), (0,0,0) );
	carry.gun = spawn( "script_model", carry.origin );
	carry.gun setModel( level.sentryTurretModel );
	if( type == "gturret" )
		carry.gun hidePartExpect( level.sentryTurretTags, "tag_grenade" );
	else
		carry.gun hidePartExpect( level.sentryTurretTags, "tag_gun" );
	carry.gun linkTo( carry, "j_gun", (0,0,0), (-90,0,0) );

	self thread deleteCarryOnLastStand( carry );
	
	for(;;)
	{
		if( isDefined(self) && self attackButtonPressed() )
		{
			sentryOrigin = bulletTrace( carry.origin+(0,0,16), carry.origin-(0,0,10000), false, carry )["position"];
			
			xFree = bulletTracePassed( sentryOrigin+(50,0,2), sentryOrigin+(-50,0,2), false, carry );
			yFree = bulletTracePassed( sentryOrigin+(0,50,2), sentryOrigin+(0,-50,2), false, carry );
			//zFree = bulletTracePassed( sentryOrigin, sentryOrigin+(0,0,64), false, carry );
			
			if( xFree && yFree /*&& zFree*/ )
			{
				carry deleteCarry();
				
				self placeTurret( sentryOrigin, type );
				self enableWeapons( true );
				return true;
			}
			else
			{
				self iPrintLnBold( &"ZMB_SENTRYGUN_NO_SPACE_HINT" );
				while( self attackButtonPressed() )
					wait 0.05;
			}
		}
		else if( isDefined(self) && self adsButtonPressed() )
		{
			carry deleteCarry();
			self enableWeapons( true );
			break;
		}
		
		if( !isDefined(self) || self.sessionstate != "playing" )
		{
			carry deleteCarry();
			self enableWeapons( true );
			break;
		}
		wait 0.05;
	}
	
	return false;
}
deleteCarryOnLastStand( carry )
{
	self endon( "death" );
	self endon( "disconnect" );
	
	self waittill( "second_chance_start" );
	
	carry deleteCarry();
}

deleteCarry()
{
	if( isDefined(self.swivel) )
	{
		self.swivel unlink();
		self.swivel delete();
	}
	
	if( isDefined(self.gun) )
	{
		self.gun unlink();
		self.gun delete();
	}
	
	self unlink();
	self delete();
}

placeTurret( origin, type )		// self = owner
{
	if( !isDefined(self.sentryTurrets) )
		self.sentryTurrets = 0;
	self.sentryTurrets++;
	
	sentry = spawnstruct();
	sentry.owner = self;
	sentry.maxhealth = 90000;
	sentry.health = sentry.maxhealth;
	sentry.team = self.team;
	sentry.type = type;
	sentry.isTargetable = true;
	sentry.idle = true;
	sentry.shooting = false;
	sentry.shoots = 0;
	sentry.target = undefined;
	sentry.bipod = spawn( "script_model", origin );
	sentry.bipod.angles = self.angles;
	sentry.bipod setModel( level.sentryTurretModel );
	sentry.bipod hidePartExpect( level.sentryTurretTags, "tag_bipod" );
	sentry.swivel = spawn( "script_model", sentry.bipod getTagOrigin("j_swivel") );
	sentry.swivel.angles = self.angles;
	sentry.swivel setModel( level.sentryTurretModel );
	sentry.swivel hidePartExpect( level.sentryTurretTags, "tag_swivel" );
	sentry.gun = spawn( "script_model", sentry.bipod getTagOrigin("j_gun") );
	sentry.gun.angles = self.angles;
	sentry.gun setModel( level.sentryTurretModel );
	if( sentry.type == "gturret" )
		sentry.gun hidePartExpect( level.sentryTurretTags, "tag_grenade" );
	else
		sentry.gun hidePartExpect( level.sentryTurretTags, "tag_gun" );
	
	level.sentryTurrets[level.sentryTurrets.size] = sentry;
	
//	sentry.gun rotatePitch( -90, 0.01 );
//	wait 0.02;
	sentry.gun playSound( "sentry_activate" );
//	sentry.gun rotatePitch( 90, 0.8 );
	wait 1;
	
	sentry thread turretIdle();
	sentry thread turretThink();
	sentry thread turretVanish();
	sentry thread turretDamage();
}

turretIdle()
{
	self endon( "turretShutdown" );
	self endon( "turretExplode" );
	
	for(;;)
	{
		while( self.idle )
		{
			degrees = randomIntRange(-360, 360);
			self turretRotate( degrees );
			
			wait 0.5+randomFloat( 2.0 );
		}
	}
}

turretThink()
{
	self endon( "turretShutdown" );
	self endon( "turretExplode" );
	
	// Scan for enemies in range
	setDvar("sentry_turret_range", "1000");
		
	self.trigger = spawn( "trigger_radius", self.bipod.origin, 0, getDvarInt("sentry_turret_range"), getDvarInt("sentry_turret_range")/5 );
	self.trigger.origin = ( self.bipod.origin-(0, 0, getDvarInt("sentry_turret_range")/10) );
	
	for(;;)
	{
		wait .05;
				
		if( !isDefined( self.trigger ) || !isDefined(self) )
			break;

		if( isDefined(self.target) || self.shooting )
			continue;

		eligibleTargets = [];
		p = getZombies();
		for(i = 0; i < p.size; i++)
		{
			if( p[i].model == "" )
				continue;

			if( p[i].sessionstate != "playing" )
				continue;

			if( p[i].health < 1 )
				continue;

			if( p[i].team == self.team )
				continue;

			if( p[i] isTouching(self.trigger) && SightTracePassed( self.gun getTagOrigin("tag_flash"), p[i] getTagOrigin("j_spine4"), false, self.gun ))
				eligibleTargets[eligibleTargets.size] = p[i];
		}
		if(!eligibleTargets.size)
			continue;

		target = eligibleTargets[randomInt(eligibleTargets.size)];
		self.target = target;
		self thread turretTarget();

		eligibleTargets = undefined;
	}
}

turretTarget()
{
	self endon( "turretShutdown" );
	self endon( "turretExplode" );
	
	if( self.shooting )
	{
		while(self.shooting)
			wait .5;
	}
	
	if( !isDefined(self.target) || (isDefined(self.target) && self.health < 1) )
	{
		self.target = undefined;
		return;
	}
	
	// aim toward target
	targetVec = vectorToAngles(self.target getTagOrigin("j_spine4") - self.gun.origin);
	self.hinge = spawn( "script_origin", self.bipod getTagOrigin("j_swivel") );
	self.hinge.angles = self.gun.angles;
	
	self.gun linkTo( self.hinge );
	wait .05;
	self.hinge rotateTo((targetVec[0], targetVec[1], self.gun.angles[2]), .5);
	self.swivel rotateTo((self.swivel.angles[0], targetVec[1], self.swivel.angles[2]), .5);
	wait .6;
	
	self.gun unlink();
	wait .05;
	self thread turretFire();
	wait .05;
	while(self.shooting)
		wait .5;
	
	self.gun linkTo(self.hinge);
	wait .05;
	self.hinge rotateTo((0, self.gun.angles[1], self.gun.angles[2]), .25);
	wait .3;

	self.gun unlink();

	if(isDefined(self.hinge))
		self.hinge delete();

	self.target = undefined;
}

turretFire()
{
	self endon( "turretShutdown" );
	self endon( "turretExplode" );

	self.shooting = true;
	for( i=0; i<level.sentryOverheat; i++)
	{
		if( self.type == "bturret" )
			wait 0.05;		// 1200 RPM
		else if( self.type == "lturret" )
			wait 0.15;		// 0.3 = 200 RPM
		else
			wait 0.5;		// 120 RPM
		
		if(	(!isDefined(self.target)) || (isDefined(self.target) && self.target.health < 1) || (isDefined(self.target) && !sightTracePassed(self.gun getTagOrigin("tag_flash"), self.target getTagOrigin("j_spine4"), false, self.gun)) )
			break;
		
		if( self.shoots >= level.sentryClipSize )
		{
			self notify( "turretLastShoot" );
			break;
		}
	
		targetVec = vectorToAngles( self.target getTagOrigin("j_spine4") - self.gun.origin );
		start = self.gun getTagOrigin("tag_flash");
		end = self.gun getTagOrigin("tag_flash") + vector_scale(anglesToForward(self.gun getTagAngles("tag_flash")), 10000);
		ent = bulletTrace(start, end, true, self)["entity"];

		if( !isDefined(ent) && isDefined(self.target) )
		{
			self.swivel rotateTo((self.swivel.angles[0], targetVec[1], self.swivel.angles[2]), .25);
			self.gun rotateTo((targetVec[0], targetVec[1], self.gun.angles[2]), .25);
		}

		self.hinge.origin = self.gun getTagOrigin("tag_origin");
		self.hinge.angles = self.gun getTagAngles("tag_origin");

		if( self.type == "bturret" )
			self thread fakeBullet();
		else if( self.type == "lturret" )
			self thread fakeRay();
	}
	wait .25;

	self.hinge.origin = self.gun getTagOrigin("tag_origin");
	self.hinge.angles = self.gun getTagAngles("tag_origin");
	wait .25;
//	self.target = undefined;
	self.shooting = false;
}

turretDamage()
{
	self endon( "turretShutdown" );
	self endon( "turretExplode" );
	
	self.gun setCanDamage( true );
	
	for(;;)
	{
		self.gun waittill( "damage", damage, attacker );
		
		if( attacker.team == self.team )
			continue;
		
		self.health -= damage;
		
		if( (self.maxhealth-self.health) >= level.sentryHealth )
			break;
	}
	
	if( (self.maxhealth-self.health) >= level.sentryHealth+100 )
		self thread turretExplode( 0.1 );
	else
		self thread turretShutdown( 0.1 );
}

turretVanish()
{
	self endon( "turretExplode" );
	self endon( "turretShutdown" );
	
	self thread destroyOnOwnerDisconnect();
	
	if( level.sentryVanishType == "clip" )
	{
		self waittill( "turretLastShoot" );
		self thread turretShutdown( 0.5 );
	}
	else if( level.sentryVanishType == "time" )
	{
		if( isDefined(self) )
			self thread turretShutdown( level.sentryLifetime );
	}
}

destroyOnOwnerDisconnect()
{
	self endon( "turretExplode" );
	
	self.owner waittill( "disconnect" );
	
	if( isDefined(self) )
		self thread turretExplode( 0.1 );
}

/*=======================================================================================
Sub functions
=======================================================================================*/
turretRotate( angle )
{
	self endon( "turretShutdown" );
	self endon( "turretExplode" );
	
	self notify( "turretRotate" );
	self endon( "turretRotate" );
	
	if( angle < 0 )
	{
		tangle = angle*(-1);
		time = tangle/level.turretSpeed;
	}
	else
		time = angle/level.turretSpeed;
	
	if( time <= 0 )
		time = 0.01;
	
	self.swivel rotateYaw( angle, time );
	self.gun rotateYaw( angle, time );
	
//	self.gun playLoopSound( "sentry_move_loop" );
	wait time;
//	self.gun stopLoopSound( "sentry_move_loop" );
//	self.gun playSound( "sentry_move_end" );
}

turretShutdown( time )
{
	self endon( "turretExplode" );
	self notify( "turretShutdown_start" );		// ends another running thread
	self endon( "turretShutdown_start" );
	
	wait time;
	
	self notify( "turretShutdown" );
	// stop rotation
	self.gun rotateYaw( 0, 0.18 );
	self.swivel rotateYaw( 0, 0.18 );
//	self.gun stopLoopSound( "sentry_move_loop" );
//	self.gun playSound( "sentry_move_end" );
	wait 0.18;
	
	// fold gun down
	self.gun playSound( "sentry_deactivate" );
	playFxOnTag( level._effect["turret_spark"], self.gun, "j_damage" );
	self.gun rotatePitch( 45, 0.2 );
	
	self thread turretExplode( 10 );	// explode the turret in 10 seconds
}

turretExplode( time )
{
	self notify( "turretExplode_start" );
	self endon( "turretExplode_start" );
	
	wait time;
	
	self notify( "turretExplode" );
	playFx( level._effect["turret_death"], self.gun.origin );
	self.gun playSound( "grenade_explode_default" );
	
	if( isDefined(self.gun) )
		self.gun delete();
	
	if( isDefined(self.swivel) )
		self.swivel delete();
	
	if( isDefined(self.bipod) )
		self.bipod delete();
	
	if( isDefined(self.owner) )
		self.owner.sentryTurrets--;
}

/*=======================================================================================
Weapon functions
=======================================================================================*/
fakeBullet()
{
	playFxOnTag( level._effect["bturret_flash"], self.gun, "tag_flash" );
	self.gun playSound( "sentry_gatling_shoot" );
	if( randomFloat( 1.0 ) <= getDvarFloat( "cg_tracerchance" ) )
		playFxOnTag( level._effect["bturret_trace"], self.gun, "tag_flash" );
	playFxOnTag( level._effect["bturret_shell"], self.gun, "tag_brass" );
	
	start = self.gun getTagOrigin("tag_flash");
	end = start+vector_scale( anglesToForward(self.gun getTagAngles("tag_flash")), 10000 );
	trace = bulletTrace( start, end, true, self.gun );
	//drawFullArray( trace );
	if( !isDefined(trace["entity"]) || !isPlayer(trace["entity"]) )
		playFx( level._effect["bturret_impact"], trace["position"] );
	else
		playFx( level._effect["bturret_hit"], trace["position"] );
	
	if( isDefined(trace["entity"]) && isPlayer(trace["entity"]) && isAlive(trace["entity"]) && isDefined(trace["entity"].team) && trace["entity"].team != self.team )
	{
		trace["entity"] thread [[level.callbackPlayerDamage]]
		(
			self,					// eInflictor	-The entity that causes the damage.(e.g. a turret)
			self.owner,				// eAttacker	-The entity that is attacking.
			20,						// iDamage		-Integer specifying the amount of damage done
			0,						// iDFlags		-Integer specifying flags that are to be applied to the damage
			"MOD_RIFLE_BULLET",		// sMeansOfDeath	-Integer specifying the method of death
			"sentryturret_mp",		// sWeapon		-The weapon number of the weapon used to inflict the damage
			trace["entity"].origin,	// vPoint		-The point the damage is from?
			(0,0,0),				// vDir			-The direction of the damage
			"none",					// sHitLoc		-The location of the hit
			0						// psOffsetTime	-The time offset for the damage
		);
	}
	
	if( isDefined(trace["entity"]) && !isPlayer(trace["entity"]) )
	{
		trace["entity"] notify( "damage", 20, self.owner, (0,0,0), (0,0,0), "MOD_RIFLE_BULLET", "", "" );
	}
	self.shoots++;
}

fakeGrenade()
{
	
}

fakeRay()
{
	playFxOnTag( level._effect["lturret_flash"], self.gun, "tag_flash" );
	self.gun playSound( "weap_raygun_fire_npc" );
	
	start = self.gun getTagOrigin("tag_flash");
	end = start+vector_scale( anglesToForward(self.gun getTagAngles("tag_flash")), 10000 );
	trace = bulletTrace( start, end, true, self.gun );
	
	projectile = spawn( "script_model", start );
	projectile setModel( "tag_origin" );
// flight
	time = distance( start, trace["position"] )/3200;
	if( time <= 0 )
		time = 0.01;
	playFxOnTag( level._effect["lturret_tail"], projectile, "tag_origin" );
	projectile playLoopSound( "weap_raygun_ploop" );
	projectile moveTo( trace["position"], time );
	wait time;	
	projectile stopLoopSound( "weap_raygun_ploop" );
// impact
	playFx( level._effect["lturret_impact"], trace["position"] );
	projectile playSound( "weap_raygun_exp" );
	radiusDamage( trace["position"], 64, 200, 100, self.owner );
	
// delete
	projectile delete();
	self.shoots++;
}

/*
	sentry_turret( origin )
	{	
	//	wait ( 0.45 );
		
		self.sentryTurret = [];
		self.sentryTurret[0] = spawn( "script_model", origin  ); // Base
		self.sentryTurret[0] setModel("weapon_sentry_turret");
		self.sentryTurret[0].angles = self.angles;
		self.sentryTurret[0].owner = self;
		self.sentryTurret[0].team = self.pers["team"];
		self.sentryTurret[0].targetname = "sentryTurret";
		//self.sentryTurret[0] thread manual_move();
		self.sentryTurret[0] thread sentry_damage();
		self.sentryTurret[0] thread sentry_vanish();
	//	self.sentryTurret[0] maps\mp\_entityheadicons::setEntityHeadIcon( self.sentryTurret[0].team, (0,0,70) );
	
		for(x = 0; x < level.sentryTurretTags.size; x++)
			if(level.sentryTurretTags[x] != "tag_base")
				self.sentryTurret[0] hidePart(level.sentryTurretTags[x]);
	
		wait .05;
		self.sentryTurret[1] = spawn("script_model", self.sentryTurret[0] getTagOrigin("j_swivel")); // Swivel
		self.sentryTurret[2] = spawn("script_model", self.sentryTurret[0] getTagOrigin("j_gun")); // Gun
		self.sentryTurret[3] = spawn("script_model", self.sentryTurret[0] getTagOrigin("j_gun")); // Barrel
	
		for(i = 1; i < self.sentryTurret.size; i++)
		{
			self.sentryTurret[i] setModel("weapon_sentry_turret");
			self.sentryTurret[i].angles = self.angles;
			self.sentryTurret[i].owner = self;
			self.sentryTurret[i].team = self.pers["team"];
			self.sentryTurret[i].targetname = "sentryTurret";
			//self.sentryTurret[i] thread manual_move();
			self.sentryTurret[i] thread sentry_damage();
			
			if(i == 1)
			{
				for(x = 0; x < level.sentryTurretTags.size; x++)
					if(level.sentryTurretTags[x] != "tag_swivel")
						self.sentryTurret[i] hidePart(level.sentryTurretTags[x]);
			}
			if(i == 2)
			{
				for(x = 0; x < level.sentryTurretTags.size; x++)
					if(level.sentryTurretTags[x] != "tag_gun")
						self.sentryTurret[i] hidePart(level.sentryTurretTags[x]);
			}
	
		}
		self.sentryTurret[3] hide();
		
		self.sentryTurretDamageTaken = 0;
		self.sentryTurretIsIdling = true;
		self.sentryTurretIsTargeting = false;
		self.sentryTurretIsFiring = false;
		self.sentryTurretTarget = undefined;
	
		self thread sentry_idle();
		self thread sentry_targeting();
		
		return true;
	}
	
	sentry_targeting()
	{
		self endon("disconnect");
		self endon("end_sentry_turret");
	
		// Scan for enemies in range
		setDvar("sentry_turret_range", "1000");
		
		self.sentryTurretTrig = spawn("trigger_radius", self.sentryTurret[0].origin, 0, Int(getDvar("sentry_turret_range")), Int(getDvar("sentry_turret_range")) / 5);
		self.sentryTurretTrig.origin = (self.sentryTurret[0].origin - (0, 0, Int(getDvar("sentry_turret_range")) / 10));
		
		while( true )
		{
			wait .05;
				
			if( !isdefined( self.sentryTurretTrig ) || !isdefined( self.sentryTurret ) )
				break;
		
			if(self.sentryTurretIsTargeting || self.sentryTurretIsFiring)
				continue;
	
			eligibleTargets = [];
			p = getentarray("player", "classname");
			for(i = 0; i < p.size; i++)
			{
				if(p[i].model == "")
					continue;
	
				if(p[i].sessionstate != "playing")
					continue;
	
				if(p[i].health < 1)
					continue;
	
				if(p[i].pers["team"] == self.pers["team"])
					continue;
	
				if(p[i] isTouching(self.sentryTurretTrig) && SightTracePassed(self.sentryTurret[0] getTagOrigin("j_barrel"), p[i] getTagOrigin("j_spine4"), false, self.sentryTurret))
					eligibleTargets[eligibleTargets.size] = p[i];
			}
			if(!eligibleTargets.size)
				continue;
	
			random = randomInt(eligibleTargets.size);
			target = eligibleTargets[random];
			self.sentryTurretTarget = target;
			self thread sentry_target();
	
			eligibleTargets = undefined;
		}
	}
	
	sentry_target()
	{
		self endon("disconnect");
		self endon("end_sentry_turret");
	
		if( self.sentryTurretIsFiring )
		{
			while(self.sentryTurretIsFiring)
				wait .5;
		}
		if( !isDefined(self.sentryTurretTarget) || (isDefined(self.sentryTurretTarget) && self.sentryTurretTarget.health < 1) )
		{
			self.sentryTurretTarget = undefined;
			self.sentryTurretIsTargeting = false;
			return;
		}
		self.sentryTurretIsTargeting = true;
	
		// aim toward target
		targetVec = vectorToAngles(self.sentryTurretTarget getTagOrigin("j_spine4")  - self.sentryTurret[3].origin);
		self.sentryTurretHinge = spawn("script_origin", self.sentryTurret[0] getTagOrigin("j_hinge"));
		self.sentryTurretHinge.angles = self.sentryTurret[2].angles;
	
		for(i = 2; i < self.sentryTurret.size; i++)
			self.sentryTurret[i] linkTo(self.sentryTurretHinge);
		wait .05;
		self.sentryTurretHinge rotateTo((targetVec[0], targetVec[1], self.sentryTurret[2].angles[2]), .5);
		self.sentryTurret[1] rotateTo((self.sentryTurret[1].angles[0], targetVec[1], self.sentryTurret[1].angles[2]), .5);
		wait .6;
	
		for(i = 2; i < self.sentryTurret.size; i++)
			self.sentryTurret[i] unlink(); // Unlink after aimed correctly - Rest of positioning is taken care of in sentry_fire()
		wait .05;
		self thread sentry_fire();
		wait .05;
		if(self.sentryTurretIsFiring)
		{
			while(self.sentryTurretIsFiring)
				wait .5;
		}
		for(i = 2; i < self.sentryTurret.size; i++)
			self.sentryTurret[i] linkTo(self.sentryTurretHinge);
		wait .05;
		self.sentryTurretHinge rotateTo((0, self.sentryTurret[2].angles[1], self.sentryTurret[2].angles[2]), .25);
		wait .3;
	
		for(i = 2; i < self.sentryTurret.size; i++)
			self.sentryTurret[i] unlink();
	
		if(isDefined(self.sentryTurretHinge))
			self.sentryTurretHinge delete();
	
		self thread anchor_barrel();
		self.sentryTurretIsTargeting = false;
	}
	
	sentry_fire()
	{
		self endon("disconnect");
		self endon("end_sentry_turret");
	
		self.sentryTurretIsFiring = true;
		for(i = 0; i < level.sentryTurretClipSize; i++)
		{
			wait .05;
			if((!isDefined(self.sentryTurretTarget)) || (isDefined(self.sentryTurretTarget) && self.sentryTurretTarget.health < 1) || (isDefined(self.sentryTurretTarget) && !sightTracePassed(self.sentryTurret[2] getTagOrigin("j_barrel_anchor"), self.sentryTurretTarget getTagOrigin("j_spine4"), false, self.sentryTurret)))
				break;
	
			targetVec = vectorToAngles(self.sentryTurretTarget getTagOrigin("j_spine4")  - self.sentryTurret[3].origin);
			start = self.sentryTurret[3] getTagOrigin("tag_flash");
			end = self.sentryTurret[3] getTagOrigin("tag_flash") + vector_scale(anglesToForward(self.sentryTurret[3] getTagAngles("tag_flash")), 10000);
			ent = bulletTrace(start, end, true, self)["entity"];
	
			if(!isDefined(ent) && isDefined(self.sentryTurretTarget))
			{
				self.sentryTurret[1] rotateTo((self.sentryTurret[1].angles[0], targetVec[1], self.sentryTurret[1].angles[2]), .25);
				self.sentryTurret[2] rotateTo((targetVec[0], targetVec[1], self.sentryTurret[2].angles[2]), .25);
			}
			self thread anchor_barrel();
			self.sentryTurret[3] rotateRoll(72, .05, 0, 0);
	
			self.sentryTurretHinge.origin = self.sentryTurret[2] getTagOrigin("tag_origin");
			self.sentryTurretHinge.angles = self.sentryTurret[2] getTagAngles("tag_origin");
	
			self.sentryTurret[3] playSound("weap_m249saw_turret_fire_npc");
			playFXOnTag(level.fx_sentryTurretFlash, self.sentryTurret[3], "tag_flash");
			playFXOnTag(level.fx_sentryTurretTracer, self.sentryTurret[3], "tag_flash");
			playFXOnTag(level.fx_sentryTurretShellEject, self.sentryTurret[2], "tag_brass");
			self.sentryTurret[3] thread sentry_bullet();
		}
		wait .25;
		self thread anchor_barrel();
		self.sentryTurretHinge.origin = self.sentryTurret[2] getTagOrigin("tag_origin");
		self.sentryTurretHinge.angles = self.sentryTurret[2] getTagAngles("tag_origin");
		wait .25;
		self.sentryTurretTarget = undefined;
		self.sentryTurretIsFiring = false;
	}
	
	anchor_barrel() // Position barrel correctly according to gun body
	{
		self.sentryTurret[3].origin = self.sentryTurret[2] getTagOrigin("j_barrel_anchor");
		self.sentryTurret[3].angles = (self.sentryTurret[2] getTagAngles("j_barrel_anchor")[0], self.sentryTurret[2] getTagAngles("j_barrel_anchor")[1], self.sentryTurret[3].angles[2]);
	}
	
	sentry_bullet()
	{
		self endon("death");
		self endon("end_sentry_turret");
	
		wait .05;
		if(!isDefined(self))
			return;
	
		start = self getTagOrigin("tag_flash");
		end = self getTagOrigin("tag_flash") + vector_scale(anglesToForward(self getTagAngles("tag_flash")), 10000);
		ent = bulletTrace(start, end, true, self)["entity"];
	
		if(isDefined(ent) && isPlayer(ent) && isAlive(ent) && isDefined(ent.pers["team"]) && ent.pers["team"] != self.team)
		{
			ent thread [[level.callbackPlayerDamage]]
			(
				self,					// eInflictor	-The entity that causes the damage.(e.g. a turret)
				self.owner,				// eAttacker	-The entity that is attacking.
				20,						// iDamage		-Integer specifying the amount of damage done
				0,						// iDFlags		-Integer specifying flags that are to be applied to the damage
				"MOD_RIFLE_BULLET",		// sMeansOfDeath	-Integer specifying the method of death
				"sentryturret_mp",		// sWeapon		-The weapon number of the weapon used to inflict the damage
				ent.origin,				// vPoint		-The point the damage is from?
				(0,0,0),				// vDir			-The direction of the damage
				"none",					// sHitLoc		-The location of the hit
				0						// psOffsetTime	-The time offset for the damage
			);
		}
	
		if(isDefined(ent) && !isPlayer(ent))
		{
			ent notify("damage", 20, self.owner, (0,0,0), (0,0,0), "MOD_RIFLE_BULLET", "", "" );
		}
	}
	
	sentry_damage()
	{
		self endon("death");
		self endon("end_sentry_turret");
	
		self setCanDamage(true);
		self.maxhealth = 999999;
		self.health = self.maxhealth;
		attacker = undefined;
	
		while(1)
		{
			self waittill("damage", dmg, attacker);
			
			if(dmg < 5)
				continue;
	
			if(!maps\mp\gametypes\_weapons::friendlyFireCheck(self.owner, attacker))
				continue;
	
			self.owner.sentryTurretDamageTaken += dmg;
	
			if(self.owner.sentryTurretDamageTaken >= level.sentryTurretHealth)
				break;
		}
		
		if(!isDefined(self))
			return;
	
		self.owner thread sentry_explode();
	}
	
	sentry_vanish()
	{
		self endon("death");
		self endon("end_sentry_turret");
		
		wait level.sentryLifetime;
		
		if( isDefined(self) )
			self.owner thread sentry_explode();
	}
	
	manual_move() // Watch for owner manually moving his turret
	{
		self endon( "death" );
		self endon( "end_sentry_turret" );
	
		while(1)
		{
			wait .05;
			if( !isDefined( self ) )
				return;
				
			if( isdefined( self.owner ) && isdefined( self ) )
			{
				if( ( distance( self.origin, self.owner.origin ) <= 60 ) && self.owner IsLookingAt( self ) )
				{
					self.owner CreatePickupMessage();
					
					if( self.owner useButtonPressed() )
						self.owner thread sentry_remove( true );
				}
				else
					self.owner DeletePickupMessage();
					
			}
		}
	}
	
	CreatePickupMessage()
	{
		self scripts\_utility::setLowerMessage( &"ZMB_SENTRYGUN_HINT" );
	}
	
	DeletePickupMessage()
	{
		self clearLowerMessage( 0.2 );
	}
	
	sentry_remove( play )
	{
		self notify("end_sentry_turret");
		
		if( play )
			self PlaySoundToPlayer( "oldschool_pickup", self );
		
		self DeletePickupMessage();
	
		for( i=0; i<self.sentryTurret.size; i++ )
		{
			if( isDefined( self.sentryTurret[i] ) )
			{
				self.sentryTurret[i] notify( "end_sentry_turret" );
				self.sentryTurret[i] delete();
			}
		}
	
		if( isdefined( self.entityHeadIcons ) ) 
			self maps\mp\_entityheadicons::setEntityHeadIcon( "none" );
		
		if( isDefined( self.sentryTurretTrig ) )
			self.sentryTurretTrig delete();
	
		if(isDefined(self.sentryTurretHinge))
			self.sentryTurretHinge delete();
	
		wait .05;
		self.sentryTurret = undefined;
		self.owner = undefined;
		
		self giveWeapon( "radar_mp" );
		self giveMaxAmmo( "radar_mp" );
		self setActionSlot( 4, "weapon", "radar_mp" );
		self.pers["hardPointItem"] = "sentry_gun";
	}
	
	sentry_explode()
	{
		self notify("end_sentry_turret");
	
		self.sentryTurret[0] playSound("grenade_explode_default");
		playFX(level.fx_sentryTurretExplode, self.sentryTurret[0] getTagOrigin("j_hinge"));
		for(i = 0; i < self.sentryTurret.size; i++)
		{
			if( isDefined( self.sentryTurret[i] ) )
			{
				self.sentryTurret[i] notify("end_sentry_turret");
				self.sentryTurret[i] delete();
			}
		}
	
		if( isdefined( self.entityHeadIcons ) ) 
			self maps\mp\_entityheadicons::setEntityHeadIcon( "none" );
		
		if(isDefined(self.sentryTurretTrig))
			self.sentryTurretTrig delete();
	
		if(isDefined(self.sentryTurretHinge))
			self.sentryTurretHinge delete();
	
		wait .05;
		self.sentryTurret = undefined;
	}
	
	IsLookingAt( gameEntity )
	{
		entityPos = gameEntity.origin;
		playerPos = self getEye();
	
		entityPosAngles = vectorToAngles( entityPos - playerPos );
		entityPosForward = anglesToForward( entityPosAngles );
	
		playerPosAngles = self getPlayerAngles();
		playerPosForward = anglesToForward( playerPosAngles );
	
		newDot = vectorDot( entityPosForward, playerPosForward );
	
		if( newDot < 0.72 ) 
			return false;
		else 
			return true;
	}
*/