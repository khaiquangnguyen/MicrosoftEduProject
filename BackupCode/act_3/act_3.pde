import processing.serial.*;
Serial myPort;
String distance;
String t_direction = "Up";
int d;
PImage img;
PImage player;
Boolean turning = true;
int last_d;
int r = 10;
int c_x = 385;
int c_y = 565;
int t_x = 0;
int t_y = 0;
int b_x = c_x;
int b_y = c_y;
int distance_to_target = 0;
IntList turns = new IntList();;
IntList x_anchors = new IntList();
IntList y_anchors = new IntList();
int direction = 8;
 //8 is straight, 2 is down, 4 is left, 6 is right
int pixel_over_cm = 5;

void setup(){
  size(1280, 720);
  String portName = Serial.list()[1];
  myPort = new Serial (this, portName, 9600);
  background(255);
  x_anchors.append(c_x);
  y_anchors.append(c_y);
  img = loadImage("act_3.jpg");
  player = loadImage("actor.png");
  background(img);
  smooth();

}

void change_target(){
  switch (direction){
        case 8:
          t_x = b_x;
          t_y = b_y - d * pixel_over_cm;
          t_direction = "Up";
          break;
        case 2:
          t_x = b_x;
          t_y = b_y + d * pixel_over_cm;
          t_direction = "Down";
          break;
        case 4:
          t_y = b_y;
          t_x = b_x - d * pixel_over_cm;
          t_direction = "Left";
          break;
        case 6:
          t_y = b_y;
          t_x = b_x + d * pixel_over_cm;
          t_direction = "Right";
          break;
        default:
          println(direction);
      }
}
void change_current_location(){
  switch (direction){
        case 8:
          c_x = b_x;
          c_y = t_y + d * pixel_over_cm;
          break;
        case 2:
          c_x = b_x;
          c_y = t_y - d * pixel_over_cm;
          break;
        case 4:
          c_y = b_y;
          c_x = t_x + d * pixel_over_cm;
          break;
        case 6:
          c_y = b_y;
          c_x = t_x - d * pixel_over_cm;
          break;
        default:
          println(direction);
      }
}
void keyPressed() {
  if (key == CODED && turning) {
    if (keyCode == UP) {
      direction = 8;
    } else if (keyCode == DOWN) {
      direction = 2;
    } 
    else if (keyCode == LEFT) {
      direction = 4;
    } 
    else if (keyCode == RIGHT) {
      direction = 6;
    } 
  }
  else{
     if (key == ENTER || key == RETURN){
      turning = !turning; 
      if (turning){
      change_direction();
      }
    }
  }
}

void change_direction(){
  x_anchors.append(t_x);
  y_anchors.append(t_y);
  b_x = t_x;
  b_y = t_y;
  c_x = b_x;
  c_y = b_y;
  change_target();
}

void draw_path(){
  if (x_anchors.size() <= 1) return;
  for (int i = 1; i < x_anchors.size(); i++){
      fill(#A9A296);
      noStroke();
      circle(x_anchors.get(i),y_anchors.get(i),r);
  }
   for (int i = 0; i < x_anchors.size()-1; i++){
      stroke(#A9A296);
      strokeWeight(4);
      line(x_anchors.get(i),y_anchors.get(i),x_anchors.get(i+1),y_anchors.get(i+1));
  }
}

void draw(){
  //draw the anchors
    background(img);
    fill(255);
    textSize(65);
    rotate(-0.3);
    text(d,70,250);
    textSize(28);
    text(t_direction,150, 290);
    textSize(16);
    if (turning){
      text("Turning...", 35, 185);
    }
    else{
      text("Sailing...", 35, 185);

    }
    rotate(0.3);

  while (myPort.available() > 0){ 
    distance = myPort.readStringUntil('\n');
    if (distance != null){
      //get the distance
      d = int(distance.trim());
    }
  }
      //abrupt change in distance. likely due to change in target
      if (d > 50){
        d = last_d;
      }
      if (turning){
        change_target(); 
        noStroke();
        fill(#A9A296,100);
        circle(b_x,b_y, 2 * d * pixel_over_cm);
      }
      else{
        change_current_location();
        fill(#A9A296);
        noStroke();
        circle(t_x,t_y,r);
        strokeWeight(4);
        stroke(#A9A296);
        line(b_x,b_y,c_x,c_y);
        image(player, c_x - 25,c_y - 25);
      }
      draw_path();
      last_d = d;
      //draw the distance text
      
}
