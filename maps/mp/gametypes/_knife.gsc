#include maps\mp\_utility;

init()
{
	thread modinfo();
	thread addTestClients();
	if(!getDvarInt("scr_scrimmode"))
		thread server_messages();
}

modinfo()
{
	level.modinfo = NewHudElem();
	level.modinfo.alignX = "right";
	level.modinfo.alignY = "top";
	level.modinfo.archived = true;
	level.modinfo.fontScale = 1.4; 
	level.modinfo.alpha = 1;
	level.modinfo.hidewheninmenu = true;

	if(getDvarInt("scr_scrimmode"))
	{
		level.modinfo.x = 400;
		level.modinfo.y = 10;
		level.modinfo setText("^2M*A*S*H KNIVES ^11.5-B2 ^3SCRIM MODE");
	}
	
	else if( GetDvar( "g_gametype" ) == "1v1" )
		{
		level.modinfo.x = 400;
		level.modinfo.y = 10;
		level.modinfo setText("^2M*A*S*H KNIVES ^11.5-B2 ^31v1 Mode");
	}

	else
	{
		level.modinfo.x = 370;
		level.modinfo.y = 10;
		level.modinfo setText("^2M*A*S*H KNIVES ^11.5-B2");
	}
}

server_messages()
{
	while (1)
	{
		wait 0.05;

		if(!getDvarInt("scr_allow_servermessages"))
			continue;

		svr_msg = [];
		svr_msg[1] = getDvar("svr_msg1");
		svr_msg[2] = getDvar("svr_msg2");
		svr_msg[3] = getDvar("svr_msg3");
		svr_msg[4] = getDvar("svr_msg4");
		svr_msg[5] = getDvar("svr_msg5");
		svr_msg[6] = getDvar("svr_msg6");
		svr_msg[7] = getDvar("svr_msg7");
		svr_msg[8] = getDvar("svr_msg8");
		svr_msg[9] = getDvar("svr_msg9");
		svr_msg[10] = getDvar("svr_msg10");

		for(i = 1; i < svr_msg.size; i++)
		{
			if(svr_msg[i] != "")
			{
				iprintln(svr_msg[i]);
				wait 240;
			}
		}
	}
}

addTestClients()
{
	wait 5;

	for(;;)
	{
		if(getdvarInt("scr_testclients") > 0)
			break;
		wait 1;
	}

	testclients = getdvarInt("scr_testclients");
	setDvar( "scr_testclients", 10 );
	for(i = 0; i < testclients; i++)
	{
		ent[i] = addtestclient();

		if (!isdefined(ent[i]))
		{
			println("Could not add test client");
			wait 1;
			continue;
		}	
		ent[i].pers["isBot"] = true;
		ent[i] thread TestClient("autoassign");
	}
	
	thread addTestClients();
}

TestClient(team)
{
self endon("disconnect");

	while(!isdefined(self.pers["team"]))
		wait .05;

	self notify("menuresponse", game["menu_team"], team);
	wait 0.5;

	classes = getArrayKeys( level.classMap );
	okclasses = [];
	for ( i = 0; i < classes.size; i++ )
	{
		if ( !issubstr( classes[i], "custom" ) && isDefined( level.default_perk[ level.classMap[ classes[i] ] ] ) )
			okclasses[ okclasses.size ] = classes[i];
	}
	
	assert( okclasses.size );

	while( 1 )
	{
		class = okclasses[ randomint( okclasses.size ) ];
		
		if(!level.oldschool)
			self notify("menuresponse", "changeclass", class);

		self waittill("spawned_player");
		wait ( 0.10 );
	}
}