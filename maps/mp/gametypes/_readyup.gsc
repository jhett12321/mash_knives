#include maps\mp\_utility;
#include maps\mp\gametypes\_hud_util;
#include common_scripts\utility;
#include maps\mp\_mashutil;

start()
{
	 // Get the main module's dvar
	 level.scr_match_readyup_period = getdvarx( "scr_scrimmode", "int", 0, 0, 1 );

	 // If readyup period is disabled then there's nothing else to do here
	 if ( level.scr_match_readyup_period == 0 ) {
			level.inReadyUpPeriod = false;
			return;
	 }

	 // Check if it's coming back after restarting the map
	 if ( isDefined( game["readyupperiod"] ) && game["readyupperiod"] ) {
			game["readyupperiod"] = false;
			return;
	 }

	 makeDvarServerInfo( "ui_hud_hardcore", level.hardcoreMode );
	 setDvar( "ui_hud_hardcore", level.hardcoreMode );

	 // We are officially in readyup period
	 level.inReadyUpPeriod = true;
	 game["readyupperiod"] = true;

	 // Precache some resources we'll be using
	 precacheString( &"MASH_READYUP_PERIOD" );
	 precacheString( &"MASH_READYUP_PERIOD_ROUND" );
	 precacheString( &"MASH_READYUP_READY" );
	 precacheString( &"MASH_READYUP_NOT_READY" );
	 precacheString( &"MASH_READYUP_PRESS_TO_TOGGLE" );
	 precacheString( &"MASH_READYUP_ALL_PLAYERS_READY" );
	 precacheString( &"MASH_READYUP_WAITING_FOR_MORE_PLAYERS" );
	 precacheStatusIcon( "hud_status_ready" );
	 precacheStatusIcon( "hud_status_notready" );

	 // Show the player we are in ready up period
	 game["readyUpPeriod"] = createServerFontString( "objective", 2.4 );
	 game["readyUpPeriod"].archived = false;
	 game["readyUpPeriod"].hideWhenInMenu = true;
	 game["readyUpPeriod"].alignX = "center";
	 game["readyUpPeriod"].alignY = "top";
	 game["readyUpPeriod"].horzAlign = "center";
	 game["readyUpPeriod"].vertAlign = "top";
	 game["readyUpPeriod"].sort = -1;
	 game["readyUpPeriod"].x = 0;
	 game["readyUpPeriod"].y = 60;
	 if( game["roundsplayed"] ) {
			game["readyUpPeriod"] setText( &"MASH_READYUP_PERIOD_ROUND" );
	 } else {
			game["readyUpPeriod"] setText( &"MASH_READYUP_PERIOD" );
	 }

	 // Let's wait until we have enough players to start a match
	 level.waitingForPlayers = true;

	 // Make sure the server has a password or inform the players in case it doesn't
	 thread checkServerPassword();

	 // Make sure we have enough players
	 waitForPlayers();

	 // Create the HUD elements
	 createHudElements();


	 // Let's wait until all players are ready to start the match
	 while ( level.inReadyUpPeriod )
	 {
			wait (0.05);

			// Initialize counters
			readyUpNotReady[ "allies" ] = 0;
			readyUpNotReady[ "axis" ] = 0;

			// Check all the players
			for ( index = 0; index < level.players.size; index++ )
			{
				 player = level.players[index];

				 // Start the monitoring thread if this player doesn't have it running
				 if ( !isDefined( player.readyUpPeriod ) && !( player.pers["team"] == "spectator" && !issubstr( level.scr_game_spectate_freelook_guids, player getGuid() ) ) ) {
						player.matchReady = false;
						player thread readyUpPeriod();
				 }

				 // Get the players team
				 playerTeam = player.pers["team"];

				 // Check type of player
				 if ( playerTeam == "spectator" ) {
				 } else {
						if ( !isDefined( player.matchReady ) || !player.matchReady ) {
							 readyUpNotReady[ playerTeam ]++;
						}
				 }
			}

			// If there are no players "not ready" then ready up period is over
			if ( readyUpNotReady[ "allies" ] == 0 && readyUpNotReady[ "axis" ] == 0 ) {
				 level.inReadyUpPeriod = false;
			}

			// Update the HUD elements
			// Display the amount of players in the allies team not ready
			game["readyUpTextAlliesNotReady"] setText( readyUpNotReady[ "allies" ] );
			if ( readyUpNotReady[ "allies" ] == 0 ) {
				 game["readyUpTextAlliesNotReady"].color = ( 0.07, 0.69, 0.26 );
			} else {
				 game["readyUpTextAlliesNotReady"].color = ( 0.694, 0.220, 0.114 );
			}

			// Display the amount of players in the allies team not ready
			game["readyUpTextAxisNotReady"] setText( readyUpNotReady[ "axis" ] );
			if ( readyUpNotReady[ "axis" ] == 0 ) {
				 game["readyUpTextAxisNotReady"].color = ( 0.07, 0.69, 0.26 );
			} else {
				 game["readyUpTextAxisNotReady"].color = ( 0.694, 0.220, 0.114 );
			}
	 }

	 level notify("readyupperiod_ended");

	 visionSetNaked( "mpIntro", 1.0 );

	 // Destroy the HUD elements
	 destroyHudElements();

	 wait (1.0);

	 // Restart the map and go to match start timer
	 map_restart( true );

	 wait (1.0);
}


