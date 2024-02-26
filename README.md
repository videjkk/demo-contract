# Demo contract

Several notes: 
  Storing the decryption key in the contract or somewhere on-chain is a bad idea, as it is accessible to anyone event if contract's source code 
  is not verified or submitted. Then it doesn't make sense to encrypt the data as the address, amount and other data would be still visible 
  in msg.sender's transactions in the explorer. Advanced users even can use tenderly.co debugger to get sensitive info.

  I decided to use UNSECURE, simple (as gas spending is the priority) encryption algorithm using XOR, as other algorithms (like RSA) would either 
  cost A LOT OF gas or just impossible to implement their secure sensitive data storing such as private key prepared for decryption.

  As a simple solution after each swap the Decrypted event is emitted. Let's assume we have a backend listening this contract on outgoing events
  making it behave like an oracle to udpate secret key in KeyStore contract (again it would be still visible to anyone even it is not verified via 
  getStorageAt or other ways)

The info below is an introduction of functionality

## Contracts mini overview
```Swap.sol```
Contract is used for making a swap using Uniswap v3; has two functions: swap (external, payable, makes a uniswap swap using encrypted data) and decrypt(private, used for XOR encrypted data decryption);

```KeyStore.sol```
Contract is used for storing a private key for encryption/decryption (XOR algorithm). (NOT_SAFE) 

## Contracts deployment
Using custom hardhat tasks contracts were deployed.
ADDRESSES:
SWAP - [0xf40c75bc7171741fbea5e4f46947131915fbd54d](https://goerli.etherscan.io/address/0xf40c75bc7171741fbea5e4f46947131915fbd54d)https://goerli.etherscan.io/address/0xf40c75bc7171741fbea5e4f46947131915fbd54d
KEYSTORE - [0xdf1477CB35fa43B37eBffCCc4F9b1dfb958A900F](https://goerli.etherscan.io/address/0xdf1477CB35fa43B37eBffCCc4F9b1dfb958A900F)https://goerli.etherscan.io/address/0xdf1477CB35fa43B37eBffCCc4F9b1dfb958A900F

## Making a swap

Firstly after deployment [set a swap address in keystore](https://goerli.etherscan.io/tx/0x80141e04febad585f3cddeb5acaef79719682d472d08ce62623944ab0e557820)https://goerli.etherscan.io/tx/0x80141e04febad585f3cddeb5acaef79719682d472d08ce62623944ab0e557820
After using decrypt function (as it is XOR, decrypt function can be used for both encrypt/decrypt) encrypt the data with leftpads (32bytes for each arg) 
the raw data is the following one:
0x0000000000000000000000006337b3caf9c5236c7f3d1694410776119edaf9fa|000000000000000000000000000000000000000000000000000aa87bee538000
where first 32 bytes is a pool address, the next 32 bytes - tokens amount user wishes to buy

the encrypted string:
0x10277a171a31b6366a283e0a4053eb066915753b7681d6d76d9e04ac7228f2a1edf36c5f4fe24f5ecdd194dc585b160d14de2087dfcb915523f2e40089016a12 

next step is to pass this encrypted string to the swap function:
https://goerli.etherscan.io/tx/0xe548b9f82e649eb1853964b64ec72278a8e12d5e76952e4645f28742a93fcde3

the data is encrypted and etherscan cannot decode it.
![image](https://github.com/videjkk/demo-contract/assets/86836604/be1cae66-f100-48a6-b00e-6e9124020ec5)

swap is successfull because the user gets their tokens ![image](https://github.com/videjkk/demo-contract/assets/86836604/e2335f3c-ab44-40ff-9300-a39eb881dd54)
 


