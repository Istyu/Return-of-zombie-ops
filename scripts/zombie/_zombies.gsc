/*=======================================================================================
Return of the Zombie Ops - Mod
Modded by Lefti & 3aGl3
=========================================================================================
Zombie AI
=======================================================================================*/
#include scripts\_utility;
#include scripts\zombie\_include;

init()
{
	precacheItem( "bot_zombie_stand_mp" );
	precacheItem( "bot_zombie_walk_mp" );
	precacheItem( "bot_zombie_run_mp" );
	precacheItem( "bot_zombie_melee_mp" );
	precacheItem( "bot_dog_idle_mp" );
	precacheItem( "bot_dog_run_mp" );
	precacheItem( "defaultweapon_mp" );
	
	precacheShellShock( "tabun_gas_mp" );
	
	//printLn( "Initializing scrips/zombies/_zombies.gsc" );
	
	level.zombies = [];
	level.zombiesAlive = 0;
	level.zombiesKilled = 0;

	SetDvarIfUninitialized( "scr_zombies", 24 );
	
	level.zombie["drop"]["powerup"]			= xDvarBool( "scr_allow_drop_powerup", 1 );
	level.zombie["drop"]["medikit"]			= xDvarBool( "scr_allow_drop_medikit", 1 );
	level.zombie["drop"]["weapons"]			= xDvarBool( "scr_allow_drop_weapons", 1 );
	
	level.zombie["powerup"]["ammo"]			= xDvarBool( "scr_powerup_ammo", 1 );
	level.zombie["powerup"]["nuke"]			= xDvarBool( "scr_powerup_nuke", 1 );
	level.zombie["powerup"]["repair"]		= xDvarBool( "scr_powerup_repair", 1 );
	level.zombie["powerup"]["double_points"]= xDvarBool( "scr_powerup_double_points", 1 );
	level.zombie["powerup"]["insta_kill"]	= xDvarBool( "scr_powerup_insta_kill", 1 );
	
	level.waitBetweenZSpawns	= xDvarInt( "scr_zombie_spawn_speed", 3, 1, 10 );
	level.zombieBaseHealth		= xDvarInt( "scr_zombie_basehealth", 100, 1, 1000 );
	level.zombieHealthPerWave	= xDvarInt( "scr_zombie_wavehealth", 2, 0 );
	
	level.zombieWalkSpeed		= xDvarFloat( "scr_zombie_speed_walk", 3.5, 2, 5 );
	level.zombieRunSpeed		= xDvarFloat( "scr_zombie_speed_run", 9, 8, 10 );
	level.dogRunSpeed			= xDvarFloat( "scr_zombie_speed_dog", 16, 15, 20 );
	
	level.zombieAttackRange		= xDvarInt( "scr_zombie_range", 32, 32, 100 );
	level.zombieDamage			= xDvarInt( "scr_zombie_damage", 12, 1 );
	level.zombieDamageOffset	= xDvarFloat( "scr_zombie_attackspeed", 0.8, 0.1, 3.0 );
	
	level.zomFX["death"] = xDvarInt( "scr_zombie_fx_death", 15, 0, 15 );
	//level.zomFX["blood"] = xDvarBool( "scr_zombie_fx_blood", 1 );
	level.zomFX["money"] = xDvarBool( "scr_zombie_fx_money", 1 );
	level.zomFX["explo"] = xDvarBool( "scr_zombie_fx_explo", 0 );
	
	
	//level._effect["zombie_eye"] = loadFx( "zombie/fx_zombie_eye_set" );
	if( level.zomFX["money"] )
		level._effect["norml_zom_death"] = loadFx( "impacts/money_explo" );		// MW2 like MoneyFX
	else
		level._effect["norml_zom_death"] = loadFx( "impacts/flesh_hit_body_fatal_exit" );
	
	level._effect["blood_zom_death"] = loadFx( "impacts/deathfx_dogbite" );				// Bloody zombie vanish
	level._effect["tabun_zom_death"] = loadFx( "smoke/toxic_gas" );						// tabun gas explosion
	level._effect["slime_zom_death"] = loadFx( "zombie/bloodpool" );		// slime explosion
	level._effect["limbs_zom_death"] = loadFx( "gore/gib_splat" );					// limbFX
	level._effect["explo_zom_death"] = loadFx( "explosions/grenadeexp_default" );		// GrenadeFX
	
	thread scripts\zombie\types::loadZombies();
	thread connectZombies();
	
	if( isDeveloper() )
		thread devZombies();
}


