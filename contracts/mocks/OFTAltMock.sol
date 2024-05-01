// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.22;

import { OFTAlt } from "../OFTAlt.sol";

// @dev WARNING: This is for testing purposes only
contract MyOFT is OFTAlt {
    constructor(
        string memory _name,
        string memory _symbol,
        address _lzEndpoint,
        address _delegate
    ) OFTAlt(_name, _symbol, _lzEndpoint, _delegate) {
        // constructor logic ...
    }
}