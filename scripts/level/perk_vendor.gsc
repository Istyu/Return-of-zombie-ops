/*=======================================================================================
                        __________      __________      
                        \______   \ ____\____    /____  
                         |       _//  _ \ /     //  _ \ 
                         |    |   (  <_> )     /(  <_> )
                         |____|_  /\____/_______ \____/ 
                                \/              \/      

=========================================================================================
Return of the Zombie Ops - Mod
Modded by Lefti & 3aGl3
=========================================================================================
BO Perk Vendor
=======================================================================================*/
#include scripts\_utility;
#include maps\mp\gametypes\_hud_util;

init()
{
	precacheString( &"MPUI_PRESS_USE_TO_BUY_PERK_N" );
	precacheString( &"MPUI_PRESS_USE_TO_BUY_PERK_N_CN" );
	precacheString( &"ZMB_YOU_BOUGHT_PERK1_N" );
	precacheString( &"ZMB_YOU_BOUGHT_PERK2_N" );
	precacheString( &"ZMB_YOU_BOUGHT_PERK3_N" );
	
	level.perkCost["specialty_tier1"] = xDvarInt( "scr_perk_cost_tier1", 1000 );
	level.perkCost["specialty_tier2"] = xDvarInt( "scr_perk_cost_tier2", 1000 );
	level.perkCost["specialty_tier3"] = xDvarInt( "scr_perk_cost_tier3", 1000 );
	
	level.vendor["specialty_tier1"] = [];
	level.vendor["specialty_tier2"] = [];
	level.vendor["specialty_tier3"] = [];
	
	scripts\level\_vendor_perks::addPerks();
}

addVendor( origin, trigger )
{
	vendor = spawnstruct();
	
	if( isDefined(trigger.script_noteworthy) )
		vendor.perk = trigger.script_noteworthy;
	else
		vendor.perk = getRandomPerk( getRandomTier() );
		
	vendor.tier = tableLookup( "mp/statsTable.csv", 4, vendor.perk, 2 );
	
	if( isDefined(trigger.script_threshold) )
		vendor.price = trigger.script_threshold;
	else
		vendor.price = level.perkCost[vendor.tier];
	
	thread setHint( trigger, vendor.perk, vendor.price );
	vendor thread perkVendorThink( trigger );	
}

perkVendorThink( trigger )	// self = vendor
{
	perkName = tableLookupIString( "mp/statsTable.csv", 4, self.perk, 3 );
	
	for(;;)
	{
		trigger waittill( "trigger", user );
		
		if( !isPlayer(user) )
			continue;
			
		if( user.pers["team"] != "allies" )
			continue;
		
		if( user usebuttonpressed() )
		{
			if( user hasPerkV(self.perk) )
				continue;
				
			if( user.points >= self.price )	
			{
				toks = strTok( self.tier, "_" );
				p = getSubStr( toks[1], 4 );
					
				user.loadout["perk"+p] = self.perk;
				//user maps\mp\gametypes\_class::refreshPerks();								// ToDo: create this threat and get all perks to work
				user scripts\player\_points::takePoints( self.price );
				
				if( p == "1" )
					user iprintln( &"ZMB_YOU_BOUGHT_PERK1_N", perkName );
				else if( p == "2" )
					user iprintln( &"ZMB_YOU_BOUGHT_PERK2_N", perkName );
				else
					user iprintln( &"ZMB_YOU_BOUGHT_PERK3_N", perkName );
				
				if( getDvarBool("scr_showperksonspawn") )
				{
					perks = getPerks( user );
					user showPerk( 0, perks[0], -50 );
					user showPerk( 1, perks[1], -50 );
					user showPerk( 2, perks[2], -50 );
					user thread hidePerksAfterTime( 3.0 );
					user thread hidePerksOnDeath();
				}
			}
			else
			{
				user iPrintLn( &"ZMB_NOT_ENOUGH_POINTS_N", self.price );
			}
			
			wait 0.5;		// release time for trigger_radius
		}
	}
}


setHint( trigger, perk, price )
{
	perk = tableLookupIString( "mp/statsTable.csv", 4, perk, 3 );
	
	if( trigger.classname == "trigger_radius" )
		trigger thread fakeHintString( &"MPUI_PRESS_USE_TO_BUY_PERK_N", perk );
	else
		trigger setHintString( &"MPUI_PRESS_USE_TO_BUY_PERK_N_CN", perk, price );
}

getRandomTier()
{
	int = randomInt( 2 );
	
	if( int == 1 )
		t = "specialty_tier1";
	else if( int == 2 )
		t = "specialty_tier2";
	else
		t = "specialty_tier3";
	
	return t;
}

getRandomPerk( tier )
{
	p = level.vendor[tier][randomInt(level.vendor[tier].size)];
	
	return p;
}