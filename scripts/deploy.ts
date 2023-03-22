import { ethers } from "hardhat";
import hre from "hardhat";
import jsonFile from "jsonfile";

async function main() {
  const willFactory = await ethers.getContractFactory("willFactory");
  const willFactoryContract = await willFactory.deploy();
  await willFactoryContract.deployed();
  console.log("willFactory deployed to:", willFactoryContract.address);

  // const will = await ethers.getContractFactory("Will");
  // const willContract = await will.deploy(assetContract.address);
  // await willContract.deployed();
  // console.log("will deployed to:", willContract.address);

  // jsonFile.writeFileSync("config.json", {
  //   asset: assetContract.address,
  //   will:willContract.address
  // });
}
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
