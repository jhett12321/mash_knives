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