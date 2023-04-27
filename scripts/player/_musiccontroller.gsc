/*=======================================================================================
Return of the Zombie Ops - Mod
Modded by Lefti & 3aGl3
=========================================================================================
Zombie MusicController by 3aGl3
=======================================================================================*/
#include scripts\_utility;

init()
{	
	level.radio_use = xDvarBool( "scr_radio_use", 1 );						// use radio script - on = 1 / off = 0	
	level.radio_random = xDvarBool( "scr_radio_random", 1 );				// shuffle tracks - on = 1 / off = 0	
	level.radio_announce = xDvarInt( "scr_radio_announce", 1, 1, 2 );		// way of announcing a new track [default: 1, min: 0, max: 2]
	level.radio_custom = xDvarBool( "scr_radio_custom", 0 );				// use custom radio songs
	level.radio_tracks = xDvarInt( "scr_radio_tracks", 5, 0, 20 );			// How many tracks do you want to play ?
		
	if( level.radio_use == 0 )
		return;
	
	precacheString( &"ZMB_NOW_PLAYING_N" );		// Now playing &&1.

	tracks = level.radio_tracks;

	if( level.radio_custom )
	{
		level.radiotrack = [];
		
		for( i=0; i<tracks; i++ )
		{
			name = getDvar( "scr_radio_csong"+i+"_name" );
			if( !isDefined(name) || name == "" )
				break;
			
			level.radiotrack[i]["sound"] = "radio_track_"+i;
			level.radiotrack[i]["name"] = name;
			level.radiotrack[i]["length"] = getDvarInt( "scr_radio_csong"+i+"_time" );
		}
	}
	else
	{
		level.radiotrack[0]["sound"] = "armada_seanprice_church";
		level.radiotrack[0]["name"] = "COD4 - Armada Church";
		level.radiotrack[0]["length"] = 228;
		
		level.radiotrack[1]["sound"] = "hgw_airlift_deploy";
		level.radiotrack[1]["name"] = "COD4 - Airlift deploy";
		level.radiotrack[1]["length"] = 100;
		
		level.radiotrack[2]["sound"] = "hgw_airlift_nuke";
		level.radiotrack[2]["name"] = "COD4 - Airlift Nuke";
		//level.radiotrack[2]["length"] = 100;
		
		level.radiotrack[3]["sound"] = "hgw_airlift_start";
		level.radiotrack[3]["name"] = "COD4 - Airlift start";
		level.radiotrack[3]["length"] = 131;
		
		level.radiotrack[4]["sound"] = "hgw_airplane_alt";
		level.radiotrack[4]["name"] = "COD4 - Airplane";
		level.radiotrack[4]["length"] = 185;
		
		level.radiotrack[5]["sound"] = "hgw_armada_start";
		level.radiotrack[5]["name"] = "COD4 - Armada";
		//level.radiotrack[5]["length"] = 100;
		
		level.radiotrack[6]["sound"] = "hgw_blackout_hurry";
		level.radiotrack[6]["name"] = "COD4 - Blackout hurry";
		level.radiotrack[6]["length"] = 54;
		
		level.radiotrack[7]["sound"] = "hgw_boga_shantytown";
		level.radiotrack[7]["name"] = "COD4 - Shantytown";
		level.radiotrack[7]["length"] = 60;
		
		level.radiotrack[8]["sound"] = "hgw_boga_tankdefense";
		level.radiotrack[8]["name"] = "COD4 - Tankdefense";
		//level.radiotrack[8]["length"] = 100;
		
		level.radiotrack[9]["sound"] = "hgw_boga_victory";
		level.radiotrack[9]["name"] = "COD4 - Bog Victory";
		level.radiotrack[9]["length"] = 85;
		
		level.radiotrack[10]["sound"] = "hgw_cargoship_escape";
		level.radiotrack[10]["name"] = "COD4 - Cargoship escape";
		level.radiotrack[10]["length"] = 84;
		
		level.radiotrack[11]["sound"] = "hgw_coup_intro";
		level.radiotrack[11]["name"] = "COD4 - Coup";
		level.radiotrack[11]["length"] = 211;
		
		level.radiotrack[12]["sound"] = "hgw_gameshell";
		level.radiotrack[12]["name"] = "Nightcore - Whispers in the dark";
		level.radiotrack[12]["length"] = 171;
		
		level.radiotrack[13]["sound"] = "hgw_icbm_tension";
		level.radiotrack[13]["name"] = "COD4 - Russia";
		level.radiotrack[13]["length"] = 103;
		
		level.radiotrack[14]["sound"] = "hgw_adrenaline";
		level.radiotrack[14]["name"] = "BO II - Adrenaline";
		level.radiotrack[14]["length"] = 205;
		
		level.radiotrack[15]["sound"] = "hgw_stag_push";
		level.radiotrack[15]["name"] = "WAW - Stag push";
		level.radiotrack[15]["length"] = 88;
		
		level.radiotrack[16]["sound"] = "hgw_underscore";
		level.radiotrack[16]["name"] = "WAW - Berlin loose";
		level.radiotrack[16]["length"] = 182;
	}
	
	thread onPlayerConnect();
}

