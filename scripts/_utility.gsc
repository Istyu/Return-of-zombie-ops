/*=======================================================================================
Return of the Zombie Ops - Mod
Modded by Lefti & 3aGl3
=========================================================================================
Zombie Utility
=======================================================================================*/
#include scripts\_weapon_key;

float( string )
{
	setDvar( "2float", string );
	float = getDvarFloat( "2float" );
	setDvar( "2float", "" );
	
	return float;
}

rnd( value, rndVal )
{
	temp = int(value*rndVal);
	
	return temp/rndVal;
}

hidePartExpect( tags, dontHide )
{
	for( i=0; i<tags.size; i++ )
	{
		if( tags[i] != dontHide )
			self hidePart( tags[i] );
	}
}

arrayMerge( array1, array2 )
{
	for( i=0; i<array2.size; i++ )
		array1[array1.size] = array2[i];
		
	return array1;
}


// Dvar functions

// ToDo: Move to dvardef.gsc
SetDvarIfUninitialized( dvarName, value )
{
	if( getDvar(dvarName) == "" )
		setDvar( dvarName, value );
}

SetDvarMinMax( dvarName, value, min, max )
{
	if( getDvar(dvarName) == "" )
		setDvar( dvarName, value );
	else if( getDvarInt(dvarName) > max )
		setDvar( dvarName, max );
	else if( getDvarInt(dvarName) < min )
		setDvar( dvarName, min );
}

getDvarBool( dvarname )
{
	if( getDvarInt(dvarname) >= 1 )
		return true;
	else
		return false;
}

xDvar( dvarName, dvarValue )
{
	if( getDvar(dvarName) == "" )
		setDvar( dvarName, dvarValue );
	
	return getDvar(dvarName);
}

xDvarInt( dvarName, dvarValue, dvarMin, dvarMax )
{
	if( getDvar(dvarName) == "" )
		setDvar( dvarName, dvarValue );
		
	if( isDefined(dvarMin) )
	{
		if( getDvarInt(dvarName) < dvarMin )
			setDvar( dvarName, dvarMin );
	}
	
	if( isDefined(dvarMax) )
	{
		if( getDvarInt(dvarName) > dvarMax )
			setDvar( dvarName, dvarMax );
	}
	
	return getDvarInt(dvarName);
}

xDvarFloat( dvarName, dvarValue, dvarMin, dvarMax )
{
	if( getDvar(dvarName) == "" )
		setDvar( dvarName, dvarValue );
	
	if( isDefined(dvarMin) )
	{
		if( getDvarFloat(dvarName) < dvarMin )
			setDvar( dvarName, dvarMin );
	}
	
	if( isDefined(dvarMax) )
	{
		if( getDvarFloat(dvarName) > dvarMax )
			setDvar( dvarName, dvarMax );
	}
	
	return getDvarFloat(dvarName);
}

xDvarBool( dvarName, dvarValue )
{
	if( getDvar(dvarName) == "" )
		setDvar( dvarName, dvarValue );
	
	return getDvarBool(dvarName);
}


// Map functions

getMaptype()
{
	maptype = "unknown";
	
	oldschool = getEntArray( "oldschool_pickup", "targetname" );
	survival = getEntArray( "weapon_buy", "targetname" );
	
	if( oldschool.size >= 1 )
		maptype = "normal";
	else if( survival.size >= 1 )
		maptype = "new_survival";
	
	return maptype;
}

getGameobjects( name )
{
	ents = getEntArray();
	gameobjects = [];
	
	for( i=0; i<ents.size; i++ )
	{
		if( isDefined(ents[i].script_gameobjectname) && ents[i].script_gameobjectname == name )
			gameobjects[gameobjects.size] = ents[i];
	}
	
	return gameobjects;
}

/*createUseObject( useText, onUseObject, user, endonSpecial )
{
	if( !isDefined(endonSpecial) )
		endonSpecial = "never_trigger";
	
	self endon( "death" );
	self endon( endonSpecial );

	while(1)
	{
		wait .05;
		if( !isDefined( self ) )
			return;
			
		if( isdefined( user ) && isdefined( self ) )
		{
			if( ( distance( self.origin, user.origin ) <= 60 ) && self.owner IsLookingAt( self ) )
			{
				self.owner CreatePickupMessage();
				
				if( self.owner useButtonPressed() )
					self.owner thread sentry_remove( true );
			}
			else
				self.owner DeletePickupMessage();
				
		}
	}
}/*/


