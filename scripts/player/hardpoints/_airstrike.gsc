//=======================================================================================
// Airstrike Script
// Created for Global OPS Mod
// Feb 2012
//=======================================================================================
#include maps\mp\_utility;
//#include scripts\_utility;

init()
{
	if( isDefined(level.indoorMap) )
		return;
	
	// Precache n stuff
	precachestring( &"ZMB_AIRSTRIKE" );
	
	precacheModel( "vehicle_mig29_desert" );
	precacheModel( "projectile_cbu97_clusterbomb" );
	
	precacheLocationSelector( "map_artillery_selector" );
	
	level.airstrikefx = loadFx( "explosions/clusterbomb" );
	level.mortareffect = loadFx( "explosions/artilleryExp_dirt_brown" );
	level.bombstrike = loadFx( "explosions/wall_explosion_pm_a" );
	
	level.fx_airstrike_afterburner = loadFx( "fire/jet_afterburner" );
	level.fx_airstrike_contrail = loadFx( "smoke/jet_contrail" );
	
	// dvars - can't use xDvarInt because we can't use the custom utility
	if( getDvar( "scr_streak_airstrike_kills" ) == "" )
		setDvar( "scr_streak_airstrike_kills", 100 );
	
	// vars
	level.artilleryDangerMaxRadius = 450;
	level.artilleryDangerMinRadius = 300;
	level.artilleryDangerForwardPush = 1.5;
	level.artilleryDangerOvalScale = 6.0;
	
	level.artilleryMapRange = level.artilleryDangerMinRadius * .3 + level.artilleryDangerMaxRadius * .7;
	
	level.artilleryDangerMaxRadiusSq = level.artilleryDangerMaxRadius * level.artilleryDangerMaxRadius;
	
	level.artilleryDangerCenters = [];
		
	//level.registerHardpoint//( name,			kills,	callThread,			title,					XP,	trigger,	icon,					sound )
	[[level.registerHardpoint]]( "airstrike", getDvarInt( "scr_streak_airstrike_kills" ), ::useAirstrikeItem,	&"ZMB_AIRSTRIKE", "radar_mp", "compass_objpoint_airstrike", "mp_killstreak_jet" );
}

useAirstrikeItem()
{
	if( isDefined( level.airstrikeInProgress ) )
	{
		self iPrintLnBold( &"MP_N_NOT_AVAILABLE", &"ZMB_AIRSTRIKE" );
		return false;
	}

	result = self selectAirstrikeLocation();
	
	if( !isDefined( result ) || !result )
		return false;
	else
		return true;
}


// Select Location

selectAirstrikeLocation()
{
	self beginLocationSelection( "map_artillery_selector", level.artilleryDangerMaxRadius * 1.2 );
	self.selectingLocation = true;

	self thread endSelectionOn( "cancel_location" );
	self thread endSelectionOn( "death" );
	self thread endSelectionOn( "disconnect" );
	self thread endSelectionOn( "used" );
	self thread endSelectionOnGameEnd();

	self endon( "stop_location_selection" );
	self waittill( "confirm_location", location );

	if ( isDefined( level.airstrikeInProgress ) )
	{
		self iPrintLnBold( &"MP_N_NOT_AVAILABLE", &"ZMB_AIRSTRIKE" );
		self thread stopAirstrikeLocationSelection( false );
		return false;
	}

	self thread finishAirstrikeUsage( location, ::useAirstrike );
	return true;
}

finishAirstrikeUsage( location, usedCallback )
{
	self notify( "used" );
	wait ( 0.05 );
	self thread stopAirstrikeLocationSelection( false );
	self thread [[usedCallback]]( location );
	return true;
}

stopAirstrikeLocationSelection( disconnected )
{
	if ( !disconnected )
	{
		self endLocationSelection();
		self.selectingLocation = undefined;
	}
	self notify( "stop_location_selection" );
}

endSelectionOn( waitfor )
{
	self endon( "stop_location_selection" );
	
	self waittill( waitfor );

	self thread stopAirstrikeLocationSelection( (waitfor == "disconnect") );
}

endSelectionOnGameEnd()
{
	self endon( "stop_location_selection" );
	
	level waittill( "game_ended" );
	
	self thread stopAirstrikeLocationSelection( false );
}


// Use Airstrike

useAirstrike( pos )
{
	trace = bullettrace( self.origin + (0,0,10000), self.origin, false, undefined );
	pos = (pos[0], pos[1], trace["position"][2] - 514);

	thread doArtillery( pos, self, self.pers["team"] );
}

