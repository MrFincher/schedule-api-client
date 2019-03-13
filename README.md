# schedule-api-client
A client for a json schedule api

Contents
--------
Right now this project only consists of
  * a very basic part for downloading the json data from the api
  * json decoding into an algebratic data type using the aeson library
  * processing of the received data
    * combining overlaping events (using a Semigroup instance)
    * converting lecturer and room shorthands to full/ descriptive names
    * removing unwanted parts
    * filtering the events by date
  * a temporary Show instance for events for debuging purposes
    
Future plans
------------
I intend to extend this project by adding
  * a frontend, probably web based, either:
    * static pages provided using a web server library like scotty, servant or snap
    * dynamic pages writen in purescript which get the processed data from a rest api

  * new features regarding data processing
  * extensive configurability (maybe using dhal-lang)
