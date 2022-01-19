// buchla 700
// still need to figure out how to input/choose waveforms.
// might use globals like in lanterman version

(

SynthDef(\buchla700, {
	arg
	freq=220,
	mod=220,
	vel=1,

	amp1=1, amp2=1, amp3=1, amp4=1,ampA=1, ampB=1,

	instr=1, config=6,

	noise=220, namp=0.6, dyn=0.8,

	shape=0,wsAbuf=0, wsBbuf=0,

	dur=1;

	var sig, sigA, sigB, max_rawindex,
	osc1, osc2, osc3, osc4,oscs,
	fmodinputs, envs, gate,
	dxr1, dxr2, dxr3, dxr4, dxr5, dxr6,
	dxMod3, dxMod6, prev_out,
	indices, rawindices,
	fb_01,freqs, sweep, fb01_indices, sweep_indices,
	aEnv, bEnv, filtEnv, rEnv, shapes, dec;

	gate=1;

	prev_out = LocalIn.ar(4);

	freqs = {freq}!4;

	max_rawindex = pi*(2**(33/16));

	/// the different note lengths etc
	shapes = [
		EnvGen.ar(Env.perc(0.01, dur, dyn, -4.0),doneAction:2),
		EnvGen.ar(Env.new([1]))
	];

	dec = Select.ar(shape, shapes);

	/// end

	fb_01 = [
		Env.adsr(0,2,0,1,7.4+vel*(1.1),0),  // 0: idx1
		Env.adsr(0,4,0.75,1,5+(vel*2.8),0), // 1: idx2
		Env([10],[1]),                      // 2: idx3
		Env.adsr(0,7,0.8,1,5.9,0),          // 3: idx4
		Env([0],[1]),                       // 4: idx5
		Env([10],[1]),                      // 5: idx6
		Env.adsr(0,10,1,1,10,0),            // 6: aEnv
		Env.adsr(0,10,1,1,10,0),            // 7: bEnv
		Env([10],[1]),                      // 8: filtEnv
		Env([0],[1])                        // 9: rEnv
	];

	sweep = [
		Env([5,8,5,8,5,8,5,8],1.5*[1,1,1,1,1,1,10]),
		Env([10,0,10],[4,4]),
		Env([5,10,5,10,5,10,5,10],[1.5,1.5,1,1,1.5,1.5,10]),
		Env([5,8,5,8,5,8,5,8],1.8*[1,1,1,1,1,1,10]),
		Env([10,0,10],[4,4]),
		Env([5,10,5,10,5,10,5,10],[1,1.5,1.5,1,1.5,1.5,1]),
		Env.adsr(0.1,0,1,0,10,0),            // 6: aEnv
		Env.adsr(0.1,0,1,0,10,0),            // 7: bEnv
		Env([10],[1]),                      // 8: filtEnv
		Env([0],[1])                        // 9: rEnv
	];

	//envs = Select.ar(instr,[fb_01,sweep]);

	sweep_indices = [
		EnvGen.ar(sweep[0],gate),
		EnvGen.ar(sweep[1],gate),
		EnvGen.ar(sweep[2],gate),
		EnvGen.ar(sweep[3],gate),
		EnvGen.ar(sweep[4],gate),
		EnvGen.ar(sweep[5],gate),
		EnvGen.kr(sweep[6],gate,doneAction:2),
		EnvGen.kr(sweep[7],gate,doneAction:2),
		EnvGen.kr(sweep[8],gate),
		EnvGen.kr(sweep[9],gate)
	];

	fb01_indices = [
		EnvGen.ar(fb_01[0],gate),
		EnvGen.ar(fb_01[1],gate),
		EnvGen.ar(fb_01[2],gate),
		EnvGen.ar(fb_01[3],gate),
		EnvGen.ar(fb_01[4],gate),
		EnvGen.ar(fb_01[5],gate),
		EnvGen.kr(fb_01[6],gate,doneAction:2),
		EnvGen.kr(fb_01[7],gate,doneAction:2),
		EnvGen.kr(fb_01[8],gate),
		EnvGen.kr(fb_01[9],gate)
	];

	indices = Select.kr(instr, [
		sweep_indices,
		fb01_indices
	]);

	indices = Clip.kr([0,0,0,0,0,0,0,0,0,0].lag(0.5) + indices, lo: 0, hi: 10);
	aEnv = indices[6];
	bEnv = indices[7];
	filtEnv = indices[8];
	rEnv = indices[9];

	rawindices = pi*(
		2**(
			(33/16)
			-(
				(100-
					(10*indices
	                )
	             )/8
	         )
	        )
	);

	////// circuit time


	// index triangle outputs
	//[po[2-1],po[2-1],po[2-1],po[1-1],po[1-1],po[1-1],
	//	 po[3-1],po[4-1],po[3-1],po[4-1],po[3-1],po[1-1]]);
	dxr1 = rawindices[0]* Select.ar(config, [
		prev_out[1],
		prev_out[1],
		prev_out[1],
		prev_out[0],
		prev_out[0],
		prev_out[0],
		prev_out[2],
		prev_out[3],
		prev_out[2],
		prev_out[3],
		prev_out[2],
		prev_out[0]
	]);
	//[po[4-1],po[2-1],po[3-1],po[3-1],po[2-1],po[4-1],
	//	 po[2-1],po[2-1],po[2-1],po[3-1],po[2-1],po[2-1]]);
	dxr2 = rawindices[1]* Select.ar(config, [
		prev_out[3],
		prev_out[1],
		prev_out[2],
		prev_out[2],
		prev_out[1],
		prev_out[3],
		prev_out[1],
		prev_out[1],
		prev_out[1],
		prev_out[2],
		prev_out[1],
		prev_out[1]
	]);

	//[po[2-1],po[4-1],po[4-1],po[2-1],po[3-1],po[3-1],
	//	     po[4-1],po[4-1],po[3-1],po[2-1],po[1-1],po[4-1]]);
	dxr4 = rawindices[3] * Select.ar(config, [
		prev_out[1],
		prev_out[3],
		prev_out[3],
		prev_out[1],
		prev_out[2],
		prev_out[2],
		prev_out[3],
		prev_out[3],
		prev_out[2],
		prev_out[1],
		prev_out[0],
		prev_out[3]
	]);
	//[po[4-1],po[4-1],po[1-1],po[3-1],po[4-1],po[2-1],
	//	 po[1-1],po[4-1],po[1-1],po[1-1],po[2-1],po[3-1]]);
	dxr5 = rawindices[4] * Select.ar(config, [
		prev_out[3],
		prev_out[3],
		prev_out[0],
		prev_out[2],
		prev_out[3],
		prev_out[1],
		prev_out[0],
		prev_out[3],
		prev_out[0],
		prev_out[0],
		prev_out[1],
		prev_out[2]
	]);

	// index triangles 3 and 6 (on images), i.e. 2 and 5 in code, only feed wavetables

	fmodinputs = [
		Select.ar(config,[
			dxr1,     dxr1,     dxr1,
			dxr2,     dxr2,     dxr2,
			dxr2,     dxr2,     dxr2,
			dxr1,     dxr2,     dxr4
		]),
		Select.ar(config,[
			Silent.ar,Silent.ar,dxr2,
			dxr5,     dxr4,     Silent.ar,
			dxr1,     dxr1,     dxr4,
			dxr2,     Silent.ar,dxr5
		]),
		Select.ar(config,[
			dxr4,     dxr4,     dxr4,
			Silent.ar,Silent.ar,dxr5,
			Silent.ar,Silent.ar,Silent.ar,
			dxr5,     Silent.ar,Silent.ar
		]),
		Select.ar(config,[
			Silent.ar,Silent.ar,dxr5,
			Silent.ar,Silent.ar,Silent.ar,
			Silent.ar,Silent.ar,Silent.ar,
			dxr5,     Silent.ar,Silent.ar
		])
	];

	fmodinputs[0] = fmodinputs[0] + Select.ar(config,[
		Silent.ar,Silent.ar,Silent.ar,
		Silent.ar,Silent.ar,Silent.ar,
		dxr4,      dxr4,    Silent.ar,
		Silent.ar,Silent.ar,Silent.ar
	]);
	fmodinputs[1] = fmodinputs[1] + Select.ar(config,[
		Silent.ar,Silent.ar,Silent.ar,
		Silent.ar,dxr5,     Silent.ar,
		Silent.ar,Silent.ar,Silent.ar,
		Silent.ar,Silent.ar,Silent.ar
	]);

    // oscillator outputs
	oscs = SinOsc.ar(freqs,fmodinputs);

	// index triangles 3 and 6 (on images), i.e. 2 and 5 in code, only feed wavetables
	dxMod3 = Select.ar(config,[
		dxr2,     dxr2,     Silent.ar,
		dxr1,     Silent.ar,dxr1,
		Silent.ar,Silent.ar,dxr1,
		Silent.ar,dxr1,     dxr4
	]);
	dxMod6 = Select.ar(config,[
		dxr5,     dxr5,     Silent.ar,
		dxr4,     Silent.ar,dxr4,
		Silent.ar,dxr5,     dxr5,
		Silent.ar,dxr4,     dxr2
	]);

	// Since the output of index triangles 3 and 6 (on images), i.e. 2 and 5 in code,
	// doesn't involve any feedback mechanisms, we might as well use oo intead of po.
	dxr3 = ((rawindices[2] + dxMod3) / max_rawindex) * oscs[1];

	dxr6 = ((rawindices[5] + dxMod6) / max_rawindex) * oscs[3];

    LocalOut.ar(oscs);

	// A track

	sigA = (rawindices[6]/max_rawindex)
	* (Shaper.ar(wsAbuf, dxr3));

	// B track

	sigB = (rawindices[7]/max_rawindex)
	* (Shaper.ar(wsBbuf, dxr6));

	///

	/// make signal come out speakers right

	sig = Splay.ar([sigA,sigB],4);

	sig = MoogFF.ar(sig, 20*(2**indices[8]), 4 * indices[9]/10);

	// make it pretty

	sig = LeakDC.ar(VerbEF.ar(sig!4));

	// free all threads
	sig.do{arg gn; DetectSilence.ar(gn)};

	sig = dec * sig;

	Out.ar(0, sig * 0.4);

}).add;
)

