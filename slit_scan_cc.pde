// Based ont Simple Real-Time Slit-Scan Program.
// by Golan Levin, December 2006.

// modified by @ramin__, @mingness  Science Hack Day 2014
/*
SETUP: 
 Select the right camera!
 The CAMERA variable is the index of the selected cameras.
 set it to and index with a resoulution of 640x480 and highest possible framerate
 All Cameras are printed out, so you can look the right one up at the first start
 MANUAL:
 There are four directions to choose from. 
 For both axis the horizontal and vertical are two different modes: Scanning and Slicing
 
 The red frame indicates that saving is activated.
 That means when the green bar reaches the end of the screen a picture is taken.
 No picture gets lost (even after program restart)
 1. -> (left to right) Scanning
 2. <- (right to left) Slicing
 3. \/ (top down) Scanning
 4. /\ (bottom up) Slicing
Slicing always takes the same CENTER line from the videoimage and copies that to the green bar location   
Scanning takes the part of the camera image where the green bar is and copies that to the green location on the screen
 */
int CAMERA = 5;

import processing.video.*;
Capture myVideo;

// two screens: direction select and slicer
final int DIR_SELECT = 0, SLICER = 1;
int screen = DIR_SELECT;
// pause during slicer
boolean pause = false;
PGraphics pg;

int video_width     = 640;
int video_height    = 480;
int video_slice_x   = video_width/2;
int video_slice_y   = video_height/2;
int window_width    = video_width;
int window_height   = video_height;

// general draw position
int draw_position; 
boolean b_newFrame  = false;  // fresh-frame flag

// all possible directions
final int LEFT_RIGHT = 0;
final int RIGHT_LEFT = 1;
final int TOP_DOWN = 2;
final int BOTTOM_UP = 3;
// actuall direction
int dir= RIGHT_LEFT;

// direction button images
PImage[] dirButton = new PImage[4];
// button size
int buttonSize = 60;
// button positions
PVector[] buttonPos = new PVector[4];

// message text
PVector textPos;
PFont message;
int fontsize=18;

// index of the next imaged saved
int nextImgIndex=-1;

// for indicating when save is pressed
boolean imageSaveIndicator= false;
// timer for that

//--------------------------------------------
void setup() {
  size(window_width, window_height);
  pg = createGraphics(window_width, window_height);

  String[] cameras = Capture.list();
  if (cameras.length == 0) {
    println("There are no cameras available for capture.");
    exit();
  } else {
    println("Available cameras:");
    for (int i = 0; i < cameras.length; i++) {
      println(i+": "+cameras[i]);
    }
  }
  myVideo = new Capture(this, cameras[CAMERA]);
  myVideo.start();
  background(0, 0, 0);

  // load font
  message = loadFont("font.vlw");
  textAlign(CENTER, CENTER);
  textPos = new PVector(width/2, height-fontsize);
  textFont(message, fontsize);
  // buttonstuff: loading image, setting position
  for (int i=0; i < 4; i++)
    dirButton[i] = loadImage(i+".png");
  buttonPos[0] = new PVector(width*.25f, height*.5f);
  buttonPos[1] = new PVector(width*.75f, height*.5f);
  buttonPos[2] = new PVector(width/2, height*.25f);
  buttonPos[3] = new PVector(width/2, height*.75f);

  // get the next file index: this makes sure, that if the program is restarted, 
  // that the old files are not deleted 
  File nextIndexF;
  do 
    nextIndexF = new File(sketchPath+"/imgs/"+(++nextImgIndex)+".png");
  while (nextIndexF.exists ());

  // for the imagesave indicator 
  noFill();
  strokeWeight(3);
}

//--------------------------------------------
public void captureEvent(Capture c) {
  c.read();
  b_newFrame = true;
}

