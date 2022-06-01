import processing.serial.*;
import queasycam.*;
import processing.sound.*;
import ddf.minim.*;
import ddf.minim.ugens.*;

QueasyCam cam;

float angx=0, angy, dang=TWO_PI/360;

PShape s;

PShape caja;
PImage cajaImg;

boolean simonDice;
PImage bombaSimon;
boolean simonDiceCompletado;

boolean mensajeCaja;
PImage cartaCaja;
int led = 0;

boolean movimiento;


PShape lector;


Serial myPort;  // Create object from Serial class
String val;     // Data received from the serial port


float sCamX;
float sCamZ;
float sCamPan;
float sCamTilt;

boolean cambioVentana;

boolean juegoTarjeta;
boolean juegoTarjetaTerminado;
boolean finTarjeta;
PImage cartaEscaner;
boolean mensajeEscaner; 

PShape card;
float hCard;

PShape keypad;

boolean juegoCodigo;

int[] numbers = {-1,-1,-1,-1};
String showNumbers = "";

PFont fontKeyPad;

SoundFile  errorS;
SoundFile  backS;
SoundFile  cardS;
SoundFile  completeS;
SoundFile  loseS;
SoundFile  doorS;
SoundFile  winS;

Minim minim;
AudioOutput out;


boolean inicio;
boolean siguiente;
boolean startGame;

PImage inicioImg;
PImage instruccionesImg;

String [] notas={"C4", "D4", "E4"};

StopWatchTimer sw = new StopWatchTimer();

int segundos;
int minutos;

PImage gameOver;
PImage congratulations;


boolean finJuego;
boolean winGame;

void setup() {
  size(800, 600, P3D);
  
  errorS = new SoundFile(this,"sound/wrong.wav");
  backS = new SoundFile(this,"sound/music2.wav");
  cardS = new SoundFile(this,"sound/scanner.wav");
  completeS = new SoundFile(this,"sound/gameComplete.wav");
  loseS = new SoundFile(this,"sound/lose.wav");
  doorS = new SoundFile(this,"sound/opendoor.wav");
  winS = new SoundFile(this,"sound/win.wav");
  
  cam = new QueasyCam(this);
  cam.sensitivity = 1;
  cam.speed = 2;
  cam.position.x = 255;
  cam.position.y = (height/2)+10;
  cam.position.z = 5;
  perspective(PI/3, (float)width/height, 0.2, 10000);
  
  s = loadShape("model/model.obj");
  
  cajaImg = loadImage("img/caja.jpg");
  caja = createShape(BOX, 15);
  caja.setTexture(cajaImg);
  
  
  cartaCaja = loadImage("img/cartaCaja.png");
  mensajeCaja = false;
  movimiento = true;
  
  pushMatrix();
  rotateY(radians(90));
  bombaSimon = loadImage("img/bomba.png");
  popMatrix();
  
  simonDiceCompletado = false;
  
  String portName = Serial.list()[0]; //change the 0 to a 1 or 2 etc. to match your port
  myPort = new Serial(this, portName, 9600);
  val = "0";
  
  lector = loadShape("lector/model.obj");
  
  cambioVentana = false;
  
  juegoTarjeta = false;
  juegoTarjetaTerminado = false;
  cartaEscaner = loadImage("img/cartaEscaner.png");
  mensajeEscaner = false;
  finTarjeta = false;
  
  card = loadShape("card/keycard.obj");
  hCard = -340;
  
  keypad = loadShape("keypad/model.obj");
  
  juegoCodigo = false;
  
  fontKeyPad = createFont("fuente.TTF", 128);
  textFont(fontKeyPad);
  
 
  minim = new Minim(this);
  out = minim.getLineOut();
  
  inicio = true;
  siguiente = false;
  startGame = false;
  
  inicioImg = loadImage("img/inicio.png");
  instruccionesImg = loadImage("img/controles.png");
  
  segundos = 0;
  minutos = 5;
  
  gameOver = loadImage("img/gameOver.png");
  congratulations = loadImage("img/congratulations.png");
  
  finJuego = false;
  winGame = false;
  
}



