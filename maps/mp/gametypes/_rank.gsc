/*=======================================================================================
Return of the Zombie Ops - Mod
Modded by Lefti & 3aGl3
=========================================================================================
Ranks
=======================================================================================*/
#include scripts\_utility;
#include common_scripts\utility;
#include maps\mp\gametypes\_hud_util;

init()
{
	level.scoreInfo = [];
	level.rankTable = [];

	precacheShader("white");

	precacheString( &"RANK_PLAYER_WAS_PROMOTED_N" );
	precacheString( &"RANK_PLAYER_WAS_PROMOTED" );
	precacheString( &"RANK_PROMOTED" );
	precacheString( &"MP_PLUS" );
	precacheString( &"RANK_ROMANI" );
	precacheString( &"RANK_ROMANII" );
	precacheString( &"RANK_ROMANIII" );
	
	registerScoreInfo( "kill", 10 );
	registerScoreInfo( "headshot", 10 );
	registerScoreInfo( "assist_25", 2 );
	registerScoreInfo( "assist_50", 5 );
	registerScoreInfo( "assist_75", 7 );
	registerScoreInfo( "suicide", 0 );
	registerScoreInfo( "teamkill", 0 );
	
	registerScoreInfo( "win", 1 );
	registerScoreInfo( "loss", 0.5 );
	registerScoreInfo( "tie", 0.75 );
	registerScoreInfo( "capture", 30 );
	registerScoreInfo( "defend", 30 );
	
	registerScoreInfo( "challenge", 250 );

	level.maxRank = int(tableLookup( "mp/rankTable.csv", 0, "maxrank", 1 ));
	level.maxPrestige = int(tableLookup( "mp/rankIconTable.csv", 0, "maxprestige", 1 ));
	
	pId = 0;
	rId = 0;
	for ( pId = 0; pId <= level.maxPrestige; pId++ )
	{
		for ( rId = 0; rId <= level.maxRank; rId++ )
			precacheShader( tableLookup( "mp/rankIconTable.csv", 0, rId, pId+1 ) );
	}

	for( rankId=0; rankId <= level.maxRank; rankId++ )
	{
		rankName = tableLookup( "mp/rankTable.csv", 0, rankId, 1 );
		assert( isDefined( rankName ) && rankName != "" );
	
		level.rankTable[rankId][1] = tableLookup( "mp/rankTable.csv", 0, rankId, 1 );
		level.rankTable[rankId][2] = tableLookup( "mp/rankTable.csv", 0, rankId, 2 );
		level.rankTable[rankId][3] = tableLookup( "mp/rankTable.csv", 0, rankId, 3 );
		level.rankTable[rankId][7] = tableLookup( "mp/rankTable.csv", 0, rankId, 7 );

		precacheString( tableLookupIString( "mp/ranktable.csv", 0, rankId, 16 ) );
		//printLn( "Loaded Rank "+rankId+", rank name: "+rankName );
	}

	level.statOffsets = [];
	level.statOffsets["weapon_assault"] = 290;
	level.statOffsets["weapon_lmg"] = 291;
	level.statOffsets["weapon_smg"] = 292;
	level.statOffsets["weapon_shotgun"] = 293;
	level.statOffsets["weapon_sniper"] = 294;
	level.statOffsets["weapon_pistol"] = 295;
	level.statOffsets["perk1"] = 296;
	level.statOffsets["perk2"] = 297;
	level.statOffsets["perk3"] = 298;

	level.numChallengeTiers	= 10;
	
	//buildChallegeInfo();																			// ToDo: challenges
	
	level thread onPlayerConnect();
}


isRegisteredEvent( type )
{
	if ( isDefined( level.scoreInfo[type] ) )
		return true;
	else
		return false;
}

registerScoreInfo( type, value )
{
	level.scoreInfo[type]["value"] = value;
}

getScoreInfoValue( type )
{
	return ( level.scoreInfo[type]["value"] );
}

getScoreInfoLabel( type )
{
	return ( level.scoreInfo[type]["label"] );
}

getRankInfoMinXP( rankId )
{
	return int(level.rankTable[rankId][2]);
}

getRankInfoXPAmt( rankId )
{
	return int(level.rankTable[rankId][3]);
}

getRankInfoMaxXp( rankId )
{
	return int(level.rankTable[rankId][7]);
}

getRankInfoFull( rankId )
{
	return tableLookupIString( "mp/ranktable.csv", 0, rankId, 16 );
}

