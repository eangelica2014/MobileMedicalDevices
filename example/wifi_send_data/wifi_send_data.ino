/*
  Temperature Sensor for Arduino Mega
  Authors: M. Chow and R. Lasser
  Revision: 2.4

  Connection instructions:
  * Black wire in GND pin on analog side of board
  * Red wire (data) in analog pin A3
  * Turn on serial monitor to view temperatures
*/

#include <WiFi.h>

int temperatureSensorPin = 3; // the analog pin 3 on Arduino Mega
                        // the resolution is 10 mV / degree centigrade
                        
// Initialize Wi-Fi client
// More information at http://arduino.cc/en/Tutorial/WiFiWebClientRepeating
WiFiClient client;
byte serverip[] = { XX1, XX1, XX3, XX4 }; // the server's IP address

// Wi-Fi setup taken from example code ConnectWithWPA
char ssid[] = "YOUR_SSID_HERE";     //  your network SSID (name) 
char pass[] = "PASSWORD_HERE";  // your network password
int status = WL_IDLE_STATUS;     // the Wifi radio's status

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
  
 // attempt to connect to Wifi network:
  while ( status != WL_CONNECTED) { 
    Serial.print("Attempting to connect to WPA SSID: ");
    Serial.println(ssid);
    // Connect to WPA/WPA2 network:    
    status = WiFi.begin(ssid, pass);

    // wait 10 seconds for connection:
    delay(10000);
  }
   
  // you're connected now, so print out the data:
  Serial.println("You're connected to the network");
  printCurrentNet();
  printWifiData();
}

void loop() {
  float temperature;
  String data;

  // Get the voltage reading from the temperature sensor
  int reading = analogRead(temperatureSensorPin);
  
  /* 
    Convert voltage conversion to temperature
    0.1931 & 11.4759 constants from approximate temperature measurements of room temperature
    of 64 degrees F and body temperature (under arm) of 97.6 degrees F.
    Arduino Mega does a-to-d conversion from volts to int in range of 0 to 1023
  */ 
  temperature = 0.1931 * (float)reading + 11.4759; // convert to degrees F
  
  // DEBUGGING: print out the temperature to serial monitor
  Serial.print(temperature);
  Serial.println(" degrees F");
  char tempFBuffer[6];
  dtostrf(temperature, 6, 2, tempFBuffer);
  data = "temperature=" + String(tempFBuffer);
  
  // Make connection to web application and post data
  client.stop();
  if (client.connect(serverip, PORT_NUMBER)) {
    client.println("POST /submit HTTP/1.1");
    client.println("Host: XX1.XX2.XX3.XX4:PORT_NUMBER");
    client.println("User-Agent: ArduinoWiFi/1.1");
    client.println("Connection: close");
    client.println("Content-Type: application/x-www-form-urlencoded;");
    client.print("Content-Length: ");
    client.println(data.length());
    client.println();
    client.println(data);
    Serial.println("Data successfully sent!");
  }
  else {
    Serial.println("Whoops, something went wrong!");
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

