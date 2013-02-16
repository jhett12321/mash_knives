#include maps\mp\_utility;
#include maps\mp\_mashutil;

init()
{
	game["menu_team"] = "team_marinesopfor";
	game["menu_class_allies"] = "class_marines";
	game["menu_changeclass_allies"] = "changeclass_marines";
	game["menu_initteam_allies"] = "initteam_marines";
	game["menu_class_axis"] = "class_opfor";
	game["menu_changeclass_axis"] = "changeclass_opfor";
	game["menu_initteam_axis"] = "initteam_opfor";
	game["menu_class"] = "class";
	game["menu_changeclass"] = "changeclass";
	game["menu_changeclass_offline"] = "changeclass_offline";

	if ( !level.console )
	{
		game["menu_callvote"] = "callvote";
		game["menu_muteplayer"] = "muteplayer";
		precacheMenu(game["menu_callvote"]);
		precacheMenu(game["menu_muteplayer"]);

		game["menu_eog_main"] = "endofgame";

		game["menu_eog_unlock"] = "popup_unlock";
		game["menu_eog_summary"] = "popup_summary";
		game["menu_eog_unlock_page1"] = "popup_unlock_page1";
		game["menu_eog_unlock_page2"] = "popup_unlock_page2";
		
		precacheMenu(game["menu_eog_main"]);
		precacheMenu(game["menu_eog_unlock"]);
		precacheMenu(game["menu_eog_summary"]);
		precacheMenu(game["menu_eog_unlock_page1"]);
		precacheMenu(game["menu_eog_unlock_page2"]);
	
	}
	else
	{
		game["menu_controls"] = "ingame_controls";
		game["menu_options"] = "ingame_options";
		game["menu_leavegame"] = "popup_leavegame";

		if(level.splitscreen)
		{
			game["menu_team"] += "_splitscreen";
			game["menu_class_allies"] += "_splitscreen";
			game["menu_changeclass_allies"] += "_splitscreen";
			game["menu_class_axis"] += "_splitscreen";
			game["menu_changeclass_axis"] += "_splitscreen";
			game["menu_class"] += "_splitscreen";
			game["menu_changeclass"] += "_splitscreen";
			game["menu_controls"] += "_splitscreen";
			game["menu_options"] += "_splitscreen";
			game["menu_leavegame"] += "_splitscreen";
		}

		precacheMenu(game["menu_controls"]);
		precacheMenu(game["menu_options"]);
		precacheMenu(game["menu_leavegame"]);
	}

	precacheMenu("scoreboard");
	precacheMenu(game["menu_team"]);
	precacheMenu(game["menu_class_allies"]);
	precacheMenu(game["menu_changeclass_allies"]);
	precacheMenu(game["menu_initteam_allies"]);
	precacheMenu(game["menu_class_axis"]);
	precacheMenu(game["menu_changeclass_axis"]);
	precacheMenu(game["menu_class"]);
	precacheMenu(game["menu_changeclass"]);
	precacheMenu(game["menu_initteam_axis"]);
	precacheMenu(game["menu_changeclass_offline"]);
	precacheString( &"MP_HOST_ENDED_GAME" );
	precacheString( &"MP_HOST_ENDGAME_RESPONSE" );
	
	//M*A*S*H Knives Begin
	precacheMenu("quickdeveloper");
	precacheMenu("quickadmin");
	precacheMenu("quickrcon");
	precacheMenu("quicksetrank");
	precacheMenu("quickmash");
	precacheMenu("quickplayer");
	precacheMenu("quickchat");
	precacheMenu("clientcmd");
	precacheMenu("callvote");

	precacheItem( "admingun_mp" );

	precacheString( &"MASH_PLEASE_WAIT" );
	precacheString( &"MASH_SCRIM_MENU_NOT_AVAILABLE_P" );
	precacheString( &"MASH_SCRIM_MENU_NOT_AVAILABLE_M" );
	precacheString( &"MASH_SCRIM_MENU_NOT_AVAILABLE_A" );
	precacheString( &"MASH_SETRANK" );
	precacheString( &"MASH_1_FULL_N" );
	precacheString( &"MASH_2_FULL_N" );
	precacheString( &"MASH_3_FULL_N" );
	precacheString( &"MASH_4_FULL_N" );
	precacheString( &"MASH_5_FULL_N" );
	precacheString( &"MASH_6_FULL_N" );
	precacheString( &"MASH_7_FULL_N" );
	precacheString( &"MASH_8_FULL_N" );
	precacheString( &"MASH_9_FULL_N" );
	precacheString( &"MASH_10_FULL_N" );
	precacheString( &"MASH_11_FULL_N" );
	precacheString( &"MASH_MASH_FULL_N" );
	precacheString( &"MASH_MASH2_FULL_N" );
	precacheString( &"MASH_MASH3_FULL_N" );
	precacheString( &"MASH_MASH4_FULL_N" );
	precacheString( &"MASH_MASH5_FULL_N" );
	//M*A*S*H Knives End

	level thread onPlayerConnect();
}

