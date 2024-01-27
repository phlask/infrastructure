//import your handler file or main file of Lambda
let index = require('./index');

//Call your exports function with required params
//In AWS lambda these are event, content, and callback
//event and content are JSON object and callback is a function
//In my example i'm using empty JSON
index.handler( require('./testEvent.json'), //event
    {}, //content
    function(ss,data) {  //callback function with two arguments 
        console.log(data);
    });