s.boot;


(
	~wsB = Signal.chebyFill(
		4096,
		[1,1,-1,-1,0,1,0,-1,0,1,0,-1,0,0,0,1], // "full tonewheel"
		normalize: true,
		zeroOffset:false
	).asWavetableNoWrap;
	~wsBbuf = Buffer.loadCollection(s,~wsB);

	~wsA = Signal.chebyFill(
		4096,
		//0.25*[1,-1,-1,1] / (1..32), // "alt saw"
		//[1,0,-1,0] / (1..32), // "true square"
		0.1*[1,0,-1,0]*Array.fill(32,1),
		normalize: true,
		zeroOffset:false
	).asWavetableNoWrap;
	~wsAbuf = Buffer.loadCollection(s,~wsA);
)

w.free;

~wsAbuf.plot;

s.options.memSize = s.options.memSize * 16;
s.reboot;

s.freeAll;

w = Synth(\buchla700, [\wsBbuf, ~wtbufnums[8], \wsAbuf, ~wtbufnums[5], \shape,0, \dyn, 0.9]);
x = Synth(\buchla700, [\wsBbuf, ~wsAbuf, \wsAbuf, ~wsBbuf, \config, 11,\vel,5.5, \freq, 60, \instr, 1, \shape, 0,\dur, 9]);
y = Synth(\buchla700, [\wsBbuf, ~wsAbuf, \wsAbuf, ~wsBbuf, \config, 11,\vel,5.5, \freq, 75, \instr, 0,\dur, 9]);
z = Synth(\buchla700, [\wsBbuf, ~wsAbuf, \wsAbuf, ~wsBbuf, \config, 11,\vel,5.5, \freq, 66, \instr, 0,\dur, 9]);

