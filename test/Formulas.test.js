const assert = require('assert');
const ganache = require('ganache-cli');
const Web3 = require('web3');
// Creates instance of web3 and plugs in ganache as provider
const provider = ganache.provider();
const web3 = new Web3(provider);
const { interface, bytecode } = require('../compile');

let accounts;
let financialFormulas;

beforeEach(async () => {
  accounts = await web3.eth.getAccounts();

  financialFormulas = await new web3.eth.Contract(JSON.parse(interface))
    .deploy({ data: bytecode })
    .send({ from: accounts[0], gas: '1000000'})

  financialFormulas.setProvider(provider);
});

describe('FinancialFormulas', () => {
  it('deploys a contract', () => {
    assert.ok(financialFormulas.options.address);
  });
  it('has default message', async () => {
    const message = await financialFormulas.methods.testMessage().call();
    assert.equal(message, 'testing');
  });
});
