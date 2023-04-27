/*=======================================================================================
Return of the Zombie Ops - Mod
Modded by Lefti & 3aGl3
=========================================================================================
Airdrop Script
=======================================================================================*/
#include maps\mp\gametypes\_hud_util;
#include scripts\_utility;
#include scripts\_weapon_key;

init()
{
	if( isDefined(level.indoorMap) )
		return;
	
	precacheModel( "vehicle_littlebird_mp" );
	precacheModel( "com_plasticcase_black_big" );
		
	precacheString( &"ZMB_AIRDROP" );				// Emergency Airdrop
	precacheString( &"ZMB_CAREPACKAGE" );			// Carepackage
	precacheString( &"ZMB_PRESS_USE_TO_GAIN_A" );	// Hold [USE] to get an ammo refill.
	precacheString( &"ZMB_PRESS_USE_TO_GAIN" );		// Hold [USE] to gain a &&1.
	precacheString( &"ZMB_PRESS_USE_TO_GAIN_W" );	// Hold [USE] to exchange your weapon with a &&1.
	precacheString( &"ZMB_CAPTURED_CAREPACKAGE" );	// Carepackage captured!
	precacheString( &"ZMB_TEMP_WEAPON_GAINED" );	// Special weapon gained!
	precacheString( &"ZMB_AMMO_REFILLED" );			// Ammo refilled!
	
	precacheShader( "hud_icon_crate_ac130" );
	precacheShader( "hud_icon_crate_airdrop" );		// used in cp
	precacheShader( "hud_icon_crate_airstrike" );
	precacheShader( "hud_icon_crate_ammo" );
	precacheShader( "hud_icon_crate_artillery" );
	precacheShader( "hud_icon_crate_helicopter" );
	precacheShader( "hud_icon_crate_nuke" );
	precacheShader( "hud_icon_crate_pavelow" );
	precacheShader( "hud_icon_crate_predator" );
	precacheShader( "hud_icon_crate_sentry_gun" );
	precacheShader( "hud_icon_crate_weapon_minigun" );
	precacheShader( "hud_icon_crate_weapon_raygun" );
	precacheShader( "hud_icon_crate_weapon_tesla" );
	precacheShader( "hud_icon_crate_rcbomb" );
	
//	level._effect["airdrop_trap"] = loadFX( "explosions/tanker_explosion" );
	
	level.caseHideTags[0] = "tag_beige";
	level.caseHideTags[1] = "tag_friendly";
	level.caseHideTags[2] = "tag_enemy";
	level.caseHideTags[3] = "tag_trap";
	level.caseHideTags[4] = "tag_logo_usmc";
	level.caseHideTags[5] = "tag_logo_sas";
	level.caseHideTags[6] = "tag_logo_arab";
	level.caseHideTags[7] = "tag_logo_ussr";
	
	level.airdropInProgress["allies"] = false;
	level.airdropInProgress["axis"] = false;
	level.carepackInProgress["allies"] = false;
	level.carepackInProgress["axis"] = false;
	
	level.carepack_captime = 4;
	setDvarMinMax( "scr_streak_supply_height", 1400, 500, 2000 );
	if( !isdefined(level.carepack_spawn_height) )
		level.carepack_spawn_height = getDvarInt( "scr_streak_supply_height" );
	
	level.carepack_cont_ammo = xDvarBool( "scr_streak_supply_ammo", 1 );
	level.carepack_owner_time = xDvarInt( "scr_carepack_owner_time", 10000, 10000, 300000);
	level.carepack_steal = xDvarBool ( "scr_carepack_steal" ,1);
	
	//level.registerHardpoint//( name,			kills,	callThread,			title,					XP,	trigger,	icon,					sound )
	[[level.registerHardpoint]]( "carepackage",	xDvarInt( "scr_streak_supply_kills", 40 ), ::setCarePackagePoint, &"ZMB_CAREPACKAGE", "location_selector_mp" );
	[[level.registerHardpoint]]( "airdrop", xDvarInt( "scr_streak_airdrop_kills", 300 ), ::setAirdropPoint, &"ZMB_AIRDROP", "location_selector_mp" );
}

// Airdrop Scripts

