init()
{
	precacheString( &"ZMB_THE_WINNER_IS" );
	precacheShader( "loadingmap" );
}

GetPlainMapRotation(number)
{
	return GetMapRotation(false, false, number);
}

GetRandomMapRotation()
{
	return GetMapRotation(true, false, undefined);
}

GetCurrentMapRotation(number)
{
	return GetMapRotation(false, true, number);
}

GetMapRotation(random, current, number)
{
	maprot = "";

	if(!isdefined(number))
		number = 0;

	if(current)
		maprot = strip(getDvar("sv_maprotationcurrent"));	

	if(maprot == "") maprot = strip(getDvar("sv_maprotation"));	

	if(maprot == "")
		return undefined;
		
	j=0;
	temparr2[j] = "";	
	for(i=0;i<maprot.size;i++)
	{
		if(maprot[i]==" ")
		{
			j++;
			temparr2[j] = "";
		}
		else
			temparr2[j] += maprot[i];
	}

	temparr = [];
	for(i=0;i<temparr2.size;i++)
	{
		element = strip(temparr2[i]);
		if(element != "")
		{
			temparr[temparr.size] = element;
		}
	}

	x = spawn("script_origin",(0,0,0));

	x.maps = [];
	lastexec = undefined;
	lastgt = level.eow_gametype;
	for(i=0;i<temparr.size;)
	{
		switch(temparr[i])
		{
			case "exec":
				if(isdefined(temparr[i+1]))
					lastexec = temparr[i+1];
				i += 2;
				break;

			case "gametype":
				if(isdefined(temparr[i+1]))
					lastgt = temparr[i+1];
				i += 2;
				break;

			case "map":
				if(isdefined(temparr[i+1]))
				{
					x.maps[x.maps.size]["exec"]		= lastexec;
					x.maps[x.maps.size-1]["gametype"]	= lastgt;
					x.maps[x.maps.size-1]["map"]	= temparr[i+1];
				}

				if(!random)
				{
					lastexec = undefined;
					lastjeep = undefined;
					lasttank = undefined;
					lastgt = undefined;
				}

				i += 2;
				break;

			default:
				iprintlnbold( "Error in der Map Rotation" );
	
				if(isGametype(temparr[i]))
					lastgt = temparr[i];
				else if(isConfig(temparr[i]))
					lastexec = temparr[i];
				else
				{
					x.maps[x.maps.size]["exec"]		= lastexec;
					x.maps[x.maps.size-1]["gametype"]	= lastgt;
					x.maps[x.maps.size-1]["map"]	= temparr[i];

					if(!random)
					{
						lastexec = undefined;
						lastjeep = undefined;
						lasttank = undefined;
						lastgt = undefined;
					}
				}
					

				i += 1;
				break;
		}
		if(number && x.maps.size >= number)
			break;
	}

	if(random)
	{
		for(k = 0; k < 20; k++)
		{
			for(i = 0; i < x.maps.size; i++)
			{
				j = randomInt(x.maps.size);
				element = x.maps[i];
				x.maps[i] = x.maps[j];
				x.maps[j] = element;
			}
		}
	}

	return x;
}

isConfig(cfg)
{
	temparr = explode(cfg,".");
	if(temparr.size == 2 && temparr[1] == "cfg")
		return true;
	else
		return false;
}

explode(s,delimiter)
{
	j=0;
	temparr[j] = "";	

	for(i=0;i<s.size;i++)
	{
		if(s[i]==delimiter)
		{
			j++;
			temparr[j] = "";
		}
		else
			temparr[j] += s[i];
	}
	return temparr;
}

strip(s)
{
	if(s=="")
		return "";

	s2="";
	s3="";

	i=0;
	while(i<s.size && s[i]==" ")
		i++;

	// String is just blanks?
	if(i==s.size)
		return "";
	
	for(;i<s.size;i++)
	{
		s2 += s[i];
	}

	i=s2.size-1;
	while(s2[i]==" " && i>0)
		i--;

	for(j=0;j<=i;j++)
	{
		s3 += s2[j];
	}
		
	return s3;
}

isGametype(gt)
{
	switch(gt)
	{
		case "dm":
		case "war":
		case "surv":
		case "arena":
			return true;
		default:
			return false;
	}
}

