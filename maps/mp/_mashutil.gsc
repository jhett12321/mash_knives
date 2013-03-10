#include maps\mp\_utility;

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
//Function End

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
//Function End

//TODO add option for any player to pickup.
//Create Use Trigger Radius from script function
//Code by Jhett12321
trigger_radius_use(classname,origin,flags,radius,height,entity,hint)
{
	self endon("trigger_radius_delete");
	entity endon("disconnect");

	classname = Spawn( "trigger_radius",origin,flags,radius,height );
	if(!isDefined(entity.triggerarray))
		entity.triggerarray = [];
	entity.triggerarray[entity.triggerarray.size] = classname;
	for(;;)
	{
		if(entity IsTouching( classname ) && !entity UseButtonPressed() && !isDefined(entity.hintElem) && isDefined(self) && isDefined(entity.showtriggerhint) && entity.showtriggerhint)
		{
//			entity setLowerMessage(hint);
			entity.hintElem = NewClientHudElem(entity);
			entity.hintElem.alignX = "center";
			entity.hintElem.alignY = "middle";
			entity.hintElem.horzAlign = "center_safearea";
			entity.hintElem.fontScale = 1.4; 
			entity.hintElem.alpha = 1;
			entity.hintElem.y = 300;
			entity.hintElem setText(hint);
			entity.hintElem.hidewheninmenu = true;
		}

		for(i = 0; i < entity.triggerarray.size; i++)
		{
			if(entity IsTouching( entity.triggerarray[i] ) && entity UseButtonPressed() && isDefined(entity.hintElem) && isDefined(self) && isDefined(entity.showtriggerhint) && entity.showtriggerhint)
				self notify("trigger_radius_used");
		}

		for(i = 0; i < entity.triggerarray.size; i++)
		{
			if(!entity IsTouching( entity.triggerarray[i] ) && isDefined(entity.hintElem) && isDefined(self) && i == entity.triggerarray.size - 1)
				entity.hintElem destroy();
//				entity clearLowerMessage(0);
			else if (entity IsTouching( entity.triggerarray[i] ))
				break;
		}

		if(isDefined(entity.hintElem) && isDefined(entity.showtriggerhint) && !entity.showtriggerhint)
			entity.hintElem destroy();
//			entity clearLowerMessage(0);

		if(!isDefined(self))
		{
			if(isDefined(entity.hintElem))
				entity.hintElem destroy();
//				entity clearLowerMessage(0);

			self notify("trigger_radius_delete");
			break;
		}
		wait 0.05;
	}
}
//Function End

//Player Permissions System
//Code by Jhett12321, with help from INSANE
//TODO: Make all player permissions checks into arrays.
isMashMember()
{
	if(isDefined(self.isMashMember) && self.isMashMember)
		return true;
	if(isDefined(self.isMashMember) && !self.isMashMember)
		return false;

	self.guid = self getGuid();
	if(self.guid == "") //GUID is not defined, or the server is being hosted locally.
	{
			self.isMashMember = false;
			return false;
	}

	for(i = 0; i < level.mashId.size; i++)
	{
		if(self.guid == level.mashId[i])
		{
			self.isMashMember = true;
			return true;
		}
	}
	self.isMashMember = false;
	return false;
}

isMashAdmin()
{
	if(isDefined(self.isMashAdmin) && self.isMashAdmin)
		return true;
	if(isDefined(self.isMashAdmin) && !self.isMashAdmin)
		return false;

	self.guid = self getGuid();
	if(self.guid == "") //GUID is not defined, or the server is being hosted locally.
	{
			self.isMashAdmin = false;
			return false;
	}

	for(i = 0; i < level.adminId.size; i++)
	{
		if(self.guid == level.adminId[i])
		{
			self.isMashAdmin = true;
			return true;
		}
	}
	self.isMashAdmin = false;
	return false;
}

isMashDev()
{
	if(isDefined(self.isMashDev) && self.isMashDev)
		return true;
	if(isDefined(self.isMashDev) && !self.isMashDev)
		return false;

	self.guid = self getGuid();
	if(self.guid == "") //GUID is not defined, or the server is being hosted locally.
	{
			self.isMashDev = false;
			return false;
	}

	for(i = 0; i < level.devId.size; i++)
	{
		if(self.guid == level.devId[i])
		{
			self.isMashDev = true;
			return true;
		}
	}
	self.isMashDev = false;
	return false;
}
//Function End

//Status Timers
//Code by Jhett12321
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
//Function End

//Combines 2 localised strings into 1.
combineStrings(str1,str2)
{
	string1 = str1;
	string2 = str2;
	string = str1 + str2;
	return string;
}
//Function End

//Stackable Action Slot
//Designed currently for action slot 4, killstreaks.
//Code by Jhett12321
setStackableActionSlot(slot,weapon,hardpointType)
{
	self.ActionSlotisEmpty = false;
	if(!isDefined(self.earnedKillStreaks))
	{
		self.earnedKillStreaks = [];
		self thread watchActionSlot(slot);
	}
	self.earnedKillStreaks[self.earnedKillStreaks.size] = hardpointType;
	self setActionSlot( slot,weapon,hardpointType );
	self.pers["hardPointItem"] = hardpointType;
	self.deleteKillStreakOnUse = true;
}

watchActionSlot(slot)
{
	for(;;)
	{
		if(isDefined(self.earnedKillStreaks) && self.earnedKillStreaks.size != 0 && isDefined(self.ActionSlotisEmpty) && self.ActionSlotisEmpty)
		{
			self giveWeapon( self.earnedKillStreaks[self.earnedKillStreaks.size - 1] );
			self giveMaxAmmo( self.earnedKillStreaks[self.earnedKillStreaks.size - 1] );
			self setActionSlot( slot,"weapon",self.earnedKillStreaks[self.earnedKillStreaks.size - 1] );
			self.pers["hardPointItem"] = self.earnedKillStreaks[self.earnedKillStreaks.size - 1];

			self thread maps\mp\gametypes\_hardpoints::playStackableSound(self.earnedKillStreaks[self.earnedKillStreaks.size - 1]);
			self.earnedKillStreaks[self.earnedKillStreaks.size - 1] = undefined;
			self.ActionSlotisEmpty = false;
			self.deleteKillStreakOnUse = false;
		}
		wait 0.01;
	}
}
//Function End

//Set Player Rank Function
//Code by Jhett12321
SetRank(ranknum,rankstr)
{
	self.setrank = ranknum;
	string = combineStrings(&"MASH_SETRANK",rankstr);
	self iprintlnbold( string );
}

//Execute Client Command Function
//Code by OpenWarfare
ExecClientCommand(cmd)
{
	self setClientDvar("ui_clientcmd", cmd);
	self openMenu("clientcmd");
	self closeMenu("clientcmd");
}