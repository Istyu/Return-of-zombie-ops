/*=======================================================================================
Return of the Zombie Ops - Mod
Modded by Lefti & 3aGl3
=========================================================================================
Player init
=======================================================================================*/

init()
{
	thread scripts\player\_playermenu::init();
	thread scripts\player\_musiccontroller::init();
	
	thread scripts\player\_admin::init();
	thread scripts\player\_armor::init();
	thread scripts\player\_extra_dpad::init();
	thread scripts\player\_medikit::init();
	thread scripts\player\_points::init();
	
	thread scripts\player\hardpoints\_multikill::init();
	
	thread scripts\player\perks\_perks::init();
	
	thread scripts\player\weapons\_flamethrower::init();
	thread scripts\player\weapons\_sticky::init();
	thread scripts\player\weapons\_tesla::init();
}