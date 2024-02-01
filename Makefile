# To avoid make printing out commands and potentially exposing private keys, prepend an "@" to the command.
# include .env file and export its env vars
# (-include to ignore error if it does not exist)
-include .env

# deps
update:; forge update

# Build & test
build  :; forge build --sizes --via-ir
test   :; forge test -vvv

# ---------------------------------------------- BASE SCRIPT CONFIGURATION ---------------------------------------------

BASE_LEDGER = --legacy --mnemonics foo --ledger --mnemonic-indexes $(MNEMONIC_INDEX) --sender $(LEDGER_SENDER)
BASE_KEY = --private-key ${PRIVATE_KEY}



custom_ethereum := --with-gas-price 10000000000 # 53 gwei
custom_polygon :=  --with-gas-price 100000000000 # 560 gwei
custom_polygon_mumbai :=  --with-gas-price 100000000000 # 560 gwei
custom_avalanche := --with-gas-price 27000000000 # 27 gwei
custom_metis-testnet := --legacy --verifier-url https://goerli.explorer.metisdevops.link/api/
custom_metis := --verifier-url  https://api.routescan.io/v2/network/mainnet/evm/1088/etherscan
custom_scroll-testnet := --legacy --with-gas-price 1000000000 # 1 gwei

# params:
#  1 - path/file_name
#  2 - network name
#  3 - script to call if not the same as network name (optional)
#  to define custom params per network add vars custom_network-name
#  to use ledger, set LEDGER=true to env
#  default to testnet deployment, to run production, set PROD=true to env
define deploy_single_fn
 DEPLOYMENT_VERSION=$(4) CHAIN_ID=$(2) forge script \
 scripts/$(1).s.sol:$(if $(3),$(3),$(1)) \
 --rpc-url $(2) --broadcast --verify --slow -vvvv \
 $(if $(LEDGER),$(BASE_LEDGER),$(BASE_KEY)) \
 $(custom_$(2))
endef

define deploy_fn
	@for chain in $$(jq -r '.chains[]' deployments/deployment_configurations/deploymentConfigs_$(3).json); do \
		echo $$chain; \
		$(call deploy_single_fn,$(1),$$chain,$(2),$(3)); \
	done
endef

# ----------------------------------------------------------------------------------------------------------------------
# ----------------------------------------- PRODUCTION DEPLOYMENT SCRIPTS ---------------------------------------------------------

# deploy emergency registry
deploy-emergency-registry:
	$(call deploy_fn,Deploy_EmergencyRegistry,DeployEmergencyMode,7)

# Deploy Proxy Factories on all networks
deploy-proxy-factory:
	$(call deploy_fn,InitialDeployments,InitialDeployments,3)

# Deploy Cross Chain Infra on all networks
deploy-cross-chain-infra:
	$(call deploy_fn,CCC/Deploy_CCC,Deploy_CCC,3)

## Deploy CCIP bridge adapters on all networks
deploy-ccip-bridge-adapters:
	$(call deploy_fn,Adapters/DeployCCIP,DeployCCIPAdapter,4)

## Deploy LayerZero bridge adapters on all networks
deploy-lz-bridge-adapters:
	$(call deploy_fn,Adapters/DeployLZ,DeployLZAdapter,1)

## Deploy HyperLane bridge adapters on all networks
deploy-hl-bridge-adapters:
	$(call deploy_fn,Adapters/DeployHL,DeployHLAdapter,1)

## Deploy SameChain adapters on ethereum
deploy-same-chain-adapters:
	$(call deploy_fn,Adapters/DeploySameChainAdapter,DeploySameChainAdapter,1)

deploy-optimism-adapters:
	$(call deploy_fn,Adapters/DeployOpAdapter,DeployOpAdapter,1)

deploy-arbitrum-adapters:
	$(call deploy_fn,Adapters/DeployArbAdapter,DeployArbAdapter,1)

deploy-metis-adapters:
	$(call deploy_fn,Adapters/DeployMetisAdapter,DeployMetisAdapter,1)

deploy-polygon-adapters:
	$(call deploy_fn,Adapters/DeployPolygon,DeployPolygonAdapter,1)

deploy-base-adapters:
	$(call deploy_fn,Adapters/DeployCBaseAdapter,DeployCBAdapter,1)

deploy-gnosis-adapters:
	$(call deploy_fn,Adapters/DeployGnosisChain,DeployGnosisChainAdapter,1)

deploy-scroll-adapters:
	$(call deploy_fn,Adapters/DeployScrollAdapter,DeployScrollAdapter,1)

deploy-zkevm-adapters:
	$(call deploy_fn,Adapters/DeployZkEVMAdapter,DeployZkEVMAdapter,1)

## Set sender bridge dapters. Only eth pol avax are needed as other networks will only receive
set-ccf-sender-adapters:
	$(call new_deploy_fn,CCC/Set_CCF_Sender_Adapters,EnableCCFSenderAdapters,4)

# Set the bridge adapters allowed to receive messages
set-ccr-receiver-adapters:
	$(call new_deploy_fn,CCC/Set_CCR_Receivers_Adapters,SetCCRAdapters,5)

# Sets the required confirmations
set-ccr-confirmations:
	$(call new_deploy_fn,CCC/Set_CCR_Confirmations,SetCCRConfirmations,6)

# Funds CCC
fund-crosschain:
	$(call deploy_fn,CCC/FundCCC,FundCrossChainController,1)

## Deploy and configure all contracts
deploy-full:
		make deploy-proxy-factory
		make deploy-cross-chain-infra
		make deploy-ccip-bridge-adapters
		make deploy-lz-bridge-adapters
		make deploy-hl-bridge-adapters
		make deploy-same-chain-adapters
		make deploy-optimism-adapters
		make deploy-arbitrum-adapters
		make deploy-metis-adapters
		make deploy-polygon-adapters
		make set-ccf-approved-senders
		make set-ccf-sender-adapters
		make set-ccr-receiver-adapters
		make set-ccr-confirmations
		make fund-crosschain
		make write-json-addresses

# ----------------------------------------------------------------------------------------------------------------------
# ----------------------------------------- HELPER SCRIPTS ---------------------------------------------------------
#remove-bridge-adapters:
#	$(call deploy_fn,helpers/RemoveBridgeAdapters,ethereum avalanche polygon binance)

#send-direct-message:
#	$(call deploy_fn,helpers/Send_Direct_CCMessage,ethereum)

#deploy_mock_destination:
#	$(call deploy_fn,helpers/Deploy_Mock_destination,zkevm)

set-approved-ccf-senders:
	$(call new_deploy_fn,CCC/Set_CCF_Approved_Senders,SetCCFApprovedSenders,6)

#send-message:
#	@$(call deploy_fn,helpers/Testnet_ForwardMessage,ethereum,Testnet_ForwardMessage)

#deploy_mock_ccc:
#	$(call deploy_fn,helpers/mocks/Deploy_Mock_CCC,zkevm)

#send-message-via-adapter:
#	$(call deploy_fn,helpers/Send_Message_Via_Adapter,ethereum)

#send-message-ccc:
#	@$(call deploy_fn,CCC/SendMessage,ethereum)

remove-adapters-custom:
	@$(call deploy_fn,CCC/Remove_CCF_Sender_Adapters,ethereum scroll)
