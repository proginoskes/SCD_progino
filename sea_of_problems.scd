// sea of problems


(
d = Dictionary.new;
d.add(\m ->
	PathName("C:/Users/kouck/Music/freesounds/metal").entries.collect({
		arg sf;
		Buffer.read(s,sf.fullPath);
	});
);
d.add(\w ->
	PathName("C:/Users/kouck/Music/freesounds/water").entries.collect({
		arg sf;
	Buffer.read(s,sf.fullPath);
	});
);
d.add(\l ->
	PathName("C:/Users/kouck/Music/freesounds/solid").entries.collect({
		arg sf;
		Buffer.read(s,sf.fullPath);
	});
);
d.add(\k ->
	PathName("C:/Users/kouck/Music/freesounds/drinking").entries.collect({
		arg sf;
		Buffer.read(s,sf.fullPath);
	});
);
d.add(\music ->
	PathName("C:/Users/kouck/Music/samples_audac").entries.collect({
		arg sf;
		Buffer.read(s,sf.fullPath);
	});
);
)

(
d.add(\songs ->
	PathName("C:/Users/kouck/Music/big_files").entries.collect({
		arg sf;
		Buffer.read(s,sf.fullPath);
	});
);
)

// bufnum dictionary
{Out.ar(0,PlayBuf.ar(1,d[\music][2].bufnum)!2)}.play;

s.freeAll


// this is using grainbuf, which is a beefy playbuf
(
SynthDef(\granular_recon, {
	arg bufnum=416, overlap=2, trigFreq=20, posRate=1, rateMul=1,

	amp=0.5, start=0, samplerate=44100, maxTime=3,
	// shared envelope values
	atk=0.1, dec=0.3, sus=0.2, rel=0.3,

	// amplitude envelope values
	atk_level=1, rel_level=0,
	dec_level=0.75, sus_level=0.75,
	curveAtk=1,curveDec=1,curveSus=1,curveRel=1,

	// pan envelope values
	pan_init_level=0,pan_atk_level=0, pan_rel_level=0,
	pan_dec_level=0, pan_sus_level=0,
	pan_curveAtk=0,pan_curveDec=0,pan_curveSus=0,pan_curveRel=0;
	var readHead, bufData, grainSig, env, envAmp, sigOut,
	bufFramesCount, trig, realOverlap, panEnv;

	bufFramesCount = BufFrames.ir(bufnum);
	trig = Impulse.ar(trigFreq);

	// // // envelope region // // //

	// amplitude envelope
	envAmp = EnvGen.ar(
		Env.new(
			times: [atk,dec,sus,rel],
			levels:[0, atk_level*amp,dec_level*amp, sus_level*amp, rel_level*amp],
			curve: [curveAtk,curveDec,curveSus,curveRel]),
		doneAction:2
	);

	panEnv = EnvGen.ar(
		Env.new(
			times: [atk,dec,sus,rel],
			levels:[pan_init_level, pan_atk_level,pan_dec_level,pan_sus_level, pan_rel_level],
			curve: [pan_curveAtk,pan_curveDec,pan_curveSus,pan_curveRel])
	);

	// // // end env region


	realOverlap = overlap;//LFNoise0.ar(trigFreq).range(1,1+overlap);

	readHead = Phasor.ar(
		rate: rateMul,
		start: start*samplerate,
		end: (start*samplerate) + (bufFramesCount *  (maxTime/samplerate)),
		//resetPos: start*samplerate
	);

	bufData = BufRd.ar(
		numChannels: 1,
		bufnum: bufnum,
		phase: readHead,
		interpolation:0
	);

	grainSig = GrainBuf.ar(
		numChannels: 1,
		trigger: trig,
		dur: realOverlap / trigFreq,
		sndbuf: bufnum,
		rate: posRate,
		pos: readHead / bufFramesCount,
		interp: 0,
		pan: 0,
		envbufnum: -1, // Hann env
		maxGrains: 512 // default
	);


	sigOut = envAmp * grainSig;
	sigOut = Pan2.ar(sigOut, panEnv);
	Out.ar(0,sigOut);
}
).add;
)

s.reboot;

s.record;
s.stopRecording;
//91 bpm
(
g = Synth(\granular_recon, [
	\bufnum, d[\songs][0].bufnum,
	\amp,0.01,
	//\amp, 0.2,
	\atk, 15, \dec, 65, \sus, 95,  \rel, 40,
	\dec_level, 0.5, \sus_level, 0.75,
	\rateMul, 0.8, \start, 225, \maxTime, 269.1,
	//\rateMul, 0.4, \start, 225, \maxTime, 269.1,
	\posRate, 0.8,
	\overlap, 300,
	//\overlap, 3,
	\trigFreq, 1000,
	//\trigFreq, 1,
	/*\pan_init_level, -0.3, \pan_atk_level, 0.3,
	\pan_dec_level, -0.5, \plan_sus_level, 0.7,
	\pan_rel_level, -0.6,*/
	\pan_init_level, 0.9, \pan_atk_level, -0.8,
	\pan_dec_level, 0.7, \plan_sus_level, -0.6,
	\pan_rel_level, 0.4,
]);
)
g.free;

