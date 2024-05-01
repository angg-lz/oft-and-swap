// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.22;

import { MintOFTAdapter, IMintableBurnable } from "../MintOFTAdapter.sol";
import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";

// @dev WARNING: This is for testing purposes only
contract MyOFT is MintOFTAdapter {
    constructor(
        address _token,
        IMintableBurnable _minterBurner,
        address _lzEndpoint,
        address _delegate
    ) MintOFTAdapter(_token, _minterBurner, _lzEndpoint, _delegate) Ownable(_delegate) {
        // constructor logic ...
    }
}