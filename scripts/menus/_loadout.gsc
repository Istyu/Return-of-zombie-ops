/*=======================================================================================
Return of the Zombie Ops - Mod
Modded by Lefti & 3aGl3
=========================================================================================
Zombie Loadout - Script
=======================================================================================*/
#include scripts\_utility;

responseHandler( response )
{
	rsptoks = strTok( response, "#" );
	
	if( isSubStr(response, "statset") )
		self setStat_think( response );
	else if( rsptoks[0] == "cacSaveAndSpawn" )
		self SaveLoadout();
	else if( rsptoks[0] == "buyitem" )
		self buyItem_think( rsptoks[1] );
	else if( response == "camoPrev" )
		self cycleCamo( "prev" );
	else if( response == "camoNext" )
		self cycleCamo( "next" );
	
	if( isDefined(rsptoks[1]) && rsptoks[1] == "RESET" )
		self setDefaultStats();
}

SaveLoadout()
{
	self [[level.spawn]]();
}

onOpenLoadout()
{
	checksum = self getStat(200);
	if( checksum < 3 )
		self setDefaultStats();
}

setDefaultStats()
{
	// 'perk_none'(stat 80), results in nothing

	self setStat( 198, 80 );		// no Armor
	self setStat( 199, 80 );		// no Medikit
	
	self setStat( 201, 80 );		// no primary weapon
	self setStat( 202, 0 );			// no attachment
	self setStat( 203, 0 );			// M9
	self setStat( 204, 0 );			// no attachment
	self setStat( 205, 80 );		// no lethal grenade
	self setStat( 206, 80 );		// no special grenade
	self setStat( 207, 80 );		// no equipment
	self setStat( 208, 80 );		// no Perk 1
	self setStat( 209, 80 );		// no Perk 2
	self setStat( 210, 80 );		// no Perk 3
	self setStat( 211, 80 );		// no Killstreak
	self setStat( 212, 80 );		// no Killstreak
	self setStat( 213, 80 );		// no Killstreak
	self setStat( 214, 0 );			// no camo
	
	self setStat( 0, 2 );			// unlock M9 by default
	self setStat( 11, 1 );			// unlock MP5 in Armory
	self setStat( 40, 1 );			// unlock M16 in Armory
	self setStat( 27, 1 );			// unlock M40A3 in Armory
	
	self setStat( 200, 3 );			// checksum
}

setStat_think( response )
{
	rsp = strTok( response, "#" );
	stat = int(rsp[1]);
	
	if( rsp[1] == "RESET" )
		self setDefaultStats();
	else
	{
		/*if( isSubStr( rsp[2], "medikit" ) || (isSubStr( rsp[2], "armor" ) && !isSubStr( rsp[2], "specialty" )) )
			value = int(tableLookup( "mp/menuInfo.csv", 1, rsp[2], 4 ));
		else*/
		value = int(tableLookup( "mp/statsTable.csv", 4, rsp[2], 0 ));
		
		self setStat( stat, value );
	}
}

buyItem_think( item )
{
	if( isSubStr( item, "armor" ) && item != "specialty_armorvest" )
	{
		self iPrintLn( "Currently unavailable!" );
	}
	else if( isSubStr( item, "medikit" ) )
	{
		self iPrintLn( "Currently unavailable!" );
	}
	else
	{
		money = self maps\mp\gametypes\_persistence::statGet( "money" );
		price = int(tableLookup( "mp/statsTable.csv", 4, item, 11 ));
		
		if( money >= price && (money-price) >= 0 )
		{
			self setStat( int(tableLookup("mp/statsTable.csv", 4, item, 0)), 2 );
			self scripts\player\_points::takeMoney( price );
			
			self iPrintLn( &"MPUI_BOUGHT_N", tableLookupIString("mp/statsTable.csv", 4, item, 3) );
			self setClientDvar( "ui_cac_important", "MPUI_ITEM_BOUGHT" );
			self thread resetImportantAfterTime( 5 );
		}
		else
		{
			self iPrintLn( &"MPUI_NOT_ENOUGH_MONEY_TO_BUY" );
			self setClientDvar( "ui_cac_important", "MPUI_NOT_ENOUGH_MONEY_TO_BUY" );
			self thread resetImportantAfterTime( 5 );
		}
	}
}

resetImportantAfterTime( time )
{
	self endon( "disconnect" );
	
	wait time;
	
	self setClientDvar( "ui_cac_important", "" );
}

cycleCamo( dir )
{
	value = self getStat( 214 );
	
	if( dir == "next" )
	{
		value++;
		if( value > 6 )
			value = 0;
			
		self setStat( 214, value );
	}
	else
	{
		value--;
		if( value < 0 )
			value = 6;
			
		self setStat( 214, value );
	}
}