import java.util.Calendar;
import java.text.SimpleDateFormat;
public static final String DATE_FORMAT_NOW = "yyyy-MM-dd_HH:mm:ss";

void saveAnnotations() {
  PrintWriter f = createWriter(path+".log");
  for(Annotation annotation : annotations) {
    f.print(annotation.name + ":");
    for(Timeslot timeslot : annotation.timeslots) {
      //float t0 = ((float)timeslot.start / (float)width) * mov.duration();
      //float t1 = ((float)timeslot.end / (float)width) * mov.duration();
      //f.print(t0 + "-" + t1 + ";");
      f.print(timeslot.start + "-" + timeslot.end + ";");
    }
    f.println();
  }
  f.flush();  // Writes the remaining data to the file
  f.close();  // Finishes the file
}

void loadAnnotations() {
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
      //t.start = (int)((Double.parseDouble(slot_t[0]) * (double)width) / mov.duration());
      //t.end   = (int)((Double.parseDouble(slot_t[1]) * (double)width) / mov.duration());
      t.start = Float.parseFloat(slot_t[0]);
      t.end   = Float.parseFloat(slot_t[1]);
      a.timeslots.add(t);
    }
    annotations.add(a);
  }
}