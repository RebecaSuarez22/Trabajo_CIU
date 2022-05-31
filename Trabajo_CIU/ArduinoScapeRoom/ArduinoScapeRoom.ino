char val;

const int ledAmarillo = 11;
const int ledVerde = 10;
const int ledRojo = 9;

const int botonAmarillo = 7;
const int botonVerde = 6;
const int botonRojo = 5;

int nivel;

int estaAmarillo = HIGH;
int estaVerde= HIGH;
int estaRojo= HIGH;

int secuencia[6] = {1,2,3,2,1,2};
int pulsado[6] = {0,0,0,0,0,0};

boolean error;

const int Trigger = 14;   
const int Echo = 15;   

int res;

boolean estadoSimonDice;


void setup() {
  Serial.begin(9600);   
  pinMode(ledAmarillo , OUTPUT);  
  pinMode(ledVerde , OUTPUT);  
  pinMode(ledRojo , OUTPUT);  

  pinMode(botonAmarillo, INPUT);
  pinMode(botonVerde, INPUT);
  pinMode(botonRojo, INPUT);

  error = false;
  nivel=1;
  estadoSimonDice = false;

  //for(int i=0; i<6; i++) secuencia[i] = random(1,3);
  //for(int i=0; i<6; i++) pulsado[i] = 0;

  pinMode(Trigger, OUTPUT); 
  pinMode(Echo, INPUT);  
  digitalWrite(Trigger, LOW);
  res = 0;
  val = 0;
}
 
void loop(){

  if (Serial.available()){ 
     val = Serial.read();
  }

  if(val == '0') estadoSimonDice = false;
  if(val == '1')estadoSimonDice = true;
  if(val == '2')startCardScanner();  
  
  if(estadoSimonDice) startSimonDice();
}


void startCardScanner(){
  long t; //timepo que demora en llegar el eco
  long d; //distancia en centimetros

  digitalWrite(Trigger, HIGH);
  delayMicroseconds(10);          //Enviamos un pulso de 10us
  digitalWrite(Trigger, LOW);
  
  t = pulseIn(Echo, HIGH); //obtenemos el ancho del pulso
  d = (t/59);             //escalamos el tiempo a una distancia en cm

  if(d>20)d=20;
  if(d<1)d=0;

  res = map(d,0,20,-345,-275);
  Serial.println(res);
  delay(100);          
  
}



void startSimonDice(){  
  
  if(nivel == 1){  
        dificultad(2);      
        if(error){
          for(int i=0; i<5;i++){
            digitalWrite(ledAmarillo , HIGH);   
            digitalWrite(ledRojo , HIGH);  
            digitalWrite(ledVerde , HIGH);  
            delay(500);                   
            digitalWrite(ledAmarillo , LOW);  
            digitalWrite(ledRojo , LOW);  
            digitalWrite(ledVerde , LOW);  
            delay(500); 
          }
          error = false;
       }else{                   
          nivel = 2;          
       }     
   }

   if(nivel == 2){  
        dificultad(4);      
        if(error){
          for(int i=0; i<5;i++){
            digitalWrite(ledAmarillo , HIGH);   
            digitalWrite(ledRojo , HIGH);  
            digitalWrite(ledVerde , HIGH);  
            delay(100);                   
            digitalWrite(ledAmarillo , LOW);  
            digitalWrite(ledRojo , LOW);  
            digitalWrite(ledVerde , LOW);  
            delay(100); 
          }
          error = false;
       }else{
          Serial.println("Pasamos de nivel");
          nivel = 3;
       }
     
   }

   if(nivel == 3){  
        dificultad(6);      
        if(error){
          //Serial.println(444);
          //Serial.println(44); 
          for(int i=0; i<5;i++){
            //Serial.println(44); 
            digitalWrite(ledAmarillo , HIGH);   
            digitalWrite(ledRojo , HIGH);  
            digitalWrite(ledVerde , HIGH);  
            delay(100);   
            Serial.println(0);                  
            digitalWrite(ledAmarillo , LOW);  
            digitalWrite(ledRojo , LOW);  
            digitalWrite(ledVerde , LOW);  
            delay(100); 
          }
          error = false;
       }else{
          estadoSimonDice = false;   
          Serial.println(1111);     
          delay(1000);          
          Serial.println(0);         
          nivel = 0; 
       }
     
   }
  
}




void encenderLed(int i){

  switch(i){
      case 1:
        Serial.println(111); 
        delay(10);
        Serial.println(11); 
        digitalWrite(ledAmarillo , HIGH);   
        delay(1000);                   
        digitalWrite(ledAmarillo , LOW);          
        break;

      case 2:
        Serial.println(222); 
        delay(10);
        Serial.println(22);
        digitalWrite(ledVerde , HIGH);   
        delay(1000);                   
        digitalWrite(ledVerde , LOW);            
        break;

       case 3:
        Serial.println(333); 
        delay(100);
        Serial.println(33); 
        digitalWrite(ledRojo , HIGH);   
        delay(1000);                   
        digitalWrite(ledRojo , LOW);        
        break;

       default:
        Serial.println(0);
        break;
   }
}


void dificultad(int difi){
            
      int count = 0;
      for(int i=0; i<difi;i++){
         encenderLed(secuencia[i]);            
      } 
      encenderLed(0);
      while(count!=difi){         
          if(val == '0'){
            Serial.println("FIN"); 
          }
          estaAmarillo = digitalRead(botonAmarillo);
          estaVerde = digitalRead(botonVerde);
          estaRojo = digitalRead(botonRojo);
          
           if (estaAmarillo == LOW) {   
              Serial.println(111); 
              delay(100);        
              Serial.println(11); 
              digitalWrite(ledAmarillo , HIGH);   
              delay(500);                   
              digitalWrite(ledAmarillo , LOW);   
              pulsado[count] = 1;            
              
              if(secuencia[count] != 1){
                Serial.println(444); 
                delay(100); 
                Serial.println(44);
                error = true;
                break;
              }
              estaAmarillo == HIGH;
              count++;
           }
    
          if (estaVerde == LOW) {
              Serial.println(222); 
              delay(100); 
              Serial.println(22); 
              digitalWrite(ledVerde , HIGH);   
              delay(500);                   
              digitalWrite(ledVerde , LOW);  
              pulsado[count] = 2;
              
              if(secuencia[count] != 2){
                Serial.println(444); 
                delay(100); 
                Serial.println(44);
                error = true;
                break;
              }

              count++; 
          }
    
          if (estaRojo == LOW) {
              Serial.println(333); 
              delay(100); 
              Serial.println(33); 
              digitalWrite(ledRojo , HIGH);   
              delay(500);                   
              digitalWrite(ledRojo , LOW);  
              pulsado[count] = 3;
               
              if(secuencia[count] != 3){
                Serial.println(444); 
                delay(100); 
                Serial.println(44);
                error = true;
                break;
              }
              count++;
          } 
        
        
      } 
        




}
