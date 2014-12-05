Tufts University - Fall 2014
CS 50/150 - EE 93/193
Taught by Ming Chow and Ronald Lasser
Mobile Medical Devices

Work by Inbar Fried, Emily Quigley, Cody Chen, Michael Nuzzolo, and Andrew Carp 

A class focused on the development of two medical applications.
Both projects used an Arduino for the hardware and an iPad for the software development.

A special focus was dedicated to understanding the customer's needs and the environment in which
the application would be integrated. These ideas guided the technology design.


--- Project 1 ---

The first project was a mobile thermometer application. The Arduino used a wifi-shield to send data
over a WiFi network to the iPad. The iPad displayed the incoming data as a 10-second average temperature,
a 1-second average temperature, and an instantaneuos temperature. The most practical features of the application
were an Audible/Visual alarm that would inform a caregiver of an alert that required their attention in a very loud
and hectic environment. On the hardware side, the thermistor used to monitor the patient temperature
was attached to the arduino and cased in an armband for convenient and mobile patient monitoring.

The presentation for this project, along with a more detailed description of the application, is available at:
https://docs.google.com/presentation/d/1mfsa-lMTR1hdAjYNuLixzUQNH43TX6MM_pkMeh5EVlY/edit#slide=id.p

--- Project 2 ---

The second project was a mobile patient monitor application. The Arduino was used to transfer information
to the iPad. Due to strict limitations of the Arudino and WiFi shield, only the temperature data was successfully
sent over the network. The ECG, Pulse, SPO2, and Blood Pressure data was simulated. The primary focus
of our design was to implement a patient monitor that would emphasize only a select set of important
data and features from existing patient monitors. This focus was driven by the desire to simplify the very complex
existing patient monitors and provide a simple and intuitive mobile supplement to the exsiting monitors.
The main features of this application include:
	- Customizable view
	- Manually configurable alarm system (only implemented for temperature)
	- Intelligent (basic machine learning) alarm system (only implemented for temperature)
	- In-app iMessages
	- Audible and visual alarms (only implemented for temperature)

The presentation for this project, along with a more detailed description of the application, is available at:
https://docs.google.com/presentation/d/10rSxnAQ6rR1_1o65u20obx_YM7kUoeOEL6GebVTrobg/edit#slide=id.p
