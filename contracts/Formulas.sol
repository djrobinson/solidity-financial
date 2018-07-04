pragma solidity ^0.4.17;

contract FinancialFormulas {

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

    // PMT(rate, nper, pv, [fv], [type])
    function calculatePayment(uint requestedRate, uint lengthInPeriods, uint requestedAmount) private returns (uint) {
        uint numerator = fv(requestedRate, lengthInPeriods, requestedAmount, 10) / requestedRate * 100000000;
        uint denominator = fv(requestedRate, lengthInPeriods, 100000000, 10) - 100000000;
        uint payment = numerator / denominator;
        return payment;
    }

    // TODO: PPMT(rate, per, nper, pv, [fv], [type])
    function ppmt() public {

    }

    // IPMT(rate, per, nper, pv, [fv], [type])
    // Not right yet
    function ipmt(uint principalBalance, uint requestedRate) public returns (uint) {
        uint interestPayment = principalBalance / requestedRate;
        return interestPayment;
    }

    // FV(rate, nper, pmt, [pv], [type])
    // rate: interest rate/period
    // nper: number of periods
    // pmt: payment/period
    // pv: present value
    // type: start or end of period
    function fv( uint rateBps, uint n, uint presentValue, uint precision) public returns (uint) {

      uint s = 0;
      uint N = 1;
      uint B = 1;
      for (uint i = 0; i < precision; ++i){
        s += presentValue * N / B / ((1 / rateBps * 100 / 10000)**i);
        N  = N * (n-i);
        B  = B * (i+1);
      }
      return s;
    }
}