void draw() {
  
  background(204);
  cam.position.y = (height/2);
  pushMatrix();
  rotateX(radians(180));
  translate(400,-300);
  scale(250);
  shape(s, 0, 0);
  popMatrix();
  
  
  pushMatrix();
  translate(width/2, height/2+50);    
  shape(caja);  
  popMatrix();
  
  
  if(inicio){
      cam.controllable = false;      
      pushMatrix();
      translate(0, 0, 260);    
      image(inicioImg,width/4, (height/4), 400, 300);
      popMatrix();    
  }
  
  if(siguiente){
      cam.controllable = false;      
      pushMatrix();
      translate(0, 0, 260);    
      image(instruccionesImg,width/4, (height/4), 400, 300);
      popMatrix();    
      println("X: "+mouseX);
      println("Y: "+mouseY);
  }
  
  
  if(startGame){
    startGame();
  }
    
   
}



void startGame(){
  //Lector
  
  pushMatrix();
  rotateX(radians(180));
  rotateY(radians(90));
  translate((width/2)-650, height/2-600,400); 
  scale(20);
  shape(lector, 0, 0);
  popMatrix();
  
  segundos = 60-sw.second();
  minutos = 4-sw.minute();  
  
  if(finJuego) enseñarMensajePerdiste();
  if(winGame) enseñarMensajeGanaste();
  
  if(segundos == 0 && minutos == 0){
    cam.position.x = 530.982;
    cam.position.z = 555.951;
    cam.pan = 4.7202444;           
    cam.tilt = -0.0052360315;
    pushMatrix();
    translate(0, 0, 300);    
    image(gameOver,width/2-65, (height/2)-150, 400, 300);  
    popMatrix();
    
    finJuego = true;  
    backS.stop();
    loseS.play();
  }    
    
  
  
  
  
  //Keypad
  pushMatrix();
  rotateX(radians(180));
  rotateY(radians(-90));
  //z,y,x
  translate(90, -325, -180);
  scale(20);
  shape(keypad, 0, 0);
  popMatrix();
    
  
  if(simonDice)simonDice();
  if(mensajeCaja)enseñarMensajeCarta();
  if(simonDiceCompletado)myPort.write('0'); 
  
  if(juegoTarjeta)lectorTarjeta();
  if(mensajeEscaner)enseñarMensajeEscaner();
  
  if(juegoCodigo)keyPad();
  if(juegoTarjetaTerminado)myPort.write('0'); 
  
  
   if (myPort.available() > 0){  
      val = myPort.readStringUntil('\n');
   } 
   
   try{
     if(val != null  && val != ""){
        led = Integer.parseInt(val.trim());
        hCard = Integer.parseInt(val.trim());
      }
   }catch(Exception e){}
   
   if(led == 1111){
      simonDice = false;
      mensajeCaja = true;   
      simonDiceCompletado = true;
    }
    
    if(finTarjeta){
      mensajeEscaner = true;
    }
    
    interactuar();
    
    if(cambioVentana){
      cam.pan = sCamPan;
      cam.tilt = sCamTilt;
      cambioVentana = false;    
    }
    
    //println(val);
    tiempoRestante();

}

void tiempoRestante(){
    pushMatrix();  
    translate((width/2)+75, (height/2)+10, 245);
    rotateY(radians(-180));
    fill(231, 76, 60);
    textSize(60);
    if(segundos<10){
      text("0"+minutos+":0"+segundos, 0, 0); 
    }else{
      text("0"+minutos+":"+segundos, 0, 0); 
    }
    popMatrix();
}



void enseñarMensajePerdiste(){
  pushMatrix();
  translate(0, 0, 300);    
  image(gameOver,width/2-65, (height/2)-150, 400, 300);  
  popMatrix();
  cam.controllable = false;
}

