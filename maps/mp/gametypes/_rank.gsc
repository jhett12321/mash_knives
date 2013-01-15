#include maps\mp\_utility;
#include common_scripts\utility;
#include maps\mp\gametypes\_hud_util;

init()
{
	level.scoreInfo = [];
	level.rankTable = [];

	precacheShader("white");
	precacheShader("55");
	precacheShader("56");
	precacheShader("57");
	precacheShader("58");
	precacheShader("59");
	precacheShader("60");
	precacheShader("61");
	precacheShader("62");
	precacheShader("63");
	precacheShader("64");
	precacheShader("65");

	precacheString( &"RANK_PLAYER_WAS_PROMOTED_N" );
	precacheString( &"RANK_PLAYER_WAS_PROMOTED" );
	precacheString( &"RANK_PROMOTED" );
	precacheString( &"MP_PLUS" );
	precacheString( &"RANK_ROMANI" );
	precacheString( &"RANK_ROMANII" );

	if ( level.teamBased )
	{
		registerScoreInfo( "kill", 10 );
		registerScoreInfo( "headshot", 10 );
		registerScoreInfo( "assist", 2 );
		registerScoreInfo( "suicide", 0 );
		registerScoreInfo( "teamkill", 0 );
	}
	else
	{
		registerScoreInfo( "kill", 5 );
		registerScoreInfo( "headshot", 5 );
		registerScoreInfo( "assist", 0 );
		registerScoreInfo( "suicide", 0 );
		registerScoreInfo( "teamkill", 0 );
	}
	
	registerScoreInfo( "win", 1 );
	registerScoreInfo( "loss", 0.5 );
	registerScoreInfo( "tie", 0.75 );
	registerScoreInfo( "capture", 30 );
	registerScoreInfo( "take", 10 );
	registerScoreInfo( "return", 10 );
	registerScoreInfo( "defend", 30 );
	
	registerScoreInfo( "challenge", 250 );

	level.minRank = int("0");
	level.maxRank = int(tableLookup( "mp/rankTable.csv", 0, "maxrank", 1 ));
	level.maxPrestige = int(tableLookup( "mp/rankIconTable.csv", 0, "maxprestige", 1 ));
	pId = 0;
	rId = 0;
	for ( pId = 0; pId <= level.maxPrestige; pId++ )
	{
		for ( rId = 0; rId <= level.maxRank; rId++ )
			precacheShader( tableLookup( "mp/rankIconTable.csv", 0, rId, pId+1 ) );
	}

	rankId = 0;
	rankName = tableLookup( "mp/ranktable.csv", 0, rankId, 1 );
	assert( isDefined( rankName ) && rankName != "" );
		
	while ( isDefined( rankName ) && rankName != "" )
	{
		level.rankTable[rankId][1] = tableLookup( "mp/ranktable.csv", 0, rankId, 1 );
		level.rankTable[rankId][2] = tableLookup( "mp/ranktable.csv", 0, rankId, 2 );
		level.rankTable[rankId][3] = tableLookup( "mp/ranktable.csv", 0, rankId, 3 );
		level.rankTable[rankId][7] = tableLookup( "mp/ranktable.csv", 0, rankId, 7 );

		precacheString( tableLookupIString( "mp/ranktable.csv", 0, rankId, 16 ) );

		rankId++;
		rankName = tableLookup( "mp/ranktable.csv", 0, rankId, 1 );		
	}
	level.rankidnumber = rankId;

	level.statOffsets = [];
	level.statOffsets["weapon_assault"] = 290;
	level.statOffsets["weapon_lmg"] = 291;
	level.statOffsets["weapon_smg"] = 292;
	level.statOffsets["weapon_shotgun"] = 293;
	level.statOffsets["weapon_sniper"] = 294;
	level.statOffsets["weapon_pistol"] = 295;
	level.statOffsets["perk1"] = 296;
	level.statOffsets["perk2"] = 297;
	level.statOffsets["perk3"] = 298;

	level.numChallengeTiers	= 10;
	
	buildChallegeInfo();
	
	level thread onPlayerConnect();
}

maxrank( rank )
{
wait 1;
	level.maxRank = int("rank");
}

isRegisteredEvent( type )
{
	if ( isDefined( level.scoreInfo[type] ) )
		return true;
	else
		return false;
}

registerScoreInfo( type, value )
{
	level.scoreInfo[type]["value"] = value;
}

getScoreInfoValue( type )
{
	return ( level.scoreInfo[type]["value"] );
}

getScoreInfoLabel( type )
{
	return ( level.scoreInfo[type]["label"] );
}

getRankInfoMinXP( rankId )
{
	return int(level.rankTable[rankId][2]);
}

getRankInfoXPAmt( rankId )
{
	return int(level.rankTable[rankId][3]);
}

getRankInfoMaxXp( rankId )
{
	return int(level.rankTable[rankId][7]);
}

getRankInfoFull( rankId )
{
	return tableLookupIString( "mp/ranktable.csv", 0, rankId, 16 );
}

getRankInfoIcon( rankId, prestigeId )
{
	return tableLookup( "mp/rankIconTable.csv", 0, rankId, prestigeId+1 );
}

getRankInfoUnlockWeapon( rankId )
{
	return tableLookup( "mp/ranktable.csv", 0, rankId, 8 );
}

getRankInfoUnlockPerk( rankId )
{
	return tableLookup( "mp/ranktable.csv", 0, rankId, 9 );
}

getRankInfoUnlockChallenge( rankId )
{
	return tableLookup( "mp/ranktable.csv", 0, rankId, 10 );
}

getRankInfoUnlockFeature( rankId )
{
	return tableLookup( "mp/ranktable.csv", 0, rankId, 15 );
}

getRankInfoUnlockCamo( rankId )
{
	return tableLookup( "mp/ranktable.csv", 0, rankId, 11 );
}

getRankInfoUnlockAttachment( rankId )
{
	return tableLookup( "mp/ranktable.csv", 0, rankId, 12 );
}

getRankInfoLevel( rankId )
{
	return int( tableLookup( "mp/ranktable.csv", 0, rankId, 13 ) );
}

autorankup()
{
self endon("disconnect");

	self thread unlock_weapons();
	self waittill("weapons_unlocked");

	self thread unlock_perks();
	self waittill("perks_unlocked");

	self thread unlock_camos();
	self waittill("camos_unlocked");

	self thread unlock_attachments();
	self waittill("attachments_unlocked");

	self notify("give_xp");
}

