init()
{
level thread onPlayerConnect();

level.tesla_fx = LoadFX( "tesla/fx_zombie_tesla_electric_bolt" );

}
onPlayerConnect()
{
   for(;;)
   {
             
      level waittill("connected", player);
      player thread onPlayerSpawned();

   }
}

onPlayerSpawned()
{
 self waittill("spawned_player");
 self thread tesla_fx();
}

tesla_fx()
{
	self endon("disconnect");
	while(1)
	{
		wait .05;
		rpgs = getEntArray("rocket", "classname");
		for(x = 0; x < rpgs.size; x++)
		{
			if( self getCurrentWeapon() == "artillery_mp" && isAlive(rpgs[x])  )
			{
            	level.tesla_fx = playfxontag( level.tesla_fx, rpgs[x], "tag_origin" );
			}
        }
    }
}
		
		