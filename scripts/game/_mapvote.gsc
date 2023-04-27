#include scripts\_utility;

init()
{
	SetDvarIfUninitialized( "scr_mapvote_gametypes", "surv arena" );
	SetDvarIfUninitialized( "scr_mapvote_surv_maps", "mp_cargoship mp_countdown mp_farm mp_killhouse mp_shipment mp_showdown" );
	SetDvarIfUninitialized( "scr_mapvote_arena_maps", "mp_cargoship mp_countdown mp_farm mp_killhouse mp_shipment mp_showdown" );
	
	level.mapvoteuse = xDvarBool( "scr_mapvote_use", 1 );
	level.mapvotetime = xDvarInt( "scr_mapvote_time", 30, 10, 120 );
	level.mapvotereplay = xDvarBool( "scr_mapvote_replay", true );
	
	level.eow_mapvotehudoffset = -7;
	wait .5;

	if( level.mapvoteuse )
	{
		CreateHud();
		thread RunMapVote();
		level waittill("VotingComplete");
		DeleteHud();
	}
	else
	{
		scripts\game\_mapsystem::getRandomMap();
	}
}

CreateHud()
{
	level.MapVotelogo = newHudElem();
	level.MapVotelogo.alignX = "center";
	level.MapVotelogo.alignY = "middle";
	level.MapVotelogo.horzAlign = "fullscreen";
	level.MapVotelogo.vertAlign = "fullscreen";
	level.MapVotelogo.alpha = 1.0;
	level.MapVotelogo.x = 325;
	level.MapVotelogo.y = 40;
	level.MapVotelogo setShader( "loadingmap", 512, 64 );
	
	level.MapVoteheader[0] = newHudElem();
	level.MapVoteheader[0].hideWhenInMenu = true;
	level.MapVoteheader[0].alignX = "center";
	level.MapVoteheader[0].x = 320;
	level.MapVoteheader[0].y = 79;
	level.MapVoteheader[0].alpha = 0.3;
	level.MapVoteheader[0].sort = 9994;
	level.MapVoteheader[0] setShader("white", 274, 2);
	
	level.MapVoteheader[1] = newHudElem();
	level.MapVoteheader[1].hideWhenInMenu = true;
	level.MapVoteheader[1].x = 190;
	level.MapVoteheader[1].y = 84;
	level.MapVoteheader[1].alpha = 1;
	level.MapVoteheader[1].fontscale = 1.4;
	level.MapVoteheader[1].sort = 9994;
	level.MapVoteheader[1].label = game["strings"]["mapvote_header"];
	
	level.MapVoteHud[0] = newHudElem();
	level.MapVoteHud[0].hideWhenInMenu = true;
	level.MapVoteHud[0].alignX = "center";
	level.MapVoteHud[0].x = 320;
	level.MapVoteHud[0].y = 105;
	level.MapVoteHud[0].alpha = 0.3;
	level.MapVoteHud[0].sort = 9994;
	level.MapVoteHud[0] setShader("white", 274, 2);

	level.MapVoteHud[1] = newHudElem();
	level.MapVoteHud[1].hideWhenInMenu = true;
	level.MapVoteHud[1].alignX = "center";
	level.MapVoteHud[1].x = 320;
	level.MapVoteHud[1].y = 220;
	level.MapVoteHud[1].alpha = 0.3;
	level.MapVoteHud[1].sort = 9994;
	level.MapVoteHud[1] setShader("white", 274, 2);

	level.MapVoteHud[2] = newHudElem();
	level.MapVoteHud[2].hideWhenInMenu = true;
	level.MapVoteHud[2].alignX = "center";
	level.MapVoteHud[2].x = 320;
	level.MapVoteHud[2].y = 246;
	level.MapVoteHud[2].alpha = 0.3;
	level.MapVoteHud[2].sort = 9994;
	level.MapVoteHud[2] setShader("white", 274, 2);

	level.MapVoteHud[3] = newHudElem();
	level.MapVoteHud[3].hideWhenInMenu = true;
	level.MapVoteHud[3].alignX = "center";
	level.MapVoteHud[3].x = 182;
	level.MapVoteHud[3].y = 79;
	level.MapVoteHud[3].alpha = 0.3;
	level.MapVoteHud[3].sort = 9994;
	level.MapVoteHud[3] setShader("white", 2, 169);

	level.MapVoteHud[4] = newHudElem();
	level.MapVoteHud[4].hideWhenInMenu = true;
	level.MapVoteHud[4].alignX = "center";
	level.MapVoteHud[4].x = 458;
	level.MapVoteHud[4].y = 79;
	level.MapVoteHud[4].alpha = 0.3;
	level.MapVoteHud[4].sort = 9994;
	level.MapVoteHud[4] setShader("white", 2, 169);

	level.MapVoteHud[5] = newHudElem();
	level.MapVoteHud[5].hideWhenInMenu = true;
	level.MapVoteHud[5].x = 190;
	level.MapVoteHud[5].y = 225;
	level.MapVoteHud[5].alpha = 1;
	level.MapVoteHud[5].fontscale = 1.4;
	level.MapVoteHud[5].sort = 9994;
	level.MapVoteHud[5].label = game["strings"]["mapvote_hint"];

	level.MapVoteHud[6] = newHudElem();
	level.MapVoteHud[6].hideWhenInMenu = true;
	level.MapVoteHud[6].alignX = "right";
	level.MapVoteHud[6].x = 450;
	level.MapVoteHud[6].y = 225;
	level.MapVoteHud[6].alpha = 1;
	level.MapVoteHud[6].fontscale = 1.4;
	level.MapVoteHud[6].sort = 9994;
	level.MapVoteHud[6].label = game["strings"]["mapvote_time"];
	level.MapVoteHud[6] setValue(level.mapvotetime);
	
	level.MapVoteHud[7] = newHudElem();
	level.MapVoteHud[7].hideWhenInMenu = true;
	level.MapVoteHud[7].alignX = "center";
	level.MapVoteHud[7].x = 320;
	level.MapVoteHud[7].y = 77;
	level.MapVoteHud[7].alpha = 0.7;
	level.MapVoteHud[7].color = (0,0,0);
	level.MapVoteHud[7].sort = 9993;
	level.MapVoteHud[7] setShader("white", 280, 173);	

	level.MapVoteNames[0] = newHudElem();
	level.MapVoteNames[1] = newHudElem();
	level.MapVoteNames[2] = newHudElem();
	level.MapVoteNames[3] = newHudElem();
	level.MapVoteNames[4] = newHudElem();
	level.MapVoteNames[5] = newHudElem();

	level.MapVoteVotes[0] = newHudElem();
	level.MapVoteVotes[1] = newHudElem();
	level.MapVoteVotes[2] = newHudElem();
	level.MapVoteVotes[3] = newHudElem();
	level.MapVoteVotes[4] = newHudElem();
	level.MapVoteVotes[5] = newHudElem();

	yPos = 112;
	for (i = 0; i < level.MapVoteNames.size; i++)
	{
		level.MapVoteNames[i].hideWhenInMenu = true;
		level.MapVoteNames[i].x = 190;
		level.MapVoteNames[i].y = yPos;
		level.MapVoteNames[i].alpha = 1;
		level.MapVoteNames[i].sort = 9995;
		level.MapVoteNames[i].fontscale = 1.4;

		level.MapVoteVotes[i].hideWhenInMenu = true;
		level.MapVoteVotes[i].alignX = "right";
		level.MapVoteVotes[i].x = 444;
		level.MapVoteVotes[i].y = yPos;
		level.MapVoteVotes[i].alpha = 1;
		level.MapVoteVotes[i].sort = 9996;
		level.MapVoteVotes[i].fontscale = 1.4;

		yPos += 17;
	}
}

