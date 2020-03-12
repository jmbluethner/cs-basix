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
 * Non-Commercial use only! Get in touch for more details: info@nighttimedev.com
 * 
 * This Plugin uses:
 * - connectmessage.sp from Crazy
 *
 * Useful DEV Sources:
 * - https://forums.alliedmods.net/image-proxy/cb170eefb344e7490ac18ab8c28e02c67d91017b/68747470733a2f2f7261772e67697468756275736572636f6e74656e742e636f6d2f4d6974636844697a7a6c652f53696d706c6541647665727469736d656e74732f6d61737465722f636f6c6f72732e706e67
 * - https://forums.alliedmods.net/showthread.php?t=261263
 *
 */

#include <sourcemod>
#include <geoip>
#include <cstrike>
#include <sdktools>
#include <sdktools_gamerules>
#pragma tabsize 0
#define CS_TEAM_NONE        0   /**< No team yet. */
#define CS_TEAM_SPECTATOR   1  	/**< Spectators. */
#define CS_TEAM_T       	2 	/**< Terrorists. */
#define CS_TEAM_CT      	3 	/**< Counter-Terrorists. */ 

new Handle:h_connectmsg = INVALID_HANDLE;
new Handle:h_disconnectmsg = INVALID_HANDLE;

public bool kniferound_happened = false;
public bool sidevote_active = false;
public bool gamepause_active = false;

public int knifeWinnerTeam;
public int wins_t;
public int wins_ct;
 
public Plugin myinfo = {
	name = "BasiX",
	author = "NIGHTTIMEDEV",
	description = "All you need for propper 5v5 Matchmaking",
	version = "1.0",
	url = "https://github.com/nighttimedev/cs-basix"
};

public void OnPluginStart() {
	h_connectmsg = CreateConVar("sm_connectmsg", "1", "Shows a connect message in the chat once a player joins.", FCVAR_NOTIFY | FCVAR_DONTRECORD);
	h_disconnectmsg = CreateConVar("sm_disconnectmsg", "1", "Shows a disconnect message in the chat once a player leaves.", FCVAR_NOTIFY | FCVAR_DONTRECORD);
	
	/* Hooks */
	
	HookEvent("round_start", OnRoundStart, EventHookMode_PostNoCopy);
	HookEvent("round_end", OnRoundEnd, EventHookMode_PostNoCopy);
	
	/* Listener */
	
	AddCommandListener(Listener_JoinTeam, "jointeam");
	
	/* Register Commands */
	
	RegConsoleCmd("switch", side_switch);
	RegConsoleCmd("stay", side_stay);
	RegConsoleCmd("sm_pause", pause_match);
	RegConsoleCmd("sm_unpause", unpause_match);
	RegConsoleCmd("playercount", playercount);
	//RegConsoleCmd("help",cmd_help);
}

public Action Listener_JoinTeam(int client, const char[] command, int args) {
	/*
	int clientTeam = GetClientTeam(client);
	PrintToChatAll("\x04TEAM: %d", clientTeam);
	*/
	if(GetClientTeam(client) == CS_TEAM_CT || GetClientTeam(client) == CS_TEAM_T) {
		if( GetClientCount(true) < 10 && wins_t == 0 && wins_ct == 0 && kniferound_happened == false) {
	  		int currPlayerCount;
	  		currPlayerCount = GetClientCount(true);
			PrintToChatAll("Wating till all players are connected! Currently: %d / 10",currPlayerCount);
	  	} else if(GetClientCount(true) == 10 && wins_t == 0 && wins_ct == 0 && kniferound_happened == false) {
			PrintHintTextToAll("!!! Game starting !!!");
			ServerCommand("exec knife.cfg");
			HookEvent("round_end", KnifeEnded, EventHookMode_PostNoCopy);
			PrintToChatAll("\x10!!! KNIFE !!!\x01");
			PrintToChatAll("\x10!!! KNIFE !!!\x01");
			PrintToChatAll("\x10!!! KNIFE !!!\x01");	
	  	}
	  	
	  	new Connect = GetConVarInt(h_connectmsg);
		if(Connect == 1) {
			new String:name[99], String:authid[99], String:IP[99], String:Country[99];
			GetClientName(client, name, sizeof(name));	
			GetClientAuthId(client, AuthId_Steam2, authid, sizeof(authid));
			GetClientIP(client, IP, sizeof(IP), true);
			PrintToServer("==> New connect from [%s]",IP);
	    if(!GeoipCountry(IP, Country, sizeof Country)) {
	        Country = "Unknown Country";
	    }
	    PrintToChatAll(" \x10[CONNECT]\x01 %s has joined the server from [%s]", name, Country);     
	    } else {
	    CloseHandle(h_connectmsg);
	   	}
	}
}

/*
public Action cmd_help(int client, int args) {
	char full[256];
	new String:name[99];
	GetCmdArgString(full, sizeof(full));
	GetClientName(client, name, sizeof(name));
	PrintToChatAll("%d is a pussy and needs help",name);
}
*/

public Action playercount(int client, int args) {
	char full[256];
	GetCmdArgString(full, sizeof(full));
	int playerCount = GetTeamClientCount(CS_TEAM_T) + GetTeamClientCount(CS_TEAM_T);
	int clientCount = GetClientCount(true);
	PrintToChatAll("[CLIENT COUNT] Currently %d // %d Players",playerCount,clientCount);
}

