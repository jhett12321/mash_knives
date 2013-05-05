#include maps\mp\_utility;

//Pre-Load Initialisation
modinit()
{
//Permissions Initialisation
	level.devId = [];
	level.mashId = [];
	level.adminId = [];
	level.devId[0] = "61d5901b5e3eba71ef7f66fcb0be735a";
	level.mashId[0] = level.devId[0];
	level.adminId[0] = level.devId[0];

	for(;;)
	{
		if(getDvar("mashguid_" + level.mashId.size) != "")
		{
			level.mashId[level.mashId.size] = getDvar("mashguid_" + level.mashId.size);
		}
		else if(getDvar("mashguid_" + level.mashId.size) == "")
		{
			break;
		}
	}

	for(;;)
	{
		if(getDvar("adminguid_" + level.adminId.size) != "")
		{
			level.adminId[level.adminId.size] = getDvar("adminguid_" + level.adminId.size);
		}
		else if(getDvar("adminguid_" + level.adminId.size) == "")
		{
			break;
		}
	}
}

//Post Load Initialisation
init()
{
	precacheString( &"MASH_MOD_NAME_1V1_MODE" );
	precacheString( &"MASH_MOD_NAME" );

	thread modinfo();
	thread addTestClients();
}

modinfo()
{
	level.modinfo = NewHudElem();
	level.modinfo.alignX = "center";
	level.modinfo.alignY = "top";
	level.modinfo.y = 10;
	level.modinfo.horzAlign = "center_safearea";
	level.modinfo.archived = true;
	level.modinfo.fontScale = 1.4; 
	level.modinfo.alpha = 1;
	level.modinfo.hidewheninmenu = true;

	if( isDefined(level.is1v1) && level.is1v1 )
		level.modinfo setText(&"MASH_MOD_NAME_1V1_MODE");
	else
		level.modinfo setText(&"MASH_MOD_NAME");
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