doArtillery(origin, owner, team)
{
	num = 17 + randomint(3);
	
	level.airstrikeInProgress = true;
	trace = bullettrace(origin, origin + (0,0,-10000), false, undefined);
	targetpos = trace["position"];
	
	yaw = getBestPlaneDirection( targetpos );
	
	wait 2;

	if ( !isDefined( owner ) )
	{
		level.airstrikeInProgress = undefined;
		return;
	}
	
	owner notify ( "begin_airstrike" );
	
	dangerCenter = spawnstruct();
	dangerCenter.origin = targetpos;
	dangerCenter.forward = anglesToForward( (0,yaw,0) );
	level.artilleryDangerCenters[ level.artilleryDangerCenters.size ] = dangerCenter;
	/# level thread debugArtilleryDangerCenters(); #/
	
	callStrike( owner, targetpos, yaw );
	
	wait 8.5;
	
	found = false;
	newarray = [];
	for ( i = 0; i < level.artilleryDangerCenters.size; i++ )
	{
		if ( !found && level.artilleryDangerCenters[i].origin == targetpos )
		{
			found = true;
			continue;
		}
		
		newarray[ newarray.size ] = level.artilleryDangerCenters[i];
	}
	assert( found );
	assert( newarray.size == level.artilleryDangerCenters.size - 1 );
	level.artilleryDangerCenters = newarray;

	level.airstrikeInProgress = undefined;
}

callStrike( owner, coord, yaw )
{	
	// Get starting and ending point for the plane
	direction = ( 0, yaw, 0 );
	planeHalfDistance = 24000;
	planeBombExplodeDistance = 1500;
	planeFlyHeight = 850;
	planeFlySpeed = 7000;

	if ( isdefined( level.airstrikeHeightScale ) )
	{
		planeFlyHeight *= level.airstrikeHeightScale;
	}
	
	startPoint = coord + vector_scale( anglestoforward( direction ), -1 * planeHalfDistance );
	startPoint += ( 0, 0, planeFlyHeight );

	endPoint = coord + vector_scale( anglestoforward( direction ), planeHalfDistance );
	endPoint += ( 0, 0, planeFlyHeight );
	
	// Make the plane fly by
	d = length( startPoint - endPoint );
	flyTime = ( d / planeFlySpeed );
	
	// bomb explodes planeBombExplodeDistance after the plane passes the center
	d = abs( d/2 + planeBombExplodeDistance  );
	bombTime = ( d / planeFlySpeed );
	
	assert( flyTime > bombTime );
	
	owner endon("disconnect");
	
	requiredDeathCount = owner.deathCount;
	
	level.airstrikeDamagedEnts = [];
	level.airStrikeDamagedEntsCount = 0;
	level.airStrikeDamagedEntsIndex = 0;
	level thread doPlaneStrike( owner, requiredDeathCount, coord, startPoint+(0,0,randomInt(500)), endPoint+(0,0,randomInt(500)), bombTime, flyTime, direction );
	wait randomfloatrange( 1.5, 2.5 );
	level thread doPlaneStrike( owner, requiredDeathCount, coord, startPoint+(0,0,randomInt(200)), endPoint+(0,0,randomInt(200)), bombTime, flyTime, direction );
	wait randomfloatrange( 1.5, 2.5 );
	level thread doPlaneStrike( owner, requiredDeathCount, coord, startPoint+(0,0,randomInt(200)), endPoint+(0,0,randomInt(200)), bombTime, flyTime, direction );
}

doPlaneStrike( owner, requiredDeathCount, bombsite, startPoint, endPoint, bombTime, flyTime, direction )
{
	// plane spawning randomness = up to 125 units, biased towards 0
	// radius of bomb damage is 512

	if ( !isDefined( owner ) ) 
		return;
	
	startPathRandomness = 100;
	endPathRandomness = 150;
	
	pathStart = startPoint + ( (randomfloat(2) - 1)*startPathRandomness, (randomfloat(2) - 1)*startPathRandomness, 0 );
	pathEnd   = endPoint   + ( (randomfloat(2) - 1)*endPathRandomness  , (randomfloat(2) - 1)*endPathRandomness  , 0 );
	
	// Spawn the planes
	plane = spawnplane( owner, "script_model", pathStart );
	plane setModel( "vehicle_mig29_desert" );
	plane.angles = direction;
	
	plane thread playPlaneFx();
	
	plane moveTo( pathEnd, flyTime, 0, 0 );
	
	/#
	if ( getdvar("scr_airstrikedebug") == "1" )
		thread airstrikeLine( pathStart, pathEnd, (1,1,1), 10 );
	#/
	
	thread callStrike_planeSound( plane, bombsite );
	
	thread callStrike_bombEffect( plane, bombTime - 1.0, owner, requiredDeathCount );
	
	// Delete the plane after its flyby
	wait flyTime;
	plane notify( "delete" );
	plane delete();
}

