// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity =0.7.6;

import "interfaces/IPoolInitializer.sol";
import "interfaces/IThrusterPoolFactory.sol";
import "interfaces/IThrusterPoolDeployer.sol";
import "interfaces/IThrusterPool.sol";

import "./PeripheryImmutableState.sol";

/// @title Creates and initializes V3 Pools
abstract contract PoolInitializer is IPoolInitializer, PeripheryImmutableState {
    /// @inheritdoc IPoolInitializer
    function createAndInitializePoolIfNecessary(address token0, address token1, uint24 fee, uint160 sqrtPriceX96)
        external
        payable
        override
        returns (address pool)
    {
        require(token0 < token1);
        pool = IThrusterPoolFactory(IThrusterPoolDeployer(factory).factory()).getPool(token0, token1, fee);

        if (pool == address(0)) {
            pool = IThrusterPoolFactory(IThrusterPoolDeployer(factory).factory()).createPool(token0, token1, fee);
            IThrusterPool(pool).initialize(sqrtPriceX96);
        } else {
            (uint160 sqrtPriceX96Existing,,,,,,) = IThrusterPool(pool).slot0();
            if (sqrtPriceX96Existing == 0) {
                IThrusterPool(pool).initialize(sqrtPriceX96);
            }
        }
    }
}
