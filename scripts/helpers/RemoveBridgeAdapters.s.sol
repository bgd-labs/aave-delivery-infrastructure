// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

import {ICrossChainForwarder} from '../../src/contracts/interfaces/ICrossChainForwarder.sol';
import {ICrossChainReceiver} from '../../src/contracts/interfaces/ICrossChainReceiver.sol';
import '../BaseScript.sol';

abstract contract BaseRemoveBridgeAdapters is BaseScript {
  function getBridgeAdaptersToDisable()
    public
    view
    virtual
    returns (ICrossChainForwarder.BridgeAdapterToDisable[] memory);

  function getReceiverBridgeAdaptersToDisallow()
    public
    view
    virtual
    returns (ICrossChainReceiver.ReceiverBridgeAdapterConfigInput[] memory);

  function _execute(DeployerHelpers.Addresses memory addresses) internal override {
    ICrossChainForwarder(addresses.crossChainController).disableBridgeAdapters(
      getBridgeAdaptersToDisable()
    );
    ICrossChainReceiver(addresses.crossChainController).disallowReceiverBridgeAdapters(
      getReceiverBridgeAdaptersToDisallow()
    );
  }
}

contract Celo is BaseRemoveBridgeAdapters {
  function TRANSACTION_NETWORK() public pure override returns (uint256) {
    return ChainIds.CELO;
  }

  function getBridgeAdaptersToDisable()
    public
    pure
    override
    returns (ICrossChainForwarder.BridgeAdapterToDisable[] memory)
  {
    ICrossChainForwarder.BridgeAdapterToDisable[]
      memory bridgeAdapters = new ICrossChainForwarder.BridgeAdapterToDisable[](0);
    return bridgeAdapters;
  }

  function getReceiverBridgeAdaptersToDisallow()
    public
    pure
    override
    returns (ICrossChainReceiver.ReceiverBridgeAdapterConfigInput[] memory)
  {
    uint256[] memory chainIds = new uint256[](1);
    chainIds[0] = ChainIds.ETHEREUM;

    ICrossChainReceiver.ReceiverBridgeAdapterConfigInput[]
      memory bridgeAdapters = new ICrossChainReceiver.ReceiverBridgeAdapterConfigInput[](3);
    bridgeAdapters[0] = ICrossChainReceiver.ReceiverBridgeAdapterConfigInput({
      bridgeAdapter: 0xcB1F67533DAD738E1930404bE9D4F844752773DA,
      chainIds: chainIds
    });
    bridgeAdapters[1] = ICrossChainReceiver.ReceiverBridgeAdapterConfigInput({
      bridgeAdapter: 0x2e649f6b54B07E210b31c9cC2eB8a0d5997c3D4A,
      chainIds: chainIds
    });
    bridgeAdapters[2] = ICrossChainReceiver.ReceiverBridgeAdapterConfigInput({
      bridgeAdapter: 0x9fE056F44510F970d724adA16903ba5D75CC4742,
      chainIds: chainIds
    });
    return bridgeAdapters;
  }
}

contract Scroll is BaseRemoveBridgeAdapters {
  function TRANSACTION_NETWORK() public pure override returns (uint256) {
    return ChainIds.ETHEREUM;
  }

  function getBridgeAdaptersToDisable()
    public
    pure
    override
    returns (ICrossChainForwarder.BridgeAdapterToDisable[] memory)
  {
    uint256[] memory chainIds = new uint256[](1);
    chainIds[0] = ChainIds.CELO;

    ICrossChainForwarder.BridgeAdapterToDisable[]
      memory bridgeAdapters = new ICrossChainForwarder.BridgeAdapterToDisable[](1);
    bridgeAdapters[0] = ICrossChainForwarder.BridgeAdapterToDisable({
      bridgeAdapter: 0xFf8C72bE9bE0Fe889e04BBFdA7D83f78dE7A5E64,
      chainIds: chainIds
    });
    return bridgeAdapters;
  }

  function getReceiverBridgeAdaptersToDisallow()
    public
    pure
    override
    returns (ICrossChainReceiver.ReceiverBridgeAdapterConfigInput[] memory)
  {
    ICrossChainReceiver.ReceiverBridgeAdapterConfigInput[]
      memory bridgeAdapters = new ICrossChainReceiver.ReceiverBridgeAdapterConfigInput[](0);

    return bridgeAdapters;
  }
}