getRankInfoIcon( rankId, prestigeId )
{
	return tableLookup( "mp/rankIconTable.csv", 0, rankId, prestigeId+1 );
}

getRankInfoUnlockWeapon( rankId )
{
	return tableLookup( "mp/ranktable.csv", 0, rankId, 8 );
}

getRankInfoUnlockPerk( rankId )
{
	return tableLookup( "mp/ranktable.csv", 0, rankId, 9 );
}

getRankInfoBuyWeapon( rankId )
{
	return tableLookup( "mp/ranktable.csv", 0, rankId, 10 );
}

getRankInfoBuyPerk( rankId )
{
	return tableLookup( "mp/ranktable.csv", 0, rankId, 11 );
}

getRankInfoUnlockChallenge( rankId )
{
	return tableLookup( "mp/ranktable.csv", 0, rankId, 12 );
}

getRankInfoUnlockFeature( rankId )
{
	return tableLookup( "mp/ranktable.csv", 0, rankId, 15 );
}
	// ToDo: Killstreak unlocking
getRankInfoUnlockKillstreak( rankId )
{
	return tableLookup( "mp/ranktable.csv", 0, rankId, 17 );
}

getRankInfoBuyKillstreak( rankId )
{
	return tableLookup( "mp/ranktable.csv", 0, rankId, 18 );
}

getRankInfoLevel( rankId )
{
	return int( tableLookup( "mp/ranktable.csv", 0, rankId, 13 ) );
}


onPlayerConnect()
{
	for(;;)
	{
		level waittill( "connected", player );

		player.pers["rankxp"] = player maps\mp\gametypes\_persistence::statGet( "rankxp" );
		printLn( player.name+" has "+player.pers["rankxp"]+" XP." );
		rankId = player getRankForXp( player getRankXP() );
		printLn( player.name+" has rankID "+rankId );
		player.pers["rank"] = rankId;
		player.pers["participation"] = 0;

		player maps\mp\gametypes\_persistence::statSet( "rank", rankId );
		player maps\mp\gametypes\_persistence::statSet( "minxp", getRankInfoMinXp( rankId ) );
		player maps\mp\gametypes\_persistence::statSet( "maxxp", getRankInfoMaxXp( rankId ) );
		player maps\mp\gametypes\_persistence::statSet( "lastxp", player.pers["rankxp"] );
		
		player.rankUpdateTotal = 0;
		
		// for keeping track of rank through stat#251 used by menu script
		// attempt to move logic out of menus as much as possible
		player.cur_rankNum = rankId;
		assertex( isdefined(player.cur_rankNum), "rank: "+ rankId + " does not have an index, check mp/ranktable.csv" );
		player setStat( 251, player.cur_rankNum );
		
		//prestige = player getPrestigeLevel();
		prestige = 0;
		player setRank( rankId, prestige );
		player.pers["prestige"] = prestige;
		
		// resetting unlockable vars
		if ( !isDefined( player.pers["unlocks"] ) )
		{
			player.pers["unlocks"] = [];
			player.pers["unlocks"]["weapon"] = 0;
			player.pers["unlocks"]["perk"] = 0;
			player.pers["unlocks"]["challenge"] = 0;
			player.pers["unlocks"]["camo"] = 0;
			player.pers["unlocks"]["attachment"] = 0;
			player.pers["unlocks"]["feature"] = 0;
			player.pers["unlocks"]["page"] = 0;

			// resetting unlockable dvars
			player setClientDvar( "player_unlockweapon0", "" );
			player setClientDvar( "player_unlockweapon1", "" );
			player setClientDvar( "player_unlockweapon2", "" );
			player setClientDvar( "player_unlockweapons", "0" );
			
			player setClientDvar( "player_unlockcamo0a", "" );
			player setClientDvar( "player_unlockcamo0b", "" );
			player setClientDvar( "player_unlockcamo1a", "" );
			player setClientDvar( "player_unlockcamo1b", "" );
			player setClientDvar( "player_unlockcamo2a", "" );
			player setClientDvar( "player_unlockcamo2b", "" );
			player setClientDvar( "player_unlockcamos", "0" );
			
			player setClientDvar( "player_unlockattachment0a", "" );
			player setClientDvar( "player_unlockattachment0b", "" );
			player setClientDvar( "player_unlockattachment1a", "" );
			player setClientDvar( "player_unlockattachment1b", "" );
			player setClientDvar( "player_unlockattachment2a", "" );
			player setClientDvar( "player_unlockattachment2b", "" );
			player setClientDvar( "player_unlockattachments", "0" );
			
			player setClientDvar( "player_unlockperk0", "" );
			player setClientDvar( "player_unlockperk1", "" );
			player setClientDvar( "player_unlockperk2", "" );
			player setClientDvar( "player_unlockperks", "0" );
			
			player setClientDvar( "player_unlockfeature0", "" );		
			player setClientDvar( "player_unlockfeature1", "" );	
			player setClientDvar( "player_unlockfeature2", "" );	
			player setClientDvar( "player_unlockfeatures", "0" );
			
			player setClientDvar( "player_unlockchallenge0", "" );
			player setClientDvar( "player_unlockchallenge1", "" );
			player setClientDvar( "player_unlockchallenge2", "" );
			player setClientDvar( "player_unlockchallenges", "0" );
			
			player setClientDvar( "player_unlock_page", "0" );
		}
		
		if ( !isDefined( player.pers["summary"] ) )
		{
			player.pers["summary"] = [];
			player.pers["summary"]["xp"] = 0;
			player.pers["summary"]["score"] = 0;
			player.pers["summary"]["challenge"] = 0;
			player.pers["summary"]["match"] = 0;
			player.pers["summary"]["misc"] = 0;

			// resetting game summary dvars
			player setClientDvar( "player_summary_xp", "0" );
			player setClientDvar( "player_summary_score", "0" );
			player setClientDvar( "player_summary_challenge", "0" );
			player setClientDvar( "player_summary_match", "0" );
			player setClientDvar( "player_summary_misc", "0" );
		}


		// resetting summary vars
		
		// set default popup in lobby after a game finishes to game "summary"
		// if player got promoted during the game, we set it to "promotion"
		player setclientdvar( "ui_lobbypopup", "" );
		
		player updateChallenges();
		player.explosiveKills[0] = 0;
		player.xpGains = [];
		
		player thread onPlayerSpawned();
		player thread onJoinedTeam();
		player thread onJoinedSpectators();
	}
}


