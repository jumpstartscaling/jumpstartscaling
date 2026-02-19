
import sqlite3
import json
import time

conn = sqlite3.connect('stream-rec.db')
c = conn.cursor()

# Check if user already exists to avoid duplicates
c.execute("SELECT id FROM streamer WHERE name='liulele66'")
if c.fetchone():
    print("User already exists")
else:
    # Insert new streamer
    # platform 2 assumed for TikTok
    # download_config: source valid config from existing Douyin one but change type
    download_config = json.dumps({"type": "tiktok", "quality": "origin"})
    engine_config = json.dumps({"type": "ffmpeg"})
    
    # Get current timestamp
    now = int(time.time())
    
    c.execute("""
        INSERT INTO streamer 
        (name, url, platform, last_stream, state, description, is_template, template_id, app_config_id, engine, engine_config, download_config)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
    """, (
        'liulele66',
        'https://www.tiktok.com/@liulele66/live',
        2,  # Platform ID for TikTok (assumed)
        0,  # last_stream
        0,  # state (idle)
        'Added via script',
        0,  # is_template
        0,  # template_id
        1,  # app_config_id
        'ffmpeg',
        engine_config,
        download_config
    ))
    
    print("Inserted liulele66")
    conn.commit()

conn.close()
