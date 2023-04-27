/*=======================================================================================
Return of the Zombie Ops - Mod
Modded by Lefti & 3aGl3
=========================================================================================
Weapon Armory Menu - Script
=======================================================================================*/
#include scripts\_utility;
#include scripts\_weapon_key;


init()
{
	precacheString( &"ZMB_YOU_ALREADY_OWN_ONE" );
}


responseHandler( response )		// self = player
{
	if( issubstr( response, "escape" ) )
	{
		self escapeMenu(response);
	}
	else if( response == "ammoRefill" )
	{
		self refillAmmo();
	}
	else if( isSubStr( response, "buy" ) )
	{
		self buyWeapon(response);
	}
}

escapeMenu( response )
{
	toks = strTok( response, "#" );
	
	if( toks.size <= 1 || toks[1] == "select" )
	{
		self closeMenus();
	}
	else if( toks[1] != "select" )
	{
		self setClientDvar( "armory", "select" );
	}
}

refillAmmo()
{
	if( self.points >= level.wShopCost["ammo"] )
	{
		list = self getweaponslistprimaries();
		for( i=0; i<list.size; i++ )
			self givemaxammo( list[i] );
		
		self scripts\player\_points::takePoints( level.wShopCost["ammo"] );
	}
	else
	{
		self iPrintLn( &"ZMB_NOT_ENOUGH_POINTS_N", level.wShopCost["ammo"] );
	}
	
	self closeMenus();
}

buyWeapon( response )
{
	tokens = strTok( response, "#" );
	weapon = tablelookup( "mp/statsTable.csv", 0, tokens[1], 4 );
	
	if( self _hasWeapon(weapon) )
	{
		self iPrintLn( &"ZMB_YOU_ALREADY_OWN_ONE" );
	}
	else
	{
		attachments = tableLookup( "mp/statsTable.csv", 4, weapon, 8 );
		attachtoks = strTok( attachments, " " );
		
		hasUpgraded = undefined;
		if( attachtoks.size >= 1 )
		{
			for( i=0; i<attachtoks.size; i++ )
			{
				if( self _hasWeapon(weapon+"_"+attachtoks[i]) )
				{
					hasUpgraded = true;
					break;
				}
			}	
		}
		
		if( isdefined(hasUpgraded) )		// owns a upgraded one
		{
			self iPrintLn( &"ZMB_YOU_ALREADY_OWN_ONE" );
		}
		else		// dosn't owns the weapon, nor a upgraded one
		{
			weaponClass = tableLookup( "mp/statsTable.csv", 4, weapon, 2 );
			weaponClassA = strTok( weaponClass, "_" );
			
			if( weaponClassA[1] == "projectile" || weaponClassA[1] == "misc" || weaponClassA[1] == "melee" )
				weaponClassA[1] = "special";
			
			if( self.points >= level.wShopCost[weaponClassA[1]] )
			{
				if( _weaponInventoryType(weapon) == "primary" )
				{
					if( self primaryCount() >= 2 )
						self takeWeapon( self getCurrentWeapon() );
					
					self _giveWeapon( weapon );
					self _switchToWeapon( weapon );
				}
				else
				{
					self _giveWeapon( weapon );
				}
				
				self scripts\player\_points::takePoints( level.wShopCost[weaponClassA[1]] );
				self playLocalSound( "mp_ingame_summary" );
			}
			else
			{
				self iPrintLn( &"ZMB_NOT_ENOUGH_POINTS" );
			}
		}
	}
	
	self closeMenus();
}