// SPDX-License-Identifier: MIT

pragma solidity ^0.8.30;

contract LinkShield {

    struct Link {
        string url;
        address owner;
        uint256 fee;
        uint256 timestamp;
        uint256 paymentsCount;
    }

    address public owner;
    uint256 public commission = 1;
    mapping(string => Link) private links;
    mapping(string => mapping(address => bool)) public hasAccess;

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the contract owner can perform this action.");
        _;
    }

    function setCommission(uint256 _commission) public onlyOwner {
        commission = _commission;
    }

    function addLink(string calldata url, string calldata linkId, uint256 fee) public {
        Link memory link = links[linkId];
        require(link.owner == address(0) || link.owner == msg.sender, "This linkId already has an owner.");
        require(fee == 0 || fee > commission, "The fee is too low.");

        link.url = url;
        link.fee = fee;
        link.owner = msg.sender;
        link.timestamp = block.timestamp;

        links[linkId] = link;
        hasAccess[linkId][msg.sender] = true;
    }

    function payLink(string calldata linkId) public payable {
        Link memory link = links[linkId];
        require(link.owner != address(0), "Link not found.");
        require(hasAccess[linkId][msg.sender] == false, "You already have access to this link.");
        require(msg.value >= link.fee, "Insufficient payment.");

        hasAccess[linkId][msg.sender] = true;
        payable(link.owner).transfer(msg.value - commission);
        links[linkId].paymentsCount++;
    }

    function getLink(string calldata linkId) public view returns (Link memory) {
        Link memory link = links[linkId];
        if (link.fee == 0) return link;
        if (hasAccess[linkId][msg.sender] == false)
            link.url = "";

        return link;
    }

    function deleteLink(string calldata linkId) public onlyOwner {
        require(links[linkId].owner != address(0), "Link does not exist.");
    
        delete links[linkId];
    }


}