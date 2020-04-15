### oci
export TF_VAR_oci_tenancy_ocid="ocid1.tenancy.oc1.."
export TF_VAR_oci_user_ocid="ocid1.user.oc1.."
export TF_VAR_oci_compartment_ocid="ocid1.compartment.oc1.."
export TF_VAR_oci_fingerprint=
export TF_VAR_oci_private_key_path=.oci/oci_api_key.pem
export TF_VAR_ssh_public_key=$(cat ~/.ssh/id_rsa.pub)

export TF_VAR_oci_region="eu-frankfurt-1"

export TF_VAR_peering_net="10.99.0"

export TF_VAR_oci_cidr_vpn_vcn="10.3.0.0/16"
export TF_VAR_oci_cidr_vpn_subnet="10.3.1.0/24"

### azure
export TF_VAR_arm_client_id=""
export TF_VAR_arm_client_secret=""
export TF_VAR_arm_tenant_id=""
export TF_VAR_arm_subscription_id=""
export TF_VAR_arm_region="germanywestcentral"

# test vnet
export TF_VAR_arm_cidr_vpn_vnet="10.2.0.0/16"
export TF_VAR_arm_cidr_vpn_subnet="10.2.1.0/24"
export TF_VAR_arm_cidr_vpn_gw_subnet="10.2.99.0/24"


