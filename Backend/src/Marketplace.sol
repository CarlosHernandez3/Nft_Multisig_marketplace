// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "./Escrow.sol";
import "./RealEstate.sol";

contract Marketplace {
    struct Listing {
        uint256 price;
        uint256 tokenId;
        uint8 bedrooms;
        uint8 bathrooms;
        string homeType;
        string location;
    }

    RealEstate newNft;

    mapping(address => Listing) addressToTokenId;

    Listing[] s_listings;

    function createListing(
        uint256 price,
        uint256 tokenId,
        uint8 bedrooms,
        uint8 bathrooms,
        string memory homeType,
        string memory location
    ) public returns (bool) {
        bool success = msg.sender == newNft.getApproved(tokenId);
        require(success, "Marketplace cannot transfer Nft");
        addressToTokenId[msg.sender] = Listing(
            price,
            tokenId,
            bedrooms,
            bathrooms,
            homeType,
            location
        );
    }
}

/*
    functions

    createListing
    deleteListing
    updateListing
    getListing
    
*/
