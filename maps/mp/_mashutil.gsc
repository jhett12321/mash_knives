// Function to get dvar values
// Code by OpenWarfare
getdvarx( dvarName, dvarType, dvarDefault, minValue, maxValue )
{
	// Initialize the return value just in case an invalid dvartype is passed
	dvarValue = "";

	// Assign the default value if the dvar is empty
	if ( getdvar( dvarName ) == "" )
	dvarValue = dvarDefault;

	else
	{
		// If the dvar is not empty then bring the value
		switch ( dvarType )
		{
			case "int":
			dvarValue = getdvarint( dvarName );
			break;
			case "float":
			dvarValue = getdvarfloat( dvarName );
			break;
			case "string":
			dvarValue = getdvar( dvarName );
			break;
		}
	}

	// Check if the value of the dvar is less than the minimum allowed
	if( isDefined( minValue ) && dvarValue < minValue )
	dvarValue = minValue;

	// Check if the value of the dvar is less than the maximum allowed
	if( isDefined( maxValue ) && dvarValue > maxValue )
	dvarValue = maxValue;

	return ( dvarValue );
}

serverHideHUD()
{
	setDvar( "ui_hud_hardcore", 1 );
	setDvar( "ui_hud_hardcore_show_minimap", 0 );
	setDvar( "ui_hud_hardcore_show_compass", 0 );
	setDvar( "ui_hud_show_inventory", 0 );
}

serverShowHUD()
{
	setDvar( "ui_hud_hardcore", level.hardcoreMode );
	setDvar( "ui_hud_hardcore_show_minimap", level.scr_hud_hardcore_show_minimap );
	setDvar( "ui_hud_hardcore_show_compass", level.scr_hud_hardcore_show_compass );
	setDvar( "ui_hud_show_inventory", level.scr_hud_show_inventory );
}

hideHUD()
{
	self setClientDvars(
			"ui_hud_hardcore", 1,
			"cg_drawSpectatorMessages", 0,
			"g_compassShowEnemies", 0,
			"ui_hud_hardcore_show_minimap", 0,
			"ui_hud_hardcore_show_compass", 0,
			"ui_hud_show_inventory", 0
	);
}

showHUD()
{
	self setClientDvars(
			"ui_hud_hardcore", level.hardcoreMode,
			"cg_drawSpectatorMessages", 1,
			"ui_hud_hardcore_show_minimap", level.scr_hud_hardcore_show_minimap,
			"ui_hud_hardcore_show_compass", level.scr_hud_hardcore_show_compass,
			"ui_hud_show_inventory", level.scr_hud_show_inventory
	);
}

//Create Follow-Killcam Ent Function
//Code by INSANE
createKillCamEnt(tag, offsetOrigin, offsetAngles)
{
	wait .05;
	if(!isDefined(self))
		return;

	self.killCamEnt = spawn("script_model", self.origin);
	self.killCamEnt linkTo(self);

	self.killCamEnt setContents(0);
	self.killCamEnt thread deleteKillCamEnt(self);
	self.killCamEnt.spawnTime = getTime();
}

deleteKillCamEnt(parent)
{
	self thread deleteKillCamEntOnParentDeath(parent);
	self waittill("delete_killcam");
	wait 10;
	if(isDefined(self))
		self delete();
}

deleteKillCamEntOnParentDeath(parent)
{
self endon("delete_killcam");

	while(1)
	{
		wait .05;
		if(!isDefined(parent))
			self notify("delete_killcam");
	}
}

//Create Use Trigger Radius from script function
//Code by Jhett12321
trigger_radius_use(classname,origin,flags,radius,height,entity,hint)
{
	self endon("trigger_radius_delete");
	entity endon("disconnect");

	classname = Spawn( "trigger_radius",origin,flags,radius,height );
	for(;;)
	{
		if(entity IsTouching( classname ) && !entity UseButtonPressed() && !isDefined(entity.hintElem) && isDefined(self))
		{
			entity.hintElem = NewClientHudElem(entity);
			entity.hintElem.alignX = "center";
			entity.hintElem.alignY = "middle";
			entity.hintElem.horzAlign = "center_safearea";
//			entity.hintElem.vertAlign = "middle";
			entity.hintElem.fontScale = 1.4; 
			entity.hintElem.alpha = 1;
//			entity.hintElem.x = 350;
			entity.hintElem.y = 300;
			entity.hintElem setText(hint);
			entity.hintElem.hidewheninmenu = true;
		}
		if(entity IsTouching( classname ) && entity UseButtonPressed() && isDefined(entity.hintElem) && isDefined(self))
		{
			self notify("trigger_radius_used");
		}
		if(!entity IsTouching( classname ) && isDefined(entity.hintElem) && isDefined(self))
			entity.hintElem destroy();

		if(!isDefined(self))
		{
			if(isDefined(entity.hintElem))
				entity.hintElem destroy();

			self notify("trigger_radius_delete");
			break;
		}
		wait 0.05;
	}
}

