/*=======================================================================================
Return of the Zombie Ops - Mod
Modded by Lefti & 3aGl3
=========================================================================================
Bulletpenetration Perk script
=======================================================================================*/
#include scripts\_utility;

init()
{
	
}

main( perk )
{
	if( perk == "specialty_bulletpenetration" )
		self setPerk( "specialty_bulletpenetration" ); 
	else if( perk == "specialty_bulletpenetration_two" )
	{
		self setPerk( "specialty_bulletpenetration" );
		self setPerk( "specialty_bulletpenetration" );
	}
	else if( perk == "specialty_bulletpenetration_pro" )
	{
		self setPerk( "specialty_bulletpenetration" ); 
		self setPerk( "specialty_bulletpenetration" ); 
		self setPerk( "specialty_bulletpenetration" ); 
	}	
}