import { loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import { expect } from "chai";
import { ethers } from "hardhat";

describe("Test Will ", function () {
    async function deployWillFactory() {
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
        const createWill= await willFactory.createWill("test","test","testURI",)
        await createWill.wait();
        const tokenIds = await willFactory.getTokenIdOnwer(owner.address);
        const approveToken = await willToken.approve(willFactory.address,tokenIds[0]);
        await approveToken.wait();
        const willContract = await ethers.getContractFactory("Will");
        const willAddress = await willFactory.getTokendIdOfWill(tokenIds[0]);
        const will = await willContract.attach(willAddress)
        await will.setBeneficiary(beneficiary.address)
        const USDtContract = await ethers.getContractFactory("USDt");
        const USDt = await USDtContract.deploy();
        await USDt.deployed();
        return { will, RealToken,willFactory , USDt, owner, beneficiary };
    }

    async function depositRealToken(){
        const {will,RealToken,owner,beneficiary} = await loadFixture(deployWillFactory);
        const realAsset = await will.depositRealAsset("testName","testDescription","testURI");
        await realAsset.wait();
        const tokenIds= await will.getRealTokenId()
        const tokenId = await tokenIds[0]
        await RealToken.approve(will.address,tokenId);
        return {will,RealToken,tokenId,owner,beneficiary}
    }

    it("function getRealTokenAddress ", async function (){
        const {RealToken,will} = await loadFixture(depositRealToken);
        expect(await will.getRealTokenAddress()).to.equal(RealToken.address);
    });

    it("function depositRealToken real token should assign to owner", async function (){
        const {RealToken,tokenId,owner} = await loadFixture(depositRealToken);
        expect(await RealToken.ownerOf(tokenId)).to.equal(owner.address);
    });

    it("function getNameTokenID ",async function (){
        const {will} = await loadFixture(depositRealToken);
        const tokenId = await will.getWillTokenId()
        expect(await will.getNameRealToken(tokenId)).to.equal("testName");
    });

    it("function getDescRealToken ",async function (){
        const {will} = await loadFixture(depositRealToken);
        const tokenId = await will.getWillTokenId()
        expect(await will.getDescRealToken(tokenId)).to.equal("testDescription");
    });

    it("function withdrawRealToken real token should assign to owner", async function (){
        const {will,RealToken,tokenId,beneficiary} = await loadFixture(depositRealToken);
        const withdraw = await will.withdrawRealAsset(tokenId)
        await withdraw.wait();
        expect(await RealToken.ownerOf(tokenId)).to.equal(beneficiary.address);
    });

    it("function depositBalance ERC20 should assign manage to will contract", async function (){
        const {will,USDt} = await loadFixture(deployWillFactory);
        const USDtApproval = await USDt.approve(will.address,1000);
        await USDtApproval.wait();
        const depositBalance = await will.depositBalance(USDt.address,1000);
        await depositBalance.wait();
        expect(await will.getBalance(USDt.address)).to.equal(1000);
    });

    it("function withdrawBalance should assign to beneficiary", async function (){
        const {will,USDt} = await loadFixture(deployWillFactory);
        const USDtApproval = await USDt.approve(will.address,1000);
        await USDtApproval.wait();
        const depositBalance = await will.depositBalance(USDt.address,1000);
        await depositBalance.wait();
        const withdraw = await will.withdrawBalance(USDt.address,50);
        await withdraw.wait();
        expect(await will.getBalance(USDt.address)).to.equal(950);
    });

    it("test require withdrawBalance msg.sender have not willToken", async function (){
        const {will,willFactory,USDt} = await loadFixture(deployWillFactory);
        const claim = await willFactory.claimWill(will.address,0)
        await claim.wait();
        const USDtApproval = await USDt.approve(will.address,1000);
        await USDtApproval.wait();
        const depositBalance = await will.depositBalance(USDt.address,1000);
        await depositBalance.wait();
        await expect(  will.withdrawBalance(USDt.address,50)).to.be.rejectedWith("will token not active");
    });

    it("test require withdrawBalance balance not enough", async function (){
        const {will,USDt} = await loadFixture(deployWillFactory);
        await expect( will.withdrawBalance(USDt.address,100)).to.be.rejectedWith("balance must be positive");
    });

    it("test require depositBalance wallet have not balance enough", async function (){
        const {will,USDt} = await loadFixture(deployWillFactory);
        const USDtApproval = await USDt.approve(will.address,ethers.utils.parseUnits("5", 20));
        await USDtApproval.wait();
        await expect( will.depositBalance(USDt.address,ethers.utils.parseUnits("5", 20))).to.be.rejectedWith("balance not enough");
    });

    it("test require withdrawRealToken msg.sender have not willToken", async function (){
        const {will,willFactory} = await loadFixture(deployWillFactory);
        const claim = await willFactory.claimWill(will.address,0)
        await claim.wait();
        await expect( will.withdrawRealAsset(0)).to.be.rejectedWith("will token not active");
    });

    it("test require withdrawRealToken msg.sender have not willToken", async function (){
        const {will,willFactory} = await loadFixture(deployWillFactory);
        const setBeneficiary = await will.setBeneficiary(ethers.constants.AddressZero)
        await setBeneficiary.wait();
        await expect( will.withdrawRealAsset(0)).to.be.rejectedWith("address beneficiary or owner not correctly registered");
    });
})