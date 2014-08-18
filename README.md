OpenTTD
=======

OpenTTD for the iPad (Note: some hacky code to get things up and running. May attempt to get it working on iPhone)

Added:
* Support for iOS7 and Xcode 5 (Note: now it *always* runs in landscape mode)
* Double tap to zoom in / out (e.g. screen resolution change)
* Multi-tap to cancel current action (e.g. when building roads/rails, if you decide you don't want the current line, press with another finger to cancel)

Might add:
* Dropbox support to sync save files

Note:
* I hacked some changes to libpng too. But as that is a submodule it'll need to be added there (in a branch)

HowTo:
* Clone this repo
* Get the submodules
  * git submodules init
  * git submodules update
* Build the project (Configure, then libpng, then freetype, then openttd)
* Run and enjoy
