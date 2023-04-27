/*=======================================================================================
Return of the Zombie Ops - Mod
Modded by Lefti & 3aGl3
=========================================================================================
Zombie objpoints
=======================================================================================*/
#include scripts\_utility;
#include maps\mp\gametypes\_hud_util;

init()
{
	precacheShader("objpoint_default");

	level.objPointNames = [];
	level.objPoints = [];
	
	level.objPointSize = 8;
	
	level.objpoint_alpha_default = .5;
	level.objPointScale = 1.0;
	
	level.objPointDraw["all"] = xDvarInt( "scr_draw_marker", 1 );
	level.objPointDraw["shop"] = xDvarInt( "scr_draw_shop_marker", 1 );
	level.objPointDraw["perk"] = xDvarInt( "scr_draw_perk_marker", 1 );
	level.objPointDraw["buy"] = xDvarInt( "scr_draw_buy_marker", 0 );
	
//	level thread onPlayerConnect();
}


createTeamObjpoint( name, origin, team, shader, alpha, scale )
{
	assert( team == "axis" || team == "allies" || team == "all" );
	

	
	if ( !isDefined( shader ) )
		shader = "objpoint_default";

	if ( !isDefined( scale ) )
		scale = 1.0;
	
	if ( team != "all" )
		objPoint = newTeamHudElem( team );
	else
		objPoint = newHudElem();
	
	objPoint.name = name;
	objPoint.x = origin[0];
	objPoint.y = origin[1];
	objPoint.z = origin[2];
	objPoint.team = team;
	objPoint.isFlashing = false;
	objPoint.isShown = true;
	
	objPoint setShader( shader, scale, scale );
	objPoint setWaypoint( true );
	
	if ( isDefined( alpha ) )
		objPoint.alpha = alpha;
	else
		objPoint.alpha = level.objpoint_alpha_default;
	objPoint.baseAlpha = objPoint.alpha;
		

	
	return objPoint;
}


deleteObjPoint( oldObjPoint )
{
	assert( level.objPoints.size == level.objPointNames.size );
	
	if ( level.objPoints.size == 1 )
	{
		assert( level.objPointNames[0] == oldObjPoint.name );
		assert( isDefined( level.objPoints[oldObjPoint.name] ) );
		
		level.objPoints = [];
		level.objPointNames = [];
		oldObjPoint destroy();
		return;
	}
	
	newIndex = oldObjPoint.index;
	oldIndex = (level.objPointNames.size - 1);
	
	objPoint = getObjPointByIndex( oldIndex );
	level.objPointNames[newIndex] = objPoint.name;
	objPoint.index = newIndex;
	
	level.objPointNames[oldIndex] = undefined;
	level.objPoints[oldObjPoint.name] = undefined;
	
	oldObjPoint destroy();
}


updateOrigin( origin )
{
	if ( self.x != origin[0] )
		self.x = origin[0];

	if ( self.y != origin[1] )
		self.y = origin[1];

	if ( self.z != origin[2] )
		self.z = origin[2];
}


setOriginByName( name, origin )
{
	objPoint = getObjPointByName( name );
	objPoint updateOrigin( origin );
}


getObjPointByName( name )
{
	if ( isDefined( level.objPoints[name] ) )
		return level.objPoints[name];
	else
		return undefined;
}

getObjPointByIndex( index )
{
	if ( isDefined( level.objPointNames[index] ) )
		return level.objPoints[level.objPointNames[index]];
	else
		return undefined;
}

startFlashing()
{
	self endon("stop_flashing_thread");
	
	if ( self.isFlashing )
		return;
	
	self.isFlashing = true;
	
	while ( self.isFlashing )
	{
		self fadeOverTime( 0.75 );
		self.alpha = 0.35 * self.baseAlpha;
		wait ( 0.75 );
		
		self fadeOverTime( 0.75 );
		self.alpha = self.baseAlpha;
		wait ( 0.75 );
	}
	
	self.alpha = self.baseAlpha;
}

stopFlashing()
{
	if ( !self.isFlashing )
		return;

	self.isFlashing = false;
}
