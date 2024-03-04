// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity >=0.5.0;

interface IThrusterGauge {
  function checkpoint(uint32 currTimestamp) external;
  
  function cross(int24 tick, bool zeroForOne) external;
}
