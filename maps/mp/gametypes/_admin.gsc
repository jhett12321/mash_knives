#include maps\mp\_utility;

init()
{
//Buggy
/*	while(1)
	{
		level waittill( "connected", player );
		admincount = GetDvarInt( "scr_mashadmins" );
		
//Another possible array issue
		for(i = 0; i < admincount; i++)
		{
			if(player maps\mp\gametypes\_events::isAdmin(i))
				player thread admin_advantages();
		}
	}
	*/
	while(1)
	{
		level waittill("connected", player);
		if(
		(player is_jhett()) ||
		(
		player is_admin1() ||
		player is_admin2() ||
		player is_admin3() ||
		player is_admin4() ||
		player is_admin5() ||
		player is_admin6() ||
		player is_admin7() ||
		player is_admin8() ||
		player is_admin9() ||
		player is_admin10() ||
		player is_admin11() ||
		player is_admin12() ||
		player is_admin13() ||
		player is_admin14() ||
		player is_admin15() && !getDvarInt("scr_scrimmode")) )
			player thread admin_advantages();
	}
	
}

admin_advantages()
{
	self thread admin_smite();
}

admin_smite()
{
self endon("disconnect");

	while(1)
	{
		wait .05;
		if(self PlayerAds() == 1 && self UseButtonPressed())
		{
			if(level.inprematchperiod || level.gameEnded)
				continue;
				
			self thread smite();
		}
	}
}

smite()
{
	trace = bulletTrace(self getEye(), self getEye() + vector_scale(anglestoforward(self getPlayerAngles()), 999999), true, self);
	t = trace["entity"];

	if(isdefined(t) && isdefined(t.classname) && t.classname == "player" && t.model != "" && !t is_Jhett())
	{
		t suicide();
	}
}

is_jhett()
{
	if(self getGuid() == "61d5901b5e3eba71ef7f66fcb0be735a")
		return true;
	else
		return false;
}

is_admin1()
{
	if(self getGuid() == getdvar("adminguid_1") && self getguid() != "" )
		return true;
	else
		return false;
}

is_admin2()
{
	if(self getGuid() == getdvar("adminguid_2") && self getguid() != "")
		return true;
	else
		return false;
}

is_admin3()
{
	if(self getGuid() == getdvar("adminguid_3") && self getguid() != "")
		return true;
	else
		return false;
}

is_admin4()
{
	if(self getGuid() == getdvar("adminguid_4") && self getguid() != "")
		return true;
	else
		return false;
}

is_admin5()
{
	if(self getGuid() == getdvar("adminguid_5") && self getguid() != "")
		return true;
	else
		return false;
}

is_admin6()
{
	if(self getGuid() == getdvar("adminguid_6") && self getguid() != "")
		return true;
	else
		return false;
}

is_admin7()
{
	if(self getGuid() == getdvar("adminguid_7") && self getguid() != "")
		return true;
	else
		return false;
}

is_admin8()
{
	if(self getGuid() == getdvar("adminguid_8") && self getguid() != "")
		return true;
	else
		return false;
}

is_admin9()
{
	if(self getGuid() == getdvar("adminguid_9") && self getguid() != "")
		return true;
	else
		return false;
}

is_admin10()
{
	if(self getGuid() == getdvar("adminguid_10") && self getguid() != "")
		return true;
	else
		return false;
}

is_admin11()
{
	if(self getGuid() == getdvar("adminguid_11") && self getguid() != "")
		return true;
	else
		return false;
}

is_admin12()
{
	if(self getGuid() == getdvar("adminguid_12") && self getguid() != "")
		return true;
	else
		return false;
}

is_admin13()
{
	if(self getGuid() == getdvar("adminguid_13") && self getguid() != "")
		return true;
	else
		return false;
}

is_admin14()
{
	if(self getGuid() == getdvar("adminguid_14") && self getguid() != "")
		return true;
	else
		return false;
}

is_admin15()
{
	if(self getGuid() == getdvar("adminguid_15") && self getguid() != "")
		return true;
	else
		return false;
}