callStrike_bombEffect( plane, launchTime, owner, requiredDeathCount )
{
	wait ( launchTime );
	
	plane thread play_sound_in_space( "veh_mig29_sonic_boom" );
	//plane playsound( "veh_mig29_sonic_boom" );
	
	bomb = spawnbomb( plane.origin, plane.angles );
	bomb moveGravity( vector_scale( anglestoforward( plane.angles ), 7000/1.5 ), 3.0 );
	
	bomb.ownerRequiredDeathCount = requiredDeathCount;
	
	/#
	if ( getdvar("scr_airstrikedebug") == "1" )
		 bomb thread traceBomb();
	#/
	
	wait ( 0.85 );
	bomb.killCamEnt = spawn( "script_model", bomb.origin + (0,0,200) );
	bomb.killCamEnt.angles = bomb.angles;
	bomb.killCamEnt thread deleteAfterTime( 10.0 );
	bomb.killCamEnt moveTo( bomb.killCamEnt.origin + vector_scale( anglestoforward( plane.angles ), 1000 ), 3.0 );
	wait ( 0.15 );

	newBomb = spawn( "script_model", bomb.origin );
 	newBomb setModel( "tag_origin" );
  	newBomb.origin = bomb.origin;
  	newBomb.angles = bomb.angles;

	bomb setModel( "tag_origin" );
	//plane moveTo( endPoint + ( (randomint( 300 ) - 150 ), (randomint( 300 ) - 150 ), 0 ), flyTime, 0, 0 );
	wait (0.05);
	
	bombOrigin = newBomb.origin;
	bombAngles = newBomb.angles;
	playfxontag( level.airstrikefx, newBomb, "tag_origin" );
	
	wait ( 0.5 );
	repeat = 12;
	minAngles = 5;
	maxAngles = 55;
	angleDiff = (maxAngles - minAngles) / repeat;
	
	for( i = 0; i < repeat; i++ )
	{
		traceDir = anglesToForward( bombAngles + (maxAngles-(angleDiff * i),randomInt( 10 )-5,0) );
		traceEnd = bombOrigin + vector_scale( traceDir, 10000 );
		trace = bulletTrace( bombOrigin, traceEnd, false, undefined );
		
		traceHit = trace["position"];
		
		/#
		if ( getdvar("scr_airstrikedebug") == "1" )
			thread airstrikeLine( bombOrigin, traceHit, (1,0,0), 20 );
		#/
		
		thread losRadiusDamage( traceHit + (0,0,16), 512, 200, 30, owner, bomb ); // targetpos, radius, maxdamage, mindamage, player causing damage, entity that player used to cause damage
	
		if ( i%3 == 0 )
		{
			thread playsoundinspace( "artillery_impact", traceHit );
			playRumbleOnPosition( "artillery_rumble", traceHit );
			earthquake( 0.7, 0.75, traceHit, 1000 );
		}
		
		wait ( 0.05 );
	}
	wait ( 5.0 );
	newBomb delete();
	bomb delete();
}

deleteAfterTime( time )
{
	self endon ( "death" );
	wait ( 10.0 );
	
	self delete();
}

playSoundinSpace (alias, origin, master)
{
	org = spawn ("script_origin",(0,0,1));
	if (!isdefined (origin))
		origin = self.origin;
	org.origin = origin;
	if (isdefined(master) && master)
		org playsoundasmaster (alias);
	else
		org playsound (alias);
	wait ( 10.0 );
	org delete();
}

