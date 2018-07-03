const path = require('path');
const fs = require('fs');
const solc = require('solc');

const formulasPath = path.resolve(__dirname, 'contracts', 'Inbox.sol');
const source = fs.readFileSynce(inboxPath, 'utf8');

console.log(solc.compile(source, 1));