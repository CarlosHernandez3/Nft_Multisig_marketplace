// SPDX-License-Identifier:MIT
pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import "../src/RealEstate.sol";
import "../node_modules/@openzeppelin/contracts/utils/Counters.sol";

// import "../node_modules/@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";

contract TestRealEstate is Test, ERC721URIStorage {
    using Counters for Counters.Counter;

    RealEstate nft;
    Counters.Counter private _tokenIds;
    uint256 newItemId;

    constructor() ERC721("Real Estate", "REAL") {}

    function setUp() public {
        nft = new RealEstate();
    }

    function testMint(string memory tokenURI) public {
        _tokenIds.increment();
        newItemId = _tokenIds.current();

        address minter = 0xdafc9E8452223f987B18D489BdACFA2C64B6207E;
        vm.prank(minter);
        nft.mint(tokenURI);
        assertEq(newItemId, 1);
        assertEq(minter, nft.s_owner(newItemId));
    }

    function testTotalSupply(string memory tokenURI) public {
        newItemId = _tokenIds.current();
        nft.mint(tokenURI);

        emit log_uint(newItemId);
        uint256 totalSupply = nft.totalSupply();
        assertEq(totalSupply, 1);
    }
}
