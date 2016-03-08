/**
 * 
 */
package dm06;

import java.util.regex.Pattern;
import java.io.*;

/**
 * @author ggordon
 * @created 6.3.2016
 */
public class FileSeparator {

	private final static String DIR = "medCollection";

	/**
	 * @param args
	 */
	public static void main(String[] args) {
		System.out.println("Received : " + args.length + " args");
		if (args.length == 0) {
             //use default file
			args = new String[]{"dm06/med.all"};
		}
		for (String arg : args) {
			System.out.println("Parsing File : " + arg);
			parseFile(arg);
		}
        System.out.println("Parsing Complete");
	}

	private static void parseFile(String fileName) {
		Pattern newStoryPattern = Pattern.compile("\\.I [0-9]+");
		try {
			verifyDirectoryExists();
			File f = new File(fileName);

			BufferedReader br = new BufferedReader(new FileReader(f));

			String line = null, story = "", filename = null;
			FileWriter tempStoryFile = null;

			while ((line = br.readLine()) != null) {

				// verify whether new file should start
				if (newStoryPattern.matcher(line).find()) {
					saveStory(tempStoryFile,story,filename);
					// refresh buffers
					story = "";
					
					// get filename
					filename = DIR + File.separator + line.split(" ")[1] + ".txt";
					
					// create new file write
					tempStoryFile = new FileWriter(filename);

					// skip .I and .W line
					line = br.readLine();
					line = br.readLine();

				}
				story += line + "\n";
			}
			saveStory(tempStoryFile,story,filename);
			br.close();
		} catch (Exception e) {
			e.printStackTrace(System.err);
		}
	}
	
	private static void saveStory(FileWriter tempStoryFile,String story, String filename) throws IOException{
		if(tempStoryFile != null){
			tempStoryFile.write(story);
			System.out.println("Created "+filename);
		    tempStoryFile.close();
		}
	}

	private static boolean verifyDirectoryExists() {
		try {
			File dir = new File(DIR);
			if (dir.isDirectory())
				return true;
			return dir.mkdir();
		} catch (Exception e) {
			e.printStackTrace(System.err);
			return false;
		}
	}

}
