/*
  Stores data onto micro SD card; serves data from Arduino Mega (yes, as a web server)
  Author: M. Chow
*/

#include <WiFi.h>
#include <SD.h>

File file;
char ssid[] = "YOUR_NETWORK_SSID_HERE";     //  your network SSID (name) 
char pass[] = "YOUR_NETWORK_PASSWORD_HERE";  // your network password
int status = WL_IDLE_STATUS;     // the Wifi radio's status
WiFiServer server(80);

void setup() {
  // Initialize the serial connection. Open serial monitor in IDE to view temps
  Serial.begin(9600);
  while (!Serial) {
    ; // wait for serial port to connect. Needed for Leonardo only
  }
  
  // check for the presence of the shield:
  if (WiFi.status() == WL_NO_SHIELD) {
    Serial.println("WiFi shield not present"); 
    // don't continue:
    while(true);
  } 
  
  // Set up using micro SD card
  // See http://arduino.cc/en/Tutorial/ReadWrite for example
  Serial.println("Setting up the SD card...");
  pinMode(10, OUTPUT);
  if (!SD.begin(4)) {
    Serial.println("SD card setup failed!");
    return;
  }
  Serial.println("SD card setup successful!");
  
  // aAtempt to connect to Wi-fi network:
  while ( status != WL_CONNECTED) { 
    Serial.print("Attempting to connect to WPA SSID: ");
    Serial.println(ssid);
    // Connect to WPA/WPA2 network:    
    status = WiFi.begin(ssid, pass);

    // wait 10 seconds for connection:
    delay(10000);
  }
   
  // Successfully connected: start web server
  Serial.println("You're connected to the network");
  printCurrentNet();
  printWifiData();
  server.begin();
}

void loop() {
  // Generate a random number between 1 - 100 and save the number to the SD card
  long reading = random(1, 100);
  file = SD.open("data.txt", FILE_WRITE);
  if (file) {
    file.println(reading);
    file.close();
    Serial.println("Saved data to data file!");
  }
  else {
    Serial.println("Error opening the data file!");
  }
  
  // Largely taken from http://arduino.cc/en/Tutorial/WiFiWebServer
  // Listen for incoming clients
  WiFiClient client = server.available();
  if (client) {
    Serial.println("A new client has connected to server");
    // An http request ends with a blank line
    boolean currentLineIsBlank = true;
    while (client.connected()) {
      if (client.available()) {
        char c = client.read();
        Serial.write(c);
        if (c == '\n' && currentLineIsBlank) {
          client.println("HTTP/1.1 200 OK");
          client.println("Content-Type: text/html");
          client.println("Connection: close");
          client.println();
          client.println("<!DOCTYPE HTML>");
          client.println("<html><head><title>Data</title></head><body>");
          
          // Print out all the data in the data (text) file
          file = SD.open("data.txt");
          if (file) {
            while (file.available()) {
              client.println(file.read());
              client.println("<br/>");
            }
            file.close();
          }
          else {
            client.println("<p>Could not open data file!</p>");
          }
          client.println("</body></html>");
          break;
        }
        if (c == '\n') {
          currentLineIsBlank = true;
        }
        else if (c != '\r') {
          currentLineIsBlank = false;
        }
      }
    }
    // Close the connection:
    client.stop();
    Serial.println("client disonnected");
  }
  
  delay(10000);
}

void printWifiData() {
  // print your WiFi shield's IP address:
  IPAddress ip = WiFi.localIP();
  Serial.print("IP Address: ");
  Serial.println(ip);
  Serial.println(ip);
  
  // print your MAC address:
  byte mac[6];  
  WiFi.macAddress(mac);
  Serial.print("MAC address: ");
  Serial.print(mac[5],HEX);
  Serial.print(":");
  Serial.print(mac[4],HEX);
  Serial.print(":");
  Serial.print(mac[3],HEX);
  Serial.print(":");
  Serial.print(mac[2],HEX);
  Serial.print(":");
  Serial.print(mac[1],HEX);
  Serial.print(":");
  Serial.println(mac[0],HEX);
}

void printCurrentNet() {
  // print the SSID of the network you're attached to:
  Serial.print("SSID: ");
  Serial.println(WiFi.SSID());

  // print the MAC address of the router you're attached to:
  byte bssid[6];
  WiFi.BSSID(bssid);    
  Serial.print("BSSID: ");
  Serial.print(bssid[5],HEX);
  Serial.print(":");
  Serial.print(bssid[4],HEX);
  Serial.print(":");
  Serial.print(bssid[3],HEX);
  Serial.print(":");
  Serial.print(bssid[2],HEX);
  Serial.print(":");
  Serial.print(bssid[1],HEX);
  Serial.print(":");
  Serial.println(bssid[0],HEX);

  // print the received signal strength:
  long rssi = WiFi.RSSI();
  Serial.print("signal strength (RSSI):");
  Serial.println(rssi);

  // print the encryption type:
  byte encryption = WiFi.encryptionType();
  Serial.print("Encryption Type:");
  Serial.println(encryption,HEX);
  Serial.println();
}

