// a version of TraingleZoom done using scale

import peasy.*;

int TREFS = 8; // number of trefoils, must be even
int MAX_FACTOR = 256; // 2 ^ TREFS. should be big enough to fill screen
float MIN_FACTOR = .01;
int index = 0;
boolean useTexture = true;
boolean video = false;

PeasyCam cam;

ArrayList<Tref> trefs = new ArrayList<Tref>();
PImage[] img = new PImage[7];

void setup() {
  size(640, 360, OPENGL);
  cam = new PeasyCam(this, 500);
  for (int i = 0 ; i < img.length ; i++) {
    img[i] = loadImage("pattern" + i + ".png");
  }
  float scale = MAX_FACTOR;
  float rot = 0;
  while (scale > MIN_FACTOR)  {
    println(scale);
    trefs.add(new Tref(scale, rot));
    scale /= 2;
    rot += PI;
  }
  println(trefs.size());
}

boolean debug;
void draw() {
  background(0);
  //camera(0, 0, 0, 0, 0, -1000, 0, 1, 0);
  //frustum(-width / 2, width / 2, -height / 2, height / 2, 0, -2000);
  //perspective(HALF_PI, (float)width / (float)height, 0, 2000);
  //float cameraZ = ((height / 2.0) / tan(PI * 60.0 / 360.0));
  //perspective(radians(60), (float)width / (float)height, cameraZ / 10.0, cameraZ * 30.0);
  if (keyPressed && key == 's') {
    debug = true;
  }
  for (Tref tref : trefs) {
    tref.draw(debug);
  }
  // if the smallest is too small, remove it and add another
  Tref tail = trefs.get(trefs.size() - 1);
  if (tail.factor < MIN_FACTOR) {
    // remove the tail
    trefs.remove(trefs.size() - 1);
    // add a bigger head
    Tref head = trefs.get(0);
    trefs.add(0, new Tref(head.factor * 2, head.rot + PI));
  }
  debug = false;
  
  if (video) {
    saveFrame("frame#####.png");
    if (frameCount > 500) {
      exit();
    }
  }
}

PShape shape;
float SZ = 20;
float C000 = SZ * cos(radians(0));
float S000 = SZ * sin(radians(0));
float C120 = SZ * cos(radians(120));
float S120 = SZ * sin(radians(120));
float C240 = SZ * cos(radians(240));
float S240 = SZ * sin(radians(240));
float TC000 = .5 + .5 * cos(radians(0));
float TS000 = .5 + .5 * sin(radians(0));
float TC120 = .5 + .5 * cos(radians(120));
float TS120 = .5 + .5 * sin(radians(120));
float TC240 = .5 + .5 * cos(radians(240));
float TS240 = .5 + .5 * sin(radians(240));

class Tref {
  float SPEED = .975;
  float MAX_ROT_SPEED = .03;
  public float factor;
  public float rot = 0.0;
  float rotSpeed = TWO_PI / 200;
  float rotAcc = random(-.002, .002);
  int tex;
  
  Tref(float factor, float rot) {
    this.factor = factor;
    this.rot = rot;
    if (useTexture) {
      tex = (int)random(img.length); 
    } else {
      tex = color(random(128, 256), random(128, 256), random(128, 256));
    }
    //println("Tex: " + tex);
    // shape is a psuedo-singleton
    if (shape == null) {
      shape = createShape();
      shape.beginShape(TRIANGLES);
      shape.noStroke();
      shape.textureMode(NORMAL);
      
      shape.vertex(C000 + C000, S000 + S000, TC000, TS000);
      shape.vertex(C000 + C120, S000 + S120, TC120, TS120);
      shape.vertex(C000 + C240, S000 + S240, TC240, TS240);

      shape.vertex(C120 + C000, S120 + S000, TC240, TS240);
      shape.vertex(C120 + C120, S120 + S120, TC000, TS000);
      shape.vertex(C120 + C240, S120 + S240, TC120, TS120);
      
      shape.vertex(C240 + C000, S240 + S000, TC120, TS120);
      shape.vertex(C240 + C120, S240 + S120, TC240, TS240);
      shape.vertex(C240 + C240, S240 + S240, TC000, TS000);
      
      shape.endShape();
    }
  }
  
  void draw(boolean debug) {
    // move and rotate
    if (debug) {
      println("factor:" + factor);
    }
    factor *= SPEED;
    rot += rotSpeed;
    rotSpeed += rotAcc;
    if (abs(rotSpeed) > MAX_ROT_SPEED ) {
      rotAcc = random(-.002, .002);
    }
    pushMatrix();
    scale(factor);
    rotateZ(rot);
    if (useTexture) {
      shape.setTexture(img[tex]);
    } else {
      shape.setFill(tex);
    }
    shape(shape);
    popMatrix();
  }
}

void keyPressed() {
  saveFrame("frame####.png");
}