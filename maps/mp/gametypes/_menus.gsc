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
	
	//M*A*S*H
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

		feature_1 = getDvar("allow_thirdperson");
		mashvote = getDvar("g_allowvote");

	if(response == "quickdeveloper")
	{
		if(self isMashDev())
		{
			if( !level.inPrematchPeriod && !level.gameEnded)
			{
				self openMenu("quickdeveloper");
			}
			else
			{
			self iprintlnbold( "^2Please wait." );
			}
		}
	}
	
	if(response == "quickadmin")
	{
		if(self isMashAdmin())
		{
			if(self getguid() == "")
			{
				self iprintlnbold( "^2You are not an ^1Admin!" );
			}
			else if( getDvarInt("scr_scrimmode") )
			{
				self iprintlnbold( "^2Admin Menu not available in Scrim Mode." );
			}
			else if( !level.inPrematchPeriod && !level.gameEnded )
			{
				self openMenu("quickadmin");
			}
			else
			{
			self iprintlnbold( "^2Please wait." );
			}
		}
		else
		self iprintlnbold( "^2You are not an ^1Admin!" );
	}
	
	if(response == "quickmash")
	{
		if(self isMashMember())
		{
			if(self getguid() == "")
				self iprintlnbold( "^2You are not a ^1M*A*S*H Member" );

			else if( !level.inPrematchPeriod && !level.gameEnded )
				self openMenu("quickmash");

			else
				self iprintlnbold( "^2Please wait." );

		}
		else
			self iprintlnbold( "^2You are not a ^1M*A*S*H Member" );
	}

	if(response == "quickplayer")
	{
		if(!level.inPrematchPeriod && !level.gameEnded && !getDvarInt("scr_scrimmode") )
		{
			self openMenu("quickplayer");
		}
		else if( getDvarInt("scr_scrimmode") )
		{
			self iprintlnbold( "^2Player Menu not available in Scrim Mode." );
		}
		else
		{
		self iprintlnbold( "^2Please wait." );
		}
	}
	
	//Comment if unused
//	if(response == "devtest")
//	{
//		fps = self GetClientDvar("com_maxfps");
//		wait 1;
//		self iprintlnbold( fps );
//	}

		if(response == "admingun")
		{
			if(self isMashAdmin())
			{
				self GiveWeapon("admingun_mp");
				self GiveMaxAmmo( "admingun_mp" );
				self switchToWeapon("admingun_mp");
			}
		}

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
					{
					self thread character\character_mp_sas_urban_specops::main();
					}
					else if( game["allies"] == "marines" )
					{
					self thread character\character_mp_usmc_specops::main();
					}
				}
				else if(self.pers["team"] == "axis")
				{
					if( game["axis"] == "opfor" )
					{
					self thread character\character_mp_arab_regular_cqb::main();
					}
					else if( game["axis"] == "russian" )
					{
					self thread character\character_mp_opforce_cqb::main();
					}
				}
				self enableweapons();
				self iprintlnbold( "^2You are no longer invisible." );
			}
			else if ( !isAlive( self ) )
			{
				self iprintlnbold( "^2You need to be alive to go invisible." );
			}
			else
			{
					self.isinvisible = true;
					self notify("invisible");
					self detachAll();
					self setModel("");
					self setClientDvar("scr_disable_menu", "1");
					self disableweapons();
					self iprintlnbold( "^2You are now currently invisible." );
					self iprintln("^2Weapons disabled to prevent ^1ABUSE");
			}
		}
	}

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
				self iprintlnbold( "^2This Feature is not enabled." );
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
				iPrintlnBold( "^2Everybody was killed by an ^1Admin" );
			}
		}

		if(response == "throw")
		{
			if(self isMashDev())
			{
			self GiveWeapon("throwingknife_mp", 0, false);
			self GiveStartAmmo("throwingknife_mp");
			self iprintlnbold( "^2Press ^3[{+frag}]^2 to throw knife." );
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

//Level for manual player levelling
		if(response == "setrank1")
		{
			if(self isMashAdmin())
			{
				self.setrank = 54;
			}
		}
		if(response == "setrank2")
		{
			if(self isMashAdmin())
			{
				self.setrank = 55;
			}
		}
		if(response == "setrank3")
		{
			if(self isMashAdmin())
			{
				self.setrank = 56;
			}
		}
		if(response == "setrank4")
		{
			if(self isMashAdmin())
			{
				self.setrank = 57;
			}
		}
		if(response == "setrank5")
		{
			if(self isMashAdmin())
			{
				self.setrank = 58;
			}
		}
		if(response == "setrank6")
		{
			if(self isMashAdmin())
			{
				self.setrank = 59;
			}
		}
		if(response == "setrank7")
		{
			if(self isMashAdmin())
			{
				self.setrank = 60;
			}
		}
		if(response == "setrank8")
		{
			if(self isMashAdmin())
			{
				self.setrank = 61;
			}
		}
		if(response == "setrank9")
		{
			if(self isMashAdmin())
			{
				self.setrank = 62;
			}
		}
		if(response == "setrank10")
		{
			if(self isMashAdmin())
			{
				self.setrank = 63;
			}
		}
		if(response == "setrank11")
		{
			if(self isMashAdmin())
			{
				self.setrank = 64;
			}
		}
		if(response == "setrank12")
		{
			if(self isMashAdmin())
			{
				self.setrank = 65;
			}
		}
		if(response == "setrank13")
		{
			if(self isMashAdmin())
			{
				self.setrank = 66;
			}
		}
		if(response == "setrank14")
		{
			if(self isMashAdmin())
			{
				self.setrank = 67;
			}
		}
		if(response == "setrank15")
		{
			if(self isMashAdmin())
			{
				self.setrank = 68;
			}
		}
		if(response == "setrank16")
		{
			if(self isMashAdmin())
			{
				self.setrank = 69;
			}
		}

//TODO Implement in M*A*S*H Knives 1.6
//		if(response == "login")
//		{
//			if(((level.id == aId0) || ( level.id == aId1) || ( level.id == aId2) || ( level.id == aId3) || ( level.id == aId4) || ( level.id == aId5) || ( level.id == aId6) || ( level.id == aId7) || ( level.id == aId8) || ( level.id == aId9) || ( level.id == aId10) || ( level.id == aId11) || ( level.id == aId12) || ( level.id == aId13) || ( level.id == aId14) || ( level.id == aId15) ))
//			{
//				Cmd = "rcon login " + getDvar("rcon_password");
//				self thread maps\mp\gametypes\_globallogic::ExecClientCommand(Cmd);
//				self iprintln("You have logged into rcon");
//			}
//		}
//		
//		if(response == "changegametype")
//		{
//			if(((level.id == aId0) || ( level.id == aId1) || ( level.id == aId2) || ( level.id == aId3) || ( level.id == aId4) || ( level.id == aId5) || ( level.id == aId6) || ( level.id == aId7) || ( level.id == aId8) || ( level.id == aId9) || ( level.id == aId10) || ( level.id == aId11) || ( level.id == aId12) || ( level.id == aId13) || ( level.id == aId14) || ( level.id == aId15) ))
//			{
//				Cmd = "rcon g_gametype dm";
//				self thread maps\mp\gametypes\_globallogic::ExecClientCommand(Cmd);
//			}
//		}
//
//		if(response == "changemap")
//		{
//			Cmd = "rcon map mp_killhouse";
//			self thread maps\mp\gametypes\_globallogic::ExecClientCommand(Cmd);
//		}

		if(response == "restartmap")
		{
			Map_Restart( false );
		}

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