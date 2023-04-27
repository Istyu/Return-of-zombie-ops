/*=======================================================================================
Return of the Zombie Ops - Mod
Modded by Lefti & 3aGl3
=========================================================================================
Zombie Wavesystem
=======================================================================================*/
#include scripts\_utility;
#include maps\mp\gametypes\_hud_util;

init()
{
	precacheString( &"ZMB_NEW_WAVE_INCOMING" );
	precacheString( &"ZMB_NEW_N_WAVE_INCOMING" );
	precacheString( &"MPUI_WB_TIME" );				// Time: &&1
	precacheString( &"MPUI_WB_WAVE" );				// Wave: &&1
	precacheString( &"MPUI_WB_KNIFE" );				// Knifekills: &&1
	precacheString( &"MPUI_WB_HEAD" );				// Headshots: &&1
	precacheString( &"MPUI_WB_FRAG" );				// Grenade kills: &&1
	precacheString( &"MPUI_WB_SIDE" );				// Sidearm kills: &&1
	
	level.startwavetext[0] = &"ZMB_READY_UP";
	level.startwavetext[1] = &"ZMB_THEY_WILL_BE_BACK";
	precacheString(level.startwavetext[0]);
	precacheString(level.startwavetext[1]);
	
	level.waveInProgress = false;
	level.specialWave = "none";
	level.waveID = 1;
	level.waveZnum = 0;
	level.freeSpawnCap = xDvarInt( "scr_wave_allowspawn", 1, 0, 999999 );		// allows spawning during the entire 1st wave
	
	setDvar( "ui_zombies_round", 0 );
	makeDvarServerInfo( "ui_zombies_round" );
	setDvar( "ui_zombies_killed", 0 );
	makeDvarServerInfo( "ui_zombies_killed" );
	setDvar( "ui_zombies_alive", 0 );
	makeDvarServerInfo( "ui_zombies_alive" );
	
	level.zombie_starttime 		= xDvarInt( "scr_wave_starttime", 6, 6 );
	level.zombie_preparetime	= xDvarInt( "scr_wave_preparetime", 15, 6 );
	level.zombieBaseNum 		= xDvarInt( "scr_wave_basenum", 15 );
	level.zombieWaveIncrease 	= xDvarInt( "scr_wave_increase", 5 );
	level.zombieSpecialWaves	= xDvarBool( "scr_wave_special", 1 );
	level.zombieSpecialChance	= xDvarInt( "scr_wave_specialchance", 10 );
	level.zombieSpecialSafe		= xDvarInt( "scr_wave_special_safe", 5 );
	
	SetDvarIfUninitialized( "scr_wave_max", 0 );
	SetDvarIfUninitialized( "scr_5secwarning_text", 1 );
	SetDvarIfUninitialized( "scr_5secwarning_sound", 1 );	
	if( isDeveloper() )
		SetDvarIfUninitialized( "dev_frezze_waves", 0 );
	
	thread createStartHud();
	thread startWaves();
	thread onZombieKilled();
}

startWaves()
{
	level endon( "game_ended" );
	
	visionSetNaked( "default", 1 );
	
	for(;;)
	{
		if( isDefined(level.everSpawnedSurvivor) && level.everSpawnedSurvivor )
			break;
		
		wait 0.05;
	}
	
	thread updateHud( 0, 0, 0 );
	level.starthud[0].alpha = 1;
	
	for ( ; level.zombie_starttime >= 0; level.zombie_starttime--)
	{	
		if( level.zombie_starttime == 5 && getDvarBool("scr_5secwarning_text") )
		{
			level.starthud[1] fadeOverTime( 0.2 );
			level.starthud[1].alpha = 1;
		}
		
		if( level.zombie_starttime <= 5 && getDvarBool("scr_5secwarning_sound") )
			playSoundOnAllPlayers( "ui_mp_timer_countdown" );
		
		level.starthud[0] setValue(level.zombie_starttime);
		level.starthud[1] setValue(level.zombie_starttime);
		
		wait 1;
	}
	
	thread deleteStartHud();
	
	if( isDeveloper() )
	{
		for(;;)
		{
			if( !getDvarBool("dev_frezze_waves") )
				break;
				
			wait 5;
		}
	}
	
	level notify( "starting_first_wave" );
	
	thread zombieWave();
}

