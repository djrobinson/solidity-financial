# solidity-financial

### _IMPORTANT: This project uses a method of approximation for calculating interest (explained below). It serves as an interim tool for financial calculation until Solidity supports fixed point numbers._

After trying to code some basic financial contracts in solidity I found that any calculation related to compound interest was incredibliy hard to come to in Solidity. Coding a simple amortizing loan was impossible for many payment periods due to integer overflows while trying to raise a fraction to a large exponent. I found a way to approximate these large fractional exponent values from [this Stackoverflow](https://ethereum.stackexchange.com/questions/10425/is-there-any-efficient-way-to-compute-the-exponentiation-of-a-fraction-and-an-in) post and have used this method to re-implement the Microsoft Excel financial functions in Solidity.

The goal of this contract is to simplify the creation of prototype financial contracts without having to dig too deeply into the current limitations of Solidity.
