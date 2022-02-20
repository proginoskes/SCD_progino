/// foiguring out how t ous pfsm and pdfsm

(
SynthDef(\fm_synth_adsr, {
	arg freq=440, bufoffset=0, out=0,
	atk=0.1, dec=0.3, sus=70, rel=0.3,
	sustain_levelA=0.75, sustain_levelB=0.75,
	curveAtk=1,curveDec=1,curveSus=1,curveRel=1,
	modCurveAtk=1,modCurveDec=1,modCurveSus=1,modCurveRel=1,
	pan =0,
	carRatio = 1, amp=0.6,
	modRatio=5, modIdx=10,
	modIdxScaleA = 1, modIdxScaleB = 0.75, modIdxScaleC = 0.75,modIdxScaleD = 1,
	wtIdx=1, wtRatio=1, wtIdxScale = 2;
	var sigCar, sigMod, sigOut, sigWT,
	wtIndexEnv, modIndexEnv, env,
	wtFreq, modFreq, carFreq;

	/*wtIndexEnv = EnvGen.kr(
		Env.new(
			[wtIdx, wtIdx *  wtIdxScale, wtIdx],
			[atk, rel],
			[curveA, curveB]
		)
	);*/

	modIndexEnv = EnvGen.kr(
		Env.new(
			[modIdx, modIdx *  modIdxScaleA, modIdx *  modIdxScaleB, modIdx *  modIdxScaleC, modIdx*  modIdxScaleD],
			[atk, dec, sus, rel],
			[curveAtk, curveDec, curveSus, curveRel]
		)
	);

	carFreq = freq * carRatio;
	modFreq = freq * modRatio;
	//wtFreq = freq * wtRatio;

	env = EnvGen.kr(
		Env.new(
		levels:[0, amp, sustain_levelA*amp, sustain_levelB*amp, 0],
		times: [atk, dec, sus, rel],
		curve: [modCurveAtk,modCurveDec,modCurveSus,modCurveRel]
		),doneAction:2);

	sigMod = (modIndexEnv * modFreq) * SinOsc.ar(modFreq);
	sigCar = env * SinOsc.ar(carFreq + sigMod);


	sigOut =LPF.ar(sigCar, 4000);
	sigOut = Pan2.ar(sigOut, pan);
	Out.ar(out,sigOut);
}).add;
)

(
SynthDef(\fm_bigsaw, {
	arg freq=440, bufoffset=0, out=0,
	atk=0.1, dec=0.3, sus=70, rel=0.3,
	sustain_levelA=0.75, sustain_levelB=0.75,
	curveAtk=1,curveDec=1,curveSus=1,curveRel=1,
	modCurveAtk=1,modCurveDec=1,modCurveSus=1,modCurveRel=1,
	pan =0,
	carRatio = 1, amp=0.6,
	modRatio=5, modIdx=10,
	modIdxScaleA = 1, modIdxScaleB = 0.75, modIdxScaleC = 0.75,modIdxScaleD = 1,
	wtIdx=1, wtRatio=1, wtIdxScale = 2;
	var sigCar, sigMod, sigOut, sigWT,
	wtIndexEnv, modIndexEnv, env,
	wtFreq, modFreq, carFreq;

	/*wtIndexEnv = EnvGen.kr(
		Env.new(
			[wtIdx, wtIdx *  wtIdxScale, wtIdx],
			[atk, rel],
			[curveA, curveB]
		)
	);*/

	modIndexEnv = EnvGen.kr(
		Env.new(
			[modIdx, modIdx *  modIdxScaleA, modIdx *  modIdxScaleB, modIdx *  modIdxScaleC, modIdx*  modIdxScaleD],
			[atk, dec, sus, rel],
			[curveAtk, curveDec, curveSus, curveRel]
		)
	);

	carFreq = freq * carRatio;
	modFreq = freq * modRatio;
	//wtFreq = freq * wtRatio;

	env = EnvGen.kr(
		Env.new(
		levels:[0, amp, sustain_levelA*amp, sustain_levelB*amp, 0],
		times: [atk, dec, sus, rel],
		curve: [modCurveAtk,modCurveDec,modCurveSus,modCurveRel]
		),doneAction:2);

	sigMod = (modIndexEnv * modFreq) * SinOsc.ar(modFreq);
	sigCar = env * LFSaw.ar(carFreq + sigMod);


	sigOut =LPF.ar(sigCar, 4000);
	sigOut = Pan2.ar(sigOut, pan);
	Out.ar(out,sigOut);
}).add;
)

s.reboot

// messing around with the saw
(
m = Synth.new(\fm_bigsaw,[
	\freq, 30.midicps,
	\carRatio, 1,
	\modRatio, 1, \modIdx, 1.2,
	\amp, 0.1,
	\atk, 0.1, \dec, 6, \sus,6, \rel, 1,
	\modIdxScaleA, 10,
	\modIdxScaleB, 1,
	\modIdxScaleC, 10,
	\modIdxScaleD, 100,
	\modCurveAtk, -1,
	\modCurveDec, -10,
	\modCurveSus, 10,
	\modCurveRel, 2
]);
)
m.free;
s.freeAll

a = BufRd.ar(1,~wtbufnums[2]);

Buffer
(
// funk bass light
m = Synth.new(\fm_synth_adsr,[
	\bufoffset, 299
]);
)
m.free;


(
    p = Pdfsm(
        [
		    // select from values twice
            Pseq( [\foo,\bar], 1 ), // foobar signals
            ( // state 0
			// key=foo; next_state=1; return value 0 then 1
                \foo : [ 1, Pseq([ 0, 1, 2  ], 2 ) ]
            ),
            ( // state 1
			// key=bar: next_state=1; return value 0 then 3
                \bar : [ 0, 4 ]
            )
        ],
        0, // first state 0
        2 // repeat twice
    ).asStream;

    // show first 11 values from stream
    11.do({ p.next.postln });
)

