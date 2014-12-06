#include <WiFi.h>

// Set the IP address
IPAddress ip(10, 3, 14, 177);

// Set pins for reading
int ledPin = 13; // LED connected to digital pin 13
int outPin1 = 3;
int outPin2 = 5;
int inPin1 = 2;
int inPin2 = 4;
int val1 = 0;     // variable to store the read value
int val2 = 0;

// Initialize serving var
char ssid[] = "EECS";

int status = WL_IDLE_STATUS;

WiFiServer server(80);
WiFiClient client;

void setup()
{
  pinMode(ledPin, OUTPUT);      // sets the digital pin 13 as output
  pinMode(inPin1, INPUT);
  pinMode(inPin2, INPUT);
  pinMode(outPin1, OUTPUT);
  pinMode(outPin2, OUTPUT);
  
  Serial.begin(9600);
  
  // check for presence of shield
  if (WiFi.status() == WL_NO_SHIELD) {
    Serial.println("No shield available");
    // don't continue
    while(true);
  }
  
  WiFi.config(ip);
  
  // attempt to connect to Wifi network
  while (status != WL_CONNECTED) {
    Serial.print("Attempting to connect to SSID: ");
    Serial.println(ssid);
    // connect to WPA2 network
    status = WiFi.begin(ssid);
    
    delay(2000);
  }
  server.begin();
  printWifiStatus();

}


void loop()
{
  digitalWrite(outPin1, HIGH);
  digitalWrite(outPin2, HIGH);
  val1 = digitalRead(inPin1);
  val2 = digitalRead(inPin2);
  
  delay(200);

  // listen for incoming clients
  client = server.available();
  if (client) {
    //Serial.println("new client");
    // an http request ends with a blank line
    boolean currentLineIsBlank = true;
    while (client.connected()) {
      if (client.available()) {
        char c = client.read();
        Serial.write(c);
        // if you've gotten to the end of the line (received a newline
        // character) and the line is blank, the http request has ended,
        // so you can send a reply
        if (c == '\n' && currentLineIsBlank) {
          // send a standard http response header
          client.println("HTTP/1.1 200 OK");
          client.println("Content-Type: application/json;charset=utf-8");
          client.println("Connection: close");  // the connection will be closed after completion of the response
          client.println();

          client.print("{\"ecg\":\"");
          client.print(!val1);
          client.print("\",\"hr\":\"");
          client.print(!val2);
          client.print("\"}");
          client.println();
           break;
        }
        if (c == '\n') {
          // you're starting a new line
          currentLineIsBlank = true;
        } 
        else if (c != '\r') {
          // you've gotten a character on the current line
          currentLineIsBlank = false;
        }
      }
    }
    // give the web browser time to receive the data
    delay(1);
    
    // close the connection:
    client.stop();
    //Serial.println("client disonnected");
  }
}


void printWifiStatus() {
  // print the SSID of the network you're attached to:
  Serial.print("SSID: ");
  Serial.println(WiFi.SSID());

  // print your WiFi shield's IP address:
  IPAddress ip = WiFi.localIP();
  Serial.print("IP Address: ");
  Serial.println(ip);

  // print the received signal strength:
  long rssi = WiFi.RSSI();
  Serial.print("signal strength (RSSI):");
  Serial.print(rssi);
  Serial.println(" dBm");
}
