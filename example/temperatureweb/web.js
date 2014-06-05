// Initialization of Express framework
var express = require('express');
var bodyParser = require('body-parser');
var validator = require('validator'); // See documentation at https://github.com/chriso/validator.js
var app = express();
app.use(bodyParser());
app.set('title', 'Temperature Data Store');

// MongoDB initialization
var mongoUri = process.env.MONGOLAB_URI || process.env.MONGOHQ_URL || 'mongodb://localhost/medical';
var mongo = require('mongodb');
var db = mongo.Db.connect(mongoUri, function(error, databaseConnection) {
  db = databaseConnection;
});

app.get('/', function(request, response) {
  response.set('Content-Type', 'text/html');
  response.send("<h1>Temperature Data Store</h1>");
});

// Record temperature
app.post('/submit', function(request, response) {
  var temperature = parseFloat(request.body.temperature);
  if (validator.isFloat(temperature)) {
    var toInsert = {
      "temperature": temperature,
      "created_at": Date.now()
    };
    db.collection('temperatures', function(er, collection) {
      var id = collection.insert(toInsert, function(err, saved) {
        if (err) {
          response.send(500)
        } else if (!saved) {
          response.send(500);
        } else {
          response.send(200);
        }
      });
    });
  }
  else {
    response.send("Temperature data was not submitted successfully");
  }
});

// Get all recorded temperatures in JSON format
app.get('/data.json', function(request, response) {
  // Enabling cross-origin resource sharing (CORS)
  // See http://stackoverflow.com/questions/11181546/node-js-express-cross-domain-scripting
  response.header("Access-Control-Allow-Origin", "*");
  response.header("Access-Control-Allow-Headers", "X-Requested-With");

  db.collection('temperatures', function(er, collection) {
    collection.find().sort({"created_at":1}).toArray(function(err, docs) {
      response.send(JSON.stringify(docs));
    });
  });
});

// Web application runs on port 5000 locally
// Oh joy! http://stackoverflow.com/questions/15693192/heroku-node-js-error-web-process-failed-to-bind-to-port-within-60-seconds-of
app.listen(process.env.PORT || 5000);

