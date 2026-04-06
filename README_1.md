# Terraform DMS PostgreSQL Migration

## AWS RDS PostgreSQL → Google Cloud SQL PostgreSQL

This project automates the infrastructure for migrating a PostgreSQL database from **AWS RDS** to **Google Cloud SQL** using **Google Cloud Database Migration Service (DMS)**.

---

## 🏗️ Architecture

```
┌─────────────────────────┐         ┌──────────────────────────────────────┐
│       AWS (ap-south-1)  │         │         GCP (asia-south1)            │
│                         │         │                                      │
│  ┌───────────────────┐  │         │  ┌────────────────────────────────┐  │
│  │  VPC 10.10.0.0/16 │  │         │  │    VPC 10.20.0.0/24           │  │
│  │                   │  │         │  │                                │  │
│  │  ┌─────────────┐  │  │  DMS    │  │  ┌──────────────────────────┐ │  │
│  │  │ RDS         │  │  │ ──────► │  │  │ Cloud SQL PostgreSQL     │ │  │
│  │  │ PostgreSQL  │  │  │         │  │  │ (Private IP)             │ │  │
│  │  │ (Public)    │  │  │         │  │  └──────────────────────────┘ │  │
│  │  │             │  │  │         │  │                                │  │
│  │  │ Logical Rep.│  │  │         │  │  ┌──────────────────────────┐ │  │
│  │  │ Enabled     │  │  │         │  │  │ GCS Bucket (Dump Files)  │ │  │
│  │  └─────────────┘  │  │         │  │  └──────────────────────────┘ │  │
│  └───────────────────┘  │         │  └────────────────────────────────┘  │
└─────────────────────────┘         │                                      │
                                    │  ┌────────────────────────────────┐  │
                                    │  │ Secret Manager                 │  │
                                    │  │ • Cloud SQL password           │  │
                                    │  │ • RDS password                 │  │
                                    │  │ • DMS replication password     │  │
                                    │  └────────────────────────────────┘  │
                                    └──────────────────────────────────────┘
```

---

## 📁 Project Structure

```
terraform-dms-migration/
├── providers.tf                    # Provider version constraints
├── variables.tf                    # Root variable definitions
├── README.md                       # This file
│
├── modules/
│   ├── aws-network/                # AWS VPC, subnets, IGW, security groups
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   │
│   ├── aws-rds/                    # RDS PostgreSQL with logical replication
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   │
│   ├── gcp-network/                # GCP VPC, subnet, private service networking
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   │
│   ├── cloudsql-new/               # New Cloud SQL PostgreSQL instance
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   │
│   ├── cloudsql-existing/          # Reference existing Cloud SQL instance
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   │
│   ├── secrets/                    # Google Secret Manager
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   │
│   └── dms/                        # DMS connection profiles & migration job
│       ├── main.tf
│       ├── variables.tf
│       └── outputs.tf
│
└── environments/
    └── mumbai/                     # Mumbai region configuration
        ├── main.tf                 # Module wiring & outputs
        ├── variables.tf            # Variable declarations
        └── terraform.tfvars        # Environment values
```

---

## 🔐 Authentication

This project uses CLI-based authentication. **No credentials are hardcoded.**

### AWS
```bash
aws configure
# Enter your Access Key ID, Secret Access Key, and region (ap-south-1)
```

### GCP
```bash
gcloud auth login
gcloud auth application-default login
gcloud config set project YOUR_PROJECT_ID
```

### Required GCP APIs
Enable the following APIs in your GCP project:
```bash
gcloud services enable sqladmin.googleapis.com
gcloud services enable servicenetworking.googleapis.com
gcloud services enable secretmanager.googleapis.com
gcloud services enable datamigration.googleapis.com
gcloud services enable storage.googleapis.com
gcloud services enable compute.googleapis.com
```

---

## ⚙️ Configuration

### 1. Update `terraform.tfvars`

Edit `environments/mumbai/terraform.tfvars`:

```hcl
# REQUIRED: Set your GCP project ID
gcp_project_id = "your-actual-project-id"

# REQUIRED: Change passwords to strong values
rds_password               = "YourStrongRDSPassword!"
dms_replication_password   = "YourStrongDMSPassword!"
cloudsql_password           = "YourStrongCloudSQLPassword!"
```

### 2. Using an Existing Cloud SQL Instance

To migrate to an existing Cloud SQL instance:
```hcl
use_existing_cloudsql          = true
existing_cloudsql_instance_name = "my-existing-instance"
```

---

## 🚀 Deployment

### Step 1: Initialize Terraform
```bash
cd environments/mumbai
terraform init
```

### Step 2: Review the Plan
```bash
terraform plan
```

### Step 3: Apply Infrastructure
```bash
terraform apply
```

### Step 4: Create Replication User on RDS

After the RDS instance is created, connect to it and create the DMS replication user:

