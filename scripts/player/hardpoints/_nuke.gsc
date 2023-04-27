/*=======================================================================================
return of the zombie ops - Mod
Modded by Lefti & 3aGl3
=========================================================================================
Nuke
=======================================================================================*/
#include scripts\_utility;
#include maps\mp\_utility;

init()
{
	precacheString( &"ZMB_NUKE" );
	precacheString( &"ZMB_THAT_WILL_HOLD_THEM_BACK" );
	
	level._effect["nuke_explosion"] = loadFx( "explosions/nuke_explosion" );
	level._effect["nuke_flash"] = loadFx( "explosions/nuke_flash" );
	
	//level.registerHardpoint//( name, kills, callThread, title, trigger, icon, sound )
	[[level.registerHardpoint]]( "nuke", xDvarInt( "scr_streak_nuke_kills", 750 ), ::callNuke, &"ZMB_NUKE" );
}

callNuke()
{
	if( isDefined(level.nukeInbound) )
	{
		self iPrintLnBold( &"MP_N_NOT_AVAILABLE", &"ZMB_NUKE" );
		return false;
	}
	
	level.nukeInbound = true;
	self thread createPlane();
	playSoundOnAllPlayers( "nuclear_warning" );
	
	return true;
}

createPlane()
{
	trace = bullettrace((0,0,0), (0,0,-10000), false, undefined);
	targetpos = trace["position"];
	
	yaw = scripts\player\hardpoints\_airstrike::getBestPlaneDirection( targetpos );
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
	
	startPoint = targetpos + vector_scale( anglestoforward( direction ), -1 * planeHalfDistance );
	startPoint += ( 0, 0, planeFlyHeight );

	endPoint = targetpos + vector_scale( anglestoforward( direction ), planeHalfDistance );
	endPoint += ( 0, 0, planeFlyHeight );
	
	// Make the plane fly by
	d = length( startPoint - endPoint );
	flyTime = ( d / planeFlySpeed );
	
	// bomb explodes planeBombExplodeDistance after the plane passes the center
	d = abs( d/2 + planeBombExplodeDistance  );
	bombTime = ( d / planeFlySpeed );
	
	assert( flyTime > bombTime );
	
	startPathRandomness = 100;
	endPathRandomness = 150;
	
	pathStart = startPoint + ( (randomfloat(2) - 1)*startPathRandomness, (randomfloat(2) - 1)*startPathRandomness, 0 );
	pathEnd   = endPoint   + ( (randomfloat(2) - 1)*endPathRandomness  , (randomfloat(2) - 1)*endPathRandomness  , 0 );
	
	// Spawn the planes
	plane = spawnplane( self, "script_model", pathStart );
	plane setModel( "vehicle_mig29_desert" );
	plane.angles = direction;
		
	plane thread scripts\player\hardpoints\_airstrike::playPlaneFx();
	plane moveTo( pathEnd, flyTime, 0, 0 );
	
	thread scripts\player\hardpoints\_airstrike::callStrike_planeSound( plane, targetpos );
	
	self thread blowNuke( targetpos, (flyTime/2)+randomFloatRange( 1.0, 1.5 ) );
	
	wait flyTime;
	plane notify( "delete" );
	plane delete();
}

blowNuke( origin, waittime )
{
	wait waittime;

	//wait(5.5);
	
	/*-----------------------
	NUKE HITS
	-------------------------*/	
	thread nuke_sunlight();
	level notify( "nuke_explodes" );
	wait(.5);
	thread scripts\player\hardpoints\_airstrike::playSoundinSpace( "nuclear_exp", origin, true );
	playFx( level._effect["nuke_explosion"], origin );
	
	setdvar( "timescale", 0.8 );
	
	if( getDvarInt("scr_wave_max") != 0 )
	{
		survivors = getSurvivors();
		for( i=0; i<survivors.size; i++ )
			survivors[i] disableWeapons( true );
	}
	wait 1;
	playFx( level._effect["nuke_flash"], origin );
	visionSetNaked( "airlift_nuke_flash", 2 );
	
	victims = getZombies();
	for( i=0; i<victims.size; i++ )
		victims[i] finishPlayerDamage( self, self, 10000, 1, "MOD_GRENADE_SPLASH", "nuclear_bomb", origin, origin, "head", 0 );
	
	setExpFog(0, 17000, 0.678352, 0.498765, 0.372533, 0.5);
	thread nuke_shockwave_blur( origin );
	wait(1);
	thread nuke_earthquake( origin );
	
	wait(2);
	
	thread scripts\player\hardpoints\_airstrike::playSoundinSpace( "nuclear_aftmath", origin, true );	
	thread nuke_shockwave_blur( origin );
	visionSetNaked( "airlift_nuke", 8 );
	
	wait(8.5);

	if( getDvarInt("scr_wave_max") != 0 )
		thread maps\mp\gametypes\_globallogic::endGame( "allies", &"ZMB_THAT_WILL_HOLD_THEM_BACK" );
	else
		visionSetNaked( "default", 20 );
		
	wait 15;
	setdvar( "timescale", 1 );
}

nuke_sunlight()
{
	level.defaultSun = getMapSunLight();
	level.nukeSun = ( 3.11, 2.05, 1.67 );
	sun_light_fade( level.defaultSun, level.nukeSun, 2 );
	wait(1);
	thread sun_light_fade( level.nukeSun, level.defaultSun, 2 );
}

nuke_shockwave_blur( origin )
{
	earthquake( 0.3, .5, origin, 80000 );
	//SetBlur( 3, .1 );																				// ToDo: Blur screen
	wait 1;
	//SetBlur( 0, .5 );
}

nuke_earthquake( origin )
{
	wait(1);
	earthquake( .5, 10, origin, 80000 );
}

sun_light_fade( startSunColor, endSunColor, fTime)
{
	fTime = int( fTime * 20 );
	
	// determine difference btwn starting and target sun RGBs
	increment = [];
	for(i=0;i<3;i++)	
		increment[i] = ( startSunColor[ i ] - endSunColor[ i ] ) / fTime;
	
	// change gradually to new sun color over time
    newSunColor = [];
    for(i=0;i<fTime;i++)
    {
    	wait(0.05);
    	for(j=0;j<3;j++)
    		newSunColor[ j ] = startSunColor[ j ] - ( increment[ j ] *  i );
		setSunLight( newSunColor[ 0 ], newSunColor[ 1 ], newSunColor[ 2 ] );
    }
    //set sunlight to new target values to account for rounding off decimal places
    setSunLight( endSunColor[ 0 ], endSunColor[ 1 ], endSunColor[ 2 ] );

//r_lightTweakSunColor
}

getMapSunLight()
{
	string = getDvar( "r_lightTweakSunColor" );
	
	toks = strTok( string, " " );
	array = [];
	
	for( i=0; i<toks.size; i++ )
		array[array.size] = float( toks[i] );
	
	return array;	
}

setSunLight( r, g, b )
{
	string = r+" "+g+" "+b+" "+level.defaultSun[3];
	setDvar( "r_lightTweakSunColor", string );
}