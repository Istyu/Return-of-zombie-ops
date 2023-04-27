/*=======================================================================================
Return of the Zombie Ops - Mod
Modded by Lefti & 3aGl3
=========================================================================================
Zombie Types
=======================================================================================*/
#include scripts\_utility;

loadZombies()
{
	level.zmbTypes = [];
	level.zmbModels = [];
	level.zombiePercentage = 0;

//================  name 			healthmultipler		animtype	percentage in waves							killfeedsring
	registerZombie( "zombie",			1,				"zmb",		100 );
	registerZombie( "explosive",		1,				"zmb",		xDvarInt( "scr_zmb_explosive", 10, 0, 100 ),	&"ZMB_TYPE_EXPLOSIVE" );
	registerZombie( "bulletproof",		1,				"zmb",		xDvarInt( "scr_zmb_bulletproof", 10, 0, 100 ),	&"ZMB_TYPE_BULLETPROOF" );
	registerZombie( "tabun",			0.9,			"zmb",		xDvarInt( "scr_zmb_tabun", 10, 0, 100 ),		&"ZMB_TYPE_TABUN" );
	registerZombie( "tank",				10,				"zmb",		xDvarInt( "scr_zmb_tank", 10, 0, 100 ),			&"ZMB_TYPE_TANK" );
	registerZombie( "runner",			0.8,			"zmb",		xDvarInt( "scr_zmb_runner", 10, 0, 100 ),		&"ZMB_TYPE_RUNNER" );
	registerZombie( "slime",			1,				"zmb",		xDvarInt( "scr_zmb_slime", 10, 0, 100 ),		&"ZMB_TYPE_SLIME" );
	
	registerZombie( "dog",				0.8,			"dog",		xDvarInt( "scr_zmb_dog", 10, 0, 100 ),			&"ZMB_TYPE_DOG" );
	
	registerZombie( "tank_explosive",	10,				"zmb",		xDvarInt( "scr_zmb_ex_tank", 10, 0, 100 ),		&"ZMB_TYPE_ETANK" );
	registerZombie( "tank_tabun", 		10,				"zmb",		xDvarInt( "scr_zmb_tx_tank", 10, 0, 100 ),		&"ZMB_TYPE_TTANK" );
	registerZombie( "tank_slime",		10,				"zmb",		xDvarInt( "scr_zmb_sl_tank", 10, 0, 100 ),		&"ZMB_TYPE_TTANK" );
	registerZombie( "runner_explosive",	0.8,			"zmb",		xDvarInt( "scr_zmb_ex_runner", 10, 0, 100 ),	&"ZMB_TYPE_ERUNNER" );
	registerZombie( "runner_bulletproof", 0.8,			"zmb",		xDvarInt( "scr_zmb_bp_runner", 10, 0, 100 ),	&"ZMB_TYPE_BRUNNER" );
	registerZombie( "dog_explosive",	0.8,			"dog",		xDvarInt( "scr_zmb_ex_dog", 10, 0, 100 ),		&"ZMB_TYPE_EDOG" );
	registerZombie( "dog_tabun",		0.8,			"dog",		xDvarInt( "scr_zmb_tx_dog", 10, 0, 100 ),		&"ZMB_TYPE_TDOG" );
	registerZombie( "dog_slime",		0.8,			"dog",		xDvarInt( "scr_zmb_sl_dog", 10, 0, 100 ),		&"ZMB_TYPE_TDOG" );
	
//	registerZombie( "boss",				100,			"zmb",		0,											"BOSS" );
	
//===============	model									zombies
	registerModel( mptype\mptype_zombie_russian_a::main,	"zombie explosive bulletproof tabun slime" );
	registerModel( mptype\mptype_zombie_al_asad::main,		"zombie runner_explosive tank_explosive tank_slime tank_tabun" );
	registerModel( mptype\mptype_zombie_vip_pres::main,		"zombie runner tabun slime bulletproof" );
	registerModel( mptype\mptype_zombie_zakhaev::main,		"explosive bulletproof tabun slime runner_bulletproof" );
	registerModel( mptype\mptype_zombie_farmer::main,		"tank tank_explosive tank_slime tank_tabun" );
	registerModel( mptype\mptype_zombie_sports::main,		"runner runner_explosive runner_bulletproof" );
	
	registerModel( mptype\mptype_german_sheperd_dog::main,	"dog dog_explosive dog_tabun dog_slime" );
	
	precacheModels();
	registerAnims();
}

