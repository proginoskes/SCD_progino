/***
* proginoskes
*
* this is a study of fm synthesis after
* a few days break from SCD
*
* the study uses John M Chowning's
* work cited at the bottom
*
*/

(
SynthDef(\fm_idxenv, {
	arg freq=440, mRatio=1, cRatio=1, modAmp=220, iScale=5,
	amp=0.2, atk=0.01, rel=3, pan=0, index=1, cAtk=(-4), cRel=4;
	var car, mod, env,ienv;
	ienv = EnvGen.kr(
		Env.new([index, index * iScale, index],
			[atk,rel],
			[cAtk, cRel]
		)
	);
	env = EnvGen.kr(Env.perc(atk,rel,curve:[cAtk,cRel]),doneAction:2);
	mod = SinOsc.ar(freq * mRatio, mul:freq * mRatio * ienv);
	car = SinOsc.ar(freq * cRatio + mod) * env * amp;
	car = Pan2.ar(car,pan);
	Out.ar(0,car);
}).add;
)

(
y = Synth(\fm_idxenv, [\freq, 55.midicps,
	\index, 20, \mRatio, 14,\cRatio, 9, \iScale,0.05, \cAtk, 4, \cRel, (-4),\index, 4,
	\rel, 1]);
)

// there is a right way and a wrong way to do
// fm synthesis this is maybe the right way?

(
SynthDef(\fm_syncro, {
	arg freq=220, modAmp=220, amp=0.2,
	mRatio=1, cRatio=1, idx=1, idx_scale=1,
	atk=0.01, rel=3, index=1, curveA=4, curveB=(-4), pan=0;
	var car, mod, env, indexEnv;

	indexEnv = EnvGen.kr(
		Env.new(
			[idx, idx * idx_scale, idx],
			[atk, rel],
			[curveA, curveB]
		)
	);

	env = EnvGen.kr(Env.perc(atk,rel,curve:[curveA,curveB]),doneAction:2);
	mod = SinOsc.ar(freq * mRatio, mul:freq * mRatio * LFNoise1.ar(indexEnv).range(0.9,1));
	car = SinOsc.ar(freq * cRatio + mod) * env * amp;
	car = Pan2.ar(car,pan);

	Out.ar(0,car);

}).add;
)



(
// a ratio of 1:3 mod:car
// gives a brass-like sound
y = Synth.new(\fm_syncro, [
	\freq, 70.midicps,
	\mRatio, 1, \cRatio, 3, \idx, 5,
	\rel, 9, \idx_scale, 0.4,
	\curveA, 2, \curveB, 6
])
)

(
// a ratio of 2:3 mod:car
// gives a clarinet-like sound
y = Synth.new(\fm_syncro, [
	\freq, 70.midicps,
	\mRatio, 2, \cRatio, 3, \idx, 5,
	\rel, 9, \idx_scale, 0.4,
	\curveA, 2, \curveB, 6
])
)

(
// a ratio of 1:5 mod:car
// gives a bassoon-like sound
y = Synth.new(\fm_syncro, [
	\freq, 30.midicps,
	\mRatio, 1, \cRatio, 5, \idx, 5,
	\rel, 9, \idx_scale, 0.4,
	\curveA, 2, \curveB, 6
])
)

(
// a ratio of 1:1.4 mod:car
// gives a "drum" sound
y = Synth.new(\fm_syncro, [
	\freq, 40.midicps,
	\mRatio, 1, \cRatio, 1.4, \idx, 25,
	\rel, 1, \idx_scale, 0.4,
	\curveA, 2, \curveB, 6
])
)


Scale.directory

