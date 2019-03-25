// ----------------------------------
// ------ L O A D I N G -------------
// ----------------------------------
/**
 * The Loading screen
 */
class LoadingScene {
  MenuItem learn, apply, measure, start;
  color background_color = MAIN_BGR_COLOR;
  PImage deco_left, deco_right, title;

  LoadingScene() {
    deco_left = loadImage("resources/menu/left_deco.png");
    deco_right = loadImage("resources/menu/right_deco.png");
    title =    loadImage("resources/menu/title.png");
  }
  /**
   * Render the menu
   */
  void render() {
    //render the background color of the menu 
    background(background_color);
    //render the title and decos of the menu
    image(deco_left, width/8, height - height/6, height / 3, height/3);
    imageMode(CENTER);
    image(deco_right, width*7/8, height - height/6, height / 3, height/3);
    image(title, width/2, height/5, height * 9 / 15, height * 4 / 15); 
    textAlign(CENTER, CENTER);
    textFont(lobster_font);
    textSize(150);
    text("Finding dolphin...", width/2, height/2);
  }
}

// ----------------------------------
// --------  L E A R N  -------------
// ----------------------------------
/**
 * The Loading screen
 */
class LearnScene {
  MenuItem home_btn, pause_btn, reload_btn;
  color background_color = MAIN_BGR_COLOR;

  LearnScene() {
    // load the buttons
    home_btn = new MenuItem(width*2/40, height * 1/20, NAV_MENU_ITEM_RADIUS, "home", "resources/nav/home.png", Action.HOME);
    pause_btn = new MenuItem(width*4/40, height* 1/20, NAV_MENU_ITEM_RADIUS, "pause", "resources/nav/pause.png", Action.PAUSE);
    reload_btn = new MenuItem(width*6/40, height*1/20, NAV_MENU_ITEM_RADIUS, "reload", "resources/nav/reload.png", Action.RELOAD);
    intro_movie.play();
  }


  /**
   * Render the scene
   */
  void render() {
    //render the background color of the menu 
    background(background_color);
    //render the buttons
    home_btn.render();
    pause_btn.render();
    reload_btn.render();
    if (intro_movie.available()) {
      intro_movie.read();
    }
    if (!pausing) {
      intro_movie.play();
      image(intro_movie, width/2, height/2, width*3/4, height*3/4);
    }
    else{
      intro_movie.pause();
    }
  }
}



// ----------------------------------
// ---------  M E N U   -------------
// ----------------------------------

/**
 * The main menu
 */
class MenuScene {
  MenuItem learn, apply, measure, start;
  color background_color = MAIN_BGR_COLOR;
  PImage deco_left, deco_right, title;
  MenuScene() {
    learn = new MenuItem(width/4, height * 11 /20, MENU_ITEM_RADIUS, "Learn", "resources/menu/learn.png", Action.LEARN);
    measure = new MenuItem(width/2, height* 11 / 20, MENU_ITEM_RADIUS, "Measure", "resources/menu/measure.png", Action.MEASURE);
    apply = new MenuItem(width*3/4, height*  11 / 20, MENU_ITEM_RADIUS, "Apply", "resources/menu/apply.png", Action.APPLY);
    deco_left = loadImage("resources/menu/left_deco.png");
    deco_right = loadImage("resources/menu/right_deco.png");
    title =    loadImage("resources/menu/title.png");
  }
  /**
   * Render the menu
   */
  void render() {
    //render the background color of the menu 
    background(background_color);
    //render the title and decos of the menu
    image(deco_left, width/8, height - height/6, height / 3, height/3);
    imageMode(CENTER);
    image(deco_right, width*7/8, height - height/6, height / 3, height/3);
    image(title, width/2, height/5, height * 9 / 15, height * 4 / 15); 
    //render the menu items
    learn.render();
    apply.render();
    measure.render();
  }
}

// ----------------------------------
// ---------  A P P L Y -------------
// ----------------------------------


/**
 * The third scene - the apply (path navigation) activity
 */

class ApplyScene {
  MenuItem home_btn, pause_btn, reload_btn;
  RectMenuItem new_path, start_btn;
  color background_color = SECONDARY_BGR_COLOR;
  PImage table_background, title;
  StringList maze_map = new StringList(); 
  color LINE_COLOR = #528ECC;
  PImage x_mark;
  IntList line_lengths = new IntList();
  // the dolphin related vars. Used to move the dolphin around
  DolphinPath dolphin;
  int x_dolphin, y_dolphin;
  int target_index_in_array, x_target, y_target, x_origin, y_origin;
  int START_X = width / 2;
  int START_Y =  height * 13/20;
  IntList x_pos = new IntList();
  IntList y_pos = new IntList();
  float path_length = 1;
  boolean turning = false;


