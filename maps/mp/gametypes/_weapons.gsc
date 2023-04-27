/*=======================================================================================
Return of the Zombie Ops - Mod
Modded by Lefti & 3aGl3
=========================================================================================
Zombie Weapons
=======================================================================================*/
#include common_scripts\utility;
#include scripts\_utility;
#include scripts\_weapon_key;

init()
{
	// assigns weapons with stat numbers from 0-149
	// attachments are now shown here, they are per weapon settings instead
	
	// generating weaponIDs array
	level.weaponIDs = [];
	max_weapon_num = 79;
	attachment_num = 80;
	for( i = 0; i <= max_weapon_num; i++ )
	{
		weapon_name = tablelookup( "mp/statstable.csv", 0, i, 4 );
		if( !isdefined( weapon_name ) || weapon_name == "" )
		{
			level.weaponIDs[i] = "";
			continue;
		}
		level.weaponIDs[i] = weapon_name;
		
		// generating attachment combinations
		attachment = tablelookup( "mp/statstable.csv", 0, i, 8 );
		if( !isdefined( attachment ) || attachment == "" )
			continue;
			
		attachment_tokens = strtok( attachment, " " );
		if( !isdefined( attachment_tokens ) )
			continue;
			
		if( attachment_tokens.size == 0 )
		{
			level.weaponIDs[attachment_num] = weapon_name + "_" + attachment;
			attachment_num++;
		}
		else
		{
			for( k = 0; k < attachment_tokens.size; k++ )
			{
				level.weaponIDs[attachment_num] = weapon_name + "_" + attachment_tokens[k];
				attachment_num++;
			}
		}
	}

	// generating weaponNames array
	level.weaponNames = [];
	for ( index = 0; index < max_weapon_num; index++ )
	{
		if ( !isdefined( level.weaponIDs[index] ) || level.weaponIDs[index] == "" )
			continue;
			
		level.weaponNames[level.weaponIDs[index]] = index;
	}
	
	// generating weaponlist array
	level.weaponlist = [];
	assertex( isdefined( level.weaponIDs.size ), "level.weaponIDs is corrupted" );
	for( i = 0; i < level.weaponIDs.size; i++ )
	{
		if( !isdefined( level.weaponIDs[i] ) || level.weaponIDs[i] == "" )
			continue;

		level.weaponlist[level.weaponlist.size] = level.weaponIDs[i];
	}

	// based on weaponList array, precache weapons in list
	for ( index = 0; index < level.weaponlist.size; index++ )
	{
		_precacheItem( level.weaponlist[index] );
	}
	
	precacheItem( "destructible_car" );	
	
	precacheModel( "weapon_rpg7_stow" );
	
	precacheShellShock( "default" );
	precacheShellShock( "concussion_grenade_mp" );

	thread maps\mp\_flashgrenades::main();
//	thread maps\mp\_teargrenades::main();
//	thread maps\mp\_entityheadicons::init();

	claymoreDetectionConeAngle = 70;
	level.claymoreDetectionDot = cos( claymoreDetectionConeAngle );
	level.claymoreDetectionMinDist = 20;
	level.claymoreDetectionGracePeriod = .75;
	level.claymoreDetonateRadius = 192;
	
	level.C4FXid = loadfx( "misc/light_c4_blink" );
	level.claymoreFXid = loadfx( "misc/claymore_laser" );
	
	level thread onPlayerConnect();
	
	level.c4explodethisframe = false;
}


onPlayerConnect()
{
	for(;;)
	{
		level waittill( "connected", player );
		
		player.usedWeapons = false;
		player.hits = 0;

		player thread onPlayerSpawned();
	}
}

onPlayerSpawned()
{
	self endon("disconnect");

	for(;;)
	{
		self waittill("spawned_player");
		
		self.concussionEndTime = 0;
		self.hasDoneCombat = false;
		self thread watchGrenadeUsage();
		
		self thread updateStowedWeapon();
	}
}

//  weapon stow logics

