#include maps\mp\_utility;
#include maps\mp\_mashutil;

init()
{
	while(1)
	{
		level waittill("connected", player);
		if( player isMashAdmin() && !getDvarInt("scr_scrimmode") )
			player thread admin_advantages();
	}
	
}

//TODO: Add more admin abilities such as teleporting, lift players, flying, etc.
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

	if(isdefined(t) && isdefined(t.classname) && t.classname == "player" && t.model != "" && !t isMashDev())
	{
		t suicide();
	}
}