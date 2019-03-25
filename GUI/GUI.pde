// all the imports
import processing.serial.*;
import java.io.File;
import java.util.Queue;
import java.util.LinkedList; 
import java.util.Collections; 
import ddf.minim.spi.*;
import ddf.minim.signals.*;
import ddf.minim.*;
import ddf.minim.analysis.*;
import ddf.minim.ugens.*;
import ddf.minim.effects.*;
import processing.video.*;




//-----------------------------
//----- C O N S T A N T S -----
//-----------------------------
final color MAIN_BGR_COLOR = #2C7DC2;
final color SECONDARY_BGR_COLOR = #CBC7BB;
int MENU_ITEM_RADIUS;
int NAV_MENU_ITEM_RADIUS;

//-----------------------------
//----- V A R I A B L E S -----
//-----------------------------
//The port for Serial input
Serial arduino_port;
//The KalmalFiler. Used to process the signal from ultrasonic sensor even further
KalmanFilter kf = new KalmanFilter();
//The current backgrond image
PImage cur_bgr, act1_bgr, act2_bgr, act3_bgr;
//The main font
PFont lobster_font;
PFont din_font;

// the thread that plays the sounds...
MyThread sonar;
// the delay between the beeps. Changed according to the distance
int delay_between_beeps = 100;
int last_time_stamp = millis();
// if we want to play the sound
boolean play_sound = false;
// to play the movie
Movie intro_movie;


// The current Scene
Scene current_scene = Scene.LOAD;
// the action to perform when mouse is pressed
Action target_action;

// Setting up the scenes
LoadingScene load_scene;
MenuScene menu_scene;
MeasureScene measure_scene;
LearnScene learn_scene;
ApplyScene apply_scene;
PauseOverlay pause_overlay;

// when the program is paused
Boolean pausing = false;
// when on transition
Boolean transitioning = false;
Boolean transition_out = true;
// the number of transition frame. the higher the number, the longer the transition
int opacity_transition = 0;
float EASING = 0.1;


//-----------------------------
//--------  S E T U P  --------
//-----------------------------

void settings() {
  //make fullscreen to get rid of the border
  fullScreen(FX2D);
  // Smooth things out
  smooth();
  //set the pixel density. Used for high density display such as Macs
  pixelDensity(displayDensity());
}


void setup() {
  //set the image mode to center, meaning images will located with center
  imageMode(CENTER);
  //load the font 
  //"C:\Users\Khai Nguyen\Desktop\Prototype_Studio_Project\GUI\resources\fonts\Din.otf"
  lobster_font = createFont("resources/fonts/Lobster.otf", 100, true);
  din_font = createFont("resources/fonts/Din.otf", 100, true);
  //radius of menu item
  MENU_ITEM_RADIUS = height / 7;
  NAV_MENU_ITEM_RADIUS = height / 27;
  //initiate the various screens
  load_scene = new LoadingScene();
  menu_scene = new MenuScene();
  pause_overlay = new PauseOverlay();
  load_scene.render();
  // load the sound 
  // create the sound player
  Minim minim = new Minim(this);
  AudioPlayer player = minim.loadFile( "resources/apply/Sonar.wav" );
  // create the thread and start it.
  sonar = new MyThread( minim, player );
  sonar.start();
  intro_movie = new Movie(this, "vid.mp4");
}


//-----------------------------
//----  M A I  N L O O P  -----
//-----------------------------
void draw() {

  target_action = null;  
  // render the scene

  render();
  //the user pauses, then do nothing
  if (pausing) {
    // draw an overlay on top of it
    fill(122, 207, 237, 230);
    //fill(255,255,255,220);
    rect(0, 0, width, height);
    pause_overlay.render();
    return;
  }
  // if transitioning, render the transition
  if (transitioning) {
    if (transition_out) {
      fadeOutAnimation();
    } else {
      fadeInAnimation();
    }
    return;
  }
  //auto select the port. Only run for the first time
  if (arduino_port == null)   
  {
    auto_select_port();
  }
  //get the sensor value
  float distance = getSensorValue();
  //if something goes wrong, do nothing
  if (distance == -1 || Float.isNaN(distance)) return;
  distance = kf.predict_and_correct(distance);
  //perform a bunch of activity
  delay_between_beeps = (int)(distance * 100);
  delay_between_beeps = constrain(delay_between_beeps, 0, 1000);
  // play the sound first
  if (millis() - last_time_stamp > delay_between_beeps && play_sound) {
    last_time_stamp = millis();
    sonar.playNow();
  }
  if (current_scene == Scene.MEASURE) measure_scene.update_distance(distance);
  if (current_scene == Scene.APPLY) apply_scene.update_distance(distance);
}


/**
 * upon mouse released. Basiclly detect mouse interaction
 */
void mouseReleased() {
  if (target_action == null) return;
  // if pausng or unpausing, then just pause and dont reset anything
  if (target_action == Action.START && current_scene == Scene.APPLY && apply_scene != null) {
    apply_scene.start_game();
    return;
  }
  if (target_action == Action.PAUSE) {
    pausing = true;
    return;
  }
  if (target_action == Action.PLAY) {
    pausing = false;
    return;
  }
  pausing = false;
  // in any other cases, got to reset everything 
  opacity_transition = 0;
  transitioning = true;
  transition_out = true;
  // reset everything
  play_sound = false;
  intro_movie.stop();
  load_scene = null;
  menu_scene = null;
  learn_scene = null;
  measure_scene = null;
  //learn_scene = null;
  apply_scene = null;
  switch(target_action) {
  case HOME:
    current_scene = Scene.HOME;
    break;
  case LEARN:
    current_scene = Scene.LEARN;
    break;
  case MEASURE:
    current_scene = Scene.MEASURE;
    break;
  case APPLY:
    current_scene = Scene.APPLY;
    break;   
  case RELOAD:    
    break;
  default:
    println(target_action);
  }
}
