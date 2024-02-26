pragma solidity ^0.8.24;

contract KeyStore {
    bytes private decryptionKey;
    address immutable owner;
    address public swapContract;

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    constructor(bytes memory _decryptionKey) {
        owner = msg.sender;
        decryptionKey = _decryptionKey;
    }

    function oracle_changeKey(bytes memory _decryptionKey) onlyOwner external {
        decryptionKey = _decryptionKey;
    }

    function setSwapContract(address _swapContract) onlyOwner external {
        require(_swapContract != address(0), "Zero address");
        swapContract = _swapContract;
    }

    function getPrivateKey() external view returns (bytes memory) {
        require(msg.sender == swapContract, "Not swap contract");
        return decryptionKey;
    }
}