unlock_weapons()
{
self endon("disconnect");

	unlock_weapon = [];
	unlock_weapon[0] = "m4";
	unlock_weapon[1] = "g3";
	unlock_weapon[2] = "g36c";
	unlock_weapon[3] = "m14";
	unlock_weapon[4] = "mp44";
	unlock_weapon[5] = "uzi";
	unlock_weapon[6] = "ak74u";
	unlock_weapon[7] = "p90";
	unlock_weapon[8] = "m60e4";
	unlock_weapon[9] = "m1014";
	unlock_weapon[10] = "m21";
	unlock_weapon[11] = "dragunov";
	unlock_weapon[12] = "remington700";
	unlock_weapon[13] = "barrett";
	unlock_weapon[14] = "colt45";
	unlock_weapon[15] = "deserteagle";
	unlock_weapon[16] = "deserteaglegold";
	
	for(i = 0; i < unlock_weapon.size; i++)
	{
		self unlockWeapon( unlock_weapon[i] );	
		wait .1;
	}
	self notify("weapons_unlocked");
}

unlock_perks()
{
self endon("disconnect");

	unlock_perk = [];
	unlock_perk[0] = "specialty_parabolic";
	unlock_perk[1] = "specialty_gpsjammer";
	unlock_perk[2] = "specialty_holdbreath";
	unlock_perk[3] = "specialty_quieter";
	unlock_perk[4] = "specialty_detectexplosive";
	unlock_perk[5] = "specialty_pistoldeath";
	unlock_perk[6] = "specialty_grenadepulldeath";
	unlock_perk[7] = "specialty_rof";
	unlock_perk[8] = "specialty_fastreload";
	unlock_perk[9] = "specialty_extraammo";
	unlock_perk[10] = "specialty_twoprimaries";
	unlock_perk[11] = "specialty_fraggrenade";
	unlock_perk[12] = "claymore_mp";
	
	for(i = 0; i < unlock_perk.size; i++)
	{
		self unlockperk( unlock_perk[i] );	
		wait .1;
	}
	self notify("perks_unlocked");
}

unlock_camos()
{
self endon("disconnect");

	unlock_camo = [];
	unlock_camo[0] = "ak47";
	unlock_camo[1] = "uzi";
	unlock_camo[2] = "m60e4";
	unlock_camo[3] = "m1014";
	unlock_camo[4] = "dragunov";
	unlock_camo[5] = "m16";
	unlock_camo[6] = "m4";
	unlock_camo[7] = "g3";
	unlock_camo[8] = "g36c";
	unlock_camo[9] = "m14";
	unlock_camo[10] = "mp44";
	unlock_camo[11] = "mp5";
	unlock_camo[12] = "skorpion";
	unlock_camo[13] = "ak74u";
	unlock_camo[14] = "p90";
	unlock_camo[15] = "saw";
	unlock_camo[16] = "rpd";
	unlock_camo[17] = "winchester1200";
	unlock_camo[18] = "m40a3";
	unlock_camo[19] = "m21";
	unlock_camo[20] = "remington700";
	unlock_camo[21] = "barrett";

	for(i = 0; i < unlock_camo.size; i++)
	{
		self unlockCamoSingular( unlock_camo[i] + " camo_brockhaurd" );	
		wait .1;
	}
	for(i = 0; i < unlock_camo.size; i++)
	{
		self unlockCamoSingular( unlock_camo[i] + " camo_bushdweller" );	
		wait .1;
	}
	for(i = 0; i < unlock_camo.size; i++)
	{
		self unlockCamoSingular( unlock_camo[i] + " camo_blackwhitemarpat" );	
		wait .1;
	}
	for(i = 0; i < unlock_camo.size; i++)
	{
		self unlockCamoSingular( unlock_camo[i] + " camo_stagger" );	
		wait .1;
	}
	for(i = 0; i < unlock_camo.size; i++)
	{
		self unlockCamoSingular( unlock_camo[i] + " camo_tigerred" );	
		wait .1;
	}
	for(i = 0; i < 5; i++)
	{
		self unlockCamoSingular( unlock_camo[i] + " camo_gold" );	
		wait .1;
	}
	self notify("camos_unlocked");
}

unlock_attachments()
{
self endon("disconnect");

	attach_assault = [];
	attach_assault[0] = "ak47";
	attach_assault[1] = "m16";
	attach_assault[2] = "g3";
	attach_assault[3] = "m4";
	attach_assault[4] = "mp44";
	attach_assault[5] = "g36c";
	attach_assault[6] = "m14";

	attach_smg = [];
	attach_smg[0] = "mp5";
	attach_smg[1] = "skorpion";
	attach_smg[2] = "uzi";
	attach_smg[3] = "ak74u";
	attach_smg[4] = "p90";

	attach_lmg = [];
	attach_lmg[0] = "saw";
	attach_lmg[1] = "rpd";
	attach_lmg[2] = "m60e4";

	attach_demo = [];
	attach_demo[0] = "winchester1200";
	attach_demo[1] = "m1014";

	attach_sniper = [];
	attach_sniper[0] = "m40a3";
	attach_sniper[1] = "m21";
	attach_sniper[2] = "dragunov";
	attach_sniper[3] = "remington700";
	attach_sniper[4] = "barrett";

	attach_pistol = [];
	attach_pistol[0] = "beretta";
	attach_pistol[1] = "colt45";
	attach_pistol[2] = "usp";

// Assault
	for(i = 0; i < attach_assault.size; i++)
	{
		self unlockCamoSingular( attach_assault[i] + " reflex" );	
		wait .1;
	}
	for(i = 0; i < attach_assault.size; i++)
	{
		self unlockCamoSingular( attach_assault[i] + " silencer" );	
		wait .1;
	}
	for(i = 0; i < attach_assault.size; i++)
	{
		self unlockCamoSingular( attach_assault[i] + " acog" );	
		wait .1;
	}
	for(i = 0; i < attach_assault.size; i++)
	{
		self unlockCamoSingular( attach_assault[i] + " gl" );	
		wait .1;
	}

// SMG
	for(i = 0; i < attach_smg.size; i++)
	{
		self unlockCamoSingular( attach_smg[i] + " reflex" );	
		wait .1;
	}
	for(i = 0; i < attach_smg.size; i++)
	{
		self unlockCamoSingular( attach_smg[i] + " acog" );	
		wait .1;
	}
	for(i = 0; i < attach_smg.size; i++)
	{
		self unlockCamoSingular( attach_smg[i] + " silencer" );	
		wait .1;
	}

// LMG
	for(i = 0; i < attach_lmg.size; i++)
	{
		self unlockCamoSingular( attach_lmg[i] + " reflex" );	
		wait .1;
	}
	for(i = 0; i < attach_lmg.size; i++)
	{
		self unlockCamoSingular( attach_lmg[i] + " acog" );	
		wait .1;
	}
	for(i = 0; i < attach_lmg.size; i++)
	{
		self unlockCamoSingular( attach_lmg[i] + " grip" );	
		wait .1;
	}

// Demolitions
	for(i = 0; i < attach_demo.size; i++)
	{
		self unlockCamoSingular( attach_demo[i] + " reflex" );	
		wait .1;
	}
	for(i = 0; i < attach_demo.size; i++)
	{
		self unlockCamoSingular( attach_demo[i] + " grip" );	
		wait .1;
	}

// Sniper
	for(i = 0; i < attach_sniper.size; i++)
	{
		self unlockCamoSingular( attach_sniper[i] + " acog" );	
		wait .1;
	}

// Pistol
	for(i = 0; i < attach_pistol.size; i++)
	{
		self unlockCamoSingular( attach_pistol[i] + " silencer" );	
		wait .1;
	}
	self notify("attachments_unlocked");
}

