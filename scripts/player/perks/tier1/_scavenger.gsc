/*=======================================================================================
Return of the Zombie Ops - Mod
Modded by Lefti & 3aGl3
=========================================================================================
Scavenger Perk script
=======================================================================================*/
#include scripts\_utility;
#include scripts\_weapon_key;

init()
{
	precacheShader( "scavenger_pickup" );
	
	level.scavengerPickups = [];
	level.scavengerBulletsLMG = 15;
	level.scavengerBulletsAR = 10;
	level.scavengerBulletsSR = 5;
	level.scavengerBulletsSP = 1;
	level.scavengerPickupTime = xDvarInt( "perk_scavenger_time", 30, 5, 120 );				// time a pickup lasts
}

makePickup( body )
{
	trigger = spawn( "trigger_radius", body.origin, 0, 32, 32 );
	trigger thread pickupThink();
	
	level.scavengerPickups[level.scavengerPickups.size] = trigger;
	
	wait level.scavengerPickupTime;
	if( isDefined(trigger) )
	{
		trigger notify( "stop_think" );
		trigger delete();
	}
}

pickupThink()
{
	self endon( "stop_think" );
	
	for(;;)
	{
		self waittill( "trigger", user );
		
		if( !isDefined(user) || !isPlayer(user) )
			continue;
			
		if( isDefined(user.team) && user.team != "allies" )
			continue;
			
		if( user hasPerkV("specialty_scavenger") )
		{
			weapon = user _getCurrentWeapon();
			if( weapon == "claymore" || weapon == "c4" || isSubStr( weapon, "grenade" ) )
				continue;
			
			weapon = strTok( weapon, "_" )[0];
			if( getWeaponClass( weapon ) == "weapon_pistol" || getWeaponClass( weapon ) == "weapon_mp" )
				bullets = level.scavengerBulletsSR;
			else if( getWeaponClass( weapon ) == "weapon_smg" || getWeaponClass( weapon ) == "weapon_assault" )
				bullets = level.scavengerBulletsAR;
			else if( getWeaponClass( weapon ) == "weapon_shotgun" || getWeaponClass( weapon ) == "weapon_sniper" )
				bullets = level.scavengerBulletsSR;
			else if( getWeaponClass( weapon ) == "weapon_lmg" )
				bullets = level.scavengerBulletsLMG;
			else
				bullets = level.scavengerBulletsSP;
						
			bullets = randomInt( bullets );
			if( bullets <= 0 )
				bullets = 1;
			
			user thread showPickupIcon();
			
			weapon = user getCurrentWeapon();
			curammo = user getWeaponAmmoStock(weapon);
			ammo = curammo+bullets;
			
			user setWeaponAmmoStock( weapon, ammo );
			break;
		}
	}
	
	self delete();
}

showPickupIcon()
{
	self notify( "scavenger_draw_icon" );
	self endon( "scavenger_draw_icon" );
	
	if( isDefined(self.hud["scavenger_pickup"]) )
		self.hud["scavenger_pickup"] destroy();
		
	self.hud["scavenger_pickup"] = newClientHudElem( self );
	self.hud["scavenger_pickup"].horzAlign = "center";
	self.hud["scavenger_pickup"].vertAlign = "middle";
	self.hud["scavenger_pickup"].x = -32;
	self.hud["scavenger_pickup"].y = -40;
	self.hud["scavenger_pickup"].alpha = 0.8;
	self.hud["scavenger_pickup"] setShader( "scavenger_pickup", 64, 32 );
	
//	self playSoundToPlayer( "oldschool_pickup", self );
	self playSoundToPlayer( "scavenger_pack_pickup", self );
	
	wait 0.1;
	
	self.hud["scavenger_pickup"] fadeOverTime( 0.4 );
	self.hud["scavenger_pickup"].alpha = 0;
	
	wait 0.5;
	
	if( isDefined(self.hud["scavenger_pickup"]) )
		self.hud["scavenger_pickup"] destroy();
}