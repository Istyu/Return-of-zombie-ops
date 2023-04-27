/*=======================================================================================
Return of the Zombie Ops - Mod
Modded by Lefti & 3aGl3
=========================================================================================
Hardline Perk script
=======================================================================================*/
#include scripts\_utility;

main( perk )
{
	if( perk == "specialty_hardline" )
		self.hardlineKills = 10;
	else if( perk == "specialty_hardline_two" )
		self.hardlineKills = 20;
	else if( perk == "specialty_hardline_pro" )
		self.hardlineKills = 30;
}