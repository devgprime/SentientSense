// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

/**
 * @title SenuCoin
 * @dev A standard ERC20 token contract for SenuCoin with additional functionalities and gas optimizations.
 */
contract SenuCoin is Ownable, ReentrancyGuard {
    using SafeMath for uint256;

    string public name = "SenuCoin";
    string public symbol = "SENU";
    uint8 public decimals = 18;
    uint256 public totalSupply;
    uint256 public constant MAX_SUPPLY = 1000000 * 10 ** 18;

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    /**
     * @dev Constructor to initialize the SenuCoin token with initial supply.
     * @param _initialSupply Initial supply of tokens to be minted.
     */
    constructor(uint256 _initialSupply) Ownable(msg.sender) { 
        require(_initialSupply <= MAX_SUPPLY, "Initial supply exceeds maximum");
        totalSupply = _initialSupply * 10 ** uint256(decimals);
        balanceOf[msg.sender] = totalSupply;
        emit Transfer(address(0), msg.sender, totalSupply);
    }

    /**
     * @dev Transfer tokens from sender to recipient.
     * @param _to Address of the recipient.
     * @param _value Amount of tokens to transfer.
     * @return A boolean indicating the success of the transfer.
     */
    function transfer(address _to, uint256 _value) public nonReentrant returns (bool) {
        require(_to != address(0), "Invalid address");
        require(balanceOf[msg.sender] >= _value, "Insufficient balance");

        balanceOf[msg.sender] = balanceOf[msg.sender].sub(_value);
        balanceOf[_to] = balanceOf[_to].add(_value);

        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    /**
     * @dev Approve spender to spend tokens on behalf of owner.
     * @param _spender Address of the spender.
     * @param _value Amount of tokens to approve.
     * @return A boolean indicating the success of the approval.
     */
    function approve(address _spender, uint256 _value) public returns (bool) {
        allowance[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    /**
     * @dev Transfer tokens from one address to another (using allowance).
     * @param _from Address from which tokens are transferred.
     * @param _to Address to which tokens are transferred.
     * @param _value Amount of tokens to transfer.
     * @return A boolean indicating the success of the transfer.
     */
    function transferFrom(address _from, address _to, uint256 _value) public nonReentrant returns (bool) {
        require(_to != address(0), "Invalid address");
        require(_value <= balanceOf[_from], "Insufficient balance");
        require(_value <= allowance[_from][msg.sender], "Allowance exceeded");

        balanceOf[_from] = balanceOf[_from].sub(_value);
        balanceOf[_to] = balanceOf[_to].add(_value);
        allowance[_from][msg.sender] = allowance[_from][msg.sender].sub(_value);

        emit Transfer(_from, _to, _value);
        return true;
    }

    /**
     * @dev Increase the allowance of a spender.
     * This function uses a gas-efficient pattern for updating allowances.
     * @param _spender The address of the spender.
     * @param _addedValue The amount of tokens to increase the allowance by.
     * @return A boolean indicating the success of the operation.
     */
    function increaseAllowance(address _spender, uint256 _addedValue) public returns (bool) {
        unchecked {  
            allowance[msg.sender][_spender] += _addedValue;
        }

        emit Approval(msg.sender, _spender, allowance[msg.sender][_spender]);
        return true;
    }
   
    /**
     * @dev Decrease the allowance of a spender.
     * This function uses a gas-efficient pattern for updating allowances.
     * @param _spender The address of the spender.
     * @param _subtractedValue The amount of tokens to decrease the allowance by.
     * @return A boolean indicating the success of the operation.
     */
    function decreaseAllowance(address _spender, uint256 _subtractedValue) public returns (bool) {
        uint256 currentAllowance = allowance[msg.sender][_spender];
        require(currentAllowance >= _subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            allowance[msg.sender][_spender] = currentAllowance - _subtractedValue;
        }

        emit Approval(msg.sender, _spender, allowance[msg.sender][_spender]);
        return true;
    }


    /**
     * @dev Mint new tokens (onlyOwner).
     * @param _recipient Address to which new tokens are minted.
     * @param _amount Amount of tokens to mint.
     */
    function mint(address _recipient, uint256 _amount) public onlyOwner {
        require(totalSupply.add(_amount) <= MAX_SUPPLY, "Exceeds maximum supply");

        totalSupply = totalSupply.add(_amount);
        balanceOf[_recipient] = balanceOf[_recipient].add(_amount);
        emit Transfer(address(0), _recipient, _amount);
    }

    /**
     * @dev Burn tokens from sender's balance.
     * @param _amount Amount of tokens to burn.
     */
    function burn(uint256 _amount) public nonReentrant {
        require(balanceOf[msg.sender] >= _amount, "Insufficient balance");
        balanceOf[msg.sender] = balanceOf[msg.sender].sub(_amount);
        totalSupply = totalSupply.sub(_amount);
        emit Transfer(msg.sender, address(0), _amount);
    }
}


