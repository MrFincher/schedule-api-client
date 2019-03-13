# schedule-api-client
A client for a json schedule api

Contents
--------
Right now this project only consists of
  * a very basic part for downloading the json data from the api
  * josn decoding into an algebratic data type using the aeson library
  * processing of the received data
    ..* combining overlaping events
    ..* removing unwanted parts
    ..* converting lecturer and room shorthands to full/ descriptive names
    ..* filtering the events by date
  * a temporary Show instance for events for debuging purposes
    
Future plans
------------
I intend to extend this project by adding
  * a frontend, probably web based
