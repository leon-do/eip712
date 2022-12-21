// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


contract VerifyTypedData {

    // EIP721 domain type
    string  public constant name = "MyName";
    string  public constant version = "1";
    uint256 public constant chainId = 1;
    address public verifyingContract = 0xCcCCccccCCCCcCCCCCCcCcCccCcCCCcCcccccccC; // address(this);

    // message type
    struct Message {
        uint256 myValue;
    }

    // stringified types and hashes
    string  public constant EIP712_DOMAIN_TYPE = "EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)";
    string  public constant MESSAGE_TYPE = "Message(uint256 myValue)";
    bytes32 public constant MESSAGE_TYPE_HASH = keccak256(abi.encodePacked(MESSAGE_TYPE));
    // to prevent signature collision
    bytes32 public DOMAIN_SEPARATOR = keccak256(
        abi.encode(
            keccak256(abi.encodePacked(EIP712_DOMAIN_TYPE)),
            keccak256(abi.encodePacked(name)),
            keccak256(abi.encodePacked(version)),
            chainId,
            verifyingContract)
    );

    function verifyTypedData(uint256 _message, bytes memory _signature) public view returns (address) {
        bytes32 hash = keccak256(abi.encodePacked(
            "\x19\x01",
            DOMAIN_SEPARATOR,
            keccak256(abi.encode(
                MESSAGE_TYPE_HASH,
                _message
            ))
        ));
        return getSigner(hash, _signature);
    }

    /*
    * @param _hash = 0x47173285a8d7341e5e972fc677286384f802f8ef42a5ec5f03bbfa254cb01fad
    * @param _signature = 0x4867486e8ab6e37a9734eb84134754148a9e70e2f61121a1517345d326795b5a40c9fa5516b1c20c8d8c1cb9b982c6a210032591e689e4f5b97d2462b8bf9fa31c
    * @return 0xdD4c825203f97984e7867F11eeCc813A036089D1
    */
    function getSigner(bytes32 _hash, bytes memory _signature) private pure returns (address) {
      bytes32 r;
      bytes32 s;
      uint8 v;
      if (_signature.length != 65) {
        return address(0);
      }
      assembly {
        r := mload(add(_signature, 32))
        s := mload(add(_signature, 64))
        v := byte(0, mload(add(_signature, 96)))
      }
      if (v < 27) {
        v += 27;
      }
      if (v != 27 && v != 28) {
        return address(0);
      } else {
        return ecrecover(_hash, v, r, s);
      }
    }
}