PrepareTime()
{
	level endon( "game_ended" );
	
	createStartHud();
	
	level.starthud[0].label = level.startwavetext[1];
	level.starthud[0] fadeOverTime( 0.2 );
	
	level.starthud[0].alpha = 1;
	
	for ( ; level.zombie_preparetime >= 0; level.zombie_preparetime--)
	{	
		if( level.zombie_preparetime == 5 && getDvarBool("scr_5secwarning_text") )
		{
			level.starthud[1] fadeOverTime( 0.2 );
			level.starthud[1].alpha = 1;
			level notify( "wave_five_warning" );
		}
		if( level.zombie_preparetime <=5 && getDvarBool("scr_5secwarning_sound") )
		{
			playSoundOnAllPlayers( "ui_mp_timer_countdown" );
		}
				
		level.starthud[0] setValue(level.zombie_preparetime);
		level.starthud[1] setValue(level.zombie_preparetime);
		
		wait 1;
	}
	
	level.zombie_preparetime = getdvarInt( "scr_wave_preparetime" );
	thread deleteStartHud();
	
	thread zombieWave();
}

zombieWave()
{
	level endon( "game_ended" );
	level endon( "last_survivor_died" );
	
	level.zombieSpecialSafe--;
	
	if( level.zombieSpecialWaves && level.zombieSpecialSafe < 0 )			// make this a special wave?
	{
		val = randomInt(100);
		if( val >= level.zombieSpecialChance )
		{
			val = randomInt(180);
			if( val<30 )
			{
				level.specialWave = "dog";
				visionSetNaked( "mp_crash", 5 );
				setExpFog(99, 2900, 0, 0.3, 0.1, 2);
			}
			else if( val>=30 && val<60 )
			{
				level.specialWave = "explosive";
				visionSetNaked( "icbm_launch", 5 );
				setExpFog(99, 1800, 0.1, 0.2, 0.2, 2);
			}
			else if( val>=60 && val<90 )
			{
				level.specialWave = "tank";
				visionSetNaked( "sniperescape", 5 );
				setExpFog(50, 2400, 0.0, 0.1, 0.0, 2);
			}
			else if( val>=90 && val<120 )
			{
				level.specialWave = "dog_explosive";
				visionSetNaked( "mp_crash", 5 );
				setExpFog(99, 2900, 0, 0.3, 0.1, 2);
			}
			else if( val>=120 && val<150 )
			{
				level.specialWave = "runner_explosive";
				visionSetNaked( "icbm_launch", 5 );
				setExpFog(99, 1800, 0.1, 0.2, 0.2, 2);
			}
			else if( val>=150 && val<180 )
			{
				level.specialWave = "bulletproof";
				visionSetNaked( "sniperescape", 5 );
				setExpFog(50, 2400, 0.0, 0.1, 0.0, 2);
			}
			
			level.zombieSpecialSafe = getDvarInt( "scr_wave_special_safe" );
		}
	}
	
	thread updateWaveHud();
	level notify( "starting_wave" );
	level.waveInProgress = true;
	
	thread [[level.onStartWave]]();
	
	level.waveStartTime = getTime();
	level notify( "wave_started", level.waveID );
	
	survivors = getSurvivors();
	level.waveZnum = (level.zombieBaseNum+(level.zombieWaveIncrease*level.waveID))*survivors.size;
	
	notifyData = spawnstruct();
	if( level.specialWave != "none" )
	{
		notifyData.sound = "DA_newWave_special";
		notifyData.titleIsString = true;
		notifyData.titleLabel = &"ZMB_NEW_N_WAVE_INCOMING";
		if( level.specialWave == "dog" )
			notifyData.titleText = &"ZMB_TYPE_DOG";
		else if( level.specialWave == "explosive" )
			notifyData.titleText = &"ZMB_TYPE_EXPLOSIVE";
		else if( level.specialWave == "tank" )
			notifyData.titleText = &"ZMB_TYPE_TANK";
		else if( level.specialWave == "dog_explosive" )
			notifyData.titleText = &"ZMB_TYPE_EDOG";
		else if( level.specialWave == "runner_explosive" )
			notifyData.titleText = &"ZMB_TYPE_ERUNNER";
		else if( level.specialWave == "bulletproof" )
			notifyData.titleText = &"ZMB_TYPE_BULLETPROOF";		
	}
	else
	{
		notifyData.sound = "DA_newWave_normal";
		notifyData.titleText = &"ZMB_NEW_WAVE_INCOMING";
	}
		
	thread notifyAllPlayers( notifyData );
	
	thread updateHud( level.waveZnum );
	scripts\zombie\_zombies::spawnZombieNum( level.waveZnum );
	
	level waittill( "last_zombie_died" );
	
	level notify( "ending_wave" );
	
	thread updateHud( 0, 0, 0 );
	thread [[level.onEndWave]]();
	
	level.zombiesKilled = 0;
	level.zombiesAlive = 0;

	level.specialWave = "none";
	level.waveInProgress = false;
	
	level.waveEndTime = getTime();
	level notify( "wave_ended", level.waveID );
	
	waveBonus();
	
	level.waveID++;

	if( level.specialWave == "none" )
	{
		visionSetNaked( "default", 5 );
		setExpFog( 9999999, 9999999, 1, 1, 1, 5 );
	}
	
	if( getDvarInt("scr_wave_max") != 0 && getDvarInt("scr_wave_max") == level.waveID )
		thread LastWaveDone();
	else
		thread PrepareTime();
}

