const http = require('http');

const server = http.createServer((req, res) => {
    res.writeHead(200, { 'Content-Type': 'text/plain' });
    res.end('HELLO FROM ORACLE SERVER!');
    console.log(`Request received from ${req.socket.remoteAddress}`);
});

server.listen(80, '0.0.0.0', () => {
    console.log('Server running at http://0.0.0.0:80/');
});

server.on('error', (e) => {
    console.error("SERVER ERROR:", e);
});
