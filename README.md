# a.DI (Aave Delivery Infrastructure)


<img src="./docs/adi-banner.jpg" alt="a.DI" width="75%" height="75%">

<br>

a.DI (Aave Delivery Insfrastucture) is a cross-chain communication abstraction layer  for decentralised systems
like the Aave DAO to communicate across networks, minimising the risk of underlying individual bridge provider failures, via consensus rules.

<br>

## Specifications

Extensive documentation about the architecture and design of the system can be found [HERE](./docs/overview.md).

Additional, more formal (but natural language) properties of the system can be found [HERE](./docs/properties.md).

<br>

## Setup instructions

All the information about setup of the project and deployments can be found [HERE](./docs/setup.md)

<br>

## Deployed Addresses

| Network   | CrossChainController                                                                                                             | Forwards to        | Receives from | Consensus                                                                                                                                                                                                                                                                                                                                                                                          |
|---------------------------------------------------------------------|------------------------------------------------------------------------|--------------------|---------------|----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| <div style="display: flex; align-items: center;"><img src="./docs/networks/ethereum.svg" alt="Ethereum" style="max-width: 25px; margin-right: 5px;"><p style="text-align: center;">Ethereum</p></div> | [0xEd42a7D8559a463722Ca4beD50E0Cc05a386b0e1](https://etherscan.io/address/0xEd42a7D8559a463722Ca4beD50E0Cc05a386b0e1)            | <img src="./docs/networks/polygon.svg" alt="Polygon" style="max-width: 25px%; margin-right: 5px;"> <img src="./docs/networks/avalanche.svg" alt="Avalanche" style="max-width: 25px; margin-right: 5px;"> <img src="./docs/networks/arbitrum.svg" alt="Arbitrum" style="max-width: 25px; margin-right: 5px;"> <img src="./docs/networks/optimism.svg" alt="Optimism" style="max-width: 25px; margin-right: 5px;"> <img src="./docs/networks/bsc.svg" alt="Binance" style="max-width: 25px; margin-right: 5px;"> <img src="./docs/networks/base.svg" alt="Base" style="max-width: 25px; margin-right: 5px;"> <img src="./docs/networks/metis.svg" alt="Metis" style="max-width: 25px; margin-right: 5px;"> | <img src="./docs/networks/avalanche.svg" alt="Avalanche" style="max-width: 25px; margin-right: 5px;"> <img src="./docs/networks/polygon.svg" alt="Polygon" style="max-width: 25px%; margin-right: 5px;">  | <div style="display: flex; align-items: center;"><img src="./docs/networks/avalanche.svg" alt="Avalanche" style="max-width: 25px; margin-right: 5px;"><p style="text-align: center;">2/3</p></div> <div style="display: flex; align-items: center;"><img src="./docs/networks/polygon.svg" alt="Polygon" style="max-width: 25px%; margin-right: 5px;"><p style="text-align: center;">3/4</p></div> |
| <div style="display: flex; align-items: center;"><img src="./docs/networks/polygon.svg" alt="Polygon" style="max-width: 25px%; margin-right: 5px;"><p style="text-align: center;">Polygon</p></div> | [0xF6B99959F0b5e79E1CC7062E12aF632CEb18eF0d](https://polygonscan.com/address/0xF6B99959F0b5e79E1CC7062E12aF632CEb18eF0d)         | <img src="./docs/networks/ethereum.svg" alt="Ethereum" style="max-width: 25px; margin-right: 5px;">              | <img src="./docs/networks/ethereum.svg" alt="Ethereum" style="max-width: 25px; margin-right: 5px;">        | <div style="display: flex; align-items: center;"><img src="./docs/networks/ethereum.svg" alt="Ethereum" style="max-width: 25px; margin-right: 5px;"><p style="text-align: center;">3/4</p></div>                                                                                                                                                                                                                                                                                                                                                                                                |
| <div style="display: flex; align-items: center;"><img src="./docs/networks/avalanche.svg" alt="Avalanche" style="max-width: 25px; margin-right: 5px;"><p style="text-align: center;">Avalanche</p></div> | [0x27FC7D54C893dA63C0AE6d57e1B2B13A70690928](https://snowtrace.io/address/0x27FC7D54C893dA63C0AE6d57e1B2B13A70690928)            | <img src="./docs/networks/ethereum.svg" alt="Ethereum" style="max-width: 25px; margin-right: 5px;">              | <img src="./docs/networks/ethereum.svg" alt="Ethereum" style="max-width: 25px; margin-right: 5px;">         | <div style="display: flex; align-items: center;"><img src="./docs/networks/ethereum.svg" alt="Ethereum" style="max-width: 25px; margin-right: 5px;"><p style="text-align: center;">2/3</p></div>                                                                                                                                                                                                                                                                                                                                                                                                |
| <div style="display: flex; align-items: center;"><img src="./docs/networks/arbitrum.svg" alt="Arbitrum" style="max-width: 25px; margin-right: 5px;"><p style="text-align: center;">Arbitrum</p></div> | [0xCbFB78a3Eeaa611b826E37c80E4126c8787D29f0](https://arbiscan.io/address/0xCbFB78a3Eeaa611b826E37c80E4126c8787D29f0)             | -                  | <img src="./docs/networks/ethereum.svg" alt="Ethereum" style="max-width: 25px; margin-right: 5px;">       | <div style="display: flex; align-items: center;"><img src="./docs/networks/ethereum.svg" alt="Ethereum" style="max-width: 25px; margin-right: 5px;"><p style="text-align: center;">1/1</p></div>                                                                                                                                                                                                                                                                                                                                                                                               |
| <div style="display: flex; align-items: center;"><img src="./docs/networks/optimism.svg" alt="Optimism" style="max-width: 25px; margin-right: 5px;"><p style="text-align: center;">Optimism</p></div> | [0x48A9FE90bce5EEd790f3F4Ce192d1C0B351fd4Ca](https://optimistic.etherscan.io/address/0x48A9FE90bce5EEd790f3F4Ce192d1C0B351fd4Ca) | -                  | <img src="./docs/networks/ethereum.svg" alt="Ethereum" style="max-width: 25px; margin-right: 5px;">        | <div style="display: flex; align-items: center;"><img src="./docs/networks/ethereum.svg" alt="Ethereum" style="max-width: 25px; margin-right: 5px;"><p style="text-align: center;">1/1</p></div>                                                                                                                                                                                                                                                                                                                                                                                                |
| <div style="display: flex; align-items: center;"><img src="./docs/networks/bsc.svg" alt="Binance" style="max-width: 25px; margin-right: 5px;"><p style="text-align: center;">Binance</p></div> | [0x9d33ee6543C9b2C8c183b8fb58fB089266cffA19](https://bscscan.com/address/0x9d33ee6543C9b2C8c183b8fb58fB089266cffA19)             | -                  | <img src="./docs/networks/ethereum.svg" alt="Ethereum" style="max-width: 25px; margin-right: 5px;">        | <div style="display: flex; align-items: center;"><img src="./docs/networks/ethereum.svg" alt="Ethereum" style="max-width: 25px; margin-right: 5px;"><p style="text-align: center;">2/3</p></div>                                                                                                                                                                                                                                                                                                                                                                                                 |
| <div style="display: flex; align-items: center;"><img src="./docs/networks/base.svg" alt="Base" style="max-width: 25px; margin-right: 5px;"><p style="text-align: center;">Base</p></div>   | [0x529467C76f234F2bD359d7ecF7c660A2846b04e2](https://basescan.org/address/0x529467C76f234F2bD359d7ecF7c660A2846b04e2)            | -                  | <img src="./docs/networks/ethereum.svg" alt="Ethereum" style="max-width: 25px; margin-right: 5px;">        | <div style="display: flex; align-items: center;"><img src="./docs/networks/ethereum.svg" alt="Ethereum" style="max-width: 25px; margin-right: 5px;"><p style="text-align: center;">1/1</p></div>                                                                                                                                                                                                                                                                                                                                                                                                 |
| <div style="display: flex; align-items: center;"><img src="./docs/networks/metis.svg" alt="Metis" style="max-width: 25px; margin-right: 5px;"><p style="text-align: center;">Metis</p></div> | [0x6fDaFb26915ABD6065a1E1501a37Ac438D877f70](https://explorer.metis.io/address/0x6fDaFb26915ABD6065a1E1501a37Ac438D877f70)       | -                  | <img src="./docs/networks/ethereum.svg" alt="Ethereum" style="max-width: 25px; margin-right: 5px;">        | <div style="display: flex; align-items: center;"><img src="./docs/networks/ethereum.svg" alt="Ethereum" style="max-width: 25px; margin-right: 5px;"><p style="text-align: center;">1/1</p></div>                                                                                                                                                                                                                                                                                                                                                                                                 |

<br>

| Network                                                                                                                                                                                                  | EmergencyRegistry                                                                                                      | Emergency Oracle                                                                                                         |
|----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|------------------------------------------------------------------------------------------------------------------------|--------------------------------------------------------------------------------------------------------------------------|
| <div style="display: flex; align-items: center;"><img src="./docs/networks/ethereum.svg" alt="Ethereum" style="max-width: 25px; margin-right: 5px;"><p style="text-align: center;">Ethereum</p></div>    | [0x73C6Fb358dDA8e84D50e98A98F7c0dF32e15C7e9](https://etherscan.io/address/0x73C6Fb358dDA8e84D50e98A98F7c0dF32e15C7e9)  | -                                                                                                                        |
| <div style="display: flex; align-items: center;"><img src="./docs/networks/polygon.svg" alt="Polygon" style="max-width: 25px%; margin-right: 5px;"><p style="text-align: center;">Polygon</p></div>      | -                                                                                                                      | [0xDAFA1989A504c48Ee20a582f2891eeB25E2fA23F](https://polygonscan.com/address/0xDAFA1989A504c48Ee20a582f2891eeB25E2fA23F) |
| <div style="display: flex; align-items: center;"><img src="./docs/networks/avalanche.svg" alt="Avalanche" style="max-width: 25px; margin-right: 5px;"><p style="text-align: center;">Avalanche</p></div> | -                                                                                                                      | [0x41185495Bc8297a65DC46f94001DC7233775EbEe](https://snowtrace.io/address/0x41185495Bc8297a65DC46f94001DC7233775EbEe)    |
| <div style="display: flex; align-items: center;"><img src="./docs/networks/arbitrum.svg" alt="Arbitrum" style="max-width: 25px; margin-right: 5px;"><p style="text-align: center;">Arbitrum</p></div>    | -                                                                                                                      | -                                                                                                                        |
| <div style="display: flex; align-items: center;"><img src="./docs/networks/optimism.svg" alt="Optimism" style="max-width: 25px; margin-right: 5px;"><p style="text-align: center;">Optimism</p></div>    | -                                                                                                                      | -                                                                                                                        |
| <div style="display: flex; align-items: center;"><img src="./docs/networks/bsc.svg" alt="Binance" style="max-width: 25px; margin-right: 5px;"><p style="text-align: center;">Binance</p></div>           | -                                                                                                                      | [0x9d33ee6543C9b2C8c183b8fb58fB089266cffA19](https://bscscan.com/address/0x9d33ee6543C9b2C8c183b8fb58fB089266cffA19)     |
| <div style="display: flex; align-items: center;"><img src="./docs/networks/base.svg" alt="Base" style="max-width: 25px; margin-right: 5px;"><p style="text-align: center;">Base</p></div>                | -                                                                                                                      | -                                                                                                                        |
| <div style="display: flex; align-items: center;"><img src="./docs/networks/metis.svg" alt="Metis" style="max-width: 25px; margin-right: 5px;"><p style="text-align: center;">Metis</p></div>             | -                                                                                                                      | -                                                                                                                        |








<br>

## Security

The following security procedures have been applied:
- Extensive testing and internal review by the BGD Labs team.
  - [Tests suite](./tests/).

- We have engaged [Emanuele Ricci](https://twitter.com/stermi) as external security partner in middle stages of the project, with outstanding results. This procedure was focused on non-biased modelling of the system in terms of flows and any kind of security problem and/or state inconsistency, keeping a tight feedback loop with the development team.


- Extensive properties checking (formal verification) procedure by [Certora](https://www.certora.com/), a security service provider of the Aave DAO.
  - [Report](./security/certora/Formal%20Verification%20Report%20of%20Aave%20Delivery%20Infrastructure.md).
  - [Properties](./security/certora/properties).

- Security review by [SigmaPrime](https://sigmaprime.io/), another security service provider of the Aave DAO.
  - [Reports](./security/sp).
  - [Test suite](https://github.com/sigp/aave-public-tests/tree/main/aave-delivery-infrastructure/tests).

<br>

## License

Copyright © 2023, Aave DAO, represented by its governance smart contracts.

Created by [BGD Labs](https://bgdlabs.com/).

The default license of this repository is [BUSL1.1](./LICENSE), but all interfaces and the content of the [libs folder](./src/contracts/libs/) and [Polygon tunnel](./src/contracts/adapters/polygon/tunnel/) folders are open source, MIT-licensed.

**IMPORTANT**. The BUSL1.1 license of this repository allows for any usage of the software, if respecting the *Additional Use Grant* limitations, forbidding any use case damaging anyhow the Aave DAO's interests.
