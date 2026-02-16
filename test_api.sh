#!/bin/bash

# God Mode API Verification Script
# This script tests all God Mode API endpoints on the deployed Coolify instance

BASE_URL="https://spark.jumpstartscaling.com"
TOKEN="jmQXoeyxWoBsB7eHzG7FmnH90f22JtaYBxXHoorhfZ-v4tT3VNEr9vvmwHqYHCDoWXHSU4DeZXApCP-Gha-YdA"

echo "🔱 God Mode API Verification"
echo "============================="
echo "Base URL: $BASE_URL"
echo ""

# Test counter
PASSED=0
FAILED=0

# Function to test an endpoint
test_endpoint() {
    local name="$1"
    local method="$2"
    local endpoint="$3"
    local data="$4"
    
    echo -n "Testing $name... "
    
    if [ "$method" = "GET" ]; then
        response=$(curl -s -w "\n%{http_code}" -H "X-God-Token: $TOKEN" "$BASE_URL$endpoint")
    else
        response=$(curl -s -w "\n%{http_code}" -X POST -H "X-God-Token: $TOKEN" -H "Content-Type: application/json" -d "$data" "$BASE_URL$endpoint")
    fi
    
    http_code=$(echo "$response" | tail -n 1)
    body=$(echo "$response" | sed '$d')
    
    if [ "$http_code" = "200" ] || [ "$http_code" = "201" ]; then
        echo "✅ PASSED (HTTP $http_code)"
        PASSED=$((PASSED + 1))
        if [ ! -z "$body" ]; then
            echo "   Response: $(echo $body | jq -c '.' 2>/dev/null || echo $body | head -c 100)"
        fi
    else
        echo "❌ FAILED (HTTP $http_code)"
        FAILED=$((FAILED + 1))
        echo "   Error: $body"
    fi
    echo ""
}

echo "📊 Testing Core Endpoints"
echo "=========================="

# 1. Health Check
test_endpoint "Health Check" "GET" "/api/god/health"

# 2. Services Status
test_endpoint "Services Status" "GET" "/api/god/services"

# 3. Database Status
test_endpoint "Database Status" "GET" "/api/god/db-status"

# 4. Database Pool Stats
test_endpoint "DB Pool Stats" "GET" "/api/god/pool-stats"

# 5. List Tables
test_endpoint "List Tables" "GET" "/api/god/tables"

# 6. Table Relationships
test_endpoint "Table Relationships" "GET" "/api/god/relationships"

echo ""
echo "🗄️ Testing SQL & Database Endpoints"
echo "====================================="

# 7. Execute SQL - Simple SELECT
test_endpoint "SQL Query (SELECT)" "POST" "/api/god/sql" '{"query": "SELECT COUNT(*) as count FROM sites"}'

# 8. Table Schema
test_endpoint "Get Table Schema" "GET" "/api/god/table-schema?table=sites"

# 9. Work Logs
test_endpoint "Work Logs" "GET" "/api/god/logs?limit=5"

echo ""
echo "📦 Testing Directus Collection Endpoints"
echo "=========================================="

# 10. Get Sites Collection
test_endpoint "Get Sites" "GET" "/api/collections/sites?limit=5"

# 11. Get Posts Collection
test_endpoint "Get Posts" "GET" "/api/collections/posts?limit=5"

# 12. Get Campaigns
test_endpoint "Get Campaigns" "GET" "/api/collections/campaigns?limit=5"

echo ""
echo "🎯 Testing Campaign Management"
echo "==============================="

# 13. Get Campaigns via God API
test_endpoint "Get Campaigns (God API)" "GET" "/api/god/campaigns"

echo ""
echo "🐍 Testing Python Bridge"
echo "========================="

# 14. Python Bridge Health
test_endpoint "Python Bridge Health" "GET" "/api/python/health"

echo ""
echo "📈 Summary"
echo "=========="
echo "✅ Passed: $PASSED"
echo "❌ Failed: $FAILED"
echo "Total Tests: $((PASSED + FAILED))"
echo ""

if [ $FAILED -eq 0 ]; then
    echo "🎉 All tests passed! God Mode is fully operational."
    exit 0
else
    echo "⚠️  Some tests failed. Check the output above for details."
    exit 1
fi
