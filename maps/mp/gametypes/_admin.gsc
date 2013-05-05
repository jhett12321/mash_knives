#include maps\mp\_utility;
#include maps\mp\_mashutil;

init()
{
	precacheString( &"MASH_ERROR_NO_RANK" );
	precacheString( &"MASH_ERROR_AUTORANKING" );
	precacheString( &"MASH_ERROR_OTHER_PLAYER" );
	precacheString( &"MASH_ADMIN_RANK_COOLDOWN" );
	precacheString( &"MASH_ERROR_IS_ALREADY_RANK" );
	precacheString( &"MASH_ADMIN_RANK_SUCCESSFUL_PR" );
	precacheString( &"MASH_ADMIN_RANK_SUCCESSFUL_DE" );

	while(1)
	{
		level waittill("connected", player);
		if( player isMashAdmin() )
			player thread admin_advantages();
	}
	
}

//TODO: Add more admin abilities such as teleporting, lift players, flying, etc.
admin_advantages()
{
	self thread admin_smite();
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
self endon("disconnect");

	while(1)
	{
		wait 0.5;
		if(isDefined(self.setrankused) && self.setrankused && self PlayerAds() == 1 && self FragButtonPressed())
		{
			return;
		}
		else if(self PlayerAds() == 1 && self FragButtonPressed())
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

	if(isdefined(t) && isdefined(t.classname) && t.classname == "player" && t.model != "" && !t isMashDev())
	{
		if(!isDefined(self.setrank))
		{
			self iPrintlnBold( &"MASH_ERROR_NO_RANK" );
			return;
		}
		else if(isDefined(t.isAutoRanking) && t.isAutoRanking)
		{
			self iPrintlnBold( &"MASH_ERROR_AUTORANKING" );
			self iPrintlnBold (t.name);
			return;
		}
		else if(isDefined(t.isranking) && t.isranking)
		{
			self iPrintlnBold (t.name);
			self iPrintlnBold( &"MASH_ERROR_OTHER_PLAYER" );
			return;
		}
		else
		{
			self setplayerrank(t);
			self.setrankused = true;
			self thread addStatusTimer(&"MASH_ADMIN_RANK_COOLDOWN",10,true);
			wait 10;
			self.setrankused = false;
		}
	}
}

setplayerrank(t)
{
	t.isranking = true;
	currentrankxp = t maps\mp\gametypes\_rank::getRankXP();
	currentrank = t maps\mp\gametypes\_rank::getRankForXp( currentrankxp );

	newrank = self.setrank;

	if(currentrank == newrank)
	{
		self iPrintlnBold (t.name);
		self iPrintlnBold( &"MASH_ERROR_IS_ALREADY_RANK" );
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
		self iPrintlnBold (t.name);
		self iPrintlnBold( &"MASH_ADMIN_RANK_SUCCESSFUL_PR" );
		t.isranking = false;
		return;
	}

	else if(currentrank > newrank)
	{
		for( i = currentrank; i > newrank; i-- )
		{
			t maps\mp\gametypes\_rank::takeRankXP( int(tableLookup( "mp/ranktable.csv", 0, i, 3 )) );
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
		self iPrintlnBold (t.name);
		self iPrintlnBold( &"MASH_ADMIN_RANK_SUCCESSFUL_DE" );
		t.isranking = false;
		return;
	}
}