setAirdropPoint( content )
{
	self endon( "death" );
	self endon( "disconnect" );
	self endon( "weapon_change" );
	
	if( isDefined(self.dropzone) || level.airdropInProgress[self.team] )
	{
		self iPrintLnBold( &"MP_N_NOT_AVAILABLE", &"ZMB_AIRDROP" );
		return false;
	}
	
	while( 1 )
	{
		self waittill( "grenade_fire", selector, weapname );
		if( weapname == "location_selector_mp" )
		{
			self.dropzone = spawn( "script_origin", self.origin );
			self thread confirmDroparea( selector, content );
			
			return true;
		}
		else
			return false;
	}
	
	return false;
}

confirmDroparea( selector, content )		// self = owner
{
	level endon( "game_ended" );
	self endon( "disconnect" );
	
	level.airdropInProgress[self.team] = true;
	
	selector waitTillNotMoving();
	self.dropzone.origin = selector.origin;
	
	wait 0.01+randomFloat(1);
	selector detonate();
	
	self createPlane( content );
}

createPlane( content )
{
	destination = (self.dropzone.origin[0], self.dropzone.origin[1], level.carepack_spawn_height);
	
	x = randomIntRange( 9900, 11000 );
	y = randomIntRange( 9900, 11000 );
	
	startPoint = destination-(x,y,0);
	endPoint = destination+(x,y,0);
	
	flyTime = 15;

	plane = spawn( "script_model", startPoint );
	plane setModel( "vehicle_ac130_low" );
	plane.angles = vectortoangles( vectornormalize(startPoint-endPoint) )-(0,90,0);
	
	plane moveTo( endPoint, flyTime );
	plane playLoopSound( "veh_ac130_flyby" );
	
	plane waitTillIsClose( destination, 100 );
	
	for( i=0; i<4; i++ )
	{
		dropPos = plane getTagOrigin( "tag_origin" );		// create a drop tag
		
		if( i==0 && isDefined(content) && content != "" )
			thread carepackageSetup( self, dropPos, content );
		else
			thread carepackageSetup( self, dropPos );
		
		self.dropzone.origin = self.dropzone.origin+(40,40,0);
		
		wait 0.1;
	}
	
	plane waitTillNotMoving();		// waittill( "move_done" );		we're not using this because it won't work...
	plane stopLoopSound();
	wait 0.1;
	plane delete();
	level.airdropInProgress[self.team] = false;
	
	if( isDefined(self.dropzone) )
		self.dropzone delete();
}

waitTillIsClose( origin, tolerance )
{
	self endon( "death" );
	
	for(;;)
	{
		if( distance2d(self.origin, origin) <= tolerance )
			break;
		
		wait 0.05;
	}
}


// Carepackage Scripts

setCarePackagePoint( content )
{
	self endon( "death" );
	self endon( "disconnect" );
	self endon( "weapon_change" );
	
	if( isDefined(self.dropzone) || level.carepackInProgress[self.team] )		// already one cp inbound
	{
		self iPrintLnBold( &"MP_N_NOT_AVAILABLE", &"ZMB_CAREPACKAGE" );
		return false;
	}
	
	while( 1 )
	{
		self waittill( "grenade_fire", selector, weapname );
		if( weapname == "location_selector_mp" )
		{
			self.dropzone = spawn( "script_origin", self.origin );
			self thread confirmDropzone( selector, content );
			
			if (self UseButtonPressed()) 
			{
    				self.crate_owneronly = true;
        				self iprintlnbold("This crate can only be picked up by you!");
      			} 
			else 
			{
       	 			self.crate_owneronly = false;
      			}			
			return true;
		}
		else
			return false;
	}	
	return false;
}

confirmDropzone( selector, content )		// self = owner
{
	level endon( "game_ended" );
	self endon( "disconnect" );
	
	selector waitTillNotMoving();
	self.dropzone.origin = selector.origin;
	
	wait 0.01+randomFloat(1);
	selector detonate();
	
	self createChopper( self.dropzone.origin, randomInt( 360 ), content );
}

