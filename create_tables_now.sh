#!/bin/bash

# Quick Fix: Create Database Tables Manually
# This will make the site work immediately while you redeploy with updated code

set -e

echo "🗄️ Creating Payload CMS Database Tables"
echo "========================================"
echo ""

ssh -i ~/.ssh/id_rsa opc@193.122.168.215 << 'ENDSSH'

echo "📊 Connecting to PostgreSQL..."

docker exec -i ok4gk4kc4kk0w4wgsksskswg psql -U postgres << 'EOSQL'

-- Create users table
CREATE TABLE IF NOT EXISTS users (
  id SERIAL PRIMARY KEY,
  name VARCHAR(255),
  tenant_id INTEGER,
  updated_at TIMESTAMP DEFAULT NOW(),
  created_at TIMESTAMP DEFAULT NOW(),
  email VARCHAR(255) UNIQUE NOT NULL,
  reset_password_token VARCHAR(255),
  reset_password_expiration TIMESTAMP,
  salt VARCHAR(255),
  hash VARCHAR(255),
  login_attempts INTEGER DEFAULT 0,
  lock_until TIMESTAMP
);

-- Create users_roles table
CREATE TABLE IF NOT EXISTS users_roles (
  id SERIAL PRIMARY KEY,
  parent_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
  value VARCHAR(50),
  "order" INTEGER
);

-- Create users_sessions table
CREATE TABLE IF NOT EXISTS users_sessions (
  id SERIAL PRIMARY KEY,
  _parent_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
  _order INTEGER,
  created_at TIMESTAMP DEFAULT NOW(),
  expires_at TIMESTAMP
);

-- Create tenants table
CREATE TABLE IF NOT EXISTS tenants (
  id SERIAL PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  slug VARCHAR(255) UNIQUE NOT NULL,
  updated_at TIMESTAMP DEFAULT NOW(),
  created_at TIMESTAMP DEFAULT NOW()
);

-- Create pages table
CREATE TABLE IF NOT EXISTS pages (
  id SERIAL PRIMARY KEY,
  title VARCHAR(255),
  slug VARCHAR(255),
  tenant_id INTEGER REFERENCES tenants(id),
  content JSONB,
  updated_at TIMESTAMP DEFAULT NOW(),
  created_at TIMESTAMP DEFAULT NOW(),
  published BOOLEAN DEFAULT false
);

-- Create media table
CREATE TABLE IF NOT EXISTS media (
  id SERIAL PRIMARY KEY,
  filename VARCHAR(255),
  mime_type VARCHAR(100),
  filesize INTEGER,
  width INTEGER,
  height INTEGER,
  url VARCHAR(500),
  updated_at TIMESTAMP DEFAULT NOW(),
  created_at TIMESTAMP DEFAULT NOW()
);

-- Create payload_preferences table
CREATE TABLE IF NOT EXISTS payload_preferences (
  id SERIAL PRIMARY KEY,
  key VARCHAR(255),
  value JSONB,
  updated_at TIMESTAMP DEFAULT NOW(),
  created_at TIMESTAMP DEFAULT NOW()
);

-- Create payload_migrations table
CREATE TABLE IF NOT EXISTS payload_migrations (
  id SERIAL PRIMARY KEY,
  name VARCHAR(255),
  batch INTEGER,
  updated_at TIMESTAMP DEFAULT NOW(),
  created_at TIMESTAMP DEFAULT NOW()
);

-- Create indexes
CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);
CREATE INDEX IF NOT EXISTS idx_tenants_slug ON tenants(slug);
CREATE INDEX IF NOT EXISTS idx_pages_slug ON pages(slug);
CREATE INDEX IF NOT EXISTS idx_pages_tenant ON pages(tenant_id);

-- List all tables
\dt

EOSQL

echo ""
echo "✅ Database tables created successfully!"
echo ""
echo "🔄 Restarting Payload CMS container..."

# Find and restart container
CONTAINER_ID=$(docker ps --filter "name=ksgwgg0kg08o000s80wcgkks" --format "{{.ID}}")
docker restart $CONTAINER_ID

echo "✅ Container restarted!"
echo ""
echo "⏱️  Waiting 10 seconds for application to start..."
sleep 10

echo ""
echo "✅ Done!"
echo ""
echo "🎉 Your Payload CMS should now be accessible at:"
echo "   https://cms.jumpstartscaling.com"
echo ""
echo "📋 Next Steps:"
echo "   1. Visit https://cms.jumpstartscaling.com"
echo "   2. Complete the Payload CMS setup wizard"
echo "   3. Create your first admin user"
echo "   4. Create your first tenant"
echo ""

ENDSSH

echo "🚀 All done! Visit https://cms.jumpstartscaling.com now!"