losRadiusDamage(pos, radius, max, min, owner, eInflictor)
{
	ents = maps\mp\gametypes\_weapons::getDamageableEnts(pos, radius, true);

	for (i = 0; i < ents.size; i++)
	{
		if (ents[i].entity == self)
			continue;
		
		dist = distance(pos, ents[i].damageCenter);
		
		if ( ents[i].isPlayer )
		{
			// check if there is a path to this entity 130 units above his feet. if not, they're probably indoors
			indoors = !maps\mp\gametypes\_weapons::weaponDamageTracePassed( ents[i].entity.origin, ents[i].entity.origin + (0,0,130), 0, undefined );
			if ( !indoors )
			{
				indoors = !maps\mp\gametypes\_weapons::weaponDamageTracePassed( ents[i].entity.origin + (0,0,130), pos + (0,0,130 - 16), 0, undefined );
				if ( indoors )
				{
					// give them a distance advantage for being indoors.
					dist *= 4;
					if ( dist > radius )
						continue;
				}
			}
		}

		ents[i].damage = int(max + (min-max)*dist/radius);
		ents[i].pos = pos;
		ents[i].damageOwner = owner;
		ents[i].eInflictor = eInflictor;
		level.airStrikeDamagedEnts[level.airStrikeDamagedEntsCount] = ents[i];
		level.airStrikeDamagedEntsCount++;
	}
	
	thread airstrikeDamageEntsThread();
}

airstrikeDamageEntsThread()
{
	self notify ( "airstrikeDamageEntsThread" );
	self endon ( "airstrikeDamageEntsThread" );

	for ( ; level.airstrikeDamagedEntsIndex < level.airstrikeDamagedEntsCount; level.airstrikeDamagedEntsIndex++ )
	{
		if ( !isDefined( level.airstrikeDamagedEnts[level.airstrikeDamagedEntsIndex] ) )
			continue;

		ent = level.airstrikeDamagedEnts[level.airstrikeDamagedEntsIndex];
		
		if ( !isDefined( ent.entity ) )
			continue; 
			
		if ( !ent.isPlayer || isAlive( ent.entity ) )
		{
			ent maps\mp\gametypes\_weapons::damageEnt(
				ent.eInflictor, // eInflictor = the entity that causes the damage (e.g. a claymore)
				ent.damageOwner, // eAttacker = the player that is attacking
				ent.damage, // iDamage = the amount of damage to do
				"MOD_PROJECTILE_SPLASH", // sMeansOfDeath = string specifying the method of death (e.g. "MOD_PROJECTILE_SPLASH")
				"cluster_bomb_mp", // sWeapon = string specifying the weapon used (e.g. "claymore_mp")
				ent.pos, // damagepos = the position damage is coming from
				vectornormalize(ent.damageCenter - ent.pos) // damagedir = the direction damage is moving in
			);

			level.airstrikeDamagedEnts[level.airstrikeDamagedEntsIndex] = undefined;
			
			if ( ent.isPlayer )
				wait ( 0.05 );
		}
		else
		{
			level.airstrikeDamagedEnts[level.airstrikeDamagedEntsIndex] = undefined;
		}
	}
}

spawnbomb( origin, angles )
{
	bomb = spawn( "script_model", origin );
	bomb.angles = angles;
	bomb setModel( "projectile_cbu97_clusterbomb" );

	return bomb;
}

callStrike_planeSound( plane, bombsite )
{
	plane thread play_loop_sound_on_entity( "veh_mig29_dist_loop" );
	while( !targetisclose( plane, bombsite ) )
		wait .05;
	plane notify ( "stop sound" + "veh_mig29_dist_loop" );
	plane thread play_loop_sound_on_entity( "veh_mig29_close_loop" );
	while( targetisinfront( plane, bombsite ) )
		wait .05;
	wait .5;
	//plane thread play_sound_in_space( "veh_mig29_sonic_boom" );
	while( targetisclose( plane, bombsite ) )
		wait .05;
	plane notify ( "stop sound" + "veh_mig29_close_loop" );
	plane thread play_loop_sound_on_entity( "veh_mig29_dist_loop" );
	plane waittill( "delete" );
	plane notify ( "stop sound" + "veh_mig29_dist_loop" );
}

targetisclose(other, target)
{
	infront = targetisinfront(other, target);
	if(infront)
		dir = 1;
	else
		dir = -1;
	a = flat_origin(other.origin);
	b = a+vector_scale(anglestoforward(flat_angle(other.angles)), (dir*100000));
	point = pointOnSegmentNearestToPoint(a,b, target);
	dist = distance(a,point);
	if (dist < 3000)
		return true;
	else
		return false;
}

targetisinfront(other, target)
{
	forwardvec = anglestoforward(flat_angle(other.angles));
	normalvec = vectorNormalize(flat_origin(target)-other.origin);
	dot = vectordot(forwardvec,normalvec); 
	if(dot > 0)
		return true;
	else
		return false;
}