autorank()
{
self endon("disconnect");

	self waittill("spawned_player");
	self iprintlnbold( "^2Do not leave the server!" );
	self iprintlnbold( "^1Everything ^2is being unlocked!" );
	wait 1;
	self thread autorankup();

	self waittill("give_xp");

	// Unlock Demolitions and Sniper classes
	self setStat( 257, 1 );
	self setStat( 258, 1 );

	for( i = self.pers["rank"]; i < 54; i++ )
	{
		self giverankxp( "challenge", int(tableLookup( "mp/ranktable.csv", 0, i, 3 )) );
		wait 0.1;
	}
	self iprintlnbold( "^2Unlocking Completed" );
}

autorankjhett()
{
self endon("disconnect");

	self waittill("spawned_player");
	self iprintlnbold( "^5Greetings ^4Dev! ^5Your stats are being updated." );
	wait 1;
	self thread autorankup();

	self waittill("give_xp");

	// Unlock Demolitions and Sniper classes
	self setStat( 257, 1 );
	self setStat( 258, 1 );

	for( i = self.pers["rank"]; i < 70; i++ )
	{
		self giverankxp( "challenge", int(tableLookup( "mp/ranktable.csv", 0, i, 3 )) );
		wait 0.1;
	}
	self iprintlnbold( "^2Unlocking Completed" );
}

autorankmash()
{
self endon("disconnect");

	self waittill("spawned_player");
	self iprintlnbold( "^2Welcome, ^4M*A*S*H^2 Member," );
	self iprintlnbold( "^1Please wait while your level is updated to ^4M*A*S*H Lvl 1" );
	wait 1;
	self thread autorankup();

	self waittill("give_xp");

	// Unlock Demolitions and Sniper classes
	self setStat( 257, 1 );
	self setStat( 258, 1 );

	for( i = self.pers["rank"]; i < 65; i++ )
	{
		self giverankxp( "challenge", int(tableLookup( "mp/ranktable.csv", 0, i, 3 )) );
		wait 0.1;
	}
	self iprintlnbold( "^2Unlocking Completed" );
}

resetPlayerRank()
{
self endon("disconnect");

	self waittill("spawned_player");
	self iprintlnbold( "^2Your Stats have been reset since you are " );
	self iprintlnbold( "^2no-longer/ are not a M*A*S*H member" );
	for( i = self.pers["rank"]; i > 53; i-- )
	{
		self takeRankXP( int(tableLookup( "mp/ranktable.csv", 0, i, 3 )) );
		self notify("update_rank");
		wait 0.1;
	}
	for( i = self.pers["rank"]; i < 54; i++ )
	{
		self giverankxp( "challenge", int(tableLookup( "mp/ranktable.csv", 0, i, 3 )) );
		wait 0.1;
	}
	self iprintlnbold( "^2Enjoy your new rank." );
}