createChopper( targetpos, chopperAngle, content )
{
	if( self.sessionstate != "playing" )
		return;
	
	level.carepackInProgress[self.pers["team"]] = true;

	x = targetpos[0];
	y = targetpos[1];
	z = level.carepack_spawn_height;
	droppos = (x,y,z);

	start = getStartEnd( droppos, chopperAngle );
	end = getStartEnd( start[1], chopperAngle );
	
	if( end[2] == 1 ) 
		start[1] = end[1];

	StartPoint = start[0];
	EndPoint = start[1];
	
	result = [];
	result[0] = StartPoint;
	result[1] = EndPoint;
	outcome = result[ randomInt( result.size ) ];

	StartPoint = StartPoint;	
	Endpoint = outcome;	

	owner = self;
    chopper = spawnHelicopter( owner, StartPoint, (0, chopperAngle, 0), "cobra_mp", "vehicle_littlebird_mp" );
		
	chopper.team = self.pers["team"];
	chopper playLoopSound( "mp_little_helicopter" );
	chopper.fakecrate = spawn( "script_model", chopper getTagOrigin("tag_ground") );
	chopper.fakecrate.angles = chopper getTagAngles("tag_ground");
	chopper.fakecrate setModel( "com_plasticcase_black_big" );
	chopper.fakecrate thread hidePartExpect( level.caseHideTags, "tag_beige" );
	chopper.fakecrate linkTo( chopper, "tag_ground" );
	chopper setdamagestage( 3 );

	chopperSpeed = 4000; 
	d = length( StartPoint - EndPoint );
	flyTime = ( d / chopperSpeed );
	
	chopper thread chopper_fly( self, EndPoint, flytime, targetpos, droppos, content );
}

chopper_fly( owner, exitNode, flytime, targetpos, droppos, content )
{
	self endon( "death" );
  	self notify( "flying");
	
	chopper_reset();
	chopper_speed = 100;
	chopper_accel = 30 + randomInt( 10 );

	self setspeed( chopper_speed, chopper_accel );	
	self setvehgoalpos( droppos, 1 );

	self waittill( "near_goal" ); 
	self notify( "path start" );
	
	if( isDefined(self.fakecrate) )
	{
		self.fakecrate unlink();
		self.fakecrate delete();
	}
	
	if( !isDefined(content) )
		content = getRandomContentCP();
	self thread carepackageSetup( owner, self getTagOrigin("tag_ground"), content );
	
	wait( 0.1 );
	self setspeed( chopper_speed, chopper_accel );	
	self setvehgoalpos( exitNode, 1 );
	self waittill( "goal" );
	
	if( isDefined(owner.dropzone) )
		owner.dropzone delete();
	
	self thread chopper_leave( exitNode, chopper_speed );
}

chopper_reset()
{
	self clearTargetYaw();
	self clearGoalYaw();
	self setspeed( 60, 25 );	
	self setyawspeed( 75, 45, 45 );
	self setmaxpitchroll( 30, 30 );
	self setneargoalnotifydist( 256 );
	self setturningability( 0.9 );
}

chopper_leave( exitNode, chopper_speed )
{
	self notify( "destintation reached" );
	self notify( "leaving" );
		
	chopper_reset();
	self setspeed( chopper_speed, 45 );	
	self setvehgoalpos( exitNode, 1 );
		
	level.carepackInProgress[ self.team ] = false;
	
	self notify( "death" );
	self delete();
	
	level notify( "carepackage_over" );
}

chopper_wait( waittime )
{
	self endon( "death" );
	self endon( "crashing" );
	self endon( "evasive" );
	
	wait( waittime );	
}

getStartEnd( targetpos, angle )
{
	forwardvector = anglestoforward( (0, angle, 0) );
	backpos = targetpos + vectormulti( forwardvector, -30000 );
	frontpos = targetpos + vectormulti( forwardvector, 30000 );
	fronthit = 0;

	trace = bulletTrace( targetpos, backpos, false, undefined );
	if( trace["fraction"] != 1 ) 
		start = trace["position"];
	else 
		start = backpos;

	trace = bulletTrace( targetpos, frontpos, false, undefined );
	if( trace["fraction"] != 1 )
	{
		endpoint = trace["position"];
		fronthit = 1;
	}
	else 
		endpoint = frontpos;

	startpos = start + vectormulti( forwardvector, -3000 );
	endpoint = endpoint + vectormulti( forwardvector, 3000 );
	pos[0] = startpos;
	pos[1] = endpoint;
	pos[2] = fronthit;
	
	return pos;
}

vectorMulti( vec, size )
{
	x = vec[0] * size;
	y = vec[1] * size;
	z = vec[2] * size;
	vec = (x,y,z);
	return vec;
}

// Crate Scripts

