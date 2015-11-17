# VideoAnalyzer

VideoAnalyzer is a simple tool written in Processing to make manual time/frequency analysis of videos easier.

Did you ever have to record specific events or time frames in a video?
Something that can't be done automatically, like specific actions taken by the people in the video?
VideoAnalyzer was written to make this work easier: just drag the mouse over the video to mark each occurance.
Especially useful for researches who have to analyze video recordings of experiments.

It requires Processing3 to work (https://www.processing.org/)


Features:
- Minimalistic fast GUI.
- Unlimited number of simultaneous events.
- Saving and loading of time-frequency analysis files (ASCII).
- Autosave functionality.


How to use:
- Open the VideoAnalyzer.pde in Processing. Edit the "path" variable to point to the video you want to analyze.
- Move your mouse left-to-right over the video for scrubbing.
- Press [SPACE] to temporarily resume playback.
- The bar at the bottom allows zooming in on a specific time frame.
- Press [A] to create a new track for annotations
- Press [E] to edit the name of the annotation track under the mouse (enter finalizes input)
- Drag with the left mouse button in an annotation track to create new occurances (time boxes).
- Drag within an occurance (box) to edit the start or end time.
- Right click on an occurance to delete it.
- Press [S] to save the current analysis to the same folder as the video file.
  The filename will be the same as the video file, appended with a ".log".
- An autosave file will automatically be generated in the same folder as well.



