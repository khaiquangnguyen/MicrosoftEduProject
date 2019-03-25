
// ----------------------------------
// ---------  S T A T E S -----------
// ----------------------------------

enum Action {
  HOME, RELOAD, MEASURE, APPLY, LEARN, PAUSE, PLAY,START;
}

enum Scene {
  LOAD, HOME, MEASURE, APPLY, LEARN;
}


// ----------------------------------
// ----- M E N U  I T E M -----------
// ----------------------------------

/**
 * Menu Item object. Used to create a menu item
 */
class MenuItem {
  final int x, y, r;
  String name;
  PImage normal_state, on_focus_state, on_pressed_state;
  Action action;
  MenuItem(int x_center, int y_center, int radius, String menu_item_name, String background, Action a) {
    x = x_center;
    y = y_center;
    r = radius;
    name = menu_item_name;
    normal_state = loadImage(background);
    action = a;
  }

  /**
   * Check if mouse is over 
   * @return true if mouse is over, false otherwise
   */
  Boolean mouse_over() {
    return calc_distance(mouseX, mouseY, x, y) <= r ? true:false;
  }

  /**
   * Render the menu item
   */
  void render() {
    imageMode(CENTER);
    image(normal_state, x, y, r*2, r*2);
    if (mouse_over()) {
      target_action = action;
    }
  }
}


// ----------------------------------
// --- R E C T  M E N U  I T E M ----
// ----------------------------------

/**
 * Menu Item object. Used to create a menu item
 */
class RectMenuItem {
  final int x, y, h;
  String name;
  PImage normal_state, on_focus_state, on_pressed_state;
  Action action;
  RectMenuItem(int x_center, int y_center, int size, String menu_item_name, String background, Action a) {
    x = x_center;
    y = y_center;
    h = size;
    name = menu_item_name;
    normal_state = loadImage(background);
    action = a;
  }

  /**
   * Check if mouse is over 
   * @return true if mouse is over, false otherwise
   */
  Boolean mouse_over() {
    return calc_distance(mouseX, mouseY, x, y) <= h ? true:false;
  }

  /**
   * Render the menu item
   */
  void render() {
    imageMode(CENTER);
    image(normal_state, x, y, h*2, h);
    if (mouse_over()) {
      target_action = action;
    }
  }
}
// ----------------------------------
// -----------  F I S H   -----------
// ----------------------------------

/**
 * Fish class. Used to render fish
 */
class Fish {
  PImage sprite_right, sprite_left;
  int x, y, size;
  // Direction. 1 for right, -1 for left
  int direction = 1;
  int last_time_stamp = 0;
  //number of pixel move per ms
  float PPMS = 0.2;
  // target to move toward
  int target_x;

  Fish( int x_c, int y_c, int dimension) {
    x = x_c;
    y = y_c;
    size = dimension;
    sprite_right = loadImage("resources/common/fish_right.png");
    sprite_left = loadImage("resources/common/fish_left.png");
    last_time_stamp = millis();
    target_x = (int)random(width);
  }
  /**
   * Render the fish
   */
  void render() {
    try {
      direction = (target_x - x) / abs(target_x-x);
    }
    catch(Exception e) {
      direction = 0;
    }
    random_walk();
    imageMode(CENTER);
    if (direction == 1) {
      image(sprite_right, x, y, size*2, size);
    } else {
      image(sprite_left, x, y, size*2, size);
    }
  }

  /**
   * Random movement for the fish
   */
  void random_walk() {
    // if close to target, get a new target and random a new speed
    if (abs(target_x-x) < size * 2) {
      // get a new target
      target_x = (int)random(width);
      PPMS = random(0.1, 0.2);
    }
    // get delta time
    int delta_time = millis() - last_time_stamp;
    // move toward the target
    x = (int) (x + direction * PPMS * delta_time);      
    // update last time stamp
    last_time_stamp = millis();
  }
}


// ----------------------------------
// ---  S O U N D  W A V E    -------
// ----------------------------------

/**
 * Fish class. Used to render fish
 */
class SoundWave {
  PImage sprite_right, sprite_left;
  int x, y, size;
  // Direction. 1 for right, -1 for left
  int direction = 1;
  int last_time_stamp = 0;
  //number of pixel move per ms
  float PPMS = 0.6;
  // target and source
  int target_x;
  int source_x;
  int opacity = 0;
  int opacity_step = 4;
  // the current target the sound wave is heading toward


