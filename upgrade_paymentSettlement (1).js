// scripts/upgrade_paymentSettlement.js

const { ethers, upgrades } = require("hardhat");

async function main() {
  // Get the deployer signer
  const [deployer] = await ethers.getSigners();

  console.log("Upgrading contracts with the account:", deployer.address);

  // Get the contract factory for the new version (PaymentSettlementV2)
  const PaymentSettlementV2 = await ethers.getContractFactory("PaymentSettlementV2");

  // Get the address of the proxy (the deployed proxy address from before)
  const proxyAddress = "0xYourDeployedProxyAddress"; // Replace with actual proxy address

  console.log("Upgrading proxy contract at address:", proxyAddress);

  // Upgrade the contract
  const upgraded = await upgrades.upgradeProxy(proxyAddress, PaymentSettlementV2);

  console.log("PaymentSettlement upgraded to:", upgraded.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });