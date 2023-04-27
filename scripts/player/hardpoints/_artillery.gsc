/*=======================================================================================
return of the zombie ops - Mod
Modded by Lefti & 3aGl3
=========================================================================================
Mortar Script
original script written by Vikings Kampfsau
=======================================================================================*/
#include scripts\_utility;

init()
{
	if( isDefined(level.indoorMap) )
		return;
	
	// Precache n stuff
	precachestring( &"ZMB_ARTILLERY" );			// Artillery strike

	//precacheLocationSelector( "map_artillery_selector" );
	precacheModel( "projectile_m203grenade" );
	
	level.effect["mortarexplosion_wood"]		= loadfx( "explosions/grenadeExp_wood" );
	level.effect["mortarexplosion_brick"]		= loadfx( "explosions/grenadeexp_default" );
	level.effect["mortarexplosion_default"]		= loadfx( "explosions/grenadeexp_default" );
	level.effect["mortarexplosion_concrete"]	= loadfx( "explosions/grenadeExp_concrete" );
	level.effect["mortarexplosion_dirt"]		= loadfx( "explosions/artilleryExp_dirt_brown" );
	level.effect["mortarexplosion_glass"]		= loadfx( "explosions/grenadeExp_windowblast" );
	level.effect["mortarexplosion_snow"]		= loadfx( "explosions/grenadeExp_snow" );
	level.effect["mortarexplosion_metal"]		= loadfx( "explosions/grenadeExp_metal" );
	level.effect["mortarexplosion_rock"]		= loadfx( "explosions/grenadeexp_default" );
	level.effect["mortarexplosion_water"]		= loadfx( "explosions/grenadeExp_water" );
	level.effect["mortarexplosion_plaster"]		= loadfx( "explosions/grenadeExp_concrete" );
	
	level.artilleryRadius = 2048;
	
	//level.registerHardpoint//( name,	kills,	callThread,	title,	XP,	trigger,	icon,	sound )
	[[level.registerHardpoint]]( "artillery", xDvarInt( "scr_streak_artillery_kills", 200 ), ::useMortarItem, &"ZMB_ARTILLERY" );
}

useMortarItem()
{
	if ( isDefined( level.mortarInProgress ) )
	{
		self iPrintLnBold( &"MP_N_NOT_AVAILABLE", &"ZMB_ARTILLERY" );
		return false;
	}
	
	result = self MortarTarget();
	
	if ( !isDefined( result ) || !result )
		return false;
	else
		return true;
}


// Select Location


MortarTarget()
{
	self beginLocationSelection( "map_artillery_selector", level.artilleryDangerMaxRadius * 1.2 );
	self.selectingLocation = true;
	
	self thread endSelectionOn( "cancel_location" );
	self thread endSelectionOn( "death" );
	self thread endSelectionOn( "disconnect" );
	self thread endSelectionOn( "used" );
	self thread endSelectionOnGameEnd();

	self endon( "stop_location_selection" );	
	self waittill( "confirm_location", pos );

	if ( isDefined( level.mortarInProgress ) )
	{
		self iPrintLnBold( &"MP_N_NOT_AVAILABLE", &"ZMB_ARTILLERY" );
		self thread stopMortarLocationSelection( false );
		return false;
	}

	thread finishMortarUsage( pos, ::useMortar );
	return true;
}

finishMortarUsage( location, usedCallback )
{
	self notify( "used" );
	wait ( 0.05 );
	self thread stopMortarLocationSelection( false );
	self thread [[usedCallback]]( location );
	return true;
}

endSelectionOn( waitfor )
{
	self endon( "stop_location_selection" );
	
	self waittill( waitfor );

	self thread stopMortarLocationSelection( (waitfor == "disconnect") );
}


endSelectionOnGameEnd()
{
	self endon( "stop_location_selection" );
	
	level waittill( "game_ended" );
	
	self thread stopMortarLocationSelection( false );
}

stopMortarLocationSelection( disconnected )
{
	if ( !disconnected )
	{
		self endLocationSelection();
		self.selectingLocation = undefined;
	}
	self notify( "stop_location_selection" );
}

useMortar( pos )
{
	trace = BulletTrace(pos+(0,0,level.carepack_spawn_height), pos-(0,0,2000), false, undefined);
	target = trace["position"];
	surface = trace["surfacetype"];
	
	thread FireMortars( self, self.pers["team"], target, surface );
	self EndLocationSelection();
}

fireMortars( owner, team, target, surface )
{
	wait 4;

	shots = randomIntRange( 75, 125 );
	
	for( i=0; i<=shots; i++ )
	{
		thread fireArtillery( owner, team, target, surface );
		wait randomFloatRange( 0.1, 0.2 );
	}
}

