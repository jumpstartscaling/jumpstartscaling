"""
TikTok Recordings Video Gallery
Flask backend with video streaming, delete (to trash), and conversion support
"""
import os
import re
import shutil
import subprocess
from datetime import datetime
from pathlib import Path
from flask import Flask, render_template, jsonify, request, send_file, abort, Response

app = Flask(__name__)

# Configuration
VIDEOS_DIR = os.environ.get('VIDEOS_DIR', '/opt/records')
TRASH_DIR = os.path.join(VIDEOS_DIR, '.trash')
ALLOWED_EXTENSIONS = {'.mp4', '.ts', '.flv', '.mkv', '.webm'}

# Ensure trash directory exists
os.makedirs(TRASH_DIR, exist_ok=True)


def parse_filename(filename):
    """Extract streamer name and timestamp from filename"""
    # Pattern: tiktok-USERNAME-TIMESTAMP.ext or other formats
    match = re.match(r'tiktok-([^-]+)-(\d{4}-\d{2}-\d{2}T[\d-]+)', filename)
    if match:
        return {
            'streamer': match.group(1),
            'timestamp': match.group(2).replace('T', ' ').replace('-', ':')[11:],
            'date': match.group(2)[:10]
        }
    # Fallback for other naming patterns
    return {
        'streamer': 'other',
        'timestamp': '',
        'date': ''
    }


def get_video_info(filepath):
    """Get video file information"""
    stat = os.stat(filepath)
    filename = os.path.basename(filepath)
    ext = os.path.splitext(filename)[1].lower()
    parsed = parse_filename(filename)
    
    # Check if MP4 version exists (for TS files)
    mp4_exists = False
    if ext == '.ts':
        mp4_path = filepath.replace('.ts', '.mp4')
        mp4_exists = os.path.exists(mp4_path)
    
    return {
        'filename': filename,
        'path': filepath,
        'size': stat.st_size,
        'size_mb': round(stat.st_size / (1024 * 1024), 1),
        'modified': datetime.fromtimestamp(stat.st_mtime).isoformat(),
        'extension': ext,
        'streamer': parsed['streamer'],
        'date': parsed['date'],
        'timestamp': parsed['timestamp'],
        'playable': ext == '.mp4',
        'needs_conversion': ext == '.ts' and not mp4_exists,
        'has_mp4': mp4_exists
    }


def get_all_videos():
    """Get all videos grouped by streamer"""
    videos = []
    
    for filename in os.listdir(VIDEOS_DIR):
        filepath = os.path.join(VIDEOS_DIR, filename)
        if not os.path.isfile(filepath):
            continue
        
        ext = os.path.splitext(filename)[1].lower()
        if ext not in ALLOWED_EXTENSIONS:
            continue
        
        video_info = get_video_info(filepath)
        
        # Skip TS files that have MP4 versions
        if video_info['has_mp4']:
            continue
            
        videos.append(video_info)
    
    # Sort by date descending
    videos.sort(key=lambda x: x['modified'], reverse=True)
    
    # Group by streamer
    streamers = {}
    for video in videos:
        streamer = video['streamer']
        if streamer not in streamers:
            streamers[streamer] = []
        streamers[streamer].append(video)
    
    return streamers


@app.route('/')
def index():
    """Main gallery page"""
    return render_template('index.html')


@app.route('/downloader')
def downloader():
    """TikTok profile downloader page"""
    return render_template('downloader.html')


# TikTokDownloader configuration
DOWNLOADER_DIR = '/app/tiktok-downloader'
DOWNLOAD_JOBS = {}  # Track active downloads


@app.route('/api/download/<username>', methods=['POST'])
def start_download(username):
    """Start downloading all videos from a Douyin/TikTok profile"""
    import json
    import uuid
    
    try:
        # Get URL from request body or construct from username
        data = request.get_json() or {}
        url = data.get('url', '')
        
        if not url:
            # Construct Douyin URL from username
            url = f"https://www.douyin.com/user/{username}"
        
        job_id = str(uuid.uuid4())[:8]
        
        # Update TikTokDownloader settings.json with the account
        settings_path = os.path.join(DOWNLOADER_DIR, 'settings.json')
        
        settings = {
            "accounts_urls": [{
                "mark": username,
                "url": url,
                "tab": "post",
                "earliest": "",
                "latest": "",
                "enable": True
            }],
            "accounts_urls_tiktok": [],
            "mix_urls": [],
            "mix_urls_tiktok": [],
            "owner_url": {},
            "owner_url_tiktok": None,
            "root": VIDEOS_DIR,
            "folder_name": "",
            "name_format": "nickname-create_time",
            "date_format": "%Y-%m-%d_%H-%M-%S",
            "split": "-",
            "folder_mode": False,
            "music": False,
            "download": True,
            "max_size": 0,
            "timeout": 30,
            "max_retry": 5,
            "max_pages": 0,
            "douyin_platform": True,
            "tiktok_platform": False,
            "browser_info": {},
            "browser_info_tiktok": {}
        }
        
        with open(settings_path, 'w') as f:
            json.dump(settings, f, indent=2)
        
        # Run TikTokDownloader in background
        # Use screen/nohup to keep it running
        cmd = f"cd {DOWNLOADER_DIR} && nohup python3 main.py < /dev/null > /tmp/download_{job_id}.log 2>&1 &"
        subprocess.Popen(cmd, shell=True)
        
        DOWNLOAD_JOBS[job_id] = {
            'username': username,
            'url': url,
            'status': 'started',
            'started': datetime.now().isoformat()
        }
        
        return jsonify({
            'success': True,
            'job_id': job_id,
            'message': f'Download started for {username}',
            'note': 'TikTokDownloader is running. Check the gallery for new videos.'
        })
        
    except Exception as e:
        return jsonify({'success': False, 'error': str(e)}), 500