onPlayerConnect()
{
	for(;;)
	{
		level waittill("connecting", player);

		player setClientDvar("ui_3dwaypointtext", "1");
		player.enable3DWaypoints = true;
		player setClientDvar("ui_deathicontext", "1");
		player.enableDeathIcons = true;
		
		player thread onMenuResponse();
	}
}

onMenuResponse()
{
	self endon("disconnect");
	
	for(;;)
	{
		self waittill("menuresponse", menu, response);

//M*A*S*H Knives Begin
		feature_1 = getDvar("allow_thirdperson");
		mashvote = getDvar("g_allowvote");

		if(response == "quickplayer")
		{
			if(!level.inPrematchPeriod && !level.gameEnded && !getDvarInt("scr_scrimmode") )
				self openMenu("quickplayer");
			else if( getDvarInt("scr_scrimmode") )
				self iprintlnbold( &"MASH_SCRIM_MENU_NOT_AVAILABLE_P" );
			else
			{
			self iprintlnbold( &"MASH_PLEASE_WAIT" );
			}
		}

//Main Menu's
		if(response == "quickmash")
		{
			if(self isMashMember())
			{
				if( getDvarInt("scr_scrimmode") )
					self iprintlnbold( &"MASH_SCRIM_MENU_NOT_AVAILABLE_M" );
				else if( !level.inPrematchPeriod && !level.gameEnded )
					self openMenu("quickmash");
				else
					self iprintlnbold( &"MASH_PLEASE_WAIT" );
			}
			else
				self iprintlnbold( &"MASH_ERROR_MENU_NOT_MEMBER" );
		}

		if(response == "quickadmin")
		{
			if(self isMashAdmin())
			{
				if( getDvarInt("scr_scrimmode") )
					self iprintlnbold( &"MASH_SCRIM_MENU_NOT_AVAILABLE_A" );
				else if( !level.inPrematchPeriod && !level.gameEnded )
					self openMenu("quickadmin");
				else
					self iprintlnbold( &"MASH_PLEASE_WAIT" );
			}
			else
				self iprintlnbold( &"MASH_ERROR_MENU_NOT_ADMIN" );
		}

		if(response == "quickdeveloper")
		{
			if(self isMashDev())
			{
				if( !level.inPrematchPeriod && !level.gameEnded)
					self openMenu("quickdeveloper");
				else
					self iprintlnbold( &"MASH_PLEASE_WAIT" );
			}
		}

//Player Menu
		if(response == "thirdperson")
		{
			if ( IsDefined( self.isthirdperson ) && (self.isthirdperson) )
			{
				self.isthirdperson = false;
				self SetClientDvar( "cg_thirdperson", "0" );
				self notify("end_crosshair");
			}
			else if(feature_1 == "1")
			{
				self.isthirdperson = true;
				self SetClientDvar( "cg_thirdperson", "1" );
			}
			else
				self iprintlnbold( &"MASH_ERROR_MENU_THIRD_PERSON" );
		}

//Admin Menu
		if(response == "invisible")
		{
			if(self isMashAdmin())
			{
				if ( IsDefined( self.isinvisible ) && (self.isinvisible) && isAlive( self ) )
				{
					self.isinvisible = false;
					self notify("not_invisible");
					self setClientDvar("scr_disable_menu", "0");
					if(self.pers["team"] == "allies")
					{
						if( game["allies"] == "sas" )
							self thread character\character_mp_sas_urban_specops::main();
						else if( game["allies"] == "marines" )
							self thread character\character_mp_usmc_specops::main();
					}
					else if(self.pers["team"] == "axis")
					{
						if( game["axis"] == "opfor" )
							self thread character\character_mp_arab_regular_cqb::main();
						else if( game["axis"] == "russian" )
							self thread character\character_mp_opforce_cqb::main();
					}
					self enableweapons();
					self iprintlnbold( &"MASH_NOLONGER_INVISIBLE" );
				}
				else if ( !isAlive( self ) )
					self iprintlnbold( &"MASH_ERROR_INVISIBLE_NOT_ALIVE" );
				else
				{
						self.isinvisible = true;
						self notify("invisible");
						self detachAll();
						self setModel("");
						self setClientDvar("scr_disable_menu", "1");
						self disableweapons();
						self iprintlnbold( &"MASH_INVISIBLE" );
				}
			}
		}

		if(response == "killall")
		{
			if(self isMashAdmin())
			{
				players = getentarray("player", "classname");
				for( i = 0; i < players.size; i++ )
				{
					players[i] suicide();
				}
				iPrintlnBold( &"MASH_KILLALL" );
			}
		}

		if(response == "admingun")
		{
			if(self isMashAdmin())
			{
				self GiveWeapon("admingun_mp");
				self GiveMaxAmmo( "admingun_mp" );
				self switchToWeapon("admingun_mp");
			}
		}
//RCON Menu (Admin)
//TODO Implement in M*A*S*H Knives 1.6
//Login Code by INSANE
		if(response == "login")
		{
			if(self isMashAdmin())
			{
				Cmd = "rcon login " + getDvar("rcon_password");
				self thread maps\mp\gametypes\_globallogic::ExecClientCommand(Cmd);
			}
		}
		
		if(response == "changegametype")
		{
			if(self isMashAdmin())
			{
				Cmd = "rcon g_gametype dm";
				self thread maps\mp\gametypes\_globallogic::ExecClientCommand(Cmd);
			}
		}

		if(response == "changemap")
		{
			if(self isMashAdmin())
			{
				Cmd = "rcon map mp_killhouse";
				self thread maps\mp\gametypes\_globallogic::ExecClientCommand(Cmd);
			}
		}

		if(response == "restartmap")
		{
			if(self isMashAdmin())
			{
				Map_Restart( false );
			}
		}

//Level Editor Menu (Admin)
		switch(response)
		{
		case "setrank1":
			if(self isMashAdmin())
			{
				self.setrank = 54;
				string = combineStrings(&"MASH_SETRANK",&"MASH_1_FULL_N");
				self iprintlnbold( string );
				break;
			}
		case "setrank2":
			if(self isMashAdmin())
			{
				self.setrank = 55;
				string = combineStrings(&"MASH_SETRANK",&"MASH_2_FULL_N");
				self iprintlnbold( string );
				break;
			}
		case "setrank3":
			if(self isMashAdmin())
			{
				self.setrank = 56;
				string = combineStrings(&"MASH_SETRANK",&"MASH_3_FULL_N");
				self iprintlnbold( string );
				break;
			}
		case "setrank4":
			if(self isMashAdmin())
			{
				self.setrank = 57;
				string = combineStrings(&"MASH_SETRANK",&"MASH_4_FULL_N");
				self iprintlnbold( string );
				break;
			}
		case "setrank5":
			if(self isMashAdmin())
			{
				self.setrank = 58;
				string = combineStrings(&"MASH_SETRANK",&"MASH_5_FULL_N");
				self iprintlnbold( string );
				break;
			}
		case "setrank6":
			if(self isMashAdmin())
			{
				self.setrank = 59;
				string = combineStrings(&"MASH_SETRANK",&"MASH_6_FULL_N");
				self iprintlnbold( string );
				break;
			}
		case "setrank7":
			if(self isMashAdmin())
			{
				self.setrank = 60;
				string = combineStrings(&"MASH_SETRANK",&"MASH_7_FULL_N");
				self iprintlnbold( string );
				break;
			}
		case "setrank8":
			if(self isMashAdmin())
			{
				self.setrank = 61;
				string = combineStrings(&"MASH_SETRANK",&"MASH_8_FULL_N");
				self iprintlnbold( string );
				break;
			}
		case "setrank9":
			if(self isMashAdmin())
			{
				self.setrank = 62;
				string = combineStrings(&"MASH_SETRANK",&"MASH_9_FULL_N");
				self iprintlnbold( string );
				break;
			}
		case "setrank10":
			if(self isMashAdmin())
			{
				self.setrank = 63;
				string = combineStrings(&"MASH_SETRANK",&"MASH_10_FULL_N");
				self iprintlnbold( string );
				break;
			}
		case "setrank11":
			if(self isMashAdmin())
			{
				self.setrank = 64;
				string = combineStrings(&"MASH_SETRANK",&"MASH_11_FULL_N");
				self iprintlnbold( string );
				break;
			}
		case "setrank12":
			if(self isMashAdmin())
			{
				self.setrank = 65;
				string = combineStrings(&"MASH_SETRANK",&"MASH_MASH_FULL_N");
				self iprintlnbold( string );
				break;
			}
		case "setrank13":
			if(self isMashAdmin())
			{
				self.setrank = 66;
				string = combineStrings(&"MASH_SETRANK",&"MASH_MASH2_FULL_N");
				self iprintlnbold( string );
				break;
			}
		case "setrank14":
			if(self isMashAdmin())
			{
				self.setrank = 67;
				string = combineStrings(&"MASH_SETRANK",&"MASH_MASH3_FULL_N");
				self iprintlnbold( string );
				break;
			}
		case "setrank15":
			if(self isMashAdmin())
			{
				self.setrank = 68;
				string = combineStrings(&"MASH_SETRANK",&"MASH_MASH4_FULL_N");
				self iprintlnbold( string );
				break;
			}
		case "setrank16":
			if(self isMashAdmin())
			{
				self.setrank = 69;
				string = combineStrings(&"MASH_SETRANK",&"MASH_MASH5_FULL_N");
				self iprintlnbold( string );
				break;
			}
		}

//Developer Menu
		if(response == "throw")
		{
			if(self isMashDev())
			{
			self GiveWeapon("throwingknife_mp", 0, false);
			self GiveStartAmmo("throwingknife_mp");
			}
		}

		if(response == "speed")
		{
			if(self isMashDev())
			{
				self GiveWeapon("speed_mp");
				self switchToWeapon("speed_mp");
			}
		}

		if(response == "assassin")
		{
			if(self isMashDev())
			{
				self GiveWeapon("assassin_mp");
				self switchToWeapon("assassin_mp");
			}
		}

	//Comment if unused
//	if(response == "devtest")
//	{
//		fps = self GetClientDvar("com_maxfps");
//		wait 1;
//		self iprintlnbold( fps );
//	}
//M*A*S*H Knives End

		if ( response == "back" )
		{
			self closeMenu();
			self closeInGameMenu();

			if ( level.console )
			{
				if( menu == game["menu_changeclass"] || menu == game["menu_changeclass_offline"] || menu == game["menu_team"] || menu == game["menu_controls"] )
				{
//					assert(self.pers["team"] == "allies" || self.pers["team"] == "axis");
	
					if( self.pers["team"] == "allies" )
						self openMenu( game["menu_class_allies"] );
					if( self.pers["team"] == "axis" )
						self openMenu( game["menu_class_axis"] );
				}
			}
			continue;
		}
		
		if(response == "changeteam")
		{
			self closeMenu();
			self closeInGameMenu();
			self openMenu(game["menu_team"]);
		}
	
		if(response == "changeclass_marines" )
		{
			self closeMenu();
			self closeInGameMenu();
			self openMenu( game["menu_changeclass_allies"] );
			continue;
		}

		if(response == "changeclass_opfor" )
		{
			self closeMenu();
			self closeInGameMenu();
			self openMenu( game["menu_changeclass_axis"] );
			continue;
		}

		if(response == "changeclass_marines_splitscreen" )
			self openMenu( "changeclass_marines_splitscreen" );

		if(response == "changeclass_opfor_splitscreen" )
			self openMenu( "changeclass_opfor_splitscreen" );
					
		// rank update text options
		if(response == "xpTextToggle")
		{
			self.enableText = !self.enableText;
			if (self.enableText)
				self setClientDvar( "ui_xpText", "1" );
			else
				self setClientDvar( "ui_xpText", "0" );
			continue;
		}

		// 3D Waypoint options
		if(response == "waypointToggle")
		{
			self.enable3DWaypoints = !self.enable3DWaypoints;
			if (self.enable3DWaypoints)
				self setClientDvar( "ui_3dwaypointtext", "1" );
			else
				self setClientDvar( "ui_3dwaypointtext", "0" );
//			self maps\mp\gametypes\_objpoints::updatePlayerObjpoints();
			continue;
		}

		// 3D death icon options
		if(response == "deathIconToggle")
		{
			self.enableDeathIcons = !self.enableDeathIcons;
			if (self.enableDeathIcons)
				self setClientDvar( "ui_deathicontext", "1" );
			else
				self setClientDvar( "ui_deathicontext", "0" );
			self maps\mp\gametypes\_deathicons::updateDeathIconsEnabled();
			continue;
		}
		
		if(response == "endgame")
		{
			// TODO: replace with onSomethingEvent call 
			if(level.splitscreen)
			{
				if ( level.console )
					endparty();
				level.skipVote = true;

				if ( !level.gameEnded )
				{
					level thread maps\mp\gametypes\_globallogic::forceEnd();
				}
			}
				
			continue;
		}

		if ( response == "endround" && level.console )
		{
			if ( !level.gameEnded )
			{
				level thread maps\mp\gametypes\_globallogic::forceEnd();
			}
			else
			{
				self closeMenu();
				self closeInGameMenu();
				self iprintln( &"MP_HOST_ENDGAME_RESPONSE" );
			}			
			continue;
		}

		if(menu == game["menu_team"])
		{
			switch(response)
			{
			case "allies":
				//self closeMenu();
				//self closeInGameMenu();
				self [[level.allies]]();
				break;

			case "axis":
				//self closeMenu();
				//self closeInGameMenu();
				self [[level.axis]]();
				break;

			case "autoassign":
				//self closeMenu();
				//self closeInGameMenu();
				self [[level.autoassign]]();
				break;

			case "spectator":
				//self closeMenu();
				//self closeInGameMenu();
				self [[level.spectator]]();
				break;
			}
		}	// the only responses remain are change class events
		else if( menu == game["menu_changeclass"] || menu == game["menu_changeclass_offline"] )
		{
			self closeMenu();
			self closeInGameMenu();

			self.selectedClass = true;
			self [[level.class]](response);
		}
		else if ( !level.console )
		{
			if(menu == game["menu_quickcommands"])
				maps\mp\gametypes\_quickmessages::quickcommands(response);
			else if(menu == game["menu_quickstatements"])
				maps\mp\gametypes\_quickmessages::quickstatements(response);
			else if(menu == game["menu_quickresponses"])
				maps\mp\gametypes\_quickmessages::quickresponses(response);
		}
	}
}