// General

connectZombies()
{
	level endon( "game_ended" );
	level waittill( "connected" );
	
	wait 5;
	
	if( isDeveloper() )
	{
		for(;;)
		{
			if( !getDvarBool("dev_suppress_zombies") )
				break;
				
			wait 1;
		}
	}
	
	for( i=0; i<getDvarInt("scr_zombies"); i++ )
	{
		id = level.zombies.size;
		level.zombies[id] = addTestClient();
		
		if( !isDefined(level.zombies[id]) )
			iPrintln( "Could not add Zombie "+id );
		else
		{
			level.zombies[id] thread makeZombie();
			level.zombies[id].pers["isBot"] = true;
			//level.zombies[id] setStat(512, 100);
		}
	}
}

makeZombie()
{
	self endon( "disconnect" );
	
	self waittill( "connected" );

	self.pers["team"] = "axis";
	self.team = "axis";
	self.sessionteam = "axis";
	
	self notify("joined_team");
	self notify("end_respawn");
	
	self.zombie = [];
	self.zombie["inUse"] = false;
	self.zombie["type"] = "none";
	self.zombie["weapon"] = "none";
	self.zombie["medikit"] = "none";
	
	self.animation = "zmb";
	self.status = "idle";
	
	self.myWaypoint = undefined;
	self.targetWp = undefined;
	self.oldWp = undefined;
}

devZombies()
{
	SetDvarIfUninitialized( "dev_zombie_spawn", 0 );
	
	wait( 5 );
	
	for(;;)
	{
		if( getDvarInt("dev_zombie_spawn") > 0 )
			break;
			
		wait 1;
	}
	
	zomnum = getDvarInt( "dev_zombie_spawn" );
	setDvar( "dev_zombie_spawn", 0 );
	
	spawnZombieNum( zomnum );
	
	thread devZombies();
}


// Spawn

spawnZombieNum( zombie_count )
{
	level endon( "game_ended" );
	
	actual_spawned = 0;
	
	for(;;)
	{
		wait 0.5;
		
		for( i=0; i < zombie_count; i++ )
		{
			zombie = getFreeZombie();
			
			if( isDefined(zombie) )
			{
				zombie prepareSpawn();
				zombie spawnZombie();
				
				actual_spawned++;
				level.zombiesAlive++;
				
				wait level.waitBetweenZSpawns;
			}
			wait 0.01;
		}
		
		if( actual_spawned == zombie_count )
			break;
		else
			zombie_count -= actual_spawned;
	}
}

