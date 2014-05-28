#Overview
This web application:

1. Records temperature, in Fahrenheit (float), sent to it via POST /submit.  Example: `curl -d "temperature=98.6" http://IP_ADDRESS:5000/submit`

2. Returns all submitted temperatures in JSON format via GET /data.json.  Example: `http://IP_ADDRESS:5000/data.json`

#Installation and Running
1. Install all required moduled via `npm install`
2. To run: `node web.js`
