# Solidity Financial
### Familiar MS Excel Finance Formulas on the Blockchain

#### _IMPORTANT: This project uses a method of approximation for calculating interest (explained below). It serves as an interim tool for financial calculation until Solidity supports fixed point numbers._

After trying to code some basic financial contracts in solidity I found that any calculation related to compound interest was incredibliy hard to calculate with Solidity. Coding a simple amortizing loan was impossible for many payment periods due to integer overflows while trying to raise a fraction to a large exponent. I found a way to approximate these large fractional exponent values from [this Stackoverflow](https://ethereum.stackexchange.com/questions/10425/is-there-any-efficient-way-to-compute-the-exponentiation-of-a-fraction-and-an-in) post and have used this method to re-implement the Microsoft Excel financial functions in Solidity.

The goal of this contract is to simplify the creation of prototype financial contracts without having to dig too deeply into the current limitations of Solidity.

**Initial Setup & Testing:**
```
npm i 
npm run test
```

**Compile & Deployment**
1. Create an [Infura](https://infura.io/) account to create your API endpoint
2. Export the 12 word wallet seed phrase from a wallet that has funds on the desired network
3. Add a `secret.js` file to your project root and include the following:
```
export default {
  mnemonic: '<your twelve word wallet mnemonic to deploy the contract from>',
  infuraApi: 'https://<network-name>.infura.io/<your-api-key>'
}
```
4. Run these scripts:
```
node compile.js
node deploy.js
```

## Formulas

### `=FV (rate, nper, pmt, [pv], [type])`


### `=PMT (rate, nper, pv, [fv], [type])`


### `=IPMT (rate, per, nper, pv, [fv], [type])`


### `=PPMT (rate, per, nper, pv, [fv], [type])`
### 
