// more fun with fm synthesis and waveshaping



(
SynthDef.new(\fmw, {
	arg out=0, time=1, dyn=0.8,
	freq=220, wsStart=220;
	var sig, oscs,
	fmod0, fmod1, fmod2, fmod3, env, wsbuf;

	//wsbuf = 8.collect{arg num; wsStart + num;};
	//
	wsbuf = wsStart;
	env = EnvGen.ar(Env.perc(0.01, time, dyn, -3.0));
	//env = EnvGen.ar(Env.adsr());

	fmod0 = GrainSin.ar(freq:freq,envbufnum:wsStart);


	//fmod1 = {VarSaw.ar(freq, fmod0)
	//	- LFNoise1.ar(freq).reciprocal}!8;
	fmod1 = VarSaw.ar(freq, fmod0);

	fmod2 = 2 * VarSaw.ar(fmod1);

	fmod3 = VarSaw.ar(fmod2);

	oscs = SinOsc.ar(freq,fmod3/(time*2));

	sig = Shaper.ar(wsbuf,oscs);
	//sig = LeakDC.ar(VerbEF.ar(sig));

	sig = LeakDC.ar(sig);

	sig = env * Splay.ar(sig,8);

	sig = Pan2.ar(sig,SinOsc.ar(freq));

	sig.do{arg gn, i; DetectSilence.ar(gn, doneAction:2)};

	Out.ar(out,sig)
}).add;
)

y = Synth(\fmw,[\freq, 44, \wsStart, 399, \dyn, 0.1, \time, 4]);

(
~chorus1 = Pdef(\chorale1,
	Pbind(
		\dur, 21/7,
		\instrument, \fmw,
		\wsStart, 397,
		\dyn, 0.8, \time, 21/7,
		\freq, Prand((Scale.jiao.degrees+2).midicps,inf)
	)
);

~chorus2 = Pdef(\chorale2,
	Pbind(
		\dur, 1/6,
		\instrument, \fmw,
		\wsStart, 399,
		\dyn, 0.4, \time, 1/6,
		\freq, Prand((Scale.jiao.degrees+24).midicps,inf)
	)
);

~chorus3 = Pdef(\chorale3,
	Pbind(
		\dur, Pseq([1,0.2,0.3,1,2],inf),
		\instrument, \fmw,
		\wsStart, 399,
		\dyn, Pseq([0,0.4],inf), \time, Pseq([1,0.2,0.3,1,2],inf),
		\freq, Prand((Scale.jiao.degrees+48).midicps,inf)
	)
);
)

(
~chorus1.stop;
~chorus2.stop;
~chorus3.stop;
)

s.freeAll;

(
~chorus1.play;
~chorus2.play;
~chorus3.play;
)


s.options.memSize = s.options.memSize * 2;

s.options.blockSize = s.options.blockSize * 2;

s.boot;

s.freeAll;

