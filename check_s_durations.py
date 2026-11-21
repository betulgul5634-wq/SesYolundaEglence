import wave, os

pure_dir = 'backend/pure_syllables'
s_files = [
    'sa.wav', 'se.wav', 'sı.wav', 'si.wav', 'so.wav', 'sö.wav', 'su.wav', 'sü.wav',
    'as.wav', 'es.wav', 'ıs.wav', 'is.wav', 'os.wav', 'ös.wav', 'us.wav', 'üs.wav',
    'asa.wav', 'ese.wav', 'ısı.wav', 'isi.wav', 'oso.wav', 'ösö.wav', 'usu.wav', 'üsü.wav',
    'sas.wav', 'ses.wav', 'sıs.wav', 'sis.wav', 'sos.wav', 'sös.wav', 'sus.wav', 'süs.wav'
]

for name in s_files:
    p = os.path.join(pure_dir, name)
    if os.path.exists(p):
        with wave.open(p, 'rb') as wf:
            dur = wf.getnframes() / wf.getframerate()
            print(f"{name:10} {dur:.3f}s, {wf.getnframes()} frames, {wf.getframerate()}Hz")
