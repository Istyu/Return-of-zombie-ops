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
Zombie Waypoints
=======================================================================================*/
#include scripts\_utility;

init()
{
	level.waypoints = [];
    level.waypointCount = 0;
    
    if( getDvarInt("developer") )
	{
		SetDvarIfUninitialized( "dev_draw_waypoints", 0 );
		SetDvarIfUninitialized( "dev_waypoints", 0 );
		thread drawWaypoints();
		thread startDevWaypoints();
	}
}

getFromCSV()
{
	fileName =  "waypoints/"+ tolower(getdvar("mapname")) + "_wp.csv";
	
	printLn( "Getting waypoints from csv: "+fileName );

	level.waypointCount = int( tableLookup(fileName, 0, 0, 1) );
	for (i=0; i<level.waypointCount; i++)
	{
		waypoint = spawnstruct();
		origin = TableLookup(fileName, 0, i+1, 1);
		orgToks = strtok( origin, " " );
		
		waypoint.origin = ( float(orgToks[0]), float(orgToks[1]), float(orgToks[2]));
		waypoint.isLinking = false;
		waypoint.ID = i;
		
		level.waypoints[i] = waypoint;
	}
	for (x=0; x<level.waypointCount; x++)
	{
		waypoint = level.waypoints[x]; 
		
		strLnk = TableLookup(fileName, 0, x+1, 2);
		tokens = strtok(strLnk, " ");
		
		waypoint.linkedCount = tokens.size;
		
		for (y=0; y<tokens.size; y++)
			waypoint.linked[y] = level.waypoints[ int(tokens[y]) ];
	}
	
	printLn( "Waypoint Count: "+level.waypointCount );
}

drawWaypoints()
{
	printLn( "^3Waiting to draw Waypoints!" );
	for(;;)
	{
		if( getDvarInt("dev_draw_waypoints") == 1 )
			break;
			
		wait 1;
	}
	
	setDvar( "logfile", 1 );
	for(i=0; i<level.waypointCount; i++)
	{
		level.waypoints[i].visible = spawn( "script_model", level.waypoints[i].origin );
		level.waypoints[i].visible setModel( "mw2_sentry_turret" );
		printLn( "Waypoint at: "+level.waypoints[i].origin );
	}
	setDvar( "logfile", 0 );
}

startDevWaypoints()
{
	
}