onJoinedTeam()
{
	self endon("disconnect");

	for(;;)
	{
		self waittill("joined_team");
		self thread removeRankHUD();
	}
}


onJoinedSpectators()
{
	self endon("disconnect");

	for(;;)
	{
		self waittill("joined_spectators");
		self thread removeRankHUD();
	}
}


onPlayerSpawned()
{
	self endon("disconnect");

	for(;;)
	{
		self waittill("spawned_player");

		if(!isdefined(self.hud_rankscroreupdate))
		{
			self.hud_rankscroreupdate = newClientHudElem(self);
			self.hud_rankscroreupdate.horzAlign = "center";
			self.hud_rankscroreupdate.vertAlign = "middle";
			self.hud_rankscroreupdate.alignX = "center";
			self.hud_rankscroreupdate.alignY = "middle";
	 		self.hud_rankscroreupdate.x = 0;
			self.hud_rankscroreupdate.y = -60;
			self.hud_rankscroreupdate.font = "default";
			self.hud_rankscroreupdate.fontscale = 2.0;
			self.hud_rankscroreupdate.archived = false;
			self.hud_rankscroreupdate.color = (0.5,0.5,0.5);
			self.hud_rankscroreupdate maps\mp\gametypes\_hud::fontPulseInit();
		}
	}
}

roundUp( floatVal )
{
	if ( int( floatVal ) != floatVal )
		return int( floatVal+1 );
	else
		return int( floatVal );
}

