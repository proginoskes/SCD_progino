// thoughtbot Making Music with SuperCollider (Edward)

SynthDef(
	\blip,
	{
		|freq|
		var env = Env.perc(level:0.1, releaseTime:0.2).kr(doneAction: Done.freeSelf);
		var sig = Pulse.ar(freq:440, width: 0.05) * env;
		Out.ar(0, [sig, sig])
	}
).add;

Synth(\blip, 442);

{Pulse.ar( freq: 440, mul:0.1, width:0.5)}.play

Env.perc(releaseTime:0.2).test.plot;

{
	var env = Env.perc(level:0.1, releaseTime:0.2).kr(doneAction: Done.freeSelf);
	Pulse.ar(freq:440, width: 0.05) * env
}.play;

s.freeAll;