getGametypeName(gt)
{
	switch(gt)
	{
		case "war":
		case "surv":
			gtname = &"MPUI_SURV";
			break;
		case "dm":
		case "arena":
			gtname = &"MPUI_ARENA";
			break;
		default:
			gtname = gt;
			break;
	}

	return gtname;
}

getMapName(map)
{
	switch(map)
	{
		case "mp_bog":
			mapname = "Bog";
			break;
		
		case "mp_countdown":
			mapname = "Countdown";
			break;

		case "mp_cargoship":
			mapname = "Cargoship - Wet Work";
			break;

		case "mp_farm":
			mapname = "Downpour - Farm";
			break;

		case "mp_overgrown":
			mapname = "Overgrown";
			break;

		case "mp_pipeline":
			mapname = "Pipeline";
			break;
		
		case "mp_shipment":
			mapname = "Shipment";
			break;

		case "mp_showdown":
			mapname = "Showdown";
			break;

		case "mp_strike":
			mapname = "Strike";
			break;

		case "mp_creek":
			mapname = "Creek";
			break;

		case "mp_killhouse":
			mapname = "Killhouse";
			break;		

		case "mp_burgundy_bulls":
			mapname = "Burgundy Bulls";
			break;

		case "mp_twin_2":
			mapname = "Twin 2";
			break;		

		case "mp_paisible":
			mapname = "Paisible";
			break;

		case "mp_vukovar_n":
			mapname = "Vukovar Night Version";
			break;	

		case "mp_vukovar":
			mapname = "Vukovar Day Version";
			break;	

		case "mp_modern_rust":
			mapname = "Rust - Modern Warfare 2";
			break;			
			
		case "mp_highrise":
			mapname = "Highrise - Modern Warfare 2";
			break;
			
		case "mp_karachi":
			mapname = "Karachi - Modern Warfare 2";
			break;	

		case "mp_fav":
			mapname = "Favela - Modern Warfare 2";
			break;	

		case "mp_inv":
			mapname = "Invasion - Modern Warfare 2";
			break;	

		case "mp_4t4scrap":
			mapname = "Scrapyard - Modern Warfare 2";
			break;	

		case "mp_skidrow":
			mapname = "Skidrow - Modern Warfare 2";
			break;			
			
		default:
		    if(getsubstr(map,0,3) == "mp_")
				mapname = getsubstr(map,3);
			else
				mapname = map;

			tmp = "";
			from = "abcdefghijklmnopqrstuvwxyz";
		    to   = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
		    nextisuppercase = true;
			for(i=0;i<mapname.size;i++)
			{
				if(mapname[i] == "_")
				{
					tmp += " ";
					nextisuppercase = true;
				}
				else if (nextisuppercase)
				{
					found = false;
					for(j = 0; j < from.size; j++)
					{
						if(mapname[i] == from[j])
						{
							tmp += to[j];
							found = true;
							break;
						}
					}
					
					if(!found)
						tmp += mapname[i];
					nextisuppercase = false;
				}
				else
					tmp += mapname[i];
			}

			if((getsubstr(tmp,tmp.size-2)[0] == "B")&&(issubstr("0123456789",getsubstr(tmp,tmp.size-1))))
				mapname = getsubstr(tmp,0,tmp.size-2)+"Beta"+getsubstr(tmp,tmp.size-1);
			else
				mapname = tmp;
			break;
	}

	return mapname;
}

getRandomMap()
{
	gametypes = strTok( getDvar("scr_mapvote_gametypes"), " " );
	maps = [];
	
	for( i=0; i<gametypes.size; i++ )
	{
		tempmaps = strTok( getdvar( "scr_mapvote_" + gametypes[i] + "_maps" ), " " );
		for( j=0; j<tempmaps.size; j++ )
		{
			id = maps.size;
			
			maps[id] = spawnstruct();
			maps[id].map = tempmaps[j];
			maps[id].gametype = gametypes[i];
		}	
	}
	
	map = maps[randomInt(maps.size)];
	
	level.mapvote["gametype"] = map.gametype;
	level.mapvote["level"] = map.map;
	
	iprintlnbold( &"ZMB_THE_WINNER_IS" );
	iprintlnbold( getMapName(map.map) );
	iprintlnbold( GetGametypeName(map.gametype) );
	
	wait 4;
}