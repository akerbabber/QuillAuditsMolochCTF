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
