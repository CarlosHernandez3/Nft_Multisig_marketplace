// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "../node_modules/@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "../node_modules/@openzeppelin/contracts/token/ERC20/IERC20.sol";

error Escrow__NotBuyer();
error Escrow__NotSeller();
error Escrow__SaleNotApproved();
error Escrow__NotParticipant();

contract Escrow {
    event Deposited(address indexed depositer, uint256 weiAmount);
    event Withdrawal(address indexed withdrawer, uint256 weiAmount);
    event NftSent(address indexed seller, address indexed buyer);

    enum State {
        OPEN,
        PENDING,
        CLOSED
    }

    IERC20 token;

    address private immutable i_lender;
    address private immutable i_seller;
    address private immutable i_buyer;
    uint256 private immutable i_deposit;
    uint256 private immutable i_assetPrice;

    bytes32 private immutable i_tokenURI;
    uint256 private immutable i_tokenId;
    address private immutable i_nftAddress;
    ERC721 private immutable i_nft;

    address public appraiser;
    uint256 public amountDeposited;
    State public saleState = State.OPEN;
    bool public appraised = false;
    bool public isFullyFunded = false;

    constructor(
        address _lender,
        address _seller,
        address _buyer,
        uint256 _deposit,
        bytes32 _tokenURI,
        uint256 _assetPrice,
        uint256 _tokenId,
        address nftAddress
    ) {
        i_lender = _lender;
        i_seller = payable(_seller);
        i_buyer = _buyer;
        i_deposit = _deposit;
        i_tokenURI = _tokenURI;
        i_assetPrice = _assetPrice;
        i_tokenId = _tokenId;
        i_nftAddress = nftAddress;
        i_nft = ERC721(nftAddress);
    }

    modifier onlyBuyer() {
        if (msg.sender != i_buyer) {
            revert Escrow__NotBuyer();
        }
        _;
    }

    modifier onlySeller() {
        if (msg.sender != i_seller) {
            revert Escrow__NotSeller();
        }
        _;
    }

    modifier onlyParticipants() {
        if (
            msg.sender != i_seller ||
            msg.sender != i_buyer ||
            msg.sender != i_lender
        ) {
            revert Escrow__NotParticipant();
        }
        _;
    }

    modifier saleApproved() {
        if (appraised == false || isFullyFunded == false) {
            revert Escrow__SaleNotApproved();
        }
        _;
    }

    // Getter funcitons

    function viewState() public view returns (State) {
        return (saleState);
    }

    function ViewBuyer() public view returns (address) {
        return (i_buyer);
    }

    function ViewSeller() public view returns (address) {
        return (i_seller);
    }

    function ViewLender() public view returns (address) {
        return (i_lender);
    }

    function ViewAppraiser() public view returns (address) {
        return (appraiser);
    }

    function ViewDownPayment() public view returns (uint256) {
        return (i_deposit);
    }

    function ViewAmountDeposited() public view returns (uint256) {
        return (amountDeposited);
    }

    function viewTokenURI() public view returns (bytes32) {
        return (i_tokenURI);
    }

    function viewAssetPrice() public view returns (uint256) {
        return (i_assetPrice);
    }

    function viewTokenId() public view returns (uint256) {
        return (i_tokenId);
    }

    function viewNftAddress() public view returns (address) {
        return (i_nftAddress);
    }

    receive() external payable {
        amountDeposited += msg.value;
    }

    function depositDownPayment() external payable onlyBuyer {
        require(saleState == State.OPEN, "Sale is not Open");
        // approve transaction

        (bool success, bytes memory data) = payable(address(this)).call{
            value: i_deposit
        }("");
        require(success, "Failed to send Down Payment!");

        amountDeposited += i_deposit;
        emit Deposited(i_buyer, i_deposit);
        saleState = State.PENDING;
    }

    function appraiseProperty() public {
        require(
            msg.sender == appraiser,
            "Only the appraiser can appraise the contract"
        );
        appraised = true;
    }

    function lenderDeposit() public payable {
        require(
            msg.sender == i_lender,
            "Deposit must be from the lender's address!"
        );
        require(saleState == State.PENDING, "No sale is pending!");
        require(
            amountDeposited >= i_deposit,
            "Down Payment has not been made!"
        );

        require(appraised, "Property has not been appraised!");

        // approve transaction

        uint256 requiredAmount = i_assetPrice - i_deposit;
        (bool sent, bytes memory data) = payable(address(this)).call{
            value: requiredAmount
        }("");
        require(sent, "The Lender's deposit failed!");
        amountDeposited += requiredAmount;
    }

    function fullyFunded() external view onlySeller {
        require(saleState == State.PENDING, "No sale is pending!");
        if (amountDeposited >= i_assetPrice) {
            isFullyFunded == true;
        } else {
            isFullyFunded == false;
        }
    }

    function cancelSale() external onlyParticipants {
        (bool success, bytes memory data) = payable(i_buyer).call{
            value: i_deposit
        }("");
        require(success, "Failed to withdraw buyer's Down Payment!");
        emit Withdrawal(i_buyer, i_deposit);
        amountDeposited -= i_deposit;

        (bool sent, bytes memory info) = payable(i_lender).call{
            value: amountDeposited
        }("");
        require(sent, "Failed to withdraw lender's Payment!");
        emit Withdrawal(i_lender, amountDeposited);
        amountDeposited = 0;
        saleState = State.OPEN;
    }

    function executeSale() external onlySeller saleApproved {
        i_nft.approve(i_buyer, i_tokenId);
        if (i_nft.getApproved(i_tokenId) != address(this)) {
            revert Escrow__SaleNotApproved();
        }

        (bool success, bytes memory data) = payable(i_seller).call{
            value: i_assetPrice
        }("");
        require(success, "Withdraw Failed!");
        amountDeposited = 0;
        emit Withdrawal(i_seller, i_assetPrice);

        i_nft.transferFrom(i_seller, i_buyer, i_tokenId);
        emit NftSent(i_seller, i_buyer);
    }
}
