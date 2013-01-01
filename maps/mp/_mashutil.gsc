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