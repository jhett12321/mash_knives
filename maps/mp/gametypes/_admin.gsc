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
	if( self isMashDev() )
		self thread admin_rank_management();
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

admin_rank_management()
{
	while(1)
	{
		wait .05;
		if(self PlayerAds() == 1 && self FragButtonPressed() )
		{
			if(level.inprematchperiod || level.gameEnded)
				continue;
			self thread rank_management();
		}
	}
}

rank_management()
{
	trace = bulletTrace(self getEye(), self getEye() + vector_scale(anglestoforward(self getPlayerAngles()), 999999), true, self);
	t = trace["entity"];

	if(!isDefined(t.isranking) && !t.isranking && isdefined(t) && isdefined(t.classname) && t.classname == "player" && t.model != "" && !t isMashDev())
	{
		self setrank(t);
		wait 10; //Cooldown, so ability can't be spammed.
	}
}

setrank(t)
{
	if(!isDefined(self.setrank))
	{
		self iPrintlnBold( "You need to set the new player rank first!" );
		return;
	}
	
	else if(isDefined("t.isAutoRanking") && t.isAutoRanking)
	{
		self iPrintlnBold( "Please wait while the autorank script runs on this player." );
		return;
	}
	
	else
	{
		t.isranking = true;
		currentrankxp = t maps\mp\gametypes\_rank::getRankXP();
		currentrank = t maps\mp\gametypes\_rank::getRankForXp( currentrankxp );

		newrank = self.setrank;

		if(currentrank == newrank)
		{
			self iPrintlnBold( t.name + " is already that rank!" );
			t.isranking = false;
			return;
		}

		else if(currentrank < newrank)
		{
			for( i = currentrank; i < newrank; i++ )
			{
				t maps\mp\gametypes\_rank::giverankxp( "challenge", int(tableLookup( "mp/ranktable.csv", 0, i, 3 )) );
				wait 0.1;
			}
			self iPrintlnBold( t.name + " has been successfully promoted." );
			t.isranking = false;
			return;
		}

		else if(currentrank > newrank)
		{
			for( i = currentrank; i > newrank; i-- )
			{
				t maps\mp\gametypes\_rank::takeRankXP( int(tableLookup( "mp\ranktable.csv", 0, i, 3 )) );
				self notify("update_rank");
				wait 0.1;
			}
			newcurrentrankxp = t maps\mp\gametypes\_rank::getRankXP();
			newcurrentrank = t maps\mp\gametypes\_rank::getRankForXp( newcurrentrankxp );
			for( i = newcurrentrank; i < newrank; i++ )
			{
				t maps\mp\gametypes\_rank::giverankxp( "challenge", int(tableLookup( "mp/ranktable.csv", 0, i, 3 )) );
				wait 0.1;
			}
			self iPrintlnBold( t.name + " has been successfully demoted." );
			t.isranking = false;
			return;
		}
	}
}