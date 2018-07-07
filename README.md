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

### `=FV (rate, nper, pmt, [pv], [loanType])`
**Status: pmt param not working yet. Only works for lump sums**
- rate - The interest rate per period.
- nper - The total number of payment periods.
- pmt - The payment made each period. Must be entered as a negative number.
- pv - [optional] The present value of future payments. If omitted, assumed to be zero. Must be entered as a negative number.
- loanType - [optional] When payments are due. 0 = end of period, 1 = beginning of period. Default is 0

### `=PV (rate, nper, pmt, [fv], [loanType])`
**Status: same as FV**
- rate - The interest rate per period.
- nper - The total number of payment periods.
- pmt - The payment made each period.
- fv - [optional] A cash balance you want to attain after the last payment is made. If omitted, assumed to be zero.
- loanType - [optional] When payments are due. 0 = end of period, 1 = beginning of period. Default is 0.

### `=PMT (rate, nper, pv, [fv], [loanType])`
**Status: Happy path working**
- rate - The interest rate for the loan.
- nper - The total number of payments for the loan.
- pv - The present value, or total value of all loan payments now.
- fv - [optional] The future value, or a cash balance you want after the last payment is made. Defaults to 0 (zero).
- loanType - [optional] When payments are due. 0 = end of period. 1 = beginning of period. Default is 0.


### `=IPMT (rate, per, nper, pv, [fv], [loanType])`
**Status: Happy path working**
- rate - The interest rate per period.
- per - The payment period of interest.
- nper - The total number of payment periods.
- pv - The present value, or total value of all payments now.
- fv - [optional] The cash balance desired after last payment is made. Defaults to 0.
- loanType - [optional] When payments are due. 0 = end of period. 1 = beginning of period. Default is 0.

### `=PPMT (rate, per, nper, pv, [fv], [loanType])`
**Status: Reuses IPMT. Needs a refactor.**
- rate - The interest rate per period.
- per - The payment period of interest.
- nper - The total number of payments for the loan.
- pv - The present value, or total value of all payments now.
- fv - [optional] The cash balance desired after last payment is made. Defaults to 0.
- type - [optional] When payments are due. 0 = end of period. 1 = beginning of period. Default is 0.

## TODO
- NPV
- IRR
- RATE
- NPER
- Figure out how to work w/ signed ints for negative values of pmt in the FV formula
- Explore if amortization schedules in-contract makes sense
- Add loanType helper
- Error checking & handling