Out.ar(0,PlayBuf.ar(1,~wtbufnums[3],rate:0.2)!2);


m.free

p.stop;

// from soundegraver composing rhythm part 1


// if we want to use a global tempo (not sure if ever will)
// use  this:
(
t = TempoClock(88/60).permanent_(true);
// to schedule commands on beat use t.schedAbs
//t.schedAbs(t.nextBar,{t.beats.postln;1})
)
t.stop;
t.pause;

// use this method to update t clock
t.tempo_(133/60);

// for some reason this doesnt change my synth
// you HAVE to use play(t, [additional args])
// or else your thing wont listen to the beat






////////////////////////////////////////////////
(// d is for drone
d = Pbindef(\Drone,
	\dur, 4,
	\amp, 0.2,
	\instrument, \fm_synth_adsr,
	\freq, 60.midicps,
	\carRatio, 1,
	\modRatio, 2, \modIdx, 1,
	\atk, 4, \dec, 4, \sus,4, \rel, 4,
	\modIdxScaleA, 0.1,
	\modIdxScaleB, 10,
	\modIdxScaleC, 20,
	\modIdxScaleD, 30,
).play(t,quant:4);
)
//////////////////////////////////////////////

d.stop;


(
~snare = Pbindef(\Snare,
	\dur, Pseq([1/2,Rest(1/2)],inf),
	\instrument, \fm_synth_adsr,
	\freq, 57.midicps,
	\carRatio, 1,
	\modRatio, 2, \modIdx, 2.3,
	\amp, 0.6,
	\atk, 0.001, \dec, 0.05, \sus,0.005, \rel, 0.0001,
	\modIdxScaleA, 0.1,
	\modIdxScaleB, 10000,
	\modIdxScaleC, 0.4,
	\modIdxScaleD, 3,
	\modCurveAtk, -1,
	\modCurveRel, 9
).play(t, quant:4);
)

(
Pbindef(\Snare,
	\atk, 0.1, \dec, 0.05, \sus,0.005, \rel, 0.01,
	\modIdxScaleA, 19,
	\modIdxScaleB, 1,
	\modIdxScaleC, 40,
	\modIdxScaleD, 1,
	\modCurveAtk, -1,)
)

~snare.stop;


(
Pbindef(\Drone,
	\dur, 16,
	\modIdxScaleA, 60,
	\modIdxScaleB, 40,
	\modIdxScaleC, 20,
	\modIdxScaleD, 0.1,
)
)

(
Pbindef(\Drone,
	\dur, 16,
	\modIdx, 0.1,
	\modIdxScaleA, 100000,
	\modIdxScaleB, 0.01,
	\modIdxScaleC, 60,
	\modIdxScaleD, 34000,
)
)

Pbindef(\Drone, \modIdx, 2.4)




(
b = Pbindef(\Claves,
	\dur, Pseq([1/2,Rest(1/2)],inf),
	\instrument, \fm_synth_adsr,
	\freq, 57.midicps,
	\carRatio, 1,
	\modRatio, 2, \modIdx, 2.3,
	\amp, 0.6,
	\atk, 0.001, \dec, 0.05, \sus,0.005, \rel, 0.0001,
	\modIdxScaleA, 0.1,
	\modIdxScaleB, 1.3,
	\modIdxScaleC, 0.4,
	\modIdxScaleD, 3,
	\modCurveAtk, -1,
	\modCurveRel, 9
).play(t, quant:4);
)
b.stop;

(
Pbindef(\Claves,
	\freq, 57.midicps,
	\modRatio, 1.2,
	\modIdxScaleA, 1.3,
	\modIdxScaleB, 0.2,
	\modIdxScaleC, 0.9,
	\modIdxScaleD, 3,
)
)

(
Pbindef(\Claves,
	\modIdxScaleA, 0.1,
	\modIdxScaleB, 2.3,
	\modIdxScaleC, 0.4,
	\modIdxScaleD, 3,
)
)

b.stop;
(
b.play(t, quant:4);
p.play(t, quant:4);
)
p.stop;


// to change values in real time use Pbindef
(
p = Pbindef(\Kick,
	\dur,Pseq([Rest(1/2),1/2,Rest(1/4),1/2,Rest(1/4)],inf),
	\instrument, \fm_synth_adsr,
	\freq, 220,
	\carRatio, 0.85,
	\modRatio, 0.55, \modIdx, 2.3,
	\amp, 0.3,
	\atk, 0.03, \dec, 0.1, \sus,0.3, \rel, 0.05,
	\modIdxScaleA, 0.1,
	\modIdxScaleB, 0.01,
	\modIdxScaleC, 0.4,
	\modIdxScaleD, 3,
	\modCurveAtk, -1,
	\modCurveRel, 9
).play(t, quant:4);
)

p.stop;


Pbindef(\Kick, \instrument, \fm_bigsaw)
Pbindef(\Kick, \amp, 0.6)

// change quality of sound on the go
(
Pbindef(\Kick,
	\modIdxScaleA, 1.2,
	\modIdxScaleB, 0.3,
	\modIdxScaleC, 0,
	\modIdxScaleD, 0,
)
)
(
Pbindef(\Kick,
	\atk, 0.001,
	\dec, 0.25,
	\sus, 0,
	\rel, 0.001
)
)


// you just have to put a new pattern in with pbindef
Pbindef(\Kick, \dur, 1/2);

(
p.stop;
b.stop;
d.stop;
)

s.record;
s.stopRecording;





		