#include "HX711.h"
#include <PID_v1.h>
HX711 scale;


float FRECUENCIA = 0.1; // 1 Hz default


float units;

int t = 400; // hardcodeado para microsteps, es el ancho de pulso, 640 es para /32 microstep
int max_1cm = 600/3; //200, son steps para una vuelta
int max_5cm = 5*600/3; //200*5 son steps para cinco vueltas

// 200 steps para 360 grados
// 360 grados hacen una vuelta, que en el tornillo es 0.6 cm
//

// DEFINICIONES DE SETUP
const int heartPin = A1;
const int scale_clk = 18;
const int scale_data = 19;
int calibratee = 0;
double gap = 0;

double TARGET_FREQ_STEPS = FRECUENCIA*2*max_1cm; // Steps por segundo para completar 1 compresion

// SENSOR: ECG
int heartValue = 0; // medicion analogica del sensor biometrico
//volatile int fasea = 0;
//volatile int faseb = 0;

// SENSOR: ENCODER
const int faseA = 3; // fase A encoder
const int faseB = 2; // fase B encoder
long zero_factor = 0; // offset de peso de fábrica para el sensor de peso
volatile int encoder = 0; // valor final del encoder en este ciclo (pulsos)
int last_encoder = 0;
int lastencoder = 0; // para guardar el pulso anterior de encoder en medio de las compresiones
int aState; // medicion actual encoder
int aLastState; // medicion encoder del ciclo anterior
int fasB = 0;
int steps = 0; //steps reales del motor
int degree = 0; // angulo del motor
int fasea = 0;
int faseb = 0;
int pulses = 0;
int last_pulse = 0;
int pulses_per_step = 0;
int revoluciones = 0;
int fin_carrera = 0;
double delta_encoder = 0;
int start_encoder = 0; //se debe guardar el step del encoder para saber cuando se avanza al siguiente
int zero_steps = 0; // da la posicion de comienzo del encoder en steps para contar hasta l y llegar a los 5 cm
int SENTIDO = 0;


 // SENSOR: CELDAS DE CARGA
float calibration_factor = 45020; //-7050 worked for my 440lb max scale setup
float last_weight = 0;
float last_acum = 0;
float weight_bounce = 0;
float last_weight_bounce = 0;
float weight = 0;
int setupit = 0;
int tick = 1;
float acum_weight = 0;
float working_weight = 0;

unsigned int count;                                       // Rising edge count of LED state
unsigned int lastDebounceTime;      
unsigned int debounceDelay;                               // Delay time
int aux_pulsos = 0;
int aux_encoder = 0;


//CONTROL: PID
double t_delay = 1;
double next_freq = 0;
double frequency = 0;
double elapsed = 0;
int pid_tick = 0;
int saved_encoder = 600;
double factor_delta = (200/saved_encoder);

//Define Variables we'll be connecting to
double Setpoint = TARGET_FREQ_STEPS; // avanzar 1 step por check del encoder
double Input, Output;
unsigned long start_time = micros();

//Define the aggressive and conservative Tuning Parameters
double aggKp=4000, aggKi=200, aggKd=1000; // aggKp=4, aggKi=0.2, aggKd=1;
double consKp=1000, consKi=50, consKd=500;

//Specify the links and initial tuning parameters
PID cprPID(&frequency, &next_freq, &Setpoint, consKp, consKi, consKd, DIRECT); // se controla la frecuencia modificando el tiempo OFF de cada step

// EXECUTION MEASUREMENTS
double exec_start = 0;


void setup() {
  // put your setup code here, to run once:

  pinMode(A1, INPUT); // heart rate monitor
  pinMode(2, INPUT); // encoder A
  pinMode(3, INPUT); // encoder B
  pinMode(scale_clk, INPUT); // CLK HX711
  pinMode(scale_data, INPUT); // Data HX711

  pinMode(faseB, INPUT_PULLUP);
  pinMode(3, INPUT_PULLUP);
  attachInterrupt(digitalPinToInterrupt(faseA), encoder_read, CHANGE);

  pinMode(scale_clk, INPUT_PULLUP);
  //attachInterrupt(digitalPinToInterrupt(faseA), loop_helper, CHANGE);

  pinMode(13, OUTPUT); //pin de steps
  pinMode(12, OUTPUT); //pin de dirección
  //pinMode(11, OUTPUT);
  pinMode(10, OUTPUT); //pin de enable (0 V es enable, 5 V es disable)
  pinMode(9, OUTPUT);
  pinMode(8, OUTPUT);

  digitalWrite(13, HIGH);
  digitalWrite(12, HIGH);
  //digitalWrite(11, HIGH);
  digitalWrite(10, HIGH);
  digitalWrite(9, LOW);
  digitalWrite(8, LOW);

  Serial.begin(115200);
  aLastState = digitalRead(faseA);

  scale.begin(scale_data, scale_clk);
  scale.set_scale(calibration_factor); //This value is obtained by using the SparkFun_HX711_Calibration sketch
  scale.tare(); //Assuming there is no weight on the scale at start up, reset the scale to 0

  calibratee = 1;
  Serial.println("Readings:");

  //turn the PID on
  cprPID.SetMode(AUTOMATIC);
  cprPID.SetOutputLimits(100000, 1000000); //500000 porque es el valor que da 1 us de delay mínimo OFF

  count = 0;
  lastDebounceTime = 0;  
  debounceDelay = 50;  
  last_encoder = pulses;
}