spawnZombie()
{
	self endon("disconnect");
	self endon("joined_spectators");
	self notify("spawned");
	self notify("end_respawn");
	
	self.sessionteam = self.team;
	
	hadSpawned = self.hasSpawned;
	
	self.sessionstate = "playing";
	self.spectatorclient = -1;
	self.killcamentity = -1;
	self.archivetime = 0;
	self.psoffsettime = 0;
	self.statusicon = "";
	self.maxhealth = int((level.zombieBaseHealth+(level.zombieHealthPerWave*level.waveID))*level.zmbTypes[self.zombie["type"]].healthmultipler);
	self.health = self.maxhealth;
	
	self.friendlydamage = undefined;
	self.hasSpawned = true;
	self.spawnTime = getTime();
	self.afk = false;
	self.lastStand = undefined;
	
	waittillframeend;
	self notify( "spawned_player" );
	
	self.Rage = 0;
	self.myWaypoint = undefined;
	self.targetWp = undefined;
	self.oldWp = undefined;
	
	self.status = "idle";
	self.moveTarget = undefined;
	self.lastMemorizedPos = undefined;
	self.targetPlayer = undefined;
	
	spawnpoint = maps\mp\gametypes\_spawnlogic::getBestZombieSpawn();
	if( isDefined(spawnpoint.angles) )
		self spawn( spawnpoint.origin, spawnpoint.angles );
	else
		self spawn( spawnpoint.origin, (0,0,0) );
	
	self detachAll();
	
	model = randomInt(level.zmbTypes[self.zombie["type"]].models.size);
	modelID = level.zmbTypes[self.zombie["type"]].models[model];
	
	[[level.zmbModels[modelID]]]();
	
	self.animation = level.zmbTypes[self.zombie["type"]].animtype;
	self setAnim();
	
	self freezecontrols( true );
	
	self.mover = spawn( "script_model", (0,0,0) );
	self.mover setmodel( "tag_origin" );
	self.mover.origin = self.origin;
	self linkto(self.mover);
	
	self scripts\zombie\_movement::zomDropToGround();
	
	self thread eyeFx();
	self thread zombieMain();
	self thread rageIncrease();
}

eyeFx()
{
	wait .1;
	
	//PlayFXOnTag( level._effect["zombie_eye"], self, "tag_eye" );
	
	if( self isRunner() )
		self.Rage += 200;	
}

prepareSpawn()
{	
	self.zombie["type"]	= "zombie";
	self.zombie["weapon"] = "none";
	self.zombie["ammo"] = "none";
	self.zombie["medikit"] = "none";

	if( level.specialWave == "none" )
	{
		typenum = randomInt( level.zombiePercentage );
		keys = getArrayKeys(level.zmbTypes);
		
		for( i=0; i<keys.size; i++ )
		{
			if( level.zmbTypes[keys[i]].minVal <= typenum && level.zmbTypes[keys[i]].maxVal > typenum )
			{
				self.zombie["type"] = keys[i];
				break;
			}
		}
	}
	else
	{
		self.zombie["type"] = level.specialWave;
	}
	
	// DEVELOPER: Override for testing special zombies
	if( getDvarInt("developer") >= 1 )
		self.zombie["type"] = "slime";
	
	self.zombie["inUse"] = true;
}

getFreeZombie()
{
	level endon( "game_ended" );
	
	zombie = undefined;
	for(;;)			// in case no zombie is free we'll try it again later
	{
		for( i=0; i<level.zombies.size; i++ )
		{
			if( level.zombies[i].zombie["inUse"] == false )
			{
				zombie = level.zombies[i];
				break;
			}
		}
		
		if( isDefined(zombie) )
			break;
		
		wait 0.5;
	}
	
	return zombie;
}


// Lifecycle

