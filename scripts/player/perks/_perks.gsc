/*=======================================================================================
return of the zombie ops - mod
developed by Lefti & 3aGl3
=========================================================================================
Perks general script
=======================================================================================*/
#include scripts\_utility;

init()
{
	precacheString( &"ZMB_ABILITY_ON_COOLDOWN" );
	precacheString( &"ZMB_ABILITY_N_READY" );
	
	// Tier 1
	thread scripts\player\perks\tier1\_ghost::init();
	thread scripts\player\perks\tier1\_scavenger::init();
	
	// Tier 2
	thread scripts\player\perks\tier2\_holdbreath::init();
	thread scripts\player\perks\tier2\_warlord::init();
	
	// Tier 3
	thread scripts\player\perks\tier3\_gasmask::init();
	thread scripts\player\perks\tier3\_hacker::init();
	thread scripts\player\perks\tier3\_laststand::init();
}

executePerksFormVar()
{
	self endon( "disconnect" );
	self endon( "death" );

	if( !isDefined(self.loadout) || ( !isDefined(self.loadout["perk1"]) && !isDefined(self.loadout["perk2"]) && !isDefined(self.loadout["perk3"]) ) )
		return;
	
	self clearPerks();
	self setPerk( "specialty_pistoldeath" );			// give this no matter what, actual perk is executed later
	
	if( isDefined(self.loadout["perk1"]) )
		self updatePerk( 0, self.loadout["perk1"] );
	
	if( isDefined(self.loadout["perk2"]) )
		self updatePerk( 1, self.loadout["perk2"] );
	
	if( isDefined(self.loadout["perk3"]) )
		self updatePerk( 2, self.loadout["perk3"] );
}

updatePerk( perkId, perkRef )
{
	self endon( "disconnect" );
	self endon( "death" );
	
	if( !isDefined(self.specialty) )
		self.specialty = [];
	
	if( isDefined(self.specialty[perkId]) && self.specialty[perkId] == perkRef )		// we already got the perk
		return;
	
	self.specialty[perkId] = perkRef;
	self startPerk( self.specialty[perkId] );
}

startPerk( perkRef )
{
	perkTok = strTok( perkRef, "_" );
	perkName = perkTok[1];
	
	switch( perkName )
	{
		// Tier 1
		case "ghost":
			self thread scripts\player\perks\tier1\_ghost::main( perkRef );
			break;
		case "hardline":
			self thread scripts\player\perks\tier1\_hardline::main( perkRef );
			break;
		// Tier 2
		case "bulletpenetration":
			self thread scripts\player\perks\tier2\_bulletpenetration::main( perkRef );
			break;
		case "holdbreath":
			self thread scripts\player\perks\tier2\_holdbreath::main( perkRef );
			break;
		case "bulletaccuracy":
			self thread scripts\player\perks\tier2\_bulletaccuracy::main( perkRef );
			break;
		case "fastreload":
			self thread scripts\player\perks\tier2\_fastreload::main( perkRef );
			break;
		case "warlord":
			self thread scripts\player\perks\tier2\_warlord::main( perkRef );
			break;
		case "rof":
			self thread scripts\player\perks\tier2\_rof::main( perkRef );
			break;
		// tier 3
		case "longersprint":
			self thread scripts\player\perks\tier3\_longersprint::main( perkRef );
			break;
		case "quieter":
			self thread scripts\player\perks\tier3\_quieter::main( perkRef );
			break;
		case "hacker":
			self thread scripts\player\perks\tier3\_hacker::main( perkRef );
			break;
		case "gasmask":
			self thread scripts\player\perks\tier3\_gasmask::main( perkRef );
			break;
		default:
			break;
	}
}
