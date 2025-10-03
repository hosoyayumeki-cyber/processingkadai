int state = 0;  //0;ホーム 1;カウントダウン 2;ゲーム 3;結果
int startTime;   //カウントダウン開始時間(ms)
int i = 0;

int score = 0;
int circleX, circleY;
int circleR = 40;
float totalReactionTime = 0;
int hitCount = 0;

int gamestartTime;
int gameDuration = 30000;   //　30(ミリ秒)

int circleSpawnTime;

// ゲームごとの平均反応時間を記録するリスト
IntList avgReactionHistory = new IntList();  //平均記録保存用

PFont font;

void setup(){
  size(600,600);
  font = createFont("MS Gothic", 32); 
  textFont(font);
  textAlign(CENTER, CENTER);
  startTime = millis();  //起動時の時間保存
}

void draw(){
  background(255);
  
  if(state == 0){  //ホーム
  
    fill((i) % 255, (i+100) % 255, (i+200) % 255);  //カラフル
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
    
  }else if(state == 1){  //カウントダウン
  
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
      
      spawnCircle();  //最初の円生成
      score = 0;
      totalReactionTime = 0; //リセット
      hitCount = 0;          //リセット
      gamestartTime = millis();
      state = 2;
      
    }
    
  }else if(state == 2){  //ゲーム
  
    int elapsed = millis() - gamestartTime;
    int remainTime = (gameDuration - elapsed) / 1000;
    
    fill(0,200,0);
    ellipse(circleX,circleY,circleR*2,circleR*2);
    
    fill(0);
    textSize(24);
    text("スコア;" + score,width/2,50);
    text("残り時間;" + remainTime,width/2,90);
    
    if(elapsed >= gameDuration){
      
      // ここで平均を計算して保存
      if(hitCount > 0){
        
        int avgReaction = int(totalReactionTime / hitCount);
        avgReactionHistory.append(avgReaction);
        
      }
      
      state = 3;
      
    }

  }else if(state == 3){  //リザルト
  
    fill((i) % 255, (i+100) % 255, (i+200) % 255);
    textSize(48);
    text("スコア:" + score,width/2,height/2 - 40);
    
    if (hitCount > 0){
      
      int avgReaction = int(totalReactionTime / hitCount);  
      
      fill(#0943D3);
      textSize(32);
      text("平均反応時間;" + avgReaction + " ミリ秒",width/2,height/2 + 10);
      
    }else{  //ゼロの時
    
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
      
      /*for文で上から順にtopN件のスコアを表示
        jを0から、topNより小さい間、1つずつ追加。
        height/2 - 40 + j*30で縦に少しずつずらして表示している*/
        
    }
  }
}

void keyPressed() {
  
  if (key == 'H' || key == 'h'){  
    
    state = 0;    //ホーム
    
  }else if (key == 'R' || key == 'r'|| key == 'S'|| key == 's'){
    
    startTime = millis();
    state = 1;    //カウントダウン開始
    
  }else if (key == 'C' || key == 'c'){
    
    state = 4;    //スコア表示
    
  }else if (key == ESC){
    
    key = 0;      //これでprocessingの終了を防いでるらしい
    state = 0;    //ESCで強制ホーム
    
  }else if(key == 'M' || key == 'm'){  //スコアを違法に増やすコード
    if(state == 2){
      score += 999;
    }
  }
}

void mousePressed(){
  
  if(state == 2){
    
    float d = dist(mouseX,mouseY,circleX,circleY);
    
    if (d < circleR){
      
      score++;
      
      int reaction = millis() - circleSpawnTime;  //反応時間
      
      totalReactionTime += reaction;
      hitCount++;
      spawnCircle();  //新しい円の生成
      
    }
  }
}

void spawnCircle(){
  
  circleX = int(random(circleR,width - circleR));
  circleY = int(random(circleR,height - circleR));
  
  circleSpawnTime = millis();  //円を生成した時の時間を記録
  
}
