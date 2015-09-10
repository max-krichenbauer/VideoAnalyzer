import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.util.Calendar;
import java.text.SimpleDateFormat;
public static final String DATE_FORMAT_NOW = "yyyy-MM-dd_HHmmss";


void makeBackup()
{
  File file = new File(path+".log");
  if (!file.exists()) {
    return;
  } // else: make a backup
  
  Calendar cal = Calendar.getInstance();
  SimpleDateFormat sdf = new SimpleDateFormat(DATE_FORMAT_NOW);
  String timestamp = sdf.format(cal.getTime());
  String backup_file_path = new String(path+".BAK_"+timestamp+".log");
  File backup_file = new File(backup_file_path);
  
  
  if(!backup_file.exists()) {
    try {
      backup_file.createNewFile();
    } catch (Exception e) {
      println("Failed to create backup file :"+backup_file_path);
      return;
    }
  }
  try {
    FileInputStream source = new FileInputStream(file);
    FileOutputStream destination = new FileOutputStream(backup_file);
    destination.getChannel().transferFrom(source.getChannel(), 0, source.getChannel().size());
    source.close();
    destination.close();
  } catch (Exception e) {
    println("Failed to create backup: Could not transfer file contents");
  }
}

//                                                                              ____________________
//_____________________________________________________________________________/  saveAnnotations()
void saveAnnotations(String path)
{
  PrintWriter f = createWriter(path+".log");
  for(Annotation annotation : annotations) {
    f.print(annotation.name + ":");
    for(Timeslot timeslot : annotation.timeslots) {
      f.print(timeslot.start + "-" + timeslot.end + ";");
    }
    f.println();
  }
  f.flush();  // Writes the remaining data to the file
  f.close();  // Finishes the file
}


//                                                                              ____________________
//_____________________________________________________________________________/ loadAnnotations()
void loadAnnotations(String path)
{
  // First test if the log file exists
  File f = new File(path+".log");
  if (!f.exists()) {
    println("Log file does not exist");
    return;
  }
  String lines[] = loadStrings(path+".log");
  annotations = new ArrayList<Annotation>();
  for(String line : lines) {
    String[] parts = split(line, ':');
    if(parts.length != 2) {
      print("ERROR READING FROM LOG FILE: line=");
      println(line);
      continue;
    }
    Annotation a = new Annotation();
    a.name = parts[0];
    String[] slots = split(parts[1], ';');
    for(String slot : slots) {
      if(slot.length() == 0) {
        continue;
      }
      String[] slot_t = split(slot, '-');
      if(slot_t.length != 2) {
        print("ERROR READING SLOT FOR '");
        print(a.name);
        print("' slot entry=");
        println(slot);
        continue;
      }
      Timeslot t = new Timeslot();
      t.start = Float.parseFloat(slot_t[0]);
      t.end   = Float.parseFloat(slot_t[1]);
      a.timeslots.add(t);
    }
    annotations.add(a);
  }
}