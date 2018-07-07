    pragma solidity ^0.4.17;

    contract FinancialFormulas {

        // USED TO KEEP DECIMAL PLACE PRECISION
        uint public constant d = 1000000000;

        function log2(int x) returns (int y){
           assembly {
                let arg := x
                x := sub(x,1)
                x := or(x, div(x, 0x02))
                x := or(x, div(x, 0x04))
                x := or(x, div(x, 0x10))
                x := or(x, div(x, 0x100))
                x := or(x, div(x, 0x10000))
                x := or(x, div(x, 0x100000000))
                x := or(x, div(x, 0x10000000000000000))
                x := or(x, div(x, 0x100000000000000000000000000000000))
                x := add(x, 1)
                let m := mload(0x40)
                mstore(m,           0xf8f9cbfae6cc78fbefe7cdc3a1793dfcf4f0e8bbd8cec470b6a28a7a5a3e1efd)
                mstore(add(m,0x20), 0xf5ecf1b3e9debc68e1d9cfabc5997135bfb7a7a3938b7b606b5b4b3f2f1f0ffe)
                mstore(add(m,0x40), 0xf6e4ed9ff2d6b458eadcdf97bd91692de2d4da8fd2d0ac50c6ae9a8272523616)
                mstore(add(m,0x60), 0xc8c0b887b0a8a4489c948c7f847c6125746c645c544c444038302820181008ff)
                mstore(add(m,0x80), 0xf7cae577eec2a03cf3bad76fb589591debb2dd67e0aa9834bea6925f6a4a2e0e)
                mstore(add(m,0xa0), 0xe39ed557db96902cd38ed14fad815115c786af479b7e83247363534337271707)
                mstore(add(m,0xc0), 0xc976c13bb96e881cb166a933a55e490d9d56952b8d4e801485467d2362422606)
                mstore(add(m,0xe0), 0x753a6d1b65325d0c552a4d1345224105391a310b29122104190a110309020100)
                mstore(0x40, add(m, 0x100))
                let magic := 0x818283848586878898a8b8c8d8e8f929395969799a9b9d9e9faaeb6bedeeff
                let shift := 0x100000000000000000000000000000000000000000000000000000000000000
                let a := div(mul(x, magic), shift)
                y := div(mload(add(m,sub(255,a))), shift)
                y := add(y, mul(256, gt(arg, 0x8000000000000000000000000000000000000000000000000000000000000000)))
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
    //
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
        // Log of decimal is an issue. Use log product rules to fix?
        // https://www.rapidtables.com/calc/math/Log_Calculator.html < bottom of page
        function nper(int _rate, int _pmt, int _pv, int _fv, bool _loanType) returns (int) {
            int bpsConverter = 10000;
            int n = -log2( 1 - _rate / bpsConverter * _pv / _pmt) / log2(1 + _rate / bpsConverter);
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