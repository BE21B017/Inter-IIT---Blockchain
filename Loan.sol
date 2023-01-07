pragma solidity ^0.7.0;

contract Bank {
    // Map to store user accounts
    mapping(address => User) public users;

    // Struct to represent a user account
    struct User {
        uint256 loanBalance; // loan balance in BR
        uint256 lastUpdated; // timestamp of last loan update
    }

    // Interest rate of 10% per hour
    uint256 public interestRate = 10;

    // Function to accept a token deposit and give the user a loan in BR
    function deposit(address _user, uint256 _amount) public {
        // Convert the token amount to BR
        uint256 loanAmount = _amount * 100;
        // Update the user's loan balance
        users[_user].loanBalance += loanAmount;
        // Update the last loan update time
        users[_user].lastUpdated = block.timestamp;
    }

  // Function to allow a user to pay back the loan and receive their token back
function payback() public payable {
    address _user = msg.sender;
    // Calculate the interest on the loan
    uint256 interest = calcInterest(_user);
    // Calculate the total amount due
    uint256 totalDue = users[_user].loanBalance + interest;
    // Check that the user has enough funds to pay back the loan
    require(msg.value >= totalDue, "Insufficient funds to pay back loan");
    // Convert the total due amount back to the original token amount
    uint256 tokenAmount = totalDue / 100;
    // Transfer the token amount back to the user
    address payable userAddress = address(uint160(_user));
    userAddress.transfer(tokenAmount);
    // Reset the user's loan balance to 0
    users[_user].loanBalance = 0;
}


    // Function to calculate the interest on a user's loan
    function calcInterest(address _user) private view returns (uint256) {
        // Calculate the elapsed time since the last loan update
        uint256 elapsedTime = block.timestamp - users[_user].lastUpdated;
        // Calculate the interest as a percentage of the loan balance
        uint256 interest = (users[_user].loanBalance * interestRate * elapsedTime) / 1000000;
        return interest;
    }
}
