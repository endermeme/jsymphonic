#!/usr/bin/env bash
#
# Builds a ready-to-run JSymphonic for the current OS, with its own Java runtime
# (users don't need to install Java). Run it after "mvn package".
#
#   packaging/package.sh <version>
#
# Output, in dist/:
#   Linux    JSymphonic-<version>-x86_64.AppImage   (needs appimagetool, or set APPIMAGETOOL)
#   Windows  JSymphonic-<version>-windows-x64.msi   (needs WiX 3) and a portable .zip
#   macOS    JSymphonic-<version>-macos-<arch>.dmg
#
# Settings and log are kept in the user's folder (see AppPaths.java), because
# the install folder is read-only.
set -euo pipefail

version="${1:?usage: packaging/package.sh <version>}"
cd "$(dirname "$0")/.."

rm -rf build/jpackage dist
mkdir -p build/jpackage/input dist
cp target/jsymphonic-*-jar-with-dependencies.jar build/jpackage/input/jsymphonic.jar

common=(
	--name JSymphonic
	--vendor JSymphonic
	--description "Transfer music to Sony Walkman players"
	--input build/jpackage/input
	--main-jar jsymphonic.jar
	--main-class org.danizmax.jsymphonic.gui.JSymphonic
	--add-modules java.base,java.desktop,java.logging,jdk.charsets,jdk.localedata
	--jlink-options "--strip-debug --no-man-pages --no-header-files --strip-native-commands --include-locales=en,cs,de,es,fr,it,pt,ru,sk,sl,sv,tr,vi,zh"
	--dest build/jpackage
)

case "$(uname -s)" in
Linux*)
	jpackage "${common[@]}" --type app-image --app-version "$version" \
		--icon packaging/icons/jsymphonic.png \
		--java-options '-Djsymphonic.datadir=~/.config/jsymphonic'

	appdir=build/JSymphonic.AppDir
	rm -rf "$appdir"
	mkdir -p "$appdir/usr"
	cp -r build/jpackage/JSymphonic/. "$appdir/usr/"
	cp packaging/linux/jsymphonic.desktop "$appdir/"
	cp packaging/icons/jsymphonic.png "$appdir/"
	ln -s usr/bin/JSymphonic "$appdir/AppRun"
	ARCH=x86_64 "${APPIMAGETOOL:-appimagetool}" "$appdir" "dist/JSymphonic-$version-x86_64.AppImage"
	;;

MINGW* | MSYS* | CYGWIN*)
	windows=(
		--app-version "$version"
		--icon packaging/icons/jsymphonic.ico
		--java-options '-Djsymphonic.datadir=~/AppData/Roaming/JSymphonic'
	)
	jpackage "${common[@]}" "${windows[@]}" --type msi \
		--win-menu --win-shortcut --win-dir-chooser \
		--win-upgrade-uuid 69db8b4f-0577-4c3f-afd0-7e1982d80d6c
	mv build/jpackage/JSymphonic-*.msi "dist/JSymphonic-$version-windows-x64.msi"

	jpackage "${common[@]}" "${windows[@]}" --type app-image
	(cd build/jpackage && 7z a -tzip "../../dist/JSymphonic-$version-windows-x64-portable.zip" JSymphonic)
	;;

Darwin*)
	iconset=build/jsymphonic.iconset
	mkdir -p "$iconset"
	for size in 16 32 128 256; do
		sips -z $size $size packaging/icons/jsymphonic.png --out "$iconset/icon_${size}x${size}.png" >/dev/null
		sips -z $((size * 2)) $((size * 2)) packaging/icons/jsymphonic.png --out "$iconset/icon_${size}x${size}@2x.png" >/dev/null
	done
	iconutil -c icns "$iconset" -o build/jsymphonic.icns

	# No --app-version here: macOS refuses bundle versions starting with 0.
	jpackage "${common[@]}" --type dmg \
		--icon build/jsymphonic.icns \
		--java-options '"-Djsymphonic.datadir=~/Library/Application Support/JSymphonic"'
	mv build/jpackage/JSymphonic-*.dmg "dist/JSymphonic-$version-macos-$(uname -m).dmg"
	;;

*)
	echo "Unsupported OS: $(uname -s)" >&2
	exit 1
	;;
esac

ls -l dist
