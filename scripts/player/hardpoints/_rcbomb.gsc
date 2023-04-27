/*=======================================================================================
Return of the Zombie Ops - Mod
Modded by Mod-Team-Germany
=========================================================================================
RC-XD
=======================================================================================*/
#include scripts\_utility;
#include common_scripts\utility;
#include maps\mp\_utility;
#include scripts\_weapon_key;

init()
{	
	precacheModel( "rccar" );
	precacheShader( "hud_rcbomb" );
	precacheString( &"ZMB_RCBOMB" );

	level.fx_rcxd_explode = loadfx( "explosions/small_vehicle_explosion" );
	level.fx_rcxd_blink =  loadfx ( "misc/light_c4_blink" );
	
	level.rcbomb_timer = xDvarInt( "scr_streak_rcbomb_timer", 30, 30, 999999);
	level.rcbomb_radius = xDvarInt( "scr_streak_rcbomb_radius",150, 100, 999999);
			
	//level.registerHardpoint ( name, kills, callThread, title, XP, trigger, icon, sound )
	[[level.registerHardpoint]]( "rcbomb", xDvarInt( "scr_streak_rcbomb_kills", 250 ), ::createRCXD, &"ZMB_RCXD", "radar_mp", "hud_rcbomb" );
}

createRCXD()
{
    self endon("death");
    self endon("disconnect");	
	    
   	self.rcxd_car = spawn ("script_model", self.origin);
	self.rcxd_car setModel("rccar");
	self.rcxd_car.angles = (self.angles[0],self.angles[1],0);
	self.rcxd_car linkTo(self);	
	self.rcxd_maxhealth = self.maxhealth;
	self.rcxd_car thread rcxdset(self);
			
	self.rcxd_car PlayLoopSound("mp_killstreak_rcxd_car");
		
	self.rcxd_car thread rcxdwatchDamage(self);
	self.rcxd_car thread play_fx_rcxd (self);
	self.rcxd_car thread rcxdwatchOwner(self);
	self.rcxd_car thread rcxdwatchforDeath(self);		

	self thread rcxd_hupen();
	self thread rcxd_hud();
	self thread rcxd_control();
	self thread rcxd_timer();	
	self thread rcxd_climb(self.rcxd_car);
	self thread rcxd_disconnect();		
	
	return true;	
}

rcxdset(owner)
{
	owner.originalOrigin = owner.origin;
	owner.originalAngles = owner.angles;
	owner.originalModel = owner.model;
	owner.isUsingSomething = true;
	owner.godmode = true;
	owner.gasImmune = true;
	owner.isTargetable = false;
	owner setClientDvar("cg_thirdperson", "1");
	owner setClientDvar("cg_thirdpersonrange", "180");
	owner SetMoveSpeedScale( 1.8 );
	owner AllowJump(false);	
	owner TakeWeapon("radar_mp");

	owner thread getweapons();
	
	owner takeAllWeapons();		
	owner setModel("");	
	self linkto(owner);
}

getweapons()
{
	self.loadout = self getweaponslist();
	self.ammocount = [];
	self.hardpoints = [];
	for( i=0; i<self.loadout.size; i++ )
		self.ammocount[i] = self getammocount( self.loadout[i] );	
}

rcxdwatchDamage(owner)
{
	owner endon("rcxd_exploded");

	for(;;)
	{
		owner waittill( "damage" );			
		if(!isDefined(owner.godmode))
			break;
		if(isDefined(owner.godmode) && !owner.godmode)
			break;	
		owner.health = owner.maxhealth;
	}
}

rcxdwatchforDeath(owner, loadout)
{
	self endon("rcxd_used");
	self waittill ("death");

	if( isPlayer(owner))
		owner notify("rcxd_used");

	if( isPlayer(owner) && isAlive(owner) )
	{
		owner hide();
		owner setmodel("");
		thread rcxd_explode( owner, owner.origin, true);
	}
	else
	{
		if( !isDefined(owner) )
			thread rcxd_explode( undefined );
		else
			thread rcxd_explode( owner, owner.origin, false);
	}
	owner removeRCXD();
}

rcxd_hud()
{
	if(!isDefined(self.car_timer))
	{
		self.car_timer = newClientHudElem(self);
		self.car_timer.x = 320;
		self.car_timer.y = 445;
		self.car_timer.alignx = "center";
		self.car_timer.aligny = "middle";
		self.car_timer.horzAlign = "fullscreen";
		self.car_timer.vertAlign = "fullscreen";
		self.car_timer.alpha = 1;
		self.car_timer.fontScale = 2;
		self.car_timer.sort = 100;
		self.car_timer.foreground = true;
		self.car_timer setTenthsTimer( level.rcbomb_timer );
	} 	
	self waittill_any("death", "disconnect", "rcxd_used", "rcxd_destroyed");
	if(isDefined(self.car_timer)) 
		     self.car_timer destroy();
}

rcxd_control(owner, loadout)
{
	self endon("death");
	self endon("disconnect");
	self endon("game_ended");
	self endon("rcxd_used");

	while(1)
	{
		wait 0.1;
		if(level.gameEnded)
			return;

		if(self AttackButtonPressed())
		{
			self hide();
			self freezeControls(true);
			self.rcxd_car notify( "death");
			return;
		}
	}
}

rcxd_timer(time, loadout)
{
	self endon("rcxd_used");
	self endon("death");
	self endon("disconnect");
	level endon("game_ended");

	wait level.rcbomb_timer;

	self.rcxd_car notify( "death");
}

rcxdwatchOwner(owner, loadout)
{
	owner endon("rcxd_used");	
	owner waittill_any("death", "disconnect");
	owner.inRC = undefined;
		
	self notify( "death" );
}

