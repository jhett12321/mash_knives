#include maps\mp\_utility;

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
addStatusTimer(name,time,persist)
{
	if(!isDefined(self.timer1))
	{
		if(isDefined(persist) && persist)
			setupTimer(self.timer1,self.timer1label,name,time,200,true);
		else
			setupTimer(self.timer1,self.timer1label,name,time,200,false);
	}

	else if(!isDefined(self.timer2))
	{
		if(isDefined(persist) && persist)
			setupTimer(self.timer2,self.timer2label,name,time,215,true);
		else
			setupTimer(self.timer2,self.timer2label,name,time,215,false);
	}

	else if(!isDefined(self.timer3))
	{
		if(isDefined(persist) && persist)
			setupTimer(self.timer3,self.timer3label,name,time,230,true);
		else
			setupTimer(self.timer3,self.timer3label,name,time,230,false);
	}

	else if(!isDefined(self.timer4))
	{
		if(isDefined(persist) && persist)
			setupTimer(self.timer4,self.timer4label,name,time,245,true);
		else
			setupTimer(self.timer4,self.timer4label,name,time,245,false);
	}

	else if(!isDefined(self.timer5))
	{
		if(isDefined(persist) && persist)
			setupTimer(self.timer5,self.timer5label,name,time,260,true);
		else
			setupTimer(self.timer5,self.timer5label,name,time,260,false);
	}

	else
		return; //Out of timers
}

setupTimer(timer,label,name,time,y,persist)
{
	timer = newClientHudElem(self);
	label = newClientHudElem(self);

//Timer Setup
	timer.x = -20;
	timer.y = y;
	timer.alignX = "center";
	timer.alignY = "middle";
	timer.horzAlign = "right";
	timer.alpha = 1;
	timer.fontscale = 1.4;

//Label Setup
	label.x = -40;
	label.y = y;
	label.alignX = "right";
	label.alignY = "middle";
	label.horzAlign = "right";
	label.alpha = 1;
	label.fontscale = 1.4;

//Final Init
	timer setTimer(time);
	label setText(name);

	if(persist)
		thread watchTimer(timer,label);

	wait time;

	if(isDefined(name) && isDefined(label))
	{
		name Destroy();
		label Destroy();
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