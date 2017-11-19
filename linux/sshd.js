var fs = require('fs');
// npm install ssh2
var Server = require('ssh2').Server;

new Server({
  hostKeys: [fs.readFileSync('host.key')],
}, function(client) {
  var stream;
  var name;

  client.on('authentication', function(ctx) {
    console.log(ctx.username, ctx.method);
    name = ctx.username;
    return ctx.accept();
    // return ctx.reject(['keyboard-interactive']);
    ctx.prompt('password:', function retryPrompt(answers) {
      if (answers.length === 0)
        return ctx.reject(['keyboard-interactive']);
      console.log(answers[0]);
      ctx.accept();
    });
  }).on('ready', function() {
    var rows;
    var cols;
    var term;
    client.once('session', function(accept, reject) {
      accept().once('pty', function(accept, reject, info) {
        console.log('pty', name, info);
        rows = info.rows;
        cols = info.cols;
        term = info.term;
        accept && accept();
      }).on('window-change', function(accept, reject, info) {
        console.log('window-change', name, info);
        rows = info.rows;
        cols = info.cols;
        if (stream) {
          stream.rows = rows;
          stream.columns = cols;
          stream.emit('resize');
        }
        accept && accept();
      }).on('exec', function (accept, reject, info) {
        console.log(info);
        reject();
      }).once('shell', function(accept, reject, info) {
        stream = accept();
        stream.name = name;
        stream.rows = rows || 24;
        stream.columns = cols || 80;
        stream.isTTY = true;
        stream.setRowMode = function () {};
        stream.on('error', function (err) { console.error(err); });
        stream.on('data', function (r) {
           //console.log(r, rows, cols);
           switch(r[0]) {
           case 0x7f:
              stream.write('\b \b');
              return;
           case 0x1b: // 0x1b 0x4f 0x41/42/43/44 ABCD ^v<>
           }
           if (r[0] === 3) {
              stream.end();
              return;
           } else if (r[0] == 13 || r[0] == 9 || (r[0] >= 32 && r[0] < 127)) {
              var p = 0, q = 0, n = r.length;
              for(var i = 0; i<n; i++) {
                 q = i;
                 if (r[i] === 0x0d) {
                    stream.write(r.slice(p, q).toString());
                    // TODO spawn process e.g. ls -l
                    stream.write(r.slice(q, q+1).toString());
                    stream.write('\n');
                    p = q + 1;
                 }
              }
              if (p <= q) {
                 stream.write(r.slice(p, q+1).toString());
              }
           }
        });
      });
    });
  }).on('end', function() {
    if (stream !== undefined) {
       stream.end();
    }
  }).on('error', function(err) {
    // Ignore errors
  });
}).listen(2222, function() {
  console.log('Listening on port ' + this.address().port);
});
