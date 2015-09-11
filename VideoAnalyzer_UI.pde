
int last_autosave = 0; // when was the last auto-save (in ms since program start)

int mouseX_offset = 0; // interaction offset (mouse pointer to pivot etc)
int mouseY_offset = 0; // interaction offset (mouse pointer to pivot etc)


//                                                                                  ________________
//_________________________________________________________________________________/  keyPressed()
void keyPressed()
{
  if (key == ' ' || (key ==  CODED && keyCode == CONTROL)) {
    ctrl_pressed = true;
    mov.play();
  }
}

//                                                                                  ________________
//_________________________________________________________________________________/ keyReleased()
void keyReleased()
{
  // [SPACE] or [CTRL]
  // Playback
  if (key == ' ' || (key == CODED && keyCode ==  CONTROL)) {
    ctrl_pressed = false;
    mov.jump(current_time);
    mov.pause();
  }
  
  // When currently editing the track name: normal typing input
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
  
  // [A] Key:
  // Create new annotation track.
  if (key== 'a' || key=='A') {
    Annotation a = new Annotation();
    a.name = "new";
    annotations.add(a);
  }
  
  // [E] Key:
  // Edit current track name.
  if (key== 'e' || key=='E') {
    int i = mouseY / 20;
    if(i >= 0 && i < annotations.size()) {
      edit_name_mode = true;
      current_track = i;
    }
  }
  
  // [S] KEY:
  // Safe annotations
  if (key== 's' || key=='S') {
    makeBackup();
    saveAnnotations(path);
  }
  
  // [D] KEY:
  // Delete the timeslot currently under the mouse
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


//                                                                                  ________________
//_________________________________________________________________________________/ mousePressed()
void mousePressed()
{
  if(mouseButton == RIGHT) {
    return; // nothing to do for right mouse button press
  }
  // test if we hit the time slider buttons
  if(mouseY > height-20) {
    int x_in  = int(in_point  * float(width));
    int x_out = int(out_point * float(width));
    if(mouseX > x_out || mouseX < x_in) {
      return; // outside of time slider
    }
    if(mouseX <= x_in+20) { // in-handle
      edit_timeline_mode = 1;
      in_point = float(mouseX) / float(width);
      return;
    }
    if(mouseX >= x_out-20) { // out-handle
      edit_timeline_mode = 2;
      out_point = float(mouseX) / float(width);
      return;
    } // else: handle middle
    edit_timeline_mode = 3;
    mouseX_offset = mouseX;
    return; // since we're in the lower line, we don't need to check of other interaction
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


//                                                                                  ________________
//_________________________________________________________________________________/ mouseDragged()
void mouseDragged()
{
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
  if(edit_timeline_mode == 3) {
    float delta = float(mouseX - mouseX_offset) / float(width);
    if(delta > 0 && out_point+delta > 1.0) {
      delta = 1.0-out_point;
    } else if (delta < 0 && in_point+delta < 0.0) {
      delta = -in_point;
    }
    in_point  = in_point + delta;
    out_point = out_point + delta;
    mouseX_offset = mouseX;
    return;
  }
  
  if(edit_slot_mode == 0 || edit_slot==null) {
    return;
  }
  if(edit_slot_mode == 1) {
    edit_slot.start = current_time;
    return;
  }
  if(edit_slot_mode == 2) {
    edit_slot.end = current_time;
    return;
  }
}

//                                                                                  ________________
//_________________________________________________________________________________/ mouseReleased()
void mouseReleased()
{
  // While we're apparently editing: check if its time to make an autosave
  int now = millis();
  if(now - last_autosave > 60000) {
    saveAnnotations(path+".autosave");
    last_autosave = now;
  }
  
  // 
  if(mouseButton == RIGHT) {
    // right mouse button click: delete timeslot if applicable
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
        return;
      }
    }
    return; // nothing else to do for right mouse button
  }
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