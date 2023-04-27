/*=======================================================================================
Return of the Zombie Ops - Mod
Modded by Lefti & 3aGl3
=========================================================================================
Zombie Menus
=======================================================================================*/

init()
{
	if( getDvar("scr_allow_quickammorefill") == "" )
		setDvar( "scr_allow_quickammorefill", 1 );
	
	game["menu_team"] = "team_marinesopfor";
	game["menu_class"] = "menu_cac";
	game["menu_weaponshop"] = "weaponshop";
	game["menu_addonshop"] = "equipmentshop";
	game["menu_clientcmd"] = "clientcmd";
	game["menu_weaponupgrades"] = "weapon_upgrades";
	game["menu_quick_player"] = "player_settings";
	game["menu_admin"] = "admin_settings";
	game["menu_mapvote"] = "mapvote";
	
	precacheMenu("player_inform");
	precacheMenu("scoreboard");
	precacheMenu(game["menu_team"]);
	precacheMenu(game["menu_class"]);
	precacheMenu(game["menu_weaponshop"]);
	precacheMenu(game["menu_addonshop"]);
	precacheMenu(game["menu_clientcmd"]);
	precacheMenu(game["menu_weaponupgrades"]);
	precacheMenu(game["menu_quick_player"]);
	precacheMenu(game["menu_admin"]);
	precacheMenu(game["menu_mapvote"]);
	
	level thread onPlayerConnect();
	//thread scripts\menus\_itemshop::init();
	thread scripts\menus\_weapon_armory::init();
	//thread scripts\menus\_equipment_armory::init();
}

onPlayerConnect()
{
	for(;;)
	{
		level waittill( "connecting", player );
		
		player setClientDvar("ui_3dwaypointtext", "1");
		player.enable3DWaypoints = true;
		player setClientDvar("ui_deathicontext", "1");
		player.enableDeathIcons = true;
		
		player thread onMenuResponse();
	}
}

onMenuResponse()
{
	self endon("disconnect");
	
	for(;;)
	{
		self waittill( "menuresponse", menu, response );
		
		println( "^0"+self.name+" caused Menu Response: "+menu+";"+response+"^7" );
		
		if( response == "back" )
		{
			self closeMenu();
			self closeIngameMenu();
			
			continue;
		}
		
		if( response == "open_class" && !level.customLoadout )
		{
			self closeMenu();
			self closeInGameMenu();
			self scripts\menus\_loadout::onOpenLoadout();
			self openMenu(game["menu_class"]);
		}
		else if( response == "open_class" && level.customLoadout )
		{
			self [[level.spawn]]();
			continue;
		}
		
		if( response == "spectator" )
		{
			self closeMenu();
			self closeInGameMenu();
			[[level.spawnSpectator]]();
		}
		
		if( response == "QuickAmmoRefill" )
		{
			if( level.weaponShopHandling == 2 || getDvarInt("scr_allow_quickammorefill") != 1 )
				self iPrintLnBold( &"ZMB_FEATURE_NOT_AVAILABLE" );
			else
			{
				if( self.points >= 750 )
				{				
					self scripts\player\_points::takePoints( 750 );
					weapons = self getWeaponslistPrimaries();
					for( i=0; i<weapons.size; i++ )
						self giveMaxAmmo(weapons[i]);
				}
				else
					self iPrintLn( &"ZMB_NOT_ENOUGH_POINTS_N", 750 );
			}
		}
		
		self thread scripts\menus\_loadout::responseHandler( response );
		
		if( menu == game["menu_weaponshop"] )
		{
			self scripts\menus\_weapon_armory::responseHandler( response );
		}
		else if( menu == game["menu_addonshop"] )
		{
			self scripts\menus\_equipment_armory::responseHandler( response );
		}
		else if( menu == game["menu_weaponupgrades"] )
		{
			self scripts\player\_playermenu::menuResponseHandler( response );
		}
		else if(menu == game["menu_quickcommands"])
			maps\mp\gametypes\_quickmessages::quickcommands(response);
		else if(menu == game["menu_quickstatements"])
			maps\mp\gametypes\_quickmessages::quickstatements(response);
		else if(menu == game["menu_quickresponses"])
			maps\mp\gametypes\_quickmessages::quickresponses(response);
		else if( menu == game["menu_admin"] && self scripts\player\_admin::clientIsAdmin() )
			self scripts\player\_admin::responseHandler( response );
		else if( menu == game["menu_admin"] && self scripts\player\_admin::clientIsVIP() )
			self scripts\player\_admin::responseHandlerVIP( response );
		
		if( strTok( response, "#" )[0] == "radio" )
			self scripts\player\_musiccontroller::responseHandler( strTok( response, "#" )[1] );
	}
}