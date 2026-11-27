package com.pipasoft.jsymphonic;

import java.io.File;

/**
 * where JSymphonic keeps its own files (JSymphonic.xml, JSymphonic.log)
 * 
 * By default they are written in the current folder, like JSymphonic always did,
 * so a copy on a USB stick or on the walkman itself keeps its settings with it.
 * Installed versions start Java with -Djsymphonic.datadir=&lt;folder&gt; instead,
 * because the install folder is usually read-only. A leading "~" in the folder
 * stands for the user's home folder.
 */
public class AppPaths {

	public static final String DATA_DIR_PROPERTY = "jsymphonic.datadir";

	/**
	 * gets the path of one of JSymphonic's own files
	 * 
	 * @param fileName the name of the file, like "JSymphonic.xml"
	 * @return the path of the file, relative to the current folder when no data folder is set
	 */
	public static String dataFile(String fileName) {
		String dir = System.getProperty(DATA_DIR_PROPERTY);
		if (dir == null || dir.isEmpty()) {
			return fileName;
		}
		if (dir.startsWith("~")) {
			dir = System.getProperty("user.home") + dir.substring(1);
		}
		File folder = new File(dir);
		folder.mkdirs();
		return new File(folder, fileName).getPath();
	}
}