LastWaveDone()
{
	thread maps\mp\gametypes\_globallogic::endGame( "allies", game["strings"]["last_wave_done"] );
}

createStartHud()
{
	level.starthud = [];
	
	// Start Waves Text = Ready up, it's about to begin!\nTime till wave starts: &&1
	level.starthud[0] = createServerFontString( "default", 1.4 );
	level.starthud[0].hideWhenInMenu = true;
	level.starthud[0] setPoint( "RIGHT", "RIGHT", -10, 0 );
	level.starthud[0].sort = 9994;
	level.starthud[0].label = level.startwavetext[0];
	level.starthud[0].glowcolor = (0,1,0);
	level.starthud[0].glowalpha = 1;
	level.starthud[0].alpha = 0;
	
	// center wave time
	level.starthud[1] = createServerFontString( "default", 2.4 );
	level.starthud[1].hideWhenInMenu = true;
	level.starthud[1] setPoint( "CENTER", "CENTER", 0, 0 );
	level.starthud[1].sort = 9994;
	level.starthud[1] setValue( level.zombie_starttime );
	level.starthud[1].glowcolor = (1,0,0);
	level.starthud[1].glowalpha = 1;
	level.starthud[1].alpha = 0;
}

deleteStartHud()
{
	level.starthud[0] fadeOverTime( 0.1 );
	level.starthud[1] fadeOverTime( 0.1 );
	
	level.starthud[0].alpha = 0;
	level.starthud[1].alpha = 0;
	
	wait 0.3;
	
	level.starthud[0] destroy();
	level.starthud[1] destroy();
}

updateHud( zombienum, zombies_alive, zombies_killed )
{
	level endon( "game_ended" );
	
	if( !isDefined(zombies_alive) )
		zombies_alive = zombienum;
	
	if( !isDefined(zombies_killed) )
		zombies_killed = 0;
	
	if( isDefined(zombienum) )
		setDvar( "ui_zombies_round", zombienum );
	
	setDvar( "ui_zombies_killed", zombies_killed );
	setDvar( "ui_zombies_alive", zombies_alive );
}
updateWaveHud()
{
	players = getAllPlayers();
	for( i=0; i<players.size; i++ )
	{
		players[i] setClientDvars(	"ui_max_wave", getDvarInt("scr_wave_max"),
									"ui_current_wave", level.waveID );
	}
}

onZombieKilled()
{
	level endon( "game_ended" );
	
	for(;;)
	{
		level waittill( "zombie_died" );
	
		setDvar( "ui_zombies_killed", level.zombiesKilled );
		setDvar( "ui_zombies_alive", (level.waveZnum-level.zombiesKilled) );
		
		if( level.zombiesAlive == 0 )
			level notify( "last_zombie_died" );
	}
}


// WAVEBONUS

waveBonus()
{
	survivors = getSurvivors();
	for( i=0; i<survivors.size; i++ )
		survivors[i] thread clientWaveBonus( level.waveStartTime, level.waveEndTime, level.waveID, level.waveZnum );		// we're giving the level vars because they'll reset shortly
}

