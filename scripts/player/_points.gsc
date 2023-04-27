/*=======================================================================================
Return of the Zombie Ops - Mod
Modded by Lefti & 3aGl3
=========================================================================================
Zombie Pointsystem
=======================================================================================*/
#include scripts\_utility;
#include maps\mp\gametypes\_hud_util;

init()
{
	precacheString( &"ZMB_MINUS" );
	precacheString( &"ZMB_PLUS_MONEY" );
	precacheString( &"ZMB_MINUS_MONEY" );
	
	level.points["repair"]	= xDvarInt( "scr_points_repair", 25, 0 );
	level.points["start"]	= xDvarInt( "scr_points_start", 0, 0, 10000 );
	level.points["multi"]	= xDvarInt( "scr_points_multi", 1, 1 );
	level.points["type"]	= xDvarInt( "scr_points_calculation", 1, 1, 3 );		// 1 = damage left health, 2 = damage, 3 = 10 per shoot

	thread onPlayerConnect();
}

onPlayerConnect()
{
	for(;;)
	{
		level waittill( "connected", player );
		
		player.points = level.points["start"];
		player.money = 0;
		player.money = player maps\mp\gametypes\_persistence::statGet( "money" );
		
		player setClientDvars(	"ui_money", "$ "+player.money,
								"ui_points", player.points );

	//	wait 2;
	//	for(;;)
	//	{
	//		wait 0.05;
	//		player givePoints(10);
	//		player giveMoney(500);
	//	}

	//	wait 2;
	//	for(r = 0; r <= 170; r++)
	//	{
	//		wait 1.5;
	//		player setRank( r, 0 );
	//	}

	//	player thread onPlayerSpawn();
	}
}

onPlayerSpawn()
{
	self endon("disconnect");

	while(1)
	{
		self waittill("spawned");
		
		wait 2;
		self giveWeapon( "m4_acog_mp" );
		self giveMaxAmmo( "m4_acog_mp" );
		self switchToWeapon( "m4_acog_mp" );
		//self setClientDvars( 
		//					"cg_thirdPerson", "1",
		//					"cg_thirdPersonAngle", "360",
		//					"cg_thirdPersonRange", "120"
		//				);
		//				self iPrintlnBold( "Third Person view" );

		/*for( i = 0; i <= 100; )
		{
			if( self.points <= 2000 )
			{
				self.points += 8000;
				IPrintLnBold("Add point");
				i++;
			}
			wait 1;
		}*/
	}
}

givePoints( pts )
{
	self maps\mp\gametypes\_globallogic::incPersStat( "score", pts );
	self.score = self maps\mp\gametypes\_globallogic::getPersStat( "score" );
	
	pts = (pts*level.points["multi"]);			// the multipler is now used
	
	self.points += pts;

	self thread flowPoints( pts, true );
	self setClientDvar( "ui_points", self.points );
}


takePoints( pts )
{
	self.points -= pts;

	self thread flowPoints( pts, false );
	self setClientDvar( "ui_points", self.points );
}


flowPoints( pts, positive )
{
	xpos = randomIntRange( 10, 30 );
	ypos = randomIntRange( 10, 30 );
	
	points = newClientHudElem( self );
	points.horzAlign = "left";
	points.vertAlign = "bottom";
	points.alignX = "center";
	points.alignY = "top";
	points.x = 150;
	points.y = -30;
	points.hidewheninmenu = true;
	points.font = "default";
	points.fontscale = 1.4;
	points.color = (1, 1, 1);
	points.glowalpha = 1;
	points.foreground = true;
	
	if( positive )
	{
		points.glowcolor = (0, 1, 0);
		points.label = &"MP_PLUS";
		points setValue( pts );
	}
	else
	{
		points.glowcolor = (1, 0, 0);
		points.label = &"ZMB_MINUS";
		points setValue( pts );
	}
	
	points.alpha = 1;
	
	points moveOverTime( 0.25 );
	
	if( positive )	
		points.x = 150+xpos;
	else
		points.x = 150-xpos;
	
	points.y = -30-ypos;
	
	wait 0.25;
	points destroy();
}

giveMoney( val )
{
	self.money += val;
	self maps\mp\gametypes\_persistence::statAdd( "money", val );

	self setClientDvar( "ui_money", "$ "+self.money );
}

takeMoney( val )
{
	self.money -= val;
	self maps\mp\gametypes\_persistence::statSet( "money", self.money );		// quite unsafe I guess...
	
	self setClientDvar( "ui_money", "$ "+self.money );
}