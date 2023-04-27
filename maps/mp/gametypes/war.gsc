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
Zombie Survival-Gamemode
=======================================================================================*/
#include scripts\_utility;

/*
	Survival
	Objective: 	Survive...
	Map ends:	When all survivors are down
	Respawning:	Between zombie waves
*/

main()
{
	maps\mp\gametypes\_globallogic::init();
	maps\mp\gametypes\_callbacksetup::SetupCallbacks();
	maps\mp\gametypes\_globallogic::SetupCallbacks();

	level.teamBased = true;
	level.onStartGameType = ::onStartGameType;
	
	thread [[level.waitForEndGame]]();		// ends the game when there are no more survivors
}

onStartGameType()
{
	setClientNameMode("auto_change");
	
	allowed[0] = "survival";
	allowed[1] = "sab";
	allowed[2] = "bombzone";
	allowed[3] = "hq";
	maps\mp\gametypes\_gameobjects::main(allowed);
}
