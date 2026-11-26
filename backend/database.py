import sqlite3
import os
import hashlib
import json
from datetime import datetime, timedelta

DB_PATH = os.path.join(os.path.dirname(__file__), "ses_yolunda.db")

def get_connection():
    conn = sqlite3.connect(DB_PATH)
    conn.row_factory = sqlite3.Row
    return conn

def hash_password(password: str) -> str:
    return hashlib.sha256(password.encode("utf-8")).hexdigest()

def init_db():
    conn = get_connection()
    cur = conn.cursor()

    # 1. Terapistler Tablosu
    cur.execute("""
    CREATE TABLE IF NOT EXISTS therapists (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        email TEXT UNIQUE NOT NULL,
        password_hash TEXT NOT NULL,
        full_name TEXT NOT NULL,
        title TEXT DEFAULT 'Dil ve Konuşma Terapisti (DKT)',
        clinic_name TEXT DEFAULT 'Dil ve Konuşma Terapisi Danışmanlık Merkezi',
        edevlet_document_no TEXT DEFAULT 'YOK-2024-DKT-8921',
        therapist_code TEXT DEFAULT 'DKT-BETUL',
        is_edevlet_verified INTEGER DEFAULT 1,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    );
    """)

    # 2. Öğrenci / Danışan Çocuklar Tablosu
    cur.execute("""
    CREATE TABLE IF NOT EXISTS students (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        therapist_id INTEGER DEFAULT 1,
        full_name TEXT NOT NULL,
        age INTEGER DEFAULT 6,
        avatar TEXT DEFAULT '👦',
        diagnosis TEXT DEFAULT 'Fonolojik ve Artikülasyon Bozukluğu',
        target_phonemes TEXT DEFAULT '/p/, /b/, /m/',
        parent_email TEXT DEFAULT '',
        password_hash TEXT DEFAULT '',
        therapist_code TEXT DEFAULT '',
        total_stars INTEGER DEFAULT 0,
        xp INTEGER DEFAULT 0,
        gems INTEGER DEFAULT 50,
        hearts INTEGER DEFAULT 5,
        streak_days INTEGER DEFAULT 1,
        last_active_date TEXT DEFAULT '',
        overall_accuracy REAL DEFAULT 0.0,
        active_stage_index INTEGER DEFAULT 0,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (therapist_id) REFERENCES therapists (id)
    );
    """)

    # 3. Terapi Seansları Tablosu
    cur.execute("""
    CREATE TABLE IF NOT EXISTS therapy_sessions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        student_id INTEGER NOT NULL,
        phoneme TEXT NOT NULL,
        duration_minutes INTEGER DEFAULT 10,
        words_attempted INTEGER DEFAULT 0,
        words_correct INTEGER DEFAULT 0,
        accuracy_score REAL NOT NULL,
        error_distribution TEXT DEFAULT '{}',
        therapist_note TEXT DEFAULT '',
        completed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (student_id) REFERENCES students (id)
    );
    """)

    # 4. Detaylı Seans Logları
    cur.execute("""
    CREATE TABLE IF NOT EXISTS session_logs (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        session_id INTEGER NOT NULL,
        target_text TEXT NOT NULL,
        spoken_text TEXT NOT NULL,
        target_phoneme TEXT NOT NULL,
        is_match INTEGER NOT NULL,
        accuracy_score INTEGER NOT NULL,
        error_type TEXT DEFAULT '',
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (session_id) REFERENCES therapy_sessions (id)
    );
    """)

    # 5. Oyun Skorları
    cur.execute("""
    CREATE TABLE IF NOT EXISTS game_scores (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        student_id INTEGER NOT NULL,
        game_name TEXT NOT NULL,
        phoneme TEXT NOT NULL,
        score INTEGER NOT NULL,
        stars_earned INTEGER NOT NULL,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (student_id) REFERENCES students (id)
    );
    """)

    # Kolon ekleme kontrolleri (Geriye dönük uyumluluk)
    def ensure_column(table, col_name, col_type):
        try:
            cur.execute(f"ALTER TABLE {table} ADD COLUMN {col_name} {col_type}")
        except Exception:
            pass

    ensure_column("students", "password_hash", "TEXT DEFAULT ''")
    ensure_column("students", "therapist_code", "TEXT DEFAULT ''")
    ensure_column("students", "xp", "INTEGER DEFAULT 0")
    ensure_column("students", "gems", "INTEGER DEFAULT 50")
    ensure_column("students", "hearts", "INTEGER DEFAULT 5")
    ensure_column("students", "streak_days", "INTEGER DEFAULT 1")
    ensure_column("students", "last_active_date", "TEXT DEFAULT ''")
    ensure_column("students", "clinical_assessment", "TEXT DEFAULT ''")
    ensure_column("therapists", "therapist_code", "TEXT DEFAULT 'DKT-BETUL'")

    # Sahte test kullanıcılarını temizle
    cur.execute("DELETE FROM students WHERE full_name IN ('Ali Yılmaz', 'Zeynep Kaya', 'Can Demir', 'Kerem Öztürk')")

    conn.commit()

    # Varsayılan Terapist (e-Devlet Onaylı Betül Gül)
    cur.execute("SELECT COUNT(*) as cnt FROM therapists")
    if cur.fetchone()["cnt"] == 0:
        admin_pass = hash_password("123456")
        cur.execute("""
        INSERT INTO therapists (email, password_hash, full_name, title, clinic_name, edevlet_document_no, therapist_code, is_edevlet_verified)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?)
        """, (
            "betulgul5634@gmail.com",
            admin_pass,
            "Uzm. DKT Betül Gül",
            "Dil ve Konuşma Terapisti (DKT)",
            "Dil ve Konuşma Danışmanlık Merkezi",
            "YOKME9PRF4N8DER3Z0",
            "DKT-BETUL",
            1
        ))
        conn.commit()

    conn.close()

if __name__ == "__main__":
    init_db()
    print("Database initialized successfully at:", DB_PATH)
