from fastapi import FastAPI, Request, HTTPException, Depends
from pydantic import BaseModel
from typing import Optional, Dict, Any
import psycopg2
from psycopg2.extras import RealDictCursor
import json
import os
import time
from datetime import datetime

app = FastAPI(title="God Mode API", version="1.0.0")

# Database Configuration
DB_HOST = "localhost"
DB_NAME = "god_mode"
DB_USER = "god_user"
DB_PASS = "JumpStart2026!"

def get_db_connection():
    try:
        conn = psycopg2.connect(
            host=DB_HOST,
            database=DB_NAME,
            user=DB_USER,
            password=DB_PASS
        )
        return conn
    except Exception as e:
        print(f"Database connection failed: {e}")
        raise HTTPException(status_code=500, detail="Database connection failed")

# Models
class Lead(BaseModel):
    source: str
    data: Dict[str, Any]

# Middleware for Logging
@app.middleware("http")
async def log_requests(request: Request, call_next):
    start_time = time.time()
    
    # Read body for logging (careful with large bodies)
    body_bytes = await request.body()
    try:
        payload = json.loads(body_bytes) if body_bytes else {}
    except:
        payload = {"raw": body_bytes.decode('utf-8', errors='ignore')}
        
    # Re-inject body for route handlers
    async def receive():
        return {"type": "http.request", "body": body_bytes}
    request._receive = receive
    
    response = await call_next(request)
    
    # Log to DB
    try:
        conn = get_db_connection()
        cur = conn.cursor()
        cur.execute(
            "INSERT INTO api_logs (endpoint, method, status, payload, response, created_at) VALUES (%s, %s, %s, %s, %s, NOW())",
            (request.url.path, request.method, response.status_code, json.dumps(payload), "{}",) 
        )
        conn.commit()
        cur.close()
        conn.close()
    except Exception as e:
        print(f"Logging failed: {e}")

    return response

@app.get("/")
def health_check():
    return {"status": "active", "service": "God Mode API"}

@app.post("/submit-lead")
def submit_lead(lead: Lead):
    try:
        conn = get_db_connection()
        cur = conn.cursor()
        
        cur.execute(
            "INSERT INTO leads (source, data, created_at) VALUES (%s, %s, NOW()) RETURNING id",
            (lead.source, json.dumps(lead.data))
        )
        new_id = cur.fetchone()[0]
        conn.commit()
        
        cur.close()
        conn.close()
        return {"success": True, "lead_id": new_id, "message": "Lead captured successfully"}
    except Exception as e:
        print(f"Error submitting lead: {e}")
        raise HTTPException(status_code=500, detail=str(e))

@app.get("/leads")
def get_leads(limit: int = 50, offset: int = 0):
    try:
        conn = get_db_connection()
        cur = conn.cursor(cursor_factory=RealDictCursor)
        
        cur.execute("SELECT * FROM leads ORDER BY created_at DESC LIMIT %s OFFSET %s", (limit, offset))
        leads = cur.fetchall()
        
        cur.close()
        conn.close()
        return {"success": True, "leads": leads}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