(
~chorus1 = Pdef(\chorale1,
    Pbind(
	    \instrument, \buchla700,
		\config, 1,
		\wsBbuf, ~wtbufnums[10], \wsAbuf, ~wtbufnums[55],
		\dur, 24/22, \instr, 0,
		\shape, 0, \dyn, 0.5, \vel, 10,
		\freq, Prand((Scale.jiao.degrees+54).midicps,inf)
		//Pseq((Scale.majorPentatonic.degrees+30).midicps ++ (Scale.majorPentatonic.degrees+30).midicps.reverse[1..3],inf)
    )
).play;

~chorus2 = Pdef(\chorale2,
    Pbind(
	    \instrument, \buchla700,
		\config, 6,
		\wsBbuf, ~wtbufnums[350], \wsAbuf, ~wtbufnums[100],
		\vel, Pwhite(0.5,7,inf),
		\dur, 6/22, \instr, 1,
		\shape, 0, \dyn, 0.4,
		\freq, Prand((Scale.jiao.degrees+30).midicps,inf)
    )
).play;
)
y.free;
~chorus2.set(\dur, 9);

~chorus1.stop;
~chorus2.stop;

Scale.directory;

s.freeAll;


s.options.memSize = s.options.memSize * 2;

s.reboot;



s.options.memSize;
s.options.blockSize = s.options.blockSize * 2;

= s.options.memSize * 16;

s.reboot;