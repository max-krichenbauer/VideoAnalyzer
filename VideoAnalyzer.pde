
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


//                                                                              ____________________
//_____________________________________________________________________________/     setup()
void setup()
{
  size(1900, 1000); // displayWidth, displayHeight); // mov.width/2, mov.height/2);
  if (surface != null) {
    surface.setResizable(true);
  }
  frameRate(30); // mov.frameRate());
  
  mov = new Movie(this, path);
  mov.play();
  mov.pause();
  mov.speed(1);
  mov.volume(0);
  loadAnnotations(path);
}

//                                                                              ____________________
//_____________________________________________________________________________/  movieEvent()
void movieEvent(Movie m)
{
  m.read();
}


//                                                                              ____________________
//_____________________________________________________________________________/    draw()
void draw()
{
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
    stroke(#FFFFFF, 127);
    line(0, (i+1)*20+1, width, (i+1)*20+1);
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
    textSize(20);
    for(int x = 5; x < width; x+= 500) {
      fill(#FFFFFF, 127);
      text(annotation.name, x+2, (i+1)*20-2 + 2);
      if(edit_name_mode && current_track == i) {
        fill(#FFFF00);
      } else {
        fill(0);
      }
      text(annotation.name, x, (i+1)*20-2);
    }
    
    i++;
  }
}