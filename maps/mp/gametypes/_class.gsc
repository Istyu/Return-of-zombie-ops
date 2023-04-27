/*=======================================================================================
Return of the Zombie Ops - Mod
Modded by Lefti & 3aGl3
=========================================================================================
Zombie Class
=======================================================================================*/
#include scripts\_utility;
#include scripts\_weapon_key;

init()
{
	level.defaultCharacter = "assault";
	
	thread cac_init();
	thread precachePlayermodels();
	thread onPlayerConnect();
}

onPlayerConnect()
{
	for(;;)
	{
		level waittill( "connected", player );
		player thread onPlayerSpawned();
	}
}

onPlayerSpawned()
{
	self endon( "disconnect" );

	for(;;)
	{
		self waittill( "spawned_player" );
		
		self thread checkClassifiedWeapons();
	}
}

checkClassifiedWeapons()
{
	self endon( "disconnect" );

// Desert Eagle Tactical
	if( self getStat(1) >= 2		// USP bought
	&& self getStat(2) >= 2			// M1911 bought
	&& self getStat(3) >= 2			// Gold Desert Eagle bought
	&& self getStat(4) >= 2 )		// Desert Eagle Scope bought
		self maps\mp\gametypes\_rank::unlockWeapon( "deserteagletac" );

// Skorpion SD		
	if( self getStat(7) >= 2		// Glock 18 bought
	&& self getStat(8) >= 2			// M93R bought
	&& self getStat(9) >= 2	)		// MP5k bought
		self maps\mp\gametypes\_rank::unlockWeapon( "mp5ksd" );

// M4 CQBR
	if( self getStat(12) >= 2		// UMP bought
	&& self getStat(13) >= 2		// Skorpion bought
	&& self getStat(15) >= 2		// UZI bought
	&& self getStat(17) >= 2		// AK74u bought
	&& self getStat(18) >= 2		// Vector bought
	&& self getStat(19) >= 2 )		// P90 bought
		self maps\mp\gametypes\_rank::unlockWeapon( "m4cqbr" );
		
// SAIGA12
	if( self getStat(22) >= 2		// KS-23 bought
	&& self getStat(23) >= 2		// W1200 bought
	&& self getStat(24) >= 2		// M1014 bought
	&& self getStat(25) >= 2 )		// AA-12 bought
		self maps\mp\gametypes\_rank::unlockWeapon( "saiga12" );
	
// TAC-50
	if( self getStat(28) >= 2		// M21 bought
	&& self getStat(29) >= 2		// Dragunow bought
	&& self getStat(30) >= 2		// R700 bought
	&& self getStat(31) >= 2		// M82 bought
	&& self getStat(33) >= 2 )		// TRG-42 bought
		self maps\mp\gametypes\_rank::unlockWeapon( "tac50" );

// Stoner 63
	if( self getStat(35) >= 2		// M249 SAW bought
	&& self getStat(36) >= 2		// RPD bought
	&& self getStat(37) >= 2 )		// M60E4 bought
		self maps\mp\gametypes\_rank::unlockWeapon( "stoner" );

// Type-95
	if( self getStat(41) >= 2		// AUG bought
	&& self getStat(42) >= 2		// AK-47 bought
	&& self getStat(43) >= 2		// SCAR bought
	&& self getStat(44) >= 2		// M4 bought
	&& self getStat(45) >= 2		// Famas F1 bought
	&& self getStat(46) >= 2		// G3 bought
	&& self getStat(48) >= 2		// G36C bought
	&& self getStat(49) >= 2		// ACR bought
	&& self getStat(50) >= 2		// M14 bought
	&& self getStat(47) >= 2 )		// FAD bought
		self maps\mp\gametypes\_rank::unlockWeapon( "type95" );
}

