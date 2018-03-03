const Converter = {
  toEth: function (amount, unit) {
    switch (unit) {
      case 'wei':
        return amount / 1000000000000000000
      case 'gwei':
        return amount / 1000000000
      case 'finney':
        return amount / 1000
      default:
        return amount
    }
  },

  toWei: function (amount, unit) {
    switch (unit) {
      case 'ether':
        return amount * 1000000000000000000
      case 'finney':
        return amount * 1000000000000000
      case 'gwei':
        return amount * 1000000000
      default:
        return amount
    }
  },

  toRealMoney: function (amount, price) {
    return amount * price
  }
}

export default Converter
