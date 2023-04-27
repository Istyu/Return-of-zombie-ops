/*=======================================================================================
return of the zombie ops - Mod
Modded by Lefti & 3aGl3
=========================================================================================
Perk - LastStand
=======================================================================================*/
#include maps\mp\gametypes\_hud_util;
#include scripts\_utility;
#include scripts\_weapon_key;

init()
{
	precacheShader( "waypoint_revive" );
	
	precacheString( &"PERKS_PRESS_USE_TO_REVIVE_N" );		// Hold [USE] to revive &&1.
	precacheString( &"PERKS_TIME_TILL_DEATH" );				// Time till death:
	
	SetDvarIfUninitialized( "scr_perk_pistoldeath_weapon", "colt45" );
	level.pistoldeath_survivetime = xDvarInt( "scr_perk_pistoldeath_survtime", 120, 30, 300 );		// five mins max, so players can't cheat invu forever
	level.pistoldeath_revivepoins = xDvarInt( "scr_player_revive_money", 20, 10, 100 );
	
	level.reviveTime = xDvarInt( "scr_player_revivetime", 5, 1, 20 );

	if( !isDefined(level.pistoldeath_instadeath) )		// this is here to be used by gamemodes
		level.pistoldeath_instadeath = false;
}

onPlayerLastStand()
{
//	printLn( "onPlayerLastStand called" );
	
	if( level.pistoldeath_instadeath )
	{
		self suicide();
		return;
	}

		
	
	pistol = undefined;
	deathtime = level.pistoldeath_survivetime;
	showNotify = true;
	reviveLoadout = self getWeaponsList();
	
	if( self hasPerkX("specialty_pistoldeath") )		// Last Stand	(keep pistol)
	{
		weapons = self getWeaponsList();
		for( i=0; i<weapons.size; i++ )
		{
			if( tableLookup( "mp/weapon_key.csv", 3, weapons[i], 1 ) == "weapon_pistol" || tableLookup( "mp/weapon_key.csv", 3, weapons[i], 1 ) == "weapon_mp" )
			{
				pistol = weapons[i];
				break;
			}
		}
		
		self takeAllWeapons();
		if( isDefined(pistol) )
		{
			self giveWeapon( pistol );
			self giveMaxAmmo( pistol );
			self switchToWeapon( pistol );
		}
		else
		{
			self _giveWeapon( getDvar("scr_perk_pistoldeath_weapon") );
			self _giveMaxAmmo( getDvar("scr_perk_pistoldeath_weapon") );
			self _switchToWeapon( getDvar("scr_perk_pistoldeath_weapon") );
		}
	}
	else if( self hasPerkX("specialty_pistoldeath_two") )		// Last Stand + (keep primary weapons)
	{
		weapons = self getweaponslist();
		for( i=0; i<weapons.size; i++ )
		{
			if( weaponinventorytype(weapons[i]) != "primary" )
				self takeWeapon(weapons[i]);
		}
	}
	else if( self hasPerkX("specialty_pistoldeath_pro") )		// Last Stand PRO	(keep everything)
	{
		deathtime = level.pistoldeath_survivetime*2;
	}
	else		// NO Last Stand (keep nothing)
	{
		deathtime = level.pistoldeath_survivetime/2;
		self takeAllWeapons();
		showNotify = false;
	}
	
	if( showNotify )
	{
		notifyData = spawnStruct();
		notifyData.glowColor = (1,0,0);
		notifyData.titleText = &"PERKS_LAST_STAND";
		notifyData.sound = "mp_last_stand";
		notifyData.iconName = "specialty_pistoldeath";
	
		self maps\mp\gametypes\_hud_message::notifyMessage( notifyData );
	}
	
	self thread reviveSetup( reviveLoadout, deathtime );
}

// Revive

reviveSetup( loadout, deathtime )
{
//	self endon( "spawned" );
//	self endon( "disconnect" );
	
	self waitTillNotMoving();		// to prevent the annoying mid air revives
	
	if( self.team != "allies" )
		return;
	
	self.reviveInProgress = false;
	
	self thread createReviveWaypoint();
	self.revivetrigger = spawn( "trigger_radius", self.origin, 0, 64, 64 );
	self.revivetrigger thread fakeHintString( &"PERKS_PRESS_USE_TO_REVIVE_N", self.name, "allies" );
	
	self thread reviveThink();
	self thread bleedOut( int(deathtime) );
	
	self thread delOnDisconnect();
	self thread delOnDeath();
	self thread delOnSpawn();
}

