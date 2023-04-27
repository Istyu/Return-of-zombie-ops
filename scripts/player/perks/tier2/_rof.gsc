/*=======================================================================================
Return of the Zombie Ops - Mod
Modded by Lefti & 3aGl3
=========================================================================================
Double Tap Perk script
=======================================================================================*/
#include scripts\_utility;

init()
{
	
}

main( perk )
{
	if( perk == "specialty_rof_pro" )
	{
		self setPerk( "specialty_rof" );
		self setPerk( "specialty_rof" );
		self setPerk( "specialty_rof" );
	}
	else if( perk == "specialty_rof_two" )
	{
		self setPerk( "specialty_rof" );
		self setPerk( "specialty_rof" );
	}
	else
		self setPerk( "specialty_rof" );
}