  SoundWave( int x_c, int y_c, int dimension, int s_x, int t_x) {
    x = x_c;
    y = y_c;
    size = dimension;
    sprite_right = loadImage("resources/common/sound_wave_right.png");
    sprite_left = loadImage("resources/common/sound_wave_left.png");
    last_time_stamp = millis();
    source_x = s_x;
    target_x = t_x;
  }
  /**
   * Render the sound_wave
   */
  void render() {
    try {
      direction = (target_x - x) / abs(target_x-x);
    }
    catch(Exception e) {
      direction = 0;
    }
    update();
    opacity += opacity_step;
    tint(255, opacity);
    imageMode(CENTER);
    if (direction == 1) {
      image(sprite_right, x, y, size*2, size);
    } else {
      image(sprite_left, x, y, size*2, size);
    }
    tint(255, 255);
  }

  /**
   * Set target
   */
  void set_target(int target) {
    target_x = target;
  }

  /**
   * Random movement for the fish
   */
  void update() {
    // if close to target, switch the target and source
    if (abs(target_x-x) < size) {
      // get a new target
      int t = target_x;
      target_x = source_x;
      source_x = t;
      if (target_x < width / 2) {
        opacity = 255;
        opacity_step = -3;
      } else {
        opacity = 0;
        opacity_step = 4;
      }
      return;
    }
    // get delta time
    int delta_time = millis() - last_time_stamp;
    // move toward the target
    x = (int) (x + direction * PPMS * delta_time);      
    // update last time stamp
    last_time_stamp = millis();
  }
}



// ----------------------------------
// -------  D O L P H I N   ---------
// ----------------------------------


/**
 * Dolphin to navigate the path
 */
class DolphinPath {
  PImage[] sprites_right;
  int frame;
  int x, y, size;
  int last_time_stamp = 0;
  //number of pixel move per ms
  float PPMS = 0.2;
  // target to move toward
  int target_x;
  PImage text_bubble;
  float distance;
  SoundWave sound_wave;
  boolean render_sound_wave = true;


  DolphinPath(int x_c, int y_c, int dimension) {
    x = x_c;
    y = y_c;
    size = dimension;
    last_time_stamp = millis();
    // get all right sprites
    sprites_right = load_sprites("resources/common/dolphin/dolphin_right/");
    text_bubble = loadImage("resources/common/text_bubble.png");
    sound_wave = new SoundWave(x, y, (int)(dimension * 1.2), x, width * 9 / 10);
  }

  /**
   * update the distance bubble
   */
  void update_distance(float d) {
    distance = d;
  }

  /**
   * update position of the dolphin
   */
  void update_position(int x_pos, int y_pos) {
    x = x_pos;
    y = y_pos;
  }
  /**
   * Render the Dolphin
   */
  void render() {
    imageMode(CENTER);  
    
    // render the bubble
    image(text_bubble, x - size, y - size*1.2, size*3, size*1.5);
    // render the font
    fill(#3B3B40);
    textAlign(RIGHT, CENTER);     
    textFont(din_font);
    // size relative to the dolphin
    textSize(size* 3/4);
    text(nf(distance, 0, 1), x-size, y-size*1.3);
    textAlign(LEFT, TOP);
    textFont(lobster_font);
    
    // size relative to the dolphin
    textSize(size * 3/8);
    text("in", x-size * 11/12, y-size*1.3);

    //render the dolphin
    frame = (frame+1) % sprites_right.length;
    image(sprites_right[frame], x, y, size*2, size);

    //render the sound wave
    if (render_sound_wave) sound_wave.render();

    //if (direction == 1) {
    //  frame = (frame+1) % sprites_right.length;
    //  image(sprites_right[frame], x, y, size*2, size);
    //} else {
    //  frame = (frame+1) % sprites_left.length;
    //  image(sprites_left[frame], x, y, size*2, size);
    //}
  }

  //  /**
  //   * Random movement for the fish
  //   */
  //  void move() {
  //    // if close to target, stop
  //    if (abs(target_x-x) < size * 2) return;
  //    // get delta time
  //    int delta_time = millis() - last_time_stamp;
  //    // move toward the target
  //    x = (int) (x + direction * PPMS * delta_time);      
  //    // update last time stamp
  //    last_time_stamp = millis();
  //  }
}



// ----------------------------------
// -------  D O L P H I N   ---------
// ----------------------------------


/**
 * Dolphin
 */
class Dolphin {
  PImage[] sprites_right;
  int frame;
  int x, y, size;
  int last_time_stamp = 0;
  //number of pixel move per ms
  float PPMS = 0.2;
  // target to move toward
  int target_x;
  PImage text_bubble;
  float distance;
  SoundWave sound_wave;
  boolean render_sound_wave = true;


