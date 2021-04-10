//SPDX-License-Identifier: Unlicense
pragma solidity ^0.7.0;

import "hardhat/console.sol";
import "./TokenERC20.sol";
import "./SafeMath.sol";

contract MyBridge {

  using SafeMath for uint;

  mapping (address => address) pairFor;
  mapping (address => address) pairTo;
  mapping (uint => bool) executed;
  

  function withdrawTokens(uint8 v , bytes32 r , bytes32 s, uint _transId, uint _amount, address _token, string calldata _name, string calldata _symbol, uint8 _decimal) external payable {
    require(executed[_transId] == false , "Already Withdraw Done");
    bytes32 message = keccak256(abi.encode(_transId,msg.sender,_amount,_token,_name,_symbol,_decimal));
    bytes32 signHash = keccak256(abi.encode("\x19Ethereum Signed Message:\n32",message));
    require(_verify(signHash, v,r,s, msg.sender) == true, "MyBridge: INVALID SINGER");
    require(_amount > 0 , "MyBridge: Nothing To Withdraw");

    if(pairTo[_token]==address(0)){
      _createToken(_token,_name,_symbol,_decimal);
    }
    TokenERC20(pairTo[_token]).mint(msg.sender,_amount);
    executed[_transId]=true;
  }


  function _createToken(address _transitToken, string memory _name , string memory _symbol , uint _decimal) internal {
    bytes memory bytecode = type(TokenERC20).creationCode;
    bytes32 salt = keccak256(abi.encodePacked(_transitToken, _name, _symbol,_decimal));
    address  bscToken;
    assembly{
      bscToken:=create2(0,add(bytecode,32),mload(bytecode),salt)
    }
    TokenERC20(bscToken).initialize(_name,_symbol,_decimal);
    pairFor[bscToken]= _transitToken;
    console.log("bscToken:",bscToken);
    pairTo[_transitToken] = bscToken;
    console.log("TranitToken",_transitToken);
  }

  function _verify(bytes32 _signHash, uint8 v ,bytes32 r , bytes32 s, address _singer) internal view returns(bool){
      return (ecrecover(_signHash,v,r,s) == _singer);
  }

  }
  
