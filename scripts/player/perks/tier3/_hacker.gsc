/*=======================================================================================
return of the zombie ops - mod
Modded by Lefti & 3aGl3
=========================================================================================
Hacker Perk script
=======================================================================================*/
#include scripts\_utility;
#include common_scripts\utility;

init()
{
	precacheShader( "marker_explosive" );
	precacheShader( "hud_us_smokegrenade" );
	precacheShader( "death_airstrike" );
}

main( perk )
{
	self endon( "disconnect" );
	self endon( "killed_player" );
	
	self thread cleanupIcon();
	for(;;)
	{
		if( self playerADS() > 0.1 )
		{
			while( self playerADS() >= 0.9 )
			{
				wait 0.01;
				
				vec = anglestoforward(self getPlayerAngles()); 
				end = (vec[0] * 2048, vec[1] * 2048, vec[2] * 2048); 
				trace = bulletTrace( self getEyeOrigin(), self getEyeOrigin()+end, true, self);
				
				if( isDefined(trace["entity"]) && isPlayer(trace["entity"]) )
				{
					aimedZombie = trace["entity"];
					if( aimedZombie isExplosive() )
					{
						self drawWarning( "marker_explosive" );
					}
					else if( aimedZombie isTabun() )
					{
						self drawWarning( "hud_us_smokegrenade" );
					}
					else if( aimedZombie isSlime() )
					{
						self drawWarning( "death_airstrike" );
					}
				}
				else
				{
					self deleteWarning();
				}
			}
			self deleteWarning();
		}
		wait 1;
	}
}

cleanupIcon()
{
	self waittill_any( "killed_player", "second_chance_start", "spawned" );
	self deleteWarning();
}

drawWarning( shader )
{
	if( isDefined(self.hud["hacker_icon"]) )
		self.hud["hacker_icon"] destroy();
	
	self.hud["hacker_icon"] = newClientHudElem( self );
	self.hud["hacker_icon"].horzAlign = "center";
	self.hud["hacker_icon"].vertAlign = "middle";
	self.hud["hacker_icon"].x = -12;
	self.hud["hacker_icon"].y = 12;
	self.hud["hacker_icon"] setShader( shader, 24, 24 );
	self.hud["hacker_icon"].alpha = 1;
	self.hud["hacker_icon"].archived = true;
}

deleteWarning()
{
	if( isDefined(self.hud["hacker_icon"]) )
		self.hud["hacker_icon"] destroy();
}