// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import "../src/Marketplace.sol";

contract TestMarketplace is Test {
    Marketplace marketplace;

    function testCreateListing(
        uint256 price,
        uint256 tokenId,
        uint8 bedrooms,
        uint8 bathrooms,
        string memory homeType,
        string memory location
    ) public {
        marketplace.createListing(
            price,
            tokenId,
            bedrooms,
            bathrooms,
            homeType,
            location
        );

        // assert.equal(// s_listings[0], listing just created
        // );
    }
}
