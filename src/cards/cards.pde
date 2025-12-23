PFont gbs;
PFont gbl;
PGraphics pg;

int WIDTH = 61;
int HEIGHT = 85;
int STROKE_WIDTH = 1;
int PADDING = 7;
int WIDTH_WITH_STROKE = WIDTH + 1;
int HEIGHT_WITH_STROKE = HEIGHT + 1;

int BACK_PADDING = 8;
int CARD_RADIUS = 11;

void setup() {
  pixelDensity(1);
  size(806, 430, P2D);
  
  pg = createGraphics(806, 430, JAVA2D);

  printArray(PFont.list());
  gbs = createFont("Georgia-Bold", 12);
  gbl = createFont("Georgia-Bold", 48);
} 

String character(int c) {
  if (c == 0) {
    return "A"; 
  } else if (c == 1) {
    return "2"; 
  } else if (c == 2) {
    return "3"; 
  } else if (c == 3) {
    return "4"; 
  } else if (c == 4) {
    return "5"; 
  } else if (c == 5) {
    return "6"; 
  } else if (c == 6) {
    return "7"; 
  } else if (c == 7) {
    return "8"; 
  } else if (c == 8) {
    return "9"; 
  } else if (c == 9) {
    return "10"; 
  } else if (c == 10) {
    return "J"; 
  } else if (c == 11) {
    return "Q"; 
  } else if (c == 12) {
    return "K";
  } else {
    throw new RuntimeException("Bad rank");
  }
}

String suitCharacter(int suit) {
  if (suit == 0) {
    return "♠"; 
  } else if (suit == 1) {
    return "♥"; 
  } else if (suit == 2) {
    return "♦"; 
  } else if (suit == 3) {
    return "♣"; 
  } else {
    throw new RuntimeException("Bad suit");
  }
}

void setSuitColor(int suit) {
  if (suit == 0) {
    pg.fill(0, 0, 0);
  } else if (suit == 1) {
    pg.fill(235, 0, 0);
  } else if (suit == 2) {
    pg.fill(235, 0, 0);
  } else if (suit == 3) {
    pg.fill(0, 0, 0);
  } else {
    throw new RuntimeException("Bad suit");
  }
}

void draw() {
  pg.beginDraw();
  pg.background(0);
  pg.clear();
  
  float sw = 1;
  pg.strokeWeight(sw);

  for (int suit = 0; suit < 4; suit ++) {
    String suit_char = suitCharacter(suit);
    
    for (int c = 0; c < 13; c++) {
      pg.pushMatrix();
      pg.translate(c*WIDTH_WITH_STROKE, suit*HEIGHT_WITH_STROKE);
  
      pg.fill(255);
      pg.stroke(40);
      pg.rect(0, 0, WIDTH, HEIGHT, CARD_RADIUS);
      
      setSuitColor(suit);
     
      pg.textFont(gbs);
      pg.textAlign(CENTER, CENTER);
      
      for (int i = 0; i < 2; i++) {
        pg.pushMatrix();
    
        pg.translate(WIDTH/2 + STROKE_WIDTH, HEIGHT/2 + STROKE_WIDTH);
        pg.rotate(i * PI);
        
        String letter = character(c);
    
        pg.text(letter, -WIDTH/2 + PADDING, -HEIGHT/2 + PADDING);
        pg.text(suit_char, -WIDTH/2 + PADDING, -HEIGHT/2 + PADDING + 10);
    
        pg.popMatrix();
      }  
      
      if (c == 0) {
        pg.textFont(gbl);
        pg.text(suit_char, WIDTH/2 + STROKE_WIDTH, HEIGHT/2 + STROKE_WIDTH - 3);
      }
  
      pg.popMatrix();
    }
  }
  
  // Render back
  pg.pushMatrix();
  pg.translate(0*WIDTH_WITH_STROKE, 4*HEIGHT_WITH_STROKE);
  
  // Draw card
  pg.fill(255);
  pg.stroke(40);
  pg.rect(0, 0, WIDTH, HEIGHT, CARD_RADIUS);
  
  // Draw inlay
  pg.fill(225, 95, 95);
  pg.noStroke();
  pg.rect(BACK_PADDING, BACK_PADDING, WIDTH-2*BACK_PADDING+1, HEIGHT-2*BACK_PADDING+1, 6);

  pg.popMatrix();
  
  background(0);
  image(pg, 0, 0);
  
  pg.save("../cards.png");
  noLoop();
}
