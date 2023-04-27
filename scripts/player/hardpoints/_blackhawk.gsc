#include scripts\_utility;
#include scripts\_weapon_key;
#include common_scripts\utility;

init()
{
	if( isDefined(level.noBlackhawk) )			// for example mp_inferno doesn't supports the blackhawk
		return;
	
	path_start = getentarray( "heli_start", "targetname" );
	loop_start = getentarray( "heli_loop_start", "targetname" );
	
	if( !path_start.size && !loop_start.size)
		return;
	
	precacheModel( "vehicle_blackhawk" );
	precacheString( &"ZMB_BLACKHAWK" );
	
	level.ownerhealth 					= xDvarInt( "scr_streak_blackhawk_phealth", 200, 100, 999999 );
	level.blackhawk_loops 				= xDvarInt( "scr_streak_blackhawk_loops", 4, 4, 40 );
	level.blackhawk_armour 				= xDvarInt( "scr_streak_blackhawk_armour", 1200, 1, 999999 );
	level.blackhawk_maxhealth 			= xDvarInt( "scr_streak_blackhawk_health", 3500, 1, 999999 );
	level.blackhawk_dest_wait 			= xDvarFloat( "scr_streak_blackhawk_wait", 3, 0.05, 60 );
	level.blackhawk_player_time 		= xDvarInt( "scr_streak_blackhawk_time", 60, 30, 360 );
	level.blackhawk_health_degrade		= xDvarInt( "scr_streak_blackhawk_healthd", 0, 0, 999999 );
	level.blackhawk_armour_bulletdamage	= xDvarFloat( "scr_streak_blackhawk_bullet", 0.3, 0.01, 100 );
	level.blackhawk_inf_clip 			= xDvarBool( "scr_streak_blackhawk_iclip", 1 );
	level.blackhawk_multi 				= xDvarBool( "scr_streak_blackhawk_multi", 0 );
	level.heli_multi 					= xDvarBool( "scr_streak_heli_multi", 0 );

	level.blackhawk_player = undefined;
	level.blackhawk = undefined;
	level.blackhawk_doom = undefined;
	
	//level.registerHardpoint//( name,			kills,	callThread,			title,					XP,	trigger,	icon,					sound )
	[[level.registerHardpoint]]( "blackhawk", xDvarInt( "scr_streak_blackhawk_kills", 350 ), ::callBlackhawk,	&"ZMB_BLACKHAWK",	"radar_mp",	"compass_objpoint_helicopter" );
}

callBlackhawk()
{
	if( isDefined(level.blackhawk_player) && !level.blackhawk_multi )		// already one blackhawk in the airspace
		return false;
		
	if( isDefined(self.insideKillstreak) )		// already inside a killstreak
		return false;
	
	heli_think( self, level.heli_paths[0][randomint(level.heli_paths.size)], self.team );
	return true;
}

spawn_helicopter( owner, origin, angles, model, targetname )
{
	chopper = spawnHelicopter( owner, origin, angles, model, targetname );
	chopper.attractor = Missile_CreateAttractorEnt( chopper, level.heli_attract_strength, level.heli_attract_range );
	
	return chopper;
}

heli_think( owner, startnode, heli_team )
{
	heliOrigin = startnode.origin;
	heliAngles = startnode.angles;
	
	chopper = spawn_helicopter( owner, heliOrigin, heliAngles, "cobra_mp", "vehicle_blackhawk" );
	chopper playLoopSound( "mp_cobra_helicopter" );
	
	/*players = getEntarray( "player", "classname" );
	for( i = 0; i < players.size; i++ )
	{
		player = players[i];
		player setClientDvar( "ui_compass_helicopter", 1 );
		player setClientDvar( "ui_compass_harrier", 0 );
	}*/
	
	chopper.aimoffset = (-88,0,-64);
	chopper.requiredDeathCount = owner.deathCount;
	chopper.score = 60;
	
	chopper.team = heli_team;
	chopper.pers["team"] = heli_team;
	
	chopper.donottarget = false;
	chopper.owner = owner;
	
	chopper thread heli_existance();
	
	if( !level.teamBased || !level.blackhawk_multi )
		heli_team = "none";
	
	level.blackhawk = chopper;
	
	level.blackhawk_doom = chopper;
	level.blackhawk_player  = true;
	
	chopper.reached_dest = false;
	chopper.maxhealth = level.blackhawk_maxhealth;
	chopper.waittime = level.blackhawk_dest_wait;
	chopper.loopcount = 0;
	chopper.evasive = false;
	chopper.health_bulletdamageble = level.blackhawk_armour;
	chopper.health_evasive = level.blackhawk_armour;
	chopper.health_low = level.blackhawk_maxhealth*0.8;
	chopper.attacker = undefined;
	chopper.currentstate = "ok";
	chopper.attackerweap = "";
	chopper.islockedon = false;
	chopper.crashing = false;
	
	owner thread get_to_tha_chopper( chopper );
	
	chopper thread heli_fly(startnode);
	chopper thread heli_damage_monitor();
	chopper thread heli_health();
	chopper thread force_heli_leave( level.blackhawk_player_time , owner );
}

