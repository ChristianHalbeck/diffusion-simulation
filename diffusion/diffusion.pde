/* easy-to-modify stuff */
  // visual
  final int WINDOW_SIZE = 900; // affects both width and height
  final int FRAME_RATE = 60; // will affect overall speed of the program (adjust particle speed to avoid this)

  final int PCOLOUR_1 = 100; // colour for substance 1 (hue, 0-255)
  final int PCOLOUR_2 = 200; // substance 2
  
  // box borders (modifying these might break stuff)
  final float BOX_LEFT_REL = 0.04; // relative to window width
  final float BOX_RIGHT_REL = 0.96;
  final float BOX_TOP_REL = 0.06; // relative to window height
  final float BOX_BOTTOM_REL = 0.74;
  final float TEXT_LEFT_REL = BOX_LEFT_REL; // settings and keys, relative to window width
  final float TEXT_TOP_REL = BOX_BOTTOM_REL + 0.06; // relative to window height
  final int TEXT_SIZE = 15;
  
  // default values
  int SET_PCOUNT = 120; // particle count (positive, even number)
  int SET_PSPEED = 10; // particle speed (positive)
  int SET_PRADIUS = 6; // particle radius (positive)
  
  // strings (for translation)
  // use spaces to align the text (font is monospaced)
  final String LNG_PCOUNT = "Anzahl Teilchen"; // particle count
  final String LNG_PSPEED = "Geschwindigkeit"; // particle speed
  final String LNG_PRADIUS = "  Teilchengröße"; // particle radius
  final String LNG_SETTINGS = "Pfeiltasten: Einstellungen ändern"; // 'use the arrow keys to change settings'
  final String LNG_PAUSE = "Leertaste: Pause / Weiter"; // 'press [key] to pause' (shows when program is unpaused)
  final String LNG_UNPAUSE = "Leertaste: Pause / Weiter"; // 'press [key] to unpause' (shows when program is paused)
  final String LNG_APPLY = "Enter: Übernehmen und Neustarten"; // 'press [key] to apply settings'
  
  // keys
  final char KEY_PAUSE = ' '; // pause, default is space (' ')
  final char KEY_APPLY = ENTER; // apply settings / restart, default is enter (ENTER)
/*                      */

ArrayList<Particle> particles;
int pCount, pRadius, BOX_LEFT, BOX_RIGHT, BOX_TOP, BOX_BOTTOM, TEXT_TOP, TEXT_LEFT;
float pSpeed;
int setSelected = 0;
boolean paused;
PFont font;


class Particle {
  float x, y, hspeed, vspeed;
  int subst;
  
  Particle(int subst_, float xMin, float xMax, float yMin, float yMax) { // positions are relative to the borders of the box
    subst = subst_;
    
    int xMinAbs = int(BOX_LEFT + pRadius + floor((BOX_RIGHT - BOX_LEFT) * xMin));
    int xMaxAbs = int(BOX_LEFT + ceil((BOX_RIGHT - BOX_LEFT) * xMax) - pRadius);
    int yMinAbs = int(BOX_TOP + pRadius + floor((BOX_BOTTOM - BOX_TOP) * yMin));
    int yMaxAbs = int(BOX_TOP + ceil((BOX_BOTTOM - BOX_TOP) * yMax) - pRadius);
    x = random(xMinAbs, xMaxAbs);
    y = random(yMinAbs, yMaxAbs);
    
    float dir = random(0, TAU);
    hspeed = pSpeed * sin(dir);
    vspeed = pSpeed * cos(dir);
  }
  
  void update() {
    // update position
    x += hspeed;
    y += vspeed;
    
    // box collisions
    if(x - pRadius <= BOX_LEFT) {
      hspeed *= -1;
      x = BOX_LEFT + pRadius + 1;
    }
    if(x + pRadius >= BOX_RIGHT) {
      hspeed *= -1;
      x = BOX_RIGHT - pRadius - 1;
    }
    if(y - pRadius <= BOX_TOP) {
      vspeed *= -1;
      y = BOX_TOP + pRadius + 1;
    }
    if(y + pRadius >= BOX_BOTTOM) {
      vspeed *= -1;
      y = BOX_BOTTOM - pRadius - 1;
    }
  }
  
  void draw() {
    ellipseMode(RADIUS);
    colorMode(HSB);
    fill(subst == 0 ? PCOLOUR_1 : PCOLOUR_2, 180, 230);
    noStroke();
    ellipse((float)x, (float)y, (float)pRadius, (float)pRadius); // convert everything to float (because Processing is weird)
  }
}

void settings() {
  size(WINDOW_SIZE, round(0.75 * WINDOW_SIZE));
}

