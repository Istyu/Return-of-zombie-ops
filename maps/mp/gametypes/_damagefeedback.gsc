/*=======================================================================================
Return of the Zombie Ops - Mod
Modded by Lefti & 3aGl3
=========================================================================================
Zombie Damagefeedback
=======================================================================================*/
// ToDo: Rework this!
init()
{
	precacheShader("damage_feedback");
	precacheShader("damage_feedback_j");
//	precacheShader("damage_feedback_lightarmor");

	level thread onPlayerConnect();
}

onPlayerConnect()
{
	for(;;)
	{
		level waittill("connecting", player);

		player.hud_damagefeedback = newClientHudElem(player);
		player.hud_damagefeedback.horzAlign = "center";
		player.hud_damagefeedback.vertAlign = "middle";
		player.hud_damagefeedback.x = -12;
		player.hud_damagefeedback.y = -12;
		player.hud_damagefeedback.alpha = 0;
		player.hud_damagefeedback.archived = true;
		player.hud_damagefeedback setShader("damage_feedback", 24, 48);
	}
}

updateDamageFeedback( specialty, lightarmor )
{
	if ( !isPlayer( self ) )
		return;
	
	if( specialty )
	{
		self thread doDamageFeedback( "specialty" );
	}
	else if( lightarmor )
	{
		self thread doDamageFeedback( "lightarmor" );
	}
	else
	{
		self thread doDamageFeedback( "normal" );
	}
}

doDamageFeedback( type )
{
	if ( !isPlayer( self ) )
		return;
	
	switch( type )
	{
	case "specialty":
		self.hud_damagefeedback setShader( "damage_feedback_j", 24, 48 );
		self playlocalsound( "MP_hit_alert" );					// TODO: change sound?
		break;
	case "lightarmor":
		self.hud_damagefeedback setShader( "damage_feedback_j", 24, 48 );
		self playlocalsound( "MP_hit_alert" );					// TODO: change sound?
		break;
	case "normal":
		self.hud_damagefeedback setShader( "damage_feedback", 24, 48 );
		self playlocalsound( "MP_hit_alert" );
		break;
	}
	
	self.hud_damagefeedback.alpha = 1;
	self.hud_damagefeedback fadeOverTime( 1 );
	self.hud_damagefeedback.alpha = 0;
}