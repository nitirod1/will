import { ethers } from "hardhat";
import hre from "hardhat";
import jsonFile from "jsonfile";

async function main() {
  const willFactory = await ethers.getContractFactory("WillFactory");
  const willFactoryContract = await willFactory.deploy();
  await willFactoryContract.deployed();
  const willToken = await ethers.getContractFactory("WillToken");
  const willTokenContract = await willToken.deploy(willFactoryContract.address);
  await willTokenContract.deployed();
  const realToken = await ethers.getContractFactory("RealToken");
  const realTokenContract = await realToken.deploy(willFactoryContract.address);
  await realTokenContract.deployed();
  const USDt = await ethers.getContractFactory("USDt");
  const USDtContract = await USDt.deploy();
  await USDtContract.deployed();
  console.log("willFactory deployed to:", willFactoryContract.address);
  console.log("willToken deployed to:", willTokenContract.address);
  console.log("USDt deployed to:", USDtContract.address);
  console.log("RealToken deployed to:", realTokenContract.address);
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
