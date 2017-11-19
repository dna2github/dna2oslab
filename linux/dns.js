const {Buffer} = require('buffer');
const dgram = require('dgram');
const fs = require('fs');

class DNSQueryPacket {
   constructor() {}

   load_config(filename) {
      const bydefault = {
         server: '8.8.8.8',
         port: 53
      };
      try {
         let text = fs.readFileSync(filename || '/etc/resolv.conf').toString().split('\n');
         for (let i = 0, n = text.length; i<n; i++) {
            if (/^\s*#\s*nameserver/.test(text[i])) {
               continue; // skip comment line
            }
            text[i] = /nameserver\s+(.+)/.exec(text[i]);
            if (!text[i]) continue;
            text[i] = text[i][1].split(':');
            if (text[i].length > 1) {
               return {
                  server: text[i][0],
                  port: parseInt(text[i][1])
               };
            } else {
               return {
                  server: text[i][0],
                  port: 53
               };
            }
         }
      } catch (e) {
      }
      return bydefault;
   }

   build(hostname) {
      /* header(12) body(n+2) question(4)*/
      let id = process.pid % 65536, p = 0;
      let raw = Buffer.alloc(12+hostname.length+2+4);
      p = raw.writeUInt16BE(id, p);
      p = raw.writeUInt16BE(0x0100, p);
      // q_count = 1
      p = raw.writeUInt16BE(0x0001, p);
      p = raw.writeUInt16BE(0x0000, p);
      p = raw.writeUInt32BE(0x00000000, p);
      hostname.split('.').forEach((x) => {
         p = raw.writeUInt8(x.length, p);
         p += raw.write(x, p, x.length, 'ascii');
      });
      p = raw.writeUInt8(0, p);
      // q_type T_A = 0x0001
      p = raw.writeUInt16BE(0x0001, p);
      // q_class INTERNET = 0x0001
      p = raw.writeUInt16BE(0x0001, p);
      return raw;
   }

   parse_name(buf, offset) {
      let p, hostname = [];
      while(buf[offset] !== 0 && offset < buf.length) {
         p = buf[offset];
         hostname.push(buf.slice(offset+1, offset+1+p).toString('ascii'));
         offset += p+1;
      }
      return hostname.join('.');
   }

   parse_record(buf, offset) {
      let obj = null;
      if (buf[offset] == 0xc0) {
         let name = this.parse_name(buf, buf[offset+1]);
         let type = buf.readUInt16BE(offset+2);
         let klass = buf.readUInt16BE(offset+4);
         let ttl = buf.readUInt32BE(offset+6);
         let rdata_len = buf.readUInt16BE(offset+10);
         let rdata = null;
         offset += 12;
         if (rdata_len) {
            rdata = buf.slice(offset, offset+rdata_len);
            offset += rdata_len;
         }

         switch(type) {
            case 1:
            obj = {
               offset,
               name,
               ipv4: rdata[0] + '.' + rdata[1] + '.' + rdata[2] + '.' + rdata[3]
            };
            break;
            case 5:
            obj = {
               offset,
               name,
               cname: this.parse_name(rdata, 0)
            }
            break;
         }
      }
      if (!obj) {
         obj = { offset };
      }
      return obj;
   }

   parse(buf) {
      let addresses = [];
      let p = 12;
      while (buf[p] !== 0) p++;
      p += 5;
      let a_count = buf.readUInt16BE(6);
      for (let i=a_count; i>=0; --i) {
         p = this.parse_record(buf, p);
         if (p.ipv4) {
            addresses.push(p.ipv4);
         }
         p = p.offset;
      }
      return addresses;
   }

   lookup(hostname, server, port) {
      let packet = this;
      if (!server) {
         server = packet.load_config();
         port = server.port;
         server = server.server;
      }
      if (!port) {
         port = 53;
      }
      let sock = dgram.createSocket('udp4');
      let buf = packet.build(hostname);
      let len = buf.length;
      return new Promise((resolve, reject) => {
         sock.on('message', (m ,r) => {
            sock.close();
            let addresses = packet.parse(m);
            if (addresses.length) {
               resolve(addresses);
            } else {
               reject();
            }
            packet = null;
         });
         sock.on('error', (err) => {
            sock.close();
            reject(err);
         });
         sock.sendto(buf, 0, buf.length, port, server);
      });
   }
}

new DNSQueryPacket().lookup('www.google.com').then((x) => console.log(x), (err) => {});
