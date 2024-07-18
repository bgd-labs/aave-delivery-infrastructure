import "base.spec";

/*==============================================================================
  rule: _shuffle__amount_of_bridges
  description: Check that the amount of bridges is in accordance with the value
               of the optimal-bandwith. Namely, if the amount is 0 or biffer than 
               the total amount of bridges we use all the bridges, and otherwise 
               the number of bridges is the optimal-bandwith.
  status: PASS.
  ============================================================================*/
rule _shuffle__amount_of_bridges() {
  env e;

  uint256 destinationChainId;
  address destination;
  uint256 gasLimit;
  bytes message;

  forwardMessage(e, destinationChainId, destination, gasLimit, message);

  uint256 bandwith = getOptimalBandwidthByChain(e,destinationChainId);
  uint256 total_num_of_active_bridges = getForwarderBridgeAdaptersByChain_len(destinationChainId);

  uint256 num_of_active_bridges = get_num_of_active_bridges();

  assert (bandwith==0 || bandwith>=total_num_of_active_bridges) => num_of_active_bridges==total_num_of_active_bridges;
  assert !(bandwith==0 || bandwith>=total_num_of_active_bridges) => num_of_active_bridges==bandwith;
}


/*==============================================================================
  rule: _shuffle__uniqueness_of_bridges
  description: Check that the shuffling process doesn't produces the same adapter
               more than once. Namely we check that all the adapters that are passed
               to the function _bridgeTransaction are different from each other.
  assumption: we only check for the case that the number of bridge-adapters is 4,
              and the optimal-bandwith is 3.
  status: PASS.
  ============================================================================*/
rule _shuffle__uniqueness_of_bridges(method f) {
  env e;
  calldataarg args;

  reset_harness_storage();
  f(e,args);

  uint256 destinationChainId = get_param_destinationChainId();
  require getForwarderBridgeAdaptersByChain_len(destinationChainId)==4;

  address d0 = getForwarderBridgeAdaptersByChainAtPos_dest(destinationChainId,0);
  address d1 = getForwarderBridgeAdaptersByChainAtPos_dest(destinationChainId,1);
  address d2 = getForwarderBridgeAdaptersByChainAtPos_dest(destinationChainId,2);
  address d3 = getForwarderBridgeAdaptersByChainAtPos_dest(destinationChainId,3);

  address c0 = getForwarderBridgeAdaptersByChainAtPos_curr(destinationChainId,0);
  address c1 = getForwarderBridgeAdaptersByChainAtPos_curr(destinationChainId,1);
  address c2 = getForwarderBridgeAdaptersByChainAtPos_curr(destinationChainId,2);
  address c3 = getForwarderBridgeAdaptersByChainAtPos_curr(destinationChainId,3);

  require d0 != d1 && d0 != d2 && d0 != d3;
  require             d1 != d2 && d1 != d3;
  require                         d2 != d3;

  require c0 != c1 && c0 != c2 && c0 != c3;
  require             c1 != c2 && c1 != c3;
  require                         c2 != c3;


  uint256 bandwith = getOptimalBandwidthByChain(e,destinationChainId);

  uint256 num_of_active_bridges = get_num_of_active_bridges();
  require get_num_of_active_bridges()==3;

  address active_d0 = get_active_bridges_dest()[0];
  address active_d1 = get_active_bridges_dest()[1];
  address active_d2 = get_active_bridges_dest()[2];

  address active_c0 = get_active_bridges_dest()[0];
  address active_c1 = get_active_bridges_dest()[1];
  address active_c2 = get_active_bridges_dest()[2];

  assert bridgeTransaction_was_called() => (active_d0 != active_d1 && active_d1 != active_d2 && active_d0 != active_d2);
  assert bridgeTransaction_was_called() => (active_c0 != active_c1 && active_c1 != active_c2 && active_c0 != active_c2);
}

