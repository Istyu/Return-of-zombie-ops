/*=======================================================================================
Return of the Zombie Ops - Mod
Modded by Lefti & 3aGl3
=========================================================================================
Ninja Perk script
=======================================================================================*/
#include scripts\_utility;

main( perk )
{
	if( self hasPerkX("specialty_quieter") )
	{
		self setPerk( "specialty_quieter" );
	}
	else
	{
		self setPerk( "specialty_quieter" );
		self setPerk( "specialty_quieter" );
	}
}