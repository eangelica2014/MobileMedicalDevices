#include <SPI.h>
#include <WiFi.h>

// the IP address for the shield:
static IPAddress ip(10, 3, 13, 88);

char ssid[]  = "EECS";      // your network SSID (name) 
char pass[]  = "";          // your network password
int keyIndex = 0;           // your network key Index number (needed only for WEP)

int status = WL_IDLE_STATUS;

WiFiServer server(80);

// global temp vars
float currTemp = 0;
float avg1sTemp = 0;
float avg10sTemp = 0;
int counter = 0;
int tenReached = 0;
float runningAvg = 0;

const int NUM_READINGS = 1000;

int avgCounter = 0;
float averagesArray[10];

void setup() {
  pinMode(A0, INPUT);

  for( int i=0; i < 10; i++ ) {
    averagesArray[i] = 0;
  }

  //Initialize serial and wait for port to open:
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

  Serial.print(("Firmware version: "));
  Serial.println(WiFi.firmwareVersion());

  WiFi.config(ip);

  // attempt to connect to Wifi network:
  while ( status != WL_CONNECTED) { 
    Serial.print("Attempting to connect to SSID: ");
    Serial.println(ssid);
    // Connect to WPA/WPA2 network. Change this line if using open or WEP network:    
    status = WiFi.begin(ssid);

    // wait 10 seconds for connection:
    delay(10000);
  } 
  server.begin();
  // you're connected now, so print out the status:
  printWifiStatus();

  //Initialize analog reference value to 1.1v for higher
  //resolution and better temp range. 
  analogReference(INTERNAL1V1);
  getTemp();
  // Set these averages before we have enough readings
  avg1sTemp = currTemp;
  avg10sTemp = currTemp;
}

void loop() {
  // check if we have a client waiting
  handleClient();  

  getTemp();
  counter++;
  if( counter >= NUM_READINGS ) {
    counter = 0;
    getAverages();
  } 
  delay(1);
}

void getTemp() {
  // Grab analog reading from thermistor
  currTemp = convertToTemp( analogRead( A0 ) ); 
  runningAvg += currTemp / NUM_READINGS; 
}

// Convert 0 to 1023 to a degrees Celcius
float convertToTemp( int reading ) {
  return (((float)reading*1.1) / 1024)*100; 
}

// Calculate our average temperature
void getAverages() {
  // grab our running average, then reset it
  avg1sTemp = runningAvg;
  runningAvg = 0;
  averagesArray[avgCounter] = avg1sTemp;
  // increment or reset the counter
  avgCounter = (avgCounter + 1) % 10;
  if(!tenReached){
    tenReached = (avgCounter == 0);
  }

  // getting 10s average
  avg10sTemp = 0;  
  if(tenReached){
    for( int i=0; i < 10; i++ ) {
      avg10sTemp += averagesArray[i];
    }
    avg10sTemp /= 10;
  }
  else{
    for( int i=0; i < avgCounter; i++ ) {
      avg10sTemp += averagesArray[i];
    }
    if(avgCounter != 0)
      avg10sTemp /= avgCounter;
  }
}

// handle a connection to our IP from iPad
void handleClient() {
  // listen for incoming clients
  WiFiClient client = server.available();
  if (client) {
    Serial.println("new client");
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
          client.print("{");
          client.print("\"currentTemp\":\"");
          client.print(currTemp);
          client.print("\",");
          client.print("\"avg10Temp\":\"");
          client.print(avg10sTemp);
          client.print("\",");
          client.print("\"avg1Temp\":\"");
          client.print(avg1sTemp);
          client.print("\"");
          client.print("}");
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
    Serial.println("client disonnected");
  }
  /*
  else{
    if(counter >= (NUM_READINGS -1)){
      Serial.println("HTTP/1.1 200 OK");
      Serial.println("Content-Type: application/json;charset=utf-8");
      Serial.println("Connection: close");  // the connection will be closed after completion of the response
      Serial.println();
      Serial.print("{");
      Serial.print("\"currentTemp\":\"");
      Serial.print(currTemp);
      Serial.print("\",");
      Serial.print("\"avg10Temp\":\"");
      Serial.print(avg10sTemp);
      Serial.print("\",");
      Serial.print("\"avg1Temp\":\"");
      Serial.print(avg1sTemp);
      Serial.print("\"");
      Serial.print("}");
      Serial.println();
    }
  }
  */
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










