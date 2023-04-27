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
blocker scripts
=======================================================================================*/
#include scripts\_utility;

init()
{
	game["strings"]["blocker_open_door"] = &"ZMB_PRESS_USE_TO_OPEN_DOOR";			// Hold [USE] to Open Door [Cost: &&1]
	game["strings"]["blocker_open_gate"] = &"ZMB_PRESS_USE_TO_OPEN_GATE";			// Hold [USE] to Open Gate [Cost: &&1]
	game["strings"]["blocker_open_misc"] = &"ZMB_PRESS_USE_TO_OPEN_MISC";			// Hold [USE] to Clear Debris [Cost: &&1]
}

blocker_think()
{
	if( self.type == "vanish" )
		self setHintString( game["strings"]["blocker_open_misc"], self.cost );
	else
		self setHintString( game["strings"]["blocker_open_"+self.type], self.cost );
	
	for(;;)
	{
		self waittill( "trigger", user );
		
		if( user.pers["team"] != "allies" )
			continue;
			
		if( user.points >= self.cost )
		{
			user scripts\player\_points::takePoints( self.cost );
			break;
		}
		else
			user iprintlnbold( &"ZMB_NOT_ENOUGH_POINTS_N", self.cost );
	}
	
	self setHintString( "" );
	switch( self.type )
	{
		case "door":
			self door_think();
			break;
		case "gate":
			self gate_think();
			break;
		default:
			self debris_think();
			break;
	}
	
	self thread activate_spawns();
}

door_think()
{
	angle = int(self.debris[0].script_threshold);
	
	for( i=0; i<self.debris.size; i++ )
		self.debris[i] rotateYaw( angle, 2 );
		
	wait 2;
}

gate_think()
{
	move = int(self.debris[0].script_threshold);
	
	for( i=0; i<self.debris.size; i++ )
		self.debris[i] moveZ( move, 2 );
		
	wait 2;
}

debris_think()
{
	for( i=0; i<self.debris.size; i++ )
	{
		self.debris[i] hide();
		self.debris[i] notsolid();
		if( isDefined(self.deathFx) )
			playFx( self.deathFx, self.debris[i].origin );
	}
	
	wait 1;
}

activate_spawns()
{
	for( i=0; i<self.zombiespawns.size; i++ )
		self.zombiespawns[i].enabled = true;
	
	for( i=0; i<self.playerspawns.size; i++ )
		self.playerspawns[i].enabled = true;
}