miniguns( chopper, player )
{
	placeMG( chopper, player );
	placeMG_2( chopper, player );
}

placeMG( chopper , player )
{
	saw = spawnTurret( "turret_mp", chopper getTagOrigin("tag_gun_r"), "saw_bipod_stand_mp" );
	saw.angles = chopper getTagAngles("tag_gun_r");
	saw linkTo( chopper, "tag_gun_r", (0,0,0), (0,0,0) );
	
	saw setModel( "weapon_saw_mg_setup" );
	/*saw setLeftArc( 45 );
	saw setRightArc( 45 );
	saw setTopArc( 25 );
	saw setBottomArc( 10 );*/
	//saw.weaponinfo = "saw_bipod_crouch_mp";
	chopper.minigun1 = saw;
}

placeMG_2( chopper, player )
{
	saw = spawnTurret( "turret_mp", chopper getTagOrigin("tag_gun_l") , "saw_bipod_crouch_mp" );
	saw.angles = chopper getTagAngles("tag_gun_l");
	saw linkTo( chopper, "tag_gun_l", (0,0,0), (0,0,0) );
	
	saw setmodel( "weapon_saw_mg_setup" );
	/*saw setLeftArc( 45 );
	saw setRightArc( 45 );
	saw setTopArc( 25 );
	saw setBottomArc( 10 );*/
	//saw2.weaponinfo = "saw_bipod_crouch_mp";
	chopper.minigun2 = saw;
}

force_heli_leave( time, owner )
{
	wait( time );

	if( isDefined(self) )
	{
		owner notify("left_chopper");
		owner notify( "blackhawk_respawn" );

		self notify( "abandoned" );
		self notify( "leaving" );
		self notify( "death" );

		level.blackhawk = undefined;
		level.blackhawk_doom = undefined;
		level.blackhawk_player  = undefined;
		self.owner = undefined;
		self heli_leave( self );
		
	}
}

on_leave()
{
	self waittill_any( "death", "leaving" );
	self notify( "blackhawk gone" );
}

on_crash()
{
	self endon("death");
	self endon("leaving");
	self waittill("crashing");
	self notify("blackhawk crashing");
}

heli_existance()
{
	self waittill_any( "death", "crashing", "leaving" );
	self.donottarget = true;
	self.crashing = true;
	level notify( "blackhawk gone" );
}

heli_reset()
{
	self clearTargetYaw();
	self clearGoalYaw();
	self setspeed( 60, 25 );
	self setyawspeed( 75, 45, 45 );
	self setmaxpitchroll( 30, 30 );
	self setneargoalnotifydist( 256 );
	self setturningability(0.9);
}

heli_wait( waittime )
{
	self endon ( "death" );
	self endon ( "crashing" );
	self endon ( "evasive" );
	wait( waittime );
}

heli_hover()
{
	self endon( "death" );
	self endon( "stop hover" );
	self endon( "evasive" );
	self endon( "leaving" );
	self endon( "crashing" );
	original_pos = self.origin;
	original_angles = self.angles;
	self setyawspeed( 10, 45, 45 );
	x = 0;
	y = 0;
}

