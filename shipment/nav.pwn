new 
	NavigatorObject[MAX_PLAYERS],
	pNavState[MAX_PLAYERS],
	pNavID[MAX_PLAYERS],
	pNavTimer[MAX_PLAYERS],
	PlayerText:NavigatorTD[MAX_PLAYERS]
;

new Float:pNavPos[MAX_PLAYERS][3];

enum NavigatorEnum 
{
    NavigatorLocation[32],
    Float:NavigatorX,
    Float:NavigatorY,
    Float:NavigatorZ
};

new const NavigatorData1[][NavigatorEnum] = 
{	
	// Job Location
	{"Pizzaman", 		2104.7771, -1805.1772, 13.5547},
	{"Trucker",     	2434.4448, -2125.6113, 13.5469},
	{"Fisherman",   	393.2632,  -2070.5837, 7.8359},
	{"Bodyguard",   	2227.4705, -1715.9694, 13.5302},
	{"Arms Dealer",  	1370.2173, -1311.9095, 13.5469},
	{"Taxi Driver",     1748.1373, -1863.0981, 13.5755},
	{"Drug Dealer",     2165.3611, -1673.0824, 15.0778},
	{"Lawyer",          1381.0668, -1086.6857, 27.3906},
	{"Detective",       1548.2339,-1668.2773,13.5667},
	{"Miner",           446.0749, -850.2650, 29.8049},
	{"Farmer",     -382.9738, -1426.2772, 26.3182},
	{"Crate Collector",     1002.1011, -2098.4394, 13.1114}
};

new const NavigatorData2[][NavigatorEnum] = 
{	
	// General Location
	{"VIP Lounge", 1798.010498, -1578.760742, 14.085617},
	{"VIP Garage", 1827.760009, -1538.630004, 13.546875},
	{"Mechanic Shop", 1803.573852, -1721.957041, 13.540957},
	{"Car Dealership", 557.196350, -1259.894897, 17.242187},
	{"DMV", 2046.8236,-1909.0981,13.6120},
	{"City Hall", 1481.007, -1771.864, 18.795}
};

public OnPlayerConnect(playerid){
    // GPS Navigator
    NavigatorTD[playerid] = CreatePlayerTextDraw(playerid,86.000000, 430.000000, "Distance: 0000.00m");
    PlayerTextDrawAlignment(playerid,NavigatorTD[playerid], 2);
    PlayerTextDrawBackgroundColor(playerid,NavigatorTD[playerid], 255);
    PlayerTextDrawFont(playerid,NavigatorTD[playerid], 2);
    PlayerTextDrawLetterSize(playerid,NavigatorTD[playerid], 0.150000, 1.000000);
    PlayerTextDrawColor(playerid,NavigatorTD[playerid], -1);
    PlayerTextDrawSetOutline(playerid,NavigatorTD[playerid], 1);
    PlayerTextDrawSetProportional(playerid,NavigatorTD[playerid], 1);
    PlayerTextDrawSetSelectable(playerid,NavigatorTD[playerid], 0);

	UInfo[playerid][pJob] = 0;
    return 1;
}

public OnPlayerDisconnect(playerid, reason){
    if(pNavState[playerid])
	{
		KillTimer(pNavTimer[playerid]);
		DestroyObject(NavigatorObject[playerid]);
		DisablePlayerCheckpoint(playerid);
		pNavState[playerid] = 0;
	}
    return 1;
}