zombieMain()
{
	self endon("disconnect");
	self endon("killed_player");
	
	self.lastTargetWp = -2;
	self.nextWp = -2;
	
	while (1)
	{
		doWait = true;
		switch( self.status )
		{
			case "idle":
				self setAnim( "idle" );
				if( isDefined(level.defaultZombieTargets) )
				{
					ID = randomInt(level.defaultZombieTargets.size);
					
					self.lastMemorizedPos = level.defaultZombieTargets[ID].origin;
					self.status = "searching";
				}
				else
					zombieWaitToBeTriggered();
				
				break;
			case "triggered":
				bestTarget = zombieGetBestTarget();
				
				if(isdefined(bestTarget))
				{
					self.lastMemorizedPos = bestTarget.origin;
					if( !checkForBarricade(bestTarget.origin) )
					{
						if( distance(bestTarget.origin, self.origin) < level.zombieAttackRange )
						{
							self setAnim( "attack" );
							self thread scripts\zombie\_movement::moveLockon(bestTarget, 4);
							self zombieMelee();
							doWait = false;
						}
						else
						{
							self animMovement();
							self scripts\zombie\_movement::moveTowards(bestTarget.origin, 4);
							doWait = false;
						}
					}
					else
					{
						self setAnim( "attack" );
						self zombieMelee();
					}
				}
				else
				{
					self.status = "searching";
				}
				
				break;
			case "searching":
				zombieWaitToBeTriggered();
				
				if( isdefined(self.lastMemorizedPos) )
				{
					if( !checkForBarricade(self.lastMemorizedPos) )
					{
						if (distance(self.lastMemorizedPos, self.origin) > 96)
						{
							self animMovement();
							self scripts\zombie\_movement::moveTowards(self.lastMemorizedPos, 4);
							doWait = false;
						}
						else
						{
							self.lastMemorizedPos = undefined;
						}
					}
					else
					{
						self setAnim( "attack" );
						self zombieMelee();
					}
				}
				else
				zombieGoIdle();

				break;
		}
	
		if(doWait)
			wait .2;
	}
}

zombieGoIdle()
{
	self.status = "idle";
	
	if( self isRunner() == false )
		self.Rage = 0;
}

zombieGetBestTarget()
{
	closest = getSurvivors();
	
	for (i=0; i<closest.size; i++)
	{
		player = closest[i];
		if (zombieSpot(player))
			return player;
		
	}
	closest = [];
	
	return undefined;
}

zombieSpot(target)
{
	if( !isAlive(target) )
		return false;
  
//	if( !target.visible )
//		return false;

	if( !target.isTargetable )
		return false;
  
	distance = distance(self.origin, target.origin);
  
	if( target hasPerkV( "specialty_quieter" ) && distance > 1536 )			// 512 units less visible with Ninja
		return false;
	else if( distance > 2048 )
		return false;
  
	speed = Length(target GetVelocity());
	if (speed > 80 && distance < 256)
		return 1;
	if (speed > 160 && distance < 416)
		return 1;
	if (speed > 240 && distance < 672)
		return 1;
  
	dot = 1.0;
  
  
	//if nearest target hasn't attacked me, check to see if it's in front of me
	fwdDir = anglestoforward(self getplayerangles());
	dirToTarget = vectorNormalize(target.origin-self.origin);
	dot = vectorDot(fwdDir, dirToTarget);

	//in front of us and is being obvious
	if(dot > -0.2)
	{
		//do a ray to see if we can see the target
	    visTrace = bullettrace(self.origin + (0,0,68), target getEyeOrigin(), false, self);
	    if(visTrace["fraction"] == 1)
	    {
	      //line(self.origin + (0,0,68), visTrace["position"], (0,1.0,0));
	      return true;
	    }
	    else
	    {
	      //line(self.origin + (0,0,68), visTrace["position"], (1,0,0));            
	      return false;
	    }
	}

	return false;
}

checkForBarricade(targetposition)
{
	for (i=0; i<level.barricades.size; i++)
	{
		ent = level.barricades[i];
		if( self istouching(ent) && ent.health > 0 )
		{
			fwdDir = vectorNormalize(targetposition-self.origin);
			dirToTarget = vectorNormalize(ent.origin-self.origin);
			dot = vectorDot(fwdDir, dirToTarget);
			if (dot > 0 && dot < 1)
			{
				return 1;
			}
		}
	}
	return 0;
}

zombieWaitToBeTriggered()
{
	survivors = getSurvivors();
	
	for( i=0; i<survivors.size; i++)
	{
		player = survivors[i];
		if( self zombieSpot(player) )
		{
			self.status = "triggered";
			break;
		}
	}
}

