# DaBlocksWorld

DaBlocksWorldPlanning is an implementation of the "Blocks World" planning Problem (https://en.wikipedia.org/wiki/Blocks_world) in the Godot Game Engine.
In this implementation Clingo is used to solve the randomly generated puzzle.


If you want to learn more about this implementation you can read the paper in the paper folder.
For more details about the ASP encoding you can refer to the original paper: https://aaai.org/ojs/index.php/aimagazine/article/view/2673 .


If you just want to play the game builds for Linux, Windows and Mac are available but only the Linux version is tested.

At the moment the ready made executable for Windows/Mac/Linux of clingo is used therefore an android/iOS port is unavailable.
However with GDNative it could be possible to cross compile the c++ source of clingo and use it on android/iOS.


## How to play

In the classic blocks world planning problem a (random) start configuration should be transformed to a (random) goal configuration.
In DaBlocksWorld however the goal configuration is not random. 
The blocks allways need to be stacked with increasing numbers.
The number in the top right corner indicates the height of each stack.
As seen here:

## Screenshots
![Image of Yaktocat](https://octodex.github.com/images/yaktocat.png)

### Credits

code/general design: DaAppLab </br>
earth model: CraigForster (https://www.blendswap.com/blend/18286) </br>
music: Aviators - Infinity Awaits Us (https://www.youtube.com/watch?v=sisGSwT2eN0&t=259s)</br>