updateStowedWeapon()
{
	self endon( "spawned" );
	self endon( "killed_player" );
	self endon( "disconnect" );
	
	self.tag_stowed_back = undefined;
	self.tag_stowed_hip = undefined;
	
	if( self.pers["team"] == "axis" )		// zombie
	{
		if( self.zombie["weapon"] != "none" )
		{
			self.tag_stowed_back = getWeaponModel( self.zombie["weapon"]+"_mp", 0 );
			
			if ( !isDefined( self.tag_stowed_back ) )
				return;

			self attach( self.tag_stowed_back, "tag_stowed_back", true );
		}
	
		if( self.zombie["medikit"] != "none" )
		{
			self.tag_stowed_hip = "prop_medikit";
			
			self attach( self.tag_stowed_hip, "tag_stowed_hip_rear", true );
		}
	}
	else if( self.pers["team"] == "allies" )		// human
	{
		while ( true )
		{
			self waittill( "weapon_change", newWeapon );
			
			// weapon array reset, might have swapped weapons off the ground
			self.weapon_array_primary =[];
			self.weapon_array_sidearm = [];
			self.weapon_array_grenade = [];
			self.weapon_array_inventory =[];
		
			// populate player's weapon stock arrays
			weaponsList = self GetWeaponsList();
			for( idx = 0; idx < weaponsList.size; idx++ )
			{
				if ( isPrimaryWeapon( weaponsList[idx] ) )
					self.weapon_array_primary[self.weapon_array_primary.size] = weaponsList[idx];
				else if ( isSideArm( weaponsList[idx] ) )
					self.weapon_array_sidearm[self.weapon_array_sidearm.size] = weaponsList[idx];
				else if ( isGrenade( weaponsList[idx] ) )
					self.weapon_array_grenade[self.weapon_array_grenade.size] = weaponsList[idx];
				else if ( isInventory( weaponsList[idx] ) )
					self.weapon_array_inventory[self.weapon_array_inventory.size] = weaponsList[idx];
			}
	
			detach_all_weapons();
			stow_on_back();
			stow_on_hip();
		}
	}
}

detach_all_weapons()
{
	if( isDefined( self.tag_stowed_back ) )
	{
		self detach( self.tag_stowed_back, "tag_stowed_back" );
		self.tag_stowed_back = undefined;
	}
	if( isDefined( self.tag_stowed_hip ) )
	{
		detach_model = getWeaponModel( self.tag_stowed_hip );
		self detach( detach_model, "tag_stowed_hip_rear" );
		self.tag_stowed_hip = undefined;
	}
}

stow_on_back()
{
	current = self getCurrentWeapon();

	self.tag_stowed_back = undefined;
	
	//  large projectile weaponry always show
	if ( self hasWeapon( "rpg_mp" ) && current != "rpg_mp" )
	{
		self.tag_stowed_back = "weapon_rpg7_stow";
	}
	else if( self _hasWeapon( "minigun" ) && current != getConsoleName( "minigun" ) )
	{
		self.tag_stowed_back = _getWeaponModel( "minigun" );
	}
	else
	{
		for ( idx = 0; idx < self.weapon_array_primary.size; idx++ )
		{
			index_weapon = self.weapon_array_primary[idx];
			assertex( isdefined( index_weapon ), "Primary weapon list corrupted." );
			
			if ( index_weapon == current )
				continue;
			
			
			
			self.tag_stowed_back = getWeaponModel( index_weapon, 0 );
		}
	}
	
	if ( !isDefined( self.tag_stowed_back ) )
		return;

	self attach( self.tag_stowed_back, "tag_stowed_back", true );
}

stow_on_hip()
{
	current = self getCurrentWeapon();

	self.tag_stowed_hip = undefined;
	
	for ( idx = 0; idx < self.weapon_array_inventory.size; idx++ )
	{
		if ( self.weapon_array_inventory[idx] == current )
			continue;

		if ( !self GetWeaponAmmoStock( self.weapon_array_inventory[idx] ) )
			continue;
			
		self.tag_stowed_hip = self.weapon_array_inventory[idx];
	}
	
	if ( !isDefined( self.tag_stowed_hip ) )
		return;

	weapon_model = getWeaponModel( self.tag_stowed_hip );
	self attach( weapon_model, "tag_stowed_hip_rear", true );
}

