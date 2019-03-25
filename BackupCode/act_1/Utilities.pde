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

class KalmanFilter {
  float q = 1.0;     // process variance
  float r = 2.0;     // estimate of measurement variance, change to see effect

  float xhat = 0.0;  // a posteriori estimate of x
  float xhatminus;   // a priori estimate of x
  float p = 1.0;     // a posteriori error estimate
  float pminus;      // a priori error estimate
  float kG = 0.0;    // kalman gain
  
  KalmanFilter() {};
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
  final int NUM_REQUIRED_READINGS = 5;

  for (String port : ports) {
    //try to get a reading from the arduino to see if there is any connection
    print(" Try connectin to port " + port_count++ +  " : " + port + "  ===>  ");
    try {
      //connect to a port
      arduino_port = new Serial (this, ports[1], 9600);
      //init the values
      start_time = millis();
      num_arduino_readings = 0;
      //test the connection for CONNECTION_TIMEOUT mls
      while (millis() - start_time < CONNECTION_TIMEOUT) {
        float distance = getSensorValue();
        if (!Float.isNaN(distance) && distance != -1) {
          num_arduino_readings++;
          //if successfully read a number of readings, then it means this is the correct port and just return
          if (num_arduino_readings >= NUM_REQUIRED_READINGS) {
            println(" PORT FOUND!");
            return;
          }
        }
      }
    }
    catch (Exception e) {
            println(" WRONG PORT!");
    }
  }
}
