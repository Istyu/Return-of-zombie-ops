/*=======================================================================================
Return of the Zombie Ops - Mod
Modded by Lefti & 3aGl3
=========================================================================================
Playermenu scrpit
=======================================================================================*/
#include scripts\_utility;
#include scripts\_weapon_key;

init()
{
	precacheShader( "reticle_flechette" );	// used in 3rd person
	precacheString( &"ZMB_ATTACHMENT_NOT_AVAILABLE_FOR_WEAPON" );
	precacheString( &"ZMB_YOU_ALREADY_OWN_ONE" );
	
	level.attachmentCost["reflex"] = 750;//xDvarInt( "scr_shop_cost_reflex", 750, 0 );
	level.attachmentCost["grip"] = 1250;//xDvarInt( "scr_shop_cost_grip", 1250, 0 );
	level.attachmentCost["acog"] = 1250;
	level.attachmentCost["gl"] = 1500;
	level.attachmentCost["silencer"] = 1000;
	level.attachmentCost["explosive"] = 1500;
	
	thread onPlayerConnect();
}

onPlayerConnect()
{
	for(;;)
	{
		level waittill( "connected", player );
		
		player setClientDvars( 	"ui_weaponup_reflex", 0,
								"ui_weaponup_grip", 0,
								"ui_weaponup_acog", 0,
								"ui_weaponup_gl", 0,
								"ui_weaponup_silencer", 0,
								"ui_weaponup_explosive", 0,
								"ui_weaponup_remove", 1 );
		
		player thread onPlayerSpawned();
		player thread playerMenuThink();
	}
}

playerMenuThink()
{
	self endon( "disconnect" );
	
	for(;;)
	{
		self waittill( "menuresponse", menu, response );
		
		switch( response )
		{
			case "openAdminMenu":
				if( self scripts\player\_admin::clientIsAdmin() )
					self openMenu( game["menu_admin"] );
				else
					self iPrintLnBold( "You're not allowed to opens this" );
				break;
			case "openMemberMenu":
				if( self scripts\player\_admin::clientIsVIP() )
					self openMenu( game["menu_admin"] );
				else
					self iPrintLnBold( "You're not allowed to opens this" );
				break;
			case "toggleFlashlight":
				//self thread toggleFlashlight();
				break;
			case "toggleThirdperson":
				self thread thirdPerson();
				break;
			case "AFKMODE":
				//toggleAFK
				break;
		}
	}
}

onPlayerSpawned()
{
	self endon( "disconnect" );
	level endon( "game_ended" );
	
	for(;;)
	{
		self waittill( "spawned_player" );
		
		if( self.team != "allies" )
			return;
		
		self thread updateWeapoupDvars();
		
	}
}

updateWeapoupDvars()
{
	self endon( "disconnect" );
	self endon( "death" );
	
	for(;;)
	{
		self waittill( "weapon_change" );
		
		weapon = self _getCurrentWeapon();
		if( weapon == "" || weapon == "none" )
			continue;
		
		toks = strTok( weapon, "_" );
		
		weapon = toks[0];
		if( isDefined(toks[1]) )
			attachment = toks[1];
		else
			attachment = "none";
		
		//self iPrintLn( "Current weapon: "+weapon );
		//self iPrintLn( "Current attachment: "+attachment );
		
		attachments = tableLookup( "mp/statsTable.csv", 4, weapon, 8 );
		//attachments = strTok( attachments, " " );
		
	// Attachment mounted?!
		if( attachment != "none" )
			self setClientDvar( "ui_weaponup_remove", 1 );
		else
			self setClientDvar( "ui_weaponup_remove", 0 );
		
	// Reflex Sight available?!
		if( isSubStr( attachments, "reflex" ) && attachment != "reflex" )
			self setClientDvar( "ui_weaponup_reflex", 1 );
		else
			self setClientDvar( "ui_weaponup_reflex", 0 );
	
	// Silencer available?!
		if( isSubStr( attachments, "silencer" ) && attachment != "silencer" )
			self setClientDvar( "ui_weaponup_silencer", 1 );
		else
			self setClientDvar( "ui_weaponup_silencer", 0 );
		
	// ACOG available?!
		if( isSubStr( attachments, "acog" ) && attachment != "acog" )
			self setClientDvar( "ui_weaponup_acog", 1 );
		else
			self setClientDvar( "ui_weaponup_acog", 0 );
	
	// Grip available?!
		if( isSubStr( attachments, "grip" ) && attachment != "grip" )
			self setClientDvar( "ui_weaponup_grip", 1 );
		else
			self setClientDvar( "ui_weaponup_grip", 0 );
		
	// Explosive available?!
		if( isSubStr( attachments, "explosive" ) && attachment != "explosive" )
			self setClientDvar( "ui_weaponup_explosive", 1 );
		else
			self setClientDvar( "ui_weaponup_explosive", 0 );
	
	// GL available?!
		if( isSubStr( attachments, "gl" ) && attachment != "gl" )
			self setClientDvar( "ui_weaponup_gl", 1 );
		else
			self setClientDvar( "ui_weaponup_gl", 0 );
	}
}

menuResponseHandler( response )
{	
	weapon = self _getCurrentWeapon();
	if( weapon == "" || weapon == "none" )
			return;
	
	ammo = _getAmmoCount( weapon );
	
	toks = strTok( weapon, "_" );
	
	weapon = toks[0];
	if( isDefined(toks[1]) )
		attachment = toks[1];
	else
		attachment = "none";
	
	if( response == "remove" )
	{
		if( attachment != "none" )
		{
			self _giveWeapon( weapon );
			self _switchToWeapon( weapon );
			self setWeaponAmmoOverall( weapon, ammo );
			self _takeWeapon( weapon+"_"+attachment );
		}
		
		return;
	}
	
	attachments = tableLookup( "mp/statsTable.csv", 4, weapon, 8 );
	
	if( attachment == response )
		self iPrintLn( &"ZMB_YOU_ALREADY_OWN_ONE" );
	else if( isSubStr( attachments, response ) && self.points >= level.attachmentCost[response] )
	{
		self _giveWeapon( weapon+"_"+response );
		self _switchToWeapon( weapon+"_"+response );
		self setWeaponAmmoOverall( weapon+"_"+response, ammo );
		self scripts\player\_points::takePoints( level.attachmentCost[response] );
		
		if( attachment != "none" )
			self _takeWeapon( weapon+"_"+attachment );
		else
			self _takeWeapon( weapon );
	}
	else if( self.points < level.attachmentCost[response] )
		self iPrintLn( &"ZMB_NOT_ENOUGH_POINTS_N", level.attachmentCost[response] );
	else
		self iPrintLn( &"ZMB_ATTACHMENT_NOT_AVAILABLE_FOR_WEAPON" );

}