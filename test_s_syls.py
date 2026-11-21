import sys, asyncio, edge_tts
sys.stdout.reconfigure(encoding='utf-8')

# Syllables of /s/
syls = ['sı', 'si', 'ıs', 'is', 'sa', 'se', 'as', 'es', 'so', 'sö', 'os', 'ös', 'su', 'sü', 'us', 'üs', 'ısı', 'isi', 'sıs', 'sis', 'asa', 'ese', 'sas', 'ses', 'oso', 'ösö', 'sos', 'sös', 'usu', 'üsü', 'sus', 'süs']

print(f"Testing {len(syls)} syllables of /s/...")