void read_weight(){
  weight_bounce = scale.get_units()*0.453592;

// ---------------------- DEBOUNCE ----------------------
  if (abs(weight_bounce - last_weight_bounce)<= 0.1) {            
 
    lastDebounceTime = millis();
    // every time the button state changes, get the time of that change
  } 
   
  if ((millis() - lastDebounceTime) > debounceDelay) {
   
  /*
  *if the difference between the last time the button changed is greater
          *than the delay period, it is safe to say
          *the button is in the final steady state, so set the LED state to
          *button state.
  */
    weight = weight_bounce;
    tick = tick + 1;
    if (weight > 0){
    acum_weight = acum_weight + weight;
    } else {
      acum_weight = acum_weight + abs(weight);
    }
    }
// ------------------- FIN DEBOUNCE ----------------------
  

  if (tick == 3){
    tick = 1;
    acum_weight = abs(weight);
  } 
  working_weight = acum_weight/tick;
 
  
  if ((abs(working_weight - last_weight) > 5)||(abs(weight - last_weight) > 5)||(working_weight > 20)){ // HX711 da hasta 20 kg de medición
    scale.set_scale(calibration_factor); //Adjust to this calibration factor
    working_weight = 0;
    acum_weight = 0;
  }
  
  if ((abs(working_weight - last_weight) <= 0.1)||(abs(weight - last_acum) <= 0.1)){
    setupit += 1;
  }
  if (setupit == 50){
    setupit = 0;
    scale.tare();
    acum_weight = 0;
  }
  
  if (calibratee){
    calibration_factor = 2*calibration_factor - scale.get_units();
    calibratee = 0;
  }
   Serial.print("Reading: ");

   Serial.print(weight_bounce);
   //Serial.print(working_weight, 1); //scale.get_units() returns a float
   Serial.print(" kg"); //You can change this to kg but you'll need to refactor the calibration_factor
   
   Serial.print(" Reading debounced: ");
   Serial.print(weight);
   //Serial.print(working_weight, 1); //scale.get_units() returns a float
   Serial.print(" kg"); //You can change this to kg but you'll need to refactor the calibration_factor

   Serial.print(" Reading average: ");
   Serial.print(working_weight);
   //Serial.print(working_weight, 1); //scale.get_units() returns a float
   Serial.print(" kg"); //You can change this to kg but you'll need to refactor the calibration_factor
   Serial.println();
  last_weight = working_weight;
  last_weight_bounce = weight_bounce;
  last_acum = weight;
}

void move_dir(int dir){
  last_encoder = encoder;
  start_time = micros();
  //delta_encoder = abs((encoder - last_encoder)/3);
  //while (delta_encoder == 0){ // asegurar 1 pulso
    //delta_encoder = abs((encoder - last_encoder)/3);
    if (dir == 0){ // forward
      digitalWrite(10, HIGH);
      digitalWrite(12, HIGH); //HIGH ES FORWARD
      digitalWrite(10, LOW);
  
      digitalWrite(13, HIGH);
      delayMicroseconds(t);
      digitalWrite(13, LOW);
      //delayMicroseconds(t);
    } else { //backward
      digitalWrite(10, HIGH);
      digitalWrite(12, LOW); //LOW ES BACKWARD
      digitalWrite(10, LOW);
  
      digitalWrite(13, HIGH);
      delayMicroseconds(t);
      digitalWrite(13, LOW);
      //delayMicroseconds(t);
    }
  //}
}
//
//void loop_helper(){
//  if (revoluciones == 5) {
//    fin_carrera = 1;
//    revoluciones = 0;
//  }
//
//  if (fin_carrera == 1){ // invertir el sentido del movimiento
//    SENTIDO = ~SENTIDO;
//    fin_carrera = 0;
//  }
//
//  delta_encoder = abs((pulses - last_encoder)/3); // mide steps pasados
//  if (abs(encoder - last_encoder) > 500){
//    delta_encoder = 0; // se reinició la cuenta del encoder
//  }
//
//  elapsed = (micros() - start_time);
//
//  frequency = delta_encoder*1000000/elapsed;
//  
//  
//}

