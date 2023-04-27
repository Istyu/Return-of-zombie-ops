/*=======================================================================================
Return of the Zombie Ops - Mod
Modded by Lefti & 3aGl3
=========================================================================================
Player Multikillssystem
=======================================================================================*/
#include scripts\_utility;

init()
{
	level.multikill = xDvarBool( "scr_allow_multikill", 1 );				// Multikill on = 1 / off = 0
	level.multikills = xDvarInt( "scr_multikills", 5, 2 );					// from how much there is a multikill [default: 5, min: 2]
	level.multikillpoints = xDvarInt ( "scr_multikillpoints", 50, 10 );	  	// How many points gives for a multikill

	if( level.multikill == false )		// returning from this point so we don't even call any threads
		return;
	
	precacheString( &"ZMB_N_GOT_MULTIKILL_N" );
	
	thread onPlayerConnect();
}


onPlayerConnect()
{
	for(;;)
	{
		level waittill( "connected", player );
	
		player thread multikillcounter();			
	}
}

multikillcounter()
{
	self endon( "disconnect" );
	
	while(1)
	{
		self.mkills = self.cur_kill_streak;			// not sure if cur_kill_streak is used...
		wait 1.1;
		self.multikills = self.cur_kill_streak - self.mkills;
		self thread multikillmessage();
	}
}

multikillMessage()
{
	self endon( "disconnect" );
	
	if( self.multikills >= level.multikills )
	{
		iPrintLn( "^1"+self.name+"^3 got a Multikill with ^2"+self.multikills+"^3 kills!" );	// maybe use iPrintLnBold?
		self scripts\player\_points::givePoints( level.multikillpoints );
		
		self iPrintLn( "^2You got "+level.multikillpoints+" Multikillpoints!" );						// print only to the player
	
		//self.multikillprintln = false;
		//self.printkills = 0;
	}
}