pragma solidity ^0.4.17;

contract FinancialFormulas {

    uint public constant d = 1000000000;
    uint public payment = 0;
    uint public spcaFactor = 0;
    uint public requestedAmount = 0;

    // TODO: PV(rate, nper, [fv], [type])
    function pv() public {

    }

    // TODO: NPV(rate, val1, [val2], [val3]...)
    function npv() public {

    }

    // TODO: XNPV(rate, values[], dates[])
    function xnpv() public {

    }

    // TODO: IRR(values[], [guess])
    function irr() public {

    }

    // MAYBE TODO: MIRR(values[], finance_rate, reinvest_rate)
    function mirr() public {

    }

    // TODO: RATE(nper, pmt, pv, [fv], [type], [guess])
    function rate() public {

    }

    // TODO: NPER(rate, pmt, pv, [fv], [type])
    function nper() public {

    }

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
      spcaFactor = s;
      return s;
    }

    function calculatePayment(uint requestedRate, uint lengthInPeriods, uint _requestedAmount, uint futureValue) public returns (uint) {
        uint numerator = calculateSpcaFactor(requestedRate, lengthInPeriods, 10) * _requestedAmount * requestedRate / 10000;
        uint denominator = calculateSpcaFactor(requestedRate, lengthInPeriods, 10) - d;
        uint calculatedPayment = numerator / denominator;
        payment = calculatedPayment;
        requestedAmount = _requestedAmount;
        return calculatedPayment;
    }

    function balance( uint rateBps, uint period, uint lengthInPeriods, uint loanAmount ) public returns (uint) {
        uint newBalance = (( loanAmount * calculateSpcaFactor(rateBps, period, 20) ) - ( ( payment * 10000 / rateBps )  * ( calculateSpcaFactor(rateBps, period, 20)  - d ))) / d;
        return newBalance;
    }

    //   FV(interest_rate, number_payments, payment, PV, Type)
    function fv(uint rateBps, uint lengthInPeriods, uint payment, uint presentValue) public returns (uint) {
      uint futureValue = calculateSpcaFactor(rateBps, lengthInPeriods, 20) * presentValue;
      return futureValue;
    }

    function ppmt(uint rateBps, uint period, uint lengthInPeriods, uint presentValue, uint futureValue) public returns (uint) {
        uint principalPayment = payment - ipmt(rateBps, period, lengthInPeriods, presentValue, futureValue);
        return principalPayment;
    }

    // IPMT(interest_rate, period, number_payments, PV, FV, Type)
    function ipmt(uint rateBps, uint period, uint lengthInPeriods, uint presentValue, uint futureValue) public returns (uint) {
      uint interestPayment = payment + calculateSpcaFactor(rateBps, period - 1, 20)  / d * (balance(rateBps, period - 1, lengthInPeriods, presentValue) * rateBps / 10000 - payment);
      return interestPayment;
    }
}