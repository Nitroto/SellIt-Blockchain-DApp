import contract from 'truffle-contract'
import PaymentContract from '@contracts/SellItPayment.json'

const Payment = {

  contract: null,

  instance: null,

  init: function () {
    let self = this

    return new Promise(function (resolve, reject) {
      self.contract = contract(PaymentContract)
      self.contract.setProvider(window.web3.currentProvider)
      self.contract.deployed().then(instance => {
        self.instance = instance
        resolve()
      }).catch(err => {
        reject(err)
      })
    })
  },

  listenToEvents: function () {
    this.instance.allEvents(
      {},
      {fromBlock: 0, toBLock: 'latest'}
    ).watch(function (error, result) {
      if (error) {
        console.log(error)
      } else {
        console.log(result)
      }
    })
  },

  depositEther: function (amountInWei) {
    let self = this

    return new Promise((resolve, reject) => {
      self.instance.Deposit(
        {
          value: amountInWei,
          from: window.web3.eth.accounts[0]
        }
      ).then(tx => {
        resolve(tx)
      }).catch(err => {
        reject(err)
      })
    })
  },

  withdrawEther: function (amountInWei) {
    let self = this

    return new Promise((resolve, reject) => {
      self.instance.Withdraw(
        amountInWei,
        {from: window.web3.eth.accounts[0]}
      ).then(tx => {
        resolve(tx)
      }).catch(err => {
        reject(err)
      })
    })
  },

  getDeposit: function () {
    let self = this

    return new Promise((resolve, reject) => {
      self.instance.GetDepositBalance.call(
        {from: window.web3.eth.accounts[0]}
      ).then(balance => {
        resolve(balance)
      }).catch(err => {
        reject(err)
      })
    })
  },

  getPending: function () {
    let self = this

    return new Promise((resolve, reject) => {
      self.instance.GetBlockedBalance.call(
        {from: window.web3.eth.accounts[0]}
      ).then(balance => {
        resolve(balance)
      }).catch(err => {
        reject(err)
      })
    })
  },

  postOffer: function (title, description, price) {
    let self = this

    return new Promise((resolve, reject) => {
      self.instance.PublishOffer(
        price,
        title,
        description,
        {from: window.web3.eth.accounts[0]}
      ).then(offer => {
        resolve(offer)
      }).catch(err => {
        reject(err)
      })
    })
  },

  getOfferById: function (id) {
    let self = this

    return new Promise((resolve, reject) => {
      self.instance.GetOfferById.call(
        id,
        {from: window.web3.eth.accounts[0]}
      ).then(tx => {
        resolve(tx)
      }).catch(err => {
        reject(err)
      })
    })
  },

  acceptOffer: function (id, address) {
    let self = this

    return new Promise((resolve, reject) => {
      self.instance.AcceptOffer(
        id,
        address,
        {from: window.web3.eth.accounts[0]}
      ).then(balance => {
        resolve(balance)
      }).catch(err => {
        reject(err)
      })
    })
  },

  cancelOfferAsSeller: function (id) {
    let self = this

    return new Promise((resolve, reject) => {
      self.instance.CancelOfferBySeller(
        id,
        {from: window.web3.eth.accounts[0]}
      ).then(tx => {
        resolve(tx)
      }).catch(err => {
        reject(err)
      })
    })
  },

  cancelOfferAsBuyer: function (id) {
    let self = this

    return new Promise((resolve, reject) => {
      self.instance.CancelOfferByBuyer(
        id,
        {from: window.web3.eth.accounts[0]}
      ).then(tx => {
        resolve(tx)
      }).catch(err => {
        reject(err)
      })
    })
  },

  confirmOffer: function (id) {
    let self = this

    return new Promise((resolve, reject) => {
      self.instance.ConfirmOffer(
        id,
        {from: window.web3.eth.accounts[0]}
      ).then(tx => {
        resolve(tx)
      }).catch(err => {
        reject(err)
      })
    })
  },

  confirmShipping: function (id) {
    let self = this

    return new Promise((resolve, reject) => {
      self.instance.ConfirmShipping(
        id,
        {from: window.web3.eth.accounts[0]}
      ).then(tx => {
        resolve(tx)
      }).catch(err => {
        reject(err)
      })
    })
  },

  getNumberOfOffers: function () {
    let self = this

    return new Promise((resolve, reject) => {
      self.instance.GetTotalNumberOfOffers(
        {from: window.web3.eth.accounts[0]}
      ).then(count => {
        resolve(count)
      }).catch(err => {
        reject(err)
      })
    })
  },

  getIndexesOfSellingOffers: function () {
    let self = this

    return new Promise((resolve, reject) => {
      self.instance.GetSellingOffers(
        {from: window.web3.eth.accounts[0]}
      ).then(indexes => {
        resolve(indexes)
      }).catch(err => {
        reject(err)
      })
    })
  },

  getIndexesOfBuyingOffers: function () {
    let self = this

    return new Promise((resolve, reject) => {
      self.instance.GetBuyingOffers(
        {from: window.web3.eth.accounts[0]}
      ).then(indexes => {
        resolve(indexes)
      }).catch(err => {
        reject(err)
      })
    })
  },

  getOfferStatus: function (id) {
    let self = this

    return new Promise((resolve, reject) => {
      self.instance.GetOfferStatus(
        id,
        {from: window.web3.eth.accounts[0]}
      ).then(result => {
        resolve(result)
      }).catch(err => {
        reject(err)
      })
    })
  },

  getShipmentAddress: function (id) {
    let self = this

    return new Promise((resolve, reject) => {
      self.instance.GetShipmentAddress(
        id,
        {from: window.web3.eth.accounts[0]}
      ).then(address => {
        resolve(address)
      }).catch(err => {
        reject(err)
      })
    })
  }
}

export default Payment
