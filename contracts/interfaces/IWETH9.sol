// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity 0.8.24;

/// @title Interface for WETH9
interface IWETH9 {
    function deposit() external payable;
    function approve(address guy, uint wad) external returns (bool);
}
