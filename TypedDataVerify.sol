// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


contract VerifyTypedData {

    // EIP721 domain type
    string  public constant name = "MyName";
    string  public constant version = "1";
    uint256 public constant chainId = 1;
    address public verifyingContract = 0x0000000000000000000000000000000000000000; // address(this);

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

    /*
    * @param _message = 123
    * @param _signature = 0x5e9714b8b78cbf84bf8e53c5967b09a7f8ee895367c0b427859ab520a79702667c8b94e6a320f88977908924bd4b57e94c52efed90e2a2c5cee601e3117e84281b
    * @return 0xdD4c825203f97984e7867F11eeCc813A036089D1
    */
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
    * @param _hash = 0x4ad89a5df51e169895dfefd22dd2563326649cf819f6727a439fe51cde67b056
    * @param _signature = 0x5e9714b8b78cbf84bf8e53c5967b09a7f8ee895367c0b427859ab520a79702667c8b94e6a320f88977908924bd4b57e94c52efed90e2a2c5cee601e3117e84281b
    * @return 0xdD4c825203f97984e7867F11eeCc813A036089D1
    */
    function getSigner(bytes32 _hash, bytes memory _signature) public pure returns (address) {
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