isPrimaryWeapon( weaponname )
{
	base_weapon = strTok( getScriptName(weaponname), "_" );
	class = tableLookup( "mp/statsTable.csv", 4, base_weapon[0], 2 );
	switch( class )
	{
		case "weapon_smg":
		case "weapon_assault":
		case "weapon_lmg":
		case "weapon_shotgun":
		case "weapon_sniper":
		case "weapon_projectile":
		case "weapon_misc":
			return true;
	}
	
	return false;
}
isSideArm( weaponname )
{
	base_weapon = strTok( getScriptName(weaponname), "_" );
	class = tableLookup( "mp/statsTable.csv", 4, base_weapon[0], 2 );
	switch( class )
	{
		case "weapon_pistol":
		case "weapon_mp":
		case "weapon_melee":
			return true;
	}
	
	return false;
}
isInventory( weaponname )
{
	base_weapon = strTok( getScriptName(weaponname), "_" );
	class = tableLookup( "mp/statsTable.csv", 4, base_weapon[0], 2 );
	switch( class )
	{
		case "weapon_explosive":
		case "weapon_special":
			return true;
	}
	
	return false;
}
isGrenade( weaponname )
{
	base_weapon = strTok( getScriptName(weaponname), "_" );
	class = tableLookup( "mp/statsTable.csv", 4, base_weapon[0], 2 );
	if( class == "weapon_grenade" )
		return true;
	else
		return false;
}


//    Grenade scripting

watchGrenadeUsage()
{
	self endon( "death" );
	self endon( "disconnect" );
	
	self.throwingGrenade = false;
	self.gotPullbackNotify = false;
	
	SetDvarIfUninitialized( "scr_deleteexplosivesonspawn", 1 );
	
	if( getdvarint("scr_deleteexplosivesonspawn") == 1 )
	{
		// delete c4 from previous spawn
		if( isdefined( self.c4array ) )
		{
			for ( i = 0; i < self.c4array.size; i++ )
			{
				if ( isdefined(self.c4array[i]) )
					self.c4array[i] delete();
			}
		}
		self.c4array = [];
		// delete claymores from previous spawn
		if( isdefined( self.claymorearray ) )
		{
			for ( i = 0; i < self.claymorearray.size; i++ )
			{
				if ( isdefined(self.claymorearray[i]) )
					self.claymorearray[i] delete();
			}
		}
		self.claymorearray = [];
	}
	else
	{
		if ( !isdefined( self.c4array ) )
			self.c4array = [];
		if ( !isdefined( self.claymorearray ) )
			self.claymorearray = [];
	}
	
	thread watchC4();
	thread watchC4Detonation();
	thread watchC4AltDetonation();
	thread watchClaymores();
	thread deleteC4AndClaymoresOnDisconnect();
	
//	self thread watchForThrowbacks();
	
	for ( ;; )
	{
		self waittill ( "grenade_pullback", weaponName );
		
		self.hasDoneCombat = true;

		if ( weaponName == "claymore_mp" )
			continue;
		
		self.throwingGrenade = true;
		self.gotPullbackNotify = true;
		
		if ( weaponName == "c4_mp" )
			self beginC4Tracking();
		else
			self beginGrenadeTracking();
	}
}

beginGrenadeTracking()
{
	self endon ( "death" );
	self endon ( "disconnect" );
	
	startTime = getTime();
	
	self waittill ( "grenade_fire", grenade, weaponName );
	
	if ( (getTime() - startTime > 1000) )
		grenade.isCooked = true;
	
	if ( weaponName == "frag_grenade_mp" )
	{
		grenade thread maps\mp\gametypes\_shellshock::grenade_earthQuake();
		grenade.originalOwner = self;
	}
		
	self.throwingGrenade = false;
}

beginC4Tracking()
{
	self endon ( "death" );
	self endon ( "disconnect" );
	
	self waittill_any ( "grenade_fire", "weapon_change" );
	self.throwingGrenade = false;
}


watchC4()
{
	self endon( "spawned_player" );
	self endon( "disconnect" );

	//maxc4 = 2;

	while(1)
	{
		self waittill( "grenade_fire", c4, weapname );
		if ( weapname == "c4" || weapname == "c4_mp" )
		{
			if ( !self.c4array.size )
				self thread watchC4AltDetonate();
			
			self.c4array[self.c4array.size] = c4;
			c4.owner = self;
			c4.activated = false;
			
			c4 thread maps\mp\gametypes\_shellshock::c4_earthQuake();
			c4 thread c4Activate();
			c4 thread c4Damage();
			c4 thread playC4Effects();
			//c4 thread c4DetectionTrigger( self.pers["team"] );
		}
	}
}

c4Activate()
{
	self endon("death");

	self waittillNotMoving();
	
	wait 0.05;
	
	self notify("activated");
	self.activated = true;
}

