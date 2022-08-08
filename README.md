# Author
Fulcrum

# Description
BTPog is a UT99 Mutator most useful for the [Bunnytrack](https://github.com/mbovijn/BTPlusPlusTE_beta3) mod. See the section below to get to know more about the individual modules.

# Modules

## BTZeroPingDodge Module
After having dodged the game blocks you from dodging again for [0.35](https://github.com/mbovijn/UT99/blob/master/Engine/PlayerPawn.uc#L4254) seconds (0.32 for BT whichs runs on [hardcore](https://github.com/mbovijn/UT99/blob/master/Botpack/DeathMatchPlus.uc#L139) mode). Unfortunately, players with a higher ping experience a large dodge block duration. BTZeroPingDodge's aim is to level the playing field, and provide an equal dodge block duration for all players, regardless of ping.

Click [here](https://github.com/mbovijn/BTPog/blob/master/DodgeBlock.md) to get to know more about why this is happening.

| Command                                           | Description
| ---                                               | ---
| `!btpog zpdodge`                                  | Toggles the functionality on/off. Enabled by default.
| `!btpog zpdodge debug`                            | Toggles the display of a message on/off each time ZeroPingDodge kicks in.

## BTStats Module
Shows the following information on-screen:
- Ground Time = time in seconds you spent on the ground.
- Air Time = time in seconds you spent in the air i.e. when jumping/falling.
- Dodge Double Tap Interval = time in seconds between two consecutive key presses that resulted in a dodge.
- Dodge Block Duration = time in seconds that you're blocked from dodging again after just having dodged.
- Time Between Dodges = time between the end of the last dodge (player landed), and the beginning of the next dodge.

| Command                                           | Description
| ---                                               | ---
| `!btpog stats`                                    | Toggles the on-screen stats on/off.
| `!btpog stats debug`                              | Toggles debug logging of dodges on/off. These can be found in your `UnrealTournament.log` file.

## BTCapLogger Module
Logs some information each time a player caps. These logs can be found in the UT `Logs` folder. Example:
```
Timestamp,Map,PlayerName,IP,HWID,EngineVersion,Renderer,SpawnCount,CapTime,ClientCapTime,DodgeBlock_1PC,DodgeBlock_5PC,DodgeBlock_25PC,DodgeBlock_50PC,DodgeBlock_100PC,DodgeBlock_Count,DodgeDoubleTap_1PC,DodgeDoubleTap_5PC,DodgeDoubleTap_25PC,DodgeDoubleTap_50PC,DodgeDoubleTap_100PC,DodgeDoubleTap_Count,DodgeAfterLanding_1PC,DodgeAfterLanding_5PC,DodgeAfterLanding_25PC,DodgeAfterLanding_50PC,DodgeAfterLanding_100PC,DodgeAfterLanding_Count,TimeBetweenDodges_1PC,TimeBetweenDodges_5PC,TimeBetweenDodges_25PC,TimeBetweenDodges_50PC,TimeBetweenDodges_100PC,TimeBetweenDodges_Count,FPS_1PC,FPS_5PC,FPS_25PC,FPS_50PC,Ping_1PC,Ping_5PC,Ping_25PC,Ping_50PC
2022-07-06T18:54:36.994,CTF-BT-andACTION-dbl,Fulcrum,127.0.0.1,6AB44D649CBBA3336F9DD0117B78FEEF,469c - Jul  4 2022 Preview,D3D9Drv,1,8.743,+0.017,0.318,0.318,0.319,0.320,0.320,6,0.134,0.134,0.155,0.158,0.218,7,0.000,0.000,0.000,0.000,0.000,0,0.471,0.471,0.471,0.500,0.501,3,47,136,142,144,94,94,94,94
2022-07-06T18:54:45.488,CTF-BT-andACTION-dbl,Fulcrum,127.0.0.1,6AB44D649CBBA3336F9DD0117B78FEEF,469c - Jul  4 2022 Preview,D3D9Drv,2,7.420,-0.001,0.319,0.319,0.319,0.320,0.321,6,0.135,0.135,0.162,0.183,0.233,7,0.000,0.000,0.000,0.000,0.000,0,0.466,0.466,0.466,0.493,0.513,3,138,142,142,144,95,95,95,95
2022-07-06T18:55:13.218,CTF-BT-andACTION-dbl,Fulcrum,127.0.0.1,6AB44D649CBBA3336F9DD0117B78FEEF,469c - Jul  4 2022 Preview,D3D9Drv,3,23.479,-0.000,0.082,0.082,0.318,0.319,0.321,17,0.114,0.114,0.140,0.150,0.203,17,0.125,0.125,0.159,0.162,0.176,8,0.000,0.000,0.000,0.000,0.000,0,136,142,142,144,92,92,93,94
2022-07-06T18:55:22.561,CTF-BT-andACTION-dbl,Fulcrum,127.0.0.1,6AB44D649CBBA3336F9DD0117B78FEEF,469c - Jul  4 2022 Preview,D3D9Drv,4,8.238,-0.000,0.318,0.318,0.318,0.320,0.326,7,0.142,0.142,0.142,0.171,0.197,7,0.000,0.000,0.000,0.000,0.000,0,0.480,0.480,0.501,0.508,0.541,5,140,142,142,144,93,93,93,93
2022-07-06T18:55:43.315,CTF-BT-andACTION-dbl,Fulcrum,127.0.0.1,6AB44D649CBBA3336F9DD0117B78FEEF,469c - Jul  4 2022 Preview,D3D9Drv,5,15.472,-0.036,0.318,0.318,0.319,0.320,0.325,7,0.129,0.129,0.159,0.168,0.191,7,0.000,0.000,0.000,0.000,0.000,0,0.426,0.426,0.463,0.465,0.513,4,9,140,142,144,9,9,11,151
```
- ClientCapTime: the CapTime from the perspective of the client. This should be roughly equal to the server-side CapTime. If the client-side CapTime is significantly higher than the server-side CapTime, it could mean that the player is using a speed hack. See [this diagram](https://github.com/mbovijn/BTPog/blob/master/Resources/ClientCapTime.drawio.png) for more information on how this works.
- DodgeBlock: percentiles on how long a player got blocked from dodging after just having dodged.
- DodgeDoubleTap: percentiles on the time interval between two consecutive key presses which resulted in a dodge.
- DodgeAfterLanding: percentiles on how quick a player dodged after having landed on the ground. Only values below 0.2 seconds are taken into account.
- TimeBetweenDodges: percentiles on the time between the end of the last dodge (player landed), and the beginning of the next dodge. Only values below 0.6 seconds are taken into account.
- FPS: percentiles on the FPS of a player. The FPS calculation can be tweaked with the 'TicksPerFPSCalculation' server-side setting.
- Ping: percentiles on the ping of a player.
- SpawnCount: the amount of times a player has spawned before the cap. If the count is 1, it could mean that the player used a reconnect bug to have a faster cap time.
- HWID: ACE hardware ID. If ACE isn't installed on the server this value will be left empty.

These statistics are interesting if you want to analyze whether a player cheated.

## BTStopwatch Module
Are you sometimes not sure which particular set of moves is faster in order to pass a certain obstacle? Just set a !cp before the obstacle, and a stopwatch after the obstacle. Once you touch the invisible stopwatch, the time it took to reach the stopwatch will appear on screen.

You could also set stopwatches when rushing in order to get quicker feedback on how the run is going. On top of that, whenever you cap and it's a personal best, the individual stopwatch times are saved, in order to give a delta time for the next run.

| Command                                           | Description
| ---                                               | ---
| `!btpog sw` or `!btpog sw <id>`                   | Sets an invisible stopwatch at your current location (and deletes any previously set stopwatch). You can set up to 32 stopwatches. Valid id values: 0, 1, 2, ... 31
| `!btpog sw <id> 50,10,-10`                        | Sets an invisible stopwatch at location 50,10,-10 (and deletes any previously set stopwatch).
| `!btpog sw reset`                                 | Removes the best times associated with all stopwatches.
| `!btpog sw delete <id>`                           | Delete a stopwatch. Valid id values: 0, 1, 2, ... 31, all
| `!btpog sw precision 3`                           | Sets the amount of decimals after the dot for stopwatch times. Defaults to 2 (e.g. 8.63), but any value between 0 and 3 is valid.

## BTSuicide Module
Got loop movers in the map you want to rush? Use this in order to suicide at the right time, so that when you arrive at the mover, the mover is in the optimal location.

>Not all BT maps are deterministic. Some of them have movers that are looping continuously. So when you try to rush such a map, it usually comes down to a matter of luck when you arrive at such a mover. The mover could be in an optimal position, or not. If not, you're losing valuable time.
What rushers can do is, go to the mover, and suicide when the mover is in a particular position, such that when you respawn and rush the map, the mover is in the optimal location. This works, but it's annoying, since you repeat the whole process over and over again. This mutator is trying to address that by allowing you to queue up a suicide action, and only actually executing the suicide when the mover is in the configured location.

| Command                                            | Description
| ---                                                | ---
| `!btpog suicide select`                            | Select which mover you want to base your suicide time on. Just aim at the mover and execute the command.
| `!btpog suicide select Mover12`                    | Select which mover you want to base your suicide time on by providing the name of the mover.
| `!btpog suicide time`                              | When the mover is in the correct location, execute this command to set the time.
| `!btpog suicide time 0.35`                         | Same as the previous command, but here you can enter a timepoint yourself.
| `!btpog suicide suicide`                           | Queue up a suicide action. The mutator will make you suicide you as soon as the mover is in the configured location.

For ease of use you could bind your suicide key to the suicide command e.g. `set input g mutate btpog suicide suicide`.

# Installation
1. Download the latest release from the [Releases page](https://github.com/mbovijn/BTPog/releases/).
2. Extract the contents of the `Build` folder to the UT99 `System` folder.
3. Configure BTPog accordingly by editing `BTPog.ini`.
4. Add the following lines under the `[Engine.GameEngine]` section in `UnrealTournament.ini`:
```
ServerActors=BTPog_v10.Main
ServerPackages=BTPog_v10
```

# Configuration
As a server admin you can configure which modules you want to be active on your server. Here's an example of a BTPog.ini file:
```
[Settings]
IsDebugging=False
IsBTStatsEnabled=True
IsBTStopwatchEnabled=True
IsBTSuicideEnabled=True
IsBTZeroPingDodgeEnabled=True
IsBTCapLoggerEnabled=True

[BTCapLoggerSettings]
TicksPerFPSCalculation=10
```
