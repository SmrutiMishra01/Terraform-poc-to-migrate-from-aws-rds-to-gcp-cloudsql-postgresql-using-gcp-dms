# =============================================================================
# AWS RDS PostgreSQL Module - Main
# =============================================================================
# Creates an RDS PostgreSQL instance configured for DMS migration:
#   - Custom parameter group with logical replication enabled
#   - Publicly accessible for DMS connectivity (demo only)
#   - Skip final snapshot for easy teardown
#
# CRITICAL: Logical replication must be enabled for DMS to work.
# The custom parameter group sets:
#   - rds.logical_replication = 1
#   - wal_level = logical (implied by rds.logical_replication)
#   - max_replication_slots = 5
#   - max_wal_senders = 10
#
# POST-DEPLOYMENT: You must create a replication user manually:
#   psql -h <rds_endpoint> -U postgres -d appdb
#   CREATE USER dmsuser WITH PASSWORD '<password>' REPLICATION;
#   GRANT ALL PRIVILEGES ON DATABASE appdb TO dmsuser;
#   GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO dmsuser;
#   ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON TABLES TO dmsuser;
# =============================================================================

# -----------------------------------------------------------------------------
# Custom Parameter Group for Logical Replication
# -----------------------------------------------------------------------------
resource "aws_db_parameter_group" "postgres_dms" {
  name        = "${var.project_name}-pg-dms-params"
  family      = "postgres${var.engine_version}"
  description = "PostgreSQL parameters for DMS logical replication"

  # Enable logical replication (required by DMS)
  parameter {
    name         = "rds.logical_replication"
    value        = "1"
    apply_method = "pending-reboot"
  }

  # Set max replication slots for DMS
  parameter {
    name         = "max_replication_slots"
    value        = "5"
    apply_method = "pending-reboot"
  }

  # Set max WAL senders for replication connections
  parameter {
    name         = "max_wal_senders"
    value        = "10"
    apply_method = "pending-reboot"
  }

  # Ensure WAL level supports logical decoding
  parameter {
    name         = "wal_level"
    value        = "logical"
    apply_method = "pending-reboot"
  }

  tags = {
    Name    = "${var.project_name}-pg-dms-params"
    Project = var.project_name
  }
}

# -----------------------------------------------------------------------------
# RDS PostgreSQL Instance
# -----------------------------------------------------------------------------
resource "aws_db_instance" "postgres" {
  identifier     = "${var.project_name}-rds-pg"
  engine         = "postgres"
  engine_version = var.engine_version

  # Instance sizing (minimal for demo)
  instance_class    = var.instance_class
  allocated_storage = var.allocated_storage
  storage_type      = "gp3"

  # Database configuration
  db_name  = var.db_name
  username = var.username
  password = var.password

  # Attach the custom parameter group with logical replication
  parameter_group_name = aws_db_parameter_group.postgres_dms.name

  # Networking
  db_subnet_group_name   = var.db_subnet_group_name
  vpc_security_group_ids = [var.security_group_id]

  # ⚠️ DEMO ONLY: Make publicly accessible for DMS connectivity
  # In production, use VPN or Direct Connect
  publicly_accessible = true

  # Backup configuration
  backup_retention_period = 7
  backup_window           = "03:00-04:00"
  maintenance_window      = "Mon:04:00-Mon:05:00"

  # Demo settings - skip snapshot on destroy for easy cleanup
  skip_final_snapshot       = true
  final_snapshot_identifier = null
  deletion_protection       = var.deletion_protection
  multi_az                  = var.enable_high_availability

  # Enable performance insights (free tier)
  performance_insights_enabled = true

  tags = {
    Name    = "${var.project_name}-rds-pg"
    Project = var.project_name
  }
}