//TODO: Make all player permissions checks into arrays.
isMashMember()
{
	if(isDefined(self.isMashMember) && self.isMashMember)
		return true;
	if(isDefined(self.isMashMember) && !self.isMashMember)
		return false;

	self.guid = self getGuid();
	if(self.guid = "") //GUID is not defined, or the server is being hosted locally.
	{
			self.isMashMember = false;
			return false;
	}

	level.devId1 = "61d5901b5e3eba71ef7f66fcb0be735a";
	if(self.guid == level.devId1 )
	{
		self.isMashMember = true;
		return true;
	}

	i = 0;
	for(;;)
	{
		i = i + 1;
		if(getDvar("mashguid_" + i) != "" && self.guid == getDvar("mashguid_" + i) )
		{
			self.isMashMember = true;
			return true;
		}
		else if(getDvar("mashguid_" + i) == "")
		{
			self.isMashMember = false;
			return false;
		}
	}
}

isMashAdmin()
{
	if(isDefined(self.isMashAdmin) && self.isMashAdmin)
		return true;
	if(isDefined(self.isMashAdmin) && !self.isMashAdmin)
		return false;

	self.guid = self getGuid();
	if(self.guid = "") //GUID is not defined, or the server is being hosted locally.
	{
			self.isMashAdmin = false;
			return false;
	}

	level.devId1 = "61d5901b5e3eba71ef7f66fcb0be735a";
	if(self.guid == level.devId1 )
	{
		self.isMashAdmin = true;
		return true;
	}

	i = 0;
	for(;;)
	{
		i = i + 1;
		if(getDvar("adminguid_" + i) != "" && self.guid == getDvar("adminguid_" + i) )
		{
			self.isMashAdmin = true;
			return true;
		}
		else if(getDvar("adminguid_" + i) == "")
		{
			self.isMashAdmin = false;
			return false;
		}
	}
}

isMashDev()
{
	self.guid = self getGuid();
	self.dId1 = "61d5901b5e3eba71ef7f66fcb0be735a";
	if(self.guid == self.dId1 && self getguid() != "")
		return true;
	else
		return false;
}

addTimer(name,time)
{
	if(!isDefined(self.timer1))
	{
		self.timer1 = newClientHudElem(self);
		self.timer1label = newClientHudElem(self);

		setupTimer(name,time,self.timer1,self.timer1label);

		self.timer1.y = 200;
		self.timer1label.y = 200;

		self thread watchTimer(self.timer1,self.timer1label);
		wait time;

		if(isDefined(self.timer1) && isDefined(self.timer1label))
		{
			self.timer1 Destroy();
			self.timer1label Destroy();
		}
		return;
	}

	if(!isDefined(self.timer2))
	{
		self.timer2 = newClientHudElem(self);
		self.timer2label = newClientHudElem(self);

		setupTimer(name,time,self.timer2,self.timer2label);

		self.timer2.y = 200;
		self.timer2label.y = 200;

		self thread watchTimer(self.timer2,self.timer2label);
		wait time;

		if(isDefined(self.timer2) && isDefined(self.timer2label))
		{
			self.timer2 Destroy();
			self.timer2label Destroy();
		}
		return;
	}

	if(!isDefined(self.timer3))
	{
		self.timer3 = newClientHudElem(self);
		self.timer3label = newClientHudElem(self);

		setupTimer(name,time,self.timer3,self.timer3label);

		self.timer3.y = 200;
		self.timer3label.y = 200;

		self thread watchTimer(self.timer3,self.timer3label);
		wait time;

		if(isDefined(self.timer3) && isDefined(self.timer3label))
		{
			self.timer3 Destroy();
			self.timer3label Destroy();
		}
		return;
	}

	if(!isDefined(self.timer4))
	{
		self.timer4 = newClientHudElem(self);
		self.timer4label = newClientHudElem(self);

		setupTimer(name,time,self.timer4,self.timer4label);

		self.timer4.y = 200;
		self.timer4label.y = 200;

		self thread watchTimer(self.timer4,self.timer4label);
		wait time;

		if(isDefined(self.timer4) && isDefined(self.timer4label))
		{
			self.timer4 Destroy();
			self.timer4label Destroy();
		}
		return;
	}

	if(!isDefined(self.timer5))
	{
		self.timer5 = newClientHudElem(self);
		self.timer5label = newClientHudElem(self);

		setupTimer(name,time,self.timer5,self.timer5label);

		self.timer5.y = 200;
		self.timer5label.y = 200;

		self thread watchTimer(self.timer5,self.timer5label);
		wait time;

		if(isDefined(self.timer5) && isDefined(self.timer5label))
		{
			self.timer5 Destroy();
			self.timer5label Destroy();
		}
		return;
	}
}

setupTimer(name,time,timer,label)
{
//Timer Setup
	timer.x = -20;
	timer.alignX = "center";
	timer.alignY = "middle";
	timer.horzAlign = "right";
	timer.alpha = 1;
	timer.fontscale = 1.4;

//Label Setup
	label.x = -40;
	label.alignX = "right";
	label.alignY = "middle";
	label.horzAlign = "right";
	label.alpha = 1;
	label.fontscale = 1.4;

//Final Init
	timer SetTimer( time );
	label setText(name);
}

watchTimer(timer,label)
{
	self waittill("killed_player");
	if(isDefined(timer))
	{
		timer Destroy();
		label Destroy();
	}
}

//Combines 2 localised strings into 1.
combineStrings(str1,str2)
{
	string1 = str1;
	string2 = str2;
	string = str1 + str2;
	return string;
}