RunMapVote()
{
	maps = undefined;
	x = undefined;

	currentgt = getDvar("g_gametype");
	currentmap = getdvar("mapname");
 
	x = GetRandomMapVoteRotation();
				
	if(isdefined(x))
	{
		if(isdefined(x.maps))
			maps = x.maps;
		x delete();
	}

	if(!isdefined(maps))
	{
		wait 0.05;
		level notify("VotingComplete");
		return;
	}

	for(j=0;j<7;j++)
	{
		level.mapcandidate[j]["map"] = currentmap;
		level.mapcandidate[j]["mapname"] = "Replay this map";
		level.mapcandidate[j]["gametype"] = currentgt;
		level.mapcandidate[j]["votes"] = 0;
	}
	
	i = 0;
	for(j=0;j<7;j++)
	{
		if(maps[i]["map"] == currentmap && maps[i]["gametype"] == currentgt)
			i++;

		if(!isdefined(maps[i]))
			break;

		level.mapcandidate[j]["map"] = maps[i]["map"];
		level.mapcandidate[j]["mapname"] = scripts\game\_mapsystem::getMapName(maps[i]["map"]);
		level.mapcandidate[j]["gametype"] = maps[i]["gametype"];
		level.mapcandidate[j]["votes"] = 0;

		i++;

		if(!isdefined(maps[i]))
			break;

		if( level.mapvotereplay == true && j>=4 )
			break;
	}
	
	thread DisplayMapChoices();
	
	game["menu_team"] = "";

	players = getentarray("player", "classname");
	for(i = 0; i < players.size; i++)
		players[i] thread PlayerVote();
	
	thread VoteLogic();	
}

