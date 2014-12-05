/*
 Comp50/EE93 - MMD
 Group #2
 Patient Monitor
 */

#include <SPI.h>
#include <WiFi.h>

IPAddress ip(10, 3, 13, 204); // CHANGE THIS
char ssid[] = "EECS";  // Only for proof-of-concept
int status = WL_IDLE_STATUS;
WiFiServer server(80);

void setup(){
  // Turn on Serial
  Serial.begin(9600);
  while(!Serial);

  // Setup WiFi Server
  if(WiFi.status() == WL_NO_SHIELD){
    Serial.println("WiFi shield not present");
    while(true);
  }
  while(status != WL_CONNECTED){
    Serial.print("Attempting to connect to SSID: ");
    Serial.println(ssid);
    status = WiFi.begin(ssid);
    delay(10000);
  }
  WiFi.config(ip);  // Set static IP address
  server.begin();
  Serial.print("IP Address: ");
  Serial.println(WiFi.localIP());

  // Setup 1kHz timer
  cli();
  TCCR1A = 0;
  TCCR1B = 0;
  TCNT1 = 0;
  OCR1A = 1999;
  TCCR1B |= (1 << WGM12);
  TCCR1B |= (1 << OCIE1A);
  TIMSK1 |= (1 << OCIE1A);
  sei();
}

const int ECG_PIN = A0;
const int PULSE_PIN = A1;
const int TEMPERATURE_PIN = A2;
const int SAMPLE_RATE =  100;
const int SLOW_FACTOR = 10;
const int SLOW_RATE = SAMPLE_RATE / SLOW_FACTOR;

static int timerFlag = 0; // How many times has the timer fired since it was last checked?
float temperature = 0; // 1-second temperature average
int temperatureArray[SLOW_RATE]; // stores last 100 temperature data points
int counter = 0; // index of largest array (up to 999)
int reading = 0; // dummy for analogRead()
int ECGArray[SAMPLE_RATE]; // stores last 1000 ECG data points
int pulseArray[SLOW_RATE]; // stores last 100 pulse data points

void loop(){
  WiFiClient client = server.available();
  if(client.connected()){
    //Serial.println("Hit!");
    sendData(client);
  }
  if(timerFlag > 0){
    //if(timerFlag > 10){
      //Serial.println(timerFlag);
    //}
    readData();
  }
}

void readData(){
  // reset timer flag
  timerFlag--;

  // wrap counter
  if(counter >= SAMPLE_RATE){
    counter = counter % SAMPLE_RATE;
  }

  // always read ECG
  ECGArray[counter] = analogRead(ECG_PIN);

  // only read temperature and pulsee sometimes
  if((counter % SLOW_FACTOR) == 0){
    // temperature
    temperature *= SLOW_RATE;
    temperature -= temperatureArray[counter/SLOW_FACTOR];
    temperatureArray[counter/SLOW_FACTOR] = analogRead(TEMPERATURE_PIN);
    temperature += temperatureArray[counter/SLOW_FACTOR];
    temperature /= SLOW_RATE;

    // pulse
    pulseArray[counter/SLOW_FACTOR] = analogRead(PULSE_PIN);
  }

  // increment counter
  counter++;
}

void sendData(WiFiClient client){
  client.flush();
  client.println("HTTP/1.1 200 OK");
  client.println("Content-Type: text/html");
  client.println("Connnection: close");
  client.println();
  client.print("{\"ECG\":[");
  int i = 0;
  String ecg = "";
  for(i = 0; i < SAMPLE_RATE-1; i++){
    ecg += String(ECGArray[i]);
    ecg += ",";
    //client.print(ECGArray[i]);
    //client.print(",");
  }
  client.print(ecg);
  client.print(ECGArray[SAMPLE_RATE-1]);
  client.print("],\"Pulse\":[");
  for(i = 0; i < SLOW_RATE-1; i++){
    client.print(pulseArray[i]);
    client.print(",");
  }
  client.print(pulseArray[SLOW_RATE-1]);
  client.print("],\"Temp\":");
  client.print(temperature);
  client.println("}");
  client.flush();
  client.stop();
}

ISR(TIMER1_COMPA_vect){
  timerFlag++;
}



