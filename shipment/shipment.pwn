#include <a_samp>
#include <sscanf2>
#include <Pawn.CMD>

// Shipment Contrator Inspired by NGG and CoM:RP - DONE

#define COLOR_WHITE             0xFFFFFFFF

// HOLDING(keys)
#define HOLDING(%0) \
	((newkeys & (%0)) == (%0))

// PRESSED(keys)
#define PRESSED(%0) \
	(((newkeys & (%0)) == (%0)) && ((oldkeys & (%0)) != (%0)))

// PRESSING(keyVariable, keys)
#define PRESSING(%0,%1) \
	(%0 & (%1))

// RELEASED(keys)
#define RELEASED(%0) \
	(((newkeys & (%0)) != (%0)) && ((oldkeys & (%0)) == (%0)))

new truckvehicle[4];
new trailer;
new actor;
new Text3D:trucklabel;
new ShipProgress[MAX_PLAYERS];

enum{
    SHIPMENT_JOB,
};

enum{// DIalog Enum
    DIALOG_GPSNAV,
	DIALOG_NAVLOCATE
}

enum pInfo{
    pId,
    pJob
}
new UInfo[MAX_PLAYERS][pInfo];

#include "nav.pwn"

main(){}

public OnGameModeInit(){
    new color = random(10);
    truckvehicle[0] = CreateVehicle(514, 2205.7312, -2642.8149, 13.5469, 274.0126, color, color, -1);
    truckvehicle[1] = CreateVehicle(514, 2249.3059, -2629.6252, 13.5669, 90.4367, color, color, -1);
    truckvehicle[2] = CreateVehicle(514, 2248.4702, -2637.2556, 13.5679, 90.4367, color, color, -1);
    truckvehicle[3] = CreateVehicle(514, 2248.2410, -2645.2698, 13.5733, 90.4367, color, color, -1);
    
    // Actor
    actor = CreateActor(72, 2192.6362,-2647.7021,13.5469, 179.1227);

    //Label
    trucklabel = Create3DTextLabel("Shipment Contrator\n{CADD44}Press 'N' to obtain this Job.", COLOR_WHITE, 2192.6362,-2647.7021,13.5469, 30.0, 0, 0);
    /*CreateVehicle(514, 2205.7312, -2642.8149, 13.5469, 274.0126, color, color, -1);
    CreateVehicle(514, 2249.3059, -2629.6252, 13.5669, 90.4367, color, color, -1);
    CreateVehicle(514, 2248.4702, -2637.2556, 13.5679, 90.4367, color, color, -1);
    CreateVehicle(514, 2248.2410, -2645.2698, 13.5733, 90.4367, color, color, -1);
    
    // Actor
    CreateActor(72, 2192.6362,-2647.7021,13.5469, 179.1227);

    //Label
    Create3DTextLabel("Shipment Contrator\n{CADD44}Press 'N' to obtain this Job.", 0xFFFFFFFF, 2192.6362, -2647.7021, 13.5469, 30.0, 0, 0);*/
    return 1;
}

public OnGameModeExit(){
    return 1;
}

public OnPlayerStateChange(playerid, newstate, oldstate){
    if(pNavState[playerid])
	{
		KillTimer(pNavTimer[playerid]);
		DestroyObject(NavigatorObject[playerid]);
		PlayerTextDrawHide(playerid, NavigatorTD[playerid]);	
		PlayerPlaySound(playerid,1150,0.0,0.0,0.0);
		DisablePlayerCheckpoint(playerid);
		pNavState[playerid] = 0;
	}
    if(newstate == PLAYER_STATE_DRIVER){
        new vehid = GetPlayerVehicleID(playerid);
        for(new i; i < 4; i ++){
            if(vehid == truckvehicle[i]){
                if(UInfo[playerid][pJob] != SHIPMENT_JOB){
                    SendClientMessage(playerid, 0xFFFFFFFF, "You cannot enter this vehicle as you're not a shipment contractor.");
                    ClearAnimations(playerid);
                    RemovePlayerFromVehicle(playerid);
                    return 0;
                }
                ShipProgress[playerid] = 1;
                SendClientMessage(playerid, 0xFFFF00FF, "Please proceed to the shipment point.");
                pNavPos[playerid][0] = 2197.5872;
                pNavPos[playerid][1] = -2662.7292;
                pNavPos[playerid][2] = 13.5469;
                SetPlayerCheckpoint(playerid, pNavPos[playerid][0], pNavPos[playerid][1], pNavPos[playerid][2], 3.0);
                //if(IsValidObject(NavigatorObject[playerid])) DestroyObject(NavigatorObject[playerid]);
                NavigatorObject[playerid] = CreateObject(19134, 0, 0, 0, 0, 0, 0);
                Refresh(playerid);
                KillTimer(pNavTimer[playerid]);
                pNavTimer[playerid] = SetTimerEx("Refresh", 100, true, "d", playerid);
                PlayerTextDrawShow(playerid, NavigatorTD[playerid]);
                PlayerPlaySound(playerid,1139,0.0,0.0,0.0);
                pNavState[playerid] = 1;
                SetPVarInt(playerid, "NavData", 1);
                return 1;
            }
        }
    }
    return 1;
}

