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
			EnvGen.kr(Env.new([0.1, 0.75, 1,2,1,0.75, 0.1], [atk+rel/3,rel/6,rel/20,rel/20,rel/6,atk+rel/3].normalizeSum(atk+rel))),

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
	\freq, (Scale.dom7.degrees + 70).midicps,
	\mRatio, 3, \cRatio,2, \idx, 90,
	\atk, 0.1, \rel, 2,
	\idx_scale, 5,
	\curveA, 2, \curveB, -2,
	\soundChoice, 0
])
)
y.free;


(Scale.dom7.degrees + 70).midicps
(instrument:\fm_syncro,freq:(Scale.dom7.degrees + 70).midicps, soundChoice:2).play;

s.boot;
s.record;
s.stopRecording;

(
p = Pbind(
	\dur, Pwrand(#[0.125, 0.25, 0.5], #[0.3, 0.5, 0.2], inf),
	\instrument, \fm_syncro,
	\degree, Pseq([Scale.min7.degrees, Scale.min7.degrees, Scale.dom7.degrees, Scale.maj7.degrees,Scale.maj7.degrees],inf),
	\root, Pseq([65,70, 63, 68, 61],inf)-36,
	\soundChoice, Prand([0],inf),
	\mRatio, 1, \cRatio,5, \idx, 2,
	\idx_scale, 2,
	\curveA, 5, \curveB, -6,
	\atk, Pseq([0.001,0.005],inf), \rel, Prand([0.001,0.9, 0.001,0.3,0.03],inf),
	\pan, Pseq([-1,-0.75,-0.5,-0.25,0,0.25,0.5,0.75,1],inf)*Pwhite(-1,1,inf)
).play;
)

p.stop

(
p = Pbind(
	\dur, 1/7,
	\instrument, \fm_syncro,
	\degree, Pseq([Scale.min7.degrees, Scale.min7.degrees, Scale.dom7.degrees, Scale.maj7.degrees,Scale.maj7.degrees],inf),
	\root, Pseq([65,70, 63, 68, 61],inf),
	\soundChoice, Prand([0],inf),
	\mRatio, 1, \cRatio,5, \idx, 2,
	\idx_scale, 2,
	\curveA, 5, \curveB, -6,
	\atk, Pseq([0.001],inf), \rel, Prand([0.001],inf),
	\pan, Pseq([-1,-0.75,-0.5,-0.25,0,0.25,0.5,0.75,1],inf)*Pwhite(-1,1,inf)
).play;
)

(
p = Pbind(
	\dur, 5/7,
	\instrument, \fm_syncro,
	\degree, Pseq([Scale.min7.degrees, Scale.min7.degrees, Scale.dom7.degrees, Scale.maj7.degrees,Scale.maj7.degrees],inf),
	\root, Prand([65,70, 63, 68, 61],inf),
	\soundChoice, Prand([0],inf),
	\mRatio, 3, \cRatio,1, \idx, 111,
	\idx_scale, 4,
	\curveA, 1, \curveB, -6,
	\atk, Pseq([0.01],inf), \rel, Prand([1],inf),
	\pan, Pseq([-1,-0.75,-0.5,-0.25,0,0.25,0.5,0.75,1],inf)*Pwhite(-1,1,inf)
).play;
)

p.stop

Scale.directory

// must use \instrument not \instr
(
~rhythmSection = (
	melody1: Pbind(
		\dur, Prand([Rest(1/64),1/16,1/16,Rest(1/2),1/7],16),
		\instrument, \fm_syncro,
		\freq,
			Prand(Scale.sixNine.degrees+70,4).midicps,
		\mRatio, 3, \cRatio, 5,
		\idx, 3,\idx_scale, 3,
		\curveA, 4, \curveB, -3,
		\amp, 0.2,
		\atk, 0.5, \rel, 1,
		\soundChoice, 0,
		\pan, Pwhite(-1,1)
	),

	melody2: Pbind(
		\dur, Prand([Rest(1/64),1/16,1/16,Rest(1/2)],16),
		\instrument, \fm_syncro,
		\freq,
			Prand(Scale.sixNine.degrees+68,4).midicps,
		\mRatio, 3, \cRatio, 5,
		\idx, 3,\idx_scale, 3,
		\curveA, 4, \curveB, -3,
		\amp, 0.2,
		\atk, 0.5, \rel, 1,
		\soundChoice, 0,
		\pan, Pwhite(-1,1)
	),
	kick: Pbind(
	\dur, Pseq([1/4,Rest(1),1/4,Rest(2/4)],1),
	\instrument, \fm_syncro,
	\freq, [40,5].midicps,
	\mRatio, 1, \cRatio,[0.85,86], \idx, 2,
	\idx_scale, 1,
	\curveA, 5, \curveB, -6,
	\amp, [0.8,0.3],
	\atk, 0.01, \rel, 0.9,
	\soundChoice, 0,
		\pan, [-0.7,0.7]
	),
	bubble:  Pbind(
	\dur, Pseq([Rest(1/2),1/2],2),
	\instrument, \fm_syncro,
	\freq, Pseq([[40,35],[40,45],[40,35],[43,47],[48,49]]).midicps,
	\mRatio, 11, \cRatio,55, \idx, 2,
	\atk, 0.001, \rel, 0.1,
	\idx_scale, 2,
	\curveA, 5, \curveB, -6,
	\soundChoice, 2,
	\amp, 0.3,
		\pan, [-0.3,0.3]
	),
	claves1: Pbind(
		\dur, Pseq([1/8],16),
	\instrument, \fm_syncro,
	\freq, [56,66].midicps,
	\mRatio, 22, \cRatio,5, \idx, 2,
	\atk, 0.001, \rel, 0.09,
	\idx_scale, 1,
	\curveA, 5, \curveB, -6,
	\soundChoice, 0,
		\pan,[-0.2,0.2]
	),
	claves2: Pbind(
	\dur, Prand([1/64],128),
	\instrument, \fm_syncro,
	\freq, [33,45].midicps,
	\mRatio, 11, \cRatio,55, \idx, 32,
	\atk, 0.001, \rel, 0.05,
	\idx_scale, 2,
	\curveA, 10, \curveB, -6,
	\soundChoice, 0,
	\amp, 0.11,
		\pan, [-0.1,0.1]
	)
);
)

p = Psym(Pseq(#[[melody2, kick, bubble, claves1], [melody2,melody1,kick, bubble], [kick,bubble,claves1,claves2,melody1]], inf), ~rhythmSection).play;

p.stop

~rhythmSection.play;

(
(
~clavesI = ~clavesI.play;
~clavesII = ~clavesII.play;
~snare=~snare.play;
~kick = ~kick.play;
);
)

(~clavesI.stop; ~clavesII.stop;~kick.stop;~snare.stop);

(
~timbre = Pbind(
	\instrument, \fm_syncro,
	\mRatio, 1, \cRatio,0.85, \idx, 2,
	\idx_scale, 1,
	\curveA, 5, \curveB, -6,
	\amp, 0.7,
	\atk, 0.01, \rel, 0.9,
	\soundChoice, 0
);
~melody = Pbind(
	\dur, Prand([1/7, 1/3.5],inf),
	\freq, Pif(Pkey(\dur) > 0.25, Prand([30,33,36].midicps,inf),  Prand([45,55].midicps,inf))
);
)

Pkey

(
~timbre.source = Pbind(
	\instrument, \fm_syncro,
	\freq, 56.midicps,
	\mRatio, 22, \cRatio,5, \idx, 2,
	\atk, 0.001, \rel, 0.09,
	\idx_scale, 1,
	\curveA, 5, \curveB, -6,
	\soundChoice, 0
)
)

p = Pchain(~melody, ~timbre).play;

p.play;
p.stop;


//percussion
(//claves
c = Synth.new(\fm_syncro, [
	\freq, 56.midicps,
	\mRatio, 22, \cRatio,5, \idx, 2,
	\atk, 0.001, \rel, 0.09,
	\idx_scale, 1,
	\curveA, 5, \curveB, -6,
	\soundChoice, 0])
)
(
// bass
b = Synth.new(\fm_syncro, [
	\freq, 34.midicps,
	\mRatio, 1, \cRatio,5, \idx, 2,
	\atk, 0.001, \rel, 0.9,
	\idx_scale, 1,
	\curveA, 5, \curveB, -6,
	\soundChoice, 0])
)
(
// kick
k = Synth.new(\fm_syncro, [
	\freq, 40.midicps,
	\mRatio, 1, \cRatio,0.85, \idx, 2,
	\atk, 0.001, \rel, 0.9,
	\idx_scale, 1,
	\curveA, 5, \curveB, -6,
	\soundChoice, 0])
)
(
// bell
d = Synth.new(\fm_syncro, [
	\freq, 111.midicps,
	\mRatio, 1, \cRatio,0.85, \idx, 2,
	\atk, 0.001, \rel, 0.9,
	\idx_scale, 1,
	\curveA, 5, \curveB, -6,
	\soundChoice, 0])
)
(
// cup
d = Synth.new(\fm_syncro, [
	\freq, 40.midicps,
	\mRatio, 11, \cRatio,55, \idx, 2,
	\atk, 0.001, \rel, 0.1,
	\idx_scale, 2,
	\curveA, 5, \curveB, -6,
	\soundChoice, 2])
)

p.stop;

s.boot;



p.stop;

