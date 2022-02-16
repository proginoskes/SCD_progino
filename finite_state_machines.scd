// this scrip we will explore envelopes using a very simple synth

(
SynthDef(\fm_syncro, {
	arg freq=220, modAmp=220, amp=0.2, envChoice=0, soundChoice=0, gate=0,
	mRatio=1, cRatio=1, idx=1, idx_scale=1, passFreq=2000, passType=1,
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
	car = BMoog.ar(car, passFreq, 0.2, passType);
	car = Pan2.ar(car,pan);

	Out.ar(0,car);

}).add;
)

// now we will look into Pfsm, a finite state machine pattern generator

( // from Pfsm ctrl+d
a = Pfsm([
        #[0,1],
        67, #[0, 0, 3],
        72, #[2],
        73, #[0, 2],
        Pseq([74, 75, 76, 77]), #[2, 3, 3],
        nil, nil
    ], inf).asStream;
Routine({
    loop({
        Synth(\fm_syncro, [\freq, a.next.midicps]);
        0.1.wait;
    })
}).play;
)

( // also from Pfsm ctrl+d
p = Pfsm([
    #[1, 2, 3], // entry states

    //e1 (== state 0)
    Pbind( \dur, Pseq([ 1/8, 3/8 ]), \midinote, Pseq([ 86, 75 ]) ),
    //#[1],    // as given in CMJ
    // my de-boredom-ated version..
    #[1, 1, 1, 1, 1, 1, 1, 8],
    //e2 (== state 1)
    Pbind( \dur, 1/2, \midinote, Pseq([ 69 ]) ),
    #[0, 1],
    //e3 (== state 2)
    Pbind( \dur, 1/3, \midinote, Pseq([ 55, 60, 66 ]) ),
    #[0, 1, 2, 2, 2, 2, 3, 3, 3, 3],
    //e4 (== state 3)
    Pbind( \dur, 1/4, \midinote, Pseq([ 81, 80, 77, 76 ]) ),
    #[1, 4, 4, 4, 4],
    //e5 (== state 4)
    Pbind( \dur, Pseq([1, 2/3, 2/3, 2/3, 1]), \midinote, Pseq([ \, 70, 70, 70, \ ]) ),
    #[2, 3],
    //e6 (== state 5)
    Pbind( \dur, 1/4, \midinote, Pseq([ 59, 61 ]) ),
    #[0, 2, 4, 5, 5, 5, 5, 5, 5, 5],
    //e7 (== state 6)
    Pbind( \dur, 1/4, \midinote, Pseq([ 87, 88 ], 2) ),
    #[4, 4, 4, 4, 6, 6, 6, 7, 7, 7],
    //e8 (== state 7)
    Pbind( \dur, 1, \midinote, Pseq([ 56 ]) ),
    #[1, 3, 6, 6, 6],
    // terminal state
    nil, nil
]).play;
)


( // also from Pfsm ctrl+d
p = Pfsm([
    #[1, 2], // entry states

    //e1 (== state 0)
    Pbind(
		\dur, Pseq([Rest(1/2), 1/2, Rest(1/4), 3/4]),
		\instrument, \fm_syncro,
		\cRatio, 1, \mRatio, 4,
		\freq, Prand(Scale.bhairav.degrees+70, inf).midicps,
	),
    //#[1],    // as given in CMJ
    // my de-boredom-ated version..
    #[1, 1, 1, 1, 1, 1, 1, 2],
    //e2 (== state 1)
    Pbind(
		\dur, Pseq([Rest(1/2), 1/2, Rest(1/4), 3/4]),
		\instrument, \fm_syncro,
		\cRatio, 1, \mRatio, 4,
		\freq, Prand(Scale.bhairav.degrees+30, inf).midicps,
	),
    #[0, 1],
    // terminal state
    Pbind(
		\dur, Pseq([Rest(1/2), 1/2, Rest(1/4), 3/4]),
		\instrument, \fm_syncro,
		\cRatio, 0.85, \mRatio, 1,
		\freq, Prand(Scale.bhairav.degrees+60, inf).midicps,
	), nil
]).play;
)

p.stop

