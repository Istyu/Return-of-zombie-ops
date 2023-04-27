/*=======================================================================================
Return of the Zombie Ops - Mod
Modded by Lefti & 3aGl3
=========================================================================================
AC-130 Spooky II
=======================================================================================*/
#include maps\mp\_utility;
#include scripts\_utility;

init()
{
	if( isDefined(level.indoorMap) )		// indoor map?
		return;
	
	if( isDefined(level.lowAirspace) )		// skybox to low?
		return;
	
	// precache & FX
	precacheModel( "vehicle_ac130_low" );
	precacheModel( "c130_zoomrig" );
	
	precacheShader( "ac130_overlay_25mm" );
	precacheShader( "ac130_overlay_40mm" );
	precacheShader( "ac130_overlay_105mm" );
	precacheShader( "ac130_overlay_grain" );
	
	// setup the origin
	minimapOrigins = getEntArray( "minimap_corner", "targetname" );
	ac130Origin = (0,0,0);
	
	if( miniMapOrigins.size )
	{
		ac130Origin = (miniMapOrigins[0].origin + miniMapOrigins[1].origin);
		vector_scale( ac130Origin, 0.5 );
	}
	
	level.ac130 = spawn( "script_model", ac130Origin );
	level.ac130 setModel( "c130_zoomrig" );
	level.ac130.angles = (0,randomInt(360),0);
	level.ac130 hide();
	
	level.ac130plane = spawn( "script_model", ac130Origin );
	level.ac130plane setModel( "vehicle_ac130_low" );
	level.ac130plane linkTo( level.ac130, "tag_player", (0,0,0), (0,0,0) );
	
	level.gunReady["ac130_25mm"] = true;
	level.gunReady["ac130_40mm"] = true;
	level.gunReady["ac130_105mm"] = true;
	
	level.ac130_rotationSpeed = 90;
	level.ac130_gunFlash = loadFx( "muzzleflashes/heavy" );
	level.ac130_40mmImpact = loadFx( "explosions/artilleryExp_dirt_brown" );
	level.ac130_105mmImpact = loadFx( "explosions/tanker_explosion" );
	
	//level.registerHardpoint//( name, kills, callThread, title, XP, trigger, icon, sound )
	[[level.registerHardpoint]]( "ac130_strike", xDvarInt( "scr_streak_ac130s_kills", 75 ), ::setStrikePoint, &"ZMB_AC130_STRIKE", "location_selector_mp", "hud_icon_ac130", "mp_killstreak_ac130" );
//	[[level.registerHardpoint]]( "ac130_gunner", xDvarInt( "scr_streak_ac130g_kills", 4 ), ::tryUseGunner, &"ZMB_AC130_GUNNER", 6, "radar_mp", "hud_icon_ac130", "mp_killstreak_ac130" );
	
	thread rotatePlane();
}

rotatePlane()
{
	for (;;)
	{
		level.ac130 rotateyaw( 360, level.ac130_rotationSpeed );
		wait level.ac130_rotationSpeed;
	}
}
	
setStrikePoint()
{
	self endon( "death" );
	self endon( "disconnect" );
	self endon( "weapon_change" );
	
	if( isDefined(level.ac130Player) )
	{
		self iPrintLnBold( &"MP_N_NOT_AVAILABLE", &"ZMB_AC130_STRIKE" );
		return false;
	}
	
	while( 1 )
	{
		self waittill( "grenade_fire", selector, weapname );
		if( weapname == "location_selector_mp" )
		{
			level.ac130Player = self;
			self.targetzone = spawn( "script_origin", selector.origin );
			self thread confirmTargetzone( selector );
			
			return true;
		}
		else
			return false;
	}
	
	return false;
}

confirmTargetzone( selector )
{
	level endon( "game_ended" );
	self endon( "disconnect" );
	
	selector waitTillNotMoving();
	self.targetzone.origin = selector.origin;
	
	wait 0.01+randomFloat(1);
	selector detonate();
	
	self bombArea();
}

bombArea()
{
	self endon( "disconnect" );
	
	smallImpactsRadius = 32;
	bigImpactRadius = 512;
	
	for( salve=0; salve<=3; salve++ )
	{
		// 8 Shoots of 40mm
		for( i=0; i<8; i++ )
		{
			x = randomInt(bigImpactRadius*2)-bigImpactRadius;		// this way we're also getting negative values
			y = randomInt(bigImpactRadius*2)-bigImpactRadius;
			
			end = self.targetzone.origin+(x,y,0);
			self thread fire40mm( end );
			
			wait 0.5;		// 120 RPM
		}
		
		// 1 shoot of 105mm
		x = randomInt(smallImpactsRadius*2)-smallImpactsRadius;		// this way we're also getting negative values
		y = randomInt(smallImpactsRadius*2)-smallImpactsRadius;
		end = self.targetzone.origin+(x,y,0);
		self fire105mm( end );
	}
	
	level.ac130Player = undefined;
}


// AC 130 Gunner

tryUseGunner()
{
	if( isDefined(level.ac130Player) )
	{
		self iPrintLnBold( &"MP_N_NOT_AVAILABLE", &"ZMB_AC130_GUNNER" );
		return false;
	}
	
	self linkTo( level.ac130, "tag_player",(0,0,0), (0,0,0) );
	
	return true;
}


