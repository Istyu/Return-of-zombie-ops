//=======================================================================================
// UAV Killstreak Scrip
// modified for RoZo
//=======================================================================================
#include scripts\_utility;

init()
{
	setDvar( "ui_uav_allies", 0 );
	setDvar( "ui_uav_axis", 0 );
	makeDvarServerInfo( "ui_uav_allies", 0 );
	makeDvarServerInfo( "ui_uav_axis", 0 );
	//setDvar( "ui_uav_client", 0 );
	
	SetDvarIfUninitialized( "scr_streak_uav_force", 0 );			// Forces UAV to be online
	SetDvarMinMax( "scr_streak_uav_lastzom", 5, 0, 900 );			// how many zombies left to enable uav
	
	if( !level.teambased )
		return;
	
	if( getDvarBool( "scr_streak_uav_force" ) )
	{
		setTeamRadar( "allies", true );
		setDvar( "ui_uav_allies", 1 );
	}
	else
	{
		if( getDvarInt("scr_streak_uav_lastzom") <= 0 )
			return;
		
		thread waitForRadarZombies();
	}
}

waitForRadarZombies()
{
	level endon( "game_ended" );
	
	wait 5;
	
	while( 1 )
	{
		if( level.zombiesAlive <= getDvarInt( "scr_streak_uav_lastzom" ) )
		{
			if( getDvarInt("ui_uav_allies") != 1 )
			{
				setTeamRadar( "allies", true );
				setDvar( "ui_uav_allies", 1 );
			}
		}
		else
		{
			if( getDvarInt("ui_uav_allies") != 0 )
			{
				setTeamRadar( "allies", false );
				setDvar( "ui_uav_allies", 0 );
			}
		}
	
		wait 1;
	}
}