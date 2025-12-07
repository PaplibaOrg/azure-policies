# Azure Policy Management

Terraform infrastructure-as-code for Azure Policy definitions, initiatives (policy sets), and assignments following Azure Cloud Adoption Framework (CAF) best practices.

## Overview

This repository provides Terraform modules to deploy and manage Azure Policies according to CAF recommendations. It supports policy definitions, policy initiatives (policy sets), and policy assignments at management group or subscription scope.

## Repository Structure

```
azure-policies/
├── .husky/                          # Git hooks for commit linting
├── .instructions/                    # Platform standards and guidelines
├── modules/
│   ├── resources/
│   │   ├── policy-definition/        # Single policy definition module
│   │   ├── policy-initiative/        # Policy initiative (policy set) module
│   │   └── policy-assignment/        # Policy assignment module
│   └── services/
│       └── policies/                 # Policy orchestration module
├── policies/                         # Policy deployment files
│   ├── policy-definitions/          # Policy definitions
│   │   ├── dev-plb-root/
│   │   │   ├── main.tf
│   │   │   ├── provider.tf
│   │   │   └── platform/
│   │   │       └── policy-vending.json
│   │   ├── test-plb-root/
│   │   └── plb-root/
│   ├── policy-initiatives/          # Policy initiatives
│   │   ├── dev-plb-root/
│   │   ├── test-plb-root/
│   │   └── plb-root/
│   └── policy-assignments/          # Policy assignments
│       ├── dev-plb-root/
│       ├── test-plb-root/
│       └── plb-root/
├── pipeline/
│   ├── deploy-policy-definitions.yaml
│   ├── deploy-policy-initiatives.yaml
│   ├── deploy-policy-assignments.yaml
│   └── templates/
│       └── deploy-terraform.yaml
├── .gitignore
├── commitlint.config.js
├── package.json
└── README.md
```

## CAF Policy Management Principles

This repository implements policy management following CAF best practices:

1. **Policy-Driven Governance**: Use Azure Policy to enforce organizational standards and compliance
2. **Management Group Hierarchy**: Deploy policies at appropriate management group levels for inheritance
3. **Policy Initiatives**: Group related policies into initiatives for easier management
4. **Assignment Strategy**: Assign policies at management group level for automatic inheritance
5. **Enforcement Modes**: Support both enforcement and audit modes

## Prerequisites

- Azure subscription with Policy Contributor role
- Terraform >= 1.0
- Azure CLI installed and configured
- Azure DevOps with self-hosted agent pool (`default`)
- User-assigned managed identity: `id-policy-vending-eus-dev-001` (for dev environment)
- Node.js and npm (for commit linting)

## Getting Started

### Initial Setup

```bash
# Clone the repository
git clone https://github.com/PaplibaOrg/azure-policies.git
cd azure-policies

# Install git hooks for commit message validation
npm install
```

### Configuration

1. **Create Policy Configuration Files**

   Create JSON files in the appropriate directory structure:
   - **Policy Definitions**: `policies/policy-definitions/<env>/platform/<name>.json`
   - **Policy Initiatives**: `policies/policy-initiatives/<env>/platform/<name>.json`
   - **Policy Assignments**: `policies/policy-assignments/<env>/platform/<name>.json`

   ```json
   {
     "environment": "dev",
     "version": "1.0.0",
     "tags": {
       "owner": "sunny.bharne",
       "application": "vending"
     },
     "policy_definitions": {
       "require-tag-environment": {
         "name": "require-tag-environment",
         "display_name": "Require Environment Tag",
         "description": "Ensures all resources have an environment tag",
         "policy_rule": "{...}"
       }
     },
     "policy_initiatives": {},
     "policy_assignments": {
       "assign-require-tag-environment": {
         "name": "assign-require-tag-environment",
         "display_name": "Assign Require Environment Tag Policy",
         "scope": "/providers/Microsoft.Management/managementGroups/dev-plb-platform",
         "policy_definition_id": "/providers/Microsoft.Management/managementGroups/dev-plb-platform/providers/Microsoft.Authorization/policyDefinitions/require-tag-environment"
       }
     }
   }
   ```