// Perks

getPerks( player )
{
	perks[0] = "specialty_null";
	perks[1] = "specialty_null";
	perks[2] = "specialty_null";
	
	if ( isPlayer( player ) )
	{
		if ( isDefined( player.loadout["perk1"] ) )
			perks[0] = player.loadout["perk1"];
		
		if ( isDefined( player.loadout["perk2"] ) )
			perks[1] = player.loadout["perk2"];
		
		if ( isDefined( player.loadout["perk3"] ) )
			perks[2] = player.loadout["perk3"];
	}

	return perks;
}


hasPerkX( perk )		// returns true if player has EXACT perk
{
	perks = getPerks( self );
	
	for( i=0; i<perks.size; i++ )
	{
		if( perks[i] == perk )
			return true;
	}
	
	return false;
}


hasPerkV( perk )		// returns true if player has perk or PLUS/PRO version
{
	perks = getPerks( self );
	
	for( i=0; i<perks.size; i++ )
	{
		if( isSubStr( perks[i], perk ) )
			return true;
	}
	
	return false;
}

getPerkTier( perk )
{
	return tableLookup( "mp/statsTable.csv", 4, perk, 2 );
}


// HUD

fakeHintString( hintString, hintValue, team )
{
	self endon( "death" );
	
	for(;;)
	{
		self waittill( "trigger", user );
		
		if( !isPlayer(user) || !isDefined(user) || !isDefined(user.lowerMessage) )
			continue;
		
		if( !isDefined(team) || user.pers["team"] == team )
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

setLowerMessage( text, time )			// ToDo: Move to Hud_utility
{
	if ( !isDefined( self.lowerMessage ) )
		return;
	
	if ( isDefined( self.lowerMessageOverride ) && text != &"" )
	{
		text = self.lowerMessageOverride;
		time = undefined;
	}
	
	self notify("lower_message_set");
	self.lowerMessage.label = text;
	
	if ( isDefined( time ) && time > 0 )
		self.lowerTimer setTimer( time );
	else
		self.lowerTimer setText( "" );
	
	self.lowerMessage fadeOverTime( 0.05 );
	self.lowerMessage.alpha = 1;
}

clearLowerMessage( fadetime )
{
	if ( !isDefined( self.lowerMessage ) )
		return;
	
	self notify("lower_message_set");
	
	if ( !isdefined(fadetime) || fadetime == 0 )
		setLowerMessage( &"" );
	else
	{
		self endon("disconnect");
		self endon("lower_message_set");
		
		self.lowerMessage fadeOverTime( fadetime );
		self.lowerMessage.alpha = 0;
		//self.lowerTimer setText( "" );
		
		wait fadetime;
		
		self setLowerMessage("");
	}
}

hidePerksAfterTime( delay )
{
	self endon("disconnect");
	self endon("perks_hidden");
	
	wait delay;
	
	self thread maps\mp\gametypes\_hud_util::hidePerk( 0, 2.0 );
	self thread maps\mp\gametypes\_hud_util::hidePerk( 1, 2.0 );
	self thread maps\mp\gametypes\_hud_util::hidePerk( 2, 2.0 );
	self notify("perks_hidden");
}

hidePerksOnDeath()
{
	self endon("disconnect");
	self endon("perks_hidden");

	self waittill("death");
	
	self maps\mp\gametypes\_hud_util::hidePerk( 0 );
	self maps\mp\gametypes\_hud_util::hidePerk( 1 );
	self maps\mp\gametypes\_hud_util::hidePerk( 2 );
	self notify("perks_hidden");
}

fadeOverBlack( in, stay, out )
{
	black = newClientHudElem( self );
	black.x = 0;
	black.y = 0;
	black.alignX = "left";
	black.alignY = "top";
	black.horzAlign = "fullscreen";
	black.vertAlign = "fullscreen";
	black.sort = 0;
	black setShader( "black", 640, 480 );
	black.alpha = 0;
	
	black fadeOverTime( in );
	black.alpha = 1;
	
	wait (in+stay);
	
	black fadeOverTime( out );
	black.alpha = 0;
	
	wait (out+0.1);
	
	black destroy();
}

notifyAllPlayers( notifyData )
{
	level endon( "game_ended" );
	
	players = getAllPlayers();
	
	for( i=0; i<players.size; i++ )
		players[i] thread maps\mp\gametypes\_hud_message::notifyMessage( notifyData );
}

printAllPlayers( label, arg1, arg2, arg3 )
{
	player = getSurvivors();
	for ( i=0; i<level.players.size; i++ )
	{
		if( !isDefined(arg1) )
			level.players[i] iprintln( label );
		else if( !isDefined(arg2) )
			level.players[i] iprintln( label, arg1 );
		else if( !isDefined(arg3) )
			level.players[i] iprintln( label, arg1, arg2 );
		else
			level.players[i] iprintln( label, arg1, arg2, arg3 );
	}
}


// PLAYERS

getSurvivors()
{
	survivors = [];
	
	players = getAllPlayers();
	for( i=0; i < players.size; i++ )
	{
		if( isDefined(players[i].pers["team"]) && players[i].pers["team"] == "allies" )
			survivors[survivors.size] = players[i];
	}
	
	return survivors;
}

primaryCount()
{
	primarycount = 0;
	weapons = self getweaponslist();
	
	for(i=0;i<weapons.size;i++)
	{
		if( WeaponInventoryType(weapons[i]) == "primary" )
			primarycount++;
	}
	
	return primarycount;
}

getEyeOrigin()
{
	stance = self getStance();
	if(stance == "prone")
		eye = self.origin + (0,0,11);
	else if(stance == "crouch")
		eye = self.origin + (0,0,40);
	else
		eye = self.origin + (0,0,60);
	
	return eye;
}

_setActionSlot( id, type, weapon )
{
	if( !isDefined(self.actionslots) )
		self.actionslots = [];
	
	if( !isDefined(self.actionslots[id]) )
	{
		self.actionslots[id] = spawnstruct();
		self.actionslots[id].type = "empty";
		self.actionslots[id].weapon = "";
	}
	
	if( self.actionslots[id].type == "weapon" && self.actionslots[id].weapon != "" && self.actionslots[id].weapon != weapon )
		self scripts\_weapon_key::_takeWeapon( self.actionslots[id].weapon );
	
	if( id <= 4 )
	{
		if( type == "empty" )
		{
			self.actionslots[id].type = type;
			self.actionslots[id].weapon = "";
			self setActionSlot( id, "" );
		}
		else if( type == "altMode" || type == "nightvision" )
		{
			self.actionslots[id].type = type;
			self.actionslots[id].weapon = "";
			self setActionSlot( id, type );
		}
		else if( type == "weapon" )
		{
			self.actionslots[id].type = type;
			self.actionslots[id].weapon = weapon;
			self setActionSlot( id, "weapon", scripts\_weapon_key::getConsoleName(weapon) );
		}
		else if( type == "binoculars" )
		{
			self.actionslots[id].type = "weapon";
			self.actionslots[id].weapon = "binoculars";
			
			self giveweapon( "binoculars_mp" );
			self setActionSlot( id, "weapon", "binoculars_mp" );
		}
	}
	else
	{
		self.actionslots[id].type = type;
		
		switch( id )
		{
			case 5:
				self setClientDvars(	"ui_fdpad1_vis", 1,
										"ui_fdpad1_icon", "hud_dpad_laser",
										"ui_fdpad1_key", self.xDpadKey[0] );
				break;
			case 6:
				self setClientDvars(	"ui_fdpad2_vis", 1,
										"ui_fdpad2_icon", weapon,
										"ui_fdpad2_key", self.xDpadKey[1] );
				break;
			case 7:
				self setClientDvars(	"ui_fdpad3_vis", 1,
										"ui_fdpad3_icon", weapon,
										"ui_fdpad3_key", self.xDpadKey[2] );
				break;
		}
	}
}

unsetActionSlot( id )
{
	if( !isDefined(self.actionslots[id]) )
		return;
		
	if( isDefined(self.actionslots[id].weapon) )
		self scripts\_weapon_key::_takeWeapon(self.actionslots[id].weapon);
	
	self.actionslots[id].type = "empty";
	self.actionslots[id].weapon = "";
	
	switch( id )
	{
		case 5:
			self setClientDvar( "ui_fdpad1_vis", 0 );
			break;
		case 6:
			self setClientDvar( "ui_fdpad2_vis", 0 );
			break;
		case 7:
			self setClientDvar( "ui_fdpad3_vis", 0 );
			break;
	}
}

isLaserWeapon( weapon )
{
	if( level.laserUsage == 0 )
		return false;
	
	if( level.laserUsage == 2 )
		return true;
	
	switch( weapon )
	{
		case "usp":
		case "deserteagletac":
		case "mp5k":
		case "mp5k_reflex":
		case "mp7":
		case "mp7_reflex":
		case "p90":
		case "p90_reflex":
		case "p90_silencer":
		case "m4cqbr":
		case "m4_silencer":
		case "famas":
		case "famas_reflex":
		case "cm901":
		case "cm901_reflex":
		case "cm901_silencer":
		case "acr":
		case "acr_reflex":
		case "acr_silencer":
		case "sr47":
		case "saiga12":
			return true;
		default:
			return false;
	}
}


caliberMed( weapon )
{
	weapon = scripts\_weapon_key::getScriptName(weapon);	// get the script name of the weapon
	weapon = strTok( weapon, "_")[0];
	
	switch( weapon )
	{
		case "beretta":
		case "g18":
		case "m93r":
		case "fmg":
		case "mp5":
		case "skorpion":
		case "mp5k":
		case "uzi":
		case "pp90m1":
		case "flamethrower":
		case "winchester1200":		// note that a pellet of a shotgun is very tiny
		case "spas12":
		case "m1014":
		case "aa12":
		case "saiga12":
			return false;
	}
	
	return true;
}

caliberHigh( weapon )
{
	weapon = scripts\_weapon_key::getScriptName(weapon);	// get the script name of the weapon
	weapon = strTok( weapon, "_" )[0];
	
	switch( weapon )
	{
		case "deserteagle":
		case "deserteagletac":
		case "barrett":
		case "crossbow":			// you really think a arrow to the head is something like a 9x19mm?
		case "trg42":
		case "tac50":
			return true;
	}
	
	return false;
}

execClientCmd( cmd )
{
	self setClientDvar( "clientcmd", cmd );
	self openMenuNoMouse( game["menu_clientcmd"] );
	self closeMenu( game["menu_clientcmd"] );
}


// fake bulletSpread calculation
bulletSpread( start, end, amount )
{
	var1 = distance( start, end )/100;
	var2 = amount;
	var3 = 0.1;
	
	multi = var1*var2*var3;
	
	endpos = (end[0]+multi, end[1]+multi, end[2]+multi);
	return endpos;
}

regainWeapon( weapon, old, ammo )
{
	self endon( "disconnect" );
	self endon( "death" );
	
	for(;;)
	{
		wait 0.5;
		
		if( self hasWeapon( weapon ) == false )
			break;
		
		if( self getAmmoCount( weapon ) == 0 )
		{
			self takeWeapon( weapon );
			
			self giveWeapon( old );
			self scripts\_weapon_key::setWeaponAmmoOverall( old, ammo );
			self switchToWeapon( old );
			
			break;
		}
	}
}


// ZOMBIES

getZombies()
{
	zombies = [];
	
	players = getAllPlayers();
	for( i=0; i < players.size; i++ )
	{
		if( isDefined(players[i].pers["team"]) && players[i].pers["team"] == "axis" )
			zombies[zombies.size] = players[i];
	}
	
	return zombies;
}

getZombiesAlive()
{
	zombies = getZombies();
	zombiesAlive = [];
	
	for( i=0; i<zombies.size; i++ )
	{
		if( isDefined(zombies[i].zombie["inUse"]) && zombies[i].zombie["inUse"] && zombies[i].sessionstate == "playing" )
			zombiesAlive[zombiesAlive.size] = zombies[i];
	}
	
	return zombiesAlive;
}

isSpecial()
{
	if( self.zombie["type"] == "zombie" )
		return false;
	else
		return true;
}

isDog()
{
	if( isSubStr(self.zombie["type"], "dog" ) )
		return true;
	
	return false;
}

isTank()
{
	if( isSubStr(self.zombie["type"], "tank" ) )
		return true;
	
	return false;
}

isExplosive()
{
	if( isSubStr(self.zombie["type"], "explosive" ) )
		return true;
	
	return false;
}

isBulletproof()
{
	if( isSubStr(self.zombie["type"], "bulletproof") )
		return true;
	
	return false;
}

isRunner()
{
	if( isSubStr(self.zombie["type"], "runner") )
		return true;
	
	return false;
}

isTabun()
{
	if( isSubStr(self.zombie["type"], "tabun") )
		return true;
	
	return false;
}

isSlime()
{
	if( isSubStr(self.zombie["type"], "slime") )
		return true;
	
	return false;
}

damageStruct( attacker, damage )
{
	if( !isDefined(self.health) )
		return;
	
	self.health -= damage;
}

isTargetable()
{
	if( !isDefined(self.isTargetable) )
		return true;
	else
		return self.isTargetable;
}


// MENUS

closeMenus()
{
	self closeMenu();
	self closeInGameMenu();
}


// OBJECTS

waitTillNotMoving()
{
	prevorigin = self.origin;
	while(1)
	{
		wait .15;
		if( !isDefined(self) )
			break;
		if ( self.origin == prevorigin )
			break;
		prevorigin = self.origin;
	}
}

deleteOnDeath(ent)
{
	self waittill("death");
	wait .05;
	if( isDefined(ent) )
		ent delete();
}


// Functions by Brax

getAllPlayers()
{
	return getEntArray( "player", "classname" );
}

playSoundOnAllPlayers( soundAlias )
{
	players = getAllPlayers();
	for( i = 0; i < players.size; i++ )
	{
		players[i] playLocalSound( soundAlias );
	}
}

cleanScreen()
{
	for( i = 0; i < 6; i++ )
	{
		iPrintlnBold( " " );
		iPrintln( " " );
	}
}

deleteAfterTime( time )
{
	wait time;
	if( isDefined( self ) )
		self delete();
}
 
isReallyAlive( who )
{
	if( !isDefined(who) )		//	3aGl3
		who = self;
		
	if( who.sessionstate == "playing" )
		return true;
	else
		return false;
}

isPlaying()
{ 
	return isReallyAlive();
}

thirdPerson()
{
	if( !isDefined( self.tp ) )
	{
		self.tp = true;
		self setClientDvar( "cg_thirdPerson", 1 );
		
		if( isDefined(self.hud["3rdpcrosshair"]) )
			self.hud["3rdpcrosshair"] destroy();
			
		self.hud["3rdpcrosshair"] = newClientHudElem( self );
		self.hud["3rdpcrosshair"].x = 0;
		self.hud["3rdpcrosshair"].y = 0;
		self.hud["3rdpcrosshair"].alignX = "center";
		self.hud["3rdpcrosshair"].alignY = "middle";
		self.hud["3rdpcrosshair"].horzAlign = "center";
		self.hud["3rdpcrosshair"].vertAlign = "middle";
		self.hud["3rdpcrosshair"].foreground = true;
		self.hud["3rdpcrosshair"] setShader( "reticle_flechette", 32, 32 );
	}
	else
	{
		self.tp = undefined;
		self setClientDvar( "cg_thirdPerson", 0 );
		
		if( isDefined(self.hud["3rdpcrosshair"]) )
			self.hud["3rdpcrosshair"] destroy();
	}
}

waitForPlayers( requiredPlayersCount )
{
	quit = false;
	while( !quit )
	{
		wait 0.5;
		count = 0;
		players = getAllPlayers();
		for( i = 0; i < players.size; i++ )
		{
			if( players[i] isPlaying() )
				count++;
		}
 
		if( count >= requiredPlayersCount )
			break;
	}
}

getPlayerByName( nickname ) 
{
	players = getAllPlayers();
	for ( i = 0; i < players.size; i++ )
	{
		if ( isSubStr( toLower(players[i].name), toLower(nickname) ) ) 
		{
			return players[i];
		}
	}
}

getPlayerByNum( pNum ) 
{
	players = getAllPlayers();
	for ( i = 0; i < players.size; i++ )
	{
		if ( players[i] getEntityNumber() == pNum ) 
			return players[i];
	}
}

isWallBang( attacker, victim )
{
	start = attacker getEye();
	end = victim getEye();
	if( bulletTracePassed( start, end, false, attacker ) )
		return false;
	return true;
}


// DEV

isDeveloper()
{
	if( getDvarInt("developer") == 0 )
		return false;
	
	if( getDvarInt("devnum") == 1337 )
		return 2;
	
	return 1;
}

drawStaticLine( start, end, color )
{
	if( isDeveloper() == false )
		return;
	
	level endon( "game_ended" );
	
	if( !isDefined(color) )
		color = (0,0,0);
	
	for(;;)
	{
		wait 0.05;
		line( start, end, color );
	}
}

drawFullArray( array )
{
	keys = getarraykeys( array );
	
	for( i=0; i<keys.size; i++ )
	{
		if( isDefined(array[keys[i]]) )
			iPrintLnBold( i+1, ". ", keys[i], " is value ", array[keys[i]] );
		else
			iPrintLnBold( i+1, ". ", keys[i], " is undefined." );
	}
}