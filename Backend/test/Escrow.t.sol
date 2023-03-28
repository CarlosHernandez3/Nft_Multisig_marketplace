// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import "../src/Escrow.sol";

contract TestEscrow is Test {
    Escrow public escrow;

    address _lender;
    address _seller;
    address _buyer;
    uint256 _deposit;
    bytes32 _tokenURI;
    uint256 _assetPrice;
    uint256 _tokenId;
    address _nftAddress;

    function setUp() public {
        escrow = new Escrow(
            _lender,
            _seller,
            _buyer,
            _deposit,
            _tokenURI,
            _assetPrice,
            _tokenId,
            _nftAddress
        );
    }

    function testConstructorInitialized() public {
        assertEq(escrow.ViewLender(), _lender);
        assertEq(escrow.ViewSeller(), _seller);
        assertEq(escrow.ViewBuyer(), _buyer);
        assertEq(escrow.ViewDownPayment(), _deposit);
        assertEq(escrow.viewTokenURI(), _tokenURI);
        assertEq(escrow.viewAssetPrice(), _assetPrice);
        assertEq(escrow.viewTokenId(), _tokenId);
        assertEq(escrow.viewNftAddress(), _nftAddress);
    }

    function testDepositDownPayment() public {
        // saleState = State.Closed; instantiate State variable
        vm.expectRevert(bytes("Sale is not Open"));
        escrow.depositDownPayment();

        address alice = 0xE0f5206BBD039e7b0592d8918820024e2a7437b9; // fake address
        (bool success, bytes memory data) = alice.call{value: _deposit}("");

        assertEq(escrow.ViewAmountDeposited(), escrow.ViewDownPayment());

        // assertEq(State.PENDING, escrow.saleState());
    }

    // function testAppraiseProperty() public {}

    // function testLenderDeposit() public {}

    // function testFullyFunded() public {}

    // function testCancelSale() public {}

    // function testExecuteSale() public {}
}

// event Deposited(address indexed depositer, uint256 weiAmount);
// event Withdrawal(address indexed withdrawer, uint256 weiAmount);
// event NftSent(address indexed seller, address indexed buyer);
// look at smart contract programmer video
