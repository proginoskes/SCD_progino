// how to use and install midi files

// install wslib

Quarks.gui; /// quarks sorted alphabetically


// recompile class library using the quarks gui

s.boot;

// read the file
m = SimpleMIDIFile.read( "C:/Users/kouck/Documents/midi_scores/IMSLP156958-WIMA.6225-brahmsdorn.mid" );

// play it (cmd-. to stop)
x = m.p.play; // takes a few seconds to start because this midifile starts with a rest
x.stop;


// play it with another instrument
(
SynthDef( "organ", { |freq = 440, sustain = 1, amp = 0.1|
        var sig;
        sig = LFPar.ar( freq * [1,2,3,5], 0, amp/[2,4,5,7] );
        Out.ar( 0, Env([0,1,1,0], [0.025,sustain,0.025]).kr(2) * sig.dup )
}).add;
);

x = m.p( \organ ).play;
x.stop;


Env
s.reboot;
s.record;
s.stopRecording;
// to play with a more complex synth, need to edit synth to fit midi
x = m.p(\fm_adsr).play;
x.stop;
//information about this midi file
m.tempi;
m.timeSignatures;
m.timeSignatureEvents;
m.keySignatures;
m.keySignatureEvents;
m.instNames;
m.tempoEvents;

// change midi image
m.metaEvents[4][3] = 100;
m.tempoEvents[1][3] = 80;
m.setTempi(200);

(
SynthDef(\fm_adsr,{
	arg
	// globals
	amp=0.1, out=0,freq=220, pan=0,

	// shared envelope values
	atk=0.01, dec=0.02, sustain=0.2, rel=0.2,

	// amplitude envelope values
	atk_level=1, rel_level=0,
	sustain_levelA=0.75, sustain_levelB=0.75,
	curveAtk=1,curveDec=1,curveSus=1,curveRel=1,

	// fundamental frequency envelope values
	fund_init_level=1,
	fund_atk_level=1.1, fund_rel_level=1,
	fund_sustain_levelA=1, fund_sustain_levelB=0.99,
	fund_curveAtk=0,fund_curveDec=0,fund_curveSus=0,fund_curveRel=0,

	// carrier frequency envelope values
	car_init_level=1,
	car_atk_level=1, car_rel_level=1,
	car_sustain_levelA=1, car_sustain_levelB=1,
	car_curveAtk=0,car_curveDec=0,car_curveSus=0,car_curveRel=0,

	// modulation frequency envelope values
	mod_init_level=1,
	mod_atk_level=1.1, mod_rel_level=1,
	mod_sustain_levelA=1, mod_sustain_levelB=1,
	mod_curveAtk=0,mod_curveDec=0,mod_curveSus=0,mod_curveRel=0,

	// modulation frequency envelope values
	modIdx_init_level=1.1,
	modIdx_atk_level=0, modIdx_rel_level=1.1,
	modIdx_sustain_levelA=0, modIdx_sustain_levelB=1.1,
	modIdx_curveAtk=0,modIdx_curveDec=0,modIdx_curveSus=\wel,modIdx_curveRel=0,


	// modulation-related frequency values
	cRatio=1, mRatio=0.99,

	// mod index values
	modIdx=3, modIdxScale=0

	;


	var
	// signals
	sigOut, sigCar, sigMod,

	envAmp, envFund, envCar, envMod, envModIdx,
	// frequency values
	fundFreq, carFreq, modFreq;

	sustain=sustain*0.99;

	// // // envelope region // // //

	// amplitude envelope
	envAmp = EnvGen.ar(
		Env.new(
			times: [atk,dec,sustain,rel],
			levels:[0, atk_level*amp,sustain_levelA*amp, sustain_levelB*amp, rel_level*amp],
			curve: [curveAtk,curveDec,curveSus,curveRel]),
		doneAction:2
	);

	// fundamental frequency envelope (multiplier values)
	envFund = EnvGen.ar(
		Env.new(
			times: [atk,dec,sustain,rel],
			levels:[fund_init_level, fund_atk_level,fund_sustain_levelA, fund_sustain_levelB, fund_rel_level],
			curve: [fund_curveAtk,fund_curveDec,fund_curveSus,fund_curveRel])
	);

	// carrier frequency envelope (multiplier values)
	envCar = EnvGen.ar(
		Env.new(
			times: [atk,dec,sustain,rel],
			levels:[car_init_level, car_atk_level,car_sustain_levelA, car_sustain_levelB, car_rel_level],
			curve: [car_curveAtk,car_curveDec,car_curveSus,car_curveRel])
	);

	// modulating frequency envelope (multiplier values)
	envMod = EnvGen.ar(
		Env.new(
			times: [atk,dec,sustain,rel],
			levels:[mod_init_level, mod_atk_level,mod_sustain_levelA, mod_sustain_levelB, mod_rel_level],
			curve: [mod_curveAtk,mod_curveDec,mod_curveSus,mod_curveRel])
	);

	// modulating index envelope (multiplier values)
	envModIdx = EnvGen.ar(
		Env.new(
			times: [atk,dec,sustain,rel],
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
	sigOut = FreeVerb.ar(sigOut, mix: 0.4, room:0.7, damp:0.2);
	sigOut = Pan2.ar(sigOut,pan);
	Out.ar(out,sigOut);
}
).add;
)
