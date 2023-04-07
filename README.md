# Moloch's Vault CTF Challenge Proof of Concept Repository

This repository contains a proof of concept for the Moloch's Vault Capture The Flag (CTF) Challenge. The objective of the challenge is to steal at least 1 WEI from the MolochVault contract.

https://quillctf.super.site/challenges/quillctf-challenges/molochs-vault

## Contents

1. [Objective](#objective)
2. [Contract Details](#contract-details)
3. [Questions](#questions)
   - [Detailed formula for finding the slot of the dynamic struct](#detailed-formula-for-finding-the-slot-of-the-dynamic-struct)
   - [Details of decrypting Moloch-algorithm](#details-of-decrypting-moloch-algorithm)
   - [Explain bypass for keccak256(abi.encodePacked())](#explain-bypass-for-keccak256abiencodepacked)
4. [Proof of Concept](#proof-of-concept)
   - [MolochCaller.sol](#molochcallersol)
   - [MOLOCH_VAULT.t.sol](#moloch_vaulttsol)
5. [Running Tests](#running-tests)

## Objective

The objective of the Moloch's Vault CTF Challenge is to steal at least 1 WEI from the MolochVault contract.

## Contract Details

- Contract Address (Görli Testnet): 0xafb9ed5cd677a1bd5725ca5fcb9a3a0572d94f6f
- Contract Source: [Etherscan](https://goerli.etherscan.io/address/0xaFB9ed5cD677a1bD5725Ca5FcB9a3a0572D94f6f#code)

## Questions

### Detailed formula for finding the slot of the dynamic struct

Please refer to the [Proof of concept](POC.md#detailed-formula-for-finding-the-slot-of-the-dynamic-struct) for the detailed formula.

### Details of decrypting Moloch-algorithm

Please refer to the [Proof of concept](POC.md#details-of-decrypting-moloch-algorithm) for the details of decrypting the Moloch-algorithm.

### Explain bypass for keccak256(abi.encodePacked())

Please refer to the [Proof of concept](POC.md#explain-bypass-for-keccak256abiencodepacked) for an explanation of the bypass.

## Proof of Concept

The repository contains two Solidity files that demonstrate a proof of concept for the Moloch's Vault CTF Challenge:

1. [MolochCaller.sol](./src/MolochCaller.sol) - A smart contract that interacts with the MolochVault contract to exploit the vulnerability.
2. [MOLOCH_VAULT.t.sol](./test/MOLOCH_VAULT.t.sol) - A test suite that demonstrates the exploit in action.

## Running Tests

To run the tests for this proof of concept, please use the following command:

```bash
forge test -vvvvv -f https://eth-goerli.public.blastapi.io
```