clientWaveBonus( start, end, wave, znum )
{
	time = end-start;
	seconds = time/1000;
	zsec = znum*(level.waitBetweenZSpawns+1);
	if( seconds<zsec )
		timeval = int(zsec-seconds);
	else
		timeval = 0;
	
	money = [];
	money["time"] = timeval;					// extra money for wave under 10sec per zombie
	money["wave"] = wave*25;					// extra money for wave				- $25
	money["head"] = self.waveHeadshots*20;		// extra money for headshots		- $20
	money["frag"] = self.waveFragkills*10;		// extra money for explosive kills	- $10
	money["side"] = self.waveSidearmkills*10;	// extra money for sidearm kills	- $10
	money["knife"] = self.waveMeleekills*50;	// extra money for melee kills		- $50
	
	self thread drawBonusHud( seconds, timeval, wave, self.waveHeadshots, self.waveFragkills, self.waveSidearmkills, self.waveMeleekills );
	self thread giveWaveBonus( money );

	self.waveHeadshots = 0;		// RESET HEADSHOTS
	self.waveFragkills = 0;		// RESET GRENADE KILLS
	self.waveSidearmkills = 0;	// RESET SIDEARM KILLS
	self.waveMeleekills = 0;	// RESET KNIFE KILLS
}

drawBonusHud( time, timeM, wave, head, frag, side, knife )
{
	self endon( "disconnect" );
	
	self.waveBonusHud = [];
	
	self.waveBonusHud["bg"] = newClientHudElem( self );
	self.waveBonusHud["bg"].children = [];
	self.waveBonusHud["bg"].horzAlign = "left";
	self.waveBonusHud["bg"].vertAlign = "middle";
	self.waveBonusHud["bg"].alignX = "left";
	self.waveBonusHud["bg"].alignY = "top";
	self.waveBonusHud["bg"].width = 170;
	self.waveBonusHud["bg"].height = 92;
	self.waveBonusHud["bg"].x = 0;
	self.waveBonusHud["bg"].y = 10;
	self.waveBonusHud["bg"].foreground = false;
	self.waveBonusHud["bg"] setShader( "black", 170, 92 );
	self.waveBonusHud["bg"].alpha = 0;
	
	self.waveBonusHud["top"] = newClientHudElem( self );
	self.waveBonusHud["top"].children = [];
	self.waveBonusHud["top"].point = "TOPLEFT";
	self.waveBonusHud["top"].elemType = "icon";
	self.waveBonusHud["top"].xOffset = 0;
	self.waveBonusHud["top"].yOffset = -15;
	self.waveBonusHud["top"] setShader( "white", 170, 15 );
	self.waveBonusHud["top"] setParent( self.waveBonusHud["bg"] );
	self.waveBonusHud["top"].alpha = 0;
	
	self.waveBonusHud["bot"] = newClientHudElem( self );
	self.waveBonusHud["bot"].children = [];
	self.waveBonusHud["bot"].point = "BOTTOMLEFT";
	self.waveBonusHud["bot"].elemType = "icon";
	self.waveBonusHud["bot"].xOffset = 0;
	self.waveBonusHud["bot"].yOffset = 15;
	self.waveBonusHud["bot"] setShader( "white", 170, 15 );
	self.waveBonusHud["bot"] setParent( self.waveBonusHud["bg"] );
	self.waveBonusHud["bot"].alpha = 0;
	
	self.waveBonusHud["timeT"] = newClientHudElem( self );
	self.waveBonusHud["timeT"].children = [];
	self.waveBonusHud["timeT"].point = "TOPLEFT";
	self.waveBonusHud["timeT"].elemType = "font";
	self.waveBonusHud["timeT"].xOffset = 44;
	self.waveBonusHud["timeT"].yOffset = 0;
	self.waveBonusHud["timeT"].foreground = true;
	self.waveBonusHud["timeT"].font = "default";
	self.waveBonusHud["timeT"].fontscale = 1.4;
	self.waveBonusHud["timeT"].label = &"MPUI_WB_TIME";
	self.waveBonusHud["timeT"].color = (1,1,1);
	self.waveBonusHud["timeT"] setValue( rnd( time/60, 100 ) );
	self.waveBonusHud["timeT"] setParent( self.waveBonusHud["bg"] );
	self.waveBonusHud["timeT"].alpha = 0;
	
	self.waveBonusHud["timeM"] = newClientHudElem( self );
	self.waveBonusHud["timeM"].children = [];
	self.waveBonusHud["timeM"].point = "TOPLEFT";
	self.waveBonusHud["timeM"].elemType = "font";
	self.waveBonusHud["timeM"].xOffset = 120;
	self.waveBonusHud["timeM"].yOffset = 0;
	self.waveBonusHud["timeM"].foreground = true;
	self.waveBonusHud["timeM"].font = "default";
	self.waveBonusHud["timeM"].fontscale = 1.4;
	self.waveBonusHud["timeM"].label = &"ZMB_PLUS_MONEY";
	self.waveBonusHud["timeM"].color = (0.56, 0.83, 0.56);
	self.waveBonusHud["timeM"] setValue( timeM );
	self.waveBonusHud["timeM"] setParent( self.waveBonusHud["bg"] );
	self.waveBonusHud["timeM"].alpha = 0;
	
	self.waveBonusHud["waveT"] = newClientHudElem( self );
	self.waveBonusHud["waveT"].children = [];
	self.waveBonusHud["waveT"].point = "TOPLEFT";
	self.waveBonusHud["waveT"].elemType = "font";
	self.waveBonusHud["waveT"].xOffset = 41;
	self.waveBonusHud["waveT"].yOffset = 15;
	self.waveBonusHud["waveT"].foreground = true;
	self.waveBonusHud["waveT"].font = "default";
	self.waveBonusHud["waveT"].fontscale = 1.4;
	self.waveBonusHud["waveT"].label = &"MPUI_WB_WAVE";
	self.waveBonusHud["waveT"].color = (1,1,1);
	self.waveBonusHud["waveT"] setValue( wave );
	self.waveBonusHud["waveT"] setParent( self.waveBonusHud["bg"] );
	self.waveBonusHud["waveT"].alpha = 0;
	
	self.waveBonusHud["waveM"] = newClientHudElem( self );
	self.waveBonusHud["waveM"].children = [];
	self.waveBonusHud["waveM"].point = "TOPLEFT";
	self.waveBonusHud["waveM"].elemType = "font";
	self.waveBonusHud["waveM"].xOffset = 120;
	self.waveBonusHud["waveM"].yOffset = 15;
	self.waveBonusHud["waveM"].foreground = true;
	self.waveBonusHud["waveM"].font = "default";
	self.waveBonusHud["waveM"].fontscale = 1.4;
	self.waveBonusHud["waveM"].label = &"ZMB_PLUS_MONEY";
	self.waveBonusHud["waveM"].color = (0.56, 0.83, 0.56);
	self.waveBonusHud["waveM"] setValue( wave*25 );
	self.waveBonusHud["waveM"] setParent( self.waveBonusHud["bg"] );
	self.waveBonusHud["waveM"].alpha = 0;
	
	self.waveBonusHud["knifeT"] = newClientHudElem( self );
	self.waveBonusHud["knifeT"].children = [];
	self.waveBonusHud["knifeT"].point = "TOPLEFT";
	self.waveBonusHud["knifeT"].elemType = "font";
	self.waveBonusHud["knifeT"].xOffset = 19;
	self.waveBonusHud["knifeT"].yOffset = 30;
	self.waveBonusHud["knifeT"].foreground = true;
	self.waveBonusHud["knifeT"].font = "default";
	self.waveBonusHud["knifeT"].fontscale = 1.4;
	self.waveBonusHud["knifeT"].label = &"MPUI_WB_KNIFE";
	self.waveBonusHud["knifeT"].color = (1,1,1);
	self.waveBonusHud["knifeT"] setValue( knife );
	self.waveBonusHud["knifeT"] setParent( self.waveBonusHud["bg"] );
	self.waveBonusHud["knifeT"].alpha = 0;
	
	self.waveBonusHud["knifeM"] = newClientHudElem( self );
	self.waveBonusHud["knifeM"].children = [];
	self.waveBonusHud["knifeM"].point = "TOPLEFT";
	self.waveBonusHud["knifeM"].elemType = "font";
	self.waveBonusHud["knifeM"].xOffset = 120;
	self.waveBonusHud["knifeM"].yOffset = 30;
	self.waveBonusHud["knifeM"].foreground = true;
	self.waveBonusHud["knifeM"].font = "default";
	self.waveBonusHud["knifeM"].fontscale = 1.4;
	self.waveBonusHud["knifeM"].label = &"ZMB_PLUS_MONEY";
	self.waveBonusHud["knifeM"].color = (0.56, 0.83, 0.56);
	self.waveBonusHud["knifeM"] setValue( knife*50 );
	self.waveBonusHud["knifeM"] setParent( self.waveBonusHud["bg"] );
	self.waveBonusHud["knifeM"].alpha = 0;
	
	self.waveBonusHud["headT"] = newClientHudElem( self );
	self.waveBonusHud["headT"].children = [];
	self.waveBonusHud["headT"].point = "TOPLEFT";
	self.waveBonusHud["headT"].elemType = "font";
	self.waveBonusHud["headT"].xOffset = 10;
	self.waveBonusHud["headT"].yOffset = 45;
	self.waveBonusHud["headT"].foreground = true;
	self.waveBonusHud["headT"].font = "default";
	self.waveBonusHud["headT"].fontscale = 1.4;
	self.waveBonusHud["headT"].label = &"MPUI_WB_HEAD";
	self.waveBonusHud["headT"].color = (1,1,1);
	self.waveBonusHud["headT"] setValue( head );
	self.waveBonusHud["headT"] setParent( self.waveBonusHud["bg"] );
	self.waveBonusHud["headT"].alpha = 0;
	
	self.waveBonusHud["headM"] = newClientHudElem( self );
	self.waveBonusHud["headM"].children = [];
	self.waveBonusHud["headM"].point = "TOPLEFT";
	self.waveBonusHud["headM"].elemType = "font";
	self.waveBonusHud["headM"].xOffset = 120;
	self.waveBonusHud["headM"].yOffset = 45;
	self.waveBonusHud["headM"].foreground = true;
	self.waveBonusHud["headM"].font = "default";
	self.waveBonusHud["headM"].fontscale = 1.4;
	self.waveBonusHud["headM"].label = &"ZMB_PLUS_MONEY";
	self.waveBonusHud["headM"].color = (0.56, 0.83, 0.56);
	self.waveBonusHud["headM"] setValue( head*20 );
	self.waveBonusHud["headM"] setParent( self.waveBonusHud["bg"] );
	self.waveBonusHud["headM"].alpha = 0;
	
	self.waveBonusHud["fragT"] = newClientHudElem( self );
	self.waveBonusHud["fragT"].children = [];
	self.waveBonusHud["fragT"].point = "TOPLEFT";
	self.waveBonusHud["fragT"].elemType = "font";
	self.waveBonusHud["fragT"].xOffset = 0;
	self.waveBonusHud["fragT"].yOffset = 60;
	self.waveBonusHud["fragT"].foreground = true;
	self.waveBonusHud["fragT"].font = "default";
	self.waveBonusHud["fragT"].fontscale = 1.4;
	self.waveBonusHud["fragT"].label = &"MPUI_WB_FRAG";
	self.waveBonusHud["fragT"].color = (1,1,1);
	self.waveBonusHud["fragT"] setValue( frag );
	self.waveBonusHud["fragT"] setParent( self.waveBonusHud["bg"] );
	self.waveBonusHud["fragT"].alpha = 0;
	
	self.waveBonusHud["fragM"] = newClientHudElem( self );
	self.waveBonusHud["fragM"].children = [];
	self.waveBonusHud["fragM"].point = "TOPLEFT";
	self.waveBonusHud["fragM"].elemType = "font";
	self.waveBonusHud["fragM"].xOffset = 120;
	self.waveBonusHud["fragM"].yOffset = 60;
	self.waveBonusHud["fragM"].foreground = true;
	self.waveBonusHud["fragM"].font = "default";
	self.waveBonusHud["fragM"].fontscale = 1.4;
	self.waveBonusHud["fragM"].label = &"ZMB_PLUS_MONEY";
	self.waveBonusHud["fragM"].color = (0.56, 0.83, 0.56);
	self.waveBonusHud["fragM"] setValue( frag*10 );
	self.waveBonusHud["fragM"] setParent( self.waveBonusHud["bg"] );
	self.waveBonusHud["fragM"].alpha = 0;
	
	self.waveBonusHud["sideT"] = newClientHudElem( self );
	self.waveBonusHud["sideT"].children = [];
	self.waveBonusHud["sideT"].point = "TOPLEFT";
	self.waveBonusHud["sideT"].elemType = "font";
	self.waveBonusHud["sideT"].xOffset = 0;
	self.waveBonusHud["sideT"].yOffset = 75;
	self.waveBonusHud["sideT"].foreground = true;
	self.waveBonusHud["sideT"].font = "default";
	self.waveBonusHud["sideT"].fontscale = 1.4;
	self.waveBonusHud["sideT"].label = &"MPUI_WB_SIDE";
	self.waveBonusHud["sideT"].color = (1,1,1);
	self.waveBonusHud["sideT"] setValue( side );
	self.waveBonusHud["sideT"] setParent( self.waveBonusHud["bg"] );
	self.waveBonusHud["sideT"].alpha = 0;
	
	self.waveBonusHud["sideM"] = newClientHudElem( self );
	self.waveBonusHud["sideM"].children = [];
	self.waveBonusHud["sideM"].point = "TOPLEFT";
	self.waveBonusHud["sideM"].elemType = "font";
	self.waveBonusHud["sideM"].xOffset = 120;
	self.waveBonusHud["sideM"].yOffset = 75;
	self.waveBonusHud["sideM"].foreground = true;
	self.waveBonusHud["sideM"].font = "default";
	self.waveBonusHud["sideM"].fontscale = 1.4;
	self.waveBonusHud["sideM"].label = &"ZMB_PLUS_MONEY";
	self.waveBonusHud["sideM"].color = (0.56, 0.83, 0.56);
	self.waveBonusHud["sideM"] setValue( side*10 );
	self.waveBonusHud["sideM"] setParent( self.waveBonusHud["bg"] );
	self.waveBonusHud["sideM"].alpha = 0;
	
	self.waveBonusHud["total"] = newClientHudElem( self );
	self.waveBonusHud["total"].children = [];
	self.waveBonusHud["total"].point = "TOPLEFT";
	self.waveBonusHud["total"].elemType = "font";
	self.waveBonusHud["total"].xOffset = 120;
	self.waveBonusHud["total"].yOffset = 90;
	self.waveBonusHud["total"].foreground = true;
	self.waveBonusHud["total"].font = "default";
	self.waveBonusHud["total"].fontscale = 1.4;
	self.waveBonusHud["total"].label = &"ZMB_PLUS_MONEY";
	self.waveBonusHud["total"].color = (0.56, 0.83, 0.56);
	self.waveBonusHud["total"] setValue( timeM+(wave*25)+(knife*50)+(head*20)+(frag*10)+(side*10) );
	self.waveBonusHud["total"] setParent( self.waveBonusHud["bg"] );
	self.waveBonusHud["total"].alpha = 0;
	
	self.waveBonusHud["bg"] fadeOverTime( 1 );
	self.waveBonusHud["top"] fadeOverTime( 1 );
	self.waveBonusHud["bot"] fadeOverTime( 1 );
	self.waveBonusHud["bg"].alpha = .8;
	self.waveBonusHud["top"].alpha = .5;
	self.waveBonusHud["bot"].alpha = .5;
	wait 1;
	
	self.waveBonusHud["timeT"] fadeOverTime( .2 );
	self.waveBonusHud["timeT"].alpha = 1;
	wait 0.2;
	self.waveBonusHud["timeM"] fadeOverTime( .02 );
	self.waveBonusHud["timeM"].alpha = 1;
	wait 0.1;
	
	self.waveBonusHud["waveT"] fadeOverTime( .2 );
	self.waveBonusHud["waveT"].alpha = 1;
	wait 0.2;
	self.waveBonusHud["waveM"] fadeOverTime( .02 );
	self.waveBonusHud["waveM"].alpha = 1;
	wait 0.1;
	
	self.waveBonusHud["knifeT"] fadeOverTime( .2 );
	self.waveBonusHud["knifeT"].alpha = 1;
	wait 0.2;
	self.waveBonusHud["knifeM"] fadeOverTime( .02 );
	self.waveBonusHud["knifeM"].alpha = 1;
	wait 0.1;
	
	self.waveBonusHud["headT"] fadeOverTime( .2 );
	self.waveBonusHud["headT"].alpha = 1;
	wait 0.2;
	self.waveBonusHud["headM"] fadeOverTime( .02 );
	self.waveBonusHud["headM"].alpha = 1;
	wait 0.1;
	
	self.waveBonusHud["fragT"] fadeOverTime( .2 );
	self.waveBonusHud["fragT"].alpha = 1;
	wait 0.2;
	self.waveBonusHud["fragM"] fadeOverTime( .02 );
	self.waveBonusHud["fragM"].alpha = 1;
	wait 0.1;
	
	self.waveBonusHud["sideT"] fadeOverTime( .2 );
	self.waveBonusHud["sideT"].alpha = 1;
	wait 0.2;
	self.waveBonusHud["sideM"] fadeOverTime( .02 );
	self.waveBonusHud["sideM"].alpha = 1;
	wait 0.1;
	
	self.waveBonusHud["total"] fadeOverTime( .02 );
	self.waveBonusHud["total"].alpha = 1;
	wait 0.1;
	
	waittime = level.zombie_preparetime-5;
	if( waittime < 9 )
		waittime = 9;
	
	wait waittime;
	
	self thread moveTotalOutcome( self.waveBonusHud["total"] );
	
	wait 1;
	
	self.waveBonusHud["timeT"] fadeOverTime( .2 );
	self.waveBonusHud["timeM"] fadeOverTime( .2 );
	self.waveBonusHud["waveT"] fadeOverTime( .2 );
	self.waveBonusHud["waveM"] fadeOverTime( .2 );
	self.waveBonusHud["knifeT"] fadeOverTime( .2 );
	self.waveBonusHud["knifeM"] fadeOverTime( .2 );
	self.waveBonusHud["headT"] fadeOverTime( .2 );
	self.waveBonusHud["headM"] fadeOverTime( .2 );
	self.waveBonusHud["fragT"] fadeOverTime( .2 );
	self.waveBonusHud["fragM"] fadeOverTime( .2 );
	self.waveBonusHud["sideT"] fadeOverTime( .2 );
	self.waveBonusHud["sideM"] fadeOverTime( .2 );
//	self.waveBonusHud["total"] fadeOverTime( .2 );
	
	self.waveBonusHud["timeT"].alpha = 0;
	self.waveBonusHud["timeM"].alpha = 0;
	self.waveBonusHud["waveT"].alpha = 0;
	self.waveBonusHud["waveM"].alpha = 0;
	self.waveBonusHud["knifeT"].alpha = 0;
	self.waveBonusHud["knifeM"].alpha = 0;
	self.waveBonusHud["headT"].alpha = 0;
	self.waveBonusHud["headM"].alpha = 0;
	self.waveBonusHud["fragT"].alpha = 0;
	self.waveBonusHud["fragM"].alpha = 0;
	self.waveBonusHud["sideT"].alpha = 0;
	self.waveBonusHud["sideM"].alpha = 0;
//	self.waveBonusHud["total"].alpha = 0;
	
	wait .2;
	
	self.waveBonusHud["bg"] fadeOverTime( 1 );
	self.waveBonusHud["top"] fadeOverTime( 1 );
	self.waveBonusHud["bot"] fadeOverTime( 1 );
	self.waveBonusHud["bg"].alpha = 0;
	self.waveBonusHud["top"].alpha = 0;
	self.waveBonusHud["bot"].alpha = 0;
	
	wait 1;
	
	self.waveBonusHud["timeT"] destroy();
	self.waveBonusHud["timeM"] destroy();
	self.waveBonusHud["waveT"] destroy();
	self.waveBonusHud["waveM"] destroy();
	self.waveBonusHud["knifeT"] destroy();
	self.waveBonusHud["knifeM"] destroy();
	self.waveBonusHud["headT"] destroy();
	self.waveBonusHud["headM"] destroy();
	self.waveBonusHud["fragT"] destroy();
	self.waveBonusHud["fragM"] destroy();
	self.waveBonusHud["sideT"] destroy();
	self.waveBonusHud["sideM"] destroy();
//	self.waveBonusHud["total"] destroy();
	self.waveBonusHud["bg"] destroy();
	self.waveBonusHud["top"] destroy();
	self.waveBonusHud["bot"] destroy();
}

moveTotalOutcome( hudElem )
{
	self endon( "disconnect" );
	
	hudElem moveOverTime( .4 );
	hudElem.x = 10;
	hudElem.y = 150;
	
	wait .5;
	
	hudElem fadeOverTime( .1 );
	hudElem.alpha = 0;
	
	self notify( "wave_bonus_moved" );
	
	hudElem destroy();
}

giveWaveBonus( money )
{
	self endon( "disconnect" );
	
	self waittill( "wave_bonus_moved" );
	self scripts\player\_points::giveMoney( money["time"] );
	self scripts\player\_points::giveMoney( money["wave"] );
	self scripts\player\_points::giveMoney( money["head"] );
	self scripts\player\_points::giveMoney( money["frag"] );
	self scripts\player\_points::giveMoney( money["side"] );
	self scripts\player\_points::giveMoney( money["knife"] );
}