readyUpPeriod()
{
	 self endon("disconnect");

	 if ( self.pers["team"] == "spectator" )
			return;

	 self.readyUpPeriod = true;

	 // Wait until waiting for players is over
	 while ( level.waitingForPlayers )
			wait (0.05);

	 // Create the HUD element that will show the player if is ready or not
	 self.readyUpText = createFontString( "objective", 2.0 );
	 self.readyUpText setPoint( "CENTER", "CENTER", 0, 0 );
	 self.readyUpText.sort = 1001;
	 self.readyUpText.foreground = false;
	 self.readyUpText.hidewheninmenu = true;

	 // Create the press USE key to toggle the readiness status
	 self.readyUpToggleText = createFontString( "default", 2.0 );
	 self.readyUpToggleText setPoint( "CENTER", "CENTER", 0, 30 );
	 self.readyUpToggleText.sort = 1001;
	 self.readyUpToggleText.foreground = false;
	 self.readyUpToggleText.hidewheninmenu = true;
	 self.readyUpToggleText setText( &"MASH_READYUP_PRESS_TO_TOGGLE" );

	 // We are going to monitor this player until the readyup period ends
	 keyDown = false;

	 while ( level.inReadyUpPeriod && !( self.pers["team"] == "spectator" && !issubstr( level.scr_game_spectate_freelook_guids, self getGuid() ) ) )
	 {
			wait (0.05);

			// Check if the player hit the use key
			if ( self useButtonPressed() ) {
				 // Toggle the status
				 self.matchReady = !self.matchReady;
				 keyDown = true;
			}

			// Check if there was a status change and update the player status
			if ( self.matchReady && self.statusicon != "hud_status_ready" ) {
				 self.statusicon = "hud_status_ready";
				 self.readyUpText.color = ( 0.07, 0.69, 0.26 );
				 self.readyUpText setText( &"MASH_READYUP_READY" );
			}
			if ( !self.matchReady && self.statusicon != "hud_status_notready" ) {
				 self.statusicon = "hud_status_notready";
				 self.readyUpText.color = ( 0.694, 0.220, 0.114 );
				 self.readyUpText setText( &"MASH_READYUP_NOT_READY" );
			}

			// If the player pressed the use key then we have to wait until the key is released
			if ( keyDown ) {
				 // Wait until the player releases the key or readyup period is over
				 while ( level.inReadyUpPeriod && self useButtonPressed() ) {
						wait (0.05);
				 }
				 keyDown = false;
			}
	 }

	 // Clear the HUD elements
	 if ( isDefined( self.readyUpText ) )
			self.readyUpText destroy();

	 if ( isDefined( self.readyUpToggleText ) )
			self.readyUpToggleText destroy();

	 self notify("readyupperiod_ended");
	 self.readyUpPeriod = undefined;
}


waitForPlayers()
{
	 // Create the HUD element so players know we are waiting for more players
	 waitingForPlayersText = createServerFontString( "objective", 1.8 );
	 waitingForPlayersText setPoint( "CENTER", "CENTER", 0, 0 );
	 waitingForPlayersText.sort = 1001;
	 waitingForPlayersText.foreground = false;
	 waitingForPlayersText.hidewheninmenu = true;
	 waitingForPlayersText.color = ( 1.0, 1.0, 0.5 );
	 waitingForPlayersText setText( &"MASH_READYUP_WAITING_FOR_MORE_PLAYERS" );

	 while ( level.waitingForPlayers )
	 {
			wait (0.05);
			players[ "allies" ] = 0;
			players[ "axis" ] = 0;
			players[ "spectator" ] = 0;

			for ( index = 0; index < level.players.size; index++ )
			{
				 player = level.players[index];
				 // Get the players team
				 playerTeam = player.pers[ "team" ];
				 players[ playerTeam ]++;

				 // Check if we have players on both teams
				 if ( level.teamBased ) {
						if ( players[ "allies" ] > 0 && players[ "axis" ] > 0 ) {
							 level.waitingForPlayers = false;
							 break;
						}
				 } else {
						// Or if we have more than 1 players for FFA
						if ( ( players[ "allies" ] + players[ "axis" ] ) >= 2 ) {
							 level.waitingForPlayers = false;
							 break;
						}
				 }
			}
	 }

	 // Destroy the HUD element
	 waitingForPlayersText destroy();
	 level.waitingForPlayers = false;
}

