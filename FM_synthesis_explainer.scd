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

// additive synthesis, could go on any number of times. can only add ugens
// because we are using analog synthesis
// we add formants to the carrier (lowest) frequency
{c = SinOsc.ar(440,0,0.2) + SinOsc.ar(880,0,0.125) + SinOsc.ar(1760,0,0.1)!2}.plot;


// FM synthesis, where we add to the carrier frequency
// an extent of deviation multiplied by a ugen changes at the rate of deviation
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