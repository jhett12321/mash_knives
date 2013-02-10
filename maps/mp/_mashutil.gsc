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
			entity.hintElem.alignX = "right";
			entity.hintElem.alignY = "top";
			entity.hintElem.fontScale = 1.4; 
			entity.hintElem.alpha = 1;
			entity.hintElem.x = 350;
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
	self.guid = self getGuid();
	self.dId1 = "61d5901b5e3eba71ef7f66fcb0be735a";
	self.mId1 = getdvar("mashguid_1");
	self.mId2 = getdvar("mashguid_2");
	self.mId3 = getdvar("mashguid_3");
	self.mId4 = getdvar("mashguid_4");
	self.mId5 = getdvar("mashguid_5");
	self.mId6 = getdvar("mashguid_6");
	self.mId7 = getdvar("mashguid_7");
	self.mId8 = getdvar("mashguid_8");
	self.mId9 = getdvar("mashguid_9");
	self.mId10	=	getdvar("mashguid_10");
	self.mId11	=	getdvar("mashguid_11");
	self.mId12	=	getdvar("mashguid_12");
	self.mId13	=	getdvar("mashguid_13");
	self.mId14	=	getdvar("mashguid_14");
	self.mId15	=	getdvar("mashguid_15");
	if(((self.guid == self.dId1) || ( self.guid == self.mId1) || ( self.guid == self.mId2) || ( self.guid == self.mId3) || ( self.guid == self.mId4) || ( self.guid == self.mId5) || ( self.guid == self.mId6) || ( self.guid == self.mId7) || ( self.guid == self.mId8) || ( self.guid == self.mId9) || ( self.guid == self.mId10) || ( self.guid == self.mId11) || ( self.guid == self.mId12) || ( self.guid == self.mId13) || ( self.guid == self.mId14) || ( self.guid == self.mId15) ) && self getguid() != "")
		return true;
	else
		return false;
}

isMashAdmin()
{
	self.guid = self getGuid();
	self.dId1 = "61d5901b5e3eba71ef7f66fcb0be735a";
	self.aId1 = getdvar("adminguid_1");
	self.aId2 = getdvar("adminguid_2");
	self.aId3 = getdvar("adminguid_3");
	self.aId4 = getdvar("adminguid_4");
	self.aId5 = getdvar("adminguid_5");
	self.aId6 = getdvar("adminguid_6");
	self.aId7 = getdvar("adminguid_7");
	self.aId8 = getdvar("adminguid_8");
	self.aId9 = getdvar("adminguid_9");
	self.aId10	=	getdvar("adminguid_10");
	self.aId11	=	getdvar("adminguid_11");
	self.aId12	=	getdvar("adminguid_12");
	self.aId13	=	getdvar("adminguid_13");
	self.aId14	=	getdvar("adminguid_14");
	self.aId15	=	getdvar("adminguid_15");
	if(((self.guid == self.dId1) || ( self.guid == self.aId1) || ( self.guid == self.aId2) || ( self.guid == self.aId3) || ( self.guid == self.aId4) || ( self.guid == self.aId5) || ( self.guid == self.aId6) || ( self.guid == self.aId7) || ( self.guid == self.aId8) || ( self.guid == self.aId9) || ( self.guid == self.aId10) || ( self.guid == self.aId11) || ( self.guid == self.aId12) || ( self.guid == self.aId13) || ( self.guid == self.aId14) || ( self.guid == self.aId15) ) && self getguid() != "")
		return true;
	else
		return false;
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
		self.timer1.x = 100;
		self.timer1.y = 200;
		self.timer1.alignX = "center";
		self.timer1.alignY = "middle";
		self.timer1.alpha = 1;
		self.timer1.fontscale = 1.4;
		
		self.timer1label = newClientHudElem(self);
		self.timer1label.x = -100;
		self.timer1label.y = 200;
		self.timer1label.alignX = "left";
		self.timer1label.alignY = "middle";
		self.timer1label.alpha = 1;
		self.timer1label.fontscale = 1.4;

		self.timer1label setText(name);
		self.timer1 SetTimer( time );

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
		self.timer2.x = 100;
		self.timer2.y = 215;
		self.timer2.alignX = "center";
		self.timer2.alignY = "middle";
		self.timer2.alpha = 1;
		self.timer2.fontscale = 1.4;
		
		self.timer2label = newClientHudElem(self);
		self.timer2label.x = -100;
		self.timer2label.y = 215;
		self.timer2label.alignX = "left";
		self.timer2label.alignY = "middle";
		self.timer2label.alpha = 1;
		self.timer2label.fontscale = 1.4;

		self.timer2label setText(name);
		self.timer2 SetTimer( time );

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
		self.timer3.x = 100;
		self.timer3.y = 230;
		self.timer3.alignX = "center";
		self.timer3.alignY = "middle";
		self.timer3.alpha = 1;
		self.timer3.fontscale = 1.4;
		
		self.timer3label = newClientHudElem(self);
		self.timer3label.x = -100;
		self.timer3label.y = 230;
		self.timer3label.alignX = "left";
		self.timer3label.alignY = "middle";
		self.timer3label.alpha = 1;
		self.timer3label.fontscale = 1.4;

		self.timer3label setText(name);
		self.timer3 SetTimer( time );

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
		self.timer4.x = 100;
		self.timer4.y = 245;
		self.timer4.alignX = "center";
		self.timer4.alignY = "middle";
		self.timer4.alpha = 1;
		self.timer4.fontscale = 1.4;
		
		self.timer4label = newClientHudElem(self);
		self.timer4label.x = -100;
		self.timer4label.y = 245;
		self.timer4label.alignX = "left";
		self.timer4label.alignY = "middle";
		self.timer4label.alpha = 1;
		self.timer4label.fontscale = 1.4;

		self.timer4label setText(name);
		self.timer4 SetTimer( time );

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
		self.timer5.x = 100;
		self.timer5.y = 260;
		self.timer5.alignX = "center";
		self.timer5.alignY = "middle";
		self.timer5.alpha = 1;
		self.timer5.fontscale = 1.4;
		
		self.timer5label = newClientHudElem(self);
		self.timer5label.x = -100;
		self.timer5label.y = 260;
		self.timer5label.alignX = "left";
		self.timer5label.alignY = "middle";
		self.timer5label.alpha = 1;
		self.timer5label.fontscale = 1.4;

		self.timer5label setText(name);
		self.timer5 SetTimer( time );

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

watchTimer(timer,label)
{
	self waittill("killed_player");
	if(isDefined(timer))
	{
		timer Destroy();
		label Destroy();
	}
}