#!/bin/bash
# Automated Coolify Deployment for Payload CMS via Database

set -e

SERVER="opc@193.122.168.215"
APP_PATH="/home/opc/payload-multitenant"
PAYLOAD_SECRET=$(openssl rand -base64 32)

echo "🚀 Automated Payload CMS Deployment to Coolify"
echo "==============================================="
echo ""

echo "Step 1: Creating PostgreSQL Database..."
# Create PostgreSQL database in Coolify via SQL
ssh -i ~/.ssh/id_rsa $SERVER << EOFDB
# Create a PostgreSQL database resource in Coolify
docker exec coolify-db psql -U coolify -d coolify << 'EOFSQL'
-- Insert PostgreSQL database
INSERT INTO standalone_postgresqls (
  uuid,
  name,
  postgres_password,
  postgres_user,
  postgres_db,
  postgres_initdb_args,
  postgres_host_auth_method,
  postgres_conf,
  image,
  created_at,
  updated_at
) VALUES (
  'payload-cms-db-' || substr(md5(random()::text), 1, 16),
  'jumpstart-cms-db',
  encode(gen_random_bytes(16), 'hex'),
  'payload_user',
  'payload',
  '',
  'scram-sha-256',
  '',
  'postgres:16-alpine',
  NOW(),
  NOW()
)
RETURNING id, uuid, postgres_password;
EOFSQL
EOFDB

echo "✅ Database creation command sent"
echo ""

echo "Step 2: Get Database Details..."
DB_INFO=$(ssh -i ~/.ssh/id_rsa $SERVER "docker exec coolify-db psql -U coolify -d coolify -t -c \"SELECT id, uuid, postgres_password FROM standalone_postgresqls WHERE name='jumpstart-cms-db' ORDER BY created_at DESC LIMIT 1;\"")
echo "Database Info: $DB_INFO"
echo ""

# Parse database info
DB_ID=$(echo "$DB_INFO" | awk '{print $1}' | tr -d ' ')
DB_UUID=$(echo "$DB_INFO" | awk '{print $3}' | tr -d ' ')
DB_PASSWORD=$(echo "$DB_INFO" | awk '{print $5}' | tr -d ' ')

echo "Database ID: $DB_ID"
echo "Database UUID: $DB_UUID"
echo "Database Password: $DB_PASSWORD"
echo ""

# Construct connection string
DATABASE_URI="postgres://payload_user:${DB_PASSWORD}@${DB_UUID}:5432/payload"
echo "Connection String: $DATABASE_URI"
echo ""

echo "Step 3: Creating Coolify Application..."

# Create application in Coolify
ssh -i ~/.ssh/id_rsa $SERVER << EOFAPP
docker exec coolify-db psql -U coolify -d coolify << EOFSQL2
-- Insert Application
INSERT INTO applications (
  uuid,
  name,
  repository_project_id,
  git_repository,
  git_branch,
  build_pack,
  install_command,
  build_command,
  start_command,
  ports_exposes,
  ports_mappings,
  base_directory,
  publish_directory,
  health_check_enabled,
  health_check_path,
  health_check_port,
  health_check_host,
  health_check_method,
  health_check_return_code,
  health_check_scheme,
  health_check_response_text,
  health_check_interval,
  health_check_timeout,
  health_check_retries,
  health_check_start_period,
  limits_memory,
  limits_memory_swap,
  limits_memory_swappiness,
  limits_memory_reservation,
  limits_cpus,
  limits_cpuset,
  limits_cpu_shares,
  settings,
  dockerfile_location,
  docker_compose_location,
  docker_compose_raw,
  docker_compose_custom_start_command,
  docker_compose_custom_build_command,
  manual_webhook_secret_github,
  manual_webhook_secret_gitlab,
  manual_webhook_secret_bitbucket,
  manual_webhook_secret_gitea,
  redirect,
  instant_deploy,
  dockerfile,
  docker_compose,
  build_pack,
  static_image,
  custom_labels,
  custom_docker_run_options,
  post_deployment_command,
  post_deployment_command_container,
  pre_deployment_command,
  pre_deployment_command_container,
  watch_paths,
  manual_build,
  custom_healthcheck_found,
  health_check_return_code,
  health_check_return_text,
  docker_registry_image_name,
  docker_registry_image_tag,
  is_bot,
  is_dual_cert,
  is_custom_ssl,
  is_force_https_enabled,
  is_gzip_enabled,
  is_stripprefix_enabled,
  is_raw_compose_deployment_enabled,
  is_build_server_enabled,
  is_consistent_container_name_enabled,
  is_container_label_escape_needed,
  is_container_label_readonly_enabled,
  is_preview_deployments_enabled,
  created_at,
  updated_at
) VALUES (
  'payload-cms-app-' || substr(md5(random()::text), 1, 16),
  'payload-cms',
  NULL,
  'file://${APP_PATH}',
  'main',
  'dockerfile',
  'npm install --legacy-peer-deps',
  'npm run build',
  'npm run start',
  '3000',
  '',
  '',
  '',
  true,
  '/',
  3000,
  'localhost',
  'GET',
  200,
  'http',
  '',
  5,
  5,
  3,
  30,
  '',
  '',
  60,
  '',
  '',
  '',
  1024,
  '{}',
  './Dockerfile',
  '',
  '',
  '',
  '',
  '',
  '',
  '',
  '',
  'redirect',
  false,
  '',
  '',
  'dockerfile',
  '',
  '',
  '',
  '',
  '',
  '',
  '',
  '',
  false,
  false,
  200,
  '',
  '',
  '',
  false,
  false,
  false,
  true,
  false,
  false,
  false,
  false,
  false,
  false,
  false,
  false,
  NOW(),
  NOW()
)
RETURNING id, uuid;
EOFSQL2
EOFAPP