flat_origin(org)
{
	rorg = (org[0],org[1],0);
	return rorg;

}

flat_angle(angle)
{
	rangle = (0,angle[1],0);
	return rangle;
}

play_loop_sound_on_entity(alias, offset)
{
	org = spawn ("script_origin",(0,0,0));
	org endon ("death");
	thread delete_on_death (org);
	if (isdefined (offset))
	{
		org.origin = self.origin + offset;
		org.angles = self.angles;
		org linkto (self);
	}
	else
	{
		org.origin = self.origin;
		org.angles = self.angles;
		org linkto (self);
	}
//	org endon ("death");
	org playloopsound (alias);
//	println ("playing loop sound ", alias," on entity at origin ", self.origin, " at ORIGIN ", org.origin);
	self waittill ("stop sound" + alias);
	org stoploopsound (alias);
	org delete();
}

delete_on_death (ent)
{
	ent endon ("death");
	self waittill ("death");
	if (isdefined (ent))
		ent delete();
}

playPlaneFx()
{
	self endon ( "death" );

	playfxontag( level.fx_airstrike_afterburner, self, "tag_engine_right" );
	playfxontag( level.fx_airstrike_afterburner, self, "tag_engine_left" );
	playfxontag( level.fx_airstrike_contrail, self, "tag_right_wingtip" );
	playfxontag( level.fx_airstrike_contrail, self, "tag_left_wingtip" );
}

getBestPlaneDirection( hitpos )
{
	if ( getdvarint("scr_airstrikebestangle") != 1 )
		return randomfloat( 360 );
	
	checkPitch = -25;
	
	numChecks = 15;
	
	startpos = hitpos + (0,0,64);
	
	bestangle = randomfloat( 360 );
	bestanglefrac = 0;
	
	fullTraceResults = [];
	
	for ( i = 0; i < numChecks; i++ )
	{
		yaw = ((i * 1.0 + randomfloat(1)) / numChecks) * 360.0;
		angle = (checkPitch, yaw + 180, 0);
		dir = anglesToForward( angle );
		
		endpos = startpos + dir * 1500;
		
		trace = bullettrace( startpos, endpos, false, undefined );
		
		/#
		if ( getdvar("scr_airstrikedebug") == "1" )
			thread airstrikeLine( startpos, trace["position"], (1,1,0), 20 );
		#/
		
		if ( trace["fraction"] > bestanglefrac )
		{
			bestanglefrac = trace["fraction"];
			bestangle = yaw;
			
			if ( trace["fraction"] >= 1 )
				fullTraceResults[ fullTraceResults.size ] = yaw;
		}
		
		if ( i % 3 == 0 )
			wait .05;
	}
	
	if ( fullTraceResults.size > 0 )
		return fullTraceResults[ randomint( fullTraceResults.size ) ];
	
	return bestangle;
}

callStrike_bomb( bombTime, coord, repeat, owner )
{
	accuracyRadius = 512;
	
	for( i = 0; i < repeat; i++ )
	{
		randVec = ( 0, randomint( 360 ), 0 );
		bombPoint = coord + vector_scale( anglestoforward( randVec ), accuracyRadius );
		
		wait bombTime;
		
		thread playsoundinspace( "artillery_impact", bombPoint );
		radiusArtilleryShellshock( bombPoint, 512, 8, 4);
		losRadiusDamage( bombPoint + (0,0,16), 768, 300, 50, owner); // targetpos, radius, maxdamage, mindamage, player causing damage
	}
}

radiusArtilleryShellshock(pos, radius, maxduration,minduration)
{
	players = level.players;
	for (i = 0; i < players.size; i++)
	{
		if (!isalive(players[i]))
			continue;
		
		playerpos = players[i].origin + (0,0,32);
		dist = distance(pos, playerpos);
		if (dist < radius) {
			duration = int(maxduration + (minduration-maxduration)*dist/radius);
			
			players[i] thread artilleryShellshock("default", duration);
		}
	}
}

artilleryShellshock(type, duration)
{
	if (isdefined(self.beingArtilleryShellshocked) && self.beingArtilleryShellshocked)
		return;
	self.beingArtilleryShellshocked = true;
	
	self shellshock(type, duration);
	wait(duration + 1);
	
	self.beingArtilleryShellshocked = false;
}


// Airstrike Danger

getAirstrikeDanger( point )
{
	danger = 0;
	for ( i = 0; i < level.artilleryDangerCenters.size; i++ )
	{
		origin = level.artilleryDangerCenters[i].origin;
		forward = level.artilleryDangerCenters[i].forward;
		
		danger += getSingleAirstrikeDanger( point, origin, forward );
	}
	return danger;
}

getSingleAirstrikeDanger( point, origin, forward )
{
	center = origin + level.artilleryDangerForwardPush * level.artilleryDangerMaxRadius * forward;
	
	diff = point - center;
	diff = (diff[0], diff[1], 0);
	
	forwardPart = vectorDot( diff, forward ) * forward;
	perpendicularPart = diff - forwardPart;
	
	circlePos = perpendicularPart + forwardPart / level.artilleryDangerOvalScale;
	
	/* /#
	if ( getdvar("scr_airstrikedebug") == "1" )
	{
		thread airstrikeLine( center, center + perpendicularPart, (1,1,1), 30 );
		thread airstrikeLine( center + perpendicularPart, center + circlePos, (1,1,1), 30 );
		thread airstrikeLine( center + circlePos, point, (.5,.5,.5), 30 );
	}
	#/ */
	
	distsq = lengthSquared( circlePos );
	
	if ( distsq > level.artilleryDangerMaxRadius * level.artilleryDangerMaxRadius )
		return 0;
	
	if ( distsq < level.artilleryDangerMinRadius * level.artilleryDangerMinRadius )
		return 1;
	
	dist = sqrt( distsq );
	distFrac = (dist - level.artilleryDangerMinRadius) / (level.artilleryDangerMaxRadius - level.artilleryDangerMinRadius);
	
	assertEx( distFrac >= 0 && distFrac <= 1, distFrac );
	
	return 1 - distFrac;
}

pointIsInAirstrikeArea( point, targetpos, yaw )
{
	return distance2d( point, targetpos ) <= level.artilleryDangerMaxRadius * 1.25;
	// TODO
	//return getSingleAirstrikeDanger( point, targetpos, yaw ) > 0;
}


// Debug

/#
debugArtilleryDangerCenters()
{
	level notify("debugArtilleryDangerCenters_thread");
	level endon("debugArtilleryDangerCenters_thread");
	
	if ( getdvar("scr_airstrikedebug") != "1" && getdvar("scr_spawnpointdebug") == "0" )
	{
		return;
	}
	
	while( level.artilleryDangerCenters.size > 0 )
	{
		for ( i = 0; i < level.artilleryDangerCenters.size; i++ )
		{
			origin = level.artilleryDangerCenters[i].origin;
			forward = level.artilleryDangerCenters[i].forward;
			
			origin += forward * level.artilleryDangerForwardPush * level.artilleryDangerMaxRadius;
			
			previnnerpos = (0,0,0);
			prevouterpos = (0,0,0);
			for ( j = 0; j <= 40; j++ )
			{
				frac = (j * 1.0) / 40;
				angle = frac * 360;
				dir = anglesToForward((0,angle,0));
				forwardPart = vectordot( dir, forward ) * forward;
				perpendicularPart = dir - forwardPart;
				pos = forwardPart * level.artilleryDangerOvalScale + perpendicularPart;
				innerpos = pos * level.artilleryDangerMinRadius;
				innerpos += origin;
				outerpos = pos * level.artilleryDangerMaxRadius;
				outerpos += origin;
				
				if ( j > 0 )
				{
					line( innerpos, previnnerpos, (1, 0, 0) );
					line( outerpos, prevouterpos, (1,.5,.5) );
				}
				
				previnnerpos = innerpos;
				prevouterpos = outerpos;
			}
		}
		wait .05;
	}
}
#/

/#
airstrikeLine( start, end, color, duration )
{
	frames = duration * 20;
	for ( i = 0; i < frames; i++ )
	{
		line(start,end,color);
		wait .05;
	}
}

traceBomb()
{
	self endon("death");
	prevpos = self.origin;
	while(1)
	{
		thread airstrikeLine( prevpos, self.origin, (.5,1,0), 20 );
		prevpos = self.origin;
		wait .2;
	}
}
#/

drawLine( start, end, timeSlice )
{
	drawTime = int(timeSlice * 20);
	for( time = 0; time < drawTime; time++ )
	{
		line( start, end, (1,0,0),false, 1 );
		wait ( 0.05 );
	}
}