//--------------------------------------------
void draw() {
  // direction selection screen
  if (screen == DIR_SELECT) {
    background(0);
    imageMode(CENTER);
    // display buttons
    for (int i=0; i <4; i++)
      image(dirButton[i], buttonPos[i].x, buttonPos[i].y, buttonSize, buttonSize);
    imageMode(CORNER);
    text("Press D to return to main menu, Space to pause, S to save image, C to clear", textPos.x, textPos.y);
  } else { //if (screen == SLICER)  
    if (pause)
      return;
    if (b_newFrame) {
      copySlice();
      b_newFrame = false; 
      image(pg, 0, 0);
      drawPositionIndicator();
    }
    // show red border, whenn image is saved (for 1 second)
    if (imageSaveIndicator) {
      stroke(255, 0, 0);
      rect(1, 1, width-3, height-3);
      if ((dir == LEFT_RIGHT && draw_position == 0) 
        || (dir == RIGHT_LEFT && draw_position ==  width-1)
        || (dir == TOP_DOWN && draw_position == 0) 
        || (dir == BOTTOM_UP && draw_position ==  height-1)) {
        pg.save("/imgs/"+nextImgIndex+".png");
        println("Image saved: "+(nextImgIndex++));
      }
    }
  }
}

void copySlice() {
  pg.beginDraw();
  pg.loadPixels();
  switch (dir) {
  case LEFT_RIGHT: 
    verticalScan();
    draw_position = (draw_position + 1) % (window_width);
    break;
  case RIGHT_LEFT: 
    verticalSlice();
    draw_position = (draw_position + window_width - 1 ) % (window_width);
    break;
  case TOP_DOWN: 
    horizontalScan();
    draw_position = (draw_position + 1 ) % (window_height);
    break;
  case BOTTOM_UP: 
    horizontalSlice();
    draw_position = (draw_position  + window_height - 1) % (window_height);
    break;
  }
  pg.updatePixels();
  pg.endDraw();
}

void drawPositionIndicator() {
  switch (dir) {
  case LEFT_RIGHT: 
  case RIGHT_LEFT: 
    stroke(0, 255, 0);
    line(draw_position, 0, draw_position, height);
    break;
  case TOP_DOWN: 
  case BOTTOM_UP:  
    stroke(0, 255, 0);
    line(0, draw_position, width, draw_position);
    break;
  }
}

void verticalScan() {
  for (int y=0; y<window_height; y++) {
    int setPixelIndex = y*window_width + draw_position;
    int getPixelIndex = y*video_width  + (window_width - draw_position - 1);
    pg.pixels[setPixelIndex] = myVideo.pixels[getPixelIndex];
  }
}

void verticalSlice() {
  for (int y=0; y<window_height; y++) {
    int setPixelIndex = y*window_width + draw_position;
    int getPixelIndex = y*video_width  + video_slice_x;
    pg.pixels[setPixelIndex] = myVideo.pixels[getPixelIndex];
  }
}

void horizontalSlice() {
  for (int x=0; x<window_width; x++) {
    int setPixelIndex = draw_position * window_width + x;
    int getPixelIndex = video_slice_y * video_width  + (window_width - x - 1);
    pg.pixels[setPixelIndex] = myVideo.pixels[getPixelIndex];
  }
}


void horizontalScan() {
  for (int x=0; x<window_width; x++) {
    int setPixelIndex = draw_position * window_width + x;
    int getPixelIndex = draw_position * video_width  + (window_width - x - 1);
    pg.pixels[setPixelIndex] = myVideo.pixels[getPixelIndex];
  }
}

public void mousePressed() {
  // check if button is pressed
  if (screen == DIR_SELECT) {
    // check all buttons, if they are pressed 
    for (int i=0; i<4; i++) {
      if (mouseX > buttonPos[i].x-buttonSize/2 &&
        mouseX < buttonPos[i].x+buttonSize/2 &&
        mouseY > buttonPos[i].y-buttonSize/2 &&
        mouseY < buttonPos[i].y+buttonSize/2) {
        //println(i);
        dir =i;
        screen = SLICER;
        background(0);
        clearPG();
        return;
      }
    }
  }
}

void setStartPos() {
  // set start position
  if (dir == RIGHT_LEFT)
    draw_position = window_width - 1;
  else if (dir== LEFT_RIGHT)
    draw_position =0;
  else if (dir== TOP_DOWN)
    draw_position =0;
  else
    draw_position =window_height - 1;
}

void keyPressed() {
  if (screen == SLICER)
    // space for pause
    if (key==' ')
      pause = !pause;
  // s to save   
    else if (key=='s') 
      imageSaveIndicator=!imageSaveIndicator;
  // c to clear screen
    else if (key=='c') 
      clearPG();
  // d to get back to direction selection screen  
    else if (key=='d') 
      screen =  DIR_SELECT;
}


void clearPG() {
  pg.beginDraw();
  pg.background(0);
  pg.endDraw(); 
  setStartPos();
}

