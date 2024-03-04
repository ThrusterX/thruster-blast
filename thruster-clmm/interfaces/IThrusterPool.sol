// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity >=0.5.0;

import "interfaces/pool/IThrusterPoolActions.sol";
import "interfaces/pool/IThrusterPoolDerivedState.sol";
import "interfaces/pool/IThrusterPoolEvents.sol";
import "interfaces/pool/IThrusterPoolImmutables.sol";
import "interfaces/pool/IThrusterPoolOwnerActions.sol";
import "interfaces/pool/IThrusterPoolState.sol";

/// @title The interface for a Thruster CLMM Pool
/// @notice A Thruster CLMM pool facilitates swapping and automated market making between any two assets that strictly conform
/// to the ERC20 specification
/// @dev The pool interface is broken up into many smaller pieces
interface IThrusterPool is
    IThrusterPoolImmutables,
    IThrusterPoolState,
    IThrusterPoolDerivedState,
    IThrusterPoolActions,
    IThrusterPoolOwnerActions,
    IThrusterPoolEvents
{}
