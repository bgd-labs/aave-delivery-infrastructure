if [[ "$1" ]]
then
    RULE="--rule $1"
    MSG="--msg \"$1:: $2\""
fi

echo "RULE is ==>" $RULE "<=="

eval \
certoraRun --send_only \
           --fe_version latest \
           certora/confs/CrossChainForwarder-envelopRetry.conf $RULE $MSG


 

#           --server staging \
#           --prover_version jaroslav/UCNotNullFix \
#              --prover_version master \
#           --typecheck_only \

 
# --method "retryTransaction(bytes,uint256,address[])" \
# --method "disableBridgeAdapters_single((address,uint256[])[])" \
# --method "retryEnvelope((uint256,address,address,uint256,uint256,bytes),uint256)" \