rageIncrease()
{
	self endon( "disconnect" );
	self endon( "killed_player" );
	
	self.Rage = 0;
	
	for(;;)
	{
		self waittill( "increaseRage", amount, attacker );
		
		self.Rage += amount;
		self.status = "triggered";
		/*self.target = "attacker";
		self.targetEnt = attacker;*/
	}
}


// Death

onZombieKilled(eInflictor, eAttacker, iDamage, sMeansOfDeath, sWeapon, vDir, sHitLoc, timeOffset, deathAnimDuration)		// self = dead zombie
{
	playFx( level._effect["norml_zom_death"], self.origin+(0,0,48) );
	
	if( !level.zomFX["explo"] )
	{
		level.zomFX["explo"] = false;	
		playFx( level._effect["blood_zom_death"], self.origin+(0,0,36) );
		level.zomFX["explo"] = true;	
	}
	
	number = level.zomFX["death"];
	
	explosion = false;
	gas = false;
	slime = false;
	limb = false;
	level.zomFX["explo"] = false;	
	
	if( number >= 8 )
	{
		limb = true;
		number -= 8;
	}
	if( number >= 4 )
	{
		slime = true;
		number -= 4;
	}
	if( number >= 2 )
	{
		gas = true;
		number -= 2;
	}
	if( number >= 1 )
	{
		explosion = true;
		number -= 1;
	}
	
	if( self isExplosive() && explosion && isDog() )
	{
		level.zomFX["explo"] = false;	
		playFx( level._effect["explo_zom_death"], self.origin+(0,0,48) );
		radiusDamage( self.origin+(0,0,48), 96, 200, 50, self );
		earthquake( 0.3, 1, self.origin, 128 );
		self playSound( "detpack_explo_default" );				
	}	
	else if( self isExplosive() && explosion )
	{
		level.zomFX["explo"] = true;	
		playFx( level._effect["limbs_zom_death"], self.origin+(0,0,48) );
		radiusDamage( self.origin+(0,0,48), 96, 200, 50, self );
		earthquake( 0.3, 1, self.origin, 128 );
		self playSound( "detpack_explo_default" );	
		level.zomFX["explo"] = false;		
	}		
	else if( self isTabun() && gas )
	{
		level.zomFX["explo"] = false;	
		self novaGas( self.origin );
		level.zomFX["explo"] = true;					
	}
	else if( self isSlime() && slime )
	{
		level.zomFX["explo"] = false;	
		self slimePuddle();	
		level.zomFX["explo"] = true;				
	}
	else if( self isTank() && limb )
	{
		level.zomFX["explo"] = true;	
		playFx( level._effect["limbs_zom_death"], self.origin+(0,0,48) );
		level.zomFX["explo"] = false;			
	}
	
	if( randomInt(100)<=10 )
		self dropPowerup();
	
	if( isDefined(self.mover) )
		self.mover delete();
	
	self thread unuseAfterTime( 2 );
}

unuseAfterTime( time )
{
	level endon( "game_ended" );
	
	wait time;
	
	if( isDefined(self) )
		self.zombie["inUse"] = false;
}

dropPowerup()
{
	
}

