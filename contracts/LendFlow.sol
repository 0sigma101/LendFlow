//SPDX-License-Identifier:MIT
pragma solidity ^0.8.0;

contract LendFlow {
    struct LoanRequest {
        address borrower;
        uint256 amount;
        uint256 duration;
        uint256 interestRate;
        uint256 collateral;
        bool isFulfilled;
        bool isRepaid;
    }

    mapping(uint256 => LoanRequest) public loanRequests;
    uint256 public loanRequestCount;

    mapping(address => uint256) public reputation;
    uint256 public reputationThreshold = 100; // Minimum reputation required for governance participation

    event LoanRequestCreated(uint256 requestId, address borrower, uint256 amount);
    event LoanFulfilled(uint256 requestId);
    event LoanRepaid(uint256 requestId);
    event ReputationUpdated(address account, uint256 reputation);

    function createLoanRequest(uint256 amount, uint256 duration, uint256 interestRate, uint256 collateral) external {
        require(amount > 0, "Amount must be greater than zero");
        require(duration > 0, "Duration must be greater than zero");
        require(interestRate > 0, "Interest rate must be greater than zero");
        uint256 interestAmount = (amount * duration * interestRate) / 100;
        amount += interestAmount;

        uint256 requestId = loanRequestCount;
        loanRequests[requestId] = LoanRequest(msg.sender, amount, duration, interestRate, collateral, false, false);
        loanRequestCount++;

        emit LoanRequestCreated(requestId, msg.sender, amount);
    }

    function fulfillLoanRequest(uint256 requestId) external {
        LoanRequest storage loanRequest = loanRequests[requestId];
        require(!loanRequest.isFulfilled, "Loan request has already been fulfilled");
        require(!loanRequest.isRepaid, "Loan has already been repaid");
        //require(loanRequest.borrower != msg.sender, "You cannot fulfill your own loan request");

        // Additional checks on lender's eligibility, available funds, and collateral value can be added here

        // Calculate interest based on loan amount and duration

        // Transfer loan amount + interest from lender to borrower
        // Implement the transfer function specific to your token or currency

        // Update reputation for the lender based on successful loan fulfillment
        reputation[msg.sender]++;

        loanRequest.isFulfilled = true;
        emit LoanFulfilled(requestId);
        emit ReputationUpdated(msg.sender, reputation[msg.sender]);
    }

    function repayLoan(uint256 requestId) external {
        LoanRequest storage loanRequest = loanRequests[requestId];
        require(loanRequest.isFulfilled, "Loan request has not been fulfilled yet");
        require(!loanRequest.isRepaid, "Loan has already been repaid");
        require(loanRequest.borrower == msg.sender, "Only the borrower can repay the loan");

        // Additional checks on repayment amount and handling can be added here

        // Transfer repayment amount from borrower to lender
        // Implement the transfer function specific to your token or currency

        loanRequest.isRepaid = true;
        emit LoanRepaid(requestId);
    }

    function updateReputation(address account, uint256 reputationValue) external {
        require(msg.sender == account, "You can only update your own reputation");

        reputation[msg.sender] = reputationValue;
        emit ReputationUpdated(msg.sender, reputation[msg.sender]);
    }

    function participateInGovernance() external view returns (bool) {
        return reputation[msg.sender] >= reputationThreshold;
    }
}