giveLoadout()
{
	self takeAllWeapons();
	if( level.customLoadout )
		self getLevelLoadout();
	else
		self getLoadoutData();
	
	self setCharacter();
	
	self.actionslots = [];
	
	self _setActionSlot( 1, "nightvision" );
	self _setActionSlot( 3, "altMode" );
	
	self _giveWeapon( self.loadout["secondary"], self.loadout["camo"] );
	
	if( self.loadout["primary"] != "none" )
	{
		self _giveWeapon( self.loadout["primary"], self.loadout["camo"] );
		self _setSpawnWeapon( self.loadout["primary"] );
	}
	else
		self _setSpawnWeapon( self.loadout["secondary"] );
	
	if( self.loadout["grenade"] != "none" )
	{
		self _GiveWeapon( self.loadout["grenade"] );
		self _SetWeaponAmmoClip( self.loadout["grenade"], 4 );
		self _SwitchToOffhand( self.loadout["grenade"] );
	}
	
	if( self.loadout["sgrenade"] != "none" )
	{
		self _GiveWeapon( self.loadout["sgrenade"] );
		self _SetWeaponAmmoClip( self.loadout["sgrenade"], 4 );
		self setOffhandSecondaryClass("flash");
	}
	
	if( self.loadout["equipment"] != "none" )
	{
		self _giveWeapon( self.loadout["equipment"] );
		self _setActionSlot( 2, "weapon", self.loadout["equipment"] );
	}
	
	self scripts\player\_armor::addArmor( self.loadout["armor"] );
	self scripts\player\_medikit::giveMedikit( self.loadout["medikit"] );
	
	self.specialty = [];
	self scripts\player\perks\_perks::executePerksFormVar();
	
	if( isdefined(self.loadout["primary"]) )
	{
		switch( weaponClass( self.loadout["primary"] ) )
		{
			case "rifle":
				baseMovespeed = 0.95;
				break;
			case "pistol":
				baseMovespeed = 1.0;
				break;
			case "mg":
				baseMovespeed = 0.875;
				break;
			case "smg":
				baseMovespeed = 1.0;
				break;
			case "spread":
				baseMovespeed = 1.0;
				break;
			default:
				baseMovespeed = 1.0;
				break;
		}
	}
	else
		baseMovespeed = 1.0;
	
	if( self hasPerkX( "specialty_lightweight" ) )
		Movespeed = baseMovespeed*1.07;
	else
		Movespeed = baseMovespeed;
	
	self setMoveSpeedScale( Movespeed );
}

getLoadoutData()
{
	checksum = self getStat(200);
	
	if( checksum < 2 )
		self scripts\menus\_loadout::setDefaultStats();
	
	loadout = [];
	loadout["primary"] 		= self getStat(201);
	loadout["pattachment"]	= self getStat(202);
	loadout["secondary"] 	= self getStat(203);
	loadout["sattachment"]	= self getStat(204);
	loadout["camo"] 		= self getStat(214);
	loadout["grenade"] 		= self getStat(205);
	loadout["sgrenade"] 	= self getStat(206);
	loadout["equipment"]	= self getStat(207);
	loadout["armor"] 		= self getStat(198);
	loadout["medikit"] 		= self getStat(199);
	loadout["perk1"] 		= self getStat(208);
	loadout["perk2"] 		= self getStat(209);
	loadout["perk3"] 		= self getStat(210);
	loadout["killstreak1"]	= self getStat(211);
	loadout["killstreak2"]	= self getStat(212);
	loadout["killstreak3"]	= self getStat(213);
	
	self.loadout = [];
	
	if( loadout["primary"] != 0 && loadout["primary"] != 80 )
		self.loadout["primary"] = tableLookup( "mp/statsTable.csv", 0, loadout["primary"], 4 );
	else
		self.loadout["primary"] = "none";
	
	if( loadout["pattachment"] != 0 )
		self.loadout["primary"] = self.loadout["primary"]+"_"+tableLookup( "mp/attachmentTable.csv", 1, loadout["pattachment"], 6 );
	
	self.loadout["secondary"] = tableLookup( "mp/statsTable.csv", 0, loadout["secondary"], 4 );
	
	if( loadout["sattachment"] != 0 )
		self.loadout["secondary"] = self.loadout["secondary"]+"_"+tableLookup( "mp/attachmentTable.csv", 1, loadout["sattachment"], 6 );
	
	self.loadout["camo"] = loadout["camo"];
	
	if( loadout["grenade"] != 80 )
		self.loadout["grenade"] = tableLookup( "mp/statsTable.csv", 0, loadout["grenade"], 4 );
	else
		self.loadout["grenade"] = "none";
	
	if( loadout["sgrenade"] != 80 )
		self.loadout["sgrenade"] = tableLookup( "mp/statsTable.csv", 0, loadout["sgrenade"], 4 );
	else
		self.loadout["sgrenade"] = "none";
		
	if( loadout["equipment"] != 80 )
		self.loadout["equipment"] = tableLookup( "mp/statsTable.csv", 0, loadout["equipment"], 4 );
	else
		self.loadout["equipment"] = "none";

	if( loadout["armor"] != 80 )
		self.loadout["armor"] = level.armor_level[loadout["armor"]];
	else
		self.loadout["armor"] = level.armor_level[0];
	
	if( loadout["medikit"] != 80 )
		self.loadout["medikit"] = level.medikit_level[loadout["medikit"]];
	else
		self.loadout["medikit"] = level.medikit_level[0];
	
	self.loadout["perk1"] = tableLookup( "mp/statsTable.csv", 0, loadout["perk1"], 4 );
	self.loadout["perk2"] = tableLookup( "mp/statsTable.csv", 0, loadout["perk2"], 4 );
	self.loadout["perk3"] = tableLookup( "mp/statsTable.csv", 0, loadout["perk3"], 4 );
	
	self.loadout["character"] = level.defaultCharacter;
	
	if( self hasPerkV("specialty_lightweight") )
		self.loadout["character"] = "specialty_lightweight";
	else if( self hasPerkV("specialty_ghost") )
		self.loadout["character"] = "specialty_ghost";
	else if( self hasPerkV("specialty_armorvest") )
		self.loadout["character"] = "specialty_armorvest";
	else if( self hasPerkV("specialty_quieter") )
		self.loadout["character"] = "specialty_quieter";
		
	if( self scripts\player\_admin::clientIsAdmin() )
	{
		mID = self getPersonalAdminModel();
		if( mID != 0 )
			self.loadout["character"] = "admin"+mID;
	}
	
	if( self getGuid() == level.developerGUID["lefti"] )
		self.loadout["character"] = "lefti";
	else if( self getGuid() == level.developerGUID["eagle"] )
		self.loadout["character"] = "eagle";
}

