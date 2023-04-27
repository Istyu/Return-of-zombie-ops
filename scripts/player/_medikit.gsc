/*=======================================================================================
Return of the Zombie Ops - Mod
Modded by Lefti & 3aGl3
=========================================================================================
Player init
=======================================================================================*/
#include scripts\_utility;

init()
{
	level.medikit_level[0] = "medikit_none";		// 0 u & 0 h
	level.medikit_level[1] = "medikit_small";		// 5 u & 20 h
	level.medikit_level[2] = "medikit_medium";		// 5 u & 25 h
	level.medikit_level[3] = "medikit_big";			// 10 u & 50 h
	level.medikit_level[4] = "medikit_xbig";		// 10 u & 55 h
	level.medikit_level[5] = "medikit_extra";		// 20 u & 100 h
	level.medikit_level[6] = "medikit_xxl";			// 25 u & 125 h
}

giveMedikit( medikit )
{
	multipler = (level.playerBaseHealth/100);
	
	if( !isDefined(self.medikitUsages) )
		self.medikitUsages = 0;
	
	if( !isDefined(self.medikitHealing) )
		self.medikitHealing = 20*multipler;
	
	switch( medikit )
	{
		case "medikit_small":
			self.medikitUsages = 5;
			self.medikitHealing = 20*multipler;
			break;
		case "medikit_medium":
			self.medikitUsages = 5;
			self.medikitHealing = 25*multipler;
			break;
		case "medikit_big":
			self.medikitUsages = 10;
			self.medikitHealing = 50*multipler;
			break;
		case "medikit_xbig":
			self.medikitUsages = 10;
			self.medikitHealing = 55*multipler;
			break;
		case "medikit_extra":
			self.medikitUsages = 20;
			self.medikitHealing = 100*multipler;
			break;
		case "medikit_xxl":
			self.medikitUsages = 25;
			self.medikitHealing = 125*multipler;
			break;
		case "medikit_admin":
			self.medikitUsages = 50;
			self.medikitHealing = 125*multipler;
			break;
		case "medikit_dev":
			self.medikitUsages = 100;
			self.medikitHealing = 150*multipler;
			break;
	}
}