  ApplyScene() {
    // load the buttons
    home_btn = new MenuItem(width*2/40, height * 1/20, NAV_MENU_ITEM_RADIUS, "home", "resources/nav/home.png", Action.HOME);
    pause_btn = new MenuItem(width*4/40, height* 1/20, NAV_MENU_ITEM_RADIUS, "pause", "resources/nav/pause.png", Action.PAUSE);
    reload_btn = new MenuItem(width*6/40, height*1/20, NAV_MENU_ITEM_RADIUS, "reload", "resources/nav/reload.png", Action.RELOAD);
    start_btn = new RectMenuItem(width*9/40, height*1/20, NAV_MENU_ITEM_RADIUS*2, "start", "resources/apply/start.png", Action.START);
    table_background = loadImage("resources/apply/table.png");
    x_mark = loadImage("resources/apply/x_mark.png");
    title = loadImage("resources/common/title.png");
    // load the dolphin
    dolphin = new DolphinPath(width * 3/20, height /9, height / 24);
    dolphin.render_sound_wave = false;
    create_maze();
    // initiate a bunch of variables
    target_index_in_array = 1;
  }

  /**
   * perform a bunch of actions when receive a distance data point
   */
  void update_distance(float distance) {   
    // update the dolphin
    dolphin.update_distance(distance);
    // update the dolphin position
    dolphin.update_position(x_dolphin, y_dolphin);
    println(x_dolphin, y_dolphin);
    // if distance is greater than path length, update it
    if (distance > path_length && distance - path_length < 5) {
      path_length = distance;
    } 
    // when get to the corner
    if (distance < 2) turning = true;
    if (turning) {
      if (distance > 4) {
        turning = false;
        path_length = distance;
        to_next_target();
      } else {
        distance = constrain(distance, 0, 2);
      }
    }
    float percent =  1 - distance/path_length;
    percent = constrain(percent, 0, 1);
    x_dolphin = (int) (x_origin + (x_target-x_origin) * percent);
    y_dolphin = (int) (y_origin + (y_target-y_origin) * percent);
  }

  /**
   * start the movement. set the dolphin to the beginning of the maze 
   */
  void start_game() {
    // reset all the variables
    play_sound = true;
    turning = false;
    path_length = 1;
    //render the maze
    x_dolphin = START_X;
    y_dolphin = START_Y;
    x_origin = START_X;
    y_origin = START_Y;
    target_index_in_array = 1;
    x_target = x_pos.get(target_index_in_array);
    y_target =y_pos.get(target_index_in_array);
    //change to reset
    start_btn.normal_state = loadImage("resources/apply/reset.png");
  }

  /**
   * switch the target of the dolphin to the next one
   */
  void to_next_target() {
    target_index_in_array++;
    if (target_index_in_array >= x_pos.size()) {
      println("Finish");
      return;
    }

    x_origin = x_target;
    y_origin = y_target;
    x_target = x_pos.get(target_index_in_array);
    y_target = y_pos.get(target_index_in_array);
  }

