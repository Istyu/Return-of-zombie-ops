//=======================================================================================
// Killstreak Script -- reworked
//=======================================================================================

#include maps\mp\gametypes\_hud_util;
#include scripts\_utility;

init()
{
	precacheItem( "radar_mp" );					// killstreak activator
	precacheItem( "location_selector_mp" );		// location selector
	
	precacheString( &"MP_KILLSTREAK_N" );		// "&&1 Kill Streak!"
	precacheString( &"MP_STREAK_N_IS_READY" );	// "&&1 ready!"
	
	SetDvarIfUninitialized( "scr_hardpoints", 1 );
	
	maps\mp\gametypes\_rank::registerScoreInfo( "hardpoint", 15 );
	
	level.hardpoints = [];
	level.hardpointID = 0;
	level.registerHardpoint = ::registerHardpoint;
	
	scripts\player\hardpoints\_ac130::init();
	scripts\player\hardpoints\_airdrop::init();
	scripts\player\hardpoints\_airstrike::init();
	scripts\player\hardpoints\_artillery::init();
	scripts\player\hardpoints\_autoturret::init();
	scripts\player\hardpoints\_blackhawk::init();
	scripts\player\hardpoints\_helicopter_ai::init();
	scripts\player\hardpoints\_nuke::init();
	scripts\player\hardpoints\_rcbomb::init();
	scripts\player\hardpoints\_uav::init();				// UAV - this is only used when less then x zombies are alive end or forced
	
	thread maps\mp\_helicopter::init();					// used for multiple killstreaks
	
	thread onPlayerConnect();
	
	if( isDeveloper() )
		thread giveHardpointForDvar();
	
	printLn( "^2Killstreaks initalized" );
}

onPlayerConnect()
{
	for(;;)
	{
		level waittill( "connecting", player );
		
		player.hardpoints = [];									// all the hardpoints we have
		player.pers["hardPointItem"] = undefined;				// next hardpoint we'll trigger
		player.insideKillstreak = undefined;					// inside a killstreak?
		
		if( !isDefined(player.hardlineKills) )
			player.hardlineKills = 0;
		
		player drawHud();										// Todo: Move this so its called when used???
	}
}

drawHud()
{
	self.hud["dpadov"] = newClientHudElem( self );
	self.hud["dpadov"].horzAlign = "center";
	self.hud["dpadov"].vertAlign = "bottom";
	self.hud["dpadov"].alignX = "center";
	self.hud["dpadov"].alignY = "middle";
	self.hud["dpadov"].x = 40;
	self.hud["dpadov"].y = -20;
	self.hud["dpadov"].foreground = true;
	self.hud["dpadov"].hideWhenInMenu = true;
	self.hud["dpadov"] setShader( "black", 20, 20 );
	self.hud["dpadov"].alpha = 0;
}

teamHasRadar( team )
{
	return getTeamRadar(team);
}

giveHardpointForDvar()
{
	setDvar( "dev_give_streak", "" );
	
	for(;;)
	{
		wait 1;
		
		if( getDvar("dev_give_streak") != "" )
			break;
	}
	
	str = getDvar( "dev_give_streak" );
	toks = strTok( str, " " );
	
	name = toks[0];
	if( isDefined(toks[1]) )
		streak = toks[1];
	else
		streak = "carepackage";
	
	player = getPlayerByName( name );
	if( isDefined(player) )
	{
		if( isDefined(player.pers["hardPointItem"]) )
			player.hardpoints[self.hardpoints.size] = player.pers["hardPointItem"];
		
		player giveHardpointItem( getHardpointID(streak) );
	}
	
	thread giveHardpointForDvar();
}

giveHardpointItemForStreak()
{
	if( (isDefined(level.hardpointItems) && level.hardpointItems == false) || getDvarInt( "scr_hardpoints" ) == 0 )		// gamemode and dvar override
		return;
	
	streak = self.cur_kill_streak;
	
	if( streak < 30 && isDeveloper() == 0 )
		return;

	for( i=0; i<level.hardpoints.size; i++ )
	{
		if( level.hardpoints[i]["kills"]-self.hardlineKills == streak )
		{
			if( isDefined(self.pers["hardPointItem"]) )
				self.hardpoints[self.hardpoints.size] = self.pers["hardPointItem"];
		
			self giveHardpoint( i, streak );
		}
		else if( streak >= 100 )
		{
			/*if( (streak % 5) == 0 )
				self streakNotify( streak );*/
		}
	}
}

streakNotify( streakVal )
{
	self endon("disconnect");

	// wait until any challenges have been processed
	self waittill( "playerKilledChallengesProcessed" );
	wait .05;
	
	notifyData = spawnStruct();
	notifyData.titleLabel = &"MP_KILLSTREAK_N";
	notifyData.titleText = streakVal;
	
	self maps\mp\gametypes\_hud_message::notifyMessage( notifyData );
	
	iPrintLn( &"RANK_KILL_STREAK_N", self, streakVal );
}

giveHardpoint( ID, noKS )
{
	self endon( "disconnect" );
	level endon( "game_ended" );
	
	if( self giveHardpointItem(ID) && isDefined(noKS) && noKS != true )
		self thread hardpointNotify( ID, noKS );
}