rcxd_explode( owner, pos, doDamage )
{
	self StopLoopSound("mp_killstreak_rcxd_car");
	self StopLoopSound("mp_killstreak_rcxd_hupe");
	self unlink();
	
	if(!isdefined(owner))
		return;

	if( isAlive(owner) && doDamage )
	{
		//RadiusDamage(pos, radius, max, min, owner, eInflictor)
		self RadiusDamage(owner.origin, level.rcbomb_radius , 500 , 80, owner, "MOD_EXPLOSIVE", "rcxd_mp");
	}
	playfx ( level.fx_rcxd_explode, pos );
	thread playsoundinspace( "grenade_explode_metal", pos );
	PhysicsExplosionSphere(pos, 400, 200, 3);
	Earthquake( 0.7, 0.5, pos, 500 );
	self.maxhealth = self.rcxd_maxhealth;

	wait 3;

	owner thread respawnPlayer( owner.loadout, owner.ammocount );
}

respawnPlayer( loadout, ammocount)
{
	if(isDefined(self.rcxd_timer))
		self.rcxd_timer destroy();	
	
	self.isTargetable = true;
	self AllowJump(true);
	self.godmode = undefined;	
	self.isUsingSomething = undefined;
	self.gasImmune = undefined;
	
	self.maxhealth = self.rcxd_maxhealth;
	self.health = self.maxhealth;
	self execClientCmd( "-attack" );		
	
	self SetMoveSpeedScale( 1 );
	self setclientdvar("cg_thirdpersonrange", 120);
	
	if(!isDefined(self.pers["thirdperson"]) || !self.pers["thirdperson"]) 
		self setclientdvar("cg_thirdperson", 0);
		
	self freezeControls(false);	
	
	self unlink();
	self setorigin( self.originalOrigin );
	self setplayerangles( self.originalAngles );	
	
	self show();
	self setModel( self.originalModel );
			
	for( i=0; i<loadout.size; i++ )
	{
		weapon = loadout[i];	
		
		if( weapon == "none" || weapon == "" || weapon == "radar_mp" || weapon == "location_selector_mp")
			return;				
		
		self setWeaponAmmoOverall( getScriptName(weapon), ammocount[i] );	
		self giveWeapon( weapon );	
				
		//iPrintlnBold (weapon);	
		
		if( weaponinventorytype( weapon ) == "primary" )
			self switchToWeapon( weapon );
		else if( weapon == "frag_grenade_mp" || weapon == "frag_grenade_short_mp" )
			self switchToOffhand( weapon );
	}
}

rcxd_climb(entity)
{
	self endon("disconnect");

	origin = self.origin;
	while(isDefined(entity))
	{
		if(isDefined(self.rcxd_car) && entity == self.rcxd_car)
		{
			if(self isOnGround())
				origin = self.origin;
			else
			{
				if(self isMantling() || self isOnLadder())
					self setOrigin(origin);
			}
		}		
	wait .05;
	}
}

removeRCXD()
{
	if( isDefined(self.rcxd_sound)) self.rcxd_sound delete();
	if( isDefined(self.rcxd_car)) self.rcxd_car delete();
}

playSoundinSpace (alias, origin, master)
{
	org = spawn ("script_origin",(0,0,1));
	if (!isdefined (origin))
		origin = self.origin;
	org.origin = origin;
	if (isdefined(master) && master)
		org playsoundasmaster (alias);
	else
		org playsound (alias);
	wait ( 10.0 );
	org delete();
}

play_loop_sound_on_entity(alias, offset)
{
	org = spawn ("script_origin",(0,0,0));
	org endon ("death");
	thread delete_on_death (org);
	if (isdefined (offset))
	{
		org.origin = self.origin + offset;
		org.angles = self.angles;
		org linkto (self);
	}
	else
	{
		org.origin = self.origin;
		org.angles = self.angles;
		org linkto (self);
	}
	org playloopsound (alias);
	self waittill ("stop sound" + alias);
	org stoploopsound (alias);
	org delete();
}

delete_on_death (ent)
{
	ent endon ("death");
	self waittill ("death");
	if (isdefined (ent))
		ent delete();
}

play_fx_rcxd(owner)
{
	self endon("death");
	self endon("rcxd_used");
	self endon("rcxd_kill");

	wait 0.3;
	PlayFxonTag( level.fx_rcxd_blink, self, "tag_ant" );
}

rcxd_disconnect(owner)
{
	self endon("death");
	self waittill("disconnect");

	if(isDefined(self.rcxd_car)) self.rcxd_car delete();
}

rcxd_roundend(owner)
{
	self endon("disconnect");
 	self waittill("ending_wave");

	if(isDefined(self.rcxd_car)) self.rcxd_car delete();
	
	if(!isDefined(self.pers["thirdperson"]) || !self.pers["thirdperson"]) self setclientdvar("cg_thirdperson", 0);
			
	self setclientdvar("cg_thirdpersonrange", 120);
}

rcxd_hupen()
{
	self endon("disconnect");
	self endon("death");

	self.rcxd_hupe = spawn("script_model", self.rcxd_car.origin);
	self.rcxd_hupe linkto(self.rcxd_car);
	
	while(1)
	{
		wait 0.05;
		if(!isDefined(self.rcxd_car))
			break;

		if(self MeleeButtonPressed())
		{
			self.rcxd_hupe PlayLoopSound("mp_killstreak_rcxd_hupe");
			wait 0.1;
		
			while(self MeleeButtonPressed())
				wait 0.1;
			
			if(isDefined(self.rcxd_car))
				self.rcxd_hupe StopLoopSound("mp_killstreak_rcxd_hupe");
		}
	}
}
	
