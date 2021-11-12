const hre = require("hardhat");


async function main() {
  const EDI = await hre.ethers.getContractFactory("EDI");
  const edi = await EDI.deploy();

  await edi.deployed();

  console.log("EDI deployed to:", edi.address);
  console.log('Factopry', EDI)

}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
