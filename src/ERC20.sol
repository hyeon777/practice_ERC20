// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./EIP712.sol";

contract ERC20 is EIP712 {
    mapping(address => uint256) private balances;
    mapping(address => mapping(address => uint256)) private allowances;
    uint256 private _totalSupply;

    address public owner;
    string private _name;
    string private _symbol;
    string private _version;
    uint8 private _decimals;
    bool public pause_check = false;
    mapping(address => uint256) public nonces;
    mapping(address => mapping(address=>uint256)) public permit_list;
    address[] public address_list;

    constructor(string memory name, string memory symbol) EIP712(name, "1") {
        owner = msg.sender;
        _name = name;
        _symbol = symbol;
        //_totalSupply = 100 ether;
        balances[msg.sender] = 100 ether;
        _decimals = 18;
        //_mint(msg.sender, 100 ether);
    }

    function name() public view returns (string memory){
        return _name;
    }


    function symbol() public view returns (string memory){
        return _symbol;
    }

    function decimals() public view returns (uint8){
        return _decimals;
    }

    function totalSupply() public view returns (uint256){
        return _totalSupply;
    }

    function balanceOf(address _owner) public view returns (uint256){
        return balances[_owner];
    }


    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    
    function pause() public {
        require(msg.sender == owner);
        pause_check = true;
    }
    function permit(address owner, address spender, uint256 value, uint256 deadline, uint8 v, bytes32 r, bytes32 s) public {
        require(block.timestamp <= deadline);

        bytes32 hash = keccak256(abi.encode(
            keccak256("Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)"), 
            owner, 
            spender, 
            value, 
            nonces[owner], 
            deadline)
        );
        bytes32 digest = _toTypedDataHash(hash);
        address user = ecrecover(digest,v,r,s);
        require(user == owner, "INVALID_SIGNER");

        nonces[owner] += 1;
        allowances[owner][spender] = value;

        emit Approval(owner, spender, value);

    }
    function transfer(address _to, uint256 _value) external returns (bool succcess) {
        require(_to != address(0), "transfer to the zero address");
        require(balances[msg.sender] >= _value, "value exceeds balance");
        require(pause_check == false);

        unchecked {
            balances[msg.sender] -= _value;
            balances[_to] += _value;
        }

        emit Transfer(msg.sender, _to, _value);
    }

    function approve(address _spender, uint256 _value) public returns (bool success){
        require(_spender != address(0), "approve to the zero address");

        allowances[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
    }

    function allowance(address _owner, address _spender) public view returns (uint256){
        return allowances[_owner][_spender];
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success){
        require(_to != address(0), "transfer to the zero address");
        require(_to != address(0), "transfer to the zero address");
        require(pause_check == false);
        
        uint256 currentAllowance = allowance(_from, msg.sender);
        require(currentAllowance >= _value, "insufficient allowance");
        unchecked {
            allowances[_from][msg.sender] -= _value;
        }

        require(balances[_from] >= _value, "value exceeds balance");

        unchecked {
            balances[_from] -= _value;
            balances[_to] += _value;
        }

        emit Transfer(_from, _to, _value);
    }

    function _mint(address _owner, uint256 _value) internal {
        require(_owner != address(0), "mint to the zero address");
        _totalSupply += _value;
        unchecked {
            balances[_owner] += _value;
        }
        emit Transfer(address(0), _owner, _value);
    }

    function _burn(address _owner, uint256 _value) internal {
        require(_owner != address(0), "burn from the zero address");
        require(balances[_owner] >= _value, "burn amount exceeds balance");
        unchecked {
            balances[_owner] -= _value;
            _totalSupply -= _value;
        }
        emit Transfer(_owner, address(0), _value);
    }
}