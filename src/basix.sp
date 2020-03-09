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
 */

#include <sourcemod>
 
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
	PrintToChatAll('\x04BasiX\x07 Plugin loaded!\x01');
}
