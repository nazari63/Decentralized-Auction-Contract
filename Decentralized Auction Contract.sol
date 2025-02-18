// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract DecentralizedAuction {
    address public admin;
    address public highestBidder;
    uint public highestBid;
    uint public auctionEndTime;
    bool public auctionEnded;
    
    event NewBid(address indexed bidder, uint amount);
    event AuctionEnded(address indexed winner, uint amount);

    constructor(uint _biddingTime) {
        admin = msg.sender;
        auctionEndTime = block.timestamp + _biddingTime;
    }

    function placeBid() external payable {
        require(block.timestamp < auctionEndTime, "Auction has ended");
        require(msg.value > highestBid, "There already is a higher bid");

        if (highestBid != 0) {
            payable(highestBidder).transfer(highestBid); // Refund the previous highest bidder
        }

        highestBidder = msg.sender;
        highestBid = msg.value;

        emit NewBid(msg.sender, msg.value);
    }

    function endAuction() external {
        require(msg.sender == admin, "Only admin can end the auction");
        require(block.timestamp >= auctionEndTime, "Auction time has not ended yet");
        require(!auctionEnded, "Auction already ended");

        auctionEnded = true;
        emit AuctionEnded(highestBidder, highestBid);

        payable(admin).transfer(highestBid);
    }

    function getHighestBid() external view returns (uint) {
        return highestBid;
    }

    function getHighestBidder() external view returns (address) {
        return highestBidder;
    }
}