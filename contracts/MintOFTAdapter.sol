// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.22;

import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";

import { IERC20Metadata, IERC20 } from "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";

import { SafeERC20 } from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import { OFTCore } from "@layerzerolabs/lz-evm-oapp-v2/contracts/oft/OFTCore.sol";

contract Operatable is Ownable {
    event OperatorChanged(address indexed, bool);
    error NotAllowedOperator();

    mapping(address => bool) public operators;

    constructor(address _owner) Ownable(_owner) {
        operators[msg.sender] = true;
    }

    modifier onlyOperators() {
        if (!operators[msg.sender]) {
            revert NotAllowedOperator();
        }
        _;
    }

    function setOperator(address operator, bool status) external onlyOwner {
        operators[operator] = status;
        emit OperatorChanged(operator, status);
    }
}

interface IMintableBurnable {
    function burn(address _from, uint256 _amount) external returns (bool);

    function mint(address _to, uint256 _amount) external returns (bool);
}

/// @title ElevatedMinterBurner
/// @notice ElevatedMinterBurner is a periphery contract for minting and burning tokens and executing arbitrary calls.
contract ElevatedMinterBurner is IMintableBurnable, Operatable {
    IMintableBurnable public immutable token;

    constructor(IMintableBurnable token_, address _owner) Operatable(_owner) {
        token = token_;
    }

    function burn(address from, uint256 amount) external override onlyOperators returns (bool) {
        return token.burn(from, amount);
    }

    function mint(address to, uint256 amount) external override onlyOperators returns (bool) {
        return token.mint(to, amount);
    }

    function exec(address target, bytes calldata data) external onlyOwner {
        (bool success, bytes memory result) = target.call(data);
        if (!success) {
            if (result.length == 0) revert();
            assembly {
                revert(add(32, result), mload(result))
            }
        }
    }
}

abstract contract MintOFTAdapter is OFTCore {
    using SafeERC20 for IERC20;

    IERC20 internal immutable innerToken;
    IMintableBurnable public immutable minterBurner;
    constructor(
        address _token,
        IMintableBurnable _minterBurner,
        address _lzEndpoint,
        address _delegate
    ) OFTCore(IERC20Metadata(_token).decimals(), _lzEndpoint, _delegate) {
        innerToken = IERC20(_token);
        minterBurner = _minterBurner;
    }

    /**
     * @dev Retrieves the address of the underlying ERC20 implementation.
     * @return The address of the adapted ERC-20 token.
     *
     * @dev In the case of OFTAdapter, address(this) and erc20 are NOT the same contract.
     */
    function token() public view returns (address) {
        return address(innerToken);
    }

    /**
     * @notice Indicates whether the OFT contract requires approval of the 'token()' to send.
     * @return requiresApproval Needs approval of the underlying token implementation.
     *
     * @dev In the case of default OFTAdapter, approval is required.
     * @dev In non-default OFTAdapter contracts with something like mint and burn privileges, it would NOT need approval.
     */
    function approvalRequired() external pure virtual returns (bool) {
        return true;
    }

    /**
     * @dev Burns tokens from the sender's specified balance.
     * @param _from The address to debit the tokens from.
     * @param _amountLD The amount of tokens to send in local decimals.
     * @param _minAmountLD The minimum amount to send in local decimals.
     * @param _dstEid The destination chain ID.
     * @return amountSentLD The amount sent in local decimals.
     * @return amountReceivedLD The amount received in local decimals on the remote.
     * @dev msg.sender will need to approve this _amountLD of tokens to be burnt by this contract.
     * @dev WARNING: The default OFTAdapter implementation assumes LOSSLESS transfers, ie. 1 token in, 1 token out.
     * IF the 'innerToken' applies something like a transfer fee, the default will NOT work...
     * a pre/post balance check will need to be done to calculate the amountReceivedLD.
     */
    function _debit(
        address _from,
        uint256 _amountLD,
        uint256 _minAmountLD,
        uint32 _dstEid
    ) internal virtual override returns (uint256 amountSentLD, uint256 amountReceivedLD) {
        (amountSentLD, amountReceivedLD) = _debitView(_amountLD, _minAmountLD, _dstEid);
        // @dev Burns tokens via approval from the caller.
        minterBurner.burn(_from, amountSentLD);
    }

    /**
     * @dev Credits tokens to the specified address.
     * @param _to The address to credit the tokens to.
     * @param _amountLD The amount of tokens to credit in local decimals.
     * @dev _srcEid The source chain ID.
     * @return amountReceivedLD The amount of tokens ACTUALLY received in local decimals.
     *
     * @dev WARNING: The default OFTAdapter implementation assumes LOSSLESS transfers, ie. 1 token in, 1 token out.
     * IF the 'innerToken' applies something like a transfer fee, the default will NOT work...
     * a pre/post balance check will need to be done to calculate the amountReceivedLD.
     */
    function _credit(
        address _to,
        uint256 _amountLD,
        uint32 /*_srcEid*/
    ) internal virtual override returns (uint256 amountReceivedLD) {
        // @dev Mints the tokens and transfers to the recipient.
        minterBurner.mint(_to, _amountLD);
        // @dev In the case of NON-default OFTAdapter, the amountLD MIGHT not be == amountReceivedLD.
        return _amountLD;
    }
}