```bash
# Connect to RDS
psql -h <rds_endpoint> -U postgres -d appdb

# Create replication user
CREATE USER dmsuser WITH PASSWORD 'ChangeMe_DMS_2024!' REPLICATION;

# Grant required privileges
GRANT ALL PRIVILEGES ON DATABASE appdb TO dmsuser;
GRANT USAGE ON SCHEMA public TO dmsuser;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO dmsuser;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO dmsuser;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON TABLES TO dmsuser;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON SEQUENCES TO dmsuser;
```

> **Note:** After creating the parameter group with `rds.logical_replication = 1`,
> you may need to **reboot the RDS instance** for the changes to take effect:
> ```bash
> aws rds reboot-db-instance --db-instance-identifier dms-pg-migration-rds-pg --region ap-south-1
> ```

### Step 5: Start the Migration Job

```bash
gcloud database-migration migration-jobs start \
  dms-pg-migration-rds-to-cloudsql \
  --region=asia-south1
```

### Step 6: Monitor Migration

```bash
# Check migration job status
gcloud database-migration migration-jobs describe \
  dms-pg-migration-rds-to-cloudsql \
  --region=asia-south1

# List all migration jobs
gcloud database-migration migration-jobs list \
  --region=asia-south1
```

---

## 📤 Outputs

After successful deployment, Terraform will output:

| Output | Description |
|--------|-------------|
| `rds_endpoint` | AWS RDS PostgreSQL endpoint |
| `rds_hostname` | RDS hostname (without port) |
| `cloudsql_instance_name` | Cloud SQL instance name |
| `cloudsql_private_ip` | Cloud SQL private IP address |
| `migration_job_id` | DMS migration job identifier |
| `gcs_bucket_name` | GCS bucket for dump files |
| `secret_cloudsql_password_id` | Secret Manager ID for Cloud SQL password |
| `secret_rds_password_id` | Secret Manager ID for RDS password |

---

## 🔑 Key Configuration Details

### Logical Replication (RDS)

DMS requires PostgreSQL logical replication. The custom parameter group sets:

| Parameter | Value | Purpose |
|-----------|-------|---------|
| `rds.logical_replication` | `1` | Enables logical replication on RDS |
| `wal_level` | `logical` | Sets WAL level for logical decoding |
| `max_replication_slots` | `5` | Allows DMS replication slots |
| `max_wal_senders` | `10` | Allows concurrent WAL sender processes |

> ⚠️ These parameters require a **reboot** of the RDS instance to take effect.

### Migration Type

The migration job is configured as **CONTINUOUS**, which means:
1. **Initial full dump** of the source database to GCS
2. **Ongoing CDC (Change Data Capture)** using logical replication
3. Changes are continuously replicated until you **promote** the destination

### Promoting the Destination

When ready to cut over:
```bash
gcloud database-migration migration-jobs promote \
  dms-pg-migration-rds-to-cloudsql \
  --region=asia-south1
```

---

## ⚠️ Security Notes

1. **RDS Public Access**: The RDS instance is publicly accessible for demo purposes. In production, use **AWS Direct Connect** or **VPN** for private connectivity.

2. **Security Group**: The PostgreSQL security group allows `0.0.0.0/0` on port 5432. In production, restrict to specific IP ranges.

3. **Passwords**: The `terraform.tfvars` file contains placeholder passwords. **Always use strong, unique passwords** and consider using environment variables (`TF_VAR_*`) instead.

4. **Secret Manager**: All passwords are stored in Google Secret Manager for secure access by GCP services.

5. **State File**: The Terraform state contains sensitive data. Use a **remote backend** (GCS, S3) with encryption in production.

---

## 🧹 Cleanup

To destroy all infrastructure:

```bash
# First, stop the migration job if running
gcloud database-migration migration-jobs stop \
  dms-pg-migration-rds-to-cloudsql \
  --region=asia-south1

# Then destroy Terraform resources
cd environments/mumbai
terraform destroy
```

---

## 💰 Cost Considerations

| Resource | Estimated Cost |
|----------|---------------|
| RDS `db.t3.micro` | ~$12/month (ap-south-1) |
| Cloud SQL `db-f1-micro` | ~$7/month (asia-south1) |
| GCS bucket | ~$0.02/GB/month |
| DMS migration job | Free (pay for compute) |
| Secret Manager | ~$0.06/secret/month |
| **Total (demo)** | **~$20/month** |

> 💡 **Tip**: Destroy resources when not in use to minimize costs.

---

## 📋 Prerequisites Checklist

- [ ] AWS CLI configured (`aws configure`)
- [ ] GCP CLI configured (`gcloud auth application-default login`)
- [ ] GCP project ID set in `terraform.tfvars`
- [ ] Required GCP APIs enabled
- [ ] Terraform >= 1.5.0 installed
- [ ] Strong passwords set for RDS, Cloud SQL, and DMS user
- [ ] Updated `gcp_project_id` in `terraform.tfvars`
