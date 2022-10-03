// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "https://github.com/ErikUrresta/staking-challenge-nft/blob/main/Contracts/RewardsToken.sol";


contract StakingNFT is Ownable, IERC721Receiver {

    uint256 public totalStaked;

    struct Staker {
        uint256 tokenId;
        uint256 timestamp;
    }
    mapping(address => Staker) public stakers;

    address[] stakersLog; 

    uint256 month = 2629743;
    uint256 constant deno = 100;

    ERC721Enumerable nft;
    RewardsToken token;

    constructor(ERC721Enumerable _nft, RewardsToken _token)  {
        nft = _nft;
        token = _token;
    }

    /* ---- Events ---- */

    event AddTokens(address _staker, uint _tokenId);

    event RemoveTokens(address _staker, uint _tokenId, uint rewards);


    /* ---- Functions ---- */


    function stake(uint256[] calldata tokenIds) external {
        uint256 tokenId;
        totalStaked += tokenIds.length;
        for (uint i = 0; i < tokenIds.length; i++) {
            tokenId = tokenIds[i];
            require(nft.ownerOf(tokenId) == msg.sender, "not your token");
        nft.transferFrom(msg.sender, address(this), tokenId);
        stakers[msg.sender] = Staker(tokenId, block.timestamp);

    }}

    function calculateRate() private view returns(uint256) {
        uint256 time = stakers[msg.sender].timestamp;
        if(block.timestamp - time < month) {
            return 0;
        } else if(block.timestamp - time <  month * 6 ) {
            return 5;
        } else if(block.timestamp - time < 12 * month) {
            return 10;
        } else {
            return 15;
        }
    }

    function unstake(address account, uint256 tokenId) external {
        require(stakers[msg.sender].tokenId == tokenId);
        uint256 rewards = calculateRate() * 10 ** 18 / month * 12 * deno;
        token.mint(msg.sender,rewards); 
        token.transfer(msg.sender, rewards);
        nft.transferFrom(address(this), account, tokenId);
        delete stakers[msg.sender];
        emit RemoveTokens(msg.sender,tokenId, rewards);
    }

    function onERC721Received(
        address,
        address from,
        uint256,
        bytes calldata
    ) external pure override returns (bytes4) {
      require(from == address(0x0), "Cannot send nfts to Vault directly");
      return IERC721Receiver.onERC721Received.selector;
    }
}
