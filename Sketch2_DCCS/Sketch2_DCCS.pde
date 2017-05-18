import processing.video.*;

Movie dino;
Capture cam;
PImage maskingImage, progImage, bgImage, difference;        //, cam;
color [] chromaKeyColors;
boolean colourCorrecting = false;

void setup() {
  size(1280, 720);
  frameRate(2);
  cam = new Capture(this, width, height);
  cam.start();
  //cam = loadImage("phone_girl.0001.png"); 
  //cam = new Movie(this,"Tracking-Field.mp4");
  //cam.loop();
  dino = new Movie(this,"TRex.mp4");
  dino.loop();
  
  maskingImage = createImage(width, height, RGB);
  bgImage = createImage(width, height, RGB);
  progImage = createImage(width, height, RGB);

  chromaKeyColors = new color[0];
}

void draw() {
  if (cam.available()) {
    cam.read();
  }
  if (dino.available()){
    dino.read();
  }
  difference = createImage(width, height, RGB);
  
  if (colourCorrecting) {
     applyScalingsFromTo(cam, dino);
     updateDifference(cam, progImage);
  }
  
    image(difference, cam.width, cam.height);
    image(dino, 0, 0);
    updateMaskImage();
    applyMaskImage();
    colourCorrecting = true;
    
    image(cam, 0, 0);
    image(progImage, 0, 0);
}

void updateMaskImage() {
  maskingImage.set(0, 0, dino);

  maskingImage.blend(bgImage, 0, 0, dino.width, dino.height, 
                              0, 0, dino.width, dino.height, 
                  DIFFERENCE);
                  
  maskingImage.filter(GRAY);
  maskingImage.filter(THRESHOLD, 0);
  maskingImage.filter(ERODE);
  maskingImage.filter(DILATE);

  color c = get(0, 0);
  chromaKeyColors = append(chromaKeyColors, c);
  makeTransparent(c);
}

void applyMaskImage() {
  progImage.set(0, 0, dino);
  progImage.mask(maskingImage);
}



void makeTransparent(color c) {
  for (int y = 0; y < height; y+= 1) {
    for (int x = 0; x < width; x+=1) {
      color pc = get(x, y);
      
      if (similar(pc,c)) {
        maskingImage.set(x, y, color(0, 0, 0, 0));
      }
    }
  }
}

boolean similar(color c, color r) {
  final int CLOSECOLOR = 120;
  boolean match = dist(red(c), green(c), blue(c), red(r), green(r), blue(r)) < CLOSECOLOR;
  
  return match;
}

void updateDifference(PImage s, PImage t) {
  difference.set(0, 0, s);
  difference.blend(t, 0, 0, s.width, s.height,
                      0, 0, s.width, s.height,
                      DIFFERENCE);
                      
  difference.filter(THRESHOLD, 0);
}