  /**
   * Render the scene
   */
  void render() {
    //render the buttons
    background(background_color);   
    home_btn.render();
    pause_btn.render();
    reload_btn.render();
    start_btn.render();
    image(table_background, width/2, height * 11/20, width, width/2);
    image(title, width*17/20, height*1/20, height/3, height/12);
    //render the maze
    strokeWeight(100);
    // joint of the axis
    strokeJoin(ROUND);
    // cap of stroke
    strokeCap(ROUND);
    stroke(LINE_COLOR);
    for (int i =0; i < x_pos.size()-1; i++) {
      line(x_pos.get(i), y_pos.get(i), x_pos.get(i+1), y_pos.get(i+1));
    }
    // render the x_mark first
    image(x_mark, width / 2, height * 13/20, height/15, height/15);
    for (int i=1; i < x_pos.size(); i++) {
      strokeWeight(2);
      fill(#528ECC);
      circle(x_pos.get(i), y_pos.get(i), 23);
    }
    // then render the dolphin
    dolphin.render();
  }

  /**
   * Generate a random maze and show it on the screen
   */
  void create_maze() {
    x_pos = new IntList();
    y_pos = new IntList();
    line_lengths = new IntList();
    maze_map = new StringList(); 
    String next_direction;
    maze_map.append("UP");
    int last_direction = 0;
    int random_direction;
    //int line_length = (int)random(width/30, width/10);
    int line_length = width/8;
    line_lengths.append(line_length);
    // reset the maze first
    int i = 0;
    for (i = 0; i < 3; i++) {
      // check for condition where it goes up and down, which is not a valid argument
      while (true) {
        random_direction = (int)random(4);  
        // if same as last direction, redo it
        if (last_direction == random_direction) continue;
        if (abs(random_direction-last_direction) == 1) {
          if ((random_direction == 1 && last_direction == 2) || (random_direction==2 && last_direction == 1)) {
            break;
          }
        } else {
          break;
        }
      }
      // create the line length first
      //random the line length
      //line_length = (int)random(width/30, width/10);
      //line_length = width/15;
      line_lengths.append(line_length);
      switch(random_direction) {
      case 0:
        next_direction = "UP";
        break;
      case 1:
        next_direction = "DOWN";
        break;
      case 2:
        next_direction = "LEFT";
        break;
      case 3:
        next_direction = "RIGHT";
        break;
      default:
        next_direction = "UP";
        break;
      }
      maze_map.append(next_direction);
      last_direction = random_direction;
    }

    // render the maze in x,y coordinate
    //render the maze
    int start_x = START_X;
    int start_y = START_Y;    
    x_pos.append(start_x);
    y_pos.append(start_y);
    i = 0;
    for (String direction : maze_map) {
      //random the line length
      line_length = line_lengths.get(i++);
      switch (direction) {
      case "UP":
        start_y = start_y - line_length;
        break;
      case "DOWN":
        start_y = start_y + line_length;
        break;
      case "LEFT":
        start_x = start_x - line_length;
        break;
      case "RIGHT":
        start_x = start_x + line_length;
        break;
      }       
      x_pos.append(start_x);
      y_pos.append(start_y);
    }
    // if the starting point is equal to the ending point, reset the maze
    if (x_pos.get(0) == x_pos.get(x_pos.size()-1) && y_pos.get(0) == y_pos.get(y_pos.size()-1)) create_maze();
  }
}


// ----------------------------------
// -------  M E A S U R E -----------
// ----------------------------------


/**
 * The second scene - measure activity
 */
class MeasureScene {
  MenuItem home_btn, pause_btn, reload_btn;
  color top_background_color = MAIN_BGR_COLOR;
  color bottom_background_color = SECONDARY_BGR_COLOR;
  int NUM_FISH = 10;
  PImage deco_wave, deco_graph, title;
  Dolphin dolphin;
  Fish[] fishes = new Fish[NUM_FISH];
  Graph graph;
  MeasureScene() {
    // load the buttons
    home_btn = new MenuItem(width*2/40, height * 1/20, NAV_MENU_ITEM_RADIUS, "home", "resources/nav/home.png", Action.HOME);
    pause_btn = new MenuItem(width*4/40, height* 1/20, NAV_MENU_ITEM_RADIUS, "pause", "resources/nav/pause.png", Action.PAUSE);
    reload_btn = new MenuItem(width*6/40, height*1/20, NAV_MENU_ITEM_RADIUS, "reload", "resources/nav/reload.png", Action.RELOAD);
    // load the decos
    deco_wave = loadImage("resources/measure/deco_wave.png");
    deco_graph = loadImage("resources/measure/deco_graph.png");
    title = loadImage("resources/common/title.png");

    // load the fishes
    for (int i = 0; i < NUM_FISH; i++) {
      int y_fish = (int)random(height * 1/20, height * 8/20);
      int x_fish = (int)random(width * 4/ 30, width * 26/30);
      Fish fish = new Fish(x_fish, y_fish, height / 50);
      fishes[i] = fish;
    }
    // load the dolphin
    dolphin = new Dolphin(width * 3/20, height /3, height / 8);

    // load the graph
    graph = new Graph(width/20, height* 19/20, width*17/20, height* 10/20, "distance over time");
  }

  /**
   * perform a bunch of actions when receive a distance data point
   */
  void update_distance(float distance) {
    // update the graph
    graph.add_data_point(distance);
    // update the dolphin
    dolphin.update_distance(distance);
  }

  /**
   * Render the scene
   */
  void render() {
    //render the background color of top and bottom first
    background(top_background_color);   
    //draw the background of the bottom half
    noStroke();
    fill(bottom_background_color);
    rect(0, height * 9/20, width, height);
    //render the fishes
    for (Fish fish : fishes) {
      fish.render();
    }  
    //render the buttons
    home_btn.render();
    pause_btn.render();
    reload_btn.render();
    // render the deco
    image(deco_wave, width * 9 / 10, height*9/20 - height/8, height/4, height/4);
    image(deco_graph, width * 9 / 10, height - height*5/24, height*5/24, height*5/12);
    image(title, width*17/20, height*1/20, height/3, height/12);

    //render the dolphin
    dolphin.render();
    // render the graph
    graph.render();
  }
}
