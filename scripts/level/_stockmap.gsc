/*=======================================================================================
                        __________      __________      
                        \______   \ ____\____    /____  
                         |       _//  _ \ /     //  _ \ 
                         |    |   (  <_> )     /(  <_> )
                         |____|_  /\____/_______ \____/ 
                                \/              \/      

=========================================================================================
return of the Zombie Ops - Mod
Modded by Lefti & 3aGl3
=========================================================================================
generic map converter
=======================================================================================*/
#include scripts\_utility;

useSDTargets()
{
	printLn( "^6Getting SD targets for weapon armorys." );
	
	structs = [];
	
	// clean up the unused things
	del = getEntArray( "bombtrigger", "targetname" );
	del = arrayMerge( del, getEntArray( "bombzone", "targetname" ) );
	deleteAll( del );
	
	allObjects = getGameobjects( "bombzone" );
	/*for( i=0; i<allObjects.size; i++ )
	{
		printLn( "SD Object ", allObjects[i].origin, ";", allObjects[i].classname, ";", allObjects[i].targetname );
	}*/
	
	for( i=0; i<allObjects.size; i++ )
	{
		if( !isDefined(allObjects[i]) )
			continue;
		
		if( allObjects[i].classname == "script_model" && !isDefined(allObjects[i].used) )
		{
			allObjects[i].used = false;
			structs[structs.size] = allObjects[i];
		}
	}

	
	for( i=0; i<structs.size; i++ )
	{
		for( j=0; j<allObjects.size; j++ )
		{
			if( distance(allObjects[j].origin, structs[i].origin) < 50 )
			{
				if( allObjects[j].classname == "script_brushmodel" )
				{
					structs[i].col = allObjects[j];
					structs[i].col linkTo( structs[i] );
				}
				else if( allObjects[j].classname == "trigger_use_touch" )
				{
					structs[i].trigger = allObjects[j];
					structs[i].trigger.offset = structs[i].origin - allObjects[j].origin;
				}
			}
		}
	}
	
	printLn( "^0Struct 0 origin: ", structs[0].origin );
	printLn( "^0Struct 1 origin: ", structs[1].origin );
	
	return structs;
}

delSDTargets()
{
	allObjects = getGameobjects( "bombzone" );
	deleteAll( allObjects );
}

useSABTargets()
{
	printLn( "^6Getting SAB targets for weapon armorys." );
	
	structs = [];
		
	// clean up the unused things
	del = getEntArray( "sab_bomb_pickup_trig", "targetname" );
	del = arrayMerge( del, getEntArray( "sab_bomb", "targetname" ) );
	del = arrayMerge( del, getEntArray( "sab_bomb_allies", "targetname" ) );
	del = arrayMerge( del, getEntArray( "sab_bomb_axis", "targetname" ) );
	
	deleteAll( del );
	
	allObjects = getGameobjects( "sab" );
	for( i=0; i<allObjects.size; i++ )
	{
		printLn( "SAB Object ", allObjects[i].origin, ";", allObjects[i].classname, ";", allObjects[i].targetname );
	}
	
		for( i=0; i<allObjects.size; i++ )
	{
		if( !isDefined(allObjects[i]) )
			continue;
		
		if( allObjects[i].classname == "script_model" && !isDefined(allObjects[i].used) )
		{
			allObjects[i].used = false;
			structs[structs.size] = allObjects[i];
		}
	}

	
	for( i=0; i<structs.size; i++ )
	{
		for( j=0; j<allObjects.size; j++ )
		{
			if( distance(allObjects[j].origin, structs[i].origin) < 50 )
			{
				if( allObjects[j].classname == "script_brushmodel" )
				{
					structs[i].col = allObjects[j];
					structs[i].col linkTo( structs[i] );
				}
				else if( allObjects[j].classname == "trigger_use_touch" )
				{
					structs[i].trigger = allObjects[j];
					structs[i].trigger.offset = structs[i].origin - allObjects[j].origin;
				}
			}
		}
	}
	
	printLn( "^0Struct 0 origin: ", structs[0].origin );
	printLn( "^0Struct 1 origin: ", structs[1].origin );
	
	return structs;
}

useHQTargets()
{
	printLn( "^6Getting HQ targets for equipment armorys." );
	
	allObjects = getGameobjects( "hq" );
	hqs = getEntArray( "hq_hardpoint", "targetname" );
	for( i=0; i<allObjects.size; i++ )
	{
		printLn( "^0HQ Object ", allObjects[i].origin, ";", allObjects[i].classname, ";", allObjects[i].targetname );
	}
	
	for( i=0; i<hqs.size; i++ )
	{
		hqs[i].used = false;
		hqs[i].sub = [];
		for( j=0; j<allObjects.size; j++ )
		{
			if( allObjects[j] == hqs[i] )
				continue;
				
			if( distance(allObjects[j].origin, hqs[i].origin) < 50 )
			{
				hqs[i].sub[hqs[i].sub.size] = allObjects[j];
				allObjects[j] linkTo( hqs[i] );
			}
		}
	}
	
	return hqs;
}

delSABTargets()
{
	allObjects = getGameobjects( "sab" );
	deleteAll( allObjects );
}

delUnusedTargets( weapon, equipment )
{
	for( i=0; i<weapon.size; i++ )
	{
		if( weapon[i].used )
			continue;
		
		if( isDefined(weapon[i].col) )
			weapon[i].col delete();		// delete clip
		
		if( isDefined(weapon[i].trigger) )
			weapon[i].trigger delete();	// delete trigger
			
		if( isDefined(weapon[i]) )
			weapon[i] delete();			// delete model
	}
	
	for( i=0; i<equipment.size; i++ )
	{
		if( equipment[i].used )
			continue;
		
		for( j=0; j<equipment[i].sub.size; j++ )
			equipment[i].sub[j] delete();
		
		equipment[i] delete();
	}
}

deleteAll( array )
{
	for(i=0; i<array.size; i++)
	{
		if( isdefined(array[i]) )
		{
			println( "DELETED: ", array[i].classname, ";", array[i].targetname );
			array[i] delete();
		}
	}
}