playC4Effects()
{
	self endon("death");
	self waittill("activated");
	
	while(1)
	{
		org = self getTagOrigin( "tag_fx" );
		ang = self getTagAngles( "tag_fx" );
		
		fx = spawnFx( level.C4FXid, org, anglesToForward( ang ), anglesToUp( ang ) );
		triggerfx( fx );
		
		self thread clearFXOnDeath( fx );
		
		originalOrigin = self.origin;
		
		while(1)
		{
			wait .25;
			if ( self.origin != originalOrigin )
				break;
		}
		
		fx delete();
		self waittillNotMoving();
	}
}

watchC4AltDetonate()
{
	self endon("death");
	self endon( "disconnect" );	
	self endon( "detonated" );
	level endon( "game_ended" );
	
	buttonTime = 0;
	for( ;; )
	{
		if ( self UseButtonPressed() )
		{
			buttonTime = 0;
			while( self UseButtonPressed() )
			{
				buttonTime += 0.05;
				wait( 0.05 );
			}
			
			println( "pressTime1: " + buttonTime );
			if ( buttonTime >= 0.5 )
				continue;
			
			buttonTime = 0;				
			while ( !self UseButtonPressed() && buttonTime < 0.5 )
			{
				buttonTime += 0.05;
				wait( 0.05 );
			}
			
			println( "delayTime: " + buttonTime );
			if ( buttonTime >= 0.5 )
				continue;

			if ( !self.c4Array.size )
				return;
				
			self notify ( "alt_detonate" );
		}
		wait ( 0.05 );
	}
}

watchC4AltDetonation()
{
	self endon("death");
	self endon("disconnect");

	while(1)
	{
		self waittill( "alt_detonate" );
		weap = self getCurrentWeapon();
		if ( weap != "c4_mp" )
		{
			newarray = [];
			for ( i = 0; i < self.c4array.size; i++ )
			{
				c4 = self.c4array[i];
				if ( isdefined(self.c4array[i]) )
					c4 thread waitAndDetonate( 0.1 );
			}
			self.c4array = newarray;
			self notify ( "detonated" );
		}
	}
}

watchC4Detonation()
{
	self endon("death");
	self endon("disconnect");

	while(1)
	{
		self waittill( "detonate" );
		weap = self getCurrentWeapon();
		if ( weap == "c4_mp" )
		{
			newarray = [];
			for ( i = 0; i < self.c4array.size; i++ )
			{
				c4 = self.c4array[i];
				if ( isdefined(self.c4array[i]) )
				{
					//if ( c4.activated )
					//{
						c4 thread waitAndDetonate( 0.1 );
					//}
					//else
					//{
					//	newarray[ newarray.size ] = c4;
					//}
				}
			}
			self.c4array = newarray;
			self notify ( "detonated" );
		}
	}
}

resetC4ExplodeThisFrame()
{
	wait .05;
	level.c4explodethisframe = false;
}

waitAndDetonate( delay )
{
	self endon("death");
	wait delay;

	self detonate();
}

watchClaymores()
{
	self endon( "spawned_player" );
	self endon( "disconnect" );

	self.claymorearray = [];
	while(1)
	{
		self waittill( "grenade_fire", claymore, weapname );
		if ( weapname == "claymore" || weapname == "claymore_mp" )
		{
			self.claymorearray[self.claymorearray.size] = claymore;
			claymore.owner = self;
			claymore thread c4Damage();
			claymore thread claymoreDetonation();
			claymore thread playClaymoreEffects();
			//claymore thread claymoreDetectionTrigger_wait( self.pers["team"] );
			//claymore maps\mp\_entityheadicons::setEntityHeadIcon(self.pers["team"], (0,0,20));
		}
	}
}

claymoreDetonation()
{
	self endon("death");
	
	self waitTillNotMoving();
	
	damagearea = spawn("trigger_radius", self.origin + (0,0,0-level.claymoreDetonateRadius), 0, level.claymoreDetonateRadius, level.claymoreDetonateRadius*2);
	self thread deleteOnDeath( damagearea );
	
	while(1)
	{
		damagearea waittill( "trigger", player );
		
		if( player.team == self.owner.team )
			continue;
		
		/*if( lengthsquared( player getVelocity() ) < 10 )
			continue;*/
		
		if( !player shouldAffectClaymore( self ) )
			continue;
		
		if( player damageConeTrace( self.origin, self ) > 0 )
			break;
	}
	
	self playsound ("claymore_activated");
	
	wait level.claymoreDetectionGracePeriod;
	
	self maps\mp\_entityheadicons::setEntityHeadIcon("none");
	self detonate();
}