void interactuar(){
  //Caja
  if(cam.position.x >= 330 && cam.position.x <= 485 && cam.position.z >= -14 && cam.position.z <= 30){
      pushMatrix();  
      translate((width/2), (height/2)+30, -40);
      rotateY(radians(-90));
      fill(255);
      textSize(4);
      text("Pulsa espacio para abrir la caja", 0, 0);  
      popMatrix();
  
      if(keyPressed && movimiento){
         if (key == ' ' && simonDiceCompletado == false){           
           simonDice = true;
           sCamX = cam.position.x;
           sCamZ = cam.position.z;
           sCamPan = cam.pan;
           sCamTilt = cam.tilt;
           
           cam.position.x = 530.982;
           cam.position.z = 555.951;
           cam.pan = 4.7202444;           
           cam.tilt = -0.0052360315;
          
         }else if (key == ' ' && simonDiceCompletado == true){
           mensajeCaja = true;
           sCamX = cam.position.x;
           sCamZ = cam.position.z;
           sCamPan = cam.pan;
           sCamTilt = cam.tilt;
           
           cam.position.x = 530.982;
           cam.position.z = 555.951;
           cam.pan = 4.7202444;
           cam.tilt = -0.0052360315;         
         
         }
      }    
  }
  
  //Tarjeta
  if(cam.position.x >= 360 && cam.position.x <= 450 && cam.position.z >= -240 && cam.position.z <= -150){
    if(simonDiceCompletado && juegoTarjetaTerminado == false){
      pushMatrix();  
      translate((width/2)-40, (height/2)+40, -245);      
      fill(255);
      textSize(4);
      text("Pulsa espacio para pasar la tarjeta", 0, 0);  
      popMatrix();
      
      if(keyPressed && movimiento){
         if (key == ' '){     
            cam.position.x = 404.986;
            cam.position.z = -152.54422;
            cam.pan = -1.5943584;
            cam.tilt = 0.03665194;
            juegoTarjeta = true;
         }
      }  
    }else if (juegoTarjetaTerminado == true){
      pushMatrix();  
      translate((width/2)-40, (height/2)+40, -245);      
      fill(255);
      textSize(4);
      text("Pulsa espacio para repetir la pista", 0, 0);  
      popMatrix();
      
      if(keyPressed && movimiento){
         if (key == ' '){     
            sCamX = cam.position.x;
            sCamZ = cam.position.z;
            sCamPan = cam.pan;
            sCamTilt = cam.tilt;
           
            cam.position.x = 404.986;
            cam.position.z = -152.54422;
            cam.pan = -1.5943584;
            cam.tilt = 0.03665194;
                    
            finTarjeta = true;   
         }
      }  
      
    
    }else{
      pushMatrix();  
      translate((width/2)-25, (height/2)+40, -245);      
      fill(255);
      textSize(4);
      text("Necesitas una tarjeta", 0, 0);  
      popMatrix();
    
    }
  }
  
  //Keypad
  if(cam.position.x >= 230 && cam.position.x <= 280 && cam.position.z <= 10 && juegoCodigo== false){
     pushMatrix();  
      translate((width/2)-216, (height/2), -50);
      rotateY(radians(90));      
      fill(255);
      textSize(4);
      text("Pulsa espacio para introducir el codigo", 0, 0);  
      popMatrix();
      
    if(keyPressed && movimiento){
         if (key == ' '){     
            cam.position.x = 252.20328;
            cam.position.z = -95.50014;
            cam.pan = -3.165155;
            cam.tilt = 0.2984513;
            juegoCodigo = true;
         }
    }
  }

}

void simonDice(){
  myPort.write('1'); 
  
  pushMatrix();  
  translate(0, 0, 300);    
  image(bombaSimon,width/2-65, (height/2)-150, 400, 300);
  cam.controllable = false;
  
  translate(0, 0, 1); 
  //Amarillo
  fill(241, 196, 15);
  ellipse((width/2)+115, (height/2)+81, 29, 30);
  
  //Verde
  fill(46, 204, 113);
  ellipse((width/2)+146, (height/2)+81, 29, 30);
  
  
  //Rojo
  fill(231, 76, 60);
  ellipse((width/2)+178, (height/2)+81, 29, 30);
  
  //println(val);
  
  switch(led){
    case 11:
      fill(252, 243, 207);
      ellipse((width/2)+115, (height/2)+81, 29, 30);
      break;
      
     case 111:
      out.playNote( 0.0, 0.9, new SineInstrument( Frequency.ofPitch( notas[0] ).asHz())); 
      break;
     
     case 22:
        fill(171, 235, 198);      
        ellipse((width/2)+146, (height/2)+81, 29, 30);
        break;
        
        
      case 222:
      out.playNote( 0.0, 0.9, new SineInstrument( Frequency.ofPitch( notas[1] ).asHz())); 
      break;
      
      case 33:
        fill(245, 183, 177);
        ellipse((width/2)+178, (height/2)+81, 29, 30); 
        break;        
        
       case 333:
          out.playNote( 0.0, 0.9, new SineInstrument( Frequency.ofPitch( notas[2] ).asHz())); 
          break;
        
      case 44:
        fill(252, 243, 207);
        ellipse((width/2)+115, (height/2)+81, 29, 30);
        fill(171, 235, 198);      
        ellipse((width/2)+146, (height/2)+81, 29, 30);
        fill(245, 183, 177);
        ellipse((width/2)+178, (height/2)+81, 29, 30);        
        break;
        
        
     case 444:
       errorS.play();
       delay(1000);
       break;
      
  
  }
  popMatrix();

  
}



