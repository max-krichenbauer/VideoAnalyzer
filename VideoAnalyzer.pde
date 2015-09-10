import java.io.File;
import processing.video.*;

String path = "C:/Users/max-k/GoogleDrive/userstudy/02_2DUI_small.mp4";
Movie mov;


class Timeslot {
  float start;
  float end;
}

class Annotation {
  String name;
  ArrayList<Timeslot> timeslots = new ArrayList<Timeslot>();
}

boolean ctrl_pressed = false;
boolean edit_name_mode = false;
int     edit_slot_mode = 0; // 0 = false, 1=start point, 2=end point
Timeslot edit_slot = null;
int     current_track = 0;

float   current_t = 0;   // time delta in movie (0~1)
float   current_time = 0;// time in movie (seconds)

float   in_point = 0;  // current section / zoom start point (0~1)
float   out_point = 1; // current section / zoom end point (0~1)
int     edit_timeline_mode = 0; // 0=no editing, 1=edit in-point, 2=edit out-point


ArrayList<Annotation> annotations = new ArrayList<Annotation>();

void setup() {
  size(1900, 1000); // displayWidth, displayHeight); // mov.width/2, mov.height/2);
  frameRate(30); // mov.frameRate());
  
  mov = new Movie(this, path);
  mov.play();
  mov.pause();
  mov.speed(1);
  mov.volume(0);
  loadAnnotations();
}
void movieEvent(Movie m) {
  m.read();
}
void draw() {
  // if CTRL is pressed, loop around current position
  if(ctrl_pressed) {
    mov.play();
    //if(mov.time() > current_time+1) {
    //  mov.jump(current_time-1);
    //}
  } else { // scrubbing mode
    current_t = ((float(mouseX) / float(width)) * (out_point-in_point)) + in_point;
    if(current_t < 0) {
      current_t = 0;
    }
    if(current_t > 1) {
      current_t = 1;
    }
    current_time = mov.duration() * current_t; 
    mov.play();
    mov.jump(current_time);
    mov.pause();
  }
  image(mov, 0, 0, width, height);
  
  // draw slider bar for in-point / out-point at the bottom of the screen
  stroke(#000000, 127);
  line(0, height-20, width, height-20);
  fill(#AAAAFF, 127);
  int x_in  = int(in_point  * float(width));
  int x_out = int(out_point * float(width));
  rect(x_in    , height-20, 20, 20);
  rect(x_out-20, height-20, 20, 20);
  float t_range = out_point - in_point;
  
  // indicate current selected time
  stroke(0);
  // int current_t_line = (int)(current_t*width);
  int current_t_line = int(float(width)*(current_t-in_point)/t_range);
  line(current_t_line, 0, current_t_line, height);
  
  // indicate current movie time
  //int mov_t_line = (int)(width * mov.time() / mov.duration());
  int mov_t_line = (int)(width * ((mov.time() / mov.duration())-in_point) / t_range);
  if(mov_t_line == current_t_line) {
    mov_t_line += 1;
  }
  stroke(#FF0000);
  line(mov_t_line, 0, mov_t_line, height);
  
  // render annotations
  stroke(0);
  
  int i = 0;
  textSize(10);
  for(Annotation annotation : annotations) {
    stroke(#000000, 127);
    line(0, (i+1)*20, width, (i+1)*20);
    
    // draw the time slots
    float f = float(width) / mov.duration();
    for(Timeslot timeslot : annotation.timeslots) {
      if(timeslot == edit_slot) {
        fill(#FFFF00, 127);
      } else {
        fill(#FFFFFF, 127);
      }
      //int x0 = int(timeslot.start * f);
      //int x1 = int(timeslot.end   * f);
      int x0 = int(width * ((timeslot.start / mov.duration())-in_point) / t_range);
      int x1 = int(width * ((timeslot.end   / mov.duration())-in_point) / t_range);
      rect(x0, i*20, 
           x1-x0, 20);
    }
    
    // draw this track name
    if(edit_name_mode && current_track == i) {
      fill(#FFFF00);
    } else {
      fill(0);
    }
    text(annotation.name, 5, (i+1)*20 - 10);
    
    i++;
  }
}


void keyPressed() {
  //if ((key == 'Q') || (key == 'q')) {
  //  terminate();
  //}
  if (key == ' ' || (key ==  CODED && keyCode == CONTROL)) {
    ctrl_pressed = true;
    mov.play();
  }
}

void keyReleased() {
  if (key == ' ' || (key == CODED && keyCode ==  CONTROL)) {
    ctrl_pressed = false;
    mov.jump(current_time);
    mov.pause();
  }
  if (edit_name_mode) {
    if(key == ENTER) {
      edit_name_mode = false;
    } else if(key == BACKSPACE) {
      String n = annotations.get(current_track).name;
      if(n.length() > 0) {
        annotations.get(current_track).name = n.substring(0, n.length()-1);
      }
    } else {
      annotations.get(current_track).name += key;
    }
    
    return;
  }
  if (key== 'a' || key=='A') {
    Annotation a = new Annotation();
    a.name = "new";
    annotations.add(a);
  }
  if (key== 'e' || key=='E') {
    int i = mouseY / 20;
    if(i >= 0 && i < annotations.size()) {
      edit_name_mode = true;
      current_track = i;
    }
  }
  
  if (key== 's' || key=='S') {
    saveAnnotations();
  }
  // Delete timeslot under currently under the mouse
  if (key== 'd' || key=='D') {
    int i = mouseY / 20;
    if(i < 0 || i >= annotations.size()) {
      return;
    }
    ArrayList<Timeslot> timeslots = annotations.get(i).timeslots;
    for(int j = timeslots.size()-1; j>=0; j--) {
      Timeslot t = timeslots.get(j);
      //float mouseT = float(mouseX) * mov.duration() / float(width);
      if(t.start <= current_time && t.end >= current_time) {
        timeslots.remove(j);
      }
    }
  }
}



void mousePressed() {
  // test if we hit the time slider buttons
  if(mouseY > height-20) {
    int x_in  = int(in_point  * float(width));
    int x_out = int(out_point * float(width));
    if(mouseX >= x_in && mouseX <= x_in+20) {
      edit_timeline_mode = 1;
      in_point = float(mouseX) / float(width);
    }
    if(mouseX >= x_out-20 && mouseX <= x_out) {
      edit_timeline_mode = 2;
      out_point = float(mouseX) / float(width);
    }
  }
  // else: creating/editing time slots
  int i = mouseY / 20;
  if(i < 0 || i >= annotations.size()) {
    return;
  }  
  current_track = i;
  // if there is a timeslot at the current position: I start editing it
  Annotation a = annotations.get(current_track);
  //float mouseT = float(mouseX) * mov.duration() / float(width);
  for(Timeslot t : a.timeslots) {
    if(t.start <= current_time && t.end >= current_time) {
      edit_slot = t;
      if(current_time-t.start < t.end-current_time) {
        t.start = current_time; // (((float)mouseX) / ((float)width)) * ((float)mov.duration());
        edit_slot_mode = 1;
      } else {
        t.end =  current_time; // (((float)mouseX) / ((float)width)) * ((float)mov.duration());
        edit_slot_mode = 2;
      }
      return;
    }
  }
  // else: create with this as start time, edit slot end time
  edit_slot = new Timeslot();
  edit_slot.start = current_time; // (((float)mouseX) / ((float)width)) * ((float)mov.duration());
  edit_slot.end   = edit_slot.start;
  a.timeslots.add(edit_slot);
  edit_slot_mode = 2;
}

void mouseDragged() {
  if(edit_timeline_mode == 1) {
    in_point = float(mouseX) / float(width);
    if(in_point < 0) {
      in_point = 0;
    }
    if(in_point >= out_point) {
      in_point = out_point - 0.01;
    }
    return;
  }
  if(edit_timeline_mode == 2) {
    out_point = float(mouseX) / float(width);
    if(out_point > 1) {
      out_point = 1;
    }
    if(out_point <= in_point) {
      out_point = in_point + 0.01;
    }
    return;
  }
  
  if(edit_slot_mode == 0 || edit_slot==null) {
    return;
  }
  if(edit_slot_mode == 1) {
    edit_slot.start = current_time; // (((float)mouseX) / ((float)width)) * ((float)mov.duration());
    return;
  }
  if(edit_slot_mode == 2) {
    edit_slot.end = current_time; // (((float)mouseX) / ((float)width)) * ((float)mov.duration());
    return;
  }
}

void mouseReleased() {
  if(edit_timeline_mode != 0) {
    edit_timeline_mode = 0;
    return;
  }
  if(edit_slot_mode != 0) {
    if(edit_slot != null && edit_slot.start > edit_slot.end) {
      float swap      = edit_slot.start;
      edit_slot.start = edit_slot.end;
      edit_slot.end   = swap;
    }
    edit_slot_mode = 0;
    edit_slot = null;
  }
}