heli_damage_monitor()
{
	self endon( "death" );
	self endon( "crashing" );
	self endon( "leaving" );
	self.damageTaken = 0;
	for( ;; )
	{
	self waittill( "damage", damage, attacker, direction_vec, P, type );
	if(!isDefined(attacker))
	continue;
	if(attacker.classname != "script_vehicle" && attacker.classname != "player")
	continue;
	if(!isPlayer(attacker) && damage < 30)damage = 30;
	heli_friendlyfire = maps\mp\gametypes\_weapons::friendlyFireCheck( self.owner, attacker );
	if( !heli_friendlyfire )
	continue;
	if(isDefined(self.owner) && attacker == self.owner)
	continue;
	if(attacker.classname == "script_vehicle" && isDefined(attacker.owner) && attacker.owner == self.owner)
	continue;
	
	if(damage < 5)
		continue;
	
	if ( level.teamBased )
	isValidAttacker = (isdefined(attacker.pers["team"]) && attacker.pers["team"] != self.team);
	
	else 
	{
	isValidAttacker = true;
	}
	
	if ( !isValidAttacker )
	continue;
	
	if(isPlayer(attacker))
	{
	attacker thread maps\mp\gametypes\_damagefeedback::updateDamageFeedback(false);
	if(type == "MOD_RIFLE_BULLET" || type == "MOD_PISTOL_BULLET")
	self.attackerweap = attacker getCurrentWeapon();
	else 
	self.attackerweap = "";
	self.attacker = attacker;
	self.ownerattacker = attacker;
	}
	
	else
	{
	self.attackerweap = "cobra_20mm_mp";
	self.attacker = attacker;
	self.ownerattacker = attacker.owner;
	}
	
	if(type == "MOD_RIFLE_BULLET" || type == "MOD_PISTOL_BULLET")
	{
	if( self.damageTaken >= self.health_bulletdamageble )
	self.damageTaken += damage;
	else
	self.damageTaken += damage*level.blackhawk_armour_bulletdamage;
	}
	else self.damageTaken += damage;
	if( self.damageTaken > self.maxhealth )
	attacker notify( "destroyed_helicopter" );
	}
}

heli_health()
{
	self endon( "death" );
	self endon( "leaving" );
	self endon( "crashing" );
	self.currentstate = "ok";
	self.laststate = "ok";
	self setdamagestage( 3 );
	for ( ;; )
	{
	if ( self.health_bulletdamageble > self.health_low )
	{
	if ( self.damageTaken >= self.health_bulletdamageble )
	self.currentstate = "heavy smoke";
	else 
	if ( self.damageTaken >= self.health_low )
	self.currentstate = "light smoke";
	}
	else
	{
	if ( self.damageTaken >= self.health_low )
	self.currentstate = "heavy smoke";
	else
	 if ( self.damageTaken >= self.health_bulletdamageble )
	self.currentstate = "light smoke";
	}
	if ( self.currentstate == "light smoke" && self.laststate != "light smoke" )
	{
	self setdamagestage( 2 );
	self.laststate = self.currentstate;
	}
	if ( self.currentstate == "heavy smoke" && self.laststate != "heavy smoke" )
	{
	self setdamagestage( 1 );
	self notify ( "stop body smoke" );
	self.laststate = self.currentstate;
	}
	if ( self.currentstate == "heavy smoke" )
	self.damageTaken += level.blackhawk_health_degrade;
	if ( self.currentstate == "light smoke" )
	self.damageTaken += level.blackhawk_health_degrade/2;
	if( self.damageTaken >= self.health_evasive )
	{
	if( !self.evasive )self thread heli_evasive();
	}
	if( self.damageTaken > self.maxhealth )
	self thread heli_crash();
	wait 1;
	}
}

heli_evasive()
{
	self notify( "evasive" );
	self.evasive = true;
	loop_startnode = level.heli_loop_paths[0];
	self thread heli_fly( loop_startnode );
}

