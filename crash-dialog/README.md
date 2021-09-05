# Piss Header Crash Dialog

- "It's by me!" - gedehari

A crash dialog aiming to make crash reports better, based of Izzy Engine's crash dialog.
This is a pain to setup, and for the average joe, it takes about 3 hours to be able to compile this singular thing.

## First off...

Get wxWidgets. https://https://www.wxwidgets.org/ In Windows, you need to compile this.

### Mac OS

You need at least OSX 10.7 and you can install wxWidgets with:

```
brew update
brew install wxwidgets
```

### Mac OS

wxWidgets can be installed on debian/ubuntu with:

```
apt-get install libwxgtk3.0-dev libwxbase3.0-dev libwxgtk-webview3.0-dev
```

while using the packaged wxWidgets on OSX and Linux may suffice they are often fairly out of date and can cause various problems both visually and during complilation. Its usually better to build directly from source.

### Windows

Download and install wxWidgets using installer from https://www.wxwidgets.org/downloads/

Create WXWIN environment var if setup didnt (eg: C:\wxWidgets-3.0.2)

Run vcvarsall.bat from Visual Studio dir (eg: "C:\Program Files (x86)\Microsoft Visual Studio 14.0\VC\vcvarsall.bat") (Can't find it? Google it you chump.)

Build shared and static releases of wxWidgets:
- cd %WXWIN%\build\msw\
- nmake.exe -f makefile.vc BUILD=release TARGET_CPU=X64
- nmake.exe -f makefile.vc BUILD=release SHARED=1 TARGET_CPU=X64

## hxWidgets

hxWidgets is a set of externs (and wrappers) for haxe that allows haxeui-hxwidgets to use the wxWidgets C++ library from Haxe. This can be installed from HaxeLib as follows:

```
haxelib install hxcpp
haxelib install hxWidgets
```

## haxeui-hxwidgets

Now you have both wxWidgets and hxWidgets installed, you can install haxeui-hxwidgets. This has a dependency to haxeui-core, and so that too must be installed. Once haxeui-core is installed, haxeui-hxwidgets can be installed using:

```
haxelib install haxeui-hxwidgets
```

# What's next?

Compile the file hxwidgets-windows.hxml if you're on Windows and hxwidgets-linux.hxml if you're on Linux using
```haxe [hxwidgets-windows.hxml|hxwidgets-linux.hxml]```
No mac version yet :(

After that, get the Main.exe file from the build/[system] folder, rename it to pissEater.exe, then put it in the dlls directory from the root directory of the source code of the mod and recompile! (the one with assets/, docs/ and source/ not the folder this readme is in)