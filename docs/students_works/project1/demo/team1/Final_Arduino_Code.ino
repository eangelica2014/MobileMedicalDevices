/*
Fully commented Arduino Code


First off, this code is pretty sloppy. It relies heavily on global variables
because there is no way to pass variables through to the function called
in an interupt. 

The few things that really confused me were in the "loop" function. These
were mostly related to serving data, but here are some key things that 
confused me early on:

    - The IP address is set in advance
    - The EECS network is set in advance
    - Despite setting these vars, it still takes time to connect
    - This connection is actually between the iPad and the Arduino **through**
          the network
    - Giving information to iPad, once the connection is made, is as easy as
          saying "client.print(your message)"


Here are the functions we use:


void setup();
    Setup essentially starts the program. It runs "flash" every millisecond
    using something called an interupt.
    Setup also starts the logic that "serves" our data. 

void flash();
    Called each millisecond. This organizes our logic for sampling temperature
    it takes a running average throughout the second. Each second another avg
    is added to a 10secondqueue

int AverageOfQueue(); Takes the average of a queue

void loop();
    Mostly organizes the logic for serving to the web, but prints out global
    variables related to temperature

void printWifiStatus();
    Prints out a wifi status

*/


#include <QueueArray.h>
#include <FlexiTimer2.h>
#include <SPI.h>
#include <WiFi.h>


/* Variables Used for Taking Temperature */

int i; //a counter for one second
long oneSecondAVG; //used for one second running sum
long tenSecondAVG; //holds the ten second average after the average of the queue
long battery;
long printOne; //the printable onesecond average
long printTen; //the printable tensecond average
long printCurrent; //the printable current average
QueueArray <long> queue;
QueueArray <long> tempQueue;

/* End of Variables used for Taking Temperature */

/* Variables Used for Serving Data */

IPAddress ip(10, 3, 14, 177);
char ssid[] = "EECS";
int status = WL_IDLE_STATUS;
WiFiServer server(80);
WiFiClient client;

/* End of Variables Used for Serving Data */

float temperature = 0; // I doubt this does anything, but I haven't checked...

void flash() {
    
//    Serial.println((analogRead(0)*.9034 + 31.074));

    printCurrent = analogRead(0);
    battery = analogRead(1);

    oneSecondAVG = oneSecondAVG + printCurrent;
    i++;


    //since flash is called every millisecond, this happens every second
    if(i == 1000){ 
      
      oneSecondAVG = oneSecondAVG/1000;
      queue.push(oneSecondAVG);
      while(queue.count() > 10){
        queue.pop();
      }
      if(queue.count() == 10){

        tenSecondAVG = AverageOfQueue();

      }
      printOne = oneSecondAVG;
      printTen = tenSecondAVG;

      
      i = 0; //reset i so that we can find out when the next second is!
      oneSecondAVG = 0;
    }
}

//takes the average of a queue... poorly written function as it only works for
//Queues of length 10
int AverageOfQueue(){

    int seconds = 0;
    for(int k = 0; k < 10; k++){
    
        seconds = seconds + queue.front();
        tempQueue.push(queue.pop());
    }
   for(int k = 0; k < 10; k++){
             queue.push(tempQueue.pop());
    }
    return seconds/10;
}


void setup() {
  /* Used for Timer */
  pinMode(0, INPUT);
  pinMode(1, INPUT);

  analogReference(EXTERNAL);
  
  oneSecondAVG = 0;
  tenSecondAVG = 0;
  i = 0;
  FlexiTimer2::set(1, flash);
  FlexiTimer2::start();
  
  /*End of Timer Use */
  
  
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

void loop() {
  float temperature = 0;
  
  // listen for incoming clients
  client = server.available();
  if (client) {
    // an http request ends with a blank line
    boolean currentLineIsBlank = true;
    while (client.connected()) {
      if (client.available()) {
        char c = client.read();

        // if you've gotten to the end of the line (received a newline
        // character) and the line is blank, the http request has ended,
        // so you can send a reply
        if (c == '\n' && currentLineIsBlank) {
          // send a standard http response header
          client.println("HTTP/1.1 200 OK");
          client.println("Content-Type: application/json;charset=utf-8");
          client.println("Connection: close");  // the connection will be closed after completion of the response
          client.println();

          client.print("{\"currentTemp\":\"");
          client.print(printCurrent);
          client.print("\",\"oneTemp\":\"");
          client.print(printOne);
          client.print("\",\"tenTemp\":\"");          
          client.print(printTen);
          client.print("\",\"batteryVolt\":\"");          
          client.print(battery);
          client.print("\"}");
          client.println();
          Serial.println(battery);
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