giveRankXP( type, value )
{
	self endon("disconnect");

	/*if ( level.teamBased && (!level.playerCount["allies"] || !level.playerCount["axis"]) )					// ToDo: What exactly happens here?
		return;
	else if ( !level.teamBased && (level.playerCount["allies"] + level.playerCount["axis"] < 2) )
		return;*/

	if ( !isDefined( value ) )
		value = getScoreInfoValue( type );
	
	if ( !isDefined( self.xpGains[type] ) )
		self.xpGains[type] = 0;
	
	self.xpGains[type] += value;
		
	self incRankXP( value );

	if ( updateRank() )
		self thread updateRankAnnounceHUD();

	if ( type == "teamkill" )
		self thread updateRankScoreHUD( 0 - getScoreInfoValue( "kill" ) );
	else
		self thread updateRankScoreHUD( value );
	
	switch( type )
	{
		case "kill":
		case "headshot":
		case "suicide":
		case "teamkill":
		case "assist":
		case "capture":
		case "defend":
		case "return":
		case "pickup":
		case "assault":
		case "plant":
		case "defuse":
			self.pers["summary"]["score"] += value;
			self.pers["summary"]["xp"] += value;
			break;

		case "win":
		case "loss":
		case "tie":
			self.pers["summary"]["match"] += value;
			self.pers["summary"]["xp"] += value;
			break;

		case "challenge":
			self.pers["summary"]["challenge"] += value;
			self.pers["summary"]["xp"] += value;
			break;
			
		default:
			self.pers["summary"]["misc"] += value;	//keeps track of ungrouped match xp reward
			self.pers["summary"]["match"] += value;
			self.pers["summary"]["xp"] += value;
			break;
	}

	self setClientDvars(
			"player_summary_xp", self.pers["summary"]["xp"],
			"player_summary_score", self.pers["summary"]["score"],
			"player_summary_challenge", self.pers["summary"]["challenge"],
			"player_summary_match", self.pers["summary"]["match"],
			"player_summary_misc", self.pers["summary"]["misc"]
		);
}

updateRank()
{
	newRankId = self getRank();
	if ( newRankId == self.pers["rank"] )
		return false;

	oldRank = self.pers["rank"];
	rankId = self.pers["rank"];
	self.pers["rank"] = newRankId;

	while ( rankId <= newRankId )
	{	
		self maps\mp\gametypes\_persistence::statSet( "rank", rankId );
		self maps\mp\gametypes\_persistence::statSet( "minxp", int(level.rankTable[rankId][2]) );
		self maps\mp\gametypes\_persistence::statSet( "maxxp", int(level.rankTable[rankId][7]) );
	
		// set current new rank index to stat#252
		self setStat( 252, rankId );
	
		// tell lobby to popup promotion window instead
		self.setPromotion = true;
		if ( level.gameEnded )
			self setClientDvar( "ui_lobbypopup", "promotion" );
		
		// unlocks weapon =======
		unlockedWeapon = self getRankInfoUnlockWeapon( rankId );	// unlockedweapon is weapon reference string
		if ( isDefined( unlockedWeapon ) && unlockedWeapon != "" )
			unlockWeapon( unlockedWeapon );
	
		// unlock perk ==========
		unlockedPerk = self getRankInfoUnlockPerk( rankId );	// unlockedweapon is weapon reference string
		if ( isDefined( unlockedPerk ) && unlockedPerk != "" )
			unlockPerk( unlockedPerk );
			
		// unlock challenge =====
		unlockedChallenge = self getRankInfoUnlockChallenge( rankId );
		if ( isDefined( unlockedChallenge ) && unlockedChallenge != "" )
			unlockChallenge( unlockedChallenge );

		// unlock feature ======
		unlockedFeature = self getRankInfoUnlockFeature( rankId );	// ex: feature_cac
		if ( isDefined( unlockedFeature ) && unlockedFeature != "" )
			unlockFeature( unlockedFeature );
			
		// unlock killstreak ===
		unlockedKillstreak = self getRankInfoUnlockKillstreak( rankId );
		if ( isDefined( unlockedKillstreak ) && unlockedKillstreak != "" )
			unlockKillstreak( unlockedKillstreak );
		
		// buy weapon ==========
		buyWeapon = self getRankInfoBuyWeapon( rankId );	// buyweapon is weapon reference string
		if ( isDefined( buyWeapon ) && buyWeapon != "" )
			buyWeapon( buyWeapon );
			
		// buy perk ============
		buyPerk = self getRankInfoBuyPerk( rankId );	// buyperk is perk reference string
		if ( isDefined( buyPerk ) && buyPerk != "" )
			buyPerk( buyPerk );
			
		// buy killstreak ======
		buyKillstreak = self getRankInfoBuyKillstreak( rankId );
		if ( isDefined( buyKillstreak ) && buyKillstreak != "" )
			buyKillstreak( buyKillstreak );

		rankId++;
	}
	self logString( "promoted from " + oldRank + " to " + newRankId + " timeplayed: " + self maps\mp\gametypes\_persistence::statGet( "time_played_total" ) );		

	self setRank( newRankId );
	return true;
}

