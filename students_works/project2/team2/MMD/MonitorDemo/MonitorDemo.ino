/*
 Comp50/EE93 - MMD
 Group #2
 Patient Monitor Demo
 
 NOTE: does not send real data
 - only reads whether data is present
 */

#include <SPI.h>
#include <WiFi.h>

const int ECG_PIN = 52;
const int PULSE_PIN = 48;
const int TEMP_PIN = 50;
const int SPO2_PIN = 28;
const int BP_PIN = 30;

IPAddress ip(10, 3, 13, 204); // CHANGE THIS
char ssid[] = "EECS";  // Only for proof-of-concept
int status = WL_IDLE_STATUS;
WiFiServer server(80);

void setup(){
  // Turn on Serial
  Serial.begin(9600);
  while(!Serial);
  

  //pinMode(SPO2_PIN, INPUT);
  //pinMode(BP_PIN, INPUT);

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

  //pinMode(ECG_PIN, INPUT_PULLUP);
  //pinMode(PULSE_PIN, INPUT);
  //pinMode(TEMP_PIN, INPUT);

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

static int timerFlag = 0; // How many times has the timer fired since it was last checked?

// 1 = on, 0 = off
int ecgOn = 0;
int pulseOn = 0;
int tempOn = 0;
int spo2On = 0;
int bpOn = 0;

void loop(){
  WiFiClient client = server.available();
  if(client.connected()){
    sendData(client); // Respond to Client
  }
  if(timerFlag > 0){
    readData(); // Update Status
  }
}

void readData(){
  // reset timer flag
  timerFlag--;

  // check everything and update
  ecgOn = digitalRead(ECG_PIN);
  pulseOn = digitalRead(PULSE_PIN);
  tempOn = digitalRead(TEMP_PIN);
  spo2On = digitalRead(SPO2_PIN);
  bpOn = digitalRead(BP_PIN);
}

void sendData(WiFiClient client){
  client.flush();
  // header
  client.println("HTTP/1.1 200 OK");
  client.println("Content-Type: text/html");
  client.println("Connnection: close");
  client.println();
  // JSON data
  client.print("{\"ECG\":");
  client.print(String(ecgOn==0));
  client.print(",\"Pulse\":");
  client.print(String(pulseOn));
  client.print(",\"Temp\":");
  client.print(String(tempOn));
  client.println("}");
  client.flush();
  // close connection
  client.stop();
}

ISR(TIMER1_COMPA_vect){
  timerFlag++;
}




