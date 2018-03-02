pragma solidity ^0.4.18;

import "./Owned.sol";

contract SellItPayment is Owned {

  uint private _offersCount;

  ///////////////////////
  // GENERAL STRUCTURE //
  ///////////////////////
  struct Offer {
    address seller;
    uint price;
    address buyer;
    string title;
    string description;
    string buyerAddress;
    bool shipped;
    bool confirmed;
    bool canceled;
  }

  mapping(uint => Offer) offers;
  mapping(address => uint) blockedInContractEth;
  mapping(address => uint) withdrawableFunds;

  ////////////
  // EVENTS //
  ////////////
  event DepositReceived(address indexed _from, uint _amount, uint _timestamp);
  event WithdrawalEth(address indexed _to, uint _amount, uint _timestamp);
  event OfferPublished(address indexed _seller, uint indexed _offerIndex);
  event OfferAccepted(address indexed _buyer, uint indexed _offerIndex);
  event OfferCanceledBySeller(address indexed _buyer, uint indexed _offerIndex);
  event OfferCanceledByBuyer(address indexed _buyer, uint indexed _offerIndex);
  event OfferConfirmed(address indexed _buyer, uint indexed _offerIndex);
  event OfferShipped(address indexed _seller, uint indexed _offerIndex);
  event TransactionConfirmed(address _from, address _to, uint _amount);


  //////////////
  // MODIFERS //
  //////////////
  modifier existing(uint index) {
    assert(_offersCount > 0);
    assert(index > 0);
    assert(index <= _offersCount);
    _;
  }

  ////////////////////////
  // MAIN FUNCTIONALITY //
  ////////////////////////
  // Constructor. Init offers count with 0
  function SellItPayment() public {
    _offersCount = 0;
  }

  // Deposit some amount of eth
  function Deposit() public payable {
    require(withdrawableFunds[msg.sender] + msg.value >= withdrawableFunds[msg.sender]);
    withdrawableFunds[msg.sender] += msg.value;
    DepositReceived(msg.sender, msg.value, now);
  }

  // Withraw not blocked funds
  function Withraw(uint amount) public {
    require(withdrawableFunds[msg.sender] - amount >= 0);
    require(withdrawableFunds[msg.sender] - amount <= withdrawableFunds[msg.sender]);
    withdrawableFunds[msg.sender] -= amount;
    msg.sender.transfer(amount);
    WithdrawalEth(msg.sender, amount, now);
  }

  // Everyone can create offer
  function PublishOffer(uint price, string title, string description) public {
    _offersCount += 1;
    Offer storage offer = offers[_offersCount];
    offer.seller = msg.sender;
    offer.price = price;
    offer.title = title;
    offer.description = description;
    offer.shipped = false;
    OfferPublished(msg.sender, _offersCount);
  }

  // Accept existing offer from user which is not seller. Buyer make payment to system or take from his deposit for the announced price.
  function AcceptOffer(uint offerIndex, string addressForShipment) public payable existing(offerIndex) {
    Offer storage offer = offers[offerIndex];
    // check if buyer is not the seller
    require(msg.sender != offer.seller);
    // check if someone has already accepted the offer
    require(offer.buyer == address(0));
    // check if offer is not already canceled
    require(offer.canceled == false);
    // check if the amount is not negative
    require(withdrawableFunds[msg.sender] + msg.value >= withdrawableFunds[msg.sender]);
    // check is the transferred amount equal or higher to the price
    require(withdrawableFunds[msg.sender] + msg.value >= offer.price);
    // transfer eth to blocked funds
    blockedInContractEth[msg.sender] += offer.price;
    // transferring excess eth to withdrawable ones
    withdrawableFunds[msg.sender] += (msg.value - offer.price);
    offer.buyer = msg.sender;
    offer.confirmed = false;
    offer.buyerAddress = addressForShipment;
    OfferAccepted(msg.sender, offerIndex);
  }

  // Seller can cancel existing offer if this offer is not confirmed yet. System allow buyer to withdraw the amount.
  function CancelOfferBySeller(uint offerIndex) public existing(offerIndex) {
    Offer storage offer = offers[offerIndex];
    // check if the seller is this who try to cancel offer
    require(msg.sender == offer.seller);
    // check if offer is not already confirmed
    require(offer.confirmed == false);
    // check if offer is not already canceled
    require(offer.canceled == false);
    offer.canceled = true;
    RefundBuyer(offer.buyer, offer.price);
    OfferCanceledBySeller(msg.sender, offerIndex);
  }

  // Buyer can cancel accepted offer if is accepted by him and offer is not shipped or confirmed yet. System will refund buyer.
  function CancelOfferByBuyer(uint offerIndex) public existing(offerIndex) {
    Offer storage offer = offers[offerIndex];
    // check if the buyer is this who try to cancel offer
    require(msg.sender == offer.buyer);
    // check if offer is not already shipped
    require(offer.shipped == false);
    // check if offer is not already confirmed
    require(offer.confirmed == false);
    // check if offer is not already canceled
    require(offer.canceled == false);
    offer.canceled = true;
    RefundBuyer(offer.buyer, offer.price);
    OfferCanceledByBuyer(msg.sender, offerIndex);
  }

  // Buyer confirm receiving of offered item or service and system make payment to seller.
  function ConfirmOffer(uint offerIndex) public existing(offerIndex) {
    Offer storage offer = offers[offerIndex];
    // check whether the buyer wants to confirm
    require(msg.sender == offer.buyer);
    // check if offer is not already confirmed
    require(offer.confirmed == false);
    // check if offer is not already canceled
    require(offer.canceled == false);
    offer.confirmed = true;
    PayToSeller(offer.buyer, offer.seller, offer.price);
    OfferConfirmed(msg.sender, offerIndex);
  }

  function ConfirmShipping(uint offerIndex) public existing(offerIndex) {
    Offer storage offer = offers[offerIndex];
    require(msg.sender == offer.seller);
    require(offer.confirmed == false);
    require(offer.canceled == false);
    offer.shipped = true;
    OfferShipped(msg.sender, offerIndex);
  }

  // Return offer info by offer id
  function GetOfferById(uint offerId) public view existing(offerId) returns (string, string, bool, bool, address) {
    Offer storage offer = offers[offerId];
    return (offer.title, offer.description, offer.confirmed, offer.canceled, offer.buyer);
  }

  // Helper function to check blocked balances
  function GetBlockedBalanceByAddres(address addr) public view returns (uint) {
    return blockedInContractEth[addr];
  }

  // Helper function to check withdrawabl balances
  function GetDepositBalanceByAddres(address addr) public view returns (uint) {
    return withdrawableFunds[addr];
  }

  // Helper function to check offers total count
  function GetTotalNumberOfOffers() public view returns (uint) {
    return _offersCount;
  }

  // Unblock amount of eth for canceled order
  function RefundBuyer(address buyer, uint amount) private {
    withdrawableFunds[buyer] += amount;
    blockedInContractEth[buyer] -= amount;
  }

  // Transfer amount of eth from buyer to seller
  function PayToSeller(address from, address to, uint amount) private {
    blockedInContractEth[from] -= amount;
    withdrawableFunds[to] += amount;
    TransactionConfirmed(from, to, amount);
  }
}
