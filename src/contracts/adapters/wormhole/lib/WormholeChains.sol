// SPDX-License-Identifier: Apache 2
// copied from https://github.com/wormhole-foundation/wormhole-solidity-sdk/commit/bb2c3a43cf1dcf3cb72853a83f2bd914f7b8cb98
pragma solidity ^0.8.13;

// In the wormhole wire format, 0 indicates that a message is for any destination chain
uint16 constant CHAIN_ID_UNSET = 0;
uint16 constant CHAIN_ID_SOLANA = 1;
uint16 constant CHAIN_ID_ETHEREUM = 2;
uint16 constant CHAIN_ID_TERRA = 3;
uint16 constant CHAIN_ID_BSC = 4;
uint16 constant CHAIN_ID_POLYGON = 5;
uint16 constant CHAIN_ID_AVALANCHE = 6;
uint16 constant CHAIN_ID_OASIS = 7;
uint16 constant CHAIN_ID_ALGORAND = 8;
uint16 constant CHAIN_ID_AURORA = 9;
uint16 constant CHAIN_ID_FANTOM = 10;
uint16 constant CHAIN_ID_KARURA = 11;
uint16 constant CHAIN_ID_ACALA = 12;
uint16 constant CHAIN_ID_KLAYTN = 13;
uint16 constant CHAIN_ID_CELO = 14;
uint16 constant CHAIN_ID_NEAR = 15;
uint16 constant CHAIN_ID_MOONBEAM = 16;
uint16 constant CHAIN_ID_NEON = 17;
uint16 constant CHAIN_ID_TERRA2 = 18;
uint16 constant CHAIN_ID_INJECTIVE = 19;
uint16 constant CHAIN_ID_OSMOSIS = 20;
uint16 constant CHAIN_ID_SUI = 21;
uint16 constant CHAIN_ID_APTOS = 22;
uint16 constant CHAIN_ID_ARBITRUM = 23;
uint16 constant CHAIN_ID_OPTIMISM = 24;
uint16 constant CHAIN_ID_GNOSIS = 25;
uint16 constant CHAIN_ID_PYTHNET = 26;
uint16 constant CHAIN_ID_XPLA = 28;
uint16 constant CHAIN_ID_BTC = 29;
uint16 constant CHAIN_ID_BASE = 30;
uint16 constant CHAIN_ID_SEI = 32;
uint16 constant CHAIN_ID_ROOTSTOCK = 33;
uint16 constant CHAIN_ID_SCROLL = 34;
uint16 constant CHAIN_ID_MANTLE = 35;
uint16 constant CHAIN_ID_WORMCHAIN = 3104;
uint16 constant CHAIN_ID_COSMOSHUB = 4000;
uint16 constant CHAIN_ID_EVMOS = 4001;
uint16 constant CHAIN_ID_KUJIRA = 4002;
uint16 constant CHAIN_ID_NEUTRON = 4003;
uint16 constant CHAIN_ID_CELESTIA = 4004;
uint16 constant CHAIN_ID_SEPOLIA = 10002;
uint16 constant CHAIN_ID_ARBITRUM_SEPOLIA = 10003;
uint16 constant CHAIN_ID_BASE_SEPOLIA = 10004;
uint16 constant CHAIN_ID_OPTIMISM_SEPOLIA = 10005;
