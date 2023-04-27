/*=======================================================================================
return of the zombie ops - Mod
Modded by Lefti & 3aGl3
=========================================================================================
Sleight of hand Perk script
=======================================================================================*/
#include scripts\_utility;

init()
{
	
}

main( perk )
{
	if( perk == "specialty_fastreload_pro" )
	{
		self setPerk( "specialty_fastreload" );
		self setPerk( "specialty_fastreload" );
		
		// add the rest here
	}
	else if( perk == "specialty_fastreload_two" )
	{
		self setPerk( "specialty_fastreload" );		// this should do the trick, since you pick up two times in oldschool you get even faster reload
		self setPerk( "specialty_fastreload" );
	}
	else
		self setPerk( "specialty_fastreload" );
}