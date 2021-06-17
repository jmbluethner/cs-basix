<img src="https://img.shields.io/github/license/nighttimedev/cs-basix?style=flat-square"> <img src="https://img.shields.io/github/size/nighttimedev/cs-basix?style=flat-square"> <img src="https://img.shields.io/github/downloads/nighttimedev/cs-basix/total?style=flat-square">

# basix
## A sourcepawn plugin for propper 5v5 CS:GO Matchmaking
---
### Included is ...
- The Plugin itself
- Several config files
### Functions  
basix is capable of performing the following tasks:  
- Automatically start the knife round once all players are connected
- Fully automatic !switch / !stay options for the knife round winning team
- Custom config files which turn your srcds server into the perfect matchmaking platform.

cfg | functions | usage |
----|-----------|-------|
server.cfg | - Force 128 tick on client & server<br>- Enable Overtime<br>- Enable Team damage<br>- Set all minor settings (max-money,...) | Gets automatically called by the server on startup |
basix_gamestart.cfg | - Sets the warmup time to 3600 secs | Gets called by basix once a new map starts. Increases warmup time so all players can connect. |
gamemode_competetive.cfg | - Disables player votes | It's the vanilla config file, but player votes are disabled
knife.cfg | - No money<br>- Increased roundtime<br>- No C4 |Gets called by basix once all players are connected, no knife-round has happened on the current map and the score is 0:0|
mainround.cfg | - Reset default secondary weapons (removed by knife.cfg)<br>- Reset roundtime (changed by knife.cfg)<br>- Enable C4 (removed by knife.cfg)

### Installation  
- Install sourcemod + metamod (tutorials are available on YouTube)
- Compile /src/basix.sp (use spider.limetech.io)

> <span style="color:red"><b>Make sure to compile the .sp file!</b> There might already be a compiled .smx in the /src folder, but that can be outdated, modified or even corrupted!</span>

- Move the compiled .smx to /addons/sourcemod/plugins on your server
- Move all files from /cfg to /csgo/cfg on your server

### SQL Connection
The plugin can connect to a SQL database. Just fill in your database information in /cfg/databases.cfg

### Usage  
- Install the plugin as described above
- Copy the config files
- Done

### Commands  
