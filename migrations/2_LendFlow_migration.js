var Demo = artifacts.require("../contracts/LendFlow.sol");
module.exports = function(deployer) {
  // Demo is the contract's name
  deployer.deploy(Demo);
};