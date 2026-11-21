import asyncio, edge_tts, miniaudio, numpy as np

async def test_syl(text):
    comm = edge_tts.Communicate(text, 'tr-TR-EmelNeural', rate='-10%', pitch='+2Hz')
    mp3 = b''
    async for c in comm.stream():
        if c['type'] == 'audio':
            mp3 += c['data']
    dec = miniaudio.decode(mp3)
    samps = np.frombuffer(dec.samples, dtype=np.int16)
    dur = len(samps) / (dec.sample_rate * dec.nchannels)
    peak = np.max(np.abs(samps))
    print(f'Text "{text}": samples={len(samps)}, dur={dur:.3f}s, peak={peak}')

async def main():
    for t in ['Uz.', 'Uz,', 'Uzz.', 'Mam.', 'Lü.', 'Ol.', 'Ul.', 'Mi.', 'Mı.', 'Çü.', 'Ül.', 'Il.', 'Iv.']:
        await test_syl(t)

if __name__ == '__main__':
    asyncio.run(main())
