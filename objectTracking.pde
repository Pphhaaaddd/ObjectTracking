// Author : Suhail Ahamed
// Sept 2017

import processing.video.*;
Capture video;

int objectCounter=0;
PImage prevFrame;
ArrayList<Object> objects = new ArrayList<Object>();

// Threshold to differenciate bg/fg
float colorThreshold = 200;

// Threshold to find if new fg points are close enough
float distThreshold=30;

// Threshold to find if new fg points are too far
float maxDistThreshold=300;

//to check if first frame has been set to background
boolean doneOnce = false;

void setup() {
  size(640, 480, P2D);
  video = new Capture(this, width, height, 30);
  video.start();
  prevFrame = createImage(video.width, video.height, RGB);
}

void captureEvent(Capture video) {
  if (!doneOnce) {
    prevFrame.copy(video, 0, 0, video.width, video.height, 0, 0, video.width, video.height); 
    prevFrame.updatePixels(); 
    doneOnce = true;
  }
  video.read();
}

void draw() {
  ArrayList<Object> currentObjects = new ArrayList<Object>();
  loadPixels();
  video.loadPixels();
  prevFrame.loadPixels();
  currentObjects.clear();

  for (int x = width/2, i=-1, j=-1; x < video.width && x>=0; x+=i, i*=-1, i+=j, j*=-1) {
    for (int y = height/2, k=-1, l=-1; y < video.height && y>=0; y+=k, k*=-1, k+=l, l*=-1) {

      int loc = x + y*video.width;            
      color current = video.pixels[loc];      
      color previous = prevFrame.pixels[loc]; 

      float r1 = red(current); 
      float g1 = green(current);
      float b1 = blue(current);

      float r2 = red(previous); 
      float g2 = green(previous);
      float b2 = blue(previous);

      float diff = sqDist(r1, g1, b1, r2, g2, b2);

      if (diff > colorThreshold*colorThreshold) {
        boolean found=false;
        for (Object o : currentObjects) {
          if (o.isNear(x, y)) {
            o.add(x, y);
            found = true;
            break;
          }
        }
        if (!found) {
          Object o = new Object(x, y);
          currentObjects.add(o);
        }
      }
      pixels[loc] = video.pixels[loc];
    }
  }

  updatePixels();

  //Removeing small objects
  for (int i= currentObjects.size()-1; i>=0; i--) {
    if (currentObjects.get(i).size() < 600) 
      currentObjects.remove(i);
  }

  //MATCH currentObjects with objects

  if (objects.isEmpty() && currentObjects.size() > 0) // there are no objects 
    for (Object o : currentObjects) {
      println("Adding");
      o.id = objectCounter;
      objectCounter++;
      objects.add(o);
    } else if (currentObjects.size() == objects.size() ) {
    for (Object o : objects) {
      float minD = 100000;
      Object matched=new Object(0,0);
      for (Object co : currentObjects) {
        float d = (o.x - co.x)*(o.x - co.x) + (o.y - co.y)*(o.y - co.y);
        if ( d < minD*minD ) {
          minD = d;
          matched.become(co);
        }
      }
      o.become(matched);
    }
  }

  for (int i= objects.size()-1; i>=0; i--)
    objects.get(i).display(i);

  fill(0);
  textAlign(RIGHT);
  textSize(24);
  text("Fg/bg threshold: " + colorThreshold, width-30, 40);
  text("Distance threshold: " + distThreshold, width-30, 20);
  
  text("currentObjects: " + currentObjects.size(), width-30, height-40);
  //text("objects: " + objects.size(), width-30, height-20);
}

// "Distance squared" between two points/colors
float sqDist(float x1, float y1, float z1, float x2, float y2, float z2) {
  float xDist = x1-x2;
  float yDist = y1-y2;
  float zDist = z1-z2;
  float dist = xDist*xDist +yDist*yDist +zDist*zDist; 
  return dist;
}
float sqDist(float x1, float y1, float x2, float y2) {
  float xDist = x1-x2;
  float yDist = y1-y2;
  float dist = xDist*xDist +yDist*yDist; 
  return dist;
}

//Update background when mousePressed
void mousePressed() {
  prevFrame.copy(video, 0, 0, video.width, video.height, 0, 0, video.width, video.height); 
  prevFrame.updatePixels();
}

//Change thresholds for color/objects
void keyPressed() {
  if (key=='s') 
    distThreshold+=4;
  if (key=='x') 
    distThreshold-=4;

  if (key=='a') 
    colorThreshold+=4;
  if (key=='z') 
    colorThreshold-=4;
  println(distThreshold);
  println(colorThreshold);
}