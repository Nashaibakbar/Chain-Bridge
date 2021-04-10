pragma solidity ^0.7.0;

import "./SafeMath.sol";
import "hardhat/console.sol";

contract TokenERC20{
    using SafeMath for uint;
    
    uint public totalSupply;
    string public name;
    string public symbol;
    uint decimal = 18;
    address masterOwner;
    
    mapping (address => uint) balances;
    mapping (address => mapping (address=> uint)) allownces;
    mapping (address => bool) owners;

    event Transfer(address  indexed from, address indexed to , uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
    event Mint(address indexed from, address indexed to, uint value);
    event Burn(address indexed from, address indexed to, uint value);

    constructor() public {
        masterOwner = msg.sender;
    }

    function balanceOf(address _user) external view returns(uint256){
        return balances[_user];
    }

    function setOwner(address _newowner) external {
        require(masterOwner== msg.sender,"TokenERC20: Not an MasterOwner");
        owners[_newowner] = true;
    }

    function getOwner(address _add) external view returns(bool){
        return owners[_add];
    }
    function initialize(string memory _name, string memory _symbol,uint _decimal) public {
        name = _name;
        symbol = _symbol;
        decimal = _decimal;
    }

    
    function _transfer(address _from, address _to , uint _value) private {
        require(_to!=address(0), "ERC20Token: Invalid Address");
        require(balances[_from] >= _value, "ERC20Token: INSUFFICIENT_BALANCE");
        balances[_from] = balances[_from].sub(_value);
        balances[_to] = balances[_to].add(_value);
        emit Transfer(_from, _to, _value);
    }

    function approve(address _spender, uint _value) external returns(bool){
        require(msg.sender==masterOwner,"ERC20Token: Invalid Owner");
        allownces[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return(true);
    }

    function transfer(address _from,address _to,uint _value) external returns(bool){
        _transfer(_from,_to,_value);
        return(true);
    }

    function transferFrom(address _from, address _to, uint _value) external returns(bool){
        require(allownces[_from][msg.sender] >= _value, "ERC20Token: Insufficient Allownce");
        allownces[_from][msg.sender] = allownces[_from][msg.sender].sub(_value);
        _transfer(_from, _to, _value);
        return(true);
    }

    function mint(address _to, uint _value) external returns(bool){
        console.log("Msg sender:",_to);
        require(msg.sender == masterOwner || owners[msg.sender] == true, "ERC20Token: Not have access to Mint");
        balances[_to]= balances[_to].add(_value);
        totalSupply = totalSupply.add(_value);
        return(true);
        emit Mint(address(0), _to, _value);
    }

    function burn(address _from , uint _value) external returns(bool){
        require(balances[_from] >= _value,"ERC20Token: Not have enough fund to burn");
        balances[_from] = balances[_from].sub(_value);
        totalSupply = totalSupply.sub(_value);
        return(true);
        emit Burn(_from,address(0),_value);
    }

}