updateRankAnnounceHUD()
{
	self endon("disconnect");

	self notify("update_rank");
	self endon("update_rank");

	team = self.pers["team"];
	if ( !isdefined( team ) )
		return;	
	
	self notify("reset_outcome");
	newRankName = self getRankInfoFull( self.pers["rank"] );
	
	notifyData = spawnStruct();

	notifyData.titleText = &"RANK_PROMOTED";
	notifyData.iconName = self getRankInfoIcon( self.pers["rank"], self.pers["prestige"] );
	notifyData.sound = "mp_level_up";
	notifyData.duration = 4.0;	
	
	rank_char = level.rankTable[self.pers["rank"]][1];
	subRank = int(rank_char[rank_char.size-1]);
	
	if ( subRank == 2 )
	{
		notifyData.textLabel = newRankName;
		notifyData.notifyText = &"RANK_ROMANI";
		notifyData.textIsString = true;
	}
	else if ( subRank == 3 )
	{
		notifyData.textLabel = newRankName;
		notifyData.notifyText = &"RANK_ROMANII";
		notifyData.textIsString = true;
	}
	else if ( subRank == 4 )
	{
		notifyData.textLabel = newRankName;
		notifyData.notifyText = &"RANK_ROMANIII";
		notifyData.textIsString = true;
	}	
	else
	{
		notifyData.notifyText = newRankName;
	}

	thread maps\mp\gametypes\_hud_message::notifyMessage( notifyData );

	if ( subRank > 1 )
		return;
	
	for ( i = 0; i < level.players.size; i++ )
	{
		player = level.players[i];
		playerteam = player.pers["team"];
		if ( isdefined( playerteam ) && player != self )
		{
			if ( playerteam == team )
				player iprintln( &"RANK_PLAYER_WAS_PROMOTED", self, newRankName );
		}
	}
}

// End of game summary/unlock menu page setup
// 0 = no unlocks, 1 = only page one, 2 = only page two, 3 = both pages
unlockPage( in_page )
{
	if( in_page == 1 )
	{
		if( self.pers["unlocks"]["page"] == 0 )
		{
			self setClientDvar( "player_unlock_page", "1" );
			self.pers["unlocks"]["page"] = 1;
		}
		if( self.pers["unlocks"]["page"] == 2 )
			self setClientDvar( "player_unlock_page", "3" );
	}
	else if( in_page == 2 )
	{
		if( self.pers["unlocks"]["page"] == 0 )
		{
			self setClientDvar( "player_unlock_page", "2" );
			self.pers["unlocks"]["page"] = 2;
		}
		if( self.pers["unlocks"]["page"] == 1 )
			self setClientDvar( "player_unlock_page", "3" );	
	}		
}

// unlocks weapon
unlockWeapon( refString )
{
	assert( isDefined( refString ) && refString != "" );
	
	refTok = strTok( refString, ";" );
	
	for( i=0; i<refTok.size; i++ )
	{
		reference = refTok[i];
		
		stat = int( tableLookup( "mp/statstable.csv", 4, reference, 0 ) );
		assertEx( stat > 0, "statsTable refstring " + reference + " has invalid stat number: " + stat );
		
		if( self getStat( stat ) > 0 )
			return;
			
		self setStat( stat, 1 );	// 1 unlocks the weapon for buying
		/*self setClientDvar( "player_unlockWeapon" + self.pers["unlocks"]["weapon"], reference );
		self.pers["unlocks"]["weapon"]++;
		self setClientDvar( "player_unlockWeapons", self.pers["unlocks"]["weapon"] );*/
	}
	
//	self unlockPage( 1 );
}

// buys weapons
buyWeapon( refString )
{
	assert( isDefined( refString ) && refString != "" );
	
	refTok = strTok( refString, ";" );
	
	for( i=0; i<refTok.size; i++ )
	{
		reference = refTok[i];
		
		stat = int( tableLookup( "mp/statstable.csv", 4, reference, 0 ) );
		assertEx( stat > 0, "statsTable refstring " + reference + " has invalid stat number: " + stat );
		
		if( self getStat( stat ) > 2 )		// unlocked any attachments yet? return then
			return;
		
		self setStat( stat, 2 );	// 1 unlocks the weapon
		/*self setClientDvar( "player_unlockWeapon" + self.pers["unlocks"]["weapon"], reference );
		self.pers["unlocks"]["weapon"]++;
		self setClientDvar( "player_unlockWeapons", self.pers["unlocks"]["weapon"] );*/
	}
	
//	self unlockPage( 1 );
}