2. **Update Terraform Backend**

   Edit `policies/<resource-type>/<environment>/provider.tf` to configure your Terraform state backend:

   ```hcl
   terraform {
     backend "azurerm" {
       resource_group_name  = "rg-tf-state-eus-dev-001"
       storage_account_name = "sttfstateeusdev001"
       container_name       = "tfstate"
       key                  = "policies-dev.tfstate"
     }
   }
   ```

## Deployment

### Azure DevOps Pipeline (Recommended)

The repository uses a template-based pipeline with Terraform Plan → Apply pattern:

**Pipeline Flow:**
```
Dev:  Plan_Policy_Dev → Apply_Policy_Dev
Test: Plan_Policy_Test → Approval_Test → Apply_Policy_Test (when configured)
Prod: Plan_Policy_Prod → Approval_Prod → Apply_Policy_Prod (when configured)
```

**Setup Steps:**

1. **Configure Service Connection** in Azure DevOps:
   - Name: `id-policy-vending-eus-dev-001` (for dev)
   - Type: Azure Resource Manager (Workload Identity Federation)
   - Managed Identity: User-assigned managed identity

2. **Assign Permissions** to the managed identity:
   ```bash
   # Policy Contributor at management group level
   az role assignment create \
     --assignee <managed-identity-principal-id> \
     --role "Policy Contributor" \
     --scope /providers/Microsoft.Management/managementGroups/<mg-name>
   ```

3. **Create Azure DevOps Environments**:
   - Pipelines → Environments → Create:
     - `Dev` (no approval)
     - `Test` (optional approval)
     - `Prod` (add approval checks)

4. **Create Pipelines** in Azure DevOps:
   - **Policy Definitions**: Path `/pipeline/deploy-policy-definitions.yaml`
   - **Policy Initiatives**: Path `/pipeline/deploy-policy-initiatives.yaml`
   - **Policy Assignments**: Path `/pipeline/deploy-policy-assignments.yaml`
   
   **Note:** Deploy in order: Definitions → Initiatives → Assignments

5. **Run Pipeline**: Push to `main` branch or manually trigger

### Manual Deployment (Local)

```bash
# For policy definitions
cd policies/policy-definitions/dev-plb-root

# For policy initiatives
cd policies/policy-initiatives/dev-plb-root

# For policy assignments
cd policies/policy-assignments/dev-plb-root

# Initialize Terraform
terraform init

# Review the plan
terraform plan

# Apply the configuration
terraform apply
```

## Module Structure

### Resource Modules

#### Policy Definition (`modules/resources/policy-definition/`)

Creates a single Azure Policy definition.

**Variables:**
- `name` - Policy definition name
- `display_name` - Display name
- `description` - Description
- `policy_type` - Policy type (BuiltIn, Custom, etc.)
- `mode` - Policy mode (All, Indexed, etc.)
- `policy_rule` - Policy rule JSON
- `parameters` - Policy parameters JSON
- `management_group_id` - Optional management group ID
- `tags` - Tags to apply

#### Policy Initiative (`modules/resources/policy-initiative/`)

Creates a policy set definition (initiative) that groups multiple policies.

**Variables:**
- `name` - Initiative name
- `display_name` - Display name
- `description` - Description
- `policy_definition_reference` - List of policy definitions to include
- `management_group_id` - Optional management group ID
- `tags` - Tags to apply

#### Policy Assignment (`modules/resources/policy-assignment/`)

Assigns a policy definition or initiative to a scope.

**Variables:**
- `name` - Assignment name
- `display_name` - Display name
- `scope` - Assignment scope (MG or subscription)
- `policy_definition_id` - Policy definition or initiative ID
- `location` - Location (for location-based policies)
- `identity_type` - Managed identity type
- `enforcement_mode` - Enforcement mode (Default, DoNotEnforce)
- `parameters` - Assignment parameters
- `tags` - Tags to apply