getPersonalAdminModel()
{
	adminID = self scripts\player\_admin::clientAdmin();
	
	if( isDefined(level.adminModel[adminID]) && level.adminModel[adminID] < 5 )
		return level.adminModel[adminID];
	else if( isDefined(level.adminModel[adminID]) && level.adminModel[adminID] >= 5 && level.adminModel[adminID] < 10 )
	{
		if( isDefined( game["allies_model"] ) && isDefined( game["allies_model"]["ASSAULT"] ) )		// we assume that all models are successfully loaded
			return level.adminModel[adminID];
		else
			return 1;
	}
	else if( isDefined(level.adminModel[adminID]) && level.adminModel[adminID] >= 10 && level.adminModel[adminID] < 15 )
	{
		if( isDefined( game["axis_model"] ) && isDefined( game["axis_model"]["ASSAULT"] ) )		// we assume that all models are successfully loaded
			return level.adminModel[adminID];
		else
			return 3;
	}
	
	return 0;
}

getLevelLoadout()
{
	self.loadout = [];
	self.loadout["character"] = level.defaultCharacter;
	
	if( isDefined(self.level_loadout) )
	{
		self.loadout["primary"] 	= self.level_loadout["primary"];
		self.loadout["pattachment"]	= self.level_loadout["pattachment"];
		self.loadout["secondary"] 	= self.level_loadout["secondary"];
		self.loadout["sattachment"]	= self.level_loadout["sattachment"];
		self.loadout["camo"] 		= self.level_loadout["camo"];
		self.loadout["grenade"] 	= self.level_loadout["grenade"];
		self.loadout["sgrenade"] 	= self.level_loadout["sgrenade"];
		self.loadout["armor"] 		= self.level_loadout["armor"];
		self.loadout["medikit"] 	= self.level_loadout["medikit"];
		self.loadout["perk1"] 		= self.level_loadout["perk1"];
		self.loadout["perk2"] 		= self.level_loadout["perk2"];
		self.loadout["perk3"] 		= self.level_loadout["perk3"];
		self.loadout["equipment"]	= self.level_loadout["equipment"];
	}
	else
	{
		self.loadout["primary"] 	= level.loadout["primary"];
		self.loadout["pattachment"]	= level.loadout["pattachment"];
		self.loadout["secondary"] 	= level.loadout["secondary"];
		self.loadout["sattachment"]	= level.loadout["sattachment"];
		self.loadout["camo"] 		= level.loadout["camo"];
		self.loadout["grenade"] 	= level.loadout["grenade"];
		self.loadout["sgrenade"] 	= level.loadout["sgrenade"];
		self.loadout["armor"] 		= level.loadout["armor"];
		self.loadout["medikit"] 	= level.loadout["medikit"];
		self.loadout["perk1"] 		= level.loadout["perk1"];
		self.loadout["perk2"] 		= level.loadout["perk2"];
		self.loadout["perk3"] 		= level.loadout["perk3"];
		self.loadout["equipment"]	= level.loadout["equipment"];
	}
}