onPlayerConnect()
{
	for(;;)
	{
		level waittill( "connected", player );
		
		player thread startRadio();
	}
}

startRadio()
{
	self endon( "disconnect" );
	
	if( !isDefined(self.radio) )
	{
		self.radio["playing"] = true;
		self.radio["track"] = randomInt(level.radiotrack.size);
		self.radio["loop"] = false;
		self.radio["random"] = level.radio_random;
	}
	
	self thread playRadio( true );
}

responseHandler( response )
{
	level endon( "game_ended" );
	self endon( "disconnect" );
	
	switch( response )
	{
		case "STOP":
			self togglePlaying();
			break;
		case "SHUFFLE":
			self toggleShuffle();
			break;
		case "LOOP":
			self toggleLoop();
			break;
		case "NEXT":
			self doOtherSong( "next" );
			break;
		case "PREV":
			self doOtherSong( "prev" );
			break;
	}
	
	self closeMenu();
	self closeInGameMenu();
}

togglePlaying()
{
	self.radio["playing"] = !self.radio["playing"];
	if( self.radio["playing"] )
	{
		self thread playRadio( false );
		self iPrintLnBold( "Radio started" );
	}
	else
	{
		self notify("radioBreak");
	
		self stoplocalsound( level.radiotrack[self.radio["track"]]["sound"], 0.5 );
		wait 0.5;
		
		self iPrintLnBold( "Radio stopped" );
	}
}

toggleShuffle()
{
	self.radio["random"] = !self.radio["random"];
	if( self.radio["random"] )
		self iPrintLnBold( "Radio is now shuffeling" );
	else
		self iPrintLnBold( "Radio is not shuffeling" );
}

toggleLoop()
{
	self.radio["loop"] = !self.radio["loop"];
	if( self.radio["loop"] )
		self iPrintLnBold( "Song looped" );
	else
		self iPrintLnBold( "Radio loop stoped" );
}

doOtherSong( dir )
{
	self notify("radioBreak");
	
	self stoplocalsound( level.radiotrack[self.radio["track"]]["sound"], 0.5 );
	wait 0.5;
	
	if( dir == "next" )
	{
		self.radio["track"]++;
		if( self.radio["track"] >= level.radiotrack.size )
			self.radio["track"] = 0;
	}
	else
	{
		self.radio["track"]--;
		if( self.radio["track"] < 0 )
			self.radio["track"] = level.radiotrack.size-1;
	}
	
	self thread playRadio( false );
}

playRadio( spawn )
{
	self endon( "disconnect" );
	self endon( "radioBreak" );
	
	if( spawn )
		self waittill( "spawned" );

	for(;;)
	{
		wait .1;
		
		if( self.radio["playing"] == false )
			break;
		
		if( level.radio_announce == 1 )
		{
			if( isDefined(level.radiotrack[self.radio["track"]]["name"]) && level.radiotrack[self.radio["track"]]["name"] != "" )
				self iPrintLn( &"ZMB_NOW_PLAYING_N", level.radiotrack[self.radio["track"]]["name"] );
			else
				self iPrintLn( &"ZMB_NOW_PLAYING_N", level.radiotrack[self.radio["track"]]["sound"] );
		}
		else if( level.radio_announce == 2 )
		{
			if( isDefined(level.radiotrack[self.radio["track"]]["name"]) && level.radiotrack[self.radio["track"]]["name"] != "" )
				self iPrintLn( &"ZMB_NOW_PLAYING_N",level.radiotrack[self.radio["track"]]["name"] );
			else
				self iPrintLn( &"ZMB_NOW_PLAYING_N",level.radiotrack[self.radio["track"]]["sound"] );
		}
		
		self playlocalsound( level.radiotrack[self.radio["track"]]["sound"] );
		
		if( isDefined(level.radiotrack[self.radio["track"]]["length"]) )
			wait level.radiotrack[self.radio["track"]]["length"];
		else
			wait 100;
		
		self nextTrack();
	}
}

nextTrack()
{
	self endon( "disconnect" );
	self endon( "radioBreak" );
	
	if( self.radio["loop"] )
		return;
	
	if( !self.radio["playing"] )
		return;
	
	if( self.radio["random"] )
	{
		num = randomInt( level.radiotrack.size );
		if( num == self.radio["track"] )
			num = randomInt( level.radiotrack.size);
		
		self.radio["track"] = num;
	}
	else
	{
		self.radio["track"]++;
		if( self.radio["track"] >= level.radiotrack.size )
			self.radio["track"] = 0;
	}
}