playClaymoreEffects()
{
	self endon("death");
	
	while(1)
	{
		self waittillNotMoving();
		
		org = self getTagOrigin( "tag_fx" );
		ang = self getTagAngles( "tag_fx" );
		fx = spawnFx( level.claymoreFXid, org, anglesToForward( ang ), anglesToUp( ang ) );
		triggerfx( fx );
		
		self thread clearFXOnDeath( fx );
		
		originalOrigin = self.origin;
		
		while(1)
		{
			wait .25;
			if ( self.origin != originalOrigin )
				break;
		}
		
		fx delete();
	}
}

c4Damage()
{
	self endon( "death" );

	self setcandamage(true);
	self.maxhealth = 100000;
	self.health = self.maxhealth;
	
	attacker = undefined;
	
	while(1)
	{
		self waittill ( "damage", damage, attacker, direction_vec, point, type, modelName, tagName, partName, iDFlags );
		if ( !isplayer(attacker) )
			continue;
		
		// don't allow people to destroy C4 on their team if FF is off
		if ( !friendlyFireCheck( self.owner, attacker ) )
			continue;
		
		if ( damage < 5 ) // ignore concussion grenades
			continue;
		
		break;
	}
	
	if ( level.c4explodethisframe )
		wait .1 + randomfloat(.4);
	else
		wait .05;
	
	if (!isdefined(self))
		return;
	
	level.c4explodethisframe = true;
	
	thread resetC4ExplodeThisFrame();
	
	self maps\mp\_entityheadicons::setEntityHeadIcon("none");
	
	if ( isDefined( type ) && (isSubStr( type, "MOD_GRENADE" ) || isSubStr( type, "MOD_EXPLOSIVE" )) )
		self.wasChained = true;
	
	if ( isDefined( iDFlags ) && (iDFlags & level.iDFLAGS_PENETRATION) )
		self.wasDamagedFromBulletPenetration = true;
	
	self.wasDamaged = true;
	
	// "destroyed_explosive" notify, for challenges
	if ( isdefined( attacker ) && isdefined( attacker.pers["team"] ) && isdefined( self.owner ) && isdefined( self.owner.pers["team"] ) )
	{
		if ( attacker.pers["team"] != self.owner.pers["team"] )
			attacker notify("destroyed_explosive");
	}
	
	self detonate( attacker );
	// won't get here; got death notify.
}

clearFXOnDeath( fx )
{
	fx endon("death");
	self waittill("death");
	fx delete();
}

shouldAffectClaymore( claymore )
{
	pos = self.origin + (0,0,32);
	
	dirToPos = pos - claymore.origin;
	claymoreForward = anglesToForward( claymore.angles );
	
	dist = vectorDot( dirToPos, claymoreForward );
	if ( dist < level.claymoreDetectionMinDist )
		return false;
	
	dirToPos = vectornormalize( dirToPos );
	
	dot = vectorDot( dirToPos, claymoreForward );
	return ( dot > level.claymoreDetectionDot );
}

// returns true if damage should be done to the item given its owner and the attacker
friendlyFireCheck( owner, attacker, forcedFriendlyFireRule )
{
	if ( !isdefined(owner) ) // owner has disconnected? allow it
		return true;
	
	if ( !level.teamBased ) // not a team based mode? allow it
		return true;
	
	friendlyFireRule = level.friendlyfire;
	if ( isdefined( forcedFriendlyFireRule ) )
		friendlyFireRule = forcedFriendlyFireRule;
	
	if ( friendlyFireRule != 0 ) // friendly fire is on? allow it
		return true;
	
	if ( attacker == owner ) // owner may attack his own items
		return true;
	
	if (!isdefined(attacker.pers["team"])) // attacker not on a team? allow it
		return true;
	
	if ( attacker.pers["team"] != owner.pers["team"] ) // attacker not on the same team as the owner? allow it
		return true;
	
	return false; // disallow it
}

