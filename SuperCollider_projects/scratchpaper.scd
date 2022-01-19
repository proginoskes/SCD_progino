(
SynthDef(\fmo, {
	arg freq=220, cRatio=2, mRatio=4, index=3, amp=2, gate=1, config=6;
	var car, mod, env;
	mod = SinOsc.ar(freq * mRatio, mul:freq * mRatio * index);
	car = {SinOsc.ar(freq * cRatio + mod)}!4;
	//car = car * mod;
	car = Splay.ar(VerbEF.ar(car),2) * amp;
	Out.ar(0,car*0.2);
}).add;
)

y = Synth(\fmo, [\mRatio, 2, \cRatio, 1, \index, 0.4]);
y.set(\cRatio,6);
y.set(\mRatio, 3);
y.set(\index, 2.6);
y.free;

s.options.memSize;
s.options.memSize = 32768;



s.freeAll;
s.reboot;
s.options.numWireBufs = 64;

(
SynthDef(\wts, {

}).add;
)

SuperDirt.start;


/// FM and PM with two subalgorithms
/// 1 -> 2 -> Out
// Asin(2pi * car + idx2 * m + phi)


(

SynthDef(\buchla700, {
	arg freq=220,
	mod=220, vel=1, gate=1,
	amp1=1, amp2=1, amp3=1, amp4=1,
	ampA=1, ampB=1, instr=1, config=6;
	var sig, sigA, sigB, max_rawindex,
	osc1, osc2, osc3, osc4,oscs,
	fmodinputs, envs,
	dxr1, dxr2, dxr3, dxr4, dxr5, dxr6,
	dxMod3, dxMod6, prev_out,
	indices, rawindices,
	fb_01,freqs, sweep, fb01_indices, sweep_indices,
	aEnv, bEnv, filtEnv, rEnv,
	wsA, wsAbuf, wsB, wsBbuf;

	prev_out = LocalIn.ar(4);

	freqs = {freq}!4;

	max_rawindex = pi*(2**(33/16));

	wsB = Signal.chebyFill(
		4096,
		[1,1,-1,-1,0,1,0,-1,0,1,0,-1,0,0,0,1], // "full tonewheel"
		normalize: true,
		zeroOffset:false
	).asWavetableNoWrap;
	wsBbuf = Buffer.loadCollection(s,wsB);

	wsA = Signal.chebyFill(
		4096,
		//0.25*[1,-1,-1,1] / (1..32), // "alt saw"
		//[1,0,-1,0] / (1..32), // "true square"
		0.1*[1,0,-1,0]*Array.fill(32,1),
		normalize: true,
		zeroOffset:false
	).asWavetableNoWrap;
	wsAbuf = Buffer.loadCollection(s,wsA);

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
		dxr4,      dxr4,      Silent.ar,
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
	* {Shaper.ar(wsAbuf, dxr3)}!4;

	// B track

	sigB = (rawindices[7]/max_rawindex)
	* {Shaper.ar(wsBbuf, dxr6)}!4;

	///


	///

	sig = Splay.ar([sigA,sigB],2);

	sig = MoogFF.ar(sig, 20*(2**indices[8]), 4 * indices[9]/10);

	Out.ar(0, sig * 0.4);


}).add;
)

s.boot;

p = Synth(\pmath2, [\freq, 110, \vel, 2,\instr, 0,\config,2]);
p.set(\config,1);
p.set(\freq, 33.midicps);
p.set(\vel,4)
// idx must be greater than 1 to have effect
p.set(\instr, 1);
p.free;

s.freeAll;

(
SynthDef(\fmath2, {
	arg amp1=10, amp2=0.5, car=220, mod=220, idx1=1, idx2=1;
	var sig, feed;

	feed = amp1 * mod * idx1 * VarSaw.ar(mod);

	sig = amp2 * SinOsc.ar(car + feed + idx2);
	sig = Splay.ar(sig,2);

	Out.ar(0, sig);

}).add;

)


f = Synth(\fmath2);
f.set(\amp1,9);
// idx must be a fraction to have an effect
f.set(\idx1, 0.4);
f.free;

(
// 1 -> 2 -> 3 -> out
SynthDef(\fmodamp, {
	arg amp1=10, amp2=0.5, car=220, mod=220, idx1=1, idx2=1;
	var sig, feed1, feed2;

	feed1 = SinOsc.ar(amp1);

	feed2 = feed1 * mod * idx1;// * VarSaw.ar(mod);

	sig = {amp2 * SinOsc.ar(car + feed2)}!8;
	sig = Splay.ar(sig,2);

	Out.ar(0, sig);

}).add;

)

s.boot;

f = Synth(\fmodamp);
f.set(\amp1, 8);
f.set(\car, 440);
// idx must be a fraction to have an effect
f.set(\idx1, 0.05);
f.free;

s.freeAll;

(
// 1 -> 2 -> 3 -> out
SynthDef(\fmodenv, {
	arg amp1=10, amp2=0.5, car=220, mod=220, modmult=440, idx1=1, idx2=1, t_gate=0, dur=1, done=2;
	var sig, feed1, feed2, env;

	env = EnvGen.kr(
		Env.new([0.01, 0.25, 0.5,0.9,0.5,0.25,0, 0.00],dur * [0.4, 0.1, 0.02, 0.02, 0.1, 0.2,0.2], [1,-3, 0,0, 3,-1]),gate: t_gate,doneAction:done
	);

	feed1 = env;
	feed2 = feed1 * modmult *  idx1 * SinOsc.ar(mod);

	sig = {amp2 * env* SinOsc.ar(car + feed2)}!8;
	sig = Splay.ar(sig,2);

	Out.ar(0, sig);

}).add;

)