novaGas( pos )
{
	fillduration = 15;
	duration = 36;
	radius = 150;
	height = radius;
	sufferingduration = 1.5;
	dmg = 15;
	
	trig = spawn( "trigger_radius", pos, 0, radius, height );
	playFX( level._effect["tabun_zom_death"], pos );
	
	//thread drawcylinder(pos, radius, height, duration, fillduration);
	
	starttime = gettime();
	
	trig thread teartimer( duration );
	
	while( true )
	{
		trig waittill( "trigger", player );
		
		if( isDefined(trig.gasTimedOut) )
			break;
		
		if( player.sessionstate != "playing" )
			continue;
		
		time = (gettime() - starttime)/1000;
		
		currad = radius;
		curheight = height;
		if (time < fillduration) {
			currad = currad * (time / fillduration);
			curheight = curheight * (time / fillduration);
		}
		
		offset = (player.origin + (0,0,32)) - pos;
		offset2d = (offset[0], offset[1], 0);
		if (lengthsquared(offset2d) > currad*currad)
			continue;
		if (player.origin[2] - pos[2] > curheight)
			continue;
		
		player.teargasstarttime = gettime(); // purposely overriding old value
		if( !isDefined(player.gasImmune) )
		{
			if( !isDefined(player.teargassuffering) )
				player thread teargassuffering( self, trig, sufferingduration, dmg );
		}
	}
	
	trig delete();
}
teartimer( time )
{
	wait time;
	self.gasTimedOut = true;
}
teargassuffering( attacker, inflictor, sufferingduration, damage )
{
	self endon("death");
	self endon("disconnect");	
	
	self.teargassuffering = true;
	self shellshock( "tabun_gas_mp", 60 );
	
	while(1)
	{
		if(gettime() - self.teargasstarttime > sufferingduration * 1000)
			break;
		
		self finishPlayerDamage(inflictor,								// The entity that causes the damage.(e.g. a turret)
								attacker,								// The entity that is attacking.
								int(damage / sufferingduration),		// Integer specifying the amount of damage done
								0,										// Integer specifying flags that are to be applied to the damage
								"MOD_PROJECTILE",						// Integer specifying the method of death
								"smoke_grenade_mp",						// The weapon number of the weapon used to inflict the damage
								self.origin,							// (vector) the directon of the hit
								inflictor.origin,						// (vector) The direction of the damage
								"head",									// The location of the hit
								0 );									// The time offset for the damage
		
		wait 1;
	}
	
	self shellshock( "tabun_gas_mp", 1 );
	
	self.teargassuffering = undefined;
}
drawcylinder(pos, rad, height, duration, fillduration)
{
	time = 0;
	while(1)
	{
		currad = rad;
		curheight = height;
		if (time < fillduration) {
			currad = currad * (time / fillduration);
			curheight = curheight * (time / fillduration);
		}
		
		for (r = 0; r < 20; r++)
		{
			theta = r / 20 * 360;
			theta2 = (r + 1) / 20 * 360;
			
			line(pos + (cos(theta) * currad, sin(theta) * currad, 0), pos + (cos(theta2) * currad, sin(theta2) * currad, 0));
			line(pos + (cos(theta) * currad, sin(theta) * currad, curheight), pos + (cos(theta2) * currad, sin(theta2) * currad, curheight));
			line(pos + (cos(theta) * currad, sin(theta) * currad, 0), pos + (cos(theta) * currad, sin(theta) * currad, curheight));
		}
		time += .05;
		if (time > duration)
			break;
		wait .05;
	}
}

slimePuddle()
{
	PlayFX( level._effect["slime_zom_death"], self.origin );
	
	if( !isDefined( self ) )
		return;
	
	maxtime = 17*2;		//SET ME; max slime duration ( take it double! )
	time = 0;
	radius = 30;
	maxradius = 180;	//SET ME
	dmg = 10;			//SET ME
		 
	players = getAllPlayers();
	
	while( isDefined( self ) )
	{
		if( time >= maxtime )
			break;
		
		for( i=0; i<players.size; i++ )
		{
			if( isAlive( players[i] ) && players[i].health > 1 && self SightConeTrace( players[i] GetEye(), self ) > 0 && distance2d( self.origin, players[i].origin ) <= radius && players[i].origin[2] <= (self.origin[2]+5) )
				players[i] maps\mp\gametypes\_globallogic::Callback_PlayerDamage( self, self, dmg, 0, "MOD_PROJECTILE", "smoke_grenade_mp", self.origin, VectorToAngles( players[i].origin - self.origin ), "none", 0 );
		}
		
		if( radius < maxradius )
			radius += 20;
		
		time++;
		wait 0.5;
	}
}