contract Ethereum is BaseRemoveBridgeAdapters {
  function TRANSACTION_NETWORK() public pure override returns (uint256) {
    return ChainIds.ETHEREUM;
  }

  function getBridgeAdaptersToDisable()
    public
    pure
    override
    returns (ICrossChainForwarder.BridgeAdapterToDisable[] memory)
  {
    uint256[] memory chainIds = new uint256[](1);
    chainIds[0] = ChainIds.CELO;

    ICrossChainForwarder.BridgeAdapterToDisable[]
      memory bridgeAdapters = new ICrossChainForwarder.BridgeAdapterToDisable[](1);
    bridgeAdapters[0] = ICrossChainForwarder.BridgeAdapterToDisable({
      bridgeAdapter: 0xFf8C72bE9bE0Fe889e04BBFdA7D83f78dE7A5E64,
      chainIds: chainIds
    });
    return bridgeAdapters;
  }

  function getReceiverBridgeAdaptersToDisallow()
    public
    pure
    override
    returns (ICrossChainReceiver.ReceiverBridgeAdapterConfigInput[] memory)
  {
    ICrossChainReceiver.ReceiverBridgeAdapterConfigInput[]
      memory bridgeAdapters = new ICrossChainReceiver.ReceiverBridgeAdapterConfigInput[](0);

    return bridgeAdapters;
  }
}

contract Ethereum_testnet is BaseRemoveBridgeAdapters {
  function TRANSACTION_NETWORK() public pure override returns (uint256) {
    return TestNetChainIds.ETHEREUM_SEPOLIA;
  }

  function getBridgeAdaptersToDisable()
    public
    pure
    override
    returns (ICrossChainForwarder.BridgeAdapterToDisable[] memory)
  {
    uint256[] memory chainIdsCCIP = new uint256[](1);
    //    chainIdsCCIP[0] = TestNetChainIds.AVALANCHE_FUJI;
    chainIdsCCIP[0] = TestNetChainIds.POLYGON_MUMBAI;

    uint256[] memory chainIds = new uint256[](1);
    //    chainIds[0] = TestNetChainIds.AVALANCHE_FUJI;
    chainIds[0] = TestNetChainIds.POLYGON_MUMBAI;
    //    chainIds[2] = TestNetChainIds.BNB_TESTNET;

    ICrossChainForwarder.BridgeAdapterToDisable[]
      memory bridgeAdapters = new ICrossChainForwarder.BridgeAdapterToDisable[](1);
    //    bridgeAdapters[0] = ICrossChainForwarder.BridgeAdapterToDisable({
    //      bridgeAdapter: 0xE1A717B665459637A0AcFB8a536a53eBDa94581a,
    //      chainIds: chainIdsCCIP
    //    });
    bridgeAdapters[0] = ICrossChainForwarder.BridgeAdapterToDisable({
      bridgeAdapter: 0xeD0F3E2b1Acc1812c798e4a98AA43C690F6aeAda,
      chainIds: chainIds
    });
    //    bridgeAdapters[2] = ICrossChainForwarder.BridgeAdapterToDisable({
    //      bridgeAdapter: 0x20fEA454Da2bF5bcfE444eb012BeF0B44b7D5059,
    //      chainIds: chainIds
    //    });
    return bridgeAdapters;
  }

  function getReceiverBridgeAdaptersToDisallow()
    public
    pure
    override
    returns (ICrossChainReceiver.ReceiverBridgeAdapterConfigInput[] memory)
  {
    uint256[] memory chainIdsCCIP = new uint256[](1);
    //    chainIdsCCIP[0] = TestNetChainIds.AVALANCHE_FUJI;
    chainIdsCCIP[0] = TestNetChainIds.POLYGON_MUMBAI;

    uint256[] memory chainIds = new uint256[](1);
    //    chainIds[0] = TestNetChainIds.AVALANCHE_FUJI;
    chainIds[0] = TestNetChainIds.POLYGON_MUMBAI;
    //    chainIds[2] = TestNetChainIds.BNB_TESTNET;

    ICrossChainReceiver.ReceiverBridgeAdapterConfigInput[]
      memory bridgeAdapters = new ICrossChainReceiver.ReceiverBridgeAdapterConfigInput[](1);

    //    bridgeAdapters[0] = ICrossChainReceiver.ReceiverBridgeAdapterConfigInput({
    //      bridgeAdapter: 0xE1A717B665459637A0AcFB8a536a53eBDa94581a,
    //      chainIds: chainIdsCCIP
    //    });
    bridgeAdapters[0] = ICrossChainReceiver.ReceiverBridgeAdapterConfigInput({
      bridgeAdapter: 0xeD0F3E2b1Acc1812c798e4a98AA43C690F6aeAda,
      chainIds: chainIds
    });
    //    bridgeAdapters[2] = ICrossChainReceiver.ReceiverBridgeAdapterConfigInput({
    //      bridgeAdapter: 0x20fEA454Da2bF5bcfE444eb012BeF0B44b7D5059,
    //      chainIds: chainIds
    //    });

    return bridgeAdapters;
  }
}

