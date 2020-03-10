/**
 *
 * Match BasiX
 * Source-Pawn Server-Plugin for CS
 *
 * Written by @NIGHTTIMEDEV
 * https://nighttimedev.com
 * March 2020
 *
 * Feel free to create forks from github!
 * Re-Use, Copying etc. permitted but please give credit.
 * 
 * This Plugin uses:
 * - connectmessage.sp from Crazy
 *
 * Usefule DEV Sources:
 * - https://forums.alliedmods.net/image-proxy/cb170eefb344e7490ac18ab8c28e02c67d91017b/68747470733a2f2f7261772e67697468756275736572636f6e74656e742e636f6d2f4d6974636844697a7a6c652f53696d706c6541647665727469736d656e74732f6d61737465722f636f6c6f72732e706e67
 *
 */

#include <sourcemod>
#include <geoip>
#include <cstrike>
#pragma tabsize 0

new Handle:h_connectmsg = INVALID_HANDLE;
new Handle:h_disconnectmsg = INVALID_HANDLE;
 
public Plugin myinfo =
{
	name = "BasiX",
	author = "NIGHTTIMEDEV",
	description = "All you need for professional 5v5 Matchmaking",
	version = "1.0",
	url = "https://github.com/nighttimedev/cs-basix"
};

public void OnPluginStart()
{
	PrintToServer("BasiX Plugin loaded!");
	h_connectmsg = CreateConVar("sm_connectmsg", "1", "Shows a connect message in the chat once a player joins.", FCVAR_NOTIFY | FCVAR_DONTRECORD);
	h_disconnectmsg = CreateConVar("sm_disconnectmsg", "1", "Shows a disconnect message in the chat once a player leaves.", FCVAR_NOTIFY | FCVAR_DONTRECORD);
	
	/* Hooks */
	
	HookEvent("round_start", OnRoundStart, EventHookMode_PostNoCopy);
}

public OnRoundStart(Handle:event, const String:name[], bool:dontBroadcast) {
	int wins_t;
	int wins_ct;
	/* Get Scores */
	wins_t = CS_GetTeamScore(0);
	wins_ct = CS_GetTeamScore(1);
	/* Print Credits, Server-Info, ... whatever */
	PrintToChatAll("\x10[STATSHOW]\x01 (%s) vs (%s)",wins_t,wins_ct);
	PrintToChatAll("");
	PrintToChatAll("");
	PrintToChatAll("");
	PrintToChatAll("");
} 

/*
 * Show Connect / Disconnect messages and log them to the console
 */

public OnClientPutInServer(client)
{
	new Connect = GetConVarInt(h_connectmsg);
	if(Connect == 1)
	{
		new String:name[99], String:authid[99], String:IP[99], String:Country[99];
		GetClientName(client, name, sizeof(name));	
		GetClientAuthId(client, AuthId_Steam2, authid, sizeof(authid));
		GetClientIP(client, IP, sizeof(IP), true);
		PrintToServer("==> New connect from [%s]",IP);
    if(!GeoipCountry(IP, Country, sizeof Country))
    {
        Country = "Unknown Country";
    }  
        PrintToChatAll(" \x04[CONNECT]\x03 %s (%s) has joined the server from [%s]", name, authid, Country);     
    } else {
    CloseHandle(h_connectmsg);
   }
}
public OnClientDisconnect(client)
{
	new Disconnect = GetConVarInt(h_disconnectmsg);
	if(Disconnect == 1)	
	{
		new String:name[99], String:authid[99], String:IP[99], String:Country[99];	
		GetClientName(client, name, sizeof(name));	
		GetClientAuthId(client, AuthId_Steam2, authid, sizeof(authid));	
		GetClientIP(client, IP, sizeof(IP), true);	
	if(!GeoipCountry(IP, Country, sizeof Country))	
    {
        Country = "Unknown Country";
    }  
        PrintToChatAll(" \x04[DISCONNECT]\x03 %s (%s) has left the server from [%s]", name, authid, Country);     
    } else {  
    CloseHandle(h_disconnectmsg);
}
}

public void OnMapStart() {
	new String:map[99], String:displayName[99];
	GetMapDisplayName(map, displayName, sizeof displayName);
	PrintToChatAll("Now playing on [%s]", displayName);
}

public OnClientAuthorized(client, const String:auth[]){
  	if( GetClientCount() < 10 ) {
  		new String:currPlayerCount[99];
  		currPlayerCount[GetClientCount()];
		PrintToChatAll("Wating till all players are connected! Currently: [%s] / 10",currPlayerCount);
  	} else {
   		PrintHintTextToAll("!!! Game starting !!!");
  	}
}
