// this is just a heavily-enveloped fm synth


s.freeAll

(
/*
this synthdef has cusomizable/callable envelopes, which allows
more control over what sound it makes at which moment of attack

>>>>>>>>>>>>>>>>>>>> global params <<<<<<<<<<<<<<<<<<<<<<<<<<<<
    amp: the limit amplitude of the output signal
    out: the bus for output, default to 0, but can be
         used to route to another synth/ugen
         (reverb, fx, etc)
    freq: the primary frequency, not necessarily carrier freq
    pan: location of output (-1:left;1:right)


>>>>>>>>>>>>>>>>>>>> amplitude params <<<<<<<<<<<<<<<<<<<<<<<<<
    atk, dec, sus, rel:
        the time between the previous event and the target. in
        this case:
        [atk] is the time from 0 to the first amplitude
        [dec] is the time the first amplitude to the first sustain
        [sus] is the time from the first sustain level to the last
        [rel] is the time from the last sustain to the end
    atk_level: the fraction amplitude of attack, default to 1
    sustain_levelA: the fraction of the limit amp that sustain
                    begins at
    sustain_levelB: the fraction of the limit amp that sustain
                    ends at, default equal to level A for flat
                    sustain
    rel_level: the fraction amplitude of release, default to silent
    curveAtk, curveDec,curveSus,curveRel:
        the curvature (derivative of slope) of the transition
        from one envelope value to the next. when a float, this
        is the derivative of the slope.
        it could also be a description of the shape, as in
        [\step, \hold, \lin, \exp, \sin, \wel, \sqr, \cub]

*/

SynthDef(\fm_adsr,{
	arg
	// globals
	amp=0.5, out=0,freq=220, pan=0,

	// shared envelope values
	atk=0.1, dec=0.3, sus=0.2, rel=0.3,

	// amplitude envelope values
	atk_level=1, rel_level=0,
	sustain_levelA=0.75, sustain_levelB=0.75,
	curveAtk=1,curveDec=1,curveSus=1,curveRel=1,

	// fundamental frequency envelope values
	fund_init_level=1,
	fund_atk_level=1, fund_rel_level=1,
	fund_sustain_levelA=1, fund_sustain_levelB=1,
	fund_curveAtk=0,fund_curveDec=0,fund_curveSus=0,fund_curveRel=0,

	// carrier frequency envelope values
	car_init_level=1,
	car_atk_level=1, car_rel_level=1,
	car_sustain_levelA=1, car_sustain_levelB=1,
	car_curveAtk=0,car_curveDec=0,car_curveSus=0,car_curveRel=0,

	// modulation frequency envelope values
	mod_init_level=1,
	mod_atk_level=1, mod_rel_level=1,
	mod_sustain_levelA=1, mod_sustain_levelB=1,
	mod_curveAtk=0,mod_curveDec=0,mod_curveSus=0,mod_curveRel=0,

	// modulation frequency envelope values
	modIdx_init_level=1,
	modIdx_atk_level=1, modIdx_rel_level=1,
	modIdx_sustain_levelA=1, modIdx_sustain_levelB=1,
	modIdx_curveAtk=0,modIdx_curveDec=0,modIdx_curveSus=0,modIdx_curveRel=0,


	// modulation-related frequency values
	cRatio=1, mRatio=0,

	// mod index values
	modIdx=0, modIdxScale=0

	;


	var
	// signals
	sigOut, sigCar, sigMod,

	envAmp, envFund, envCar, envMod, envModIdx,
	// frequency values
	fundFreq, carFreq, modFreq;

	// // // envelope region // // //

	// amplitude envelope
	envAmp = EnvGen.ar(
		Env.new(
			times: [atk,dec,sus,rel],
			levels:[0, atk_level*amp,sustain_levelA*amp, sustain_levelB*amp, rel_level*amp],
			curve: [curveAtk,curveDec,curveSus,curveRel]),
		doneAction:2
	);

	// fundamental frequency envelope (multiplier values)
	envFund = EnvGen.ar(
		Env.new(
			times: [atk,dec,sus,rel],
			levels:[fund_init_level, fund_atk_level,fund_sustain_levelA, fund_sustain_levelB, fund_rel_level],
			curve: [fund_curveAtk,fund_curveDec,fund_curveSus,fund_curveRel])
	);

	// carrier frequency envelope (multiplier values)
	envCar = EnvGen.ar(
		Env.new(
			times: [atk,dec,sus,rel],
			levels:[car_init_level, car_atk_level,car_sustain_levelA, car_sustain_levelB, car_rel_level],
			curve: [car_curveAtk,car_curveDec,car_curveSus,car_curveRel])
	);

	// modulating frequency envelope (multiplier values)
	envMod = EnvGen.ar(
		Env.new(
			times: [atk,dec,sus,rel],
			levels:[mod_init_level, mod_atk_level,mod_sustain_levelA, mod_sustain_levelB, mod_rel_level],
			curve: [mod_curveAtk,mod_curveDec,mod_curveSus,mod_curveRel])
	);

	// modulating index envelope (multiplier values)
	envModIdx = EnvGen.ar(
		Env.new(
			times: [atk,dec,sus,rel],
			levels:[modIdx_init_level, modIdx_atk_level,modIdx_sustain_levelA, modIdx_sustain_levelB, modIdx_rel_level],
			curve: [modIdx_curveAtk,modIdx_curveDec,modIdx_curveSus,modIdx_curveRel])
	);

	// this allows us to control the fundamental with an env
	fundFreq = envFund * freq;

	modFreq = envMod * mRatio * fundFreq;
	carFreq = envCar * cRatio * fundFreq;

	sigMod = envModIdx * modIdx * modFreq * SinOsc.ar(modFreq);

	sigCar = SinOsc.ar((carFreq) + sigMod);

	// these should stay relatively constant
	sigOut = envAmp * sigCar;
	sigOut = Pan2.ar(sigOut,pan);
	Out.ar(out,sigOut);
}
).add;
)


(
// funk bass light
m = Synth.new(\fm_adsr, [
	\freq, 50.midicps,
	\dec,0.5,
	\sus,0.1,
	\mRatio, 5,
	\cRatio, 1,
	\mod_sustain_levelA, 1.1,
	\modIdx_sustain_levelA, 9,
	\modIdx, 10,
]
);
)
m.free;