// npx hardhat run scripts/deploy_paymentSettlement.js

const { ethers, upgrades } = require("hardhat");

async function main() {
  // Get the signer (deployer) account
  const [deployer] = await ethers.getSigners();

  console.log("Deploying contracts with the account:", deployer.address);

  // Get the contract factory for the PaymentSettlement contract
  const PaymentSettlement = await ethers.getContractFactory("PaymentSettlement");
  console.log("✅ Contract factory loaded: PaymentSettlement");

  // Define the constructor parameters for PaymentSettlement
  const sibTelAddress = "0xeBD4A6BC935E1FBB338efc2b82c4333Cd529e6b2"; // Replace with actual SIBTEL contract address
  const stablecoinAddress = "0xb9915C43421eE77bEe6c12EE49a5C94fee754Ae6"; // Replace with actual stablecoin contract address
  const centralAuthorityAddress = "0x8Be6Aa4A54b79075D486B154046c6c324A85B93E"; // Replace with actual central authority address

  // Deploy the PaymentSettlement contract as a proxy (UUPS upgradeable)
  console.log("Deploying PaymentSettlement contract as a proxy...");
  const paymentSettlementProxy = await upgrades.deployProxy(
    PaymentSettlement,
    [sibTelAddress, stablecoinAddress, centralAuthorityAddress], // Constructor arguments for initialize
    { initializer: "initialize" } // Use the initialize function (since it's upgradeable)
  );
  
  await paymentSettlementProxy.waitForDeployment(); // Wait for the deployment to complete
  // Nous attendons que le contrat soit entièrement déployé
  await paymentSettlementProxy.deploymentTransaction().wait();

  // Log the deployed contract address
  //console.log("Contract deployed and mined:", paymentSettlementProxy);
  console.log(`L'adresse du contrat intelligent  Payment Settlement est ${paymentSettlementProxy.target}`);
}

// Execute the deployment script
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
