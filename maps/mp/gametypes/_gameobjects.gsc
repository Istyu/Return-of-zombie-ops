/*=======================================================================================
Return of the Zombie Ops - Mod
Modded by Lefti & 3aGl3
=========================================================================================
Zombie Wavesystem
=======================================================================================*/
#include scripts\_utility;

main(allowed)
{
	entitytypes = getentarray();
	for(i = 0; i < entitytypes.size; i++)
	{
		if(isdefined(entitytypes[i].script_gameobjectname))
		{
			dodelete = true;
			
			// allow a space-separated list of gameobjectnames
			gameobjectnames = strtok(entitytypes[i].script_gameobjectname, " ");
			
			for(j = 0; j < allowed.size; j++)
			{
				for (k = 0; k < gameobjectnames.size; k++)
				{
					if(gameobjectnames[k] == allowed[j])
					{	
						dodelete = false;
						break;
					}
				}
				if (!dodelete)
					break;
			}
			
			if(dodelete)
			{
				//println("DELETED: ", entitytypes[i].classname);
				entitytypes[i] delete();
			}
		}
	}
}


init()
{
	level.numGametypeReservedObjectives = 0;
		
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
		
		self.touchTriggers = [];
		self.carryObject = undefined;
		self.claimTrigger = undefined;
		self.canPickupObject = true;
		self.disabledWeapon = 0;
		self.killedInUse = undefined;
	}
}