deleteC4AndClaymoresOnDisconnect()
{
	self endon("death");
	self waittill("disconnect");
	
	c4array = self.c4array;
	claymorearray = self.claymorearray;
	
	wait .05;
	
	for ( i = 0; i < c4array.size; i++ )
	{
		if ( isdefined(c4array[i]) )
			c4array[i] delete();
	}
	for ( i = 0; i < claymorearray.size; i++ )
	{
		if ( isdefined(claymorearray[i]) )
			claymorearray[i] delete();
	}
}

weaponDamageTracePassed(from, to, startRadius, ignore)
{
	midpos = undefined;
	
	diff = to - from;
	if ( lengthsquared( diff ) < startRadius*startRadius )
		midpos = to;
	dir = vectornormalize( diff );
	midpos = from + (dir[0]*startRadius, dir[1]*startRadius, dir[2]*startRadius);

	trace = bullettrace(midpos, to, false, ignore);
	
	if ( getdvarint("scr_damage_debug") != 0 )
	{
		if (trace["fraction"] == 1)
		{
			thread drawStaticLine(midpos, to, (1,1,1));
		}
		else
		{
			thread drawStaticLine(midpos, trace["position"], (1,.9,.8));
			thread drawStaticLine(trace["position"], to, (1,.4,.3));
		}
	}
	
	return (trace["fraction"] == 1);
}


damageEnt(eInflictor, eAttacker, iDamage, sMeansOfDeath, sWeapon, damagepos, damagedir)
{
	if (self.isPlayer)
	{
		self.damageOrigin = damagepos;
		self.entity thread [[level.callbackPlayerDamage]](
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
	else
	{
		// destructable walls and such can only be damaged in certain ways.
		if (self.isADestructable && (sWeapon == "artillery_mp" || sWeapon == "claymore_mp"))
			return;
		
		self.entity notify("damage", iDamage, eAttacker, (0,0,0), (0,0,0), "mod_explosive", "", "" );
	}
}


getDamageableEnts(pos, radius, doLOS, startRadius)
{
	ents = [];
	
	if (!isdefined(doLOS))
		doLOS = false;
		
	if ( !isdefined( startRadius ) )
		startRadius = 0;
	
	// players
	players = level.players;
	for (i = 0; i < players.size; i++)
	{
		if (!isalive(players[i]) || players[i].sessionstate != "playing")
			continue;
		
		playerpos = players[i].origin + (0,0,32);
		dist = distance(pos, playerpos);
		if (dist < radius && (!doLOS || weaponDamageTracePassed(pos, playerpos, startRadius, undefined)))
		{
			newent = spawnstruct();
			newent.isPlayer = true;
			newent.isADestructable = false;
			newent.entity = players[i];
			newent.damageCenter = playerpos;
			ents[ents.size] = newent;
		}
	}
	
	// grenades
	grenades = getentarray("grenade", "classname");
	for (i = 0; i < grenades.size; i++)
	{
		entpos = grenades[i].origin;
		dist = distance(pos, entpos);
		if (dist < radius && (!doLOS || weaponDamageTracePassed(pos, entpos, startRadius, grenades[i])))
		{
			newent = spawnstruct();
			newent.isPlayer = false;
			newent.isADestructable = false;
			newent.entity = grenades[i];
			newent.damageCenter = entpos;
			ents[ents.size] = newent;
		}
	}

	destructibles = getentarray("destructible", "targetname");
	for (i = 0; i < destructibles.size; i++)
	{
		entpos = destructibles[i].origin;
		dist = distance(pos, entpos);
		if (dist < radius && (!doLOS || weaponDamageTracePassed(pos, entpos, startRadius, destructibles[i])))
		{
			newent = spawnstruct();
			newent.isPlayer = false;
			newent.isADestructable = false;
			newent.entity = destructibles[i];
			newent.damageCenter = entpos;
			ents[ents.size] = newent;
		}
	}

	destructables = getentarray("destructable", "targetname");
	for (i = 0; i < destructables.size; i++)
	{
		entpos = destructables[i].origin;
		dist = distance(pos, entpos);
		if (dist < radius && (!doLOS || weaponDamageTracePassed(pos, entpos, startRadius, destructables[i])))
		{
			newent = spawnstruct();
			newent.isPlayer = false;
			newent.isADestructable = true;
			newent.entity = destructables[i];
			newent.damageCenter = entpos;
			ents[ents.size] = newent;
		}
	}
	
	return ents;
}