heli_crash()
{
	self notify( "crashing" );
	self thread heli_fly( level.heli_crash_paths[0]);
	self thread heli_spin( 180 );
	self waittill ( "path start" );
	playfxontag( level.chopper_fx["explode"]["large"], self, "tag_engine_left" );
	self playSound ( level.heli_sound[self.team]["hitsecondary"] );
	self setdamagestage( 0 );
	self thread trail_fx( level.chopper_fx["fire"]["trail"]["large"], "tag_engine_left", "stop body fire" );
	self notify( "kill_owner", self.ownerattacker );
	self waittill( "destination reached" );
	self thread heli_explode();
}

heli_spin( speed )
{
	self endon( "death" );
	playfxontag( level.chopper_fx["explode"]["medium"], self, "tail_rotor_jnt" );
	self playSound ( level.heli_sound[self.team]["hit"] );
	self thread spinSoundShortly();
	self thread trail_fx( level.chopper_fx["smoke"]["trail"], "tail_rotor_jnt", "stop tail smoke" );
	self setyawspeed( speed, speed, speed );
	while ( isdefined( self ) )
	{
	self settargetyaw( self.angles[1]+(speed*0.9) );
	wait ( 1 );
	}
}

spinSoundShortly()
{
	self endon("death");
	wait .25;
	self stopLoopSound();
	wait .05;
	self playLoopSound( level.heli_sound[self.team]["spinloop"] );
	wait .05;
	self playSound( level.heli_sound[self.team]["spinstart"] );
}

trail_fx( trail_fx, trail_tag, stop_notify )
{
	self notify( stop_notify );
	self endon( stop_notify );
	self endon( "death" );
	for ( ;; )
	{
	playfxontag( trail_fx, self, trail_tag );
	wait( 0.05 );
	}
}

heli_explode()
{
	self notify( "death" );
	forward = ( self.origin + ( 0, 0, 100 ) ) - self.origin;
	playfx ( level.chopper_fx["explode"]["death"], self.origin, forward );
	self playSound( level.heli_sound[self.team]["crash"] );
	team = self.pers["team"];
	if(!level.teamBased || !level.blackhawk_multi)
	team = "none";
	level.blackhawk = undefined;
	level.blackhawk_doom = undefined;
	level.blackhawk_player  = undefined;
	//level.minigun1 delete();
	//level.minigun2 delete();
	self delete();
}

heli_leave( chopper )
{
	self notify( "desintation reached" );
	self notify( "leaving" );
	if(isDefined(level.heli_leavenodes) && level.heli_leavenodes.size)
	{
		random_leave_node = randomInt( level.heli_leavenodes.size );
		leavenode = level.heli_leavenodes[random_leave_node];
		heli_reset();
		level.blackhawk = undefined;
		level.blackhawk_doom = undefined;
		level.blackhawk_player  = undefined;
		self setspeed( 100, 45 );
		self setvehgoalpos( leavenode.origin, 1 );
		self waittillmatch( "goal" );
	}
	self notify( "death" );
	
	team = self.pers["team"];
	if(!level.teamBased || !level.blackhawk_multi)team = "none";
	level.blackhawk = undefined;
	level.blackhawk_doom = undefined;
	level.blackhawk_player  = undefined;
	//level.minigun1 delete();
	//level.minigun2 delete();
	self delete();
}

