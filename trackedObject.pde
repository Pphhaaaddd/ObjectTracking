class Object {
  float minx, miny, maxx, maxy; //points of the rectangle
  float x, y; // center of the Object
  int lifespan=100, id=0;
  ArrayList<PVector> locs; // list of points in the object

  boolean taken = false;

  Object(float x1, float y1) {
    locs = new ArrayList<PVector>();
    locs.add(new PVector(x1, y1));
    minx = x1;
    miny = y1;
    maxx = x1; 
    maxy = y1;
    x = x1;
    y = y1;
  }

  boolean isNear(float x1, float y1) {
    for (PVector l : locs) {
      float d = sqDist(x1, y1, l.x, l.y);
      if (d<distThreshold*distThreshold)
        return true;
    }    
    return false;
  }

  boolean isFar(float x1, float y1) {
    float d = sqDist(x1, y1, x, y);
    if (d>maxDistThreshold*maxDistThreshold)
      return true;
    return false;
  }

  //Add a new point
  void add(float x1, float y1) {
    minx = min(minx, x1);
    miny = min(miny, y1);
    maxx = max(maxx, x1);
    maxy = max(maxy, y1);
    locs.add(new PVector(x1, y1));
    x=(minx+maxx)/2; 
    y=(miny+maxy)/2;
  }

  void display(int i) {

    for (PVector l : locs) {
      stroke(0, 255, 0);
      point(l.x, l.y);
    }
    textAlign(CENTER);
    textSize(16);
    fill(255);
    text(id, x, y);
    fill(0, 30);
    stroke(255, 0, 0);
    strokeWeight(2);
    ellipse( (minx+maxx)/2, (miny+maxy)/2, (maxx-minx)/1.05, (maxy-miny)/1.05);
  }

  float size() {
    return locs.size();
  }

  PVector getCenter() {
    return new PVector(x, y);
  }

  //Copy one Object to wnother
  void become(Object other) {
    minx = other.minx;
    maxx = other.maxx;
    miny = other.miny;
    maxy = other.maxy;

    x = other.x;
    y = other.y;
  
    taken = other.taken;
    //id = other.id;
    locs = other.locs;
  }
}