// unlocks perk
unlockPerk( refString )
{
	assert( isDefined( refString ) && refString != "" );
	
	refTok = strTok( refString, ";" );
	
	for( i=0; i<refTok.size; i++ )
	{
		reference = refTok[i];
		
		stat = int( tableLookup( "mp/statstable.csv", 4, reference, 0 ) );
		
		if( self getStat( stat ) > 0 )
			return;

		self setStat( stat, 1 );	// 1 unlocks the perk for buying
	}
	
//	self unlockPage( 2 );
}

// buys perks
buyPerk( refString )
{
	assert( isDefined( refString ) && refString != "" );
	
	refTok = strTok( refString, ";" );
	
	for( i=0; i<refTok.size; i++ )
	{
		reference = refTok[i];
		
		stat = int( tableLookup( "mp/statstable.csv", 4, reference, 0 ) );
		
		if( self getStat( stat ) > 2 )		// already upgraded? return then
			return;

		self setStat( stat, 2 );	// 1 unlocks the perk for buying
		/*self setClientDvar( "player_unlockPerk" + self.pers["unlocks"]["perk"], reference );
		self.pers["unlocks"]["perk"]++;
		self setClientDvar( "player_unlockPerks", self.pers["unlocks"]["perk"] );*/
	}
	
//	self unlockPage( 2 );
}

// unlocks killstreaks
unlockKillstreak( refString )
{
	assert( isDefined( refString ) && refString != "" );
	
	refTok = strTok( refString, ";" );
	
	for( i=0; i<refTok.size; i++ )
	{
		reference = refTok[i];
		
		stat = int( tableLookup( "mp/statstable.csv", 4, reference, 0 ) );
		assertEx( stat > 0, "statsTable refstring " + reference + " has invalid stat number: " + stat );
		
		if( self getStat( stat ) > 0 )
			return;
		
		self setStat( stat, 1 );	// 1 unlocks the killstreak for buying
		/*self setClientDvar( "player_unlockKillstreak" + self.pers["unlocks"]["killstreak"], reference );
		self.pers["unlocks"]["killstreak"]++;
		self setClientDvar( "player_unlockKillstreaks", self.pers["unlocks"]["killstreak"] );*/
	}
	
	//self unlockPage( 1 );
}

// buys killstreaks
buyKillstreak( refString )
{
	assert( isDefined( refString ) && refString != "" );
	
	refTok = strTok( refString, ";" );
	
	for( i=0; i<refTok.size; i++ )
	{
		reference = refTok[i];
		
		stat = int( tableLookup( "mp/statstable.csv", 4, reference, 0 ) );
		assertEx( stat > 0, "statsTable refstring " + reference + " has invalid stat number: " + stat );
		
		if( self getStat( stat ) > 0 )
			return;
		
		self setStat( stat, 1 );	// 1 unlocks the killstreak for buying
		/*self setClientDvar( "player_unlockKillstreak" + self.pers["unlocks"]["killstreak"], reference );
		self.pers["unlocks"]["killstreak"]++;
		self setClientDvar( "player_unlockKillstreaks", self.pers["unlocks"]["killstreak"] );*/
	}
	
	//self unlockPage( 1 );
}

unlockChallenge( refString )
{
	assert( isDefined( refString ) && refString != "" );

	// tokenize reference string, accepting multiple camo unlocks in one call
	Ref_Tok = strTok( refString, ";" );
	assertex( Ref_Tok.size > 0, "Camo unlock specified in datatable ["+refString+"] is incomplete or empty" );
	
	for( i=0; i<Ref_Tok.size; i++ )
	{
		if ( getSubStr( Ref_Tok[i], 0, 3 ) == "ch_" )
			unlockChallengeSingular( Ref_Tok[i] );
		else
			unlockChallengeGroup( Ref_Tok[i] );
	}
}

// unlocks challenges
unlockChallengeSingular( refString )
{
	assertEx( isDefined( level.challengeInfo[refString] ), "Challenge unlock "+refString+" does not exist." );
	tableName = "mp/challengetable_tier" + level.challengeInfo[refString]["tier"] + ".csv";
	
	if ( self getStat( level.challengeInfo[refString]["stateid"] ) )
		return;

	self setStat( level.challengeInfo[refString]["stateid"], 1 );
	
	// set tier as new
	self setStat( 269 + level.challengeInfo[refString]["tier"], 2 );// 2: new, 1: old
	
	//self setClientDvar( "player_unlockchallenge" + self.pers["unlocks"]["challenge"], level.challengeInfo[refString]["name"] );
	self.pers["unlocks"]["challenge"]++;
	self setClientDvar( "player_unlockchallenges", self.pers["unlocks"]["challenge"] );	
	
	self unlockPage( 2 );
}