heli_fly( currentnode )
{
	self endon( "death" );
	self notify( "flying");
	self endon( "flying" );
	self endon( "abandoned" );
	self.reached_dest = false;
	heli_reset();
	pos = self.origin;
	wait( 2 );
	while ( isdefined( currentnode.target ) )
	{
	nextnode = getent( currentnode.target, "targetname" );
	assertex( isdefined( nextnode ), "Next node in path is undefined, but has targetname" );
	pos = nextnode.origin+(0,0,30);
	if( isdefined( currentnode.script_airspeed ) && isdefined( currentnode.script_accel ) )
	{
	heli_speed = currentnode.script_airspeed;
	heli_accel = currentnode.script_accel;
	}
	else {
	heli_speed = 30+randomInt(20);
	heli_accel = 15+randomInt(15);
	}
	if ( !isdefined( nextnode.target ) )
	stop = 1;
	else
	stop = 0;
	if( self.currentstate == "heavy smoke" || self.currentstate == "light smoke" )
	{
	self setspeed( heli_speed, heli_accel );
	self setvehgoalpos( (pos), stop );
	self waittill( "near_goal" );
	self notify( "path start" );
	}
	else 
	{
	if( isdefined( nextnode.script_delay ) )
	stop = 1;
	self setspeed( heli_speed, heli_accel );
	self setvehgoalpos( (pos), stop );
	if ( !isdefined( nextnode.script_delay ) )
	{
	self waittill( "near_goal" );
	self notify( "path start" );
	}
	else {
	self setgoalyaw( nextnode.angles[1] );
	self waittillmatch( "goal" );
	heli_wait( nextnode.script_delay );
	}
	}
	for( index = 0; index < level.heli_loop_paths.size; index++ )
	{
	if ( level.heli_loop_paths[index].origin == nextnode.origin )
	self.loopcount++;
	}
	if( self.loopcount >= level.blackhawk_loops )
	{
	self thread heli_leave();
	return;
	}
	currentnode = nextnode;
	}
	self setgoalyaw( currentnode.angles[1] );
	self.reached_dest = true;
	self notify ( "destination reached" );
	heli_wait( self.waittime );
	if( isdefined( self ) )
	self thread heli_evasive();
}

check_owner()
{
	if ( !isdefined( self.owner ) || !isdefined( self.owner.pers["team"] ) || self.owner.pers["team"] != self.team )
	{
		self notify ( "abandoned" );
		self thread heli_leave( self );
	}
}

get_to_tha_chopper(chopper)
{
	self iPrintlnBold( "Press MELEE to switch seats" );
	
	self.insideKillstreak = "blackhawk";
	self.isTargetable = false;		// zombies won't notice us anymore!
	self.blackhawkkills = 0;
	

	loadout = self getweaponslist();
	laodoutAmmo = [];
	for( i=0; i<loadout.size; i++ )
	{
		laodoutAmmo[i] = self getammocount( loadout[i] );
	}
	
	self thread respawn( loadout, laodoutAmmo, self.origin );
	self thread giveloadout();
	self thread killowner(chopper);
	self thread linktoblackhawk(chopper);
	self thread monitorowner(chopper);
	
	self.crap = self.maxhealth;
	self.maxhealth = 99999;
	self.health = self.maxhealth;
}

monitorowner(chopper)
{
	chopper endon("death");
	chopper endon("leaving");
	chopper endon("kill_owner");
	
	while(1)
	{
		wait 0.05;
		chopper check_owner();
		if( !isPlayer(self) || self.sessionstate != "playing" )
			break;
		
		weap = self getcurrentweapon();
		if( level.blackhawk_inf_clip )
			self setweaponammoclip( weap, 999 );
			
		stance = self getStance();
		docmd = false;
		if(stance == "stand")
		{
			self setClientDvar("clientcmd","lowerstance");
			docmd = true;
		}
		else if(stance == "prone")
		{
			self setClientDvar("clientcmd","raisestance");
			docmd = true;
		}
		
		if(docmd)
		{
			self openMenu("clientcmd");
			self closeMenu("clientcmd");
		}
	}
}

giveloadout()
{
	self endon("left_blackhawk");
	self endon("death");
	self endon("joined_spectators");
	self endon("spawned");
	self endon("disconnect");
	
	self takeAllWeapons();
	
	//if( getDvarInt("scr_enable_nightvision") )
	//	self setActionSlot(1, "nightvision");
	
	self clearPerks();
	
	self setPerk( "specialty_bulletpenetration" );
	self setPerk( "specialty_bulletaccuracy" );
	self setPerk( "specialty_rof" );
	self setPerk( "specialty_bulletdamage" );
	
//	self giveWeapon( "barrett_mp" );
	self giveWeapon( "minigun_mp" );
	self switchToWeapon( "minigun_mp" );
}

killowner(chopper)
{
	self endon("death");
	self endon("joined_spectators");
	self endon("spawned");
	self endon("disconnect");
	chopper endon("death");
	chopper endon("leaving");
	
	chopper waittill( "kill_owner", attacker );
	
	self unlink();
	
	chopper.linker unlink();
	chopper.linker delete();
	chopper.killedowner = true;
	self.insideKillstreak = undefined;
	level.blackhawk = undefined;
	level.blackhawk_doom = undefined;
	level.blackhawk_player  = undefined;
	
	self notify( "stop_blackhawk" );
	self suicide();
}


