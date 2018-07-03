pragma solidity ^0.4.17;

contract FinancialFormulas {

    // PMT()
    function calculatePayment(uint requestedRate, uint lengthInPeriods, uint requestedAmount) private returns (uint) {
        uint numerator = futureValue(requestedRate, lengthInPeriods, requestedAmount, 10) / requestedRate * 100000000;
        uint denominator = futureValue(requestedRate, lengthInPeriods, 100000000, 10) - 100000000;
        uint payment = numerator / denominator;
        return payment;
    }

    // IPMT()
    // Not right yet
    function calculateInterestPayment(uint principalBalance, uint requestedRate) private returns (uint) {
        uint interestPayment = principalBalance / requestedRate;
        return interestPayment;
    }

    // FV()
    function futureValue( uint rateReciprocal, uint n, uint presentValue, uint precision) private returns (uint) {
      uint s = 0;
      uint N = 1;
      uint B = 1;
      // Might need to adjust how we set % to fraction later by changing q
      for (uint i = 0; i < precision; ++i){
        s += presentValue * N / B / (rateReciprocal**i);
        N  = N * (n-i);
        B  = B * (i+1);
      }
      return s;
    }
}