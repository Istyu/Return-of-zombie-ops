/*=======================================================================================
Return of the Zombie Ops - Mod
Modded by Lefti & 3aGl3
=========================================================================================
Zombie Health
=======================================================================================*/
#include scripts\_utility;
#include maps\mp\gametypes\_hud_util;

init()
{
	precacheModel( "prop_medikit" );
	
	level.playerBaseHealth = xDvarInt( "scr_player_basehealth", 100, 50, 500 );
	regenTime = xDvarFloat( "scr_player_healthreg", 0.5, 0, 1 );
	
	level.medikit_level = [];
	level.medikit_level[0] = "medikit_none";
	level.medikit_level[1] = "medikit_small";
	level.medikit_level[2] = "medikit_medium";
	level.medikit_level[3] = "medikit_large";
	level.medikit_level[4] = "medikit_xlarge";
	level.medikit_level[5] = "medikit_extra";

	level.healthOverlayCutoff = 0.55; // getting the dvar value directly doesn't work right because it's a client dvar getdvarfloat("hud_healthoverlay_pulseStart");
	
	level.playerHealth_RegularRegenDelay = regenTime * 9000;
	level.healthRegenDisabled = (level.playerHealth_RegularRegenDelay <= 0);

	thread onPlayerConnect();
}

onPlayerConnect()
{
	for(;;)
	{
		level waittill( "connected", player );
		
		wait .05;		// so the isBot can be set
		
		if( !isDefined(player.pers["isBot"]) || player.pers["isBot"] == false )
			player thread onPlayerSpawned();
	}
}

onPlayerSpawned()
{
	self endon("disconnect");

	for(;;)
	{
		self waittill( "spawned_player" );
		
		self thread updateHealthHud();
		self thread playerHealthRegen();
	}
}

playerHealthRegen()
{
	self endon( "disconnect" );
	self endon( "joined_team" );
	self endon( "joined_spectators" );
	self endon( "killed_player" );
	self endon( "end_healthregen" );
	
	if( self.health <= 0 )
	{
		assert( !isalive( self ) );
		return;
	}
	
	maxhealth = self.health;
	oldhealth = maxhealth;
	player = self;
	health_add = 0;
	
	regenRate = 0.07;
	veryHurt = false;
	
	player.breathingStopTime = -10000;
	
	thread playerBreathingSound(maxhealth * 0.35);
	
	lastSoundTime_Recover = 0;
	hurtTime = 0;
	newHealth = 0;
	
	for(;;)
	{
		wait (0.05);
		if (player.health == maxhealth)
		{
			veryHurt = false;
			self.atBrinkOfDeath = false;
			continue;
		}

		if (player.health <= 0)
			return;

		wasVeryHurt = veryHurt;
		ratio = player.health / maxHealth;
		if (ratio <= level.healthOverlayCutoff)
		{
			veryHurt = true;
			self.atBrinkOfDeath = true;
			if (!wasVeryHurt)
			{
				hurtTime = gettime();
			}
		}
			
		if (player.health >= oldhealth)
		{
			if (gettime() - hurttime < level.playerHealth_RegularRegenDelay)
				continue;
			
			if ( level.healthRegenDisabled )
				continue;

			if (gettime() - lastSoundTime_Recover > level.playerHealth_RegularRegenDelay)
			{
				lastSoundTime_Recover = gettime();
				self playLocalSound("breathing_better");
			}
	
			if (veryHurt)
			{
				newHealth = ratio;
				if (gettime() > hurtTime + 3000)
					newHealth += regenRate;
			}
			else
				newHealth = 1;
							
			if ( newHealth >= 1.0 )
				newHealth = 1.0;
				
			if (newHealth <= 0)
			{
				// Player is dead
				return;
			}
			
			player setnormalhealth(newHealth);
			oldhealth = player.health;
			continue;
		}

		oldhealth = player.health;
			
		health_add = 0;
		hurtTime = gettime();
		player.breathingStopTime = hurtTime + 6000;
	}
}

playerBreathingSound(healthcap)
{
	self endon("end_healthregen");
	
	wait (2);
	player = self;
	for(;;)
	{
		wait (0.2);
		if( !isDefined(player.health) || player.health <= 0 )
			return;
			
		// Player still has a lot of health so no breathing sound
		if(player.health >= healthcap)
			continue;
		
		if( level.healthRegenDisabled && gettime() > player.breathingStopTime )
			continue;
			
		player playLocalSound("breathing_hurt");
		wait .784;
		wait (0.1 + randomfloat (0.8));
	}
}

updateHealthHud()
{
	self endon( "killed_player" );
	self endon( "disconnect" );
	
	max = self.maxhealth;
	health = self.health;
	self setClientDvars( "ui_maxhealth", max, "ui_health", health );
	
	for(;;)
	{
		if( self.health != health || max != self.maxhealth )
		{
			max = self.maxhealth;
			health = self.health;
			
			if( health <= 0 )
				health = 1;
			
			self setClientDvars( "ui_maxhealth", max, "ui_health", health );
		}
		wait 0.5;
	}
}