contract Avalanche_testnet is BaseRemoveBridgeAdapters {
  function TRANSACTION_NETWORK() public pure override returns (uint256) {
    return TestNetChainIds.AVALANCHE_FUJI;
  }

  function getBridgeAdaptersToDisable()
    public
    pure
    override
    returns (ICrossChainForwarder.BridgeAdapterToDisable[] memory)
  {
    uint256[] memory chainIds = new uint256[](1);
    chainIds[0] = TestNetChainIds.ETHEREUM_SEPOLIA;

    ICrossChainForwarder.BridgeAdapterToDisable[]
      memory bridgeAdapters = new ICrossChainForwarder.BridgeAdapterToDisable[](3);
    bridgeAdapters[0] = ICrossChainForwarder.BridgeAdapterToDisable({
      bridgeAdapter: 0xcbfDCff31af9813623639B85A4Cc5A99A78898B2,
      chainIds: chainIds
    });
    bridgeAdapters[1] = ICrossChainForwarder.BridgeAdapterToDisable({
      bridgeAdapter: 0xb61D46ef1a62FdEd0b4F7bcAc621c0fe711573D4,
      chainIds: chainIds
    });
    bridgeAdapters[2] = ICrossChainForwarder.BridgeAdapterToDisable({
      bridgeAdapter: 0x308Bf3A446F79097053126C5cB2D53a9FcbA6d7C,
      chainIds: chainIds
    });

    return bridgeAdapters;
  }

  function getReceiverBridgeAdaptersToDisallow()
    public
    pure
    override
    returns (ICrossChainReceiver.ReceiverBridgeAdapterConfigInput[] memory)
  {
    uint256[] memory chainIds = new uint256[](1);
    chainIds[0] = TestNetChainIds.ETHEREUM_SEPOLIA;

    ICrossChainReceiver.ReceiverBridgeAdapterConfigInput[]
      memory bridgeAdapters = new ICrossChainReceiver.ReceiverBridgeAdapterConfigInput[](3);

    bridgeAdapters[0] = ICrossChainReceiver.ReceiverBridgeAdapterConfigInput({
      bridgeAdapter: 0xcbfDCff31af9813623639B85A4Cc5A99A78898B2,
      chainIds: chainIds
    });
    bridgeAdapters[1] = ICrossChainReceiver.ReceiverBridgeAdapterConfigInput({
      bridgeAdapter: 0xb61D46ef1a62FdEd0b4F7bcAc621c0fe711573D4,
      chainIds: chainIds
    });
    bridgeAdapters[2] = ICrossChainReceiver.ReceiverBridgeAdapterConfigInput({
      bridgeAdapter: 0x308Bf3A446F79097053126C5cB2D53a9FcbA6d7C,
      chainIds: chainIds
    });

    return bridgeAdapters;
  }
}

