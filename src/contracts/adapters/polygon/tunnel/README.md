## Claiming Polygon => Ethereum Messages
While messaging to Polygon from Ethereum is "automatic," messaging from Ethereum to Polygon requires an active claiming transaction to process the transaction on Ethereum.

In order to do this, refer to [these docs.](https://wiki.polygon.technology/docs/pos/design/bridge/l1-l2-communication/state-transfer/#state-transfer-from-polygon--ethereum)

Essentially, the steps are as follows:

1. Note the bridging out ("burn") transaction hash on Polygon.
2. Query the API with your noted transaction hash at `https://proof-generator.polygon.technology/api/v1/matic/exit-payload/{BURN_TX_HASH_HERE}?eventSignature=0x8c5261668696ce22758910d05bab8f186d6eb247ceac2af2e82c7dc17669b036`
3. Call the `receiveMessage()` function on the `FxTunnelEthereum` contract with the data returned from the API in step 2 as the input data.

Note that the API will only return the data needed once the "burn" transaction was checkpointed (checkpoints are snapshots of the Polygon chain state published to Ethereum).