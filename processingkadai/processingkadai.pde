int state = 0;  
int startTime;   
int i = 0;

int score = 0;
int circleX, circleY;
int circleR = 40;   // これは使わなくなるけど一応残してある
float totalReactionTime = 0;
int hitCount = 0;

int gamestartTime;
int gameDuration = 30000;   

int circleSpawnTime;
IntList avgReactionHistory = new IntList();  

PFont font;

// --- ポリゴンの頂点を保持するリスト ---
int[][] poly;

void setup(){
  size(600,600);
  font = createFont("MS Gothic", 32); 
  textFont(font);
  textAlign(CENTER, CENTER);
  startTime = millis();  
}

void draw(){
  background(255);
  
  if(state == 0){  
    fill((i) % 255, (i+100) % 255, (i+200) % 255);  
    textSize(48);
    text("反射神経テスト",width/2,height/2 - 140);
    
    fill((i) % 255, (i+80) % 255, (i+160) % 255);
    textSize(38);
    text("S:スタート",width/2,height/2 - 20);
    
    fill((i) % 255, (i+140) % 255, (i+240) % 255);
    textSize(38);
    text("C:スコア",width/2,height/2 + 30);
    
    fill((i) % 255, (i+160) % 255, (i+40) % 255);
    textSize(38);
    text("ESC:リセット",width/2,height/2 + 80);
    
    i = i+3;
    
  }else if(state == 1){  
    int elapsed = millis() - startTime;
    float sec = elapsed / 1000.0;
    int remain = 3 - floor(sec);
    
    if(remain >= 1){
      fill(0);
      textSize(48);
      text(remain,width/2,height/2);
    }else if(sec < 4.1){
      fill(#FF0000);
      textSize(48);
      text("START!",width/2,height/2);
    }else{
      spawnCircle();  
      score = 0;
      totalReactionTime = 0; 
      hitCount = 0;          
      gamestartTime = millis();
      state = 2;
    }
    
  }else if(state == 2){  
    int elapsed = millis() - gamestartTime;
    int remainTime = (gameDuration - elapsed) / 1000;
    
    fill(0,200,0);
    drawPolygon(poly);   // ←丸の代わりにポリゴン描画
    
    fill(0);
    textSize(24);
    text("スコア;" + score,width/2,50);
    text("残り時間;" + remainTime,width/2,90);
    
    if(elapsed >= gameDuration){
      if(hitCount > 0){
        int avgReaction = int(totalReactionTime / hitCount);
        avgReactionHistory.append(avgReaction);
      }
      state = 3;
    }

  }else if(state == 3){  
    fill((i) % 255, (i+100) % 255, (i+200) % 255);
    textSize(48);
    text("スコア:" + score,width/2,height/2 - 40);
    
    if (hitCount > 0){
      int avgReaction = int(totalReactionTime / hitCount);  
      fill(#0943D3);
      textSize(32);
      text("平均反応時間;" + avgReaction + " ミリ秒",width/2,height/2 + 10);
    }else{  
      textSize(32);
      text("平均反応時間; ---",width/2,height/2);
    }
    
    textSize(24);
    text("H;ホーム / R;リトライ",width/2,height/2 + 60);
    
  }else if(state == 4){  
    fill(#F77ACC);
    textSize(32);
    text("平均反応時間ランキング", width/2, height/2 - 100);
    
    IntList sorted = avgReactionHistory.copy();
    sorted.sort();
    int topN = min(5, sorted.size());
    
    textSize(26);
    for (int j = 0; j < topN; j++){
      text((j+1) + "位: " + sorted.get(j) + " ms", width/2, height/2 - 40 + j*30);
    }
  }
}

void keyPressed() {
  if (key == 'H' || key == 'h'){  
    state = 0;    
  }else if (key == 'R' || key == 'r'|| key == 'S'|| key == 's'){
    startTime = millis();
    state = 1;    
  }else if (key == 'C' || key == 'c'){
    state = 4;    
  }else if (key == ESC){
    key = 0;      
    state = 0;    
  }
}

void mousePressed(){
  if(state == 2){
    if (pointInPolygon(mouseX, mouseY, poly)){  // ←円じゃなく多角形判定
      score++;
      int reaction = millis() - circleSpawnTime;  
      totalReactionTime += reaction;
      hitCount++;
      spawnCircle();  
    }
  }
}

void spawnCircle(){
  circleX = int(random(50, width - 50));
  circleY = int(random(50, height - 50));
  circleSpawnTime = millis();  

  // ポリゴンの形を定義（毎回中心位置で更新）
  poly = new int[][] {
    {circleX, circleY - 20},
    {circleX - 20, circleY},
    {circleX, circleY - 35},
    {circleX - 35, circleY},
    {circleX + 20, circleY - 20}
  };
}

void drawPolygon(int[][] p){
  beginShape();
  for (int i=0; i<p.length; i++){
    vertex(p[i][0], p[i][1]);
  }
  endShape(CLOSE);
}

// --- 点が多角形内にあるかを判定する関数 ---
boolean pointInPolygon(float px, float py, int[][] poly){
  boolean inside = false;
  int n = poly.length;
  for (int i = 0, j = n-1; i < n; j = i++) {
    float xi = poly[i][0], yi = poly[i][1];
    float xj = poly[j][0], yj = poly[j][1];
    
    boolean intersect = ((yi > py) != (yj > py)) &&
      (px < (xj - xi) * (py - yi) / (yj - yi) + xi);
    if (intersect) inside = !inside;
  }
  return inside;
}
