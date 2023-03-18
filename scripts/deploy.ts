import { ethers } from "hardhat";
import hre from "hardhat";
import jsonFile from "jsonfile";

async function main() {
  const asset = await ethers.getContractFactory("FactoryAsset");
  const will = await ethers.getContractFactory("Will");
  const assetContract = await asset.deploy();
  await assetContract.deployed();
  console.log("asset deployed to:", assetContract.address);

  const willContract = await will.deploy(assetContract.address);
  await willContract.deployed();
  console.log("will deployed to:", willContract.address);

  jsonFile.writeFileSync("config.json", {
    asset: assetContract.address,
    will:willContract.address
  });
}
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
