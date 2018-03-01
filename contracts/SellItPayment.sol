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
    string buyerAddres;
    bool shipped;
    bool confirmed;
    bool canceled;
  }

  mapping(uint => Offer) offers;

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
    if (_offersCount > 0) {
      _;
    }
    if (index <= _offersCount) {
      _;
    }
  }

  ////////////////////////
  // MAIN FUNCTIONALITY //
  ////////////////////////
  function SellItPayment() public {
    _offersCount = 0;
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
    require(msg.sender != offer.seller);
    require(offer.buyer == address(0));
    require(!offer.canceled);
    // Add payment to owner address affter confirmation of client owner should transfer amount to seller!
    offer.buyer = msg.sender;
    offer.confirmed = false;
    offer.buyerAddres = addressForShipment;
    OfferAccepted(msg.sender, offerIndex);
  }

  // Seller can cancel existing offer if this offer is not confirmed yet. System refund buyer.
  function CancelOfferBySeller(uint offerIndex) public existing(offerIndex) {
    Offer storage offer = offers[offerIndex];
    require(msg.sender == offer.seller);
    require(!offer.confirmed);
    require(!offer.canceled);
    offer.canceled = true;
    // Refund buyer
    OfferCanceledBySeller(msg.sender, offerIndex);
  }

  // Buyer can cancel accepted offer if is accepted by him and offer is not shipped yet. System will refund buyer.
  function CancelOfferByBuyer(uint offerIndex) public existing(offerIndex) {
    Offer storage offer = offers[offerIndex];
    require(msg.sender == offer.buyer);
    require(!offer.shipped);
    require(!offer.canceled);
    offer.canceled = true;
    // Refund buyer
    OfferCanceledByBuyer(msg.sender, offerIndex);
  }

  // Buyer confirm receiving of offered item or service and system make payment to seller
  function ConfirmOffer(uint offerIndex) public existing(offerIndex) {
    Offer storage offer = offers[offerIndex];
    require(msg.sender == offer.buyer);
    require(!offer.confirmed);
    offer.confirmed = true;
    // Add payment to seller!
    OfferConfirmed(msg.sender, offerIndex);
  }

  //function GetOfferById(uint offerIndex) public view {
  //
  // }
}
