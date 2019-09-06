# sdl2test
Small examples of libSDL2 usage in V, C and C++ languages.
Historically, the purpose was to evaluate the changes from SDL1 to SDL2.

# Credits
tetris_v.v is just and SDL port of original source from <a href='https://github.com/vlang/v'>vlang/v</a> example by Alex
- wrote simple SDL2 V wrapper, ported GLFW to SDL, tweaked colors and added music & sounds

<img src='https://github.com/nsauzede/sdl2test/raw/master/tetris_v.png'>

tvintris0_v.v is a dual-player (local) version, inspired by ancient game Twintris
-uses published vpm module nsauzede.vsdl2

Colors, Music and Sounds ripped from amiga title Twintris (1990 nostalgia !)
- Graphician : Svein Berge
- Musician : Tor Bernhard Gausen (Walkman/Cryptoburners)

# Dependencies
Ubuntu :
`$ sudo apt install libsdl2-ttf-dev libsdl2-mixer-dev`

ClearLinux :
`$ sudo swupd bundle-add devpkg-SDL2_ttf devpkg-SDL2_mixer`

Windows/MSYS2 :
`$ pacman -S mingw-w64-x86_64-SDL2_ttf mingw-w64-x86_64-SDL2_mixer`


# Misc
Makefile auto-detects available SDL version (2 or 1)

- vsdl : naive V wrapper for SDL2 binding
- CSDL : small C++ class to abstract SDL1/2
- various C and V examples to