public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
    if(dialogid == DIALOG_GPSNAV)
	{
		if(response)
		{
			if(!IsPlayerInAnyVehicle(playerid)) return SendClientMessage(playerid, COLOR_WHITE, "You must be in a vehicle to use navigation!");
			if(GetPVarInt(playerid, "NavData") == 1)
			{
				pNavID[playerid] = listitem;
				SetPlayerCheckpoint(playerid, NavigatorData1[pNavID[playerid]][NavigatorX], NavigatorData1[pNavID[playerid]][NavigatorY], NavigatorData1[pNavID[playerid]][NavigatorZ], 3.0);
				if(IsValidObject(NavigatorObject[playerid])) DestroyObject(NavigatorObject[playerid]);
				NavigatorObject[playerid] = CreateObject(19134, 0, 0, 0, 0, 0, 0);
				Refresh(playerid);
				KillTimer(pNavTimer[playerid]);
				pNavTimer[playerid] = SetTimerEx("Refresh", 100, true, "d", playerid);
				PlayerTextDrawShow(playerid, NavigatorTD[playerid]);
				PlayerPlaySound(playerid,1139,0.0,0.0,0.0);
				pNavState[playerid] = 1;
			}
			else if(GetPVarInt(playerid, "NavData") == 2)
			{
				pNavID[playerid] = listitem;
				SetPlayerCheckpoint(playerid, NavigatorData2[pNavID[playerid]][NavigatorX], NavigatorData2[pNavID[playerid]][NavigatorY], NavigatorData2[pNavID[playerid]][NavigatorZ], 3.0);
				if(IsValidObject(NavigatorObject[playerid])) DestroyObject(NavigatorObject[playerid]);
				NavigatorObject[playerid] = CreateObject(19134, 0, 0, 0, 0, 0, 0);
				Refresh(playerid);
				KillTimer(pNavTimer[playerid]);
				pNavTimer[playerid] = SetTimerEx("Refresh", 100, true, "d", playerid);
				PlayerTextDrawShow(playerid, NavigatorTD[playerid]);
				PlayerPlaySound(playerid,1139,0.0,0.0,0.0);
				pNavState[playerid] = 1;
			}
		}
	}
	if(dialogid == DIALOG_NAVLOCATE)
    {
        if(response)
        {
            switch(listitem)
            {
                case 0: // JOBS
                {
                    if(!IsPlayerInAnyVehicle(playerid)) return SendClientMessage(playerid, COLOR_WHITE, "You must be in a vehicle to use navigation!");
                    static string[sizeof(NavigatorData1) * 64];

                    if (string[0] == EOS) 
                    {
                        SetPVarInt(playerid, "NavData", 1);
                        for (new i; i < sizeof(NavigatorData1); i++) 
                        {
                            format(string, sizeof string, "%s %s\n", string, NavigatorData1[i][NavigatorLocation]);
                        }
                    } 
                    ShowPlayerDialog(playerid, DIALOG_GPSNAV, DIALOG_STYLE_LIST, "Locate", string, "Select", "Close");
                }
                case 1: // GENERAL LOCATIONS
                {
                    if(!IsPlayerInAnyVehicle(playerid)) return SendClientMessage(playerid, COLOR_WHITE, "You must be in a vehicle to use navigation!");
                    static string[sizeof(NavigatorData2) * 64];

                    if (string[0] == EOS) 
                    {
                        SetPVarInt(playerid, "NavData", 2);
                        for (new i; i < sizeof(NavigatorData2); i++) 
                        {
                            format(string, sizeof string, "%s %s\n", string, NavigatorData2[i][NavigatorLocation]);
                        }
                    } 
                    ShowPlayerDialog(playerid, DIALOG_GPSNAV, DIALOG_STYLE_LIST, "Locate", string, "Select", "Close");
                }
            }
        }
    }
 
    return 0; // You MUST return 0 here! Just like OnPlayerCommandText.
}