void setup() {
  frameRate(FRAME_RATE);
  
  BOX_LEFT = floor(BOX_LEFT_REL * width);
  BOX_RIGHT = ceil(BOX_RIGHT_REL * width);
  BOX_TOP = floor(BOX_TOP_REL * height);
  BOX_BOTTOM = round(BOX_BOTTOM_REL * height);
  TEXT_LEFT = floor(TEXT_LEFT_REL * width);
  TEXT_TOP = ceil(TEXT_TOP_REL * height);
  
  font = loadFont("DejaVuSansMono-24.vlw");
  
  paused = true; // pause after restart
  
  // apply settings
  pCount = SET_PCOUNT;
  pSpeed = (float)SET_PSPEED / 3;
  pRadius = SET_PRADIUS;
  
  // initialize particles
  particles = new ArrayList<Particle>();
  for(int i = 0; i < pCount / 2; i++) { // substance 1
    particles.add(new Particle(0, 0, 0.5, 0, 1));
  }
  for(int i = 0; i < pCount / 2; i++) { // substance 2
    particles.add(new Particle(1, 0.5, 1, 0, 1));
  }
}

void draw() {
  background(0); // erase previous frame
  
  stroke(80);
  strokeWeight(1);
  line(BOX_LEFT + (BOX_RIGHT - BOX_LEFT)/2, BOX_TOP, BOX_LEFT + (BOX_RIGHT - BOX_LEFT)/2, BOX_BOTTOM);

  // update, draw and count particles
  int cLeft1 = 0, cLeft2 = 0, cRight1 = 0, cRight2 = 0;
  for(Particle particle : particles) {
    if(!paused) particle.update();
    particle.draw();
    
    if(particle.x < BOX_LEFT + (BOX_RIGHT - BOX_LEFT)/2) {
      if(particle.subst == 0) {
        cLeft1++;
      } else {
        cLeft2++;
      }
    } else {
      if(particle.subst == 0) {
        cRight1++;
      } else {
        cRight2++;
      }
    }
  }
  
  // draw box
  rectMode(CORNERS);
  noFill();
  stroke(255);
  strokeWeight(3);
  rect(BOX_LEFT, BOX_TOP, BOX_RIGHT, BOX_BOTTOM);
  
  // draw number of particles in each half
  textFont(font, TEXT_SIZE + 3);
  textAlign(BOTTOM, LEFT);
  colorMode(HSB);
  
  fill(PCOLOUR_1, 180, 230);
  text(" " + cLeft1, BOX_LEFT, BOX_TOP - 12);
  fill(PCOLOUR_2, 180, 230);
  text("       " + cLeft2, BOX_LEFT, BOX_TOP - 12);
  fill(255);
  text("     +     = " + (cLeft1 + cLeft2), BOX_LEFT, BOX_TOP - 12);
  
  fill(PCOLOUR_1, 180, 230);
  text(" " + cRight1, BOX_LEFT + (BOX_RIGHT - BOX_LEFT)/2, BOX_TOP - 12);
  fill(PCOLOUR_2, 180, 230);
  text("       " + cRight2, BOX_LEFT + (BOX_RIGHT - BOX_LEFT)/2, BOX_TOP - 12);
  fill(255);
  text("     +     = " + (cRight1 + cRight2), BOX_LEFT + (BOX_RIGHT - BOX_LEFT)/2, BOX_TOP - 12);
  
  // draw settings
  textFont(font, TEXT_SIZE);
  textAlign(TOP, LEFT);
  fill(255);
  text(LNG_PCOUNT + ": " +
            (setSelected == 0 ? ("[" + SET_PCOUNT + "]") : (" " + SET_PCOUNT)) + "\n" + // draw brackets around value if selected
      LNG_PSPEED + ": " +
            (setSelected == 1 ? ("[" + SET_PSPEED + "]") : (" " + SET_PSPEED)) + "\n" +
      LNG_PRADIUS + ": " +
            (setSelected == 2 ? ("[" + SET_PRADIUS + "]") : (" " + SET_PRADIUS)) + "\n" +
      "\n" +
      LNG_SETTINGS + "\n" +
      (paused ? LNG_UNPAUSE : LNG_PAUSE) + "\n" +
      LNG_APPLY, TEXT_LEFT, TEXT_TOP);
}

void keyPressed() {
  switch(key) {
    case KEY_PAUSE:
      pause();
      break;
    case KEY_APPLY:
      restart();
      break;
    default:
      switch(keyCode) {
        case LEFT: case RIGHT: case UP: case DOWN:
          changeSettings(keyCode);
          break;
      }
  }
}

void changeSettings(int dir) {
  // update based on key press
  if(dir == UP) {
    setSelected = (setSelected + 3 - 1) % 3;
  }
  if(dir == DOWN) {
    setSelected = (setSelected + 1) % 3;
  }
  if(dir == LEFT) {
    switch(setSelected) {
      case 0:
        SET_PCOUNT -= 2;
        break;
      case 1:
        SET_PSPEED--;
        break;
      case 2:
        SET_PRADIUS--;
        break;
    }
  }
  if(dir == RIGHT) {
    switch(setSelected) {
      case 0:
        SET_PCOUNT += 2;
        break;
      case 1:
        SET_PSPEED++;
        break;
      case 2:
        SET_PRADIUS++;
        break;
    }
  }
  
  // ...
  if(SET_PCOUNT <= 0) {
    SET_PCOUNT = 2;
  }
  if(SET_PSPEED <= 0) {
    SET_PSPEED = 1;
  }
  if(SET_PRADIUS <= 0) {
    SET_PRADIUS = 1;
  }
}

void pause() {
  paused = paused ? false : true;
}

void restart() {
  setup();
}