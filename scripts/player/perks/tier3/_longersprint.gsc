/*=======================================================================================
Return of the Zombie Ops - Mod
Modded by Lefti & 3aGl3
=========================================================================================
Extreme Conditioning Perk script
=======================================================================================*/
#include scripts\_utility;

init()
{
	
}

main( perk )
{
	if( perk == "specialty_longersprint" )
		self setPerk( "specialty_longersprint" );
	else if( perk == "specialty_longersprint_two" )
	{
		self setPerk( "specialty_longersprint" );
		self setPerk( "specialty_longersprint" );
	}
	else if( perk == "specialty_longersprint_pro" )
	{
		self setPerk( "specialty_longersprint" );
		self setPerk( "specialty_longersprint" );
	}
}