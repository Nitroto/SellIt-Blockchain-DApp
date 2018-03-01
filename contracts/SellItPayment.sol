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
  mapping(address => uint) balanceEthForAddress;
  mapping(address => uint) pendingReturns;

  ////////////
  // EVENTS //
  ////////////
  event OfferPublished(address indexed _seller, uint indexed _offerIndex);
  event OfferAccepted(address indexed _buyer, uint indexed _offerIndex);
  event OfferCanceledBySeller(address indexed _buyer, uint indexed _offerIndex);
  event OfferCanceledByBuyer(address indexed _buyer, uint indexed _offerIndex);
  event OfferConfirmed(address indexed _buyer, uint indexed _offerIndex);

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
  function SellItPayment() public {
    _offersCount = 0;
  }

  function GetTotalNumberOfOffers() public view returns (uint) {
    return _offersCount;
  }

  // Anyone can create offer
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

  // Accept existing offer from user which is not seller. Buyer make payment to system for the announced price.
  function AcceptOffer(uint offerIndex, string addressForShipment) public payable existing(offerIndex) {
    Offer storage offer = offers[offerIndex];
    // check if buyer is not the seller
    require(msg.sender != offer.seller);
    // check if someone has already accepted the offer
    require(offer.buyer == address(0));
    // check if offer is not already canceled
    require(offer.canceled == false);
    // check if the amount is not negative
    require(balanceEthForAddress[msg.sender] + msg.value >= balanceEthForAddress[msg.sender]);
    // check is the transferred amount equal to the price
    require(msg.value == offer.price);
    // transfer eth to payment
    balanceEthForAddress[msg.sender] += msg.value;
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
    // Refund buyer
    OfferCanceledByBuyer(msg.sender, offerIndex);
  }

  // Buyer confirm receiving of offered item or service and system make payment to seller.
  function ConfirmOffer(uint offerIndex) public existing(offerIndex) payable {
    Offer storage offer = offers[offerIndex];
    // check whether the buyer wants to confirm
    require(msg.sender == offer.buyer);
    // check if offer is not already confirmed
    require(offer.confirmed == false);
    // check if offer is not already canceled
    require(offer.canceled == false);
    // Execute instant payment to seller.
    offer.confirmed = true;

    OfferConfirmed(msg.sender, offerIndex);
  }

  function GetOfferById(uint offerIndex) public view existing(offerIndex) returns (string, string, bool, bool, address) {
    Offer storage offer = offers[offerIndex];
    return (offer.title, offer.description, offer.confirmed, offer.canceled, offer.buyer);
  }

  function GetBalanceByAddres(address addr) public view returns(uint) {
    return balanceEthForAddress[addr];
  }

  //   function GetAddresByString(string addr) private view returns(address) {

  //   }


  function RefundBuyer(address buyer, uint amount) private {
    pendingReturns[buyer] += amount;
    balanceEthForAddress[buyer] -= amount;
  }

  //   function PayToSeller(uint amount) private {

  //   }
}