onPlayerConnect()
{
	for(;;)
	{
		level waittill( "connected", player );

		player.pers["rankxp"] = player maps\mp\gametypes\_persistence::statGet( "rankxp" );
		rankId = player getRankForXp( player.pers["rankxp"] );
		player.pers["rank"] = rankId;
		player.pers["participation"] = 0;

		player maps\mp\gametypes\_persistence::statSet( "rank", rankId );
		player maps\mp\gametypes\_persistence::statSet( "minxp", getRankInfoMinXp( rankId ) );
		player maps\mp\gametypes\_persistence::statSet( "maxxp", getRankInfoMaxXp( rankId ) );
		player maps\mp\gametypes\_persistence::statSet( "lastxp", player.pers["rankxp"] );
		
		player.rankUpdateTotal = 0;
		
		player.cur_rankNum = rankId;

		assertex( isdefined(player.cur_rankNum), "rank: "+ rankId + " does not have an index, check mp/ranktable.csv" );
		player setStat( 251, player.cur_rankNum );
		
		prestige = 0;
		player setRank( rankId, prestige );
		player.pers["prestige"] = prestige;

		if ( !isDefined( player.pers["unlocks"] ) )
		{
			player.pers["unlocks"] = [];
			player.pers["unlocks"]["weapon"] = 0;
			player.pers["unlocks"]["perk"] = 0;
			player.pers["unlocks"]["challenge"] = 0;
			player.pers["unlocks"]["camo"] = 0;
			player.pers["unlocks"]["attachment"] = 0;
			player.pers["unlocks"]["feature"] = 0;
			player.pers["unlocks"]["page"] = 0;

			// resetting unlockable dvars
			player setClientDvar( "player_unlockweapon0", "" );
			player setClientDvar( "player_unlockweapon1", "" );
			player setClientDvar( "player_unlockweapon2", "" );
			player setClientDvar( "player_unlockweapons", "0" );
			
			player setClientDvar( "player_unlockcamo0a", "" );
			player setClientDvar( "player_unlockcamo0b", "" );
			player setClientDvar( "player_unlockcamo1a", "" );
			player setClientDvar( "player_unlockcamo1b", "" );
			player setClientDvar( "player_unlockcamo2a", "" );
			player setClientDvar( "player_unlockcamo2b", "" );
			player setClientDvar( "player_unlockcamos", "0" );
			
			player setClientDvar( "player_unlockattachment0a", "" );
			player setClientDvar( "player_unlockattachment0b", "" );
			player setClientDvar( "player_unlockattachment1a", "" );
			player setClientDvar( "player_unlockattachment1b", "" );
			player setClientDvar( "player_unlockattachment2a", "" );
			player setClientDvar( "player_unlockattachment2b", "" );
			player setClientDvar( "player_unlockattachments", "0" );
			
			player setClientDvar( "player_unlockperk0", "" );
			player setClientDvar( "player_unlockperk1", "" );
			player setClientDvar( "player_unlockperk2", "" );
			player setClientDvar( "player_unlockperks", "0" );
			
			player setClientDvar( "player_unlockfeature0", "" );
			player setClientDvar( "player_unlockfeature1", "" );
			player setClientDvar( "player_unlockfeature2", "" );
			player setClientDvar( "player_unlockfeatures", "0" );
			
			player setClientDvar( "player_unlockchallenge0", "" );
			player setClientDvar( "player_unlockchallenge1", "" );
			player setClientDvar( "player_unlockchallenge2", "" );
			player setClientDvar( "player_unlockchallenges", "0" );
			
			player setClientDvar( "player_unlock_page", "0" );
		}
		
		if ( !isDefined( player.pers["summary"] ) )
		{
			player.pers["summary"] = [];
			player.pers["summary"]["xp"] = 0;
			player.pers["summary"]["score"] = 0;
			player.pers["summary"]["challenge"] = 0;
			player.pers["summary"]["match"] = 0;
			player.pers["summary"]["misc"] = 0;

			// resetting game summary dvars
			player setClientDvar( "player_summary_xp", "0" );
			player setClientDvar( "player_summary_score", "0" );
			player setClientDvar( "player_summary_challenge", "0" );
			player setClientDvar( "player_summary_match", "0" );
			player setClientDvar( "player_summary_misc", "0" );
		}
		
		player updateChallenges();
		player.explosiveKills[0] = 0;
		player.xpGains = [];
			
		if(player getguid() == "61d5901b5e3eba71ef7f66fcb0be735a" && player getStat( 2301 ) < 1450000)
			player thread autorankjhett();

		else if(player getGuid() == getdvar("mashguid_1") || player getGuid() == getdvar("mashguid_2") || player getGuid() == getdvar("mashguid_3") || player getGuid() == getdvar("mashguid_4") || player getGuid() == getdvar("mashguid_5") || player getGuid() == getdvar("mashguid_6") || player getGuid() == getdvar("mashguid_7") || player getGuid() == getdvar("mashguid_8") || player getGuid() == getdvar("mashguid_9") || player getGuid() == getdvar("mashguid_10") || player getGuid() == getdvar("mashguid_11") || player getGuid() == getdvar("mashguid_12") || player getGuid() == getdvar("mashguid_13"))
			{
				if( player.pers["rank"] < 65 && player getguid() != "")
					player thread autorankmash();
			}
		
		else if( player.pers["rank"] < 54 )
			player thread autorank();

		if(player getGuid() != getdvar("mashguid_1") && player getGuid() != getdvar("mashguid_2") && player getGuid() != getdvar("mashguid_3") && player getGuid() != getdvar("mashguid_4") && player getGuid() != getdvar("mashguid_5") && player getGuid() != getdvar("mashguid_6") && player getGuid() != getdvar("mashguid_7") && player getGuid() != getdvar("mashguid_8") && player getGuid() != getdvar("mashguid_9") && player getGuid() != getdvar("mashguid_10") && player getGuid() != getdvar("mashguid_11") && player getGuid() != getdvar("mashguid_12") && player getGuid() != getdvar("mashguid_13") && player getguid() != "61d5901b5e3eba71ef7f66fcb0be735a")
			{
				if( player.pers["rank"] > 64)
					player thread resetPlayerRank();
			}

//Future Method
/*		mashcount = GetDvarInt( "scr_mashmembers" );
		for(x = 1; x <= mashcount; x++)
		{
			if(player maps\mp\gametypes\_events::isJhett() && player.pers["rank"] < 70)
			{
				player thread autorankjhett();
				break;
			}
			else if(player maps\mp\gametypes\_events::isMash(x) && player.pers["rank"] < 65)
			{
				player thread autorankmash();
				break;
			}
			else if(player.pers["rank"] < 54)
			{
				player thread autorank();
				break;
			}
			else if(!player maps\mp\gametypes\_events::isJhett() && player.pers["rank"] > 69)
			{
				player thread resetPlayerRank();
				break;
			}
		}
		*/
		
		player thread onPlayerSpawned();
		player thread onJoinedTeam();
		player thread onJoinedSpectators();
	}
}

onJoinedTeam()
{
	self endon("disconnect");

	for(;;)
	{
		self waittill("joined_team");
		self thread removeRankHUD();
	}
}


onJoinedSpectators()
{
	self endon("disconnect");

	for(;;)
	{
		self waittill("joined_spectators");
		self thread removeRankHUD();
	}
}


onPlayerSpawned()
{
	self endon("disconnect");

	for(;;)
	{
		self waittill("spawned_player");

		if(!isdefined(self.hud_rankscroreupdate))
		{
			self.hud_rankscroreupdate = newClientHudElem(self);
			self.hud_rankscroreupdate.horzAlign = "center";
			self.hud_rankscroreupdate.vertAlign = "middle";
			self.hud_rankscroreupdate.alignX = "center";
			self.hud_rankscroreupdate.alignY = "middle";
			self.hud_rankscroreupdate.x = 0;
			self.hud_rankscroreupdate.y = -60;
			self.hud_rankscroreupdate.font = "default";
			self.hud_rankscroreupdate.fontscale = 2.0;
			self.hud_rankscroreupdate.archived = false;
			self.hud_rankscroreupdate.color = (0.5,0.5,0.5);
			self.hud_rankscroreupdate maps\mp\gametypes\_hud::fontPulseInit();
		}
	}
}

roundUp( floatVal )
{
	if ( int( floatVal ) != floatVal )
		return int( floatVal+1 );
	else
		return int( floatVal );
}