linktoblackhawk( chopper )
{
	chopper endon("death");
	chopper endon("crashing");
	
	chopper.linker = spawn( "script_origin", chopper getTagOrigin("tag_guy4") );
	chopper.linker setContents(0);
	chopper.linker linkTo( chopper, "tag_guy4", (12,-26,-16), (0,0,0) );
	
	self setOrigin( chopper.linker.origin );
	self setPlayerAngles( chopper.angles );
	self linkto( chopper.linker );
	
	self thread waitforseatchange(chopper);
	self execClientCmd( "gocrouch" );
	
	chopper waittill( "leaving" );
	
	self execClientCmd( "-attack" );
	
	if( isPlayer(self) )
	{
		self unlink();
		if( self.sessionstate == "playing" )
			self notify( "blackhawk_respawn" );;
	}
	
	chopper.linker unlink();
	chopper.linker delete();
}


waitforseatchange(chopper)
{
	chopper endon("kill_owner");
	chopper endon("death");
	chopper endon("leaving");
	self endon("death");
	self endon("disconnect");
	self endon("joined_spectators");
	self endon("spawned");
	
	seat = 1;
	while(1)
	{
		wait 0.05;
		if(self meleeButtonPressed())
		{
			chopper.linker unlink();
			if(seat)
			{	
				chopper.linker linkTo(chopper,"tag_guy6",(12,26,-16),(0,0,0));
			}
			else
			{
				chopper.linker linkTo(chopper,"tag_guy4",(12,-26,-16),(0,0,0));
			}
			
			seat = !seat;
			while( self meleeButtonPressed() )
				wait 0.05;
		}
	}
}

respawn( loadout, ammocount, origin )
{
	self waittill( "blackhawk_respawn" );
	
	self notify( "stop_stow" );
	self.insideKillstreak = undefined;
	self.blackhawkkills = 0;
	self.isTargetable = true;
	
	self notify( "stop_blackhawk" );
	self thread maps\mp\gametypes\_weapons::updateStowedWeapon();
	//self maps\mp\gametypes\_teams::playerModelForWeapon( self.pers["primaryWeapon"] );
	
	self.maxhealth = self.crap;
	self.health = self.maxhealth;
	self execClientCmd( "-attack" );
	level.blackhawk = undefined;
	level.blackhawk_doom = undefined;
	level.blackhawk_player  = undefined;
	
	//spawnPoints = maps\mp\gametypes\_spawnlogic::getTeamSpawnPoints( self.pers["team"] );
	//spawnPoint = maps\mp\gametypes\_spawnlogic::getSpawnpoint_NearTeam( spawnPoints );
	
	spawnpoints = [];
	for( i=0; i<level.playerspawns.size; i++ )
	{
		if( level.playerspawns[i].enabled )
			spawnpoints[spawnpoints.size] = level.playerspawns[i];
	}
	spawnpoint = spawnpoints[randomInt(spawnpoints.size)];
	
	wait 1;
	
	self unlink();
	self setorigin( spawnpoint.origin );
	self setplayerangles( spawnpoint.angles );
	
	self takeAllWeapons();
	
	for( i=0; i<loadout.size; i++ )
	{
		weapon = loadout[i];
		
		if( weapon == "none" || weapon == "" || weapon == "radar_mp" || weapon == "location_selector_mp" )
			continue;
		
		self giveWeapon( weapon );
		self setWeaponAmmoOverall( getScriptName(weapon), ammocount[i] );
		
		if( weaponinventorytype( weapon ) == "primary" )
			self switchToWeapon( weapon );
		else if( weaponinventorytype( weapon ) == "item" )
			self _setActionSlot( 2, "weapon", getScriptName(weapon) );
		else if( weapon == "frag_grenade_mp" || weapon == "frag_grenade_short_mp" )
			self switchToOffhand( weapon );
	}
	self setoffhandsecondaryclass( "flash" );
	self.specialty = [];
	self scripts\player\perks\_perks::executePerksFormVar();
}