// GPS Navigator
stock Float:PointAngle(playerid, Float:xa, Float:ya, Float:xb, Float:yb) // Don't know the owner.
{
	new Float:carangle;
	new Float:xc, Float:yc;
	new Float:angle;
	xc = floatabs(floatsub(xa,xb));
	yc = floatabs(floatsub(ya,yb));
	if (yc == 0.0 || xc == 0.0)
	{
		if(yc == 0 && xc > 0) angle = 0.0;
		else if(yc == 0 && xc < 0) angle = 180.0;
		else if(yc > 0 && xc == 0) angle = 90.0;
		else if(yc < 0 && xc == 0) angle = 270.0;
		else if(yc == 0 && xc == 0) angle = 0.0;
	}
	else
	{
		angle = atan(xc/yc);
		if(xb > xa && yb <= ya) angle += 90.0;
		else if(xb <= xa && yb < ya) angle = floatsub(90.0, angle);
		else if(xb < xa && yb >= ya) angle -= 90.0;
		else if(xb >= xa && yb > ya) angle = floatsub(270.0, angle);
	}
	GetVehicleZAngle(GetPlayerVehicleID(playerid), carangle);
	return floatadd(angle, -carangle);
}

// GPS Navigator
forward Refresh(playerid);
public Refresh(playerid)
{
	new Float:pos[3], Float:pPos[3];
	switch(GetPVarInt(playerid, "NavData"))
	{
		case 1:
		{
			pPos[0] = pNavPos[playerid][0];
			pPos[1] = pNavPos[playerid][1];
			pPos[2] = pNavPos[playerid][2];
			GetVehiclePos(GetPlayerVehicleID(playerid), pos[0], pos[1], pos[2]);
			new Float:rot = PointAngle(playerid, pos[0], pos[1], pPos[0], pPos[1]);
			AttachObjectToVehicle(NavigatorObject[playerid], GetPlayerVehicleID(playerid), 0.000000, 0.000000, 30.000000, 0.000000, 90.0, rot + 180);
			new Float:mesafe, str[32];
			mesafe = GetPlayerDistanceFromPoint(playerid, pPos[0], pPos[1], pPos[2]);
			format(str, sizeof(str), "Distance: %0.2fm", mesafe);
			PlayerTextDrawSetString(playerid, NavigatorTD[playerid], str);
			if(IsPlayerInRangeOfPoint(playerid, 3.0, pPos[0], pPos[1], pPos[2]))
			{
				KillTimer(pNavTimer[playerid]);
				DestroyObject(NavigatorObject[playerid]);
				PlayerTextDrawHide(playerid, NavigatorTD[playerid]);	
				DisablePlayerCheckpoint(playerid);
				PlayerPlaySound(playerid,1137,0.0,0.0,0.0);
				pNavState[playerid] = 0;
			}
		}
		case 2:
		{
			pPos[0] = NavigatorData2[pNavID[playerid]][NavigatorX];
			pPos[1] = NavigatorData2[pNavID[playerid]][NavigatorY];
			pPos[2] = NavigatorData2[pNavID[playerid]][NavigatorZ];
			GetVehiclePos(GetPlayerVehicleID(playerid), pos[0], pos[1], pos[2]);
			new Float:rot = PointAngle(playerid, pos[0], pos[1], pPos[0], pPos[1]);
			AttachObjectToVehicle(NavigatorObject[playerid], GetPlayerVehicleID(playerid), 0.000000, 0.000000, 1.399998, 0.000000, 90.0, rot + 180);
			new Float:mesafe, str[32];
			mesafe = GetPlayerDistanceFromPoint(playerid, pPos[0], pPos[1], pPos[2]);
			format(str, sizeof(str), "Distance: %0.2fm", mesafe);
			PlayerTextDrawSetString(playerid, NavigatorTD[playerid], str);
			if(IsPlayerInRangeOfPoint(playerid, 1.0, pPos[0], pPos[1], pPos[2]))
			{
				KillTimer(pNavTimer[playerid]);
				DestroyObject(NavigatorObject[playerid]);
				PlayerTextDrawHide(playerid, NavigatorTD[playerid]);	
				DisablePlayerCheckpoint(playerid);
				PlayerPlaySound(playerid,1137,0.0,0.0,0.0);
				pNavState[playerid] = 0;
			}
		}
	}
	return 1;
}