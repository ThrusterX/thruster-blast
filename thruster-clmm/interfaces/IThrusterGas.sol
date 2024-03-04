// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity >=0.5.0;

interface IThrusterGas {
    event ClaimGas(address indexed recipient, uint256 amount);

    function claimGas(address _recipient, uint256 _minClaimRateBips) external returns (uint256 amount);

    function setManager(address _manager) external;
}
