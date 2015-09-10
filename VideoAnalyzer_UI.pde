
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