  Dolphin( int x_c, int y_c, int dimension) {
    x = x_c;
    y = y_c;
    size = dimension;
    last_time_stamp = millis();
    // get all right sprites
    sprites_right = load_sprites("resources/common/dolphin/dolphin_right/");
    text_bubble = loadImage("resources/common/text_bubble.png");
    sound_wave = new SoundWave(x, y, (int)(dimension * 1.2), x, width * 9 / 10);
  }

  /**
   * update the distance bubble
   */
  void update_distance(float d) {
    distance = d;
  }

  /**
   * update position of the dolphin
   */
  void update_position(int x_pos, int y_pos) {
    x = x_pos;
    y = y_pos;
  }
  /**
   * Render the Dolphin
   */
  void render() {
    imageMode(CENTER);  
    
    // render the bubble
    image(text_bubble, x - size/2, y - size, size*2, size);
    // render the font
    fill(#3B3B40);
    textAlign(RIGHT, CENTER);     
    textFont(din_font);
    // size relative to the dolphin
    textSize(size*1/2);
    text(nf(distance, 0, 1), x-size * 5 / 12, y-size*1.1);
    textAlign(LEFT, TOP);
    textFont(lobster_font);
    
    // size relative to the dolphin
    textSize(size*1/4);
    text("in", x-size / 3, y-size*1.1);

    //render the dolphin
    frame = (frame+1) % sprites_right.length;
    image(sprites_right[frame], x, y, size*2, size);

    //render the sound wave
    if (render_sound_wave) sound_wave.render();

  }

}

// ----------------------------------
// --------   G R A P H   -----------
// ----------------------------------

class Graph {
  // origin is bot left (0,0). cor is corner (top-right)
  int origin_x, origin_y, corner_x, corner_y, w, h;
  String title;
  // colors
  color AXIS_COLOR = #A4A299; 
  color LINE_COLOR = #7B796E;
  // the maximum distance the graph can accept in inch
  final int MAX_DISTANCE = 80;
  // the number of second should be shown on the x-axis
  final int TIME_FRAME = 15;
  // number of x_ticks and y_ticks
  final int NUM_X_TICKS = 30;
  final int NUM_Y_TICKS = 10;
  // number of pixel per inch
  int pixel_per_inch;
  // queue to store all the readings
  Queue <Reading> readings = new LinkedList<Reading>();
  // the time stamp of the data point at origin. shift along with graph. unit is in s
  float init_time_stamp;
  // start time stamp
  int time_start = millis();
  // the time frame of last record
  int last_record_time_frame = millis();
  // number of mls should have passed before taking another reding
  int TIME_BETWEEN_READING = 0;

  Graph(int x, int y, int c_x, int c_y, String name) {
    origin_x = x;
    origin_y  = y;
    corner_x = c_x;
    corner_y = c_y;
    w = corner_x - origin_x;
    h = origin_y - corner_y;
    title = name;
    // calculate the number of pixel per inch. h/max_distance
    pixel_per_inch = h / MAX_DISTANCE;
  }

  /**
   * Add a new data point to the graph and render accordingly
   */
  void add_data_point(float data_point) {
    // cap the data
    if (data_point >= MAX_DISTANCE) data_point = MAX_DISTANCE;
    // add both points and timestamp
    int time_stamp = millis();
    // check if enough time have passed yet. not enough then do nothing
    //println(time_stamp - last_record_time_frame);
    if (time_stamp - last_record_time_frame < TIME_BETWEEN_READING) return;
    // update last record
    last_record_time_frame = time_stamp;
    // total time passed
    float time_passed = (time_stamp - time_start)/1000.0;
    // calculate new init time stamp (time stamp of point at index 0)
    if (time_passed < TIME_FRAME) {
      init_time_stamp = 0;
    } else {
      init_time_stamp = time_passed - TIME_FRAME;
    }
    readings.add(new Reading(data_point, time_stamp));
    // if queue is holding more values than time frame, then remove the first element from the queue
    while (time_stamp - readings.peek().time_stamp > TIME_FRAME * 1000) {
      readings.remove();
    }
  }


  /**
   * render the entire graph
   */
  void render() {
    render_axis();
    render_line();
  }

  /**
   * Render the line part of the graph
   */
  void render_line() {
    float last_value = 0;
    int x_pos = origin_x + 10;
    int last_time_stamp = millis();
    strokeWeight(5);
    // joint of the axis
    strokeJoin(ROUND);
    // cap of stroke
    strokeCap(ROUND);
    // update max distance    
    for (Reading a_reading : readings) {
      if (last_value == 0) {
        last_value = a_reading.reading;
        last_time_stamp = a_reading.time_stamp;
      } else {        
        // draw the line
        // color of the line
        stroke(LINE_COLOR);
        line(x_pos, origin_y - last_value * pixel_per_inch, x_pos + (a_reading.time_stamp - last_time_stamp) * w/(TIME_FRAME*1000), origin_y - a_reading.reading * pixel_per_inch);
        // update last_value and x_pos
        last_value = a_reading.reading;
        x_pos = x_pos + (a_reading.time_stamp - last_time_stamp) * w/(TIME_FRAME*1000);
        last_time_stamp = a_reading.time_stamp;
      }
    }
  }