carepackageSetup( owner, dropPos, content )		// self = chopper
{
	if( !isDefined(content) )
		content = getRandomContent();
		
	crate = spawn( "script_model", dropPos );
	crate setModel( "com_plasticcase_black_big" );
	crate.angles = (0, randomInt(360), 0);
	crate hidePartExpect( level.caseHideTags, "tag_friendly" );
	crate.content = content;
	crate.owner = owner;

	crate.spawnTime = gettime();

	if (isdefined(crate.owner.crate_owneronly)) 
	{
   	 	crate.owneronly = crate.owner.crate_owneronly;
  	} 
	else 
	{
    		crate.owneronly = false;
  	}
	
	start = crate.origin;
	destination = owner.dropzone.origin;
	impactPos = destination;
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
	
	// spawn crates inside :-)
  	if ((impactPos[2] - destination[2]) > 250) 
	{
    		impactPos = destination;
	}
	
	time = calcTime( crate.origin, impactPos );
	
	crate moveTo( impactPos, time );
	wait( time+0.01 );
	crate playSound( "crate_hit_ground" );
	
	thread createPickup( crate );
}

createPickup( crate )
{
	crate.trigger = spawn( "trigger_radius", crate.origin, 0, 64, 64 );
	crate.trigger thread fakePickupString( crate.owner, crate.content );
	
	crate createWaypoint();
	
	crate thread deleteCrateTime( 120 );
	crate thread carepackage_think();
	crate thread deleteOnPickup();
}

deleteCrateTime( time )
{
	self endon( "death" );
	self endon( "pickup" );
	
	wait time;
	
	self deleteWaypoint();
	self notify( "pickup" );
}

carepackage_think()
{
	self.trigger endon( "death" );
	
	for(;;)
	{
		self.trigger waittill( "trigger", user );
		
		if( !isPlayer(user) || user.team != "allies" )
			continue;
		
		if( user useButtonPressed() && !isDefined(user.isUsingSomething) )
			user thread pickupCrate( self );
	}
}

pickupCrate( crate )		// self = user
{
//	self endon( "death" );
	self endon( "disconnect" );	

	cp_time = level.carepack_owner_time;
	takecp = level.carepack_steal;

	if (crate.owner != self) 
	{
		self iprintlnbold("This is "+crate.owner.name+"'s crate!!!");
	  
		if ( (gettime() - crate.spawnTime) < cp_time || crate.owneronly == true) 
		{
	    		self.isUsingSomething = true;
      			wait 0.5;
      			self.isUsingSomething = undefined;
      			return;
    		}
	}
	
	self disableWeapons( true );
	self.isUsingSomething = true;
	
	if( isDefined(self.pBar) )							// destroy any old progress bars
		self.pBar destroyElem();
	
	self.pBar = self createPrimaryProgressBar();		// create a progress bar for him
	
	percent = 0;
	while( isDefined(crate.trigger) && self useButtonPressed() && self isTouching(crate.trigger) && isAlive(self) )
	{
		if( self == crate.owner )			// the owner needs only half the time
		{
			percent += 1;
			wait (level.carepack_captime/200);
		}
		else if ( takecp == 1)
		{
			percent+=1;
			wait (level.carepack_captime/100);
		}
		else
		{
			iPrintLnBold ( "^2You can not pickup "+crate.owner.name+"  carepackage !" );
			break;
		}
		
		percent++;
		self.pBar updateBar( percent/100 );
		if( percent >= 100 )
			break;
	}
	self enableWeapons( true );
	self.isUsingSomething = undefined;
	self.pBar destroyElem();
	
	if( percent >= 100 && isDefined(crate) )
	{
		if( crate.content == "ammo" )
			self gainAmmoPackage( crate );
		else if( isSubStr( crate.content, "weapon" ) )
			self thread gainWeaponPackage( crate );
		else
			self gainCarePackage( crate );
	
		crate deleteWaypoint();
		crate notify( "pickup" );
	}
}