// AC-130 Weapon Code

fire25mm( destination )
{
	impactPos = destination;

	// model: tag_origin
	// speed: 1040 m/s
	// meters = (units*2.54)/100;
	
	start = level.ac130plane getTagOrigin( "tag_25mm_flash" );
	trace = bulletTrace( start, destination, false, level.ac130plane );

	for( i=0;i<5;i++)		// we're redoing this a maximum of 5 times!
	{
		trace = bulletTrace( start, destination, false, undefined );
		if( trace["fraction"] != 1 )
		{
			if( trace["surfacetype"] == "none" || trace["surfacetype"] == "default" )
				start = trace["position"];
			else
			{
				impactPos = trace["position"];
				break;
			}
		}
		else
		{
			impactPos = destination;
			break;
		}
	}

	
	flyDist = distance( level.ac130plane.origin, impactPos );
	flyTime = ((flyDist*2.54)/100)/1040;
	
	projectile = spawn( "script_model", level.ac130plane.origin );
	projectile setModel( "projectile_rpg7" );
	projectile.angles = vectortoangles(vectornormalize(projectile.origin - impactPos));
	projectile hide();
	
	playFxOnTag( level.ac130_gunFlash, level.ac130plane, "tag_25mm_flash" );
	playFxOnTag( level.fx_sentryTurretTracer, level.ac130plane, "tag_25mm_flash" );		// ToDo: Replace with an own tracer
	level.ac130plane playSound( "ac130_25mm_fire" );
	
	projectile show();
	projectile moveTo( impactPos, flyTime );
	wait flyTime;
	
// impact
	projectile hide();
	
//	playFx( level.ac130_25mmImpact, impactPos );
//	projectile playSound( "artillery_explosion" );
	radiusDamage( impactPos, 32, 500, 10, self, "MOD_EXPLOSIVE", "ac130_25mm_impact");
	
	projectile delete();
}

fire40mm( destination )
{
	impactPos = destination;

	// model: projectile_rpg7
	// speed: 810 m/s
	// meters = (units*2.54)/100;
	
	start = level.ac130plane getTagOrigin( "tag_40mm_flash" );
	trace = bulletTrace( start, destination, false, level.ac130plane );

	for( i=0;i<5;i++)		// we're redoing this a maximum of 5 times!
	{
		trace = bulletTrace( start, destination, false, undefined );
		if( trace["fraction"] != 1 )
		{
			if( trace["surfacetype"] == "none" || trace["surfacetype"] == "default" )
				start = trace["position"];
			else
			{
				impactPos = trace["position"];
				break;
			}
		}
		else
		{
			impactPos = destination;
			break;
		}
	}

	
	flyDist = distance( level.ac130plane.origin, impactPos );
	flyTime = ((flyDist*2.54)/100)/810;
	
	projectile = spawn( "script_model", level.ac130plane.origin );
	projectile setModel( "projectile_rpg7" );
	projectile.angles = vectortoangles(vectornormalize(projectile.origin - impactPos));
	projectile hide();
	
	playFxOnTag( level.ac130_gunFlash, level.ac130plane, "tag_40mm_flash" );
	level.ac130plane playSound( "ac130_40mm_fire" );
	
	projectile show();
	projectile moveTo( impactPos, flyTime );
	wait flyTime;
	
// impact
	projectile hide();
	
	playFx( level.ac130_40mmImpact, impactPos );
	projectile playSound( "artillery_explosion" );
	radiusDamage( impactPos, 200 , 600 , 50, self, "MOD_EXPLOSIVE", "ac130_40mm_impact");
	
	projectile delete();
}

fire105mm( destination )
{
	impactPos = destination;

	// model: projectile_rpg7
	// speed: 464 m/s
	// meters = (units*2.54)/100;
	
	start = level.ac130plane getTagOrigin( "tag_105mm_flash" );
	trace = bulletTrace( start, destination, false, level.ac130plane );

	for( i=0;i<5;i++)		// we're redoing this a maximum of 5 times!
	{
		trace = bulletTrace( start, destination, false, undefined );
		if( trace["fraction"] != 1 )
		{
			if( trace["surfacetype"] == "none" || trace["surfacetype"] == "default" )
				start = trace["position"];
			else
			{
				impactPos = trace["position"];
				break;
			}
		}
		else
		{
			impactPos = destination;
			break;
		}
	}

	flyDist = distance( level.ac130plane.origin, impactPos );
	flyTime = ((flyDist*2.54)/100)/464;
	
	projectile = spawn( "script_model", level.ac130plane.origin );
	projectile setModel( "projectile_rpg7" );
	projectile.angles = vectortoangles(vectornormalize(projectile.origin - impactPos));
	projectile hide();
	
	playFxOnTag( level.ac130_gunFlash, level.ac130plane, "tag_105mm_flash" );
	level.ac130plane playSound( "ac130_105mm_fire" );
	
	projectile show();
	projectile moveTo( impactPos, flyTime );
	wait flyTime;
	
// impact
	projectile hide();
	
	playFx( level.ac130_105mmImpact, impactPos );
	projectile playSound( "exp_suitcase_bomb_main" );
	radiusDamage( impactPos, 512 , 1200 , 300, self, "MOD_EXPLOSIVE", "ac130_105mm_impact");
	
	projectile delete();
}