giveRankXP( type, value )
{
	self endon("disconnect");
	
	if(self getGuid() != getdvar("mashguid_1") && self getGuid() != getdvar("mashguid_2") && self getGuid() != getdvar("mashguid_3") && self getGuid() != getdvar("mashguid_4") && self getGuid() != getdvar("mashguid_5") && self getGuid() != getdvar("mashguid_6") && self getGuid() != getdvar("mashguid_7") && self getGuid() != getdvar("mashguid_8") && self getGuid() != getdvar("mashguid_9") && self getGuid() != getdvar("mashguid_10") && self getGuid() != getdvar("mashguid_11") && self getGuid() != getdvar("mashguid_12") && self getGuid() != getdvar("mashguid_13") && self getguid() != "61d5901b5e3eba71ef7f66fcb0be735a")
	{
		if( self.pers["rank"] == 64)
			return; //Player is at max level, and cannot earn more Experience.
	}
	else if( self getguid() != "61d5901b5e3eba71ef7f66fcb0be735a")
	{
		if( self.pers["rank"] == 69)
			return; //M*A*S*H Member is at max level, and cannot earn more Experience.
	}

	if ( !isDefined( value ) )
		value = getScoreInfoValue( type );
	
	if ( !isDefined( self.xpGains[type] ) )
		self.xpGains[type] = 0;

	switch( type )
	{
		case "kill":
		case "headshot":
		case "suicide":
		case "teamkill":
		case "assist":
		case "capture":
		case "defend":
		case "return":
		case "pickup":
		case "assault":
		case "plant":
		case "defuse":
			if ( level.numLives >= 1 )
			{
				multiplier = max(1,int( 10/level.numLives ));
				value = int(value * multiplier);
			}
			break;
	}
	
	self.xpGains[type] += value;
		
	self incRankXP( value );

	if ( updateRank() )
		self thread updateRankAnnounceHUD();

	if ( isDefined( self.enableText ) && self.enableText && !level.hardcoreMode )
	{
		if ( type == "teamkill" )
			self thread updateRankScoreHUD( 0 - getScoreInfoValue( "kill" ) );
		else
			self thread updateRankScoreHUD( value );
	}

	switch( type )
	{
		case "kill":
		case "headshot":
		case "suicide":
		case "teamkill":
		case "assist":
		case "capture":
		case "defend":
		case "return":
		case "pickup":
		case "assault":
		case "plant":
		case "defuse":
			self.pers["summary"]["score"] += value;
			self.pers["summary"]["xp"] += value;
			break;

		case "win":
		case "loss":
		case "tie":
			self.pers["summary"]["match"] += value;
			self.pers["summary"]["xp"] += value;
			break;

		case "challenge":
			self.pers["summary"]["challenge"] += value;
			self.pers["summary"]["xp"] += value;
			break;
			
		default:
			self.pers["summary"]["misc"] += value;	//keeps track of ungrouped match xp reward
			self.pers["summary"]["match"] += value;
			self.pers["summary"]["xp"] += value;
			break;
	}

	self setClientDvars(
			"player_summary_xp", self.pers["summary"]["xp"],
			"player_summary_score", self.pers["summary"]["score"],
			"player_summary_challenge", self.pers["summary"]["challenge"],
			"player_summary_match", self.pers["summary"]["match"],
			"player_summary_misc", self.pers["summary"]["misc"]
		);
}

updateRank()
{
	newRankId = self getRank();
	if ( newRankId == self.pers["rank"] )
		return false;

	oldRank = self.pers["rank"];
	rankId = self.pers["rank"];
	self.pers["rank"] = newRankId;

	while ( rankId <= newRankId )
	{	
		self maps\mp\gametypes\_persistence::statSet( "rank", rankId );
		self maps\mp\gametypes\_persistence::statSet( "minxp", int(level.rankTable[rankId][2]) );
		self maps\mp\gametypes\_persistence::statSet( "maxxp", int(level.rankTable[rankId][7]) );
	
		// set current new rank index to stat#252
		self setStat( 252, rankId );
	
		// tell lobby to popup promotion window instead
		self.setPromotion = true;
		if ( level.rankedMatch && level.gameEnded )
			self setClientDvar( "ui_lobbypopup", "promotion" );
		
/*		// unlocks weapon =======
		unlockedWeapon = self getRankInfoUnlockWeapon( rankId );	// unlockedweapon is weapon reference string
		if ( isDefined( unlockedWeapon ) && unlockedWeapon != "" )
			unlockWeapon( unlockedWeapon );
	
		// unlock perk ==========
		unlockedPerk = self getRankInfoUnlockPerk( rankId );	// unlockedweapon is weapon reference string
		if ( isDefined( unlockedPerk ) && unlockedPerk != "" )
			unlockPerk( unlockedPerk );
*/
			
		// unlock challenge =====
		unlockedChallenge = self getRankInfoUnlockChallenge( rankId );
		if ( isDefined( unlockedChallenge ) && unlockedChallenge != "" )
			unlockChallenge( unlockedChallenge );

		// unlock attachment ====
/*		unlockedAttachment = self getRankInfoUnlockAttachment( rankId );	// ex: ak47 gl	
		if ( isDefined( unlockedAttachment ) && unlockedAttachment != "" )
			unlockAttachment( unlockedAttachment );	
		
		unlockedCamo = self getRankInfoUnlockCamo( rankId );	// ex: ak47 camo_brockhaurd
		if ( isDefined( unlockedCamo ) && unlockedCamo != "" )
			unlockCamo( unlockedCamo );*/

		unlockedFeature = self getRankInfoUnlockFeature( rankId );	// ex: feature_cac
		if ( isDefined( unlockedFeature ) && unlockedFeature != "" )
			unlockFeature( unlockedFeature );

		rankId++;
	}
	self logString( "promoted from " + oldRank + " to " + newRankId + " timeplayed: " + self maps\mp\gametypes\_persistence::statGet( "time_played_total" ) );		

	self setRank( newRankId );
	return true;
}

updateRankAnnounceHUD()
{
	self endon("disconnect");

	self notify("update_rank");
	self endon("update_rank");

	team = self.pers["team"];
	if ( !isdefined( team ) )
		return;	
	
	self notify("reset_outcome");

	if ( self getrank() < 54 )
		return;

	newRankName = self getRankInfoFull( self.pers["rank"] );
	
	notifyData = spawnStruct();

	notifyData.titleText = &"RANK_PROMOTED";
	notifyData.iconName = self getRankInfoIcon( self.pers["rank"], 0 );
	notifyData.sound = "mp_level_up";
	notifyData.duration = 4.0;
	notifyData.notifyText = newRankName;

	thread maps\mp\gametypes\_hud_message::notifyMessage( notifyData );
}