(
p = Pbind(
	\instrument, \fm_syncro,
	\dur, 1/9,
	\freq, Prand(Scale.bhairav.degrees+70,inf).round(1).midicps,
	//\cRatio, Pwhite(2, 256).round(1),
	//\mRatio, Pexprand(2,256).round(1),
	\index, Pwhite(1,50),
	\curveB, Pwhite (-3, -12),
	\idx_scale, Pwhite(0.05, 20),
	\mRatio, 2, \cRatio, 3, \idx, 5,
	//\modAmp, Pexprand(100,1000),
	\amp, Pexprand(0.1,0.9),
	\atk, Pexprand(0.001,0.05),
	\rel, Pexprand(0.5, 2.0),
).play;

b = Pbind(
	\instrument, \fm_syncro,
	\dur, Pseq(#[ 0.22222222222222, 0.88888888888889, 0.33333333333333, 0.33333333333333, 0.77777777777778, 0.11111111111111, 0.11111111111111, 0.33333333333333 ],inf),
	\freq, Prand(Scale.bhairav.degrees+22,inf).round(1).midicps,
	//\cRatio, Pwhite(2, 256).round(1),
	//\mRatio, Pexprand(2,256).round(1),
	\index, Pwhite(1,50),
	\mRatio, 1, \cRatio, 3, \idx, 9,
	\curveB, Pwhite (-1, -5),
	\idx_scale, Pwhite(0.05, 20),
	//\modAmp, Pexprand(100,1000),
	\amp, Pwhite(0.4,0.9),
	\atk, Pexprand(0.001,0.05),
	\rel, Pexprand(0.5, 2.0),
).play;
)

(
b.stop;
p.stop;
)


// Chowning Implementation: basic
(
SynthDef(\chow_basic, {
	arg p4=1, p5=220, p6=220, p7=220;
	var ug1,ug2,ug3;

	ug1 = p7 * SinOsc.ar(p6);

	ug3 = p4 * SinOsc.ar(p5, add: ug1);

	//ug3 = LPF.ar(ug3, 440);

	ug3 = Pan2.ar(ug3,0);

	Out.ar(0,ug3);

}).add;
)

(
y = Synth(\chow_basic, [
	\p4, 1,
	\p5, 440,
	\p6, 1200,
	\p7, 4,
]);
)
y.free;
s.freeAll;


// P1 : begin time of instr
// P2 : instr number
// P3 : duration of note
// P4 : amp of output
// P5 : carFreq
// P6 : modFreq
// P7 : mod index 1 (->deviation 1)
// P8 : mod index 2 (->deviation 2)

// deviation 1:
// P7*P6

// deviation 2:
// (P8-P7)*P6


(
SynthDef(\fm_chow, {
	arg p1=0.01, p3=1, p4=0.7,
	p5=220, p6=220,
	p7=2, p8=8;
	var dev1, dev2,
	ug1, ug2, ug3, ug4, ug5, ug6;

	dev1 = p7*p6;
	dev2 = (p8-p7)*p6;

	// envelopes (fig 11)
	ug5 = EnvGen.kr(Env.new(
		[0,dev2,0.75*dev2,0],
		[0,p1,p3.reciprocal,p3],
	), doneAction:2);
	ug4 = EnvGen.kr(Env.new(
		[0,p4,0.75*p4,0],
		[0,p1,p3.reciprocal,p3],
	));

// oscs and additions
	ug6 = dev1 + ug5;
	ug1 = ug6 * SinOsc.ar(p6);
	ug2 = p5 + ug1;
	ug3 = ug4 * SinOsc.ar(ug2);

	ug3 = Pan2.ar(ug3,0);


	Out.ar(0,ug3);
}).add;
)

(
// "Brass-Like Tones"
y = Synth(\fm_chow, [
	\p3, 0.6,
	\p4, 1,
	\p5, 440,
	\p6, 440,
	\p7, 0,
	\p8, 5
]);
)


(
// "Clarinet-Like Tones"
y = Synth(\fm_chow, [
	\p3, 0.6,
	\p4, 1,
	\p5, 900,
	\p6, 300,
	\p7, 0,
	\p8, 2
]);
)

(
// "Bassoon-Like Tones"
y = Synth(\fm_chow, [
	\p3, 0.6,
	\p4, 1,
	\p5, 500,
	\p6, 100,
	\p7, 0,
	\p8, 1.5
]);
)

(
// "AnotherReed-Like Tones"
y = Synth(\fm_chow, [
	\p3, 0.6,
	\p4, 1,
	\p5, 900,
	\p6, 600,
	\p7, 0,
	\p8, 1.5
]);
)

(
// "Wooddrum-Like Tones"
y = Synth(\fm_chow, [
	\p3, 15,
	\p4, 1,
	\p5, 200,
	\p6, 280,
	\p7, 0,
	\p8, 10
]);
)

(
// "Wooddrum-Like Tones"
y = Synth(\fm_chow, [
	\p3, 0.2,
	\p4, 1,
	\p5, 80,
	\p6, 55,
	\p7, 0,
	\p8, 25
]);
)


s.freeAll;

// fig 17
// an FM circuit which allows formants
// at any arbitrary point

(
SynthDef(\fm_chow_xr, {
	arg p1=0.01, p3=1, p4=0.7,
	p5=220, p6=220,
	p7=2, p8=8,
	p10=1, p11=1, p12=500;
	var dev1, dev2,
	ug1, ug2, ug3, ug4, ug5, ug6,
	// 4->7 1->8;
	ug7, ug8, ug9, ug10, ug11,
	//ug12, ug13, ug14, ug15,
	sig;

	dev1 = p7*p6;
	dev2 = (p8-p7)*p6;

	// envelopes (fig 11)
	ug5 = EnvGen.kr(Env.new(
		[0,dev2,0.75*dev2,0],
		[0,p1,p3.reciprocal,p3],
	), doneAction:2);
	ug4 = EnvGen.kr(Env.new(
		[0,p4,0.75*p4,0],
		[0,p1,p3.reciprocal,p3],
	));

	// oscs and additions
	ug6 = dev1 + ug5;
	ug1 = ug6 * SinOsc.ar(p6);
	ug2 = p5 + ug1;
	ug3 = ug4 * SinOsc.ar(ug2);

	// oscs for formant
	ug8 = ug1 * p11;
	ug9 = ug8 + p12;
	ug7 = p10 * ug4;
	ug10 = SinOsc.ar(ug9, mul: ug7);

	ug11 = ug3 + ug10;

	sig =LeakDC.ar(ug11);

	sig = Pan2.ar(sig,0);

	Out.ar(0,sig);
}).add;
)

(
//
y = Synth(\fm_chow_xr, [
	\p3, 0.2,
	\p4, 1,
	\p5, 250,
	\p6, 250,
	\p7, 1,
	\p8, 3,
	\p10, 0.2,
	\p11, 0.5,
	\p12, 2100
]);
)


/*
CHOWNING, JOHN M. “The Synthesis of Complex Audio
Spectra by Means of Frequency Modulation.” Computer
Music Journal 1, no. 2 (1977): 46–54.
http://www.jstor.org/stable/23320142.
*/
