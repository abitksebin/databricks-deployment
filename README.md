Markdown · README.md

# Azure Databricks Platform with Terraform and Terragrunt

Infrastructure as code for a secure Azure Databricks platform: a VNet-injected workspace with secure cluster connectivity, Unity Catalog, and baseline workspace configuration. Terraform modules are orchestrated by Terragrunt, one unit per layer, with remote state in Azure Storage.

## What gets deployed

| Unit | Module | Creates |
| --- | --- | --- |
| `network` | `modules/network` | Resource group, VNet, two delegated Databricks subnets (host and container), NSG, NAT gateway with static public IP, subnet reserved for private endpoints |
| `workspace` | `modules/databricks-workspace` | Premium Azure Databricks workspace injected into the VNet, no public IPs on nodes (secure cluster connectivity), managed resource group |
| `unity-catalog` | `modules/databricks-unity-catalog` | ADLS Gen2 storage for the metastore root, access connector (managed identity) with Storage Blob Data Contributor, metastore, workspace assignment |
| `workspace-config` | `modules/databricks-config` | Cluster policy, `data-engineers` group, shared autoscaling cluster, permissions |

Apply order is resolved by Terragrunt: `network` -> `workspace` -> `unity-catalog` -> `workspace-config`.

## Repository layout

```
.
├── root.hcl                          # remote state, azurerm provider generation, shared inputs
├── modules/
│   ├── network/
│   ├── databricks-workspace/
│   ├── databricks-unity-catalog/
│   └── databricks-config/
├── live/
│   └── dev/
│       ├── env.hcl                   # subscription, account ID, region, state backend (edit this)
│       ├── network/terragrunt.hcl
│       ├── workspace/terragrunt.hcl
│       ├── unity-catalog/terragrunt.hcl
│       └── workspace-config/terragrunt.hcl
└── scripts/
    └── bootstrap-state.sh            # creates the Terraform state storage account
```

To add staging or prod, copy `live/dev` to `live/<env>` and edit `env.hcl` and the unit inputs.

## Prerequisites

**Tooling**

- Terraform >= 1.6
- Terragrunt (a version that supports `root.hcl`)
- Azure CLI, logged in with `az login`

**Azure**

- Contributor plus User Access Administrator (or Owner) on the target subscription. Unity Catalog creates a role assignment, which Contributor alone cannot do.
- Resource providers registered: `Microsoft.Databricks`, `Microsoft.Network`, `Microsoft.Storage`, `Microsoft.Compute`.
- Enough vCPU quota in the chosen region for the node type (default `Standard_DS3_v2`, roughly 16 vCPUs at max autoscale).
- Globally unique names for the state and Unity Catalog storage accounts.
- A managed resource group name that does not already exist (`rg-dbx-dev-databricks-managed` by default).
- VNet and subnet CIDRs that do not overlap networks you will peer or connect to later.

**Databricks**

- A Databricks **account ID** (account console at `accounts.azuredatabricks.net`). The account exists once the first workspace is created in your tenant.
- The identity applying the `unity-catalog` unit must be a Databricks **account admin**. Workspace admin is not enough.

## Getting started

1. **Configure the environment.** Edit `live/dev/env.hcl`:
   - `subscription_id`
   - `state_resource_group`, `state_storage_account`, `state_container`
   - `databricks_account_id` (can be filled in after step 4)
2. **Create the state backend** (once per environment):

   ```bash
   ./scripts/bootstrap-state.sh <subscription_id> uksouth rg-tfstate-dev <storage_account_name>
   ```
3. **Review inputs** in each `live/dev/*/terragrunt.hcl` (CIDRs, names, node type, autoscale limits). Change the placeholder Unity Catalog storage account name (`stdbxucdev001`), which must be globally unique.
4. **Deploy.** The Databricks account ID only becomes available once a workspace exists, so on a brand-new tenant apply the first two units first:

   ```bash
   cd live/dev
   terragrunt run-all plan
   (cd network && terragrunt apply)
   (cd workspace && terragrunt apply)
   # fill in databricks_account_id in env.hcl, make yourself account admin, then:
   terragrunt run-all apply
   ```

   If you already have a Databricks account, skip straight to `terragrunt run-all apply`.

On older Terragrunt versions use `terragrunt run-all ...`; on newer ones `terragrunt run --all ...`.

## Design notes

- **Secure cluster connectivity.** Nodes have no public IPs. Outbound traffic leaves through a NAT gateway with a static IP (`nat_public_ip` output), which is handy for firewall allow-lists.
- **NSG is empty on purpose.** Databricks adds its own rules through the subnet delegation.
- **Subnet sizing.** Each node uses one IP in each of the two Databricks subnets, and Azure reserves 5 per subnet. A `/24` is fine for dev; use `/22` or larger for production.
- **Why `workspace-config` is a separate unit.** The Databricks provider needs the workspace URL, which only exists after the workspace is created.
- **Why `unity-catalog` is a separate unit.** It uses the account-level Databricks provider and different permissions from workspace configuration.
- **Dependency mocks.** `mock_outputs` allow `init`, `validate` and `plan` to run before upstream units are deployed. They are never used for `apply`.

### Unity Catalog

- Azure allows **one metastore per region per account**. If one already exists, set `existing_metastore_id` in `live/dev/unity-catalog/terragrunt.hcl`; the unit then only assigns the workspace to it.
- The metastore root storage uses default network rules. For locked-down environments, add a firewall or private endpoint (the `private_endpoints` subnet is already provisioned) and allow the access connector.
- Catalogs and schemas are not created here. They are workspace-scoped, so add a further unit using the workspace-level provider.

## Authentication

- **Local:** Azure CLI login for both the `azurerm` and `databricks` providers.
- **CI:** set `ARM_CLIENT_ID`, `ARM_CLIENT_SECRET`, `ARM_TENANT_ID` and `ARM_SUBSCRIPTION_ID` for a service principal. It needs the Azure roles above, Storage Blob Data Contributor on the state account, and must be a workspace admin and an account admin in Databricks.

## Not included

- Private Link (front-end and back-end) and private DNS zones, needed to disable public network access
- Customer-managed keys
- Diagnostic settings to Log Analytics, Azure Policy and budgets
- Entra ID group sync (SCIM) in place of the workspace-local group
- Unity Catalog catalogs, schemas and grants

## Cleaning up

```bash
cd live/dev
terragrunt run-all destroy
```

Destroying the metastore fails if it contains catalogs unless `force_destroy` is set. Remove the state backend manually afterwards.

## Contributing

1. Branch from `main`.
2. Run `terraform fmt -recursive` and `terragrunt run-all validate`.
3. Open a pull request describing the change and the plan output.

## License
-