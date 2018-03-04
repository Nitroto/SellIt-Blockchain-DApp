pragma solidity ^0.4.18;

import "./Owned.sol";

contract SellItPayment is Owned {

  uint private _offersCount;

  ///////////////////////
  // GENERAL STRUCTURE //
  ///////////////////////
  struct Offer {
    address seller;
    address buyer;
    string title;
    string description;
    uint price;
    string addressForShipment;
    bool accepted;
    bool shipped;
    bool confirmed;
    bool canceled;
  }

  mapping(uint => Offer) offers;
  mapping(address => uint[]) sellingOffersByAddr;
  mapping(address => uint[]) buyingOffersByAddr;
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

  modifier isSeller(uint index) {
    assert(msg.sender == offers[index].seller);
    _;
  }

  modifier isBuyer(uint index) {
    assert(msg.sender == offers[index].buyer);
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
    sellingOffersByAddr[msg.sender].push(_offersCount);
    OfferPublished(msg.sender, _offersCount);
  }

  // Accept existing offer from user which is not seller. Buyer make payment to system or take from his deposit for the announced price.
  function AcceptOffer(uint offerIndex, string addressForShipment) public existing(offerIndex) {
    Offer storage offer = offers[offerIndex];
    require(msg.sender != offer.seller);
    // check if someone has already accepted the offer
    require(offer.buyer == address(0));
    // check if offer is not already canceled
    require(offer.canceled == false);
    // check is the transferred amount equal or higher to the price
    require(withdrawableFunds[msg.sender]  >= offer.price);
    // transfer eth from withdrawable to blocked funds
    withdrawableFunds[msg.sender] -= offer.price;
    blockedInContractEth[msg.sender] += offer.price;
    offer.buyer = msg.sender;
    offer.accepted = true;
    offer.confirmed = false;
    offer.addressForShipment = addressForShipment;
    buyingOffersByAddr[msg.sender].push(offerIndex);
    OfferAccepted(msg.sender, offerIndex);
  }

  // Seller can cancel existing offer if this offer is not confirmed yet. System allow buyer to withdraw the amount.
  function CancelOfferBySeller(uint offerIndex) public existing(offerIndex) {
    Offer storage offer = offers[offerIndex];
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
  function ConfirmOffer(uint offerIndex) public existing(offerIndex) isBuyer(offerIndex) {
    Offer storage offer = offers[offerIndex];
    // check if offer is not already confirmed
    require(offer.confirmed == false);
    // check if offer is not already canceled
    require(offer.canceled == false);
    offer.confirmed = true;
    PayToSeller(offer.buyer, offer.seller, offer.price);
    OfferConfirmed(msg.sender, offerIndex);
  }

  // Seller can confirm shippment
  function ConfirmShipping(uint offerIndex) public existing(offerIndex) isSeller(offerIndex) {
    Offer storage offer = offers[offerIndex];
    require(offer.confirmed == false);
    require(offer.canceled == false);
    offer.shipped = true;
    OfferShipped(msg.sender, offerIndex);
  }

  // Only seller can get shipment address
  function GetShipmentAddress(uint offerIndex) public view existing(offerIndex) isSeller(offerIndex) returns (string) {
    return offers[offerIndex].addressForShipment;
  }

  // Only seller and buyer can see offer status
  function GetOfferStatus(uint offerIndex) public view existing(offerIndex) returns (bool, bool, bool){
    Offer storage offer = offers[offerIndex];
    require(msg.sender == offer.seller || msg.sender == offer.buyer);
    return (offer.shipped, offer.confirmed, offer.canceled);
  }

  // Return offer info by offer id
  function GetOfferById(uint offerIndex) public view existing(offerIndex) returns (uint, string, string, uint, bool) {
    Offer storage offer = offers[offerIndex];
    return (offerIndex, offer.title, offer.description, offer.price, offer.accepted);
  }

  // Return selling offers of user
  function GetSellingOffers() public view returns (uint[]) {
    return sellingOffersByAddr[msg.sender];
  }

  // Return buying offers of user
  function GetBuyingOffers() public view returns (uint[]) {
    return buyingOffersByAddr[msg.sender];
  }

  // User can check blocked balances
  function GetBlockedBalance() public view returns (uint) {
    return blockedInContractEth[msg.sender];
  }

  // User can check withdrawabl balances
  function GetDepositBalance() public view returns (uint) {
    return withdrawableFunds[msg.sender];
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

  // Serialization of main structure
  function serializeOffer(uint offerIndex) private view returns (bytes data) {
    Offer storage offer = offers[offerIndex];
    uint _size = 4 + bytes(offer.title).length;
    bytes memory _data = new bytes(_size);

    uint counter = 0;
    for (uint i = 0; i < 4; i++) {
      data[counter] = byte(offerIndex >> (8 * i) & uint32(255));
      counter++;
    }

    for (i = 0; i < bytes(offer.title).length; i++)
    {
      _data[counter] = bytes(offer.title)[i];
      counter++;
    }

    return (_data);
  }
}
