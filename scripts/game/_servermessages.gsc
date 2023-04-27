/*=======================================================================================
                        __________      __________      
                        \______   \ ____\____    /____  
                         |       _//  _ \ /     //  _ \ 
                         |    |   (  <_> )     /(  <_> )
                         |____|_  /\____/_______ \____/ 
                                \/              \/      

=========================================================================================
return of the zombie ops - mod
developed by Lefti & 3aGl3
=========================================================================================
Server messages script
=======================================================================================*/
#include scripts\_utility;

init()
{
	level.servermessages[0] = &"MENU_MOD_BY_VERSION";
	level.servermessages[1] = "Visit us at www.mod-team-germany.de";
	
	for( i=2; i<500; i++ )
	{
		if( getDvar("scr_smsg_"+(i-2)) != "" )
			level.servermessages[i] = getDvar( "scr_smsg_"+(i-2) );
		else
			break;
	}
	
	level.serverMessageIntervall = xDvarInt( "scr_smsg_interval", 60, 1, 360 );
	level.serverMessageNum = 0;
	
	thread serverMessages();
}

serverMessages()
{
	level endon( "game_ended" );
	
	for(;;)
	{
		wait level.serverMessageIntervall;
		
		thread printAllPlayers( level.servermessages[level.serverMessageNum] );
		
		level.serverMessageNum++;
		if( level.serverMessageNum >= level.servermessages.size )
			level.serverMessageNum = 0;
	}
}