void enseñarMensajeCarta(){
  pushMatrix();
  translate(0, 0, 300);    
  image(cartaCaja,width/2-65, (height/2)-150, 400, 300);
  cam.controllable = false;
  popMatrix();
}

void enseñarMensajeEscaner(){
  cam.controllable = false;
  pushMatrix();
  translate(0, 0, -200);    
  image(cartaEscaner,(width/2)-34.9, (height/2)-25.1, 75, 56.25);
  popMatrix();
  finTarjeta = false;
}

void enseñarMensajeGanaste(){
  pushMatrix();
  translate(0, 0, 300);    
  image(congratulations,width/2-65, (height/2)-150, 400, 300);  
  popMatrix();
  cam.controllable = false;
}


void lectorTarjeta(){
  long ini = 0;
  long fin = 0;
  long tiempoTotal = 0;
  myPort.write('2');   
  cam.controllable = false;
  pushMatrix();
  rotateZ(radians(90));
  rotateY(radians(-90));
  rotateZ(radians(-90));
  translate(401.5, -240, hCard); 
  scale(350);
  shape(card, 0, 0);
  popMatrix();
  
  println(hCard);
  cardS.stop();
  if(hCard == -300){
    ini = millis();
    cardS.play();
    while(hCard == -300){
        if (myPort.available() > 0){  
          val = myPort.readStringUntil('\n');
         } 
   
       try{
         if(val != null  && val != ""){
            hCard = Integer.parseInt(val.trim());
          }
       }catch(Exception e){}
       
        fin = millis();
        tiempoTotal = (fin-ini)/1000;
        
        if(tiempoTotal == 3){
        
          cardS.stop();           
          //cam.controllable = true;            
          completeS.play();
          delay(300);          
           
          sCamX = cam.position.x;
          sCamZ = cam.position.z;
          sCamPan = cam.pan;
          sCamTilt = cam.tilt;
          
          finTarjeta = true;  
          juegoTarjeta = false;
          juegoTarjetaTerminado = true;
                    
        }
    }
    
  }else{
    println("MAL");
      
  }

}