### Service Module (`modules/services/policies/`)

Orchestrates creation of policy definitions, initiatives, and assignments.

**Variables:**
- `environment` - Environment name
- `tags` - Base tags object
- `policy_definitions` - Map of policy definitions
- `policy_initiatives` - Map of policy initiatives
- `policy_assignments` - Map of policy assignments

## Policy Rule Format

Policy rules are JSON strings following Azure Policy schema:

```json
{
  "if": {
    "allOf": [
      {
        "field": "type",
        "equals": "Microsoft.Resources/subscriptions/resourceGroups"
      },
      {
        "field": "tags.environment",
        "exists": false
      }
    ]
  },
  "then": {
    "effect": "deny"
  }
}
```

## Configuration Files

### JSON Configuration Format

Each policy JSON file (e.g., `policy-vending.json`) contains policy configuration:

```json
{
  "environment": "dev",
  "version": "1.0.0",
  "tags": {
    "owner": "sunny.bharne",
    "application": "vending"
  },
  "policy_definitions": {
    "policy-key": {
      "name": "policy-name",
      "display_name": "Policy Display Name",
      "policy_rule": "{...}"
    }
  },
  "policy_initiatives": {
    "initiative-key": {
      "name": "initiative-name",
      "display_name": "Initiative Display Name",
      "policy_definition_reference": [...]
    }
  },
  "policy_assignments": {
    "assignment-key": {
      "name": "assignment-name",
      "display_name": "Assignment Display Name",
      "scope": "/providers/Microsoft.Management/managementGroups/...",
      "policy_definition_id": "..."
    }
  }
}
```

The `main.tf` in each resource type folder automatically reads all JSON files recursively from subdirectories and creates the respective policy resources (definitions, initiatives, or assignments) for each configuration.

**Deployment Order:**
1. Deploy **Policy Definitions** first
2. Deploy **Policy Initiatives** (depends on definitions)
3. Deploy **Policy Assignments** (depends on definitions and initiatives)

## Development Workflow

### Commit Messages

All commits must follow [Conventional Commits](https://www.conventionalcommits.org/) format:

```bash
# Good examples
git commit -m "feat: add new policy definition"
git commit -m "fix: update policy assignment scope"
git commit -m "docs: update README"

# Bad examples (rejected by git hooks)
git commit -m "updated stuff"
git commit -m "fix"
```

### Making Changes

1. Create a feature branch:
   ```bash
   git checkout -b feature/your-feature
   ```

2. Make changes to Terraform modules or configuration files

3. Test locally:
   ```bash
   cd policies
   terraform init
   terraform plan
   ```

4. Commit with conventional commit message (validated automatically)

5. Push and create pull request

## Security Considerations

- ✅ Use managed identities for service connections (no secrets in code)
- ✅ Service connections secured in Azure DevOps
- ✅ Least privilege role assignments (Policy Contributor)
- ✅ State files stored in secure Azure Storage backend
- ✅ Policy assignments at management group level for inheritance

## Troubleshooting

**Issue:** "Insufficient permissions to create policy"
- **Solution:** Verify managed identity has "Policy Contributor" role at management group level

**Issue:** "Policy definition not found"
- **Solution:** Ensure policy definitions are created before initiatives or assignments reference them

**Issue:** "Invalid policy rule JSON"
- **Solution:** Validate policy rule JSON syntax before deployment

**Issue:** "State locked" error
- **Solution:** Check for stuck locks, use `terraform force-unlock` if needed

## Learn More

- [Azure Policy Documentation](https://docs.microsoft.com/azure/governance/policy/)
- [Policy Definition Structure](https://docs.microsoft.com/azure/governance/policy/concepts/definition-structure)
- [Policy Initiatives](https://docs.microsoft.com/azure/governance/policy/concepts/initiative-definition-structure)
- [Cloud Adoption Framework](https://docs.microsoft.com/azure/cloud-adoption-framework/)
- [Terraform Azure Provider](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)
- [Conventional Commits](https://www.conventionalcommits.org/)

## License

ISC

