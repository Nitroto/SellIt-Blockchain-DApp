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
    // let self = this

    return new Promise((resolve, reject) => {

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
      self.instance.Withraw(
        amountInWei,
        {from: window.web3.eth.accounts[0]}
      ).then(tx => {
        resolve(tx)
      }).catch(err => {
        reject(err)
      })
    })
  },

  getDeposit: function (address) {
    let self = this

    return new Promise((resolve, reject) => {
      self.instance.GetDepositBalanceByAddres.call(
        address || window.web3.eth.accounts[0],
        {from: window.web3.eth.accounts[0]}
      ).then(balance => {
        resolve(balance)
      }).catch(err => {
        reject(err)
      })
    })
  },

  getPending: function (address) {
    let self = this

    return new Promise((resolve, reject) => {
      self.instance.GetBlockedBalanceByAddres.call(
        address || window.web3.eth.accounts[0],
        {from: window.web3.eth.accounts[0]}
      ).then(balance => {
        resolve(balance)
      }).catch(err => {
        reject(err)
      })
    })
  }
}

export default Payment