contract Polygon_testnet is BaseRemoveBridgeAdapters {
  function TRANSACTION_NETWORK() public pure override returns (uint256) {
    return TestNetChainIds.POLYGON_MUMBAI;
  }

  function getBridgeAdaptersToDisable()
    public
    pure
    override
    returns (ICrossChainForwarder.BridgeAdapterToDisable[] memory)
  {
    uint256[] memory chainIds = new uint256[](1);
    chainIds[0] = TestNetChainIds.ETHEREUM_SEPOLIA;

    ICrossChainForwarder.BridgeAdapterToDisable[]
      memory bridgeAdapters = new ICrossChainForwarder.BridgeAdapterToDisable[](1);
    bridgeAdapters[0] = ICrossChainForwarder.BridgeAdapterToDisable({
      bridgeAdapter: 0x0b367e246651657B3Dcb501bd59E3fAfaC99e7a8,
      chainIds: chainIds
    });
    //    bridgeAdapters[1] = ICrossChainForwarder.BridgeAdapterToDisable({
    //      bridgeAdapter: 0x64033B2270fd9D6bbFc35736d2aC812942cE75fE,
    //      chainIds: chainIds
    //    });
    //    bridgeAdapters[2] = ICrossChainForwarder.BridgeAdapterToDisable({
    //      bridgeAdapter: 0x5F53594445823139efbe8a85fAB45E83e865B5b9,
    //      chainIds: chainIds
    //    });

    return bridgeAdapters;
  }

  function getReceiverBridgeAdaptersToDisallow()
    public
    pure
    override
    returns (ICrossChainReceiver.ReceiverBridgeAdapterConfigInput[] memory)
  {
    uint256[] memory chainIds = new uint256[](1);
    chainIds[0] = TestNetChainIds.ETHEREUM_SEPOLIA;

    ICrossChainReceiver.ReceiverBridgeAdapterConfigInput[]
      memory bridgeAdapters = new ICrossChainReceiver.ReceiverBridgeAdapterConfigInput[](1);

    bridgeAdapters[0] = ICrossChainReceiver.ReceiverBridgeAdapterConfigInput({
      bridgeAdapter: 0x0b367e246651657B3Dcb501bd59E3fAfaC99e7a8,
      chainIds: chainIds
    });
    //    bridgeAdapters[1] = ICrossChainReceiver.ReceiverBridgeAdapterConfigInput({
    //      bridgeAdapter: 0x64033B2270fd9D6bbFc35736d2aC812942cE75fE,
    //      chainIds: chainIds
    //    });
    //    bridgeAdapters[2] = ICrossChainReceiver.ReceiverBridgeAdapterConfigInput({
    //      bridgeAdapter: 0x5F53594445823139efbe8a85fAB45E83e865B5b9,
    //      chainIds: chainIds
    //    });

    return bridgeAdapters;
  }
}

contract Binance_testnet is BaseRemoveBridgeAdapters {
  function TRANSACTION_NETWORK() public pure override returns (uint256) {
    return TestNetChainIds.BNB_TESTNET;
  }

  function getBridgeAdaptersToDisable()
    public
    pure
    override
    returns (ICrossChainForwarder.BridgeAdapterToDisable[] memory)
  {
    uint256[] memory chainIds = new uint256[](1);
    chainIds[0] = TestNetChainIds.ETHEREUM_SEPOLIA;

    ICrossChainForwarder.BridgeAdapterToDisable[]
      memory bridgeAdapters = new ICrossChainForwarder.BridgeAdapterToDisable[](2);
    bridgeAdapters[0] = ICrossChainForwarder.BridgeAdapterToDisable({
      bridgeAdapter: 0xF1a818CE6b4F49452388099e6E671E42F1767AB6,
      chainIds: chainIds
    });
    bridgeAdapters[1] = ICrossChainForwarder.BridgeAdapterToDisable({
      bridgeAdapter: 0x2FD0ea3cF58cB9cD25c2a186E643629198A37600,
      chainIds: chainIds
    });

    return bridgeAdapters;
  }

  function getReceiverBridgeAdaptersToDisallow()
    public
    pure
    override
    returns (ICrossChainReceiver.ReceiverBridgeAdapterConfigInput[] memory)
  {
    uint256[] memory chainIds = new uint256[](1);
    chainIds[0] = TestNetChainIds.ETHEREUM_SEPOLIA;

    ICrossChainReceiver.ReceiverBridgeAdapterConfigInput[]
      memory bridgeAdapters = new ICrossChainReceiver.ReceiverBridgeAdapterConfigInput[](2);

    bridgeAdapters[0] = ICrossChainReceiver.ReceiverBridgeAdapterConfigInput({
      bridgeAdapter: 0xF1a818CE6b4F49452388099e6E671E42F1767AB6,
      chainIds: chainIds
    });
    bridgeAdapters[1] = ICrossChainReceiver.ReceiverBridgeAdapterConfigInput({
      bridgeAdapter: 0x2FD0ea3cF58cB9cD25c2a186E643629198A37600,
      chainIds: chainIds
    });

    return bridgeAdapters;
  }
}
