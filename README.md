Cross compilation of a standard hello world program for the Amiga

Hello Amiga
===========

Compile on OS X or GNU/Linux and run the hello executable from an
Amiga emulator (UAE).

It should be enough to clone this repo and run make from the base
directory. That should download the vasm assembler and vlink linker,
build them, compile the hello executable from the hello.s source code
and finally create a zip-file containing only the hello Amiga
executable.

Note. A zip-file can be mounted as a harddisk in (at least) FS-UAE.


UAE instructions
================

First you have to specify kickstart and workbench images. The most
common Amiga model was the 500. Use kickstart/workbench 1.3 for that
model (Can be bought from Amiga Forever or if you own an Amiga 500,
you can legally download the images from the internet).

Select the kickstart 1.3 image as Kickstart ROM and the Workbench 1.3
image as the first hard disk.

Now select hello.zip (created by running make) as the second hard disk
in UAE and click Start to fire up the emulator.

Klick on Workbench1.3 and then Shell to enter the Amiga shell. The
second hard disk should be named DH1. So run the command "cd DH1:"
followed by "dir" (to list the contents of the zip-file, posing as
hard disk).

    1.SYS:> cd DH1:
    1.DH1:> dir
      .info   hello

Now execute the hello binary by simply entering the command hello:

    1.DH1:> hello

If it prints "Hello, World!" then it works.


CLI tip
=======

try:

    1.SYS:> dh1:hello              ; without the cd command


Now what?
=========

Now you can start replacing the assembly code in hello.s with your own
code, run make again and execute your code inside the UAE emulator.


Learn the Amiga
===============

* Amiga Hardware Reference Manual
* Amiga System Programmer's Guide
  http://www.retro-commodore.eu/amiga-development/


By the way
==========

Since the time that has elapsed since I wrote the sentences above I've
committed some examples. To try them, just change the second line in
the Makefile from:

    EXE = hello

to the name of one of the other .s files in the repo (without the .s
extension):

* EXE = hello        ; Hello, World! program using dos.library
* EXE = copper       ; Copper coprocessor example
* EXE = playfields   ; Playfields example
* EXE = c1           ; Copper-1 from vikke.net (floating copper bars)

I have successfully compiled all of the examples with vasm/vlink and
executed them on the UAE emulator (using Kickstart ROM v1.3).


TODO
====

* Add examples from http://coppershade.org/


Good Luck!


Señor Albert "Hickle Fickle" Veli

    ~~=) All Rights Reversed - No Rights Reserved (=~~

Sweetmorn, the 62nd day of Bureaucracy in the YOLD 3180

.

PS Om du talar svenska, se demoskolan för Amiga som startar i nummer
1990-09 av SHN: http://hemdatornytt2.selda.se/tidningsarkiv/

.

```
                  █▒░░░▒░▒█
            █▓▓░   ░░▓▓▓▓▓▓▓░░░▒▓
         ▓░ ░▓▓▓▓▓▒░▓▓▓▓▓▓▓▒░░░░░██▒
       ▒   ▒▓▓▓▓▓▓░░░░░░░░░▓▒░░░░▒███▒
     ▓   ░▓▓▒▒▒▒▒  ░░░░░░░▓▓▓█████▒███▓▒
    ░▓▓▓░░░▒▒▒▒▒   ░░░░░░░▓▓▓█████▒▒▒▒▓▓▓
   ▒▓▓▓░       ▒▒▒▒▒▒░░░░▓▓▓▓█████▒▒▒▒▒▒██
  ░▓▓▓▒       ░▒▒▒▒▒▒▓▓▓▒░░░▓▓████▒▒▒▒▒▒███
 ░▓▓▓▓       ░▒▒▒▒▒▒▒▓▓▓░░░░░░▒▒▒▒▓▒▒▒▒▒▓███
 ░░░░▒▓░░    ▒▒▒▒▒▒▓▓▓▓▒░░░░░▒▒▒▒▒██████▓███
▒░░░░▓▓▓▓▓▓▒▒░░▒▓▓▓▓▓▓▓░░░░░▒▒▒▒▒▓███████▓▓▓▒
▒░░░░▓▓▓▓▓▓▓░░░░░░░░░░▒░░░▒▒▒▒▒▒▒███████▓▓▓▓▓
░░░░▒▓▓▓▓▓▓▓░░░░░░░░░░▓██████▓▒▒▓███████▓▓▓▓▒
 ▓▓▓░▓▓▓▓▓▓░░░░░░░░░░▓██████████▒▒▒▓▓▓██▓▓▓▓
 ▓▓▓▒░░░░░▒░░░░░░░░▒▒██████████▒▒▓▓▓▓▓▓████▓
  ██▓░░░░░░████▓▓▒▒▒▓█████████▓▓▓▓▓▓▓▓████▓
   ▓█░░░░░▒█████████▒▒▒▒▓█████▓▓▓▓▓▓▓▓████
    ▒▒▒▒▒▒▒████████▒▒▒▒▒▒▒▒▓▓█████▓▓▓███▓
     ▒▓███▒████████▒▒▒▒▒▓▓▓▓███████▓▓▓▓▓
       ▒███▒▒▒▒▒▓█▒▒▓▓▓▓▓▓▓███████▓▓▓▓
         ░██▓▓▓▓▓▓███████▓██████▓▓▓
             ▓▓▓▓███████▓▓▓▓▓▓██
```