DeleteHud()
{
	level.MapVoteheader[0] destroy();
	level.Mapvoteheader[1] destroy();
	
	level.MapVoteHud[0] destroy();
	level.MapVoteHud[1] destroy();
	level.MapVoteHud[2] destroy();
	level.MapVoteHud[3] destroy();
	level.MapVoteHud[4] destroy();
	level.MapVoteHud[5] destroy();
	level.MapVoteHud[6] destroy();
	level.MapVoteHud[7] destroy();
	
	level.MapVoteNames[0] destroy();
	level.MapVoteNames[1] destroy();
	level.MapVoteNames[2] destroy();
	level.MapVoteNames[3] destroy();
	level.MapVoteNames[4] destroy();
	level.MapVoteNames[5] destroy();
	
	level.MapVoteVotes[0] destroy();
	level.MapVoteVotes[1] destroy();
	level.MapVoteVotes[2] destroy();
	level.MapVoteVotes[3] destroy();	
	level.MapVoteVotes[4] destroy();
	level.MapVoteVotes[5] destroy();

	players = getentarray("player", "classname");
	for(i = 0; i < players.size; i++)
		if(isdefined(players[i].vote_indicator))
			players[i].vote_indicator destroy();
}

DisplayMapChoices()
{
	level endon("VotingDone");

	for (i = 0; i < level.MapVoteNames.size; i++)
	{
		if (isDefined(level.mapcandidate[i]))
		{
			if (isDefined(level.mapcandidate[i]["gametype"]))
				level.MapVoteNames[i] setText(level.mapcandidate[i]["mapname"] + " (" + level.mapcandidate[i]["gametype"] +")");
			else
				level.MapVoteNames[i] setText(level.mapcandidate[i]["mapname"]);
		}
		wait 0.05;
	}
}

