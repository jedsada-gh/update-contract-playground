pragma solidity ^0.4.24;

import "./StorageState.sol";
import "./ProductStorageState.sol";
import "./Ownable.sol";


contract Proxy2 is StorageState, Ownable, ProductStorageState {
    
    constructor(ProductStorage product, Storage storage_) public {
        _product = product;
        _storage = storage_;
    }

    event Upgraded(address indexed implementation);

    address public _implementation;

    function implementation() public view returns (address) {
        return _implementation;
    }

    function upgradeTo(address impl) public onlyOwner {
        require(
            _implementation != impl,
            "Cannot upgrade to the same implementation."
        );
        _implementation = impl;
        emit Upgraded(impl);
    }
  
    function () public payable {
        address _impl = implementation();
        require(
            _impl != address(0),
            "Cannot set implementation to address(0)"
        );
        bytes memory data = msg.data;

        assembly {
            let result := delegatecall(gas, _impl, add(data, 0x20), mload(data), 0, 0)
            let size := returndatasize
            let ptr := mload(0x40)
            returndatacopy(ptr, 0, size)
            switch result
            case 0 { revert(ptr, size) }
            default { return(ptr, size) }
        }
    }
}