bleedOut( deathtime )
{
	level endon( "game_ended" );

	self endon( "disconnect" );
	self endon( "killed_player" );
	self endon( "spawned" );
	
	self createReviveHud( deathtime );
	for(; deathtime>=0; deathtime-- )
	{
		self.hud["revhud"] setValue( deathtime );
		wait 1;
	}
	
	self deleteReviveHud();
	
	wait .5;
	
	while( self.reviveInProgress )
		wait .5;
	
	if( isDefined(self) )
		self suicide();
}

reviveThink()
{
	self endon( "killed_player" );
	self endon( "spawned" );
	
	for(;;)
	{
		self.revivetrigger waittill( "trigger", user );
		
		if( self.reviveInProgress )
			continue;
		
		if( user.team == "axis" )
			continue;
		
		if( user useButtonPressed() && !isDefined(user.isUsingSomething)  )
			self thread revivePlayer( user );
	}
}

revivePlayer( reviver )		// self = guy on the ground
{
	reviver disableWeapons( true );
	reviver.isUsingSomething = true;
	
	if( isDefined(reviver.pBar) )
		reviver.pBar destroyElem();
	
	reviver.pBar = reviver createPrimaryProgressBar();		// create a progress bar for him
	
	self.reviveInProgress = true;
	
	percent = 0;
	while( isDefined(reviver) && isDefined(self.revivetrigger) && reviver useButtonPressed() && reviver isTouching(self.revivetrigger))
	{
		percent++;
		wait (level.reviveTime/100);
		
		if( isDefined(reviver) && isDefined(reviver.pBar) )
			reviver.pBar updateBar( percent/100 );
		
		if( percent >= 100 )
			break;
	}
	
	if( isDefined(reviver) )
	{
		reviver enableWeapons( true );
		reviver.isUsingSomething = undefined;
		if( isDefined(reviver.pbar) )
			reviver.pBar destroyElem();
	}
	
	if( percent >= 100 && isDefined(self) )
	{
		self deleteReviveHud();
		self suicide();
		self [[level.spawnClient]]( self.origin, self.angles );
		
		if( isDefined(reviver) )
			reviver thread scripts\player\_points::givePoints(level.pistoldeath_revivepoins);
	}
	
	if( isDefined(self) )
		self.reviveInProgress = false;
}

// Misc

createReviveWaypoint()
{
	if( isDefined(self.hud["reviveNote"]) )
		self.hud["reviveNote"] destroy();
	
	self.hud["reviveNote"] = newHudElem();
	self.hud["reviveNote"].x = self.origin[0];
	self.hud["reviveNote"].y = self.origin[1];
	self.hud["reviveNote"].z = self.origin[2]+35;
	self.hud["reviveNote"].alpha = .9;
	self.hud["reviveNote"].archived = true;
	self.hud["reviveNote"] setShader( "waypoint_revive", 25, 25 );
	self.hud["reviveNote"] setWaypoint( true, "waypoint_revive" );
}

deleteReviveWaypoint()
{
	if( isDefined(self.hud["reviveNote"]) )
		self.hud["reviveNote"] destroy();
}

createReviveHud( deathtime )
{	
	if( isDefined(self.hud["revhud"]) )
		self.hud["revhud"] destroy();
	
	self.hud["revhud"] = self createFontString( "default", 1.4 );
	self.hud["revhud"].hideWhenInMenu = true;
	self.hud["revhud"] setPoint( "CENTER", "CENTER", 0, 150 );
	self.hud["revhud"].sort = 9994;
	self.hud["revhud"].label = &"PERKS_TIME_TILL_DEATH";
	self.hud["revhud"] setValue( deathtime );
	self.hud["revhud"].glowcolor = (1, 1, 0);
	self.hud["revhud"].glowalpha = .8;
	self.hud["revhud"].alpha = 1;
}

deleteReviveHud()
{
	if( isDefined(self.hud["revhud"]) )
		self.hud["revhud"] destroy();
}

delOnDisconnect()
{
	self endon( "killed_player" );
	self endon( "spawned" );
	
	self waittill( "disconnect" );
	
	if( isDefined(self.revivetrigger) )
		self.revivetrigger delete();
		
	self deleteReviveWaypoint();
}

delOnDeath()
{
	self endon( "disconnect" );
//	self endon( "spawned" );
	
	self waittill( "killed_player" );
	
	//wait 0.05;
	
	if( isDefined(self.revivetrigger) )
		self.revivetrigger delete();
	
	self deleteReviveWaypoint();
}

delOnSpawn()
{
	self endon( "disconnect" );
	self endon( "killed_player" );
	
	self waittill( "spawned" );
		
	if( isDefined(self.revivetrigger) )
		self.revivetrigger delete();
	
	self deleteReviveWaypoint();
}
