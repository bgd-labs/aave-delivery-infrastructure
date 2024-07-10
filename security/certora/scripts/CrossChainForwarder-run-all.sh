
certoraRun security/certora/confs/verifyCrossChainForwarder-sanity.conf 

certoraRun security/certora/confs/verifyCrossChainForwarder-envelopRetry.conf

certoraRun security/certora/confs/verifyCrossChainForwarder-newEnvelope.conf

certoraRun security/certora/confs/verifyCrossChainForwarder-simpleRules.conf

certoraRun security/certora/confs/verifyCrossChainForwarder-invariants.conf

certoraRun security/certora/confs/verifyCrossChainForwarder-encode-decode-correct.conf \
           --rule encode_decode_well_formed_TX

certoraRun security/certora/confs/verifyCrossChainForwarder-shuffle.conf

