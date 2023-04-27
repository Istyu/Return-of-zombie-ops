/*=======================================================================================
Return of the Zombie Ops - Mod
Modded by Lefti & 3aGl3
=========================================================================================
Armor general
=======================================================================================*/
#include scripts\_utility;

init()
{
	precacheString( &"ZMB_ARMOR_ADDED" );
	precacheString( &"ZMB_YOUR_ARMOR_WORN_OFF" );
												// threshold & health, health based on 100 normal player health
	level.armor_level[0] = "armor_none";		// 0 th. & 0 h.
	level.armor_level[1] = "armor_xlight";		// 1 th. & 0 h.
	level.armor_level[2] = "armor_light";		// 1 th. & 10 h.
	level.armor_level[3] = "armor_medium";		// 5 th. & 40 h.
	level.armor_level[4] = "armor_heavy";		// 5 th. & 20 h.
	level.armor_level[5] = "armor_xheavy";		// 10 th. & 25 h.
	level.armor_level[6] = "armor_xtreme";		// 10 th. & 50 h.
	
	level.armorHealthUsage = xDvarBool( "scr_allow_armorhealth", 1 );
	level.armorMultiUsage = xDvarBool( "scr_allow_damagethreshold", 1 );
}

addArmor( armor )
{
	if( !isDefined(self.armor_threshold) )				// damage multipler
		self.armor_threshold = 1;
		
	if( !isDefined(self.armor_health) )					// not regainable armor health
		self.armor_health = 0;
	
	if( armor == "armor_none" )
		return;
	
	healthmulti = level.playerBaseHealth/100;
	
	switch( armor )
	{
		case "armor_xlight":
			self.armor_threshold = 0.99;				// percent of damage that you still got as float (99% in this case)
			//self.armor_health += (0*healthmulti);
			break;
		case "armor_light":
			self.armor_threshold = 0.99;
			self.armor_health += (10*healthmulti);
			break;
		case "armor_medium":
			self.armor_threshold = 0.98;
			self.armor_health += (10*healthmulti);
			break;
		case "armor_heavy":
			self.armor_threshold = 0.95;
			self.armor_health += (20*healthmulti);
			break;
		case "armor_xheavy":
			self.armor_threshold = 0.90;
			self.armor_health += (25*healthmulti);
			break;
		case "armor_xtreme":
			self.armor_threshold = 0.90;
			self.armor_health += (50*healthmulti);
			break;
	}
	
	if( level.armorHealthUsage == false )
		self.armor_health = 0;
		
	if( level.armorMultiUsage == false )
		self.armor_threshold = 1;
	
	//if( level.armorHealthUsage || level.armorMultiUsage )
		//self iPrintLn( &"ZMB_ARMOR_ADDED", (1-self.armor_threshold)*100, self.armor_health );
}

setArmor( armor )
{
	if( !isDefined(self.armor_threshold) )				// damage multipler
		self.armor_threshold = 1;
		
	if( !isDefined(self.armor_health) )					// not regainable armor health
		self.armor_health = 0;
	
	healthmulti = level.playerBaseHealth/100;
	
	switch( armor )
	{
		case "armor_none":
			self.armor_threshold = 1;
			self.armor_health = 0;
			break;
		case "armor_xlight":
			self.armor_threshold = 0.99;				// percent of damage that you still got as float (99% in this case)
			self.armor_health = 0;
			break;
		case "armor_light":
			self.armor_threshold = 0.99;
			self.armor_health = (10*healthmulti);
			break;
		case "armor_medium":
			self.armor_threshold = 0.98;
			self.armor_health = (10*healthmulti);
			break;
		case "armor_heavy":
			self.armor_threshold = 0.95;
			self.armor_health = (20*healthmulti);
			break;
		case "armor_xheavy":
			self.armor_threshold = 0.90;
			self.armor_health = (25*healthmulti);
			break;
		case "armor_xtreme":
			self.armor_threshold = 0.90;
			self.armor_health = (50*healthmulti);
			break;
	}
	
	if( level.armorHealthUsage == false )
		self.armor_health = 0;
		
	if( level.armorMultiUsage == false )
		self.armor_threshold = 1;
	
	if( level.armorHealthUsage || level.armorMultiUsage )
		self iPrintLn( &"ZMB_ARMOR_ADDED", (1-self.armor_threshold)*100, self.armor_health );
}