public OnPlayerEnterVehicle(playerid, vehicleid, ispassenger){
    if((truckvehicle[0] <= vehicleid <= truckvehicle[3]) && UInfo[playerid][pJob] != SHIPMENT_JOB){
        ClearAnimations(playerid);
        RemovePlayerFromVehicle(playerid);
        SendClientMessage(playerid, 0xFFFFFFFF, "You cannot enter this vehicle as you're not a shipment contractor.");
        return 0;
    }
    return 1;
}

public OnPlayerEnterCheckpoint(playerid){
    new veh = GetPlayerVehicleID(playerid);
    if(ShipProgress[playerid] == 1){
        DisablePlayerCheckpoint(playerid);
        TogglePlayerControllable(playerid, false);
        SetTimerEx("ShipmentTimer", 500, false, "ii", playerid, 0);
        return 1;
    }
    else if(ShipProgress[playerid] == 2){
        DisablePlayerCheckpoint(playerid);
        SetPlayerCheckpoint(playerid, 2222.5979,-2682.7598,13.5409, 5.0);
        DetachTrailerFromVehicle(veh);
        DestroyVehicle(trailer);
        SendClientMessage(playerid, COLOR_WHITE, "Return the truck.");
        ShipProgress[playerid] = 3;
        return 1;
    }
    else if(ShipProgress[playerid] == 3){
        new payout = random(1000) + 9999;
        GivePlayerMoney(playerid, payout);
        SetVehicleToRespawn(veh);
        DisablePlayerCheckpoint(playerid);
        new message[128];
        format(message, 128, "Your payout for your work is: {00FF00}$%i{FFFF00}.", payout);
        SendClientMessage(playerid, 0xFFFF00FF, message);
        return 1;
    }
    return 1;
}

public OnPlayerSpawn(playerid){
    SetPlayerPos(playerid, 2222.5979,-2682.7598,13.5409);
    return 1;
}

public OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	if (newkeys == KEY_NO){
        if(IsPlayerInRangeOfPoint(playerid, 3.0, 2192.6362,-2647.7021,13.5469)){
            UInfo[playerid][pJob] = SHIPMENT_JOB;
            SendClientMessage(playerid, COLOR_WHITE, "Congratulations. You have obtained the Shipment Contractor.");
            return 1;
        }
    }
	return 1;
}

// Timer
forward ShipmentTimer(playerid, stage);
public ShipmentTimer(playerid, stage){
    new timer;
    switch(stage){
        case 0:{
             GameTextForPlayer(playerid, "5 Seconds Left", 1000, 3);
        }
        case 1:{
            GameTextForPlayer(playerid, "4 Seconds Left", 1000, 3);
        }
        case 2:{
            GameTextForPlayer(playerid, "3 Seconds Left", 1000, 3);
        }
        case 3:{
            GameTextForPlayer(playerid, "2 Seconds Left", 1000, 3);
        }
        case 4:{
            GameTextForPlayer(playerid, "1 Second Left", 1000, 3);
        }
        case 5:{
            SetPlayerShipmentProgress(playerid);
        }
    }
    stage++;

    if(stage != 6){
        timer = SetTimerEx("ShipmentTimer", 1000, false, "ii", playerid, stage);
    }
    else{
        KillTimer(timer);
    }
}

stock SetPlayerShipmentProgress(playerid){
    new veh = GetPlayerVehicleID(playerid);
    //SetVehicleToRespawn(veh);
    //new vehicle = CreateVehicle(514, 271.7534,-2662.5291,13.5061, 85.0422, 1, 1, -1, 0);

    trailer = CreateVehicle(584, 2271.7534, -2662.5291+3, 13.5061, 85.0422, 1, 1, -1, 0);
    SetVehiclePos(veh, 2261.3779,-2659.1072,14.0874);
    SetVehicleZAngle(veh, 89.4366);
    AttachTrailerToVehicle(trailer, veh);

    TogglePlayerControllable(playerid, true);
    ShipProgress[playerid] = 2;

    SetTimerEx("CheckPlayerTrailer", 800, false, "ii", playerid, veh);
}

forward CheckPlayerTrailer(playerid, vehid);
public CheckPlayerTrailer(playerid, vehid)
{
    if(IsTrailerAttachedToVehicle(vehid))
    {
        SetPlayerCheckpoint(playerid, 1932.1134,-1780.9846,13.3828, 8.0);
        SendClientMessage(playerid, COLOR_WHITE, "Go to the designated area of dropping shipments.");
    }
}