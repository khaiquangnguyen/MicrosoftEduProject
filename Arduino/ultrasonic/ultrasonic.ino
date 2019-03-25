#include "MedianFilterLib.h"


// -----------------------------------
// -------- V A R I A B L E S --------
//------------------------------------
// defines arduino pins numbers
#define TRIGGER_PIN  12  // Arduino pin tied to trigger pin on the ultrasonic sensor.
#define ECHO_PIN     13  // Arduino pin tied to echo pin on the ultrasonic sensor.
#define MAX_DISTANCE 79 // Maximum distance we want to ping for (in centimeters). Maximum sensor distance is rated at 400-500cm.
#define FPS 15          // Number of time the code should run per second

// duration of pulse which indicates distance
float duration;
// distane to target
float distance;
// median filter ojbect
MedianFilter<float> medianFilter(7);
//int delayTone_count = 0;

void setup() {
  pinMode(TRIGGER_PIN, OUTPUT); // Sets the trigPin as an Output
  pinMode(ECHO_PIN, INPUT); // Sets the echoPin as an Input

  Serial.begin(9600); // Starts the serial communication
}

void loop() {
  // Clears the trigPin
  digitalWrite(TRIGGER_PIN, LOW);
  delayMicroseconds(5);

  // Sets the trigPin on HIGH state for 10 micro seconds
  digitalWrite(TRIGGER_PIN, HIGH);
  delayMicroseconds(10);
  digitalWrite(TRIGGER_PIN, LOW);
  // Reads the echoPin, returns the sound wave travel time in microseconds
  duration = pulseIn(ECHO_PIN, HIGH);
  // Calculating the distance in cm
//  distance = duration * 0.01715;
  // Calculating the distance in inches
    distance = duration * 0.00675;
  //  constrain the distance
  distance = constrain(distance, 0, MAX_DISTANCE);
  distance = medianFilter.AddValue(distance);
  Serial.println(distance);
  delay(1000/FPS);
}
  //  Serial.print(inches);
  //  Serial.print("in, ");
  //  Serial.print(cm);
  //  Serial.print("cm");
  //  Serial.println();
  //  //constrain the distance
  //  distance = constrain(distance,0,MAX_DISTANCE);
  //  // Prints the distance on the Serial Monitor
  //  Serial.println(distance);
  //  delay(20);
  //  tone(buzzerPin,30, 200);
  //  int sound_delay = map(distance,0,400,25,1000);
  //  delay(sound_delay);
  //  noTone(buzzerPin);
//}
