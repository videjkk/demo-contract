// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "./interfaces/ISwapRouter.sol";
import "./interfaces/IWETH9.sol";
import "./interfaces/IPool.sol";
import "./KeyStore.sol";

/*
Several notes: 
  Storing the decryption key in the contract or somewhere on-chain is a bad idea, as it is accessible to anyone event if contract's source code 
  is not verified or submitted. Then it doesn't make sense to encrypt the data as the address, amount and other data would be still visible 
  in msg.sender's transactions in the explorer. Advanced users even can use tenderly.co debugger to get sensitive info.

  I decided to use UNSECURE, simple (as gas spending is the priority) encryption algorithm using XOR, as other algorithms (like RSA) would either 
  cost A LOT OF gas or just impossible to implement their secure sensitive data storing such as private key prepared for decryption.

  As a simple solution after each swap the Decrypted event is emitted. Let's assume we have a backend listening this contract on outgoing events
  making it behave like an oracle to udpate secret key in KeyStore contract (again it would be still visible to anyone even it is not verified via 
  getStorageAt or other ways)
*/

contract Swap {
    ISwapRouter public immutable swapRouter;
    IWETH9 public immutable WETH;
    KeyStore private keyStore;
    
    // event used for an oracle asking to change the XOR encrypt/decrypt key 
    event Decrypted(uint256 timestamp);

    event Swapped(uint256 amountOut);

    constructor(ISwapRouter _swapRouter, IWETH9 _WETH, KeyStore _keyStore) {
        swapRouter = _swapRouter;
        WETH = _WETH;
        keyStore = _keyStore;
    }

    function swap(
        bytes calldata encryptedData
    ) external payable {
        bytes memory decryptedData = decrypt(encryptedData);
        (uint256 rawPoolAddress, uint256 amount)  = abi.decode(decryptedData, (uint256, uint256));
        address poolAddress = address(uint160(rawPoolAddress));
        
        emit Decrypted(block.timestamp);

        require(msg.value == amount, "Incorrect ETH amount");

        WETH.deposit{value: msg.value}();
        WETH.approve(address(swapRouter), msg.value);

        IUniswapV3Pool pool = IUniswapV3Pool(poolAddress);

        ISwapRouter.ExactInputSingleParams memory params =
            ISwapRouter.ExactInputSingleParams({
                tokenIn: pool.token1(),
                tokenOut: pool.token0(),
                fee: pool.fee(),
                recipient: msg.sender,
                amountIn: amount,
                amountOutMinimum: 0,
                sqrtPriceLimitX96: 0
            });

        uint256 amountOut = swapRouter.exactInputSingle(params);
        emit Swapped(amountOut);
    }

    function decrypt(
        bytes memory data // The encrypted data
    ) public view returns (bytes memory result) {
        uint256 length = data.length;
        bytes memory key = keyStore.getPrivateKey();
        assembly {
            // The free memory pointer (at address 0x40) points to the start of free memory.
            //  set result variable to this location.
            result := mload(0x40)
            //  then increment the free memory pointer to reserve space for result.
            //  add 32 to the length to account for the length field of the bytes array.
            mstore(0x40, add(add(result, length), 32))
            //  store the length of data at the start of the result.
            mstore(result, length)
        }

        //  iterate over the data in chunks of 32 bytes.
        for (uint i = 0; i < length; i += 32) {
            // For each chunk, generate a hash of the key and the current offset.
            // This hash will be used to decrypt the chunk.
            bytes32 hash = keccak256(abi.encodePacked(key, i));

            bytes32 chunk; // The current chunk of data
            assembly {
                //  load the current chunk into the chunk variable.
                chunk := mload(add(data, add(i, 32)))
            }
            //  decrypt the chunk by XORing it with the hash.
            chunk ^= hash;
            assembly {
                //  store the decrypted chunk in the result.
                mstore(add(result, add(i, 32)), chunk)
            }
        }
    }
}