@app.route('/api/download/status/<job_id>')
def download_status(job_id):
    """Check status of a download job"""
    job = DOWNLOAD_JOBS.get(job_id)
    if not job:
        return jsonify({'success': False, 'error': 'Job not found'}), 404
    
    # Check if log file exists and read last lines
    log_file = f"/tmp/download_{job_id}.log"
    log_lines = []
    if os.path.exists(log_file):
        with open(log_file, 'r') as f:
            log_lines = f.readlines()[-20:]  # Last 20 lines
    
    return jsonify({
        'success': True,
        'job': job,
        'log': ''.join(log_lines)
    })


@app.route('/api/videos')
def api_videos():
    """Get all videos grouped by streamer"""
    try:
        streamers = get_all_videos()
        return jsonify({
            'success': True,
            'streamers': streamers,
            'total': sum(len(v) for v in streamers.values())
        })
    except Exception as e:
        return jsonify({'success': False, 'error': str(e)}), 500


@app.route('/api/videos/<filename>', methods=['DELETE'])
def delete_video(filename):
    """Move video to trash"""
    try:
        filepath = os.path.join(VIDEOS_DIR, filename)
        
        if not os.path.exists(filepath):
            return jsonify({'success': False, 'error': 'File not found'}), 404
        
        # Move to trash instead of deleting
        trash_path = os.path.join(TRASH_DIR, filename)
        shutil.move(filepath, trash_path)
        
        # Also move corresponding TS or MP4 if exists
        base = os.path.splitext(filename)[0]
        for ext in ['.ts', '.mp4']:
            related = os.path.join(VIDEOS_DIR, base + ext)
            if os.path.exists(related) and related != filepath:
                shutil.move(related, os.path.join(TRASH_DIR, base + ext))
        
        return jsonify({'success': True, 'message': f'Moved {filename} to trash'})
    except Exception as e:
        return jsonify({'success': False, 'error': str(e)}), 500


@app.route('/api/convert/<filename>', methods=['POST'])
def convert_video(filename):
    """Convert TS to MP4 using FFmpeg"""
    try:
        filepath = os.path.join(VIDEOS_DIR, filename)
        
        if not os.path.exists(filepath):
            return jsonify({'success': False, 'error': 'File not found'}), 404
        
        if not filename.endswith('.ts'):
            return jsonify({'success': False, 'error': 'Only TS files can be converted'}), 400
        
        output_path = filepath.replace('.ts', '.mp4')
        
        # Run FFmpeg conversion - try stream copy first (fastest, no quality loss)
        # If that fails, use CRF 18 for high quality
        cmd = [
            'ffmpeg', '-i', filepath,
            '-c:v', 'copy',  # Try to copy video stream (instant)
            '-c:a', 'aac', '-b:a', '192k',
            '-movflags', '+faststart',
            '-y', output_path
        ]
        
        # Run in background (non-blocking)
        subprocess.Popen(cmd, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
        
        return jsonify({
            'success': True, 
            'message': f'Conversion started for {filename}',
            'output': os.path.basename(output_path)
        })
    except Exception as e:
        return jsonify({'success': False, 'error': str(e)}), 500


@app.route('/video/<filename>')
def serve_video(filename):
    """Serve video file with range request support for seeking"""
    filepath = os.path.join(VIDEOS_DIR, filename)
    
    if not os.path.exists(filepath):
        abort(404)
    
    file_size = os.path.getsize(filepath)
    
    # Handle range requests for video seeking
    range_header = request.headers.get('Range')
    
    if range_header:
        byte_start, byte_end = 0, None
        match = re.match(r'bytes=(\d+)-(\d*)', range_header)
        
        if match:
            byte_start = int(match.group(1))
            if match.group(2):
                byte_end = int(match.group(2))
        
        if byte_end is None:
            byte_end = min(byte_start + 10 * 1024 * 1024, file_size - 1)  # 10MB chunks
        
        length = byte_end - byte_start + 1
        
        def generate():
            with open(filepath, 'rb') as f:
                f.seek(byte_start)
                remaining = length
                while remaining > 0:
                    chunk_size = min(8192, remaining)
                    data = f.read(chunk_size)
                    if not data:
                        break
                    remaining -= len(data)
                    yield data
        
        response = Response(
            generate(),
            status=206,
            mimetype='video/mp4',
            direct_passthrough=True
        )
        response.headers['Content-Range'] = f'bytes {byte_start}-{byte_end}/{file_size}'
        response.headers['Accept-Ranges'] = 'bytes'
        response.headers['Content-Length'] = length
        return response
    
    return send_file(filepath, mimetype='video/mp4')


if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8888, debug=False)
