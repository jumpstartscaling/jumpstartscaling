#!/bin/bash

# ═══════════════════════════════════════════════════════════════════════════
# 🔱 GOD ARCHITECT HANDOFF SCRIPT
# ═══════════════════════════════════════════════════════════════════════════
# Ref: Forever Connection Implementation
# Updates local architecture files with enhancements

echo "🔱 Initiating Handoff Protocol..."

# 1. Move Forever Connection Module (with Cache Flush)
if [ -f "src/temp_forever.py" ]; then
    echo "   → Updating forever_connection.py..."
    mv src/temp_forever.py god_architect_local/forever_connection.py
    chmod +x god_architect_local/forever_connection.py
else
    echo "   ⚠ temp_forever.py not found (Skipping)"
fi

# 2. Move Bedrock SQL (with Phase 5 Relationship Awakening)
if [ -f "src/temp_bedrock.sql" ]; then
    echo "   → Updating awaken_bedrock.sql..."
    mv src/temp_bedrock.sql god_architect_local/awaken_bedrock.sql
else
    echo "   ⚠ temp_bedrock.sql not found (Skipping)"
fi

# 3. Patch Master Controller (Add Telemetry)
TARGET_MASTER="god_architect_local/god_architect_master.py"
if grep -q "check_god_mode_health" "$TARGET_MASTER"; then
    echo "   ✓ Master Controller already patched."
else
    echo "   → Patching Master Controller with Telemetry..."
    cat >> "$TARGET_MASTER" << 'EOF'

# ═══════════════════════════════════════════════════════════════════════════
# 🔱 GOD MODE TELEMETRY (Injected by Handoff)
# ═══════════════════════════════════════════════════════════════════════════

try:
    # Ensure forever_connection imports work even if app reload
    if 'forever_connection' not in sys.modules:
        import forever_connection
    from forever_connection import run_remote_sql, initiate_forever_connection
except ImportError:
    st.error("❌ forever_connection.py module missing!")

def check_god_mode_health():
    """Background worker to check for remote errors."""
    try:
        sql = "SELECT count(*) as count FROM work_log WHERE level = 'ERROR' AND timestamp > NOW() - INTERVAL '1 hour'"
        res = run_remote_sql(sql)
        
        if res.get('success') and res.get('rows') and res['rows'][0]['count'] > 0:
            count = res['rows'][0]['count']
            st.sidebar.error(f"🚨 {count} REMOTE ERRORS")
            with st.sidebar.expander("VIEW ERROR LOGS"):
                 logs = run_remote_sql("SELECT timestamp, action, details FROM work_log WHERE level='ERROR' ORDER BY timestamp DESC LIMIT 5")
                 if logs.get('rows'):
                     for l in logs['rows']:
                         st.code(f"[{l['timestamp']}] {l['action']}\n{l['details']}", language="text")
        else:
             st.sidebar.success("🟢 REMOTE SYSTEM HEALTHY")
    except Exception as e:
        # Fail silently to not brick UI
        pass

# Inject Telemetry Check
check_god_mode_health()

EOF
fi

echo "✨ Handoff Complete. Architecture Updated."
