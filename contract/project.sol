// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract AutomatedMortgagePayment {
    address public lender;
    address public borrower;
    uint public mortgageAmount;
    uint public monthlyPayment;
    uint public dueDate;
    uint public totalPaid;
    uint public paymentInterval = 30 days;

    event PaymentMade(address indexed borrower, uint amount, uint timestamp);
    event MortgageFullyPaid(address indexed borrower, uint totalAmount, uint timestamp);

    modifier onlyBorrower() {
        require(msg.sender == borrower, "Only borrower can perform this action");
        _;
    }

    modifier onlyLender() {
        require(msg.sender == lender, "Only lender can perform this action");
        _;
    }

    constructor(
        address _borrower,
        uint _mortgageAmount,
        uint _monthlyPayment
    ) {
        lender = msg.sender;
        borrower = _borrower;
        mortgageAmount = _mortgageAmount;
        monthlyPayment = _monthlyPayment;
        dueDate = block.timestamp + paymentInterval;
    }

    function makePayment() external payable onlyBorrower {
        require(msg.value == monthlyPayment, "Incorrect payment amount");
        require(block.timestamp >= dueDate, "Payment not due yet");
        require(totalPaid < mortgageAmount, "Mortgage already paid off");

        totalPaid += msg.value;
        dueDate += paymentInterval;
        payable(lender).transfer(msg.value);

        emit PaymentMade(msg.sender, msg.value, block.timestamp);

        if (totalPaid >= mortgageAmount) {
            emit MortgageFullyPaid(msg.sender, totalPaid, block.timestamp);
        }
    }

    function getRemainingBalance() public view returns (uint) {
        return mortgageAmount - totalPaid;
    }

    function getNextDueDate() public view returns (uint) {
        return dueDate;
    }

    function isMortgagePaidOff() public view returns (bool) {
        return totalPaid >= mortgageAmount;
    }
} 