echo "✅ Application creation command sent"
echo ""

echo "Step 4: Getting Application Details..."
APP_INFO=$(ssh -i ~/.ssh/id_rsa $SERVER "docker exec coolify-db psql -U coolify -d coolify -t -c \"SELECT id, uuid FROM applications WHERE name='payload-cms' ORDER BY created_at DESC LIMIT 1;\"")
APP_ID=$(echo "$APP_INFO" | awk '{print $1}' | tr -d ' ')
APP_UUID=$(echo "$APP_INFO" | awk '{print $3}' | tr -d ' ')

echo "Application ID: $APP_ID"
echo "Application UUID: $APP_UUID"
echo ""

echo "Step 5: Adding Environment Variables..."
ssh -i ~/.ssh/id_rsa $SERVER << EOFENV
docker exec coolify-db psql -U coolify -d coolify << EOFSQL3
-- Insert environment variables  
INSERT INTO environment_variables (key, value, is_build_time, is_preview, application_id, created_at, updated_at)
VALUES
  ('DATABASE_URI', '${DATABASE_URI}', false, false, ${APP_ID}, NOW(), NOW()),
  ('PAYLOAD_SECRET', '${PAYLOAD_SECRET}', false, false, ${APP_ID}, NOW(), NOW()),
  ('PAYLOAD_CONFIG_PATH', 'src/payload.config.ts', false, false, ${APP_ID}, NOW(), NOW()),
  ('NEXT_PUBLIC_SERVER_URL', 'https://cms.jumpstartscaling.com', false, false, ${APP_ID}, NOW(), NOW()),
  ('PORT', '3000', false, false, ${APP_ID}, NOW(), NOW()),
  ('NODE_ENV', 'production', false, false, ${APP_ID}, NOW(), NOW());
EOFSQL3
EOFENV

echo "✅ Environment variables added"
echo ""

echo "Step 6: Setting Domain..."
# This would need to be done via Coolify UI or API
echo "MANUAL STEP REQUIRED:"
echo "1. Go to http://193.122.168.215:8000"
echo "2. Find the 'payload-cms' application"
echo "3. Go to 'Domains' tab"
echo "4. Add domain: cms.jumpstartscaling.com"
echo "5. Enable SSL/TLS"
echo "6. Click 'Deploy'"
echo ""

echo "✅ SETUP COMPLETE!"
echo ""
echo "📊 Summary:"
echo "  Database: jumpstart-cms-db"
echo "  Database User: payload_user"  
echo "  Database Password: $DB_PASSWORD"
echo "  Connection String: $DATABASE_URI"
echo "  Application: payload-cms"
echo "  Payload Secret: $PAYLOAD_SECRET"
echo ""
echo "🌐 Next: Configure domain in Coolify UI and deploy"
echo ""
