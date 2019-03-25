//
//  KalmanFilter.pde - Kalman Filter for Processing
//
//  see also:
//    http://www.scipy.org/Cookbook/KalmanFiltering
//
//  example:
//    KalmanFilter kf = new KalmanFilter();
//       .
//       .
//    void draw() {
//        // measurement value
//        float x = getSensorValue();
//
//        // a posteriori estimate of x
//        float xhat = kf.predict_and_correct(x)
//
//source https://gist.github.com/yoggy/2020928

//connection timeout, in millis. Used to check whether the current port is correct or not
final int CONNECTION_TIMEOUT = 1000;
//The number of required reading to conclude that the connection port is valid
final int NUM_REQUIRED_READINGS = 5;

class KalmanFilter {
  float q = 1.0;     // process variance
  float r = 2.0;     // estimate of measurement variance, change to see effect

  float xhat = 0.0;  // a posteriori estimate of x
  float xhatminus;   // a priori estimate of x
  float p = 1.0;     // a posteriori error estimate
  float pminus;      // a priori error estimate
  float kG = 0.0;    // kalman gain

  KalmanFilter() {
  };
  KalmanFilter(float q, float r) {
    q(q); 
    r(r);
  }

  void q(float q) {
    this.q = q;
  }

  void r(float r) {
    this.r = r;
  }

  float xhat() {
    return this.xhat;
  }

  void predict() {
    xhatminus = xhat;
    pminus = p + q;
  }

  float correct(float x) {
    kG = pminus / (pminus + r);
    xhat = xhatminus + kG * (x - xhatminus);
    p = (1 - kG) * pminus;

    return xhat;
  }

  float predict_and_correct(float x) {
    predict();
    return correct(x);
  }
}


/**
 * Get the raw sensor data and return it as an integeter
 * @return the distance to the object
 */

float getSensorValue() {
  if (arduino_port == null) return -1;
  if (arduino_port.available() <= 0) return -1;
  String distance = arduino_port.readStringUntil('\n');
  if (distance == null) return -1;
  //get the distance
  float numerical_distance = float(distance.trim());
  return numerical_distance;
}

/**
 * Automatically detect the right Arduino port
 * @return the correct arduino port
 */
void auto_select_port() {
  println("------------------------------");
  println("-- F I N D I N G  P O R T S --");
  println("------------------------------");
  println();
  String[] ports = Serial.list();
  // the ordinal number of port we have checked
  int port_count = 0;
  // The time to begin the countdown
  int start_time = millis();
  //count the number of valid instance returned from arduino
  int num_arduino_readings = 0;
  //The supposed number of valid read from Arduino until it is confirmed that the port is correct
  for (String port : ports) {
    //try to get a reading from the arduino to see if there is any connection
    print(" Try connectin to port " + port_count++ +  " : " + port + "  ===>  ");
    try {
      //connect to a port
      arduino_port = new Serial (this, port, 9600);
      //delay the program so that the arduino has sometimes to connect to the new port
      delay(1000);
      //begin the countdown
      start_time = millis();
      num_arduino_readings = 0;
      //test the connection for CONNECTION_TIMEOUT mls
      while (millis() - start_time < CONNECTION_TIMEOUT) {
        float distance = getSensorValue();
        render();
        //if something goes wrong, do nothing
        if (!Float.isNaN(distance) && distance != -1) {
          num_arduino_readings++;
          //if successfully read a number of readings, then it means this is the correct port and just return
          if (num_arduino_readings >= NUM_REQUIRED_READINGS) {
            current_scene = Scene.HOME;
            println(" PORT FOUND!");
            return;
          }
        }
      }
      println(" WRONG PORT!");
    }
    catch (Exception e) {
      println(" WRONG PORT!");
    }
  }
}

/**
 * Get the distance between two points (x1,y1), and (x2,y2)
 * @return the distance between two ponts
 */
int calc_distance(int x1, int y1, int x2, int y2) {
  return int(sqrt(sq(x1-x2)+sq(y1-y2)));
}

// This function returns all the files in a directory as an array of Strings  
String[] listFileNames(String dir) {
  String path = sketchPath();
  File file = new File(path, dir);
  if (file.isDirectory()) {
    String names[] = file.list();
    return names;
  } else {
    // If it's not a directory
    return null;
  }
}


/**
 * Load all sprites within a folder 
 * @return the array of sprites
 */

PImage[] load_sprites (String dir) {
  String[] filenames = listFileNames(dir);
  int num_sprite = filenames.length;
  PImage[] images = new PImage[num_sprite];
  // and load them into an array
  for (int i = 0; i < num_sprite; i++) {
    // Use nf() to number format 'i' into four digits
    images[i] = loadImage(dir + filenames[i]);
  }
  return images;
}

/**
 * A single class to store the reading
 */
class Reading { 
  float reading;
  int time_stamp;
  Reading(float r, int t) { 
    reading = r;
    time_stamp = t;
  }
} 

/**
 * fade out animation
 */
void fadeOutAnimation() {
  // draw an overlay on top of it
  if (opacity_transition >= 225) {
    transition_out = false;
    return;
  } else {     
    fill(25, 106, 179, opacity_transition);
    opacity_transition = opacity_transition +ceil((255-opacity_transition) * EASING);
    rect(0, 0, width, height);
  }
}
/**
 * Fade in animation
 */
void fadeInAnimation() {
  switch(current_scene) {
  case LOAD:
    if (load_scene == null) load_scene = new LoadingScene();
    break;
  case HOME:
    if (menu_scene == null)menu_scene = new MenuScene();
    break;
  case LEARN:
    if (learn_scene == null) learn_scene = new LearnScene();
    break;
  case MEASURE:
    if (measure_scene == null) measure_scene = new MeasureScene();
    break;
  case APPLY:
    if (apply_scene == null) apply_scene = new ApplyScene();
    break;
  default:
    menu_scene.render();
    break;
  }  
  if (opacity_transition <= 30) {
    transitioning = false;
    transition_out = true;
    return;
  } else { 
    opacity_transition = (int) (opacity_transition *EASING);
    fill(25, 106, 179, opacity_transition);
    rect(0, 0, width, height);
  }
}


/**
 * The render function to selection which scene to render
 */
void render() {

  switch(current_scene) {
  case LOAD:
    if (load_scene != null) {
      load_scene.render();
    }
    break;
  case HOME:
    if (menu_scene != null) menu_scene.render();
    break;
  case LEARN:
    if (learn_scene != null) learn_scene.render();
    break;
  case MEASURE:
    if (measure_scene != null) measure_scene.render();
    break;
  case APPLY:
    if (apply_scene != null) apply_scene.render();
    break;
  default:
    menu_scene.render();
    break;
  }
}
