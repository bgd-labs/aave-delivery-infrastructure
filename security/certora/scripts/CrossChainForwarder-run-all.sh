
certoraRun --send_only \
           --fe_version latest \
           certora/confs/CrossChainForwarder-sanity.conf 

certoraRun --send_only \
           --fe_version latest \
           certora/confs/CrossChainForwarder-envelopRetry.conf

certoraRun --send_only \
           --fe_version latest \
           certora/confs/CrossChainForwarder-newEnvelope.conf

certoraRun --send_only \
           --fe_version latest \
           certora/confs/CrossChainForwarder-simpleRules.conf

certoraRun --send_only \
           --fe_version latest \
           certora/confs/CrossChainForwarder-invariants.conf
