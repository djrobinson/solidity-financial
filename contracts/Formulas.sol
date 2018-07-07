pragma solidity ^0.4.17;

contract FinancialFormulas {

    // USED TO KEEP DECIMAL PLACE PRECISION
    uint public constant d = 1000000000;

    /**
     * 2^127.
     */
    uint128 private constant TWO127 = 0x80000000000000000000000000000000;

    /**
     * 2^128 - 1.
     */
    uint128 private constant TWO128_1 = 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;

    /**
     * ln(2) * 2^128.
     */
    uint128 private constant LN2 = 0xb17217f7d1cf79abc9e3b39803f2f6af;

    /**
     * Return index of most significant non-zero bit in given non-zero 256-bit
     * unsigned integer value.
     *
     * @param x value to get index of most significant non-zero bit in
     * @return index of most significant non-zero bit in given number
     */
    function mostSignificantBit (uint256 x) pure internal returns (uint8) {
      require (x > 0);

      uint8 l = 0;
      uint8 h = 255;

      while (h > l) {
        uint8 m = uint8 ((uint16 (l) + uint16 (h)) >> 1);
        uint256 t = x >> m;
        if (t == 0) h = m - 1;
        else if (t > 1) l = m + 1;
        else return m;
      }

      return h;
    }

    /**
     * Calculate log_2 (x / 2^128) * 2^128.
     *
     * @param x parameter value
     * @return log_2 (x / 2^128) * 2^128
     */
    function log_2 (uint256 x) pure internal returns (int256) {
      require (x > 0);

      uint8 msb = mostSignificantBit (x);

      if (msb > 128) x >>= msb - 128;
      else if (msb < 128) x <<= 128 - msb;

      x &= TWO128_1;

      int256 result = (int256 (msb) - 128) << 128; // Integer part of log_2

      int256 bit = TWO127;
      for (uint8 i = 0; i < 128 && x > 0; i++) {
        x = (x << 1) + ((x * x + TWO127) >> 128);
        if (x > TWO128_1) {
          result |= bit;
          x = (x >> 1) - TWO127;
        }
        bit >>= 1;
      }

      return result;
    }

    /**
     * Calculate ln (x / 2^128) * 2^128.
     *
     * @param x parameter value
     * @return ln (x / 2^128) * 2^128
     */
    function ln (uint256 x) pure public returns (int256) {
      require (x > 0);

      int256 l2 = log_2 (x);
      if (l2 == 0) return 0;
      else {
        uint256 al2 = uint256 (l2 > 0 ? l2 : -l2);
        uint8 msb = mostSignificantBit (al2);
        if (msb > 127) al2 >>= msb - 127;
        al2 = (al2 * LN2 + TWO127) >> 128;
        if (msb > 127) al2 <<= msb - 127;

        return int256 (l2 >= 0 ? al2 : -al2);
      }
    }

    function calculateSpcaFactor( uint rate, uint n, uint precision) public returns (uint) {
      uint s = 0;
      uint N = 1;
      uint B = 1;
      for (uint i = 0; i < precision; ++i){
        uint partOne = d * N / B ;
        s += partOne *  rate**i / 10000**i;
        N  = N * (n-i);
        B  = B * (i+1);
      }
      return s;
    }

    // Use uinternally to calculate future principal balances
    function balance( uint rate, uint period, uint nper, uint _pv, uint _fv) private returns (uint) {
        uint payment = pmt( rate, nper, _pv, _fv, false );
        uint newBalance = (( _pv * calculateSpcaFactor(rate, period, 20) ) - ( ( payment * 10000 / rate )  * ( calculateSpcaFactor(rate, period, 20)  - d ))) / d;
        return newBalance;
    }

    // FV(interest_rate, number_payments, payment, PV, Type)
    // TODO: INCLUDE PAYMENT IN CALCULATION
    function fv(uint rate, uint nper, uint payment, uint pv, bool _loanType) public returns (uint) {
            uint fv = calculateSpcaFactor(rate, nper, 20) * pv / d;
        return fv;
    }

    // PV()
    function pv(uint _rate, uint _nper, uint _pmt, uint _fv, bool _loanType) public returns (uint) {
        uint spcaf = calculateSpcaFactor(_rate, _nper, 20);
        uint pv = _fv / spcaf / d;
        return pv;
    }

    // NPER()
    function nper(uint _rate, uint _pmt, uint _pv, uint _fv, bool _loanType) returns (int) {
        uint rate = _rate * d;
        uint pmt = _pmt * d;
        uint pv = _pv * d;
        uint bpsConverter = 10000 * d;
        int n = -ln( d - rate / bpsConverter * pv / pmt) / ln(d + rate / bpsConverter);
        // -N*log(1+i) = log(1-iA/P)
        return 0;
    }

    // NPV()
    function npv(uint _rate, bytes _pmtsBuffer) returns (uint) {
        // This will be pretty scrappy...
        // https://hackernoon.com/serializing-string-arrays-in-solidity-db4b6037e520
        return 0;
    }

    // IRR()
    function irr(bytes _valuesBuffer, uint _guess) returns (uint) {
        // Same situation as above
        return 0;
    }

    // RATE()
    function rate(uint _nper, uint _pmt, uint _pv, bool _loanType, uint _guess) returns (uint) {
        // Newton's method: https://math.stackexchange.com/questions/502976/newtons-method-annuity-due-equation
        return 0;
    }

    // PMT
    function pmt(uint _requestedRate, uint _nper, uint _requestedAmount, uint _fv, bool _loanType) public returns (uint) {
        uint numerator = calculateSpcaFactor(_requestedRate, _nper, 10) * _requestedAmount * _requestedRate / 10000;
        uint denominator = calculateSpcaFactor(_requestedRate, _nper, 10) - d;
        uint calculatedPayment = numerator / denominator;
        return calculatedPayment;
    }

    // PPMT
    function ppmt(uint _rate, uint _period, uint nper, uint _pv, uint _fv, bool _loanType) public returns (uint) {
        uint payment = pmt( _rate, nper, _pv, _fv, false );
        uint principalPayment = payment - ipmt(_rate, _period, nper, _pv, _fv, false);
        return principalPayment;
    }

    // IPMT(interest_rate, period, number_payments, PV, FV, Type)
    function ipmt(uint _rate, uint _period, uint _nper, uint _pv, uint _fv, bool _loanType) public returns (uint) {
        uint payment = pmt( _rate, _nper, _pv, _fv, false );
        uint interestPayment = payment + calculateSpcaFactor(_rate, _period - 1, 20)  / d * (balance(_rate, _period - 1, _nper, _pv, 0) * _rate / 10000 - payment);
        return interestPayment;
    }
}