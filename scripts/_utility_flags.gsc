/*=======================================================================================
                        __________      __________      
                        \______   \ ____\____    /____  
                         |       _//  _ \ /     //  _ \ 
                         |    |   (  <_> )     /(  <_> )
                         |____|_  /\____/_______ \____/ 
                                \/              \/      

=========================================================================================
return of the zombie ops - mod
developed by mod-team-germany
=========================================================================================
Flags Utility
=======================================================================================*/

flag_init( message )
{
	if( !isDefined(level.flag) )
		level.flag = [];
		
	assertEx( !isDefined(level.flag[ message ]), "Trying to init flag that is already set!" );
	
	level.flag[ message ] = false;
}

flag( message )
{
	assertEx( isdefined( message ), "Tried to check flag but the flag was not defined." );
	assertEx( isdefined( level.flag[ message ] ), "Tried to check flag " + message + " but the flag was not initialized." );

	return level.flag[ message ];
}

flag_set( message )
{
	assertEx( isdefined( message ), "Tried to set flag but the flag was not defined." );
	assertEx( isdefined( level.flag[ message ] ), "Tried to set flag " + message + " but the flag was not initialized." );
	
	// if the flag is already set we don't need to do it again
	if( !level.flag[ message ] )
	{
		level.flag[ message ] = true;
		level notify( message );
	}
}

flag_clear( message )
{
	assertEx( isdefined( message ), "Tried to clear flag but the flag was not defined." );
	assertEx( isdefined( level.flag[ message ] ), "Tried to clear flag " + message + " but the flag was not initialized." );
	
	level.flag[ message ] = false;
}

flag_wait( message )
{
	while( !level.flag[ message ] )
		level waittill( message );
}