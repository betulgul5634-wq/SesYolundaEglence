# -*- coding: utf-8 -*-
"""
Ses Yolunda Eğlence - Tüm Testleri Çalıştırma Aracı (Unified Test Runner)
Bu script, bitirme jürisi veya geliştirici için hem mobil hem backend tüm testleri tek tıkla çalıştırır.
"""

import subprocess
import sys
import os

def run_command(desc, cmd, cwd=None):
    print("=" * 65)
    print(f"▶ {desc}...")
    print(f"  Komut: {' '.join(cmd) if isinstance(cmd, list) else cmd}")
    print("=" * 65)
    
    res = subprocess.run(cmd, cwd=cwd, shell=True)
    if res.returncode == 0:
        print(f"✔ BAŞARILI: {desc}\n")
        return True
    else:
        print(f"❌ HATA: {desc} başarısız oldu (Hata Kodu: {res.returncode})\n")
        return False

def main():
    print("""
    ╔═══════════════════════════════════════════════════════════════╗
    ║        🎙️ SES YOLUNDA EĞLENCE - BİTİRME PROJESİ             ║
    ║             TAM SİSTEM TEST VE DOĞRULAMA SUITE                ║
    ╚═══════════════════════════════════════════════════════════════╝
    """)
    
    results = []
    
    # 1. Flutter Statik Kod Analizi
    results.append(("Flutter Statik Analiz (flutter analyze)", run_command("Flutter Statik Analiz", ["flutter", "analyze", "mobile"])))
    
    # 2. Flutter Birim Testleri
    results.append(("Flutter Klinik Birim Testleri", run_command("Flutter Birim Testleri", ["flutter", "test", "test/sound_groups_unit_test.dart"], cwd="mobile")))
    
    # 3. Python Backend Entegrasyon Testleri
    results.append(("FastAPI Backend Entegrasyon Testleri", run_command("Backend API Testleri", [sys.executable, "-m", "unittest", "tests/test_backend_api.py"])))
    
    # 4. Bitirme Projesi Adli Denetimi
    results.append(("Nihai Akustik & Fonem Adli Denetimi", run_command("Akustik Doğrulama", [sys.executable, "scripts/verify_graduation_project.py"])))
    
    print("\n" + "=" * 65)
    print("               TEST SONUÇLARI ÖZET TABLOSU")
    print("=" * 65)
    all_passed = True
    for name, status in results:
        status_text = "🟢 GEÇTİ (PASSED)" if status else "🔴 BAŞARISIZ (FAILED)"
        print(f"  {name:<42} : {status_text}")
        if not status:
            all_passed = False
            
    print("=" * 65)
    if all_passed:
        print("🎉 TEBRİKLER! TÜM TESTLER %100 BAŞARIYLA TAMAMLANDI.")
        print("   Proje bitirme jürisi sunumuna ve teslimine bütünüyle hazırdır.")
        sys.exit(0)
    else:
        print("⚠️ DİKKAT: Bazı testler başarısız oldu. Lütfen yukarıdaki çıktıları inceleyiniz.")
        sys.exit(1)

if __name__ == '__main__':
    main()
