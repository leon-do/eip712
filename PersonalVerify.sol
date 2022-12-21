// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract PersonalVerify {
    /*
     * @param _message = hello world
     * @param _signature = 0x4867486e8ab6e37a9734eb84134754148a9e70e2f61121a1517345d326795b5a40c9fa5516b1c20c8d8c1cb9b982c6a210032591e689e4f5b97d2462b8bf9fa31c
     * @return 0xdD4c825203f97984e7867F11eeCc813A036089D1
     */
    function getSigner(string memory _message, bytes memory _signature)
        public
        pure
        returns (address)
    {
        bytes32 hash = keccak256(abi.encodePacked(_message));

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
            return
                ecrecover(
                    keccak256(
                        abi.encodePacked(
                            "\x19Ethereum Signed Message:\n32",
                            hash
                        )
                    ),
                    v,
                    r,
                    s
                );
        }
    }
}