  /**
   * Render the axis of the graph
   */
  void render_axis() {
    // the tough part. Render the graph axis
    // color of the axis
    stroke(AXIS_COLOR);
    // weight of the axis
    strokeWeight(10);
    // joint of the axis
    strokeJoin(ROUND);
    // cap of stroke
    strokeCap(ROUND);
    // draw the y axis
    line(origin_x, origin_y, origin_x, corner_y);
    // draw the x axis
    line(origin_x, origin_y, corner_x, origin_y);
    // draw the tickers
    strokeWeight(7);
    // on y axis
    fill(AXIS_COLOR);
    textAlign(RIGHT, CENTER);
    textFont(din_font);
    textSize(12);      

    for (int i = 0; i <= NUM_Y_TICKS; i++) {
      line(origin_x, origin_y - i * h/(NUM_Y_TICKS), origin_x * 0.9, origin_y - i * h/(NUM_Y_TICKS));
      textAlign(RIGHT, CENTER);
      text(MAX_DISTANCE/NUM_Y_TICKS * i, origin_x * 0.8, origin_y - i * h/(NUM_Y_TICKS));
    }
    // draw the unit
    textAlign(CENTER, BOTTOM);     
    textFont(din_font);
    textSize(16);
    text("(In)", origin_x, corner_y - 15);

    // on x axis
    fill(AXIS_COLOR);
    textAlign(CENTER, TOP);     
    textFont(din_font);
    textSize(12);      
    for (int i = 0; i <= NUM_X_TICKS; i++) {
      line(origin_x + i * w/(NUM_X_TICKS), origin_y, origin_x + i * w/(NUM_X_TICKS), origin_y * 1.01);
      text(nf(init_time_stamp + float(i) * TIME_FRAME/NUM_X_TICKS, 0, 1), origin_x + i * w/(NUM_X_TICKS), origin_y * 1.02);
    }
    //draw the unit
    textAlign(LEFT, CENTER);     
    textFont(din_font);
    textSize(16);
    text("(Sec)", corner_x + 15, origin_y );
  }
}


/**
 * Pause Overlay. Only the mid object
 */

class PauseOverlay {
  MenuItem home_btn, cont_btn, reload_btn;
  PImage background_img;
  PauseOverlay() {
    // load the buttons
    home_btn = new MenuItem(width/2 + width/80 - width/15, height* 23/40, NAV_MENU_ITEM_RADIUS, "home", "resources/nav/home.png", Action.HOME);
    cont_btn = new MenuItem(width/2 + width/80, height* 23/40, NAV_MENU_ITEM_RADIUS, "pause", "resources/nav/play.png", Action.PLAY);
    reload_btn = new MenuItem(width/2 + width/80 + width/15, height*23/40, NAV_MENU_ITEM_RADIUS, "reload", "resources/nav/reload.png", Action.RELOAD);
    // load the background image of the pause menu
    background_img = loadImage("resources/nav/overlay_background.png");
  }

  /**
   * render the pause menu
   */
  void render() {
    imageMode(CENTER);
    image(background_img, width/2, height/2, width/4, height/4);
    home_btn.render();
    cont_btn.render();
    reload_btn.render();
  }
}

/**
 * Thread object to play the sound file so that it doesn't affect the main program. 
 * Source: http://www.science.smith.edu/dftwiki/index.php/Tutorial:_Playing_Sounds_in_a_Separate_Thread
 */

class MyThread extends Thread {
  Minim minim;
  AudioPlayer player;
  boolean quit;
  boolean playNow;

  MyThread( Minim m, AudioPlayer p ) {
    minim = m;
    player = p;
    quit    = false;
    playNow = false;
  }

  public void playNow() {
    playNow = true;
  }

  public void quit() {
    quit = true;
  }

  void run() {
    while ( !quit ) {
      // wait 10 ms, then check if need to play
      try {
        Thread.sleep( 10 );
      } 
      catch ( InterruptedException e ) {
        return;
      }

      // if we have to play the sound, do it!
      if ( playNow ) {
        playNow = false;
        player.play();
        player.rewind();
      }

      // go back and wait again for 10 ms...
    }
  }
}
