import { loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import { expect } from "chai";
import { ethers } from "hardhat";

describe("Test USDt Contract", function () {
    async function deployUSDt() {
        const [owner,beneficiary] = await ethers.getSigners();
        const USDtContract = await ethers.getContractFactory("USDt");
        const USDt = await USDtContract.deploy();
        await USDt.deployed();
        return {USDt,owner,beneficiary}
    }


    it("function mint", async function (){
        const {USDt,beneficiary} = await loadFixture(deployUSDt);
        const mint = await USDt.mint(beneficiary.address,100);
        await mint.wait();
        expect(await USDt.balanceOf(beneficiary.address)).to.equal(100);
    });
});