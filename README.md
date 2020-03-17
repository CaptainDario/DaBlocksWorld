# DaBlocksWorld

DaBlocksWorldPlanning is an implementation of the "Blocks World" planning Problem (https://en.wikipedia.org/wiki/Blocks_world) in the Godot Game Engine.
In this interactive implementation a configuration gets randomly created and then solved by Clingo (https://potassco.org/clingo/).


If you want to learn more about this implementation you can read the paper in the paper folder.
If you are still interested after reading the paper above you can refer to the original paper: https://aaai.org/ojs/index.php/aimagazine/article/view/2673 .


If you just want to play the game, builds for Linux, Windows and Mac are available but only the Linux/Windows version are tested.

At the moment the ready made executable for Windows/Mac/Linux of clingo is used therefore an android/iOS port is unavailable.
However with GDNative it could be possible to cross compile the c++ source of clingo and use it on android/iOS.


## How to play

In the classic blocks world planning problem a (random) start configuration should be transformed to a (random) goal configuration.
In DaBlocksWorld however the goal configuration is not random. 
The blocks allways need to be stacked with increasing numbers sorted by color. </br>
![Start to finish](https://www.visittranas.com/wp-content/uploads/2018/03/placeholder.jpg)
</br> However the placement of the stacks does not matter. </br>
![Amibigous goal configs](https://www.visittranas.com/wp-content/uploads/2018/03/placeholder.jpg)

## Screenshots
![Main Menu](https://www.visittranas.com/wp-content/uploads/2018/03/placeholder.jpg)
![In Game start](https://www.visittranas.com/wp-content/uploads/2018/03/placeholder.jpg)
![In Game finished](https://www.visittranas.com/wp-content/uploads/2018/03/placeholder.jpg)

### Credits

code/general design: Dario </br>
earth model: CraigForster (https://www.blendswap.com/blend/18286) </br>
music: Aviators - Infinity Awaits Us (https://www.youtube.com/watch?v=sisGSwT2eN0&t=259s)</br>
