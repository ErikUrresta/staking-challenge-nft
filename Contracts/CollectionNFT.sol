// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 < 0.9.0; 

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract Nft721 is ERC721 {

    uint256 public tokenCounterForId; 

    constructor() ERC721("CollectionDemo", "CDD") {
        tokenCounterForId = 0;
    }


    function createToken() public returns(uint256) {
        uint256 newTokenId = tokenCounterForId;
        _safeMint(msg.sender, newTokenId); 
        tokenCounterForId++;
        return newTokenId;
        }
}
