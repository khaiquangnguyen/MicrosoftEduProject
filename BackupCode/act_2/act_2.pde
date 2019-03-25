Boolean show_wave = true;
PImage img;
int wWidth, wHeight, r = 1;
float lastR;
int lineNum = 5;
int spacing = 100;
float source_x;
float source_y;
float target_x;
float target_y;
float moving_x;
import processing.serial.*;
Serial myPort;
String distance;
int d;
float graph_height = 300;
IntList distances = new IntList();
int distance_between_points = 10;
int max_num_points = 100;
int last_frame_count = 0;

//#A9A296
void setup(){
        wWidth = 1280;
        wHeight = 720;
        source_x = wWidth * 5 / 20;
        source_y = wHeight * 4/ 17 - 10;
        target_x = wWidth;
        target_y = source_y;
        moving_x = source_x;
        lastR = 1500;
        background(255);
        size(1280,720);
        img = loadImage("act_2.jpg");
        background(img);
        smooth();
        String portName = Serial.list()[1];
        myPort = new Serial (this, portName, 9600);
}

void draw(){
         //if (frameCount - last_frame_count > 3){          
         //   d = (int)random(100,200);
         //   distances.append(d);
         //   last_frame_count = frameCount;
         //}

        //draw the graph
        while (myPort.available() > 0){
          distance = myPort.readStringUntil('\n');
          if (distance != null && frameCount - last_frame_count > 3){
            //get the distance
            last_frame_count = frameCount;
            d = int(distance.trim());
            if (d >= 100){
              d = 100;
            }
            distances.append(d);            
          }
        }
        background(img);
        fill(255);
        r = r + 15;
        for (int i = 1; i <= lineNum; i++) {
            stroke(#E3E2E4);
            strokeWeight(3);
            if (show_wave) {
                noFill();
                float r2 = (r + spacing * i) % lastR;
                arc(source_x, source_y, r2, r2/2, -PI / 20, PI/20);
            }
        }
        if (distances.size() > 1){
              int count = distances.size() > max_num_points ? distances.size() - max_num_points : 0;
              int last_x = 70;
              int next_x = distances.get(count);
              int last_y = wHeight - (int)map(distances.get(count),0,200,50,250);
              int next_y = distances.get(count);
              textSize(40);
              text(distances.get(distances.size()-1),1120,165);
              while (distances.size() >= 3 && count < distances.size()-1){
                next_y = wHeight - (int)map(distances.get(count),0,100,50,350);
                next_x = last_x + distance_between_points;
                stroke(#E3E2E4);
                strokeWeight(4);
                line(last_x,last_y,next_x,next_y);
                last_x = next_x;
                last_y = next_y;
                count++;
              }
            }
}
