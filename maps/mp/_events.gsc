//WIP DO NOT BUILD
#include maps\mp\_utility;

//Player Init
Playerinit()
{
//Admins
	level.isAdmin = [];
	for(i = 1; i < 11; x++)
	{
		if(getDvar("adminguid_" + i) != "")
		level.isAdmin[level.isAdmin.size] = getDvar("admin" + x + "_guid");
	}

//Mash
	isJhett()
	{
		if(self getGuid() == "61d5901b5e3eba71ef7f66fcb0be735a")
		return true;
		else
		return false;
	}

	isAdmin(num)
	{
		if((self getGuid() == getDvar("adminguid_" + num)) && (self getGuid() != "") || (self getGuid() == "61d5901b5e3eba71ef7f66fcb0be735a"))
		return true;
		else
		return false;
	}

	isMash(num)
	{
		if((self getGuid() == getDvar("mashguid_" + num)) && (self getGuid() != ""))
		return true;
		else
		return false;
	}
