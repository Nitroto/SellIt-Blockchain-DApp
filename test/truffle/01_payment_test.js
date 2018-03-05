let SellItPayment = artifacts.require('./SellItPayment.sol')

contract('SellItPayment', function (accounts) {
  let payment

  let _owner = accounts[0]

  beforeEach(async function () {
    payment = await SellItPayment.new({
      from: _owner
    })
  })

  it('it should create new instance of contract with 0 offers', async function () {
    let count = await payment.GetTotalNumberOfOffers.call()
    assert.strictEqual(count.toNumber(), 0, 'Contract is not initialized correctly')
  })

  it('it should create new offer in contract', async function () {
    let price = 1000
    let title = 'Title'
    let description = 'Description'
    await payment.PublishOffer(price, title, description)
    let count = await payment.GetTotalNumberOfOffers.call()
    assert.strictEqual(count.toNumber(), 1, 'Offer is not added')
  })

  it('it should create 2 new offers in contract', async function () {
    let price = 1000
    let title = 'Title'
    let description = 'Description'
    await payment.PublishOffer(price, title, description)
    await payment.PublishOffer(price, title, description)
    let count = await payment.GetTotalNumberOfOffers.call()
    assert.strictEqual(count.toNumber(), 2, 'Offers are not added')
  })

  it('it should save correct offer data', async function () {
    let price = 1000
    let title = 'Title'
    let description = 'Description'
    await payment.PublishOffer(price, title, description)
    let offer = await payment.GetOfferById(1)
    assert.strictEqual(offer[0].toNumber(), 1, 'Index is not set correctly')
    assert.strictEqual(offer[1].toString(), title, 'Title is not set correctly')
    assert.strictEqual(offer[2].toString(), description, 'Description is not set correctly')
    assert.strictEqual(offer[3].toNumber(), price, 'price is not set correctly')
    assert.equal(offer[4], false, 'Offer is set as accepted')
  })

  it('it should return correct statuses of offer', async function () {
    let price = 1000
    let title = 'Title'
    let description = 'Description'
    await payment.PublishOffer(price, title, description)
    let offerStatuses = await payment.GetOfferStatus(1)
    assert.equal(offerStatuses[0], false, 'Offer is set as shipped')
    assert.equal(offerStatuses[1], false, 'Offer is set as confirmed')
    assert.equal(offerStatuses[2], false, 'Offer is set as canceled')
  })

  it('it should return correct number of buying offers', async function () {
    let temp = await payment.GetSellingOffers()
    let sellingOffers = []
    temp.forEach(function (i) {
      sellingOffers.push(i.toNumber())
    })
    assert.strictEqual(sellingOffers.length, 0, 'count of selling offers is incorrect')
  })

  it('it should return correct number of selling offers', async function () {
    let price = 1000
    let title = 'Title'
    let description = 'Description'
    await payment.PublishOffer(price, title, description)
    await payment.PublishOffer(price, title, description)
    let temp = await payment.GetSellingOffers()
    let sellingOffers = []
    temp.forEach(function (i) {
      sellingOffers.push(i.toNumber())
    })
    assert.strictEqual(sellingOffers.length, 2, 'count of selling offers is incorrect')
    assert.deepEqual(sellingOffers, [1, 2], 'indexes are not correct')
  })

  it('it should return correct number of buying offers', async function () {
    let temp = await payment.GetBuyingOffers()
    let sellingOffers = []
    temp.forEach(function (i) {
      sellingOffers.push(i.toNumber())
    })
    assert.strictEqual(sellingOffers.length, 0, 'count of buying offers is incorrect')
  })

  it('it should cancel offer as seller', async function () {
    let price = 1000
    let title = 'Title'
    let description = 'Description'
    await payment.PublishOffer(price, title, description)
    await payment.CancelOfferBySeller(1)
    let offerStatuses = await payment.GetOfferStatus(1)
    assert.equal(offerStatuses[0], false, 'Shipped is not false')
    assert.equal(offerStatuses[1], false, 'Confirm is not false')
    assert.equal(offerStatuses[2], true, 'Cancel is not true')
  })

  xit('it shouldn\'t ship offer after cancellation', async function () {
    let price = 1000
    let title = 'Title'
    let description = 'Description'
    await payment.PublishOffer(price, title, description)
    await payment.CancelOfferBySeller(1)
    assert.throws(await payment.ConfirmShipping(1), 'Error thrown must be a Error')
  })

  it('it should shipped offer', async function () {
    let price = 1000
    let title = 'Title'
    let description = 'Description'
    await payment.PublishOffer(price, title, description)
    await payment.ConfirmShipping(1)
    let offerStatuses = await payment.GetOfferStatus(1)
    assert.equal(offerStatuses[0], true, 'Shipped is not true')
    assert.equal(offerStatuses[1], false, 'Confirm is not false')
    assert.equal(offerStatuses[2], false, 'Cancel is not false')
  })

  it('it should cancel after shipment', async function () {
    let price = 1000
    let title = 'Title'
    let description = 'Description'
    await payment.PublishOffer(price, title, description)
    await payment.ConfirmShipping(1)
    await payment.CancelOfferBySeller(1)
    let offerStatuses = await payment.GetOfferStatus(1)
    assert.equal(offerStatuses[0], true, 'Shipped is not true')
    assert.equal(offerStatuses[1], false, 'Confirm is not false')
    assert.equal(offerStatuses[2], true, 'Cancel is not true')
  })

  it('it should deposit 1 eth to contract', async function () {
    let transfer = 1000000000000000000
    await payment.Deposit({value: transfer, from: accounts[0]})
    let balance = await payment.GetDepositBalance()
    assert.strictEqual(balance.toNumber(), transfer, 'Incorrect balance')
  })

  it('it should deposit 3 eth to contract', async function () {
    let transfer = 1000000000000000000
    await payment.Deposit({value: transfer, from: accounts[0]})
    await payment.Deposit({value: transfer, from: accounts[0]})
    await payment.Deposit({value: transfer, from: accounts[0]})
    let balance = await payment.GetDepositBalance()
    assert.strictEqual(balance.toNumber(), 3 * transfer, 'Incorrect balance')
  })

  it('it should deposit 3 eth to contract and then withdraw them', async function () {
    let transfer = 1000000000000000000
    await payment.Deposit({value: transfer, from: accounts[0]})
    await payment.Deposit({value: transfer, from: accounts[0]})
    await payment.Deposit({value: transfer, from: accounts[0]})
    await payment.Withdraw(3000000000000000000, {from: accounts[0]})
    let balance = await payment.GetDepositBalance()
    assert.strictEqual(balance.toNumber(), 0, 'Incorrect balance')
  })

  it('it should accept offer', async function () {
    let price = 1000
    let title = 'Title'
    let description = 'Description'
    await payment.PublishOffer(price, title, description)
    let transfer = 1000000000000000000
    await payment.Deposit({value: transfer, from: accounts[1]})
    await payment.AcceptOffer(1, 'home', {from: accounts[1]})
    let offer = await payment.GetOfferById(1)
    let balance = await payment.GetBlockedBalance({from: accounts[1]})
    assert.equal(offer[4], true, 'Offer is not accepted')
    assert.strictEqual(balance.toNumber(), price, 'Blocked sum is not correct')
  })

  xit('it should cancel offer as buyer', async function () {
    let price = 1000
    let title = 'Title'
    let description = 'Description'
    await payment.PublishOffer(price, title, description)
    let transfer = 1000000000000000000
    await payment.Deposit({value: transfer, from: accounts[1]})
    await payment.AcceptOffer(1, 'home', {from: accounts[1]})
    await payment.CancelOfferByBuyer(1, {from: accounts[1]})
    let offerStatuses = await payment.GetOfferStatus(1)
    let balancBlocked = await payment.GetBlockedBalance({from: accounts[1]})
    let balancDeposit = await payment.Withdraw({from: accounts[1]})
    assert.equal(offerStatuses[0], false, 'Shipped is not true')
    assert.equal(offerStatuses[1], false, 'Confirm is not false')
    assert.equal(offerStatuses[2], true, 'Cancel is not true')
    assert.strictEqual(balancBlocked.toNumber(), 0, 'Buyer balance is incorrect')
    assert.strictEqual(balancDeposit.toNumber(), transfer, 'Buyer balance is incorrect')

  })

  it('it should confirm offer', async function () {
    let price = 1000
    let title = 'Title'
    let description = 'Description'
    await payment.PublishOffer(price, title, description)
    let transfer = 1000000000000000000
    await payment.Deposit({value: transfer, from: accounts[1]})
    await payment.AcceptOffer(1, 'home', {from: accounts[1]})
    await payment.ConfirmOffer(1, {from: accounts[1]})
    let offerStatuses = await payment.GetOfferStatus(1)
    let balanceBuyer = await payment.GetBlockedBalance({from: accounts[1]})
    let balanceSeller = await payment.GetDepositBalance({from: accounts[0]})
    assert.equal(offerStatuses[0], false, 'Shipped is not true')
    assert.equal(offerStatuses[1], true, 'Confirm is not false')
    assert.equal(offerStatuses[2], false, 'Cancel is not false')
    assert.strictEqual(balanceBuyer.toNumber(), 0, 'Buyer balance is incorrect')
    assert.strictEqual(balanceSeller.toNumber(), price, 'Seller balance is incorrect')
  })

})