void loop() {
  delay(3); // minimo tiempo de ejecucion para que el driver no reclame
  // ----------------------------- DESCOMENTAR PARA LOOP DE CONTROL ------------------------------------

  read_weight();
  heartValue = analogRead(A1);

  if (aux_pulsos > 600){
    aux_pulsos = 0;
  }
  if (abs(aux_encoder) > 600){
    aux_encoder = 0;
  }
  
  //encoder_read(); //YA CUBIERTO POR ISR, SOLO LA DEJO PARA TESTING
  
  if ((abs(millis() - exec_start) >= (500/FRECUENCIA))){
    saved_encoder = encoder;
    encoder = 0;
    pulses = 0;
    exec_start = millis();
    revoluciones++;
  }
  //Serial.println(encoder + pulses);
  
  if (revoluciones == 1) {
    SENTIDO = ~SENTIDO;
    revoluciones = 0;
  }

  delta_encoder = abs((encoder - last_encoder))*0.03; // mide steps pasados
  if (abs(encoder - last_encoder) > 300){
    delta_encoder = 0; // se reinició la cuenta del encoder
  }

  elapsed = (micros() - start_time);

  frequency = delta_encoder*1000000/elapsed;


  // --------------- CALCULAR PID ----------------
  pid_tick++;
  if (pid_tick >0){
    pid_tick = 0;
    gap = Setpoint-frequency; //distance away from setpoint
    if (gap > 0){
        if(gap<100)
        {  //we're close to setpoint, use conservative tuning parameters
          cprPID.SetTunings(consKp, consKi, consKd);
        }
        else
        {
           //we're far from setpoint, use aggressive tuning parameters
           cprPID.SetTunings(aggKp, aggKi, aggKd);
        }
    
      cprPID.Compute();

      if (next_freq > 0){
        t_delay = (int) abs((1000000)/(next_freq)); // tiempo de delay de cada step en tiempo off, se calcula como el tiempo entre poteniales órdenes de movimiento de 1 step mínimo
        move_dir(SENTIDO);
        delayMicroseconds(t_delay);
      } 
    } 
  }


  // --------------- FIN CÁLCULO PID -------------------

  

//  print_stats();
  Serial.print(" PULSOS ENCODER: ");
  Serial.print(aux_pulsos);
  Serial.print(" POS ENCODER: ");
  Serial.print(aux_encoder);
  Serial.print(" ECG: ");
  Serial.print(heartValue);
  Serial.println();

}

void print_stats(){
    Serial.println();
    Serial.print("PID OUTPUT: ");
    Serial.print(next_freq);
    Serial.print("  GAP: ");
    Serial.print(gap);
    Serial.print("  SENTIDO: ");
    Serial.print(SENTIDO);
    Serial.print("  DELTA: ");
    Serial.print(delta_encoder);
    Serial.print("  Frequency: ");
    Serial.print(frequency);
    Serial.print("  Delay: ");
    Serial.print(t_delay);
    //Serial.print("  REVOLUCIONES: ");
    //Serial.print(revoluciones);
    Serial.print("  PULSOS: ");
    Serial.print(pulses);
    Serial.print("  ENCODER: ");
    Serial.print(encoder);
    //Serial.print("  EXEC TIME: ");
    //Serial.print(millis() - exec_start);
    Serial.println();
}

void encoder_read() {
  //delay(3); // asegurarse de leer un pulso a la vez

  aState = digitalRead(faseA); // Reads the "current" state of the outputA
  fasB = digitalRead(faseB);
  // If the previous and the current state of the outputA are different, that means a Pulse has occured
  if (aState != aLastState) {
    aux_pulsos++;
    // If the outputB state is different to the outputA state, that means the encoder is rotating clockwise
    if (fasB != aState) {
      aux_encoder++;
      encoder ++; // si de cualquier lado llega a 220 o más tiene 600 pulsos
//      Serial.print("Pulsos transcurridos: ");
//      Serial.print(pulses - last_pulse);
//      Serial.println();
    } else {
      //encoder --;
      pulses++;
      aux_encoder--;
    }

  }
  aLastState = aState; // actualizar estado de la fase A
  pulses = abs(pulses);
  encoder = abs(encoder);


}

void test_step_time(){
  if(Serial.available())
  {
    char temp = Serial.read();
    if(temp == 'z'){
      double i = millis();
      delta_encoder = abs((pulses - last_encoder)/3);
      while (delta_encoder == 0){
        delta_encoder = abs((pulses - last_encoder)/3);
        move_dir(0);
        Serial.println(delta_encoder);
      }
      Serial.println(millis() - i);
    }
    if (temp == 'a'){
      t_delay += 1;
    }
    if (temp == 's'){
      t_delay -= 1;
    }
    if (temp == 'q'){
      t += 1;
    }
    if (temp == 'w'){
      t -= 1;
    }
    Serial.print("T: ");
    Serial.print(t);
    Serial.print("  T_DELAY: ");
    Serial.print(t_delay);
    Serial.println();
    last_encoder = pulses;
  }
}
