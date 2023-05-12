import { loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import { expect } from "chai";
import { ethers } from "hardhat";

describe("Test WillFactory", function () {
    async function deployTokenFixture() {
        const [owner, beneficiary] = await ethers.getSigners();
        const willFactoryContract = await ethers.getContractFactory("WillFactory");
        const willFactory = await willFactoryContract.deploy();
        await willFactory.deployed();
        const willTokenContract = await ethers.getContractFactory("WillToken");
        const willToken = await willTokenContract.deploy(willFactory.address);
        await willToken.deployed();
        const RealTokenContract = await ethers.getContractFactory("RealToken");
        const RealToken = await RealTokenContract.deploy(willFactory.address);
        await RealToken.deployed();
        const setWillTokenTX = await willFactory.setwillTokenAddress(willToken.address)
        await setWillTokenTX.wait();  
        const setRealTokenTX = await willFactory.setRealTokenAddress(RealToken.address)
        await setRealTokenTX.wait();  
        return { willFactory,willToken , RealToken, owner, beneficiary};
      }

    it("function set WillToken address connect to willFactory contract", async function () {
        const { willFactory , willToken} = await loadFixture(deployTokenFixture);
        expect(await willFactory.getwillTokenAddress()).to.equal(willToken.address)
    });

    it("function set RealToken address connect to willFactory contract", async function () {
        const { willFactory , RealToken} = await loadFixture(deployTokenFixture);
        expect(await willFactory.getRealTokenAddress()).to.equal(RealToken.address)
    });

    it("Create will should mint will token to msg.sender", async function () {
        const { willFactory , willToken , owner} = await loadFixture(deployTokenFixture);
        const createWill= await willFactory.createWill("test","test","testURI",)
        await createWill.wait();
        expect(await willToken.ownerOf(0)).to.equal(owner.address)
    });

    it("function registerID ",async function (){
        const {willFactory,owner} = await loadFixture(deployTokenFixture);
        const register = await willFactory.registerID("1419901939373",owner.address)
        await register.wait();
        expect(await willFactory.getRegister("1419901939373")).to.equal(owner.address)
    })

    it("function claim will should beneficiary receive will token from owner", async function (){
        const {willFactory,willToken,owner,beneficiary} = await loadFixture(deployTokenFixture);
        const createWill= await willFactory.createWill("test","test","testURI",)
        await createWill.wait();
        const tokenIds = await willFactory.getTokenIdOnwer(owner.address);
        const approveToken = await willToken.approve(willFactory.address,tokenIds[0]);
        await approveToken.wait();
        const will = await ethers.getContractFactory("Will");
        const willAddress = await willFactory.getTokendIdOfWill(tokenIds[0]);
        const willContract =await will.attach(willAddress)
        await willContract.setBeneficiary(beneficiary.address)
        await willFactory.claimWill(willAddress,tokenIds[0])
        expect(await willToken.ownerOf(tokenIds[0])).to.equal(beneficiary.address)
    });
    
    it("test require createWill not set will token address", async function (){
        const {willFactory} = await loadFixture(deployTokenFixture);
        const willTokenAddress =await willFactory.setwillTokenAddress(ethers.constants.AddressZero);
        await willTokenAddress.wait();
        await expect(willFactory.createWill("test","test","testURI")).to.be.revertedWith("address will token unset now !")
    });

    it("test require claimWill beneficiary not set value",async function(){
        const {willFactory,willToken,owner,beneficiary} = await loadFixture(deployTokenFixture);
        const createWill= await willFactory.createWill("test","test","testURI",)
        await createWill.wait();
        const tokenIds = await willFactory.getTokenIdOnwer(owner.address);
        const approveToken = await willToken.approve(willFactory.address,tokenIds[0]);
        await approveToken.wait();
        const will = await ethers.getContractFactory("Will");
        const willAddress = await willFactory.getTokendIdOfWill(tokenIds[0]);
        const willContract =await will.attach(willAddress)
        await willContract.setBeneficiary(ethers.constants.AddressZero)
        await expect(willFactory.claimWill(willAddress,tokenIds[0])).to.be.revertedWith("address beneficiary or owner not correctly registered")
    })
});