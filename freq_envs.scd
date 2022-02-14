// this scrip we will explore envelopes using a very simple synth

(
SynthDef(\fm_syncro, {
	arg freq=220, modAmp=220, amp=0.2, envChoice=0, soundChoice=2, gate=0,
	mRatio=1, cRatio=1, idx=1, idx_scale=1,
	atk=0.01, rel=3, index=1, curveA=4, curveB=(-4), pan=0;
	var car, mod, env, indexEnv, carEnv;

	indexEnv = EnvGen.kr(
		Env.new(
			[idx, idx * idx_scale, idx],
			[atk, rel],
			[curveA, curveB]
		)
	);

	carEnv = Select.kr(soundChoice,
		[
			1,
			EnvGen.kr(Env.new([0.1, 2, 0.1], [atk+rel/2,atk+rel/2], [5,-5])),
			EnvGen.kr(Env.new([0.1, 0.75, 1,2,1,0.75, 0.1], [atk+rel/3,rel/6,rel/20,rel/20,rel/6,atk+rel/3].normalizeSum(atk+rel)))
		]
	);
	env = Select.kr(envChoice, [
		EnvGen.kr(Env.perc(atk,rel,curve:[curveA,curveB]),doneAction:2)
	]);
	mod = SinOsc.ar(freq * mRatio, mul:freq * mRatio * LFNoise2.ar(indexEnv).range(0.9,1));
	car = SinOsc.ar(carEnv * freq * cRatio + mod) * env * amp;
	car = Pan2.ar(car,pan);

	Out.ar(0,car);

}).add;
)


Env.new([0.1, 0.75, 1,2,1,0.75, 0.1], [0.1+1/3,1/6,1/20,1/20,1/6,0.1+1/3]).plot

(
y = Synth.new(\fm_syncro, [
	\mRatio, 1, \cRatio,11, \idx, 90,
	\atk, 1, \rel, 1,
	\idx_scale, 5,
	\curveA, 2, \curveB, -6,
	\soundChoice, 2
])
)
y.free;


(instrument:\fm_syncro,freq:70.midicps).play;

(
p = Pbind(
	\dur, 1/3,
	\freq, Prand(Scale.major.degrees + 70,inf).midicps,
	\instrument, \fm_syncro,
	\soundChoice, Prand([0,1,2],inf),
	\mRatio, 1, \cRatio,11, \idx, 90,
	\idx_scale, 5,
	\curveA, 2, \curveB, -6,
	\atk, 0.9, \rel, 0.001,
	\pan, Pwhite(-2,2,inf)
).play;
)

p.stop;