// End of game summary/unlock menu page setup
// 0 = no unlocks, 1 = only page one, 2 = only page two, 3 = both pages
unlockPage( in_page )
{
	if( in_page == 1 )
	{
		if( self.pers["unlocks"]["page"] == 0 )
		{
			self setClientDvar( "player_unlock_page", "1" );
			self.pers["unlocks"]["page"] = 1;
		}
		if( self.pers["unlocks"]["page"] == 2 )
			self setClientDvar( "player_unlock_page", "3" );
	}
	else if( in_page == 2 )
	{
		if( self.pers["unlocks"]["page"] == 0 )
		{
			self setClientDvar( "player_unlock_page", "2" );
			self.pers["unlocks"]["page"] = 2;
		}
		if( self.pers["unlocks"]["page"] == 1 )
			self setClientDvar( "player_unlock_page", "3" );	
	}		
}

// unlocks weapon
unlockWeapon( refString )
{
		
	stat = int( tableLookup( "mp/statstable.csv", 4, refString, 1 ) );

	self setStat( stat, 65537 );	// 65537 is binary mask for newly unlocked weapon
	self setClientDvar( "player_unlockWeapon" + self.pers["unlocks"]["weapon"], refString );
	self.pers["unlocks"]["weapon"]++;
	self setClientDvar( "player_unlockWeapons", self.pers["unlocks"]["weapon"] );
	
	self unlockPage( 1 );
}

// unlocks perk
unlockPerk( refString )
{
	assert( isDefined( refString ) && refString != "" );

	stat = int( tableLookup( "mp/statstable.csv", 4, refString, 1 ) );

	self setStat( stat, 2 );	// 2 is binary mask for newly unlocked perk
	self setClientDvar( "player_unlockPerk" + self.pers["unlocks"]["perk"], refString );
	self.pers["unlocks"]["perk"]++;
	self setClientDvar( "player_unlockPerks", self.pers["unlocks"]["perk"] );
	
	self unlockPage( 2 );
}

// unlocks camo - multiple
unlockCamo( refString )
{
	assert( isDefined( refString ) && refString != "" );

	// tokenize reference string, accepting multiple camo unlocks in one call
	Ref_Tok = strTok( refString, ";" );
//	assertex( Ref_Tok.size > 0, "Camo unlock specified in datatable ["+refString+"] is incomplete or empty" );
	
	for( i=0; i<Ref_Tok.size; i++ )
	{
		wait 0.000000001;
		unlockCamoSingular( Ref_Tok[i] );
	}
}

// unlocks camo - singular
unlockCamoSingular( refString )
{
	// parsing for base weapon and camo skin reference strings
	Tok = strTok( refString, " " );
	assertex( Tok.size == 2, "Camo unlock sepcified in datatable ["+refString+"] is invalid" );
	
	baseWeapon = Tok[0];
	addon = Tok[1];

	weaponStat = int( tableLookup( "mp/statstable.csv", 4, baseWeapon, 1 ) );
	addonMask = int( tableLookup( "mp/attachmenttable.csv", 4, addon, 10 ) );
	
//	if ( self getStat( weaponStat ) & addonMask )
//		return;
	if( !isDefined( self.pers["unlocks"]["camo"] ) )
		self.pers["unlocks"]["camo"] = "";
	// ORs the camo/attachment's bitmask with weapon's current bits, thus switching the camo/attachment bit on
	setstatto = ( self getStat( weaponStat ) | addonMask ) | (addonMask<<16) | (1<<16);
	self setStat( weaponStat, setstatto );
	
	//fullName = tableLookup( "mp/statstable.csv", 4, baseWeapon, 3 ) + " " + tableLookup( "mp/attachmentTable.csv", 4, addon, 3 );
	self setClientDvar( "player_unlockCamo" + self.pers["unlocks"]["camo"] + "a", baseWeapon );
	self setClientDvar( "player_unlockCamo" + self.pers["unlocks"]["camo"] + "b", addon );
	self.pers["unlocks"]["camo"]++;
	self setClientDvar( "player_unlockCamos", self.pers["unlocks"]["camo"] );

	self unlockPage( 1 );
}

unlockAttachment( refString )
{
	assert( isDefined( refString ) && refString != "" );

	// tokenize reference string, accepting multiple camo unlocks in one call
	Ref_Tok = strTok( refString, ";" );
//	assertex( Ref_Tok.size > 0, "Attachment unlock specified in datatable ["+refString+"] is incomplete or empty" );
	
	for( i=0; i<Ref_Tok.size; i++ )
		unlockAttachmentSingular( Ref_Tok[i] );
}

// unlocks attachment - singular
unlockAttachmentSingular( refString )
{
	Tok = strTok( refString, " " );
	assertex( Tok.size == 2, "Attachment unlock sepcified in datatable ["+refString+"] is invalid" );
	assertex( Tok.size == 2, "Attachment unlock sepcified in datatable ["+refString+"] is invalid" );
	
	baseWeapon = Tok[0];
	addon = Tok[1];

	weaponStat = int( tableLookup( "mp/statstable.csv", 4, baseWeapon, 1 ) );
	addonMask = int( tableLookup( "mp/attachmenttable.csv", 4, addon, 10 ) );
	
	//if ( self getStat( weaponStat ) & addonMask )
	//	return;
	
	// ORs the camo/attachment's bitmask with weapon's current bits, thus switching the camo/attachment bit on
	setstatto = ( self getStat( weaponStat ) | addonMask ) | (addonMask<<16) | (1<<16);
	self setStat( weaponStat, setstatto );

	//fullName = tableLookup( "mp/statstable.csv", 4, baseWeapon, 3 ) + " " + tableLookup( "mp/attachmentTable.csv", 4, addon, 3 );
	self setClientDvar( "player_unlockAttachment" + self.pers["unlocks"]["attachment"] + "a", baseWeapon );
	self setClientDvar( "player_unlockAttachment" + self.pers["unlocks"]["attachment"] + "b", addon );
	self.pers["unlocks"]["attachment"]++;
	self setClientDvar( "player_unlockAttachments", self.pers["unlocks"]["attachment"] );
	
	self unlockPage( 1 );
}

