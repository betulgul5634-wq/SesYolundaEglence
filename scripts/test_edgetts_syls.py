import asyncio
import edge_tts
import speech_recognition as sr
import io
import miniaudio
import wave

test_prompts = {
    'Iıp.': 'Iıp.',
    'İip.': 'İip.',
    'ıp': 'ıp',
    'ip': 'ip',
    'Pıı.': 'Pıı.',
    'Pii.': 'Pii.',
    'Ip': 'Ip',
    'İp': 'İp',
    'ap': 'ap',
    'Aap.': 'Aap.',
}

async def test_all():
    r = sr.Recognizer()
    for label, text in test_prompts.items():
        comm = edge_tts.Communicate(text, "tr-TR-EmelNeural", pitch="+3Hz", rate="-6%")
        mp3_data = b""
        async for chunk in comm.stream():
            if chunk["type"] == "audio":
                mp3_data += chunk["data"]
        dec = miniaudio.decode(mp3_data)
        wav_io = io.BytesIO()
        with wave.open(wav_io, "wb") as wf:
            wf.setnchannels(dec.nchannels)
            wf.setsampwidth(2)
            wf.setframerate(dec.sample_rate)
            wf.writeframes(dec.samples)
        wav_io.seek(0)
        try:
            with sr.AudioFile(wav_io) as source:
                audio = r.record(source)
            rec = r.recognize_google(audio, language="tr-TR")
        except Exception as e:
            rec = f"<none/error: {e}>"
        print(f"Prompt: {label:10} -> Heard: '{rec}'")

asyncio.run(test_all())
