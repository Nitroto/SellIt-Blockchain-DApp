let Users = artifacts.require("./Users.sol");
let SellItPayment = artifacts.require("./SellItPayment.sol")

module.exports = function(deployer) {
  deployer.deploy(Users);
  deployer.deploy(SellItPayment);
};
