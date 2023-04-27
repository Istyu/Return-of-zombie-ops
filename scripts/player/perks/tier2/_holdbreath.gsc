/*=======================================================================================
Return of the Zombie Ops - Mod
Modded by Lefti & 3aGl3
=========================================================================================
Holdbreath Perk script
=======================================================================================*/
#include scripts\_utility;

init()
{
	
}

main( perk )
{
	if( perk == "specialty_holdbreath" )
		self setPerk( "specialty_holdbreath" );
	else if( perk == "specialty_holdbreath_two" )
	{
		self setPerk( "specialty_holdbreath" );
		self setPerk( "specialty_holdbreath" );
	}
	else if( perk == "specialty_holdbreath_pro" )
	{
		self setPerk( "specialty_holdbreath" );
		self setPerk( "specialty_holdbreath" );
	}
}