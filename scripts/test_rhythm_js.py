# Let's test the Web Audio API rhythm beat script structure
js_code = """
(function() {
  if (window._rhythmLoopActive) {
    try { window._rhythmLoopStop(); } catch(e) {}
  }
  try {
    const AudioContext = window.AudioContext || window.webkitAudioContext;
    const ctx = new AudioContext();
    if (ctx.state === 'suspended') {
      ctx.resume();
    }
    window._rhythmCtx = ctx;
    window._rhythmLoopActive = true;
    
    const bpm = 112;
    const beatTime = 60.0 / bpm; // ~0.535s
    const startTime = ctx.currentTime + 0.05;
    
    // Master gain for rhythm backing track (balanced so voice is clearly heard on top)
    const masterGain = ctx.createGain();
    masterGain.gain.setValueAtTime(0.28, ctx.currentTime);
    masterGain.connect(ctx.destination);
    
    // Function to schedule a kick drum
    function playKick(time) {
      const osc = ctx.createOscillator();
      const gain = ctx.createGain();
      osc.type = 'sine';
      osc.frequency.setValueAtTime(130, time);
      osc.frequency.exponentialRampToValueAtTime(42, time + 0.12);
      gain.gain.setValueAtTime(0.7, time);
      gain.gain.exponentialRampToValueAtTime(0.001, time + 0.18);
      osc.connect(gain);
      gain.connect(masterGain);
      osc.start(time);
      osc.stop(time + 0.2);
    }
    
    // Function to schedule a hand clap / snare
    function playClap(time) {
      // Noise burst for clap
      const bufferSize = ctx.sampleRate * 0.08;
      const buffer = ctx.createBuffer(1, bufferSize, ctx.sampleRate);
      const output = buffer.getChannelData(0);
      for (let i = 0; i < bufferSize; i++) {
        output[i] = Math.random() * 2 - 1;
      }
      const whiteNoise = ctx.createBufferSource();
      whiteNoise.buffer = buffer;
      
      const filter = ctx.createBiquadFilter();
      filter.type = 'bandpass';
      filter.frequency.value = 1100;
      filter.Q.value = 1.8;
      
      const gain = ctx.createGain();
      gain.gain.setValueAtTime(0.5, time);
      gain.gain.exponentialRampToValueAtTime(0.01, time + 0.12);
      
      whiteNoise.connect(filter);
      filter.connect(gain);
      gain.connect(masterGain);
      
      // Tone pop
      const osc = ctx.createOscillator();
      const oscGain = ctx.createGain();
      osc.type = 'triangle';
      osc.frequency.setValueAtTime(280, time);
      osc.frequency.exponentialRampToValueAtTime(140, time + 0.06);
      oscGain.gain.setValueAtTime(0.3, time);
      oscGain.gain.exponentialRampToValueAtTime(0.01, time + 0.06);
      osc.connect(oscGain);
      oscGain.connect(masterGain);
      
      whiteNoise.start(time);
      whiteNoise.stop(time + 0.12);
      osc.start(time);
      osc.stop(time + 0.06);
    }
    
    // Function to schedule woodblock / shaker
    function playWoodblock(time, high) {
      const osc = ctx.createOscillator();
      const gain = ctx.createGain();
      osc.type = 'sine';
      osc.frequency.value = high ? 950 : 720;
      gain.gain.setValueAtTime(0.2, time);
      gain.gain.exponentialRampToValueAtTime(0.001, time + 0.04);
      osc.connect(gain);
      gain.connect(masterGain);
      osc.start(time);
      osc.stop(time + 0.05);
    }
    
    // Function to schedule playful marimba chime note
    function playMarimba(time, freq) {
      const osc = ctx.createOscillator();
      const gain = ctx.createGain();
      osc.type = 'triangle';
      osc.frequency.value = freq;
      gain.gain.setValueAtTime(0.22, time);
      gain.gain.exponentialRampToValueAtTime(0.001, time + 0.25);
      osc.connect(gain);
      gain.connect(masterGain);
      osc.start(time);
      osc.stop(time + 0.28);
    }
    
    // Notes progression (C4, E4, G4, A4, C5)
    const melody = [261.63, 329.63, 392.00, 440.00, 523.25, 440.00, 392.00, 329.63];
    
    let currentStep = 0;
    let nextNoteTime = startTime;
    const scheduleAheadTime = 0.2;
    const lookahead = 25.0; // ms
    
    function nextNote() {
      nextNoteTime += (beatTime / 2); // 8th notes
      currentStep = (currentStep + 1) % 16;
    }
    
    function scheduleStep(step, time) {
      const beatInMeasure = step % 8; // 8 eighth notes per 4/4 measure
      
      // Kick on 1 and 5 (beats 1 and 3)
      if (beatInMeasure === 0 || beatInMeasure === 4) {
        playKick(time);
      }
      // Clap on 2 and 6 (beats 2 and 4)
      if (beatInMeasure === 2 || beatInMeasure === 6) {
        playClap(time);
      }
      // Shaker / woodblock on off-beats
      if (beatInMeasure % 2 === 1) {
        playWoodblock(time, beatInMeasure === 7);
      }
      
      // Melodic bass / marimba chime on main beats
      if (beatInMeasure === 0) playMarimba(time, melody[Math.floor(step / 2) % melody.length]);
      if (beatInMeasure === 4) playMarimba(time, melody[(Math.floor(step / 2) + 2) % melody.length]);
    }
    
    let timerId = null;
    function scheduler() {
      if (!window._rhythmLoopActive) return;
      while (nextNoteTime < ctx.currentTime + scheduleAheadTime) {
        scheduleStep(currentStep, nextNoteTime);
        nextNote();
      }
      timerId = setTimeout(scheduler, lookahead);
    }
    
    scheduler();
    
    window._rhythmLoopStop = function() {
      window._rhythmLoopActive = false;
      if (timerId) clearTimeout(timerId);
      try {
        masterGain.gain.setValueAtTime(masterGain.gain.value, ctx.currentTime);
        masterGain.gain.exponentialRampToValueAtTime(0.0001, ctx.currentTime + 0.25);
        setTimeout(() => {
          try { ctx.close(); } catch(e) {}
        }, 300);
      } catch(e) {}
    };
  } catch(e) {
    console.error("Rhythm error:", e);
  }
})();
"""
print("JS syntax length:", len(js_code))
