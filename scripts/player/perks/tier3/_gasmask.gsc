/*=======================================================================================
Return of the Zombie Ops - Mod
Modded by Lefti & 3aGl3
=========================================================================================
Gasmask Perk script
=======================================================================================*/
#include scripts\_utility;
#include common_scripts\utility;

init()
{
	precacheShader( "gasmask_overlay" );
}

main( perk )
{
	self endon( "disconnect" );
	self endon( "killed_player" );
	
	self notify( "activePerkWaiter3_start" );
	self endon( "activePerkWaiter3_start" );
	
	self.gasImmune = undefined;
	self _setActionSlot( 7, "gasmask", "specialty_grenadepulldeath" );
	
	for(;;)
	{
		self waittill( "toggle_dpad7" );
		
		if( isDefined(self.gasImmune) )
		{
			self disableweapons( true );
			self thread fadeOverBlack( .3, .5, .2 );
			wait .5;
			self notify( "remove_mask" );
			self enableweapons( true );
		}
		else
		{
			self disableweapons( true );
			self thread fadeOverBlack( .3, .5, .2 );
			wait .5;
			self.gasImmune = true;
			self createGasmaskOverlay();
			self thread mask_think();
			self enableweapons( true );
		}
	}
}

mask_think()
{
	self waittill_any( "remove_mask", "killed_player", "second_chance_start", "spawned" );
	
	self.gasImmune = undefined;
	self deleteGasmaskOverlay();
}

createGasmaskOverlay()
{
	if( isDefined(self.hud["gasmaskov"]) )
		self.hud["gasmaskov"] destroy();
		
	self.hud["gasmaskov"] = newClientHudElem( self );
	self.hud["gasmaskov"].x = 0;
	self.hud["gasmaskov"].y = 0;
	self.hud["gasmaskov"].alignX = "left";
	self.hud["gasmaskov"].alignY = "top";
	self.hud["gasmaskov"].horzAlign = "fullscreen";
	self.hud["gasmaskov"].vertAlign = "fullscreen";
	self.hud["gasmaskov"].sort = 0;
	self.hud["gasmaskov"] setShader( "gasmask_overlay", 640, 480 );
	self.hud["gasmaskov"].alpha = 1;
}

deleteGasmaskOverlay()
{
	if( isDefined(self.hud["gasmaskov"]) )
		self.hud["gasmaskov"] destroy();
}