registerAnims()
{
	// Zombie animation
	level.BotAnim["zmb"]["run"] = spawnstruct();
	level.BotAnim["zmb"]["run"].weapon = "bot_zombie_run_mp";
	level.BotAnim["zmb"]["run"].speed = level.zombieRunSpeed;
	level.BotAnim["zmb"]["walk"] = spawnstruct();
	level.BotAnim["zmb"]["walk"].weapon = "bot_zombie_walk_mp";
	level.BotAnim["zmb"]["walk"].speed = level.zombieWalkSpeed;
	level.BotAnim["zmb"]["idle"] = spawnstruct();
	level.BotAnim["zmb"]["idle"].weapon = "bot_zombie_stand_mp";
	level.BotAnim["zmb"]["idle"].speed = 0;
	level.BotAnim["zmb"]["attack"] = spawnstruct();
	level.BotAnim["zmb"]["attack"].weapon = "bot_zombie_melee_mp";
	level.BotAnim["zmb"]["attack"].speed = 0;
	
	// Dog animations
	level.BotAnim["dog"]["run"] = spawnstruct();
	level.BotAnim["dog"]["run"].weapon = "bot_dog_run_mp";
	level.BotAnim["dog"]["run"].speed = level.dogRunSpeed;
	level.BotAnim["dog"]["walk"] = spawnstruct();
	level.BotAnim["dog"]["walk"].weapon = "bot_dog_run_mp";
	level.BotAnim["dog"]["walk"].speed = level.dogRunSpeed;
	level.BotAnim["dog"]["idle"] = spawnstruct();
	level.BotAnim["dog"]["idle"].weapon = "bot_dog_idle_mp";
	level.BotAnim["dog"]["idle"].speed = 0;
	level.BotAnim["dog"]["attack"] = spawnstruct();
	level.BotAnim["dog"]["attack"].weapon = "defaultweapon_mp";
	level.BotAnim["dog"]["attack"].speed = 0;
}

precacheModels()
{
	mptype\mptype_zombie_russian_a::precache();
	mptype\mptype_zombie_zakhaev::precache();
	mptype\mptype_zombie_farmer::precache();
	mptype\mptype_zombie_sports::precache();
	mptype\mptype_zombie_vip_pres::precache();
	mptype\mptype_zombie_al_asad::precache();
	
	mptype\mptype_german_sheperd_dog::precache();
}


registerZombie( name, healthmultipler, animtype, percent, string )
{
	if( percent == 0 )
		return;
	
	zmb = spawnstruct();
	zmb.healthmultipler = healthmultipler;
	zmb.animtype = animtype;
	zmb.minVal = level.zombiePercentage;
	level.zombiePercentage += percent;
	zmb.maxVal = level.zombiePercentage;
	zmb.killfeed = string;
	zmb.models = [];
	
	level.zmbTypes[name] = zmb;
	if( isdefined(string) )
		precacheString( string );
}

registerModel( model, zomb )
{
	mID = level.zmbModels.size;
	
	level.zmbModels[mId] = model;
	
	zombies = strTok( zomb, " " );
	for( i=0; i<zombies.size; i++ )
	{
		if( isDefined(level.zmbTypes[zombies[i]]) )			// in case the zombie has 0%
			level.zmbTypes[zombies[i]].models[level.zmbTypes[zombies[i]].models.size] = mID;
	}
}