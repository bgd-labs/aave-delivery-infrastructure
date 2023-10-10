
/* =================================================================================
   Rule: sanity / sanity_false.
   Status: all fail as expected. For that we use: 
           - hashing_length_bound: 384. This is the minimal (in 32 jumps) that works.
           - copyLoopUnroll: 10 (this parameter may not be the minimal).
   ================================================================================*/
rule sanity(method f) {
    env e;
    calldataarg args;
    f(e,args);
    satisfy true;
}


//rule sanity_false(method f) {
//    env e;
//    calldataarg args;
//    f(e,args);
//    assert false;
//}

