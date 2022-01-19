(
SynthDef.new(\config1_FB01,{
	// reminder that Select.ar selects from an array

	// A and B give the waveshape
	// triangles are indices
	// circles are oscillators
	// lines represent computation

	arg out=0, fund=440, vel=1
	shaper6=0, shaper5=0, shaper4=0,
	shaper3=0, shaper2=0, shaper1=0,
	mod1=220, idx1=1,
	mod3=220, idx3=1;
	var bigA, bigB, sig, modfreq=2, modamp=1, rEnv, filtEnv,
	sixEnv, fiveEnv, fourEnv, threeEnv, twoEnv, oneEnv, aEnv, bEnv,
	sixMsg, fiveMsg, fourMsg, threeMsg, twoMsg, oneMsg,
	sixOsc, fiveOsc, fourOsc, threeOsc, twoOsc, oneOsc,
	wsAbuf, wsBbuf, wsA, wsB;

	wsA = Signal.chebyFill(
		4096,
		0.25*[1,-1,-1,1] / (1..32), // "alt saw"
		normalize: true,
		zeroOffset:false
	).asWavetableNoWrap;
	wsAbuf = Buffer.loadCollection(s,wsA);

	wsB = Signal.chebyFill(
		4096,
		[1,1,-1,-1,0,1,0,-1,0,1,0,-1,0,0,0,1], // "full tonewheel"
		normalize: true,
		zeroOffset:false
	).asWavetableNoWrap;
	wsBbuf = Buffer.loadCollection(s,wsB);

	oneEnv = EnvGen.ar(Env.adsr(0,2,0,1,7.4+vel*(1.1),0));
	twoEnv = EnvGen.ar(Env.adsr(0,4,0.75,1,5+(vel*2.8),0));
	threeEnv = EnvGen.ar(Env([10],[1]));
	fourEnv = EnvGen.ar(Env.adsr(0,7,0.8,1,5.9,0));
	fiveEnv= EnvGen.ar(Env([0],[1]));
	sixEnv = EnvGen.ar(Env([10],[1]));
	aEnv = EnvGen.ar(Env.adsr(0,10,1,1,10,0));
	bEnv = EnvGen.ar(Env.adsr(0,10,1,1,10,0));
	filtEnv = EnvGen.ar(Env([10],[1]));
	rEnv = EnvGen.ar(Env([0],[1]));


	// B track

	bigB = pi*(2**((33/16)-((100-(10*aEnv))/8)))
	         * Shaper.ar(wsBbuf, sixMsg);

	// A track

	bigA = pi*(2**((33/16)-((100-(10*levelA))/8)))
	         * Shaper.ar(wsAbuf, threeMsg);


	sig = Splay([bigA,bigB], 2);

	Out(out, sig);

}).add;
)


s.reboot;

s.freeAll;

(
SynthDef.new(\config1a, {
	arg freq=220;
	var oneOsc,twoOsc,threeOsc,fourOsc,fiveOsc,sixOsc,
	oneEnv,twoEnv,threeEnv,fourEnv,fiveEnv,sixEnv,bigA,bigB;

	bigA = threeEnv *

}).add;
)