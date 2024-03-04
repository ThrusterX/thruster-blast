// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity =0.7.6;

import "interfaces/IBlastPoints.sol";
import "interfaces/IThrusterPoolFactory.sol";
import "interfaces/IThrusterPoolDeployer.sol";

import "contracts/NoDelegateCall.sol";
import "contracts/ThrusterGas.sol";

/// @title Canonical Thruster CLMM factory
/// @notice Deploys Thruster CLMM pools and manages ownership and control over pool protocol fees
contract ThrusterPoolFactory is IThrusterPoolFactory, NoDelegateCall, ThrusterGas {
    /// @inheritdoc IThrusterPoolFactory
    address public override owner;

    /// Points adminf or Blast points
    address public override pointsAdmin;

    /// @inheritdoc IThrusterPoolFactory
    address public override deployer;

    /// @inheritdoc IThrusterPoolFactory
    mapping(uint24 => int24) public override feeAmountTickSpacing;
    /// @inheritdoc IThrusterPoolFactory
    mapping(address => mapping(address => mapping(uint24 => address))) public override getPool;
    mapping(address => bool) public poolExists;

    address private constant BLAST_POINTS = 0x2536FE9ab3F511540F2f9e2eC2A805005C3Dd800;

    constructor(address _owner, address _pointsAdmin) ThrusterGas(_owner) {
        owner = _owner;
        emit OwnerChanged(address(0), _owner);
        pointsAdmin = _pointsAdmin;
        IBlastPoints(BLAST_POINTS).configurePointsOperator(_pointsAdmin);

        feeAmountTickSpacing[500] = 10;
        emit FeeAmountEnabled(500, 10);
        feeAmountTickSpacing[3000] = 60;
        emit FeeAmountEnabled(3000, 60);
        feeAmountTickSpacing[10000] = 200;
        emit FeeAmountEnabled(10000, 200);
    }

    /// @inheritdoc IThrusterPoolFactory
    function createPool(address tokenA, address tokenB, uint24 fee)
        public
        override
        noDelegateCall
        returns (address pool)
    {
        require(tokenA != tokenB);
        (address token0, address token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
        require(token0 != address(0));
        int24 tickSpacing = feeAmountTickSpacing[fee];
        require(tickSpacing != 0);
        require(getPool[token0][token1][fee] == address(0));
        pool = IThrusterPoolDeployer(deployer).deploy(address(this), token0, token1, fee, tickSpacing);
        getPool[token0][token1][fee] = pool;
        // populate mapping in the reverse direction, deliberate choice to avoid the cost of comparing addresses
        getPool[token1][token0][fee] = pool;
        poolExists[pool] = true;
        emit PoolCreated(token0, token1, fee, tickSpacing, pool);
    }

    /// @inheritdoc IThrusterPoolFactory
    function setOwner(address _owner) external override {
        require(msg.sender == owner);
        require(_owner != address(0));
        emit OwnerChanged(owner, _owner);
        owner = _owner;
    }

    function setDeployer(address _deployer) external {
        require(msg.sender == owner && deployer == address(0), "INVALID");
        deployer = _deployer;
    }

    /// @inheritdoc IThrusterPoolFactory
    function enableFeeAmount(uint24 fee, int24 tickSpacing) public override {
        require(msg.sender == owner);
        require(fee < 1000000);
        // tick spacing is capped at 16384 to prevent the situation where tickSpacing is so large that
        // TickBitmap#nextInitializedTickWithinOneWord overflows int24 container from a valid tick
        // 16384 ticks represents a >5x price change with ticks of 1 bips
        require(tickSpacing > 0 && tickSpacing < 16384);
        require(feeAmountTickSpacing[fee] == 0);

        feeAmountTickSpacing[fee] = tickSpacing;
        emit FeeAmountEnabled(fee, tickSpacing);
    }

    function claimDeployerGas(address _recipient) external {
        require(msg.sender == owner);
        IThrusterPoolDeployer(deployer).claimGas(_recipient);
    }

    function emitSwap(
        address sender,
        address recipient,
        int256 amount0,
        int256 amount1,
        uint160 sqrtPriceX96,
        uint128 liquidity,
        int24 tick
    ) external override {
        require(poolExists[msg.sender], "INVALID_POOL");
        emit Swap(msg.sender, sender, recipient, amount0, amount1, sqrtPriceX96, liquidity, tick);
    }

    function updatePointsAdmin(address _pointsAdmin) external {
        require(msg.sender == owner);
        pointsAdmin = _pointsAdmin;
    }
}
