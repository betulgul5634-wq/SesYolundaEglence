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

    # 1. Terapistler Tablosu (Dil ve Konuşma Terapistleri & e-Devlet YÖK Mezuniyet Doğrulamalı)
    cur.execute("""
    CREATE TABLE IF NOT EXISTS therapists (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        email TEXT UNIQUE NOT NULL,
        password_hash TEXT NOT NULL,
        full_name TEXT NOT NULL,
        title TEXT DEFAULT 'Dil ve Konuşma Terapisti (DKT)',
        clinic_name TEXT DEFAULT 'Dil ve Konuşma Terapisi Danışmanlık Merkezi',
        edevlet_document_no TEXT DEFAULT 'YOK-2024-DKT-8921',
        is_edevlet_verified INTEGER DEFAULT 1,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    );
    """)

    # 2. Öğrenci / Danışan Çocuklar Tablosu (Veli E-Posta Bildirim Entegreli)
    cur.execute("""
    CREATE TABLE IF NOT EXISTS students (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        therapist_id INTEGER NOT NULL,
        full_name TEXT NOT NULL,
        age INTEGER NOT NULL,
        avatar TEXT DEFAULT '👦',
        diagnosis TEXT DEFAULT 'Fonolojik ve Artikülasyon Bozukluğu',
        target_phonemes TEXT DEFAULT '/r/, /k/, /s/',
        parent_email TEXT DEFAULT '',
        total_stars INTEGER DEFAULT 0,
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

    # 4. Detaylı Seans Sözcük / Fonem Logları
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

    # 5. Oyun Skorları Tablosu
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

    conn.commit()

    # Varsayılan Terapist ve Örnek Klinik Verileri Yükle (Seed Data)
    cur.execute("SELECT COUNT(*) as cnt FROM therapists")
    if cur.fetchone()["cnt"] == 0:
        seed_clinical_data(conn)

    conn.close()

def seed_clinical_data(conn):
    cur = conn.cursor()
    # Demo Dil ve Konuşma Terapisti (e-Devlet Onaylı DKT Mezuniyet Belgeli)
    admin_pass = hash_password("123456")
    cur.execute("""
    INSERT INTO therapists (email, password_hash, full_name, title, clinic_name, edevlet_document_no, is_edevlet_verified)
    VALUES (?, ?, ?, ?, ?, ?, ?)
    """, ("dkt@klinik.com", admin_pass, "Uzm. DKT Merve Kaya", "Dil ve Konuşma Terapisti (DKT)", "Dil ve Konuşma Danışmanlık Merkezi", "YOK-2024-DKT-8921", 1))
    therapist_id = cur.lastrowid

    # 4 Örnek Öğrenci (Veli Bildirim E-postaları ile)
    students_data = [
        (therapist_id, "Ali Yılmaz", 6, "👦", "Rhotacism (/r/ Sesletim Güçlüğü)", "/r/, /l/", "veli.ali@gmail.com", 42, 78.5, 17),
        (therapist_id, "Zeynep Kaya", 5, "👧", "Önleme (/k/ ➔ /t/ değişimi)", "/k/, /g/", "veli.zeynep@gmail.com", 55, 84.0, 4),
        (therapist_id, "Can Demir", 7, "🧒", "Sigmatizm (/s/ Pelteklik)", "/s/, /z/", "veli.can@gmail.com", 68, 91.2, 8),
        (therapist_id, "Kerem Öztürk", 6, "🦁", "Ötümlülük Değişimi (/p/ ➔ /b/)", "/p/, /b/", "veli.kerem@gmail.com", 30, 72.0, 0),
    ]

    for s in students_data:
        cur.execute("""
        INSERT INTO students (therapist_id, full_name, age, avatar, diagnosis, target_phonemes, parent_email, total_stars, overall_accuracy, active_stage_index)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
        """, s)
        s_id = cur.lastrowid

        # Geçmiş seans kayıtları
        now = datetime.now()
        for i in range(1, 6):
            session_date = (now - timedelta(days=6-i)).strftime("%Y-%m-%d %H:%M:%S")
            acc = min(98.0, 60.0 + (i * 7.5))
            cur.execute("""
            INSERT INTO therapy_sessions (student_id, phoneme, duration_minutes, words_attempted, words_correct, accuracy_score, error_distribution, therapist_note, completed_at)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
            """, (s_id, s[5].split(",")[0].strip(), 12, 16, int(16 * (acc/100)), acc, json.dumps({"Yerine Koyma": 2, "Önleme": 1 if i < 3 else 0}), f"Seans {i}: Artikülasyon belirginleşiyor, ritim iyi.", session_date))

    conn.commit()

if __name__ == "__main__":
    init_db()
    print("Database initialized successfully at:", DB_PATH)