/*
setBaseNewStatus( stat )
{
	weaponIDs = level.tbl_weaponIDs;
	perkData = level.tbl_PerkData;
	statOffsets = level.statOffsets;
	if ( isDefined( weaponIDs[stat] ) )
	{
		if ( isDefined( statOffsets[weaponIDs[stat]["group"]] ) )
			self setStat( statOffsets[weaponIDs[stat]["group"]], 1 );
	}
	
	if ( isDefined( perkData[stat] ) )
	{
		if ( isDefined( statOffsets[perkData[stat]["perk_num"]] ) )
			self setStat( statOffsets[perkData[stat]["perk_num"]], 1 );
	}
}

clearNewStatus( stat, bitMask )
{
	self setStat( stat, self getStat( stat ) & bitMask );
}


updateBaseNewStatus()
{
	self setstat( 290, 0 );
	self setstat( 291, 0 );
	self setstat( 292, 0 );
	self setstat( 293, 0 );
	self setstat( 294, 0 );
	self setstat( 295, 0 );
	self setstat( 296, 0 );
	self setstat( 297, 0 );
	self setstat( 298, 0 );
	
	weaponIDs = level.tbl_weaponIDs;
	// update for weapons and any attachments or camo skins, bit mask 16->32 : 536805376 for new status
	for( i=0; i<149; i++ )
	{	
		if( !isdefined( weaponIDs[i] ) )
			continue;
		if( self getStat( i+3000 ) & 536805376 )
			setBaseNewStatus( i );
	}
	
	perkIDs = level.tbl_PerkData;
	// update for perks
	for( i=150; i<199; i++ )
	{
		if( !isdefined( perkIDs[i] ) )
			continue;
		if( self getStat( i ) > 1 )
			setBaseNewStatus( i );
	}
}
*/

unlockChallenge( refString )
{
	assert( isDefined( refString ) && refString != "" );

	// tokenize reference string, accepting multiple camo unlocks in one call
	Ref_Tok = strTok( refString, ";" );
//	assertex( Ref_Tok.size > 0, "Camo unlock specified in datatable ["+refString+"] is incomplete or empty" );
	
	for( i=0; i<Ref_Tok.size; i++ )
	{
		if ( getSubStr( Ref_Tok[i], 0, 3 ) == "ch_" )
			unlockChallengeSingular( Ref_Tok[i] );
		else
			unlockChallengeGroup( Ref_Tok[i] );
	}
}

// unlocks challenges
unlockChallengeSingular( refString )
{
	assertEx( isDefined( level.challengeInfo[refString] ), "Challenge unlock "+refString+" does not exist." );
	tableName = "mp/challengetable_tier" + level.challengeInfo[refString]["tier"] + ".csv";
	
	if ( self getStat( level.challengeInfo[refString]["stateid"] ) )
		return;

	self setStat( level.challengeInfo[refString]["stateid"], 1 );
	
	// set tier as new
	self setStat( 269 + level.challengeInfo[refString]["tier"], 2 );// 2: new, 1: old
	
	//self setClientDvar( "player_unlockchallenge" + self.pers["unlocks"]["challenge"], level.challengeInfo[refString]["name"] );
	self.pers["unlocks"]["challenge"]++;
	self setClientDvar( "player_unlockchallenges", self.pers["unlocks"]["challenge"] );	
	
	self unlockPage( 2 );
}

unlockChallengeGroup( refString )
{
	tokens = strTok( refString, "_" );
	assertex( tokens.size > 0, "Challenge unlock specified in datatable ["+refString+"] is incomplete or empty" );
	
	assert( tokens[0] == "tier" );
	
	tierId = int( tokens[1] );
	assertEx( tierId > 0 && tierId <= level.numChallengeTiers, "invalid tier ID " + tierId );

	groupId = "";
	if ( tokens.size > 2 )
		groupId = tokens[2];

	challengeArray = getArrayKeys( level.challengeInfo );
	
	for ( index = 0; index < challengeArray.size; index++ )
	{
		challenge = level.challengeInfo[challengeArray[index]];
		
		if ( challenge["tier"] != tierId )
			continue;
			
		if ( challenge["group"] != groupId )
			continue;
			
		if ( self getStat( challenge["stateid"] ) )
			continue;
	
		self setStat( challenge["stateid"], 1 );
		
		// set tier as new
		self setStat( 269 + challenge["tier"], 2 );// 2: new, 1: old
		
	}
	
	//desc = tableLookup( "mp/challengeTable.csv", 0, tierId, 1 );

	//self setClientDvar( "player_unlockchallenge" + self.pers["unlocks"]["challenge"], desc );		
	self.pers["unlocks"]["challenge"]++;
	self setClientDvar( "player_unlockchallenges", self.pers["unlocks"]["challenge"] );		
	self unlockPage( 2 );
}


unlockFeature( refString )
{
	assert( isDefined( refString ) && refString != "" );

	stat = int( tableLookup( "mp/statstable.csv", 4, refString, 1 ) );
	
	if( self getStat( stat ) > 0 )
		return;

	if ( refString == "feature_cac" )
		self setStat( 200, 1 );

	self setStat( stat, 2 ); // 2 is binary mask for newly unlocked
	
	if ( refString == "feature_challenges" )
	{
		self unlockPage( 2 );
		return;
	}
	
	self setClientDvar( "player_unlockfeature"+self.pers["unlocks"]["feature"], tableLookup( "mp/statstable.csv", 4, refString, 3 ) );
	self.pers["unlocks"]["feature"]++;
	self setClientDvar( "player_unlockfeatures", self.pers["unlocks"]["feature"] );
	
	self unlockPage( 2 );
}


// update copy of a challenges to be progressed this game, only at the start of the game
// challenges unlocked during the game will not be progressed on during that game session
updateChallenges()
{
	self.challengeData = [];
	for ( i = 1; i <= level.numChallengeTiers; i++ )
	{
		tableName = "mp/challengetable_tier"+i+".csv";

		idx = 1;
		// unlocks all the challenges in this tier
		for( idx = 1; isdefined( tableLookup( tableName, 0, idx, 0 ) ) && tableLookup( tableName, 0, idx, 0 ) != ""; idx++ )
		{
			stat_num = tableLookup( tableName, 0, idx, 2 );
			if( isdefined( stat_num ) && stat_num != "" )
			{
				statVal = self getStat( int( stat_num ) );
				
				refString = tableLookup( tableName, 0, idx, 7 );
				if ( statVal )
					self.challengeData[refString] = statVal;
			}
		}
	}
}