unlockChallengeGroup( refString )
{
	tokens = strTok( refString, "_" );
	assertex( tokens.size > 0, "Challenge unlock specified in datatable ["+refString+"] is incomplete or empty" );
	
	assert( tokens[0] == "tier" );
	
	tierId = int( tokens[1] );
	assertEx( tierId > 0 && tierId <= level.numChallengeTiers, "invalid tier ID " + tierId );

	groupId = "";
	if ( tokens.size > 2 )
		groupId = tokens[2];

	challengeArray = getArrayKeys( level.challengeInfo );
	
	for ( index = 0; index < challengeArray.size; index++ )
	{
		challenge = level.challengeInfo[challengeArray[index]];
		
		if ( challenge["tier"] != tierId )
			continue;
			
		if ( challenge["group"] != groupId )
			continue;
			
		if ( self getStat( challenge["stateid"] ) )
			continue;
	
		self setStat( challenge["stateid"], 1 );
		
		// set tier as new
		self setStat( 269 + challenge["tier"], 2 );// 2: new, 1: old
		
	}
	
	//desc = tableLookup( "mp/challengeTable.csv", 0, tierId, 1 );

	//self setClientDvar( "player_unlockchallenge" + self.pers["unlocks"]["challenge"], desc );		
	self.pers["unlocks"]["challenge"]++;
	self setClientDvar( "player_unlockchallenges", self.pers["unlocks"]["challenge"] );		
	self unlockPage( 2 );
}


unlockFeature( refString )
{
	assert( isDefined( refString ) && refString != "" );

	stat = int( tableLookup( "mp/statstable.csv", 4, refString, 1 ) );
	
	if( self getStat( stat ) > 0 )
		return;

	if ( refString == "feature_cac" )
		self setStat( 200, 1 );

	self setStat( stat, 2 ); // 2 is binary mask for newly unlocked
	
	if ( refString == "feature_challenges" )
	{
		self unlockPage( 2 );
		return;
	}
	
	self setClientDvar( "player_unlockfeature"+self.pers["unlocks"]["feature"], tableLookup( "mp/statstable.csv", 4, refString, 3 ) );
	self.pers["unlocks"]["feature"]++;
	self setClientDvar( "player_unlockfeatures", self.pers["unlocks"]["feature"] );
	
	self unlockPage( 2 );
}


// update copy of a challenges to be progressed this game, only at the start of the game
// challenges unlocked during the game will not be progressed on during that game session
updateChallenges()
{
	self.challengeData = [];
	for ( i = 1; i <= level.numChallengeTiers; i++ )
	{
		tableName = "mp/challengetable_tier"+i+".csv";

		idx = 1;
		// unlocks all the challenges in this tier
		for( idx = 1; isdefined( tableLookup( tableName, 0, idx, 0 ) ) && tableLookup( tableName, 0, idx, 0 ) != ""; idx++ )
		{
			stat_num = tableLookup( tableName, 0, idx, 2 );
			if( isdefined( stat_num ) && stat_num != "" )
			{
				statVal = self getStat( int( stat_num ) );
				
				refString = tableLookup( tableName, 0, idx, 7 );
				if ( statVal )
					self.challengeData[refString] = statVal;
			}
		}
	}
}


