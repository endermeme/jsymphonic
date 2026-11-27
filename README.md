# Jsymphonic Revival

Note that I am not the orignal author. Jsymphonic was/is located at https://sourceforge.net/projects/symphonic/ and it appears the original author, nicolas_cardoso, abandoned it. This repository is just me moving the code to github and changing a couple things so it will work on modern JVMs and converting the build so it's more modern (I changed it to build with Maven). I did not change any of the functionality, so this should work exactly as before. I tried it on linux and it works. If anyone tries it on Windows or mac, please let me know.

## Running Jsymphonic
Download the latest jar from https://github.com/brianpipa/jsymphonic/releases/ and then you need to run it. Depending on your OS, and what you have configured, the way to do this may vary. See https://brianpipa.github.io/jsymphonic for full run instructions

### Ready-to-run builds
Each release also has builds that include their own Java, so nothing else needs to be installed:
- **Windows**: `JSymphonic-<version>-windows-x64.msi` (installer) or `-portable.zip` (unzip and run `JSymphonic.exe`)
- **macOS**: `JSymphonic-<version>-macos-arm64.dmg` (Apple Silicon) or `-macos-x86_64.dmg` (Intel). The app is not signed: the first time, right-click it and choose *Open*.
- **Linux**: `JSymphonic-<version>-x86_64.AppImage` (make it executable and run it). On Arch Linux: `yay -S jsymphonic` from the AUR.

These builds keep their settings (`JSymphonic.xml`) and log in the user's folder: `~/.config/jsymphonic` on Linux, `%APPDATA%\JSymphonic` on Windows, `~/Library/Application Support/JSymphonic` on macOS. The plain jar still keeps them in the current folder, as before; start it with `-Djsymphonic.datadir=<folder>` to change that.

## Languages
English, Chinese, Deutsch, Español, Français, Svenska, Tiếng Việt, Türkçe and Русский. Choose one in *Properties > Interface*, then restart JSymphonic. The translations are in `src/main/resources/localization`; `swing_<locale>.properties` translates the standard dialogs (Yes/No buttons, file chooser) for languages Java does not translate itself.

## Building Jsymphonic (for developers only)
Clone this repo then install the jars to your local maven repo with these commands:
```
mvn install:install-file -Dfile=./jars/jaudiotagger.jar -DgroupId=org -DartifactId=jaudiotagger -Dversion=1.0 -Dpackaging=jar
mvn install:install-file -Dfile=./jars/swing-layout.jar -DgroupId=org.jdesktop.layout -DartifactId=swing-layout -Dversion=1.0 -Dpackaging=jar
```
Once that's done, you can build it with `mvn package` that will create target/jsymphonic-0.4-jar-with-dependencies.jar which is your runnable jar

To build the ready-to-run packages for your OS, run `packaging/package.sh <version>` after `mvn package` (it uses `jpackage` from JDK 14+). Pushing a version tag to GitHub builds all of them and publishes a release (see `.github/workflows/release.yml`). The AUR package is in `packaging/aur`.

The previous build used precompiled jars in a weird way so I packaged those up into the jars you see in the /jars directory. I tried using moremodern maven-capable versions but they didn't work and I couldn't find the versions that were used here so I just packaged them into jars to make the build "better". Someone could probably change the code to use the newer libraries but it really didn't seem worth it at this point. There's lots of opportunity for code improvement, but unless someone is adding new features, it just doesn't seem worth it right now.

Any new files I add will be in https://github.com/brianpipa/jsymphonic/tree/main/src/main/java/com/pipasoft/jsymphonic I did add ResourceLoader.java to centralize the loading of the icon images.

I had to change two places in the code where it looked at the java version. One is here: https://sourceforge.net/p/symphonic/code/HEAD/tree/jsymphonic/branches/v0.3/src/org/danizmax/jsymphonic/gui/JSymphonicWindow.java#l361 - this code can't handle modern JVMs when they return a version of something like "17.0.7". I ended up just removing the version check altogether - you can see it here: https://github.com/brianpipa/jsymphonic/blob/main/src/main/java/org/danizmax/jsymphonic/gui/JSymphonicWindow.java#L363
