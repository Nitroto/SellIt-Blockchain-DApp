import contract from 'truffle-contract'
import PaymentContract from '@contracts/SellItPayment.json'

const Payment = {

  contract: null,

  instance: null,

  init: function () {
    let self = this

    return new Promise(function (resolve, reject) {
      // SellItPayment
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
    let self = this

    return new Promise((resolve, reject) => {

    })
  },

  depositEther: function (amount) {

  },

  exists: function (address) {
    let self = this

    return new Promise((resolve, reject) => {
      self.instance.exists.call(
        address || window.web3.eth.defaultAccount,
        {from: window.web3.eth.accounts[0]}
      ).then(exists => {
        resolve(exists)
      }).catch(err => {
        reject(err)
      })
    })
  }
}

export default Payment
