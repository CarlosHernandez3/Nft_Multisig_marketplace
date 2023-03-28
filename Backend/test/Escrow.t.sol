// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import "../src/Escrow.sol";
import "../node_modules/@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract TestEscrow is Test {
    enum State {
        OPEN,
        PENDING,
        CLOSED
    }

    Escrow public escrow;
    State public saleState;
    address public appraiser;
    // IERC20 token;
    // token.deploy();

    address _lender;
    address _seller;
    address _buyer;
    uint256 _deposit;
    bytes32 _tokenURI;
    uint256 _assetPrice;
    uint256 _tokenId;
    address _nftAddress;

    function setUp() public {
        // _lender = vm.addr(2);
        // _seller = vm.addr(3);
        // _buyer = vm.addr(1);
        // appraiser = vm.addr(4);
        // _deposit = 1 ether;
        // _tokenURI = "hello world";
        // _assetPrice = 2 ether;
        // _tokenId = 0;
        // _nftAddress = vm.addr(5);

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

    function testFailDepositDownPayment() public {
        vm.startPrank(_buyer);
        escrow.depositDownPayment();
        vm.expectRevert(bytes("Sale is not Open"));
    }

    function testDepositDownPayment() public {
        vm.startPrank(_buyer);
        vm.deal(_buyer, 20 ether);
        escrow.depositDownPayment();
        assertEq(escrow.ViewAmountDeposited(), escrow.ViewDownPayment());
    }

    function testFailSalePending() public {
        saleState == State.OPEN;
        vm.startPrank(_buyer);
        escrow.depositDownPayment();
        assertEq(escrow.ViewAmountDeposited(), escrow.ViewDownPayment());
        vm.stopPrank();

        vm.startPrank(_lender);
        escrow.depositDownPayment();
    }

    function testAppraiseProperty() public {
        vm.startPrank(appraiser);
        escrow.appraiseProperty();
    }

    function testFailAppraiseProperty() public {
        escrow.appraiseProperty();
    }

    function testLenderDeposit() public {
        vm.startPrank(_buyer);
        escrow.depositDownPayment();
        vm.stopPrank();

        vm.startPrank(appraiser);
        escrow.appraiseProperty();
        vm.stopPrank();

        vm.startPrank(_lender);
        escrow.lenderDeposit();
    }

    function testFailLenderDeposit() public {
        escrow.lenderDeposit();
    }

    function testFullyFunded() public {
        vm.startPrank(_buyer);
        escrow.depositDownPayment();
        vm.stopPrank();

        vm.startPrank(appraiser);
        escrow.appraiseProperty();
        vm.stopPrank();

        vm.startPrank(_lender);
        escrow.lenderDeposit();
        vm.stopPrank();

        vm.startPrank(_seller);
        escrow.fullyFunded();
        emit log_uint(escrow.amountDeposited());
        // assertEq(escrow.isFullyFunded(), true); // throws error
    }

    function testFailFullyFunded() public {
        escrow.fullyFunded();

        vm.startPrank(_seller);
        escrow.fullyFunded();
        vm.stopPrank();

        vm.startPrank(_buyer);
        escrow.depositDownPayment();
        escrow.fullyFunded();
    }

    // function testCancelSale() public {}

    // function testExecuteSale() public {}
}

// event Deposited(address indexed depositer, uint256 weiAmount);
// event Withdrawal(address indexed withdrawer, uint256 weiAmount);
// event NftSent(address indexed seller, address indexed buyer);
// how to test events

//

// questions

// should i use vm.deal to use money. if so how to evaluate that tmoney is