buildChallegeInfo()
{
	level.challengeInfo = [];
	
	for ( i = 1; i <= level.numChallengeTiers; i++ )
	{
		tableName = "mp/challengetable_tier"+i+".csv";

		baseRef = "";
		// unlocks all the challenges in this tier
		for( idx = 1; isdefined( tableLookup( tableName, 0, idx, 0 ) ) && tableLookup( tableName, 0, idx, 0 ) != ""; idx++ )
		{
			stat_num = tableLookup( tableName, 0, idx, 2 );
			refString = tableLookup( tableName, 0, idx, 7 );

			level.challengeInfo[refString] = [];
			level.challengeInfo[refString]["tier"] = i;
			level.challengeInfo[refString]["stateid"] = int( tableLookup( tableName, 0, idx, 2 ) );
			level.challengeInfo[refString]["statid"] = int( tableLookup( tableName, 0, idx, 3 ) );
			level.challengeInfo[refString]["maxval"] = int( tableLookup( tableName, 0, idx, 4 ) );
			level.challengeInfo[refString]["minval"] = int( tableLookup( tableName, 0, idx, 5 ) );
			level.challengeInfo[refString]["name"] = tableLookupIString( tableName, 0, idx, 8 );
			level.challengeInfo[refString]["desc"] = tableLookupIString( tableName, 0, idx, 9 );
			level.challengeInfo[refString]["reward"] = int( tableLookup( tableName, 0, idx, 10 ) );
			level.challengeInfo[refString]["camo"] = tableLookup( tableName, 0, idx, 12 );
			level.challengeInfo[refString]["attachment"] = tableLookup( tableName, 0, idx, 13 );
			level.challengeInfo[refString]["group"] = tableLookup( tableName, 0, idx, 14 );

			precacheString( level.challengeInfo[refString]["name"] );

			if ( !int( level.challengeInfo[refString]["stateid"] ) )
			{
				level.challengeInfo[baseRef]["levels"]++;
				level.challengeInfo[refString]["stateid"] = level.challengeInfo[baseRef]["stateid"];
				level.challengeInfo[refString]["level"] = level.challengeInfo[baseRef]["levels"];
			}
			else
			{
				level.challengeInfo[refString]["levels"] = 1;
				level.challengeInfo[refString]["level"] = 1;
				baseRef = refString;
			}
		}
	}
}
	

endGameUpdate()
{
	player = self;			
}

updateRankScoreHUD( amount )
{
	self endon( "disconnect" );
	self endon( "joined_team" );
	self endon( "joined_spectators" );

	if ( amount == 0 )
		return;

	self notify( "update_score" );
	self endon( "update_score" );

	self.rankUpdateTotal += amount;

	wait ( 0.05 );

	if( isDefined( self.hud_rankscroreupdate ) )
	{			
		if ( self.rankUpdateTotal < 0 )
		{
			self.hud_rankscroreupdate.label = &"";
			self.hud_rankscroreupdate.color = (1,0,0);
		}
		else
		{
			self.hud_rankscroreupdate.label = &"MP_PLUS";
			self.hud_rankscroreupdate.color = (1,1,0.5);
		}

		self.hud_rankscroreupdate setValue(self.rankUpdateTotal);
		self.hud_rankscroreupdate.alpha = 0.85;
		self.hud_rankscroreupdate thread maps\mp\gametypes\_hud::fontPulse( self );

		wait 1;
		self.hud_rankscroreupdate fadeOverTime( 0.75 );
		self.hud_rankscroreupdate.alpha = 0;
		
		self.rankUpdateTotal = 0;
	}
}

removeRankHUD()
{
	if(isDefined(self.hud_rankscroreupdate))
		self.hud_rankscroreupdate.alpha = 0;
}

getRank()
{	
	rankXp = self.pers["rankxp"];
	rankId = self.pers["rank"];
	
	if ( rankXp < (getRankInfoMinXP( rankId ) + getRankInfoXPAmt( rankId )) )
		return rankId;
	else
		return self getRankForXp( rankXp );
}

getRankForXp( xpVal )
{
	rankId = 0;
	rankName = level.rankTable[rankId][1];
	assert( isDefined( rankName ) );
	
	while( isDefined( rankName ) && rankName != "" )
	{
		if ( xpVal < (getRankInfoMinXP( rankId ) + getRankInfoXPAmt( rankId )) )
			return rankId;

		rankId++;
		if ( isDefined( level.rankTable[rankId] ) )
			rankName = level.rankTable[rankId][1];
		else
			rankName = undefined;
	}
	
	rankId--;
	return rankId;
}

getSPM()
{
	rankLevel = (self getRank() % 61) + 1;
	return 3 + (rankLevel * 0.5);
}

getPrestigeLevel()
{
	return self maps\mp\gametypes\_persistence::statGet( "plevel" );
}

getRankXP()
{
	return self.pers["rankxp"];
}

incRankXP( amount )
{
	xp = self getRankXP();
	newXp = (xp + amount);

	if ( self.pers["rank"] == level.maxRank && newXp >= getRankInfoMaxXP( level.maxRank ) )
		newXp = getRankInfoMaxXP( level.maxRank );

	self.pers["rankxp"] = newXp;
	self maps\mp\gametypes\_persistence::statSet( "rankxp", newXp );
}