checkServerPassword()
{
	 // Make sure the server has no password before doing anything else
	 if ( getdvar("g_password") != "" )
			return;

	 // Create the HUD element
	 serverNoPassword = createServerFontString( "objective", 1.8 );
	 serverNoPassword.archived = false;
	 serverNoPassword.hideWhenInMenu = true;
	 serverNoPassword.alignX = "center";
	 serverNoPassword.alignY = "top";
	 serverNoPassword.horzAlign = "center";
	 serverNoPassword.vertAlign = "top";
	 serverNoPassword.sort = -1;
	 serverNoPassword.x = 0;
	 serverNoPassword.y = 86;
	 serverNoPassword.alpha = 1;
	 serverNoPassword.color = ( 0.694, 0.220, 0.114 );
	 serverNoPassword setText( &"MASH_READYUP_NOPASSWORD" );

	 oldTime = gettime();

	 // Loop until the ready-up period is over
	 while ( level.inReadyUpPeriod ) {
			wait (0.05);

			// Check if we have a password
			if ( getdvar("g_password") == "" ) {
				 // Make the message blink so it really catches the players' attention
				 if ( gettime() - oldTime >= 500 ) {
						oldTime = gettime();
						serverNoPassword.alpha = !serverNoPassword.alpha;
				 }
			} else {
				 serverNoPassword.alpha = 0;
			}
	 }

	 // Destroy the HUD element
	 serverNoPassword destroy();

	 return;
}


destroyHudElements()
{
	 // Allies
	 game["readyUpIconAllies"] destroy();
	 game["readyUpTextAlliesNotReady"] destroy();

	 // Axis
	 game["readyUpIconAxis"] destroy();
	 game["readyUpTextAxisNotReady"] destroy();

	 // Misc
	 game["readyUpPeriod"] destroy();
}


createHudElements()
{
	 // Create the elements to show the allies readiness status
	 game["readyUpIconAllies"] = createServerIcon( game["icons"]["allies"], 64, 64 );
	 game["readyUpIconAllies"].archived = false;
	 game["readyUpIconAllies"].hideWhenInMenu = true;
	 game["readyUpIconAllies"].alignX = "center";
	 game["readyUpIconAllies"].alignY = "bottom";
	 game["readyUpIconAllies"].horzAlign = "center";
	 game["readyUpIconAllies"].vertAlign = "middle";
	 game["readyUpIconAllies"].sort = -3;
	 game["readyUpIconAllies"].alpha = 0.9;
	 game["readyUpIconAllies"].x = -90;
	 game["readyUpIconAllies"].y = -30;

	 game["readyUpTextAlliesNotReady"] = createServerFontString( "objective", 1.5 );
	 game["readyUpTextAlliesNotReady"].archived = false;
	 game["readyUpTextAlliesNotReady"].hideWhenInMenu = true;
	 game["readyUpTextAlliesNotReady"].alignX = "right";
	 game["readyUpTextAlliesNotReady"].alignY = "bottom";
	 game["readyUpTextAlliesNotReady"].horzAlign = "center";
	 game["readyUpTextAlliesNotReady"].vertAlign = "middle";
	 game["readyUpTextAlliesNotReady"].sort = -1;
	 game["readyUpTextAlliesNotReady"].x = -60;
	 game["readyUpTextAlliesNotReady"].y = -30;


	 // Create the elements to show the axis readiness status
	 game["readyUpIconAxis"] = createServerIcon( game["icons"]["axis"], 64, 64 );
	 game["readyUpIconAxis"].archived = false;
	 game["readyUpIconAxis"].hideWhenInMenu = true;
	 game["readyUpIconAxis"].alignX = "center";
	 game["readyUpIconAxis"].alignY = "bottom";
	 game["readyUpIconAxis"].horzAlign = "center";
	 game["readyUpIconAxis"].vertAlign = "middle";
	 game["readyUpIconAxis"].sort = -3;
	 game["readyUpIconAxis"].alpha = 0.9;
	 game["readyUpIconAxis"].x = 90;
	 game["readyUpIconAxis"].y = -30;

	 game["readyUpTextAxisNotReady"] = createServerFontString( "objective", 1.5 );
	 game["readyUpTextAxisNotReady"].archived = false;
	 game["readyUpTextAxisNotReady"].hideWhenInMenu = true;
	 game["readyUpTextAxisNotReady"].alignX = "right";
	 game["readyUpTextAxisNotReady"].alignY = "bottom";
	 game["readyUpTextAxisNotReady"].horzAlign = "center";
	 game["readyUpTextAxisNotReady"].vertAlign = "middle";
	 game["readyUpTextAxisNotReady"].sort = -1;
	 game["readyUpTextAxisNotReady"].x = 120;
	 game["readyUpTextAxisNotReady"].y = -30;

	 return;
}


waitForReadyUpToFinish()
{
	 if ( getdvarx( "scr_scrimmode", "int", 0, 0, 1 ) == 0 ) {
			return;
	 } else {
			while ( !isDefined( game["readyupperiod"] ) || game["readyupperiod"] )
				 wait (0.05);

			return;
	 }
}