int state = 0;

float px = 350, py = 250;
float vx = 0, vy = 0;

float accel = 0.5;
float friction = 0.88;
float gravity = 0.7;
float jumpForce = -12;

float pR = 20;

int n = 8;

float[] ex = new float[n];
float[] ey = new float[n];
float[] evx = new float[n];
float[] evy = new float[n];

float eR = 15;

int lives = 3;

int startTime;
int duration = 30;

boolean canHit = true;
int lastHitTime = 0;
int hitCooldownMs = 800;

void setup() {
  size(700, 350);
  frameRate(60);
  resetGame();
}

void resetGame() {
  px = width/2;
  py = 250;
  vx = 0;
  vy = 0;
  lives = 3;

  for (int i = 0; i < n; i++) {
    ex[i] = random(eR, width - eR);
    ey[i] = random(eR, height - eR);
    evx[i] = random(-3, 3);
    evy[i] = random(-3, 3);

    if (abs(evx[i]) < 1) evx[i] = 2;
    if (abs(evy[i]) < 1) evy[i] = -2;
  }
}

void draw() {
  background(240);

  if (state == 0) drawStart();
  else if (state == 1) runGame();
  else if (state == 2) drawGameOver();
  else if (state == 3) drawWin();
}

void drawStart() {
  fill(0);
  textAlign(CENTER);
  textSize(32);
  text("Dodge & Survive", width/2, 120);
  textSize(18);
  text("Press ENTER to Start", width/2, 180);
}

void runGame() {
  int elapsed = (millis() - startTime) / 1000;
  int remaining = duration - elapsed;

  if (remaining <= 0) state = 3;

  if (keyPressed) {
    if (keyCode == RIGHT) vx += accel;
    if (keyCode == LEFT) vx -= accel;
  }

  vx *= friction;
  vy += gravity;

  px += vx;
  py += vy;

  float groundY = 300;

  if (py > groundY) {
    py = groundY;
    vy = 0;
  }

  px = constrain(px, pR, width - pR);

  fill(0, 200, 150);
  ellipse(px, py, pR*2, pR*2);

  for (int i = 0; i < n; i++) {
    ex[i] += evx[i];
    ey[i] += evy[i];

    if (ex[i] > width - eR || ex[i] < eR) evx[i] *= -1;
    if (ey[i] > height - eR || ey[i] < eR) evy[i] *= -1;

    fill(255, 0, 0,200);
    ellipse(ex[i], ey[i], eR*2, eR*2);

    float d = dist(px, py, ex[i], ey[i]);

    if (d < pR + eR && canHit) {
      lives--;
      canHit = false;
      lastHitTime = millis();
    }
  }

  if (!canHit && millis() - lastHitTime > hitCooldownMs) {
    canHit = true;
  }

  if (lives <= 0) state = 2;

  fill(0);
  textSize(16);
  textAlign(LEFT);
  text("Lives: " + lives, 20, 25);
  text("Time: " + remaining, 20, 45);
}

void drawGameOver() {
  fill(0);
  textAlign(CENTER);
  textSize(32);
  text("GAME OVER", width/2, 140);
  textSize(18);
  text("Press R to Restart", width/2, 200);
}

void drawWin() {
  fill(0);
  textAlign(CENTER);
  textSize(32);
  text("YOU WIN!", width/2, 140);
  textSize(18);
  text("Press R to Restart", width/2, 200);
}

void keyPressed() {
  if (state == 0 && keyCode == ENTER) {
    state = 1;
    startTime = millis();
  }

  if (state == 1 && key == ' ' && vy == 0) {
    vy = jumpForce;
  }

  if ((state == 2 || state == 3) && (key == 'r' || key == 'R')) {
    resetGame();
    state = 0;
  }
}
