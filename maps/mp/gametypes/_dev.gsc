/*=======================================================================================
Return of the Zombie Ops - Mod
Modded by Lefti & 3aGl3
=========================================================================================
Zombie Developement
=======================================================================================*/
#include scripts\_utility;

init()
{
//	thread onPlayerConnect();
	
	if( isDeveloper() < 1 )
		return;
	
	printLn( "^0Starting developer scripts.^7" );
	
	thread devGetStat();
	thread devSetStat();
	thread devUnlockAll();
	thread devGivePoints();
	thread devGiveArmor();
	thread setRank();
	//thread spamValue( "val here!" );
	
	printLn( "^2Developer scripts started.^7" );
}

setRank()
{
	SetDvarIfUninitialized( "dev_set_rank", "" );
	
	wait( 5 );
	
	for(;;)
	{
		if( getDvar("dev_set_rank") != "" )
			break;
			
		wait 1;
	}
	
	dvar = getDvar( "dev_set_rank" );
	setDvar( "dev_set_rank", "" );
	
	playername = strTok( dvar, " " )[0];
	rank = int(strTok( dvar, " " )[1]);
	
	player = getPlayerByName( playername );
	if( isDefined(player) )
	{
		newRank = rank;
		player.pers["rank"] = 0;
		player.pers["rankxp"] = 0;

		lastXp = 0;
		for( index = 0; index <= newRank; index++ )		
		{
			newXp = maps\mp\gametypes\_rank::getRankInfoMinXP( index );
			player thread maps\mp\gametypes\_rank::giveRankXP( "kill", newXp - lastXp );
			lastXp = newXp;
			wait ( 0.25 );
			self notify ( "cancel_notify" );
		}
	}
	
	thread setRank();
}

devSetStat()
{
	SetDvarIfUninitialized( "dev_set_stat", "" );
	
	wait( 5 );
	
	for(;;)
	{
		if( getDvar("dev_set_stat") != "" )
			break;
			
		wait 1;
	}
	
	if( getDvarBool("developer_script") )
	{
		iPrintLn( "^1Can't set stats!^7 'developer_script' need to be 0." );
		return;
	}
	
	string = getDvar( "dev_set_stat" );
	setDvar( "dev_set_stat", "" );
	
	toks = strTok( string, " " );
	
	if( toks.size != 3 )
		iprintLn( "^3Invalid input at dev_set_stat!^7" );
	
	if( toks.size > 2 )
	{
		name = toks[0];
		stat = int(toks[1]);
		val = int(toks[2]);
		
		player = getPlayerByName( name );
		if( isDefined(player) )
		{
			player setStat( stat, val );
			player iPrintLn( "^2Stat "+stat+" set to "+val+".^7" );
		}
	}	
	
	thread devSetStat();
}

devGetStat()
{
	SetDvarIfUninitialized( "dev_get_stat", "" );
	
	wait( 5 );
	
	for(;;)
	{
		if( getDvar("dev_get_stat") != "" )
			break;
			
		wait 1;
	}
	
	string = getDvar( "dev_get_stat" );
	setDvar( "dev_get_stat", "" );
	
	toks = strTok( string, " " );
	
	if( toks.size != 2 )
		iprintLn( "^3Invalid input at dev_get_stat!^7" );
	
	if( toks.size > 1 )
	{
		name = toks[0];
		stat = int(toks[1]);
		
		player = getPlayerByName( name );
		if( isDefined(player) )
		{
			val = player getStat( stat );
			player iPrintLn( "^3Stat "+stat+" is "+val+".^7" );
		}
	}
	
	thread devGetStat();
}


devGivePoints()
{
	SetDvarIfUninitialized( "dev_give_points", "" );
	
	wait( 5 );
	
	for(;;)
	{
		if( getDvar("dev_give_points") != "" )
			break;
			
		wait 1;
	}
	
	string = getDvar( "dev_give_points" );
	setDvar( "dev_give_points", "" );
	
	toks = strTok( string, " " );
	
	if( toks.size != 2 )
		iprintLn( "^3Invalid input at 'dev_give_points'!^7" );
	
	if( toks.size > 1 )
	{
		name = toks[0];
		points = int(toks[1]);
		
		player = getPlayerByName( name );
		if( isDefined(player) )
		{
			player scripts\player\_points::givePoints( points );
			player iPrintLn( "^3You got "+points+" points by script.^7" );
		}
	}
	
	thread devGivePoints();
}


devGiveArmor()
{
	level endon( "game_ended" );
	
	SetDvarIfUninitialized( "dev_give_armor", "" );
	
	wait 5;
	
	
	for(;;)
	{
		if( getDvar("dev_give_armor") != "" )
			break;
			
		wait 1;
	}
	
	string = getDvar( "dev_give_armor" );
	setDvar( "dev_give_armor", "" );
	
	toks = strTok( string, " " );
	
	if( toks.size != 2 )
		iprintLn( "^3Invalid input at 'dev_give_armor'!^7" );
	
	if( toks.size > 1 )
	{
		name = toks[0];
		armorId = int(toks[1]);
		
		if( armorId >= level.armor_level.size )			// prevent errors!
			armorId = level.armor_level.size-1;
		
		player = getPlayerByName( name );
		if( isDefined(player) )
		{
			player scripts\player\_armor::addArmor( level.armor_level[armorId] );
		}
	}
	
	thread devGiveArmor();
}


spamValue( value )
{
	if( !isDefined(value) )
		return;
	
	for(;;)
	{
		wait 5;
		iPrintLnBold( "Value is: "+value );
	}
}

devUnlockAll()
{
	SetDvarIfUninitialized( "dev_unlock_all", "" );
	
	wait( 5 );
	
	for(;;)
	{
		if( getDvar("dev_unlock_all") != "" )
			break;
			
		wait 1;
	}
	
	name = getDvar( "dev_unlock_all" );
	setDvar( "dev_unlock_all", "" );
	
	player = getPlayerByName( name );
	if( isDefined(player) )
	{
		for( i=0; i<=186; i++ )
		{
			player setStat( i, 2 );
			
			wait 1;
		}
			
		player iPrintLn( "^3Everything is now unlocked.^7" );
	}
	
	
	thread devUnlockAll();
}