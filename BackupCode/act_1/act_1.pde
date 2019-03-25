// all the imports
import processing.serial.*;

//-----------------------------
//----- V A R I A B L E S -----
//-----------------------------
//The port for Serial input
Serial arduino_port;
//windowWidth and windowHeight
final int W_WIDTH = 1920;
final int W_HEIGTH = 1080;
//connection timeout, in millis. Used to check whether the current port is correct or not
final int CONNECTION_TIMEOUT = 1000;
//The KalmalFiler. Used to process the signal from ultrasonic sensor even further
KalmanFilter kf = new KalmanFilter();
//The current backgrond image
PImage cur_bgr, act1_bgr, act2_bgr, act3_bgr;
//The main font
PFont main_font;

//-----------------------------
//--------  S E T U P  --------
//-----------------------------

void settings() {
  //set size of the screen
  size(W_WIDTH, W_HEIGTH);
  //set the pixel density. Used for high density display such as Macs
  pixelDensity(displayDensity());
  //make fullscreen to get rid of the border
  fullScreen();
}


void setup() {
  //set the image mode to center, meaning images will located with center
  imageMode(CENTER);
  // Smooth things out 
  smooth();
  //load all the background images and actors first
  act1_bgr = loadImage("act_1.jpg");
  //then, load the font 
  //main_font = createFont();
  auto_select_port();
}


void draw() {
  float distance = getSensorValue();
  //if something goes wrong, do nothing
  if (distance == -1 || Float.isNaN(distance)) return;
  distance = kf.predict_and_correct(distance);
  println(nf(distance, 0, 1));
}


int d;
Boolean show_wave = true;
int wWidth, wHeight, r = 1;
float lastR;
int lineNum = 5;
int spacing = 100;


float source_x;
float source_y;
float target_x;
float target_y;
float moving_x;




//void setup() {
//  source_x = wWidth * 7 / 20;
//  source_y = wHeight * 10/ 17;
//  target_x = wWidth;
//  target_y = source_y;
//  moving_x = source_x;
//  lastR = 1280;
//  background(255);
//img = loadImage("act_1.jpg");
//background(img,10);
//  smooth();
//  d = 20;

//}

//void draw() {
//  float d = getSensorValue();
//  if (d == -1 || Float.isNaN(d)) return;
//  d = kf.predict_and_correct(d);
//  println(nf(d, 0, 1));

////draw the wave
//background(img);
//textSize(70);
//text(d, wWidth / 8 - 40, wHeight / 4);
//r = r + 12;
//for (int i = 1; i <= lineNum; i++) {
//  stroke(#E3E2E4);
//  strokeWeight(2);
//  if (show_wave) {
//    noFill();
//    float r2 = (r + spacing * i) % lastR;
//    arc(source_x, source_y, r2, r2/2, -PI / 10, PI/10);
//  }
//}
////draw the graph
//while (myPort.available() > 0) {
//  distance = myPort.readStringUntil('\n');
//  println(distance);
//  if (distance != null) {
//    //    //get the distance
//    d = int(distance.trim());
//  }
//}
//}
