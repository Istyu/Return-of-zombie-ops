/*=======================================================================================
                        __________      __________      
                        \______   \ ____\____    /____  
                         |       _//  _ \ /     //  _ \ 
                         |    |   (  <_> )     /(  <_> )
                         |____|_  /\____/_______ \____/ 
                                \/              \/      

=========================================================================================
Return of the Zombie Ops - Mod
Modded by Lefti & 3aGl3
=========================================================================================
Barricade Script
=======================================================================================*/
#include maps\mp\gametypes\_hud_util;
#include scripts\_utility;

init()
{
	precacheString( &"ZMB_PRESS_USE_TO_REBUILD" );
	
	level.barricadeRepairPoints = xDvarInt( "scr_points_repair", 10, 1 );
	level.barricadeRepairTime = xDvarInt( "scr_barricade_repair_time", 1, 0, 10 );
	level.barricadeAlliesDamage = xDvarBool( "scr_allow_allies_struct_damage", 0 );
}

barricade_create()
{
	self setCanDamage( true );
	
	self.boards = self.parts.size;							// boards up
	self.maxhealth = self.parthealth*self.boards;			// maximum health
	self.health = self.maxhealth;							// current health
	
	for( i=0; i<self.parts.size; i++ )
	{
		self.parts[i].maxhealth = self.parthealth;
		self.parts[i].health = self.parts[i].maxhealth;
	}
	
	self thread barricade_damage_think();
	self thread barricade_rebuild_think();
}

barricade_damage_think()
{
	for(;;)
	{
		self waittill( "damage", damage, eAttacker, dmgDir, dmgOrigin, sMeansOfDeath );
		
		if( self.health < 0 )		// we don't want the health drop under 0
			self.health = 0;
		
		if( isDefined(eAttacker.team) && eAttacker.team == "allies" )		// no damage from allies
		{
			self.health += damage;
			continue;
		}
		
		for( i=0; i<self.parts.size; i++ )
		{
			board = self.parts[i];
			if( board.health > 0 )
			{
				if( damage < board.health )
				{
					board.health -= damage;
					break;
				}
				else if( damage > board.health )
				{
					board.health = 0;
					board hide();
					
					self.boards--;
					self setHintString( &"ZMB_PRESS_USE_TO_REBUILD" );
					
					damage = damage-self.parthealth;
				}
				else
				{
					board.health = 0;
					board hide();
					
					self.boards--;
					self setHintString( &"ZMB_PRESS_USE_TO_REBUILD" );
					break;
				}
			}
		}
		
		if( self.boards == 0 )		// no boards up -> no health left
			self.health = 0;
	}
}

barricade_rebuild_think()
{
	for(;;)
	{
		self waittill( "trigger", user );
		
		if( !isDefined(user.team) || user.team != "allies" || isDefined(user.isUsingSomething) )
			continue;
		
		if( self.boards >= self.parts.size )
			continue;
		
		user disableWeapons( true );
		user.isUsingSomething = true;
		
		if( isDefined(user.pBar) )							// destroy any old progress bars
			user.pBar destroyElem();
	
		user.pBar = user createPrimaryProgressBar();		// create a progress bar for him
		
		stepping = 100/(level.barricadeRepairTime/0.01);
		
		self playSound( "env_rebuild_barricade_board" );
		
		percent = 0;
		while( user isTouching(self) && user useButtonPressed() )
		{
			percent += stepping;
			user.pBar updateBar( percent/100 );
			
			wait 0.01;
			
			if( percent >= 100 )
				break;
		}
		
		if( percent >= 100 )
			self thread rebuild_board( user );
		
		user.pBar destroyElem();
		
		user enableWeapons( true );
		user.isUsingSomething = undefined;
	}
}

rebuild_board( user )
{
	self.boards++;
	ID = self.parts.size-self.boards;
	
	self.parts[ID] show();
	self.parts[ID].health = self.parts[ID].maxhealth;
	
	if( ID == 0 )
		self setHintString( "" );
	
	self.health += self.parthealth;
	
	user thread scripts\player\_points::givePoints( level.barricadeRepairPoints );
}