public Action:pause_match(int client, int args) {
	char full[256];
	GetCmdArgString(full, sizeof(full));
	if(!gamepause_active && GameRules_GetProp("m_bWarmupPeriod") == 0) {
		new String:name[99];
		ServerCommand("mp_pause_match");
		GetClientName(client, name, sizeof(name));
		PrintToChatAll("%s triggered a game pause!",name);
		gamepause_active = true;
	} else if(gamepause_active) {
		PrintHintText(client,"A pause has already been triggered!");
	} else if(GameRules_GetProp("m_bWarmupPeriod") == 1) {
		PrintHintText(client,"Can't start pause during warmup!");
	}
}

public Action:unpause_match(int client, int args) {
	char full[256];
	GetCmdArgString(full, sizeof(full));
	if(!gamepause_active) {
		PrintHintText(client,"There is no scheduled pause!");
	} else {
		// Both teams need to !unpause
		// Check if pause was set by admin or players
	}
}

public Action side_switch(int client, int args) {
	char full[256];
	GetCmdArgString(full, sizeof(full));
	if(sidevote_active && GetClientTeam(client) == knifeWinnerTeam) {
		// swap teams & start main	
		sidevote_active = false;
		ServerCommand("mp_swapteams");
		ServerCommand("exec mainround.cfg");
		PrintToChatAll("\x10!!! LIVE !!!\x01");
		PrintToChatAll("\x10!!! LIVE !!!\x01");
		PrintToChatAll("\x10!!! LIVE !!!\x01");
	} else if(sidevote_active && GetClientTeam(client) != knifeWinnerTeam) {
		PrintHintText(client,"You are not in the team that won the knife round! Vote ignored.")	
	} else if(!sidevote_active) {
		PrintHintText(client, "Nothing to vote at the moment!");
	}
}

public Action side_stay(int client, int args) {
	char full[256];
	GetCmdArgString(full, sizeof(full));
	if(sidevote_active && GetClientTeam(client) == knifeWinnerTeam) {
		// dont swap & start main
		sidevote_active = false;
		ServerCommand("exec mainround.cfg");
		PrintToChatAll("\x10!!! LIVE !!!\x01");
		PrintToChatAll("\x10!!! LIVE !!!\x01");
		PrintToChatAll("\x10!!! LIVE !!!\x01");
	} else if(sidevote_active && GetClientTeam(client) != knifeWinnerTeam) {
		PrintHintText(client,"You are not in the team that won the knife round! Vote ignored.")	
	} else if(!sidevote_active) {
		PrintHintText(client, "Nothing to vote at the moment!");
	}
}

public OnRoundStart(Handle:event, const String:name[], bool:dontBroadcast) {
	
} 

public KnifeEnded(Handle:event, const String:name[], bool:dontBroadcast) {
	knifeWinnerTeam = GetEventInt(event, "winner");
	if(knifeWinnerTeam == 2) {
		PrintToChatAll("Team 2 won!");
		PrintToChatAll("The first message from that Team decides !switch or !stay");
		// receive & validate chat commands from team 2
		
} else if(knifeWinnerTeam == 1) {
		PrintToChatAll("Team 1 won!");
		PrintToChatAll("The first message from that Team decides !switch or !stay");
		// receive & validate chat commands from team 1
	} else {
		PrintToChatAll("ERROR! Winning Team couldn't be detected!");}
	}
public OnRoundEnd(Handle:event, const String:name[], bool:dontBroadcast) {
	/* Get Scores */
	wins_t = CS_GetTeamScore(CS_TEAM_T);
	wins_ct = CS_GetTeamScore(CS_TEAM_CT);
	/* stats */
	PrintToChatAll(" \x10[STATSHOW] \x07%d\x01 vs \x0C%d",wins_t,wins_ct);
}

/*
 * Show Connect / Disconnect messages on Player connect / disconnect
 * +
 * Log client IP to server console
 */

public OnClientPutInServer(client) {
	
}

public OnClientDisconnect(client) {
	new Disconnect = GetConVarInt(h_disconnectmsg);
	if(Disconnect == 1)	{
		new String:name[99], String:authid[99], String:IP[99], String:Country[99];	
		GetClientName(client, name, sizeof(name));	
		GetClientAuthId(client, AuthId_Steam2, authid, sizeof(authid));	
		GetClientIP(client, IP, sizeof(IP), true);	
		if(!GeoipCountry(IP, Country, sizeof Country))	
		{
			Country = "Unknown Country";
		}  
			PrintToChatAll(" \x10[DISCONNECT]\x01 %s has left the server from [%s]", name, Country);     
		} else {  
		CloseHandle(h_disconnectmsg);
	}
}

public void OnMapStart() {
	kniferound_happened = false;
	
	PrintToServer("");
	PrintToServer("");
	PrintToServer("-------------------------");
	PrintToServer("");
	PrintToServer(" ! BasiX Plugin loaded ! ");
	PrintToServer("");
	PrintToServer("-------------------------");
	PrintToServer("");
	PrintToServer("");

	ServerCommand("exec basix_gamestart.cfg");

	new String:map[99], String:displayName[99];
	GetMapDisplayName(map, displayName, sizeof(displayName));
	PrintToChatAll("Now playing on %s", displayName);
	/*
	wins_t = CS_GetTeamScore(CS_TEAM_T);
	wins_ct = CS_GetTeamScore(CS_TEAM_CT);
	*/
}

public OnClientAuthorized(client, const String:auth[]){
  	
}
