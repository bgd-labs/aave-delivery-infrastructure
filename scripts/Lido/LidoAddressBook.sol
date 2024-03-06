// SPDX-FileCopyrightText: 2024 Lido <info@lido.fi>
// SPDX-License-Identifier: GPL-3.0

pragma solidity 0.8.19;

library LidoAddressBook {
  // Ethereum
  address internal constant CREATE3_FACTORY_ETHEREUM = address(0);
  address internal constant CREATE3_FACTORY_ETHEREUM_TESTNET = 0x7C01fd61bA44505D32e622FB9b39f1f2EdcEC30d;

  address internal constant TRANSPARENT_PROXY_FACTORY_ETHEREUM = address(0);
  address internal constant TRANSPARENT_PROXY_FACTORY_ETHEREUM_TESTNET = 0x889901C8f05dc05f4B8772c4ea3516cBc2Df1982;

  address internal constant PROXY_ADMIN_ETHEREUM = address(0);
  address internal constant PROXY_ADMIN_ETHEREUM_TESTNET = 0x86ED95c2DdA3D506A1E63e837b821322D5316F02;

  address internal constant GUARDIAN_ETHEREUM = address(0);
  address internal constant GUARDIAN_ETHEREUM_TESTNET = address(0);

  // Polygon
  address internal constant CREATE3_FACTORY_POLYGON = address(0);
  address internal constant CREATE3_FACTORY_POLYGON_TESTNET = 0x7C01fd61bA44505D32e622FB9b39f1f2EdcEC30d;

  address internal constant TRANSPARENT_PROXY_FACTORY_POLYGON = address(0);
  address internal constant TRANSPARENT_PROXY_FACTORY_POLYGON_TESTNET = 0xFC6FdBfeD8c1e3F3f665AE82b51750995DC80604;

  address internal constant PROXY_ADMIN_POLYGON = address(0);
  address internal constant PROXY_ADMIN_POLYGON_TESTNET = 0xb5c3bE51cD240AC377F74Ce47c8BF7eBEC2D6a0B;

  address internal constant GUARDIAN_POLYGON = address(0);
  address internal constant GUARDIAN_POLYGON_TESTNET = address(0);

  // Binance
  address internal constant CREATE3_FACTORY_BINANCE = address(0);
  address internal constant CREATE3_FACTORY_BINANCE_TESTNET = 0x7C01fd61bA44505D32e622FB9b39f1f2EdcEC30d;

  address internal constant TRANSPARENT_PROXY_FACTORY_BINANCE = address(0);
  address internal constant TRANSPARENT_PROXY_FACTORY_BINANCE_TESTNET = 0xDd84ee2775e0A012C4a40605A1D07B9AaE88C448;

  address internal constant PROXY_ADMIN_BINANCE = address(0);
  address internal constant PROXY_ADMIN_BINANCE_TESTNET = 0xb83B47a3e9CB971AD5B1BEeB744dA46b28108C8a;

  address internal constant GUARDIAN_BINANCE = address(0);
  address internal constant GUARDIAN_BINANCE_TESTNET = address(0);
}
