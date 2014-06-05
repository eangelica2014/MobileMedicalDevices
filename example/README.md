#Overview
This example reads data (e.g., temperature via temperature sensor) from an Arduino and sends it to a web application hosted on a server somewhere.  An iOS app then reads the data from the web application via JSON API.

#Components of This Example
1. Code for Arduino: `wifi_send_data`
2. The web application: `temperatureweb`
3. iOS application: `TemperatureGraphApp-iOS`

#Requirements for Arduino
1. Arduino (using Mega 2560)
2. Arduino Wi-Fi Shield

#Requirements for Web Application
1. Node.js + Express web application framework
2. MongoDB (database)

#Requirements for iOS Application
1. Core Plot for iOS (https://github.com/core-plot/core-plot/wiki)