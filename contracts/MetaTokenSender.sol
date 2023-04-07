// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

contract RandomToken is ERC20 {
constructor() ERC20("", "") {}

function freeMint(uint256 amount) public{
_mint(msg.sender, amount);
}
}

contract TokenSender{
    using ECDSA for bytes32;
//New mapping 
mapping(bytes32 => bool ) executed;

    function transfer(
      address sender,
      uint256 amount,
      address recipient,
      address tokenContract,
      uint nonce,
      bytes memory signature
    ) public{

   // Calculate the hash of all the requisite values.
   bytes32 messageHash = getHash(sender, amount, recipient, tokenContract, nonce);
   
   //Convert it to a signed message hash.
   bytes32 signedMessageHash = messageHash.toEthSignedMessageHash();
   
   // Require that this signature hasn't already been executed
    require(!executed[signedMessageHash], "Already executed");
   //Extract the original signer address.
    address signer = signedMessageHash.recover(signature);
    //Make sure the signer is the person on whose behalfs we are executing the tranaction.
    require(signer == sender, "Signanture does not come from sender");
    //Transfer tokens from sender to recipient.
    bool sent = ERC20(tokenContract).transferFrom(sender, recipient, amount);
    require(sent, "Transfer failed");
    }
    //Helper function to calculate the keccak256 Hash.

    function getHash(address sender, uint256 amount, address recipient, address tokenContract, uint nonce) public pure returns(bytes32){
     return keccak256(
        abi.encodePacked(sender, amount, recipient, tokenContract, nonce));
    }
}