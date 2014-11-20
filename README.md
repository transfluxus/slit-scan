slit-scan
=========

[Science Hack Day Berlin](http:///berlin.sciencehackday.org) modified Real-Time Slit-Scan Program for [ STATE Experience Science Festival](http://www.statefestival.org/)  2014

**Processing sketch**

Based ont Simple Real-Time Slit-Scan Program.
by Golan Levin, December 2006.

modified by @ramin__, @mingness  Science Hack Day 2014

**SETUP**    
 Select the right camera!
 The CAMERA variable is the index of the selected cameras.
 set it to and index with a resoulution of 640x480 and highest possible framerate
 All Cameras are printed out, so you can look the right one up at the first start
 
 **MANUAL**   
 There are four directions to choose from. 
 For both axis the horizontal and vertical are two different modes: Scanning and Slicing
 
 The red frame indicates that saving is activated.
 That means when the green bar reaches the end of the screen a picture is taken.
 No picture gets lost (even after program restart)
 1. > (left to right) Scanning
 2. < (right to left) Slicing
 3. \/ (top down) Scanning
 4. /\ (bottom up) Slicing
 
_Slicing_ always takes the same CENTER line from the videoimage and copies that to the green bar location   
_Scanning_ takes the part of the camera image where the green bar is and copies that to the green location on the screen