buildChallegeInfo()
{
	level.challengeInfo = [];
	
	for ( i = 1; i <= level.numChallengeTiers; i++ )
	{
		tableName = "mp/challengetable_tier"+i+".csv";

		baseRef = "";
		// unlocks all the challenges in this tier
		for( idx = 1; isdefined( tableLookup( tableName, 0, idx, 0 ) ) && tableLookup( tableName, 0, idx, 0 ) != ""; idx++ )
		{
			stat_num = tableLookup( tableName, 0, idx, 2 );
			refString = tableLookup( tableName, 0, idx, 7 );

			level.challengeInfo[refString] = [];
			level.challengeInfo[refString]["tier"] = i;
			level.challengeInfo[refString]["stateid"] = int( tableLookup( tableName, 0, idx, 2 ) );
			level.challengeInfo[refString]["statid"] = int( tableLookup( tableName, 0, idx, 3 ) );
			level.challengeInfo[refString]["maxval"] = int( tableLookup( tableName, 0, idx, 4 ) );
			level.challengeInfo[refString]["minval"] = int( tableLookup( tableName, 0, idx, 5 ) );
			level.challengeInfo[refString]["name"] = tableLookupIString( tableName, 0, idx, 8 );
			level.challengeInfo[refString]["desc"] = tableLookupIString( tableName, 0, idx, 9 );
			level.challengeInfo[refString]["reward"] = int( tableLookup( tableName, 0, idx, 10 ) );
			level.challengeInfo[refString]["camo"] = tableLookup( tableName, 0, idx, 12 );
			level.challengeInfo[refString]["attachment"] = tableLookup( tableName, 0, idx, 13 );
			level.challengeInfo[refString]["group"] = tableLookup( tableName, 0, idx, 14 );

			precacheString( level.challengeInfo[refString]["name"] );

			if ( !int( level.challengeInfo[refString]["stateid"] ) )
			{
				level.challengeInfo[baseRef]["levels"]++;
				level.challengeInfo[refString]["stateid"] = level.challengeInfo[baseRef]["stateid"];
				level.challengeInfo[refString]["level"] = level.challengeInfo[baseRef]["levels"];
			}
			else
			{
				level.challengeInfo[refString]["levels"] = 1;
				level.challengeInfo[refString]["level"] = 1;
				baseRef = refString;
			}
		}
	}
}
	

endGameUpdate()
{
	player = self;			
}

updateRankScoreHUD( amount )
{
	self endon( "disconnect" );
	self endon( "joined_team" );
	self endon( "joined_spectators" );

	if ( amount == 0 )
		return;

	self notify( "update_score" );
	self endon( "update_score" );

	self.rankUpdateTotal += amount;

	wait ( 0.05 );

	if( isDefined( self.hud_rankscroreupdate ) )
	{			
		if ( self.rankUpdateTotal < 0 )
		{
			self.hud_rankscroreupdate.label = &"";
			self.hud_rankscroreupdate.color = (1,0,0);
		}
		else
		{
			self.hud_rankscroreupdate.label = &"MP_PLUS";
			self.hud_rankscroreupdate.color = (1,1,0.5);
		}

		self.hud_rankscroreupdate setValue(self.rankUpdateTotal);
		self.hud_rankscroreupdate.alpha = 0.85;
		self.hud_rankscroreupdate thread maps\mp\gametypes\_hud::fontPulse( self );

		wait 1;
		self.hud_rankscroreupdate fadeOverTime( 0.75 );
		self.hud_rankscroreupdate.alpha = 0;
		
		self.rankUpdateTotal = 0;
	}
}

removeRankHUD()
{
	if(isDefined(self.hud_rankscroreupdate))
		self.hud_rankscroreupdate.alpha = 0;
}

getRank()
{	
	rankXp = self.pers["rankxp"];
		return self getRankForXp( rankXp );
}

getRankForXp( xpVal )
{
	rankId = 0;
	rankName = level.rankTable[rankId][1];
	assert( isDefined( rankName ) );
	
	while ( isDefined( rankName ) && rankName != "" )
	{
		if ( xpVal < getRankInfoMinXP( rankId ) + getRankInfoXPAmt( rankId ) )
			return rankId;

		rankId++;
		if ( isDefined( level.rankTable[rankId] ) )
			rankName = level.rankTable[rankId][1];
		else
			rankName = undefined;
	}
	
	rankId--;
	return rankId;
}

getSPM()
{
	rankLevel = (self getRank() % 61) + 1;
	return 3 + ( rankLevel * 0.5 );
}

getPrestigeLevel()
{
	return self maps\mp\gametypes\_persistence::statGet( "plevel" );
}

getRankXP()
{
	return self.pers["rankxp"];
}

incRankXP( amount )
{	
	xp = self getRankXP();
	newXp = (xp + amount);

	if ( self.pers["rank"] == level.maxRank && newXp >= getRankInfoMaxXP( level.maxRank ) )
		newXp = getRankInfoMaxXP( level.maxRank );

	self.pers["rankxp"] = newXp;
	self maps\mp\gametypes\_persistence::statSet( "rankxp", newXp );
}

// Decrease
decRankXP( amount )
{	
	xp = self getRankXP();
	newXp = (xp - amount);

	if ( self.pers["rank"] == level.minRank && newXp <= getRankInfoMinXP( level.minRank ) )
		newXp = getRankInfoMinXP( level.minRank );

	self.pers["rankxp"] = newXp;
	self maps\mp\gametypes\_persistence::statSet( "rankxp", newXp );
}

newincRankXP( value )
{
	self endon("disconnect");
	self thread updateRankScoreHUD( value );
	self incRankXP( value );
}

takeRankXP( value )
{
self endon("disconnect");
	
	self decRankXP( value );

	self setClientDvars("player_summary_xp", self.pers["summary"]["xp"],
			"player_summary_score", self.pers["summary"]["score"],
			"player_summary_challenge", self.pers["summary"]["challenge"],
			"player_summary_match", self.pers["summary"]["match"],
			"player_summary_misc", self.pers["summary"]["misc"]);
	if ( updateRank() )
		self thread updateRankAnnounceHUD();
}

raiseRankXP( value )
{
self endon("disconnect");
	
	self IncRankXP( value );

	self setClientDvars("player_summary_xp", self.pers["summary"]["xp"],
			"player_summary_score", self.pers["summary"]["score"],
			"player_summary_challenge", self.pers["summary"]["challenge"],
			"player_summary_match", self.pers["summary"]["match"],
			"player_summary_misc", self.pers["summary"]["misc"]);
}