s.boot;

f = Synth(\fmodenv, [\t_gate, 1, \amp1, 8, \idx, 5, \car, 1000, \dur, 30]);
f.set(\amp1, 2);
f.set(\car, 440);
// idx must be a fraction to have an effect
f.set(\idx1, rrand(1,40));
f.free;

s.boot;

s.freeAll;

Shaper.ar

(
SynthDef.new(\waveshaper, {
	arg car, etc;
	var buff, sig;
	buff = Buffer.alloc(s, 512, 1, {
		arg buf;
		buf.chebyMsg([1,0,1,1,0,1]);
	});

	sig = Shaper.ar(buff, SinOsc.ar(car,0,Line.kr(0,0.6,6)), 0.5);

	sig = Splay.ar(sig,2);

	Out.ar(0,sig);
}).add;
)

y = Synth(\waveshaper, [\car, 330]);
y.free;


(
SynthDef.new(\customwaveshape, {
	arg freq=220, buff=0;
	var sig;
	sig = Shaper.ar(buff, SinOsc.ar(freq,0,Line.kr(0,0.6,6)), 0.5);

	sig = Splay.ar(sig,2);

	Out.ar(0,sig);
}).add;
)

///////////////////////////////////// buffered waveshape



///////////////////////////////////// configured waveshape
// config 6

~genvstr[~idx1eno] = "Env.adsr(0,1,0,1,4+(~vel*4.8),0)";
~genvstr[~idx2eno] = "Env.adsr(0,2,0,1,5.5+(~vel*1.5),0)";
~genvstr[~idx3eno] = "Env([10],[1])";
~genvstr[~idx4eno] = "Env.adsr(0,8,0,1,8.0,0)";
~genvstr[~idx5eno]= "Env([0],[1])";
~genvstr[~idx6eno] = "Env([10],[1])";
~genvstr[~levelAeno] = "Env.adsr(0,10,1,1,10,0)";
~genvstr[~levelBeno] = "Env.adsr(0,10,1,1,10,0)";
~genvstr[~filteno] = "Env([10],[1])";
~genvstr[~reseno] = "Env([0],[1])";


SinOsc.browse;

///////////////////////////////////// grainsin
// to create formants
// from alikthename on github

(

SynthDef.new(\gsin, {
	arg grainrate=1, level=0.3, freq = 440,
	 trigg, formA=2, formB=6, overA=2, overB=2, gate=1;
	var sig, ef, ef_, one, two, three, four, five, six, fund;

	ef = freq;

	ef_ = ef.clip.(50,1500);

	five = EnvGen.kr(
		Env.perc(
			attackTime: (ef_.linlin(50,1500,0.1,0.2)),
			releaseTime: Rand(1,7)
		),
		gate: gate
	);

	// add some pinknoise for naturalism
	five = five * PinkNoise.ar(1!2).range( 0.1, 1 ).lag(0.02) ;

	fund = GrainSin.ar(
		numChannels:1,
		trigger: Impulse.ar(ef),
		dur: Rand(0.5, 2) * (1.05 - five.pow(1.1))
		* SinOsc.ar(five * 3, {Rand(0,6.28)}.dup).range(0.87,1.15) / ef,

		freq: ef
		* SinOsc.ar(five * 3, {Rand(0,6.28)}.dup).range(0.9,1.5),

		pan: PinkNoise.ar(0.5!2)
	);

	// one and two are formants, same but with dif multipliers
	// and two more rdm
	one = GrainSin.ar(
		numChannels:1,
		trigger: Impulse.ar(ef + Rand(-3,3)),
		dur: overA * (1.05-five.pow(1.5))
		* SinOsc.ar(five * 4, {Rand(0,6.28)}.dup).range(0.87, 1.15) / ef,
		freq: ef * (formA
			* SinOsc.ar(five * 4, {Rand(0,6.28)}.dup).range(0.9,1.1)),
		pan: PinkNoise.ar(0.5!2)
	);
	two = GrainSin.ar(
		numChannels:1,
		trigger: Impulse.ar(ef + Rand(-3,3)),
		dur: overB * (1.05-five.pow(2.5))
		* SinOsc.ar(five * 6, {Rand(0,6.28)}.dup).range(0.87, 1.15) / ef,
		freq: ef * (formB
			* SinOsc.ar(five * 5, {Rand(0,6.28)}.dup).range(0.9,Rand(1,1.5))),
		pan: PinkNoise.ar(0.5!2)
	);

	three = Splay.ar([
		fund * (level * five).pow(0.7),
		one * (level * five).pow(ef_.linlin(50,1500,1.1,1.5)),
		two * (level * five).pow(ef_.linlin(50,1500,1.1,2.5))
	],2);

	three = LeakDC.ar(three);

	four = three;

	4.do({
		arg i;
		four = AllpassC.ar(
			in: four,
			delaytime: LFNoise1.kr(0.2!2).range(0.01,0.02)
		)
	} * 0.05);

	four = three * Rand(0.1,0.9) + four;

	DetectSilence.ar(four,doneAction:2);
	/*
	sig = GrainSin.ar(
		numChannels: 1,
		trigger: Impulse.kr(1),
		dur: 1,
		freq: fund
	);
	sig = Splay.ar(sig,2);
	*/

	Out.ar(0,four);

}).add;

)

s.boot;
(
y = Synth(\gsin, [\freq,440,
	\formB, 2.4, \formA, 8.4
]);
)

y.set(\fund, 340);
y.set(\grainrate, 660);
y.free;

s.options.memSize;

s.reboot;

s.freeAll;
