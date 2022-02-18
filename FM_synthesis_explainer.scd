// the frequency modulation equation is:
// y(t) = Asin(2pi * car * t + Isin(2pi * mod * t))
// where
//       y(t) <- the output signal
//       t    <- the time
//       A    <- the amplitude of the output signal
//       car  <- the frequency of the output signal
//       I    <- the amplitude of the modulating signal
//                 (the maximum value it adds/subtracts each period)
//       mod  <- the frequency of modulation
//                 (the number of times per second that the modulation cycles)
//
// In essence, frequency modulation is about rapidly and periodically
// changing the rate of a primary signal so that we can use it to express
// a wider variety of sounds.
//
// Changing the modulation index will alter the extent to which the pitch
// changes each modulation cycle. Changing the modulation frequency changes
// the rate at which the pitch changes. This is essentially a digitized form
// of vibrato.
//
// Because this is such a mathematical operation, we could not achieve FM
// synthesis on a wide scale without widespread adoption of the digital synthesizer.
// For most of the 20th century, the analog synth using additive and subtractive
// synthesis allowed for a wide array of sounds, though one had to add a large
// number of synthesizers together to get a sound "just right". With digital
// FM synthesis, all we need to do is change the rate or extent of vibrato
// in the right way, and we can make just about any timbre of sound.




({a = SinOsc.ar(440, 0, 0.2)}.plot;
{b = SinOsc.ar(880,0,0.2)}.plot;

// additive synthesis, could go on any number of times. can only add entire wave
// generators because we are using analog synthesis
// we add formants (overtones/higher frequencies) to the carrier (lowest) frequency
// to get the right sound
{c = SinOsc.ar(440,0,0.2) + SinOsc.ar(880,0,0.125) + SinOsc.ar(1760,0,0.1)!2}.plot;


// FM synthesis,
// where we add directly to the carrier frequency
// a multiple of the extent of change every portion of the cycle
{d = SinOsc.ar(440 + (1760 * SinOsc.ar(880)))!2}.plot;


// shown together:
{e = [SinOsc.ar(440,0,0.2) + SinOsc.ar(880,0,0.125) + SinOsc.ar(1760,0,0.1),SinOsc.ar(440 + (1760 * SinOsc.ar(880)),0,0.2)]}.plot;

{f = SinOsc.ar(440 + (30 * SinOsc.ar(8)))!2}.scope

)


s.boot
s.quit
s.freeAll

// ADDITIVE SYNTH




//FM SYNTH

(
SynthDef(\fm_sample, {
	arg freq=440, modFreq=10, modIdx=10;
	var sigCar, sigMod, sigOut;
	sigMod = modIdx * SinOsc.ar(modFreq);
	sigCar = SinOsc.ar(freq + sigMod);
	sigOut = Pan2.ar(sigCar);
	Out.ar(0,sigOut);
}).add;
)

a = (instrument: \fm_sample, freq:220, modFreq: 440, modIdx: 660).play;
a.free;

(
a = Synth(\fm_sample, [
	\freq, 220,
	\modFreq, 220, \modIdx,220,
])
)
a.free;


Out.ar(0,PlayBuf.ar(2, ~wtbufnums[2])).play


// bonus: WAVETABLE
// we can change the place the wavetable goes in
// the synth to have it modify different aspects
// of the sound
//
// need to have wavetables added from startup file
(
SynthDef(\fm_wavetable, {
	arg freq=440, atk=0.01, rel=2,
	curveA=5, curveB=(-6),
	carRatio = 1, amp=0.6,
	modRatio=10, modIdx=10, modIdxScale = 1,
	wtIdx=1, wtRatio=0.01, wtIdxScale = 1;
	var sigCar, sigMod, sigOut, sigWT,
	wtIndexEnv, modIndexEnv, env,
	wtFreq, modFreq, carFreq;

	wtIndexEnv = EnvGen.kr(
		Env.new(
			[wtIdx, wtIdx *  wtIdxScale, wtIdx],
			[atk, rel],
			[curveA, curveB]
		)
	);

	modIndexEnv = EnvGen.kr(
		Env.new(
			[modIdx, modIdx *  modIdxScale, modIdx],
			[atk, rel],
			[curveA, curveB]
		)
	);

	carFreq = freq * carRatio;
	modFreq = freq * modRatio;
	wtFreq = freq * wtRatio;


	env = EnvGen.kr(Env.perc(atk,rel,curve:[5,-6]),doneAction:2);

	sigWT = (wtIndexEnv * wtFreq) * PlayBuf.ar(1, ~wtbufnums[47], rate:wtFreq, loop:1);
	sigMod =  (modIndexEnv  * modFreq + sigWT) * SinOsc.ar(modFreq);
	sigCar = env * amp * SinOsc.ar(freq + sigMod + sigWT);
	sigOut = Pan2.ar(sigCar);
	Out.ar(0,sigOut);
}).add;
)

(
// drum
a = Synth(\fm_wavetable, [
	\freq,30.midicps,
	\wtRatio, 0.7, \wtIdx, 2, \wtIdxScale, 5,
	\modRatio, 0.55, \modIdx, 2, \modIdxScale, 5,
	\carRatio, 0.85, \amp, 0.5
])
)

(
// weird clarinet/oboe
a = Synth(\fm_wavetable, [
	\freq,50.midicps,
	\wtRatio, 0.2, \wtIdx, 1, \wtIdxScale, 5,
	\modRatio, 5, \modIdx, 1, \modIdxScale, 3,
	\carRatio, 1, \amp, 0.5,
	\atk, 0.1, \rel, 3
])
)

(
// weird clarinet/oboe
a = Synth(\fm_wavetable, [
	\freq,50.midicps,
	\wtRatio, 0.2, \wtIdx, 1, \wtIdxScale, 5,
	\modRatio, 3, \modIdx, 1, \modIdxScale, 3,
	\carRatio, 2, \amp, 0.5,
	\atk, 0.1, \rel, 3
])
)



(
~instruments = (
	guitar: Pbind(
		\dur, Pseq([1/2, Rest(1/2),1/4, Rest(1/4)],inf)/1,
		\instrument, \fm_wavetable,
		\freq, Pseq([
			Pn((Scale.maj7.degrees+50).midicps , 4),
			Pn((Scale.dom7.degrees+54).midicps , 4),
			Pn((Scale.maj7.degrees+55).midicps , 4),
			Pn((Scale.dom7.degrees+45).midicps , 4)
		],inf),//Pseq((Scale.major.degrees ++ Scale.bhairav.degrees.reverse + 60).midicps,inf),
		\wtRatio, 1.2, \wtIdx, 1, \wtIdxScale, 1.2,
		\modRatio, 4, \modIdx,0.3,\modIdxScale, 1.2,
		\atk, 0.01, \rel, 0.5
	)
)
)

y = Psym(Prand(#[[guitar]], inf), ~instruments).play;

y.stop;

y.stop;

s.freeAll;

s.freeAll
a.free
