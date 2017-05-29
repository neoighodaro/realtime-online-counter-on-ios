var Pusher = require('pusher');
let express = require('express');
let bodyParser = require('body-parser');
let fs = require('fs');

let app = express();

let pusher = new Pusher({
  appId: 'PUSHER_ID',
  key: 'PUSHER_KEY',
  secret: 'PUSHER_SECRET',
  cluster: 'PUSHER_CLUSTER',
  encrypted: true
});

app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: false }));

app.post('/update_counter', function(req, res) {
  let counterFile = './count.txt';

  fs.readFile(counterFile, 'utf-8', function(err, count) {
    count = parseInt(count) + 1;
    fs.writeFile(counterFile, count, function (err) {
      pusher.trigger('counter', 'new_user', {count:count});
      res.json({count:count});
    });
  });
});

app.use(function(req, res, next) {
    let err = new Error('Not Found');
    err.status = 404;
    next(err);
});

module.exports = app;

app.listen(4000, function(){
  console.log('App listening on port 4000!')
})