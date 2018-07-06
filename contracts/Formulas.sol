pragma solidity ^0.4.17;

contract FinancialFormulas {

    // USED TO KEEP DECIMAL PLACE PRECISION
    uint public constant d = 1000000000;

    function calculateSpcaFactor( uint rateBps, uint n, uint precision) public returns (uint) {
      uint s = 0;
      uint N = 1;
      uint B = 1;
      for (uint i = 0; i < precision; ++i){
        uint partOne = d * N / B ;
        s += partOne *  rateBps**i / 10000**i;
        N  = N * (n-i);
        B  = B * (i+1);
      }
      return s;
    }

    // Use internally to calculate future principal balances
    function balance( uint rateBps, uint period, uint lengthInPeriods, uint _presentValue, uint _futureValue) private returns (uint) {
        uint payment = pmt( rateBps, lengthInPeriods, _presentValue, _futureValue, false );
        uint newBalance = (( _presentValue * calculateSpcaFactor(rateBps, period, 20) ) - ( ( payment * 10000 / rateBps )  * ( calculateSpcaFactor(rateBps, period, 20)  - d ))) / d;
        return newBalance;
    }

    //   FV(interest_rate, number_payments, payment, PV, Type)
    function fv(uint rateBps, uint lengthInPeriods, uint payment, uint presentValue) public returns (uint) {
      uint futureValue = calculateSpcaFactor(rateBps, lengthInPeriods, 20) * presentValue;
      return futureValue;
    }

    // PMT
    function pmt(uint _requestedRate, uint _lengthInPeriods, uint _requestedAmount, uint _futureValue, bool _loanType) public returns (uint) {
        uint numerator = calculateSpcaFactor(_requestedRate, _lengthInPeriods, 10) * _requestedAmount * _requestedRate / 10000;
        uint denominator = calculateSpcaFactor(_requestedRate, _lengthInPeriods, 10) - d;
        uint calculatedPayment = numerator / denominator;
        return calculatedPayment;
    }

    // PPMT
    function ppmt(uint _rateBps, uint _period, uint lengthInPeriods, uint _presentValue, uint _futureValue, bool _loanType) public returns (uint) {
        uint payment = pmt( _rateBps, lengthInPeriods, _presentValue, _futureValue, false );
        uint principalPayment = payment - ipmt(_rateBps, _period, lengthInPeriods, _presentValue, _futureValue, false);
        return principalPayment;
    }

    // IPMT(interest_rate, period, number_payments, PV, FV, Type)
    function ipmt(uint _rateBps, uint _period, uint _lengthInPeriods, uint _presentValue, uint _futureValue, bool _loanType) public returns (uint) {
        uint payment = pmt( _rateBps, _lengthInPeriods, _presentValue, _futureValue, false );
        uint interestPayment = payment + calculateSpcaFactor(_rateBps, _period - 1, 20)  / d * (balance(_rateBps, _period - 1, _lengthInPeriods, _presentValue, 0) * _rateBps / 10000 - payment);
        return interestPayment;
    }
}