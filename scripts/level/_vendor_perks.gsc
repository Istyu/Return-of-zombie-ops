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
BO Perk Vendor - Perk definition
=======================================================================================*/

addPerks()
{
	// Tier 1
	addPerk( 1, "specialty_lightweight" );
	addPerk( 1, "specialty_scavenger" );
	
	// Tier 2
	addPerk( 2, "specialty_bulletpenetration" );
	addPerk( 2, "specialty_bulletaccuracy" );
	
	// Tier 3
	addPerk( 3, "specialty_longersprint" );
	addPerk( 3, "specialty_pistoldeath" );
}

addPerk( tier, perk )
{
	if( !isDefined(level.vendor["specialty_tier"+tier]) )
		return;
	
	level.vendor["specialty_tier"+tier][level.vendor["specialty_tier"+tier].size] = perk;
}

/*=======================================================================================
VALID PERKS

// TIER 1
specialty_lightweight
specialty_lightweight_two
specialty_lightweight_pro
specialty_scavenger
specialty_scavenger_two
specialty_scavenger_pro
specialty_ghost
specialty_ghost_two
specialty_ghost_pro
specialty_armorvest
specialty_armorvest_two
specialty_armorvest_pro
specialty_hardline
specialty_hardline_two
specialty_hardline_pro

// TIER 2
specialty_bulletpenetration
specialty_bulletpenetration_two
specialty_bulletpenetration_pro
specialty_holdbreath
specialty_holdbreath_two
specialty_holdbreath_pro
specialty_bulletaccuracy
specialty_bulletaccuracy_two
specialty_bulletaccuracy_pro
specialty_fastreload
specialty_fastreload_two
specialty_fastreload_pro
specialty_extraammo
specialty_extraammo_two
specialty_extraammo_pro
specialty_explosiveammo
specialty_explosiveammo_two
specialty_explosiveammo_pro

// TIER 3
specialty_longersprint
specialty_longersprint_two
specialty_longersprint_pro
specialty_quieter
specialty_quieter_two
specialty_quieter_pro
specialty_pistoldeath
specialty_pistoldeath_two
specialty_pistoldeath_pro
specialty_hacker
specialty_hacker_two
specialty_hacker_pro
specialty_gasmask
specialty_gasmask_two
specialty_gasmask_pro

=======================================================================================*/