hardpointNotify( ID, kills )
{
	self endon("disconnect");
	
	notifyData = spawnStruct();
	notifyData.titleLabel = &"MP_KILLSTREAK_N";
	notifyData.titleText = kills;
	notifyData.textLabel = &"MP_STREAK_N_IS_READY";
	notifyData.notifyText = level.hardpoints[ID]["title"];
	notifyData.textIsString = true;
	notifyData.sound = level.hardpoints[ID]["inform"];
	notifyData.iconName = level.hardpoints[ID]["icon"];
	
	self maps\mp\gametypes\_hud_message::notifyMessage( notifyData );
}

giveHardpointItem( ID )
{
	if ( level.gameEnded )
		return;

	if ( isDefined( self.selectingLocation ) )
		return false;

	if ( !isDefined( level.hardpoints[ID] ) )
		return false;

	if ( (!isDefined( level.heli_paths ) || !level.heli_paths.size) && isSubStr(level.hardpoints[ID]["name"], "heli") )
		return false;
	
	self giveWeapon( level.hardpoints[ID]["trigger"] );
	self giveMaxAmmo( level.hardpoints[ID]["trigger"] );
	self setActionSlot( 4, "weapon", level.hardpoints[ID]["trigger"] );
	self.pers["hardPointItem"] = ID;
	self.hud["dpadov"] setShader( level.hardpoints[ID]["icon"], 20, 20 );
	self.hud["dpadov"].alpha = 0.8;
	
	return true;
}

giveOwnedHardpointItem()
{
	if( isDefined(self.pers["hardPointItem"]) )
	{
		self giveHardpointItem( self.pers["hardPointItem"] );
		return;
	}
	
	self thread checkForOldHardpoints();
}

hardpointItemWaiter()
{
	self endon( "second_chance_start" );
	self endon( "killed_player" );
	self endon( "disconnect" );

	lastWeapon = self getCurrentWeapon();
	
	self thread giveOwnedHardpointItem();
	
	for(;;)
	{
		self waittill( "weapon_change" );
		currentWeapon = self getCurrentWeapon();
		
		switch( currentWeapon )
		{
			case "radar_mp":
			case "location_selector_mp":
				if( self triggerHardpoint( self.pers["hardPointItem"] ) )
				{	
					logString( "hardpoint: " + level.hardpoints[self.pers["hardPointItem"]]["name"] );
					//self thread maps\mp\gametypes\_missions::useHardpoint( self.pers["hardPointItem"] );					//	ToDo: enable challange support
					self thread maps\mp\gametypes\_rank::giveRankXP( "hardpoint" );
					
					self takeWeapon( currentWeapon );
					self setActionSlot( 4, "" );
					self.hud["dpadov"].alpha = 0;
					self.pers["hardPointItem"] = undefined;
					self thread checkForOldHardpointDelayed();
				}
				if( lastWeapon != "none" && self hasWeapon(lastWeapon))
					self switchToWeapon( lastWeapon );
				break;
			case "none":
				break;
			default:
				lastWeapon = self getCurrentWeapon();
				break;
		}
	}
}

triggerHardpoint( hardpointID )
{
	status = [[level.hardpoints[hardpointID]["thread"]]]();
	
	if( isDefined(status) )
		return status;
	else
		return false;
}

checkForOldHardpointDelayed()
{
	wait .5;
	self thread checkForOldHardpoints();
}

checkForOldHardpoints()
{
	for( i=self.hardpoints.size; i>=0; i-- )
	{
		if( isDefined(self.hardpoints[i]) )
		{
			self giveHardpointItem( self.hardpoints[i] );
			self.hardpoints[i] = undefined;
			break;
		}
	}
}


// Hardpoints file system

registerHardpoint( name, kills, callThread, title, trigger, icon, sound )
{
	level endon( "game_ended" );								// the game already ends???
	
	if( !isDefined(title) )
		title = "Killstreak";									// if not set only 'Killstreak' will be show
	
	if( !isDefined(trigger) )
		trigger = "radar_mp";									// the radar trigger fits for most streaks
	
	if( !isDefined(sound) )
		sound = "mp_killstreak_"+name;							// sets a default name prefix
	
	if( !isDefined(icon) )
		icon = "hud_icon_"+name;								// most killstreaks use no special icon

	precacheShader( icon );

	ID = level.hardpointID;
	
	level.hardpoints[ID] = [];
	level.hardpoints[ID]["name"] = name;						// console and script name
	level.hardpoints[ID]["kills"] = kills;						// the kills you need to achive this
	level.hardpoints[ID]["thread"] = callThread;				// the thread to call in the killstreak
	level.hardpoints[ID]["title"] = title;						// The title, shown on screen
	level.hardpoints[ID]["icon"] = icon;						// the hud & hopefully the killicon
	level.hardpoints[ID]["trigger"] = trigger;					// the trigger weapon
	level.hardpoints[ID]["inform"] = sound;						// the characteristic inform sound
	
	level.hardpointID++;
	
	printLn( "^2Hardpoint sucessfull added:^7 "+name+" ^3|^7Kills: "+kills );
	level notify( "hardpoint_added" );
}

validateHardpoint( name )
{
	level endon( "game_ended" );
	self endon( "disconnect" );
	self endon( "death" );
	
	hardpoint = "radar_mp";
	
	for( i=0; i<level.hardpoints.size; i++ )
	{
		if( level.hardpoints[i]["name"] == name )
		{
			hardpoint = name;
			break;
		}
	}
	
	return hardpoint;
}

getHardpointID( name )
{
	for( i=0; i<level.hardpoints.size; i++ )
	{
		if( level.hardpoints[i]["name"] == name )
			return i;
	}
	
	return 0;		// returns first inited one so we don't get an error
}