void keyPad(){
  cam.controllable = false;
  pushMatrix();  
  translate((width/2)-218, (height/2) + 7.5, -85);
  rotateY(radians(90));
  fill(0);
  rect(0, 0, 20, 5);
  popMatrix();
  
  pushMatrix();  
      translate((width/2)-216, (height/2), -50);
      rotateY(radians(90));      
      fill(255);
      textSize(4);
      //text("Pulsa suprimir para salir", 0, 0);  
      popMatrix();
  
  println(numbers);
  mostrarNumeros();
  if(keyPressed){
    switch(key){
      case '0':
        for(int i=0; i<4; i++){
          if(numbers[i] == -1){
            numbers[i] = 0;
            break;
          }
        }
        delay(100);
        break;
       
      
      case '1':
        for(int i=0; i<4; i++){
          if(numbers[i] == -1){
            numbers[i] = 1;
            break;
          }
        }
        delay(100);
        break;
        
       case '2':
        for(int i=0; i<4; i++){
          if(numbers[i] == -1){
            numbers[i] = 2;
            break;
          }
        }
        delay(100);
        break;
        
       case '3':
        for(int i=0; i<4; i++){
          if(numbers[i] == -1){
            numbers[i] = 3;
            break;
          }
        }
        delay(100);
        break;
        
       case '4':
        for(int i=0; i<4; i++){
          if(numbers[i] == -1){
            numbers[i] = 4;
            break;
          }
        }
        delay(100);
        break;
        
       case '5':
        for(int i=0; i<4; i++){
          if(numbers[i] == -1){
            numbers[i] = 5;
            break;
          }
        }
        delay(100);
        break;
        
       case '6':
        for(int i=0; i<4; i++){
          if(numbers[i] == -1){
            numbers[i] = 6;
            break;
          }
        }
        delay(100);
        break;
        
       case '7':
        for(int i=0; i<4; i++){
          if(numbers[i] == -1){
            numbers[i] = 7;
            break;
          }
        }
        delay(100);
        break;
        
       case '8':
        for(int i=0; i<4; i++){
          if(numbers[i] == -1){
            numbers[i] = 8;
            break;
          }
        }
        delay(100);
        break;
        
       case '9':
        for(int i=0; i<4; i++){
          if(numbers[i] == -1){
            numbers[i] = 9;
            break;
          }
        }
        delay(100);
        break;
        
       
       case BACKSPACE:
          cam.controllable = true;
          juegoCodigo = false;
        
    }
  
  }
  
  if(numbers[3]!=-1 && key == ENTER && keyPressed){
    if(numbers[0] == 2 && numbers[1] == 4 && numbers[2] == 1 && numbers[3] == 5){
       cam.controllable = true;
       cam.position.x = 530.982;
       cam.position.z = 555.951;
       cam.pan = 4.7202444;           
       cam.tilt = -0.0052360315;
       pushMatrix();
       translate(0, 0, 300);    
       image(congratulations,width/2-65, (height/2)-150, 400, 300);  
       popMatrix();
    
       winGame = true;  
       backS.stop();
       winS.play();
       delay(2000);
       doorS.play();
      
        
        
    }else{
        errorS.play();
        for(int i=0; i<4; i++) numbers[i] = -1;   
        delay(3000);
    }
  }
  
}


void mostrarNumeros(){  
  
  showNumbers = "";
  for(int i=0; i<4; i++){
    if(numbers[i] != -1) showNumbers += numbers[i] ;
  }
  
  pushMatrix();  
  translate((width/2)-216, (height/2) + 11.5, -88);
  rotateY(radians(90));
  fill(255);
  textSize(6);
  text(showNumbers, 0, 0);  
  popMatrix();
  
  fill(0, 408, 612, 816);
  

}

void mouseClicked(){  
    
  //Cerrar simon dice
  if(mouseX>5 && mouseX<45 && mouseY>8 && mouseY<50 && simonDice == true){
    simonDice = false;
    cam.controllable = true;
    cam.position.x = sCamX ;
    cam.position.z = sCamZ;    
    cambioVentana = true;
    myPort.write('0');
   }
  
  
  //Cerrar carta simon dice
  if(mouseX>34 && mouseX<72 && mouseY>37 && mouseY<81 && mensajeCaja == true){
    mensajeCaja = false;
    cam.controllable = true;
    cam.position.x = sCamX ;
    cam.position.z = sCamZ;
    cambioVentana = true;
    }
    
    
   //Cerrar carta escaner
  if(mouseX>12 && mouseX<51 && mouseY>45 && mouseY<86 && mensajeEscaner == true){
    mensajeEscaner = false;
    cam.controllable = true;
    cam.position.x = sCamX ;
    cam.position.z = sCamZ;
    cambioVentana = true;
    }
    
   
   //Cerrar inicio
   if(mouseX>725 && mouseX<765 && mouseY>515 && mouseY<555 && inicio == true){
      inicio = false;
      siguiente = true;
    }
    
    //Cerrar instrucciones
   if(mouseX>306 && mouseX<480  && mouseY>500 && mouseY<555 && siguiente == true){
      siguiente = false;
      startGame = true;
      backS.play();  
      sw.start();
      cam.controllable = true;
    }
    
    
}

class SineInstrument implements Instrument{
  Oscil wave;
  Line  ampEnv;

  SineInstrument(float frequency){
    // Oscilador sinusoidal con envolvente
    wave   = new Oscil( frequency, 0, Waves.SINE );
    ampEnv = new Line();
    ampEnv.patch( wave.amplitude );
  }

  // Secuenciador de notas
  void noteOn(float duration){
    // Amplitud de la envolvente
    ampEnv.activate( duration, 0.5f, 0 );
    // asocia el oscilador a la salida
    wave.patch( out );
  }

  // Final de la nota
  void noteOff(){
    wave.unpatch( out );
  }
}