PlayerVote()
{
	level endon("VotingDone");
	self endon("disconnect");
	self notify ( "reset_outcome" );

	novote = false;

	if(self.pers["team"] == "spectator")
		novote = true;
		
	if (isDefined(self.pers["isBot"]))
		novote = true;

	self maps\mp\gametypes\_globallogic::spawnSpectator();
	self.sessionstate = "spectator";
	self.spectatorclient = -1;
	resettimeout();
	
	self setClientdvar("g_scriptMainMenu", "");
	self closeMenu();

	self allowSpectateTeam("allies", false);
	self allowSpectateTeam("axis", false);
	self allowSpectateTeam("freelook", false);
	self allowSpectateTeam("none", true);

	if(novote)
		return;

	colors[0] = (0  ,  0,  1);
	colors[1] = (0  ,  0,  1);
	colors[2] = (0  ,  0,  1);
	colors[3] = (0  ,  0,  1);
	colors[4] = (0  ,  0,  1);
	colors[5] = (0  ,  0,  1);
	
	self.vote_indicator = newClientHudElem( self );
	self.vote_indicator.alignY = "middle";
	self.vote_indicator.x = 190;
	self.vote_indicator.y = level.eow_mapvotehudoffset;
	self.vote_indicator.archived = false;
	self.vote_indicator.sort = 9998;
	self.vote_indicator.alpha = 0;
	self.vote_indicator.color = colors[0];
	self.vote_indicator setShader("white", 264, 17);
	
	hasVoted = false;

	for(;;)
	{
		wait .01;

		if(self attackButtonPressed() == true)
		{
			if(!hasVoted)
			{
				self.vote_indicator.alpha = .3;
				self.votechoice = 0;
				hasVoted = true;
			}
			else
				self.votechoice++;

			if (self.votechoice == 6)
				self.votechoice = 0;

			self.vote_indicator.y = 120 + self.votechoice * 17;			
			self.vote_indicator.color = colors[self.votechoice];
		}					
		while(self attackButtonPressed() == true)
			wait.01;

		self.sessionstate = "spectator";
		self.spectatorclient = -1;
	}
}

VoteLogic()
{
	for( ; level.mapvotetime >= 0; level.mapvotetime-- )
	{
		for(j=0;j<10;j++)
		{
			for( i=0; i<6; i++ )
				level.mapcandidate[i]["votes"] = 0;
			
			players = getentarray("player", "classname");
			for(i = 0; i < players.size; i++)
			{
				if( isdefined(players[i].votechoice) )
					level.mapcandidate[players[i].votechoice]["votes"]++;
			}

			level.MapVoteVotes[0] setValue( level.mapcandidate[0]["votes"] );
			level.MapVoteVotes[1] setValue( level.mapcandidate[1]["votes"] );
			level.MapVoteVotes[2] setValue( level.mapcandidate[2]["votes"] );
			level.MapVoteVotes[3] setValue( level.mapcandidate[3]["votes"] );
			level.MapVoteVotes[4] setValue( level.mapcandidate[4]["votes"] );
			level.MapVoteVotes[5] setValue( level.mapcandidate[5]["votes"] );
			wait .1;
		}
		
		level.MapVoteHud[6] setValue( level.mapvotetime );
	}

	wait 0.2;
	
	newmapnum = 0;
	topvotes = 0;
	for(i=0;i<6;i++)
	{
		if (level.mapcandidate[i]["votes"] > topvotes)
		{
			newmapnum = i;
			topvotes = level.mapcandidate[i]["votes"];
		}
	}

	SetMapWinner(newmapnum);
}

