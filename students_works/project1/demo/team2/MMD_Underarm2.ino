/* Comp50/EE93 - MMD
  Group #2
  Underarm Thermometer
*/

#include <SPI.h>
#include <WiFi.h>

IPAddress ip(10, 3, 14, 116); // CHANGE THIS
char ssid[] = "EECS";  // Only for proof-of-concept
int status = WL_IDLE_STATUS;
WiFiServer server(80);

int INPUT_PIN = A5; // CHANGE THIS
const int MAX_SAMPLES = 1000;
const int MAX_SECS = 10;
double secs[MAX_SECS];
double samples[MAX_SAMPLES];
int currentSec = 0;
int currentSample = 0;
double oneAve = 0;
double tenAve = 0;
double sample = 0;

void setup(){
  Serial.begin(9600);
  while(!Serial){
    continue;
  }

  Serial.println("Started");
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

  //WiFi.config(ip);  // Set static IP address
  
  server.begin();
  
  Serial.print("IP Address: ");
  Serial.println(WiFi.localIP());
}

void loop(){
  WiFiClient client = server.available();
  if(client){
    if(client.connected()){
        client.flush();
        client.println("HTTP/1.1 200 OK");
        client.println("Content-Type: text/html");
        client.println("Connnection: close");
        client.println();
        client.print("{\"current\":");
        client.print(sample);
        client.print(",\"one\":");
        client.print(oneAve);
        client.print(",\"ten\":");
        client.print(tenAve);
        client.println("}");
        client.flush();
    }
    client.stop();
  }
  updateTemps();
}

void updateTemps(){
  sample = analogRead(INPUT_PIN);
  oneAve = oneAve * (double) MAX_SAMPLES;
  oneAve = oneAve - samples[currentSample] + sample;
  oneAve = oneAve / (double) MAX_SAMPLES;
  samples[currentSample] = sample;
  currentSample = currentSample + 1;
  if(currentSample >= MAX_SAMPLES){
    currentSample = currentSample - MAX_SAMPLES;
    tenAve = tenAve * (double) MAX_SECS;
    tenAve = tenAve - secs[currentSec] + oneAve;
    tenAve = tenAve / (double) MAX_SECS;
    secs[currentSec] = oneAve;
    currentSec = currentSec + 1;
    if(currentSec >= MAX_SECS){
      currentSec = currentSec - MAX_SECS;
    }
  }
}

