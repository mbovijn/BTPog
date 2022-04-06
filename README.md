# BTPog

## Author
Fulcrum

## Description
BTPog has 3 different components. They can all be triggered through mutate commands or by speaking in chat, e.g. `mutate btpog suicide select` or say `!btpog suicide select`.

### Component 1: Suicide
Got loop movers in the map you want to rush? Use this in order to suicide at the right time, so that when you arrive at the mover, the mover is in the optimal location.

>Not all BT maps are deterministic. Some of them have movers that are looping continuously. So when you try to rush such a map, it usually comes down to a matter of luck when you arrive at such a mover. The mover could be in an optimal position, or not. If not, you're losing valuable time.
What rushers can do is, go to the mover, and suicide when the mover is in a particular position, such that when you respawn and rush the map, the mover is in the optimal location. This works, but it's annoying, since you repeat the whole process over and over again. This mutator is trying to address that by allowing you to queue up a suicide action, and only actually executing the suicide when the mover is in the configured location.

| Command                                                 | Description
| ---                                                     | ---
| `mutate btpog suicide select`                           | Select which mover you want to base your suicide time on. Just aim at the mover and execute the command.
| `mutate btpog suicide time`                             | When the mover is in the correct location, execute this command to set the time.
| `mutate btpog suicide time 0.35`                        | Same as the previous command, but here you can enter a timepoint yourself.
| `mutate btpog suicide suicide`                          | Queue up a suicide action. The mutator will make you suicide you as soon as the mover is in the configured location.
| `mutate btpog suicide fire`                             | Queue up a fire action. The mutator will make you fire as soon as the mover is in the configured location. This was mosly used for debugging.

For ease of use you could bind the suicide command to a key i.e. `set input g mutate btpog suicide suicide`.

### Component 2: Stopwatch
Are you sometimes not sure which particular set of moves is faster in order to pass a certain obstacle? Just set a !cp before the obstacle, and a stopwatch after the obstacle. Once you touch the invisible stopwatch, the time it took will appear on screen.

| Command                                                 | Description
| ---                                                     | ---
| `mutate btpog stopwatch set`                            | Sets an invisible stopwatch at your current location, and deletes any previously set stopwatch.
| `mutate btpog stopwatch set 50,10,-10`                  | Sets an invisible stopwatch at location (50,10,-10), and deletes any previously set stopwatch.
| `mutate btpog stopwatch clear`                          | Clears any earlier set stopwatch.

### Component 3: Stats
Shows the delta time between two consecutive key presses that resulted in a dodge.

| Command                                                 | Description
| ---                                                     | ---
| `mutate btpog stats on`                                 | Turn the stats on.
| `mutate btpog stats off`                                | Turn the stats off.

## Installation
1. Download the latest release from the [Releases page](https://github.com/mbovijn/BTPog/releases/).
2. Copy `BTPogV1.u` to the `System` folder.
3. Add the following line under the `[Engine.GameEngine]` section in `UnrealTournament.ini`:
```
ServerActors=BTPogV1.Main
ServerPackages=BTPogV1
```