SetMapWinner(winner)
{
	map		= level.mapcandidate[winner]["map"];
	mapname	= level.mapcandidate[winner]["mapname"];
	gametype	= level.mapcandidate[winner]["gametype"];

//	setdvar("sv_maprotationcurrent", " gametype " + gametype + " map " + map);
	if( isDefined(gametype) )
		level.mapvote["gametype"] = gametype;
	else
		level.mapvote["gametype"] = getDvar("g_gametype");
	level.mapvote["level"] = map;
	wait 0.1;

	level notify( "VotingDone" );
	wait 0.05;

	iprintlnbold( &"ZMB_THE_WINNER_IS" );
	iprintlnbold( mapname );
	iprintlnbold( scripts\game\_mapsystem::GetGametypeName(gametype) );

	level.MapVoteheader[0] fadeOverTime (1);
	level.Mapvoteheader[1] fadeOverTime (1);
	
	level.MapVoteHud[0] fadeOverTime (1);
	level.MapVoteHud[1] fadeOverTime (1);
	level.MapVoteHud[2] fadeOverTime (1);
	level.MapVoteHud[3] fadeOverTime (1);
	level.MapVoteHud[4] fadeOverTime (1);
	level.MapVoteHud[5] fadeOverTime (1);
	level.MapVoteHud[6] fadeOverTime (1);
	level.MapVoteHud[7] fadeOverTime (1);
	
	level.MapVoteNames[0] fadeOverTime (1);
	level.MapVoteNames[1] fadeOverTime (1);
	level.MapVoteNames[2] fadeOverTime (1);
	level.MapVoteNames[3] fadeOverTime (1);
	level.MapVoteNames[4] fadeOverTime (1);
	level.MapVoteNames[5] fadeOverTime (1);
	
	level.MapVoteVotes[0] fadeOverTime (1);
	level.MapVoteVotes[1] fadeOverTime (1);
	level.MapVoteVotes[2] fadeOverTime (1);
	level.MapVoteVotes[3] fadeOverTime (1);	
	level.MapVoteVotes[4] fadeOverTime (1);
	level.MapVoteVotes[5] fadeOverTime (1);

	level.MapVoteheader[0].alpha = 0;
	level.Mapvoteheader[1].alpha = 0;
	
	level.MapVoteHud[0].alpha = 0;
	level.MapVoteHud[1].alpha = 0;
	level.MapVoteHud[2].alpha = 0;
	level.MapVoteHud[3].alpha = 0;
	level.MapVoteHud[4].alpha = 0;
	level.MapVoteHud[5].alpha = 0;
	level.MapVoteHud[6].alpha = 0;
	level.MapVoteHud[7].alpha = 0;
	
	level.MapVoteNames[0].alpha = 0;
	level.MapVoteNames[1].alpha = 0;
	level.MapVoteNames[2].alpha = 0;
	level.MapVoteNames[3].alpha = 0;
	level.MapVoteNames[4].alpha = 0;
	level.MapVoteNames[5].alpha = 0;
	
	level.MapVoteVotes[0].alpha = 0;
	level.MapVoteVotes[1].alpha = 0;
	level.MapVoteVotes[2].alpha = 0;
	level.MapVoteVotes[3].alpha = 0;	
	level.MapVoteVotes[4].alpha = 0;
	level.MapVoteVotes[5].alpha = 0;

	players = getentarray("player", "classname");
	for(i = 0; i < players.size; i++)
	{
		if(isdefined(players[i].vote_indicator))
		{
			players[i].vote_indicator fadeOverTime (1);
			players[i].vote_indicator.alpha = 0;
		}
	}

	wait 4;
	level notify( "VotingComplete" );
}

GetRandomMapVoteRotation()
{	
	gtrotstr = getdvar( "scr_mapvote_gametypes" );
	gtrot_array = listOfStringsToArray(gtrotstr);
	
	x = spawn("script_origin",(0,0,0));
	x.maps = [];
	z=0;
		
	for (i=0; i<gtrot_array.size; i++)
	{
		gt=gtrot_array[i];
		gtmaprotstr = getdvar( "scr_mapvote_" + gt + "_maps" );
		if(isdefined(gtmaprotstr))
		{
			gtmaprot = listOfStringsToArray(gtmaprotstr);
		  
			for(j=0; j<gtmaprot.size; j++)
			{
				x.maps[z]["gametype"] = gt ;
				x.maps[z]["map"] = gtmaprot[j];
				z++;
			}
		}
	}

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

	return x;
}

listOfStringsToArray(list)
{		
	list = scripts\game\_mapsystem::strip(list);
		
	j=0;
	temparr2[j] = "";	
	for(i=0;i<list.size;i++)
	{
		if(list[i]==" ")
		{
			j++;
			temparr2[j] = "";
		}
		else
			temparr2[j] += list[i];
	}

	temparr = [];
	for(i=0;i<temparr2.size;i++)
	{
		element = scripts\game\_mapsystem::strip(temparr2[i]);
		if(element != "")
		{
			temparr[temparr.size] = element;
		}
	}
	return temparr;
}