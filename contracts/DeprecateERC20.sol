// SPDX-License-Identifier: MIT
pragma solidity 0.8.5;

// ============ External Imports ============
import {Initializable} from "@openzeppelin/contracts/proxy/utils/Initializable.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
// ============ Internal Imports ============
import {IPartyToken} from "./interfaces/IPartyToken.sol";

/*
DeprecateERC20
by Anna Carroll
*/
contract DeprecateERC20 is Initializable {
    // ============ Immutables ============

    IERC20 public immutable oldToken;
    uint256 public immutable exchangeRate;

    // ============  Public Storage ============

    IPartyToken public newToken;
    // amount of oldToken migrated; target = 25k (all crowdfund tokens)
    uint256 public totalMigrated;

    // ============  Events ============

    event Migrated(address indexed owner, uint256 oldTokenAmount);

    // ======== Constructor =========

    constructor(address _oldToken, uint256 _exchangeRate) {
        // set oldToken and exchangeRate
        oldToken = IERC20(_oldToken);
        exchangeRate = _exchangeRate;
    }

    // ======== Initializer =========

    function initialize(address _newToken) external initializer {
        newToken = IPartyToken(_newToken);
    }

    // ======== External Functions =========

    /**
     * @notice Transfer token holder's entire balance of old token to burn address
     * in exchange for fixed rate of new token
     * @dev Token Holder must approve this contract to spend
     * their total balance of oldToken before calling migrate
     */
    function migrate(address _tokenHolder) external {
        // get function token holder's balance of old token
        uint256 _oldBalance = oldToken.balanceOf(_tokenHolder);
        // send total balance of old token to burn address
        oldToken.transferFrom(_tokenHolder, address(0), _oldBalance);
        // send balance of new token to caller
        newToken.lockupTransfer(_tokenHolder, _oldBalance * exchangeRate);
        // update total & emit event
        totalMigrated += _oldBalance;
        emit Migrated(_tokenHolder, _oldBalance);
    }
}