gainWeaponPackage( crate )
{
	self endon( "disconnect" );
	self endon( "death" );
	
	toks = strTok( crate.content, "_" );
	weapon = toks[1];
	for(;;)
	{
		self waittill( "weapon_change" );
		current = self getCurrentWeapon();
		if( current == "" || current == "none" )
			continue;
		
		if( weaponInventoryType( current ) == weaponInventoryType( getConsoleName(weapon) ) )
		{
			ammo = self getAmmoCount( current );
			self takeWeapon( current );
			
			self _giveWeapon( weapon );
			self _giveMaxAmmo( weapon );
			self _switchToWeapon( weapon );
			
			notifyData = spawnStruct();
			notifyData.titleText = &"ZMB_CAPTURED_CAREPACKAGE";
			notifyData.titleIsText = true;
			notifyData.notifyText = &"ZMB_TEMP_WEAPON_GAINED";
			notifyData.textIsString = true;
			notifyData.sound = "oldschool_pickup";
			//notifyData.iconName = level.hardpoints[ID]["icon"];
			
			self maps\mp\gametypes\_hud_message::notifyMessage( notifyData );
			
			self thread regainWeapon( getConsoleName(weapon), current, ammo );
			break;
		}
	}
}

gainAmmoPackage( crate )
{
	self endon( "disconnect" );
	self endon( "death" );
	
	weapons = self getWeaponsList();
	for( i=0; i<weapons.size; i++ )
	{
		self iPrintLn( weapons[i] );
		self giveMaxAmmo( weapons[i] );		
	}	
	
	notifyData = spawnStruct();
	notifyData.titleText = &"ZMB_CAPTURED_CAREPACKAGE";
	notifyData.titleIsText = true;
	notifyData.notifyText = &"ZMB_AMMO_REFILLED";
	notifyData.textIsString = true;
	notifyData.sound = "ammo_crate_use";
	//notifyData.iconName = level.hardpoints[ID]["icon"];
	
	self maps\mp\gametypes\_hud_message::notifyMessage( notifyData );
}

gainCarePackage( crate )
{
	self endon( "disconnect" );
	self endon( "death" );
	
	ID = maps\mp\gametypes\_hardpoints::getHardpointID( crate.content );
	
	if( isDefined(self.pers["hardPointItem"]) )
		self.hardpoints[self.hardpoints.size] = self.pers["hardPointItem"];
	
	self maps\mp\gametypes\_hardpoints::giveHardpointItem( ID );
	self carePackageNotify( ID );
}

carePackageNotify( ID )
{
	self endon("disconnect");

//	wait .05;

	notifyData = spawnStruct();
	notifyData.titleText = &"ZMB_CAPTURED_CAREPACKAGE";
	notifyData.titleIsText = true;
	notifyData.textLabel = &"MP_STREAK_N_IS_READY";
	notifyData.notifyText = level.hardpoints[ID]["title"];
	notifyData.textIsString = true;
	notifyData.sound = level.hardpoints[ID]["inform"];
	notifyData.iconName = level.hardpoints[ID]["icon"];
	
	self maps\mp\gametypes\_hud_message::notifyMessage( notifyData );
}

// MISC
getRandomContent()
{
	value = randomInt( 100 );
	
	if( value <= 10 )	// epic stuff
	{
		candidate[0] = "nuke";
		candidate[1] = "weapon_minigun";
		candidate[2] = "weapon_tesla";
		
		result = candidate[randomInt(candidate.size)];
	}
	else if( value > 10 && value <= 30 )	// rare stuff
	{
		candidate[0] = "ac130_gunner";
		candidate[1] = "pavelow";
		candidate[2] = "weapon_raygun";
		
		result = candidate[randomInt(candidate.size)];
	}
	else if( value > 30 && value <= 60 )	// normal stuff
	{
		candidate[0] = "airstrike";
		candidate[1] = "artillery";
		candidate[2] = "helicopter";
		candidate[3] = "rcbomb";
		
		result = candidate[randomInt(candidate.size)];
	}
	else	// crap
	{
		candidate[0] = "predator";
		candidate[1] = "sentry_gun";
		
		if( level.carepack_cont_ammo )
			candidate[2] = "ammo";
		
		result = candidate[randomInt(candidate.size)];
	}
	//result = "weapon_minigun";
	
	if( !isSubStr( result, "weapon" ) && result != "ammo" )
		result = level.hardpoints[maps\mp\gametypes\_hardpoints::getHardpointID( result )]["name"];		// we're doing this so we make a content valid
	
	return result;
}
getRandomContentCP()
{
	value = randomInt( 100 );
	
	if( value <= 10 )	// epic stuff
	{
		candidate[0] = "airdrop";
		candidate[1] = "weapon_minigun";
		candidate[2] = "weapon_tesla";
		
		result = candidate[randomInt(candidate.size)];
	}
	else if( value > 10 && value <= 30 )	// rare stuff
	{
		candidate[0] = "ac130_gunner";
		candidate[1] = "pavelow";
		candidate[2] = "weapon_raygun";
		
		result = candidate[randomInt(candidate.size)];
	}
	else if( value > 30 && value <= 60 )	// normal stuff
	{
		candidate[0] = "airstrike";
		candidate[1] = "artillery";
		candidate[2] = "helicopter";
		candidate[3] = "rcbomb";
		
		result = candidate[randomInt(candidate.size)];
	}
	else	// crap
	{
		candidate[0] = "predator";
		candidate[1] = "sentry_gun";
		
		if( level.carepack_cont_ammo )
			candidate[2] = "ammo";
		
		result = candidate[randomInt(candidate.size)];
	}
	//result = "weapon_minigun";
	
	if( !isSubStr( result, "weapon" ) && result != "ammo" )
		result = level.hardpoints[maps\mp\gametypes\_hardpoints::getHardpointID( result )]["name"];		// we're doing this so we make a content valid
	
	return result;
}

calcTime( startpos, endpos )
{
	distvalue = distance( startpos, endpos );
	timeinsec = distvalue/getDvarInt( "g_gravity" );
	
	if( timeinsec <= 0 ) 
		timeinsec = 0.1;
	
	return timeinsec;
}

getPickupString( content )
{
	string = "";
	if( isSubStr( content, "weapon" ) )
	{
		toks = strTok( content, "_" );
		string = tableLookupIString( "mp/statsTable.csv", 4, toks[1], 3 );
	}
	else
	{
		for( i=0; i<level.hardpoints.size; i++ )
		{
			if( level.hardpoints[i]["name"] == content )
			{
				string = level.hardpoints[i]["title"];
				break;
			}
		}
	}
	
	return string;
}

deleteOnPickup()
{
	level endon( "game_ended" );
	
	self waittill( "pickup" );
	
	if( isDefined(self.trigger) )
		self.trigger delete();
		
	if( isDefined(self) )
		self delete();
}

fakePickupString( owner, content )
{
	self endon( "death" );
	
	if( content == "ammo" )
	{
		hintString = &"ZMB_PRESS_USE_TO_GAIN_A";
		hintValue = "";
	}
	else if( isSubStr( content, "weapon" ) )
	{
		hintString = &"ZMB_PRESS_USE_TO_GAIN_W";
		hintValue = getPickupString( content );
	}
	else
	{
		hintString = &"ZMB_PRESS_USE_TO_GAIN";
		hintValue = getPickupString( content );
	}
	
	for(;;)
	{
		self waittill( "trigger", user );
		
		if( !isPlayer(user) || user.team != "allies" )
			continue;
		
		if( level.teambased )
		{
			user.lowerMessage.label = hintString;
			if( isDefined(hintValue) )
				user.lowerMessage setText( hintValue );
			else
				user.lowerMessage setText( "" );
			
			user.lowerMessage.alpha = 1;
			user.lowerMessage FadeOverTime( 0.05 );
			user.lowerMessage.alpha = 0;
		}
		else		// Free For All
		{
			user.lowerMessage.label = hintString;
			if( isDefined(hintValue) )
				user.lowerMessage setText( hintValue );
			else
				user.lowerMessage setText( "" );
			
			user.lowerMessage.alpha = 1;
			user.lowerMessage FadeOverTime( 0.05 );
			user.lowerMessage.alpha = 0;
		}
	}
}

createWaypoint()
{
	if( isSubStr( self.content, "ac130" ) )
		shader = "hud_icon_crate_ac130";
	else if( isSubStr( self.content, "sentry" ) )
		shader = "hud_icon_crate_sentry_gun";
	else
		shader = "hud_icon_crate_"+self.content;
	
	self.waypoint = newHudElem();
	self.waypoint.x = self.origin[0];
	self.waypoint.y = self.origin[1];
	self.waypoint.z = self.origin[2]+16;
	self.waypoint.alpha = .9;
	self.waypoint.archived = true;
	self.waypoint setShader( shader, 25, 25 );
	self.waypoint setWaypoint( true, shader );
}

deleteWaypoint()
{
	if( isDefined(self.waypoint) ) 
		self.waypoint destroy();
}