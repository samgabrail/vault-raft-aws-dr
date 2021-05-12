#!/usr/bin/env bash
declare -A tpl_vault_node_address_names
tpl_vault_node_address_names=(["vault_1"]="10.0.101.22" ["vault_2"]="10.0.101.23" ["vault_3"]="10.0.101.24" ["vault_1_DR"]="10.0.101.25" ["vault_2_DR"]="10.0.101.26" ["vault_3_DR"]="10.0.101.27")
for name, address in tpl_vault_node_address_names
echo "${address} ${name}" | sudo tee -a testHosts
end