cac_init()
{
	level.perkIcons = [];
	level.perkNames = [];
	
	for( i=80; i<171; i++ )
	{
		perkName = tableLookup( "mp/statsTable.csv", 0, i, 4 );
		
		if( !isDefined(perkName) || perkName == "" )
			continue;
		
		level.perkIcons[perkName] = tableLookup( "mp/statsTable.csv", 0, i, 6 );
		level.perkNames[perkName] = tableLookupIString( "mp/statsTable.csv", 0, i, 3 );
		
		precacheShader( level.perkIcons[perkName] );
	}
}


setCharacter()
{
	self detachAll();
	
	if( !isDefined(self.loadout["character"]) )
		self.loadout["character"] = level.defaultCharacter;
	
	switch( self.loadout["character"] )
	{
		case "specialty_armorvest":
			self setModel("playermodel_mw2_USMC_lmg_a");
			self setViewmodel("viewhands_mw2_ranger");
			self.voice = "american";
			break;
		case "specialty_ghost":
			self setModel("playermodel_mw2_USMC_sniper");
			self setViewmodel("viewhands_mw2_usmc_sniper");
			self.voice = "american";
			break;
		case "specialty_lightweight":
			self setModel("playermodel_mw2_USMC_shotgun_a");
			self setViewmodel("viewhands_mw2_ranger");
			self.voice = "american";
			break;
		case "specialty_quieter":
			self setModel("playermodel_mw2_USMC_smg_a");
			self setViewmodel("viewhands_mw2_ranger");
			self.voice = "american";
			break;
		case "juggernaut":
			self setModel("playermodel_mw3_exp_juggernaunt");
			self setViewmodel("viewhands_mw3_ally_jugg");
			self.voice = "american";
			break;
		case "lefti":
		case "admin2":
		case "admin4":
			self setModel("playermodel_aot_alice");
			self setViewmodel("viewhands_sas_woodland");
			self.voice = "american";
			break;
		case "admin3":
		case "eagle":
			self setModel( "plr_fonv_riotgear_c" );
			self setViewmodel("viewhands_mw3_ally_jugg");
			self.voice = "american";
			break;
		case "admin1":
			self setModel("body_complete_mp_price_woodland");
			self setViewmodel("viewhands_sas_woodland");
			self.voice = "british";
			break;
		case "admin5":
			self [[game["allies_model"]["ASSAULT"]]]();
			break;
		case "admin6":
			self [[game["allies_model"]["SPECOPS"]]]();
			break;
		case "admin7":
			self [[game["allies_model"]["RECON"]]]();
			break;
		case "admin8":
			self [[game["allies_model"]["SUPPORT"]]]();
			break;
		case "admin9":
			self [[game["allies_model"]["SNIPER"]]]();
			break;
		case "admin10":
			self [[game["axis_model"]["ASSAULT"]]]();
			break;
		case "admin11":
			self [[game["axis_model"]["SPECOPS"]]]();
			break;
		case "admin12":
			self [[game["axis_model"]["RECON"]]]();
			break;
		case "admin13":
			self [[game["axis_model"]["SUPPORT"]]]();
			break;
		case "admin14":
			self [[game["axis_model"]["SNIPER"]]]();
			break;
		default:
			self setModel("playermodel_mw2_USMC_assault_a");
			self setViewmodel("viewhands_mw2_ranger");
			self.voice = "american";
			break;
	}
}

precachePlayermodels()
{
	precacheModel("playermodel_mw2_USMC_assault_a");
	precacheModel("playermodel_mw2_USMC_shotgun_a");
	precacheModel("playermodel_mw2_USMC_sniper");
	precacheModel("playermodel_mw2_USMC_smg_a");
	precacheModel("playermodel_mw2_USMC_lmg_a");
	precacheModel("playermodel_mw3_exp_juggernaunt");
	precacheModel("plr_fonv_riotgear_c");
	precacheModel("playermodel_aot_alice");
	precacheModel("body_complete_mp_price_woodland");
	
	precacheModel("viewhands_mw3_ally_jugg");
	precacheModel("viewhands_mw2_usmc_sniper");
	precacheModel("viewhands_mw2_ranger");
	precacheModel("viewhands_sas_woodland");
}