fireArtillery( owner, team, target, surface )
{
	playSoundOnAllPlayers( "artillery_fire" );
	
	wait randomFloatRange( 1.0, 2.0 );
	
	xStart = randomInt( level.artilleryRadius*3 )-level.artilleryRadius*2;
	yStart = randomInt( level.artilleryRadius*3 )-level.artilleryRadius*2;
	
	xEnd = randomIntRange( 0-level.artilleryRadius, level.artilleryRadius );
	yEnd = randomIntRange( 0-level.artilleryRadius, level.artilleryRadius );
	
	startpoint = target+(xStart, yStart, level.carepack_spawn_height);
	endorigin = target+(xEnd, yEnd, 0);

	mortar = spawn( "script_model", startpoint );
	mortar setModel( "projectile_m203grenade" );
	mortar.origin = startpoint;
	mortar.angles = vectortoangles(vectornormalize(mortar.origin - startpoint));

	mortarend = spawn( "script_model", endorigin );
	mortarend.origin = endorigin;
	mortarend playsound( "artillery_incoming" );

	falltime = randomfloat(3) + 0.2;
	
	mortar moveto(endorigin, falltime);

	wait falltime;

	if( !isDefined(owner) || owner.pers["team"] == game["attackers"] )
		mortar RadiusDamage( mortar.origin, 0 , 0 , 0 );
	else
		mortar RadiusDamage( mortar.origin, 400 , 1500 , 300, owner, "MOD_EXPLOSIVE", "mortar_mp");
	
	self playsound( "artillery_explosion" );
	playFx(	level.effect["mortarexplosion_dirt"]/*explosion(surface)*/, endorigin );
	PlayRumbleOnPosition( "artillery_rumble", self.origin );
	earthquake( 0.7, 0.5, self.origin, 800 );

	wait .1;
	mortar delete();
	mortarend delete();
}

explosion( surface )
{
	switch(surface)
	{
		case "bark": sound = "rocket_explode_bark"; effect = level.effect["mortarexplosion_wood"]; break;
		case "brick": sound = "rocket_explode_brick"; effect = level.effect["mortarexplosion_brick"]; break;
		case "carpet": sound = "rocket_explode_carpet"; effect = level.effect["mortarexplosion_wood"]; break;
		case "cloth": sound = "rocket_explode_cloth"; effect = level.effect["mortarexplosion_default"]; break;
		case "concrete": sound = "rocket_explode_concrete"; effect = level.effect["mortarexplosion_concrete"]; break;
		case "dirt": sound = "rocket_explode_dirt"; effect = level.effect["mortarexplosion_dirt"]; break;
		case "flesh": sound = "rocket_explode_flesh"; effect = level.effect["mortarexplosion_default"]; break;
		case "foliage": sound = "rocket_explode_foliage"; effect = level.effect["mortarexplosion_dirt"]; break;
		case "glass": sound = "rocket_explode_glass"; effect = level.effect["mortarexplosion_glass"]; break;
		case "grass": sound = "rocket_explode_grass"; effect = level.effect["mortarexplosion_dirt"]; break;
		case "gravel": sound = "rocket_explode_gravel"; effect = level.effect["mortarexplosion_dirt"]; break;
		case "ice": sound = "rocket_explode_ice"; effect = level.effect["mortarexplosion_snow"]; break;
		case "metal": sound = "rocket_explode_metal"; effect = level.effect["mortarexplosion_metal"]; break;
		case "mud": sound = "rocket_explode_mud"; effect = level.effect["mortarexplosion_dirt"]; break;
		case "paper": sound = "rocket_explode_paper"; effect = level.effect["mortarexplosion_default"]; break;
		case "rock": sound = "rocket_explode_rock"; effect = level.effect["mortarexplosion_rock"]; break;
		case "sand": sound = "rocket_explode_sand"; effect = level.effect["mortarexplosion_dirt"]; break;
		case "snow": sound = "rocket_explode_snow"; effect = level.effect["mortarexplosion_snow"]; break;
		case "water": sound = "rocket_explode_water"; effect = level.effect["mortarexplosion_water"]; break;
		case "wood": sound = "rocket_explode_wood"; effect = level.effect["mortarexplosion_wood"]; break;
		case "asphalt": sound = "rocket_explode_asphalt"; effect = level.effect["mortarexplosion_plaster"]; break;
	
		default: sound = "rocket_explode_default"; effect = level.effect["mortarexplosion_default"]; break;
	}
	
	return effect;
}
