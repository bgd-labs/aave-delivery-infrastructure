pragma solidity ^0.8.8;

import {ICrossChainReceiverHarness} from './ICrossChainReceiverHarness.sol';

contract BaseReceiverPortalDummy {
  
    uint256 public receiveCrossChainMessage_success_counter;
  //  bool internal receiveCrossChainMessage_reverts;
  //  mapping(uint256 => bool) internal _receiveCrossChainMessage_reverts;
//  bool [100] internal _receiveCrossChainMessage_reverts;
  bool internal _receiveCrossChainMessage_reverts;
  

    function receiveCrossChainMessage_reverts() internal view returns (bool) {return _receiveCrossChainMessage_reverts;}


   function receiveCrossChainMessage(address originSender, uint256 originChainId, bytes memory message) external{
      //  require( ( receiveCrossChainMessage_success_counter <  60)); 
      //   require (!_receiveCrossChainMessage_reverts[receiveCrossChainMessage_success_counter]);
        address ad;
     //   require(ICrossChainReceiverHarness(ad).receiveCrossChainMessage_reverts());
        require ( receiveCrossChainMessage_reverts());
        receiveCrossChainMessage_success_counter++;
      
    }

}