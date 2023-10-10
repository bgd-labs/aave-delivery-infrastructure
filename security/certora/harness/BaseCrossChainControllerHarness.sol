pragma solidity ^0.8.8;

import {BaseCrossChainController} from '../../../src/contracts/BaseCrossChainController.sol';
import {CrossChainReceiverHarnessAbstract} from './CrossChainReceiverHarnessAbstract.sol';

contract BaseCrossChainControllerHarness is BaseCrossChainController, CrossChainReceiverHarnessAbstract {

}
