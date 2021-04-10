const {expect} = require('chai');
const {waffle, ethers} = require('hardhat');
const provider = waffle.provider;
const web3 = require("web3");
const {
    defaultAbiCoder,
    hexlify,
    keccak256,
    toUtf8Bytes,
    solidityPack
  } = require("ethers/lib/utils");
const { ecsign } = require("ethereumjs-util");
const { Wallet } = require('ethers');


describe("Check Deployment", () => {
   
        const [owner,account1] = provider.getWallets();
        let mybridge;
        let MyBridge;
        let tokenErc20;
        let TokenERC20;

    beforeEach( async() =>{
          MyBridge =   await ethers.getContractFactory("MyBridge");
          mybridge = await MyBridge.deploy();
          TokenERC20 = await ethers.getContractFactory("TokenERC20");
          tokenErc20 =await TokenERC20.deploy();
    })
    
    it("Withdraw Coins", async() => {

        const _transId =1;
        const _amount =10;
        const _name = "FarhanCoin";
        const _symbol= "frx";
        const _decimal =18;
        let _token = await tokenErc20.address;
        tokenErc20.setOwner(mybridge.address);
        console.log("Bridge address",mybridge.address);
        var msg = keccak256(defaultAbiCoder.encode(
        ["uint","address","uint","address","string","string","uint8"],
        [_transId,owner.address,_amount,_token,_name,_symbol,_decimal]));
        var msghash = keccak256(defaultAbiCoder.encode(
        ["string","bytes32"],["\x19Ethereum Signed Message:\n32",msg]));
         const { v,r,s } = ecsign(Buffer.from(msghash.slice(2), 'hex'),
         Buffer.from(owner._signingKey().privateKey.slice(2),'hex'));
         await mybridge.withdrawTokens(v,hexlify(r),hexlify(s),_transId,_amount,_token,_name,_symbol,_decimal);  
         console.log('Sender:',owner.address)    
         console.log('Balance : ',Number(await tokenErc20.balanceOf(owner.address)));
         console.log('totalSupply: ',Number(await tokenErc20.totalSupply()));
         console.log('Token Name: ',await tokenErc20.symbol());
         const bsctoken = mybridge.pairTo[_token];
         console.log(bsctoken);
    }); 
});