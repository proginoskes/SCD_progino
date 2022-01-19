// reciever.message:
3.cubed;
3.cudeb; // unknown message
3,cubed; // ungrammatical
number = 3.cubed; // not a known variable
( // local variable
  var number;
  number = 3.cubed;
)
//global variable
~number = 3.cubed


( // function
var foo;
foo = 3;
foo = foo.cubed;
foo = foo + 100;
foo = foo / 2;
foo;
)
// is equivalent to
3.cubed + 100 / 2;

//single line
/*
multiline
*/

// to get help use cmd+d
cubed

Server.local.;

s.boot;
s.quit;

// make sin oscillator assign funct to x
x = {SinOsc.ar}.play;

// free x
x.free;

// make sin oscillator assign funct to x
x = {SinOsc.ar};

// play x assign to y
y = x.play;

y.free;

// lets look at Ugens
// UGen
// these accept 3 message types
// ar: audio rate - output at default sample rate
// kr: kontrol rate - for ugens that shape other ugens
// ir: initialization rate - do not continuously, only when instatiated

// SinOsc

x.free;

x = {SinOsc.ar(700, 0, 0.125, 0)}.play;

// freq 700, def all others
x = {SinOsc.ar(700)}.play;

// frea 700, amp 0.125
x = {SinOsc.ar(700, mul:0.125)}.play

(
z = {
	arg freq = 440, amp = 1;
	var sig;
	sig = SinOsc.ar(freq) * amp;
}.play;
)

z.set(\freq, 220);
z.set(\amp, 0.125);
z.set(\amp, 0.5, \freq, 250);
z.free;


// Ugens that control Ugens
(
z = {
	arg amp = 1;
	var sig, freq;

	// freq is a control rate
	// 8 new values per second
	// mul is low
	// add is high
	freq = LFNoise0.kr(8,400,600);
	sig = SinOsc.ar(freq) * amp;
}.play;
)

z.set(\amp, 0.1);
z.free;

// same with range instead
(
z = {
	arg amp = 1;
	var sig, freq;

	// range limits values of freq
	// 8 new values per second
	// range(_,) is low
	// range(,_) high
	freq = LFNoise0.kr(8).range(400,600);
	sig = SinOsc.ar(freq) * amp;
}.play;
)

(
z = {
	arg amp = 1;
	var sig, freq;

	// exp range normalizes by log
	// 8 new values per second
	// exprange(_,) is low
	// exprange(,_) is high
	freq = LFNoise0.kr(8).exprange(400,600);
	sig = SinOsc.ar(freq) * amp;
}.play;
)

z.free;

// all ugens have range method


// now generate amps
(
z = {
	var sig, freq, amp;

	// exp range normalizes by log
	// 8 new values per second
	// exprange(_,) is low
	// exprange(,_) is high
	freq = LFNoise0.kr(8).exprange(400,600);
	amp = LFNoise0.kr(12).exprange(0.02,1);
	sig = SinOsc.ar(freq) * amp;
}.play;
)

z.free;

// now control freq of random vals
(
z = {
	arg noiseHz=8, ampHz=12;
	var sig, freq, amp;

	// exp range normalizes by log
	// 8 new values per second
	// exprange(_,) is low
	// exprange(,_) is high
	freq = LFNoise0.kr(noiseHz).exprange(400,600);
	amp = LFNoise0.kr(ampHz).exprange(0.02,1);
	sig = SinOsc.ar(freq) * amp;
}.play;
)

z.set(\noiseHz, 11, \ampHz, 9);
z.set(\noiseHz, exprand(4,64), \ampHz, exprand(4,64));

z.free;


// create a synth tutorial 3

// SynthDef: backend
// Synth: frontend

// many methods are synths

(
SynthDef.new(\sineTest, {
	arg noiseHz=8, ampHz=12;
	var sig, freq, amp;

	// exp range normalizes by log
	// 8 new values per second
	// exprange(_,) is low
	// exprange(,_) is high
	freq = LFNoise0.kr(noiseHz).exprange(400,600);
	amp = LFNoise0.kr(ampHz).exprange(0.02,1);
	sig = SinOsc.ar(freq) * amp;
	Out.ar(0, [sig,sig]);
}).add;
)

// initialize x with args for sinetest
x = Synth.new(\sineTest, [\noiseHz, 3]);

// change x's args for sinetest
x.set(\ampHz, exprand(4,64));

x.free;


(
SynthDef.new(\pulseTest, {
	arg ampHz=4, fund=40, maxPart=4, width=0.5;
	var amp1,amp2,freq1,freq2,sig1,sig2;

	// random volumes
	amp1 = LFPulse.kr(ampHz,0,0.12)*0.75;
	amp2 = LFPulse.kr(ampHz,0.5,0.12)*0.75;

	// round(fund) gives overtones of a fundamental
	freq1 = LFNoise0.kr(4).exprange(fund,fund*maxPart).round(fund);
	freq2 = LFNoise0.kr(4).exprange(fund,fund*maxPart).round(fund);

	freq1 = freq1 * LFPulse.kr(8, add:1);
	freq1 = freq1 * LFPulse.kr(6, add:1);


	sig1 = Pulse.ar(freq1, width, amp1);
	sig2 = Pulse.ar(freq2, width, amp2);

	// add reverb by setting to a UGen with itself as an arg
	sig1 = FreeVerb.ar(sig1, 0.7, 0.8, 0.25);
	sig2 = FreeVerb.ar(sig2, 0.7, 0.8, 0.25);

	Out.ar(0, sig1);
	Out.ar(1, sig2);

}).add;
)

x = Synth.new(\pulseTest, [\ampHz, 5, \fund, 42, \maxPart, 3, \width, 0.6 ]);

x.set(\fund, exprand(64,256), \width, rand(0.2,1.7),\maxPart, exprand(3,28), \ampHz, exprand(2,64));

x.free;

s.freeAll;

// envelopes and doneAction (tutorial 4)

envelopes

// line
/*
takes start and end, duration, output-multiplier, output-addend, and doneAction

doneActions are evaluated when the line is completed
    -> doneActions are inherently finite
    -> there are 15 options (0: nothing, 2: free)

*/

Server.local.plotTree;

(
x = {
	var sig, env, freq;
	env = XLine.kr(2, 0.02, 1, doneAction:0);
	freq = XLine.kr(880,110,5,doneAction:2);
	sig = Pulse.ar(freq) * env;
}.play;
)

// db to amp: .dbamp
// amp to db: .ampdb

s.freeAll;

// envs

// default triangle
Env.new.plot;

/*
Env(levels, times, curve, releaseNode, loopNode, offset)

times are the duration between levels
curve defines the shape between durations
Env
*/

(
x = {
	arg t_gate;
	var sig, env;
	env = EnvGen.kr(Env.new(2*[0.01, 0.25, 0.5,0.9,0.5,0.25, 0.01],[0.4, 0.1, 0.02, 0.02, 0.1, 0.4], [1,-3, 0,0, 3,-1]), t_gate);//,doneAction:2);
	sig = SinOsc.ar(220 + 1.005**env)*env;
}.play;
)

// \gate is final; \t_gate resets after being set
x.set(\t_gate, 1);

x.free;

s.freeAll;

Env.new(2*[0.01, 0.25, 0.5,0.9,0.5,0.25, 0.01],[0.3, 0.2, 0.02, 0.02, 0.2, 0.3], [1,-5, 0,0, 5,-1]).plot;

// what's Env.adsr
/*
Attack Decay Sustain Release:
- sustain portion allows us to sustain indef
-

VarSaw

*/

Env.adsr.plot;

(
x = {
	arg gate;
	var sig, env, freq;
	env = EnvGen.kr(Env.adsr(1.2,2.4,0.9,2, curve: -3), gate ,doneAction:2);
	freq = EnvGen.kr(Env.adsr(1), gate, 200, 0.1);
	sig =
StkClarinet.ar(SinOsc.kr(freq).range(20,880));
}.play;
)

x.set(\gate, 1);

x.free;

/////////////////// test your skills ////////////////////
/*
Make a SynthDef that uses:
- left and right with different sounds/flavors
- complex math
- arguments
- EnvGen and other UGens
- gate/t_gate
*/
(
SynthDef(\quizSyn, {
	arg ampHz=4, fund=40, maxPart=4, width=0.5;
	var amp1,amp2,freq1,freq2,sig1,sig2;

	// random volumes
	amp1 = LFPulse.kr(ampHz,0,0.12)*0.75;
	amp2 = LFPulse.kr(ampHz,0.5,0.12)*0.75;

	// round(fund) gives overtones of a fundamental
	freq1 = LFNoise0.kr(4).exprange(fund,fund*maxPart).round(fund);
	freq2 = LFNoise0.kr(4).exprange(fund,fund*maxPart).round(fund);

	//freq1 = freq1 * LFPulse.kr(8, add:1);
	//freq1 = freq1 * LFPulse.kr(6, add:1);


	sig1 = SinOsc.ar(freq1, width, amp1);
	sig2 = SinOsc.ar(freq2, width, amp2);

	// add reverb by setting to a UGen with itself as an arg
	sig1 = FreeVerb.ar(sig1, 0.7, 0.8, 0.25);
	sig2 = FreeVerb.ar(sig2, 0.7, 0.8, 0.25);

	Out.ar(0, sig1);
	Out.ar(1, sig2);

}).add;
)

x = Synth.new(\quizSyn, [\ampHz, 5, \fund, 42, \maxPart, 60, \width, 0.6 ]);

x.set(\fund, exprand(64,256), \width, rand(0.2,1.7),\maxPart, exprand(3,28), \ampHz, exprand(2,64));

x.free;



s.freeAll;

//Env.circle([0,1,0],[0.01,0.5,0.2]).plot;
/*
Env.xyc([[2, 0.5, [\lin, \exp]], [0, 1, \lin], [3, 1.4, \lin]]).plot;
Env.xyc({ [1.0.rand, 1.0.rand, {[\lin, \exp, \step].choose} ! 3] } ! 8).plot
Env([[2, 1], 0], [[1, 2]], \lin).plot;

Env.xyc([[[2.0, 2.3], 0.5, \lin], [0, 1, \lin], [3, 1.4, \lin]]).plot;

Env([0.01, 5, 1, 0.5] + 1, [1, 0.5, 1, 0.25], [[\lin, \sqr]]).plot;

Impulse

*/


// multichannel cynth tutorial 5
s.meter;

x = {[SinOsc.ar(440), SinOsc.ar(440)]}.play
x.free;

//shorthand:
x = {SinOsc.ar([440,440])}.play;
x.free;

(
x = {
	var sig, amp;
	// two channels
	amp = SinOsc.kr([7,1]).range(0,1);
	// control rate applies its number of signals
	sig=SinOsc.ar(440);
	sig=sig*amp;

}.play;
)

x.free;

(
x = {
	var sig, amp;
	// two channels
	amp = SinOsc.kr([7,1,2,0.2,6]).range(0,1);
	// control rate applies its number of signals
	sig=SinOsc.ar([300,500,700,900,1000]);
	sig=sig*amp;

	// eqiv to Mix.new(sig).dup(2) or Mix.new(sig)!2
	[Mix.new(sig), Mix.new(sig)]*0.25;
}.play;
)

x.free;

// Splay
(
x = {
	var sig, amp;
	// two channels
	amp = SinOsc.kr([7,1,2,0.2,6]).range(0,1);
	// control rate applies its number of signals
	sig=SinOsc.ar([300,500,700,900,1000]);
	sig=sig*amp;

	// spread array of channels across stereo evenly
	Splay.ar(sig)*0.25;
}.play;
)

x.free;

// same on each side
x = {PinkNoise.ar(0.5)!2}.play;

x.free;

// diff on each side
x = {PinkNoise.ar(0.5!2)}.play;

x.free;

// Synthdef with two channels and env, ExpRand runs on each call, not compile
(
SynthDef.new(\customove, {
	arg t_gate=1, fund=60, overtones=8;
	var sig, amp, env, diff;

	env = EnvGen.kr(
		Env.new(2*[0.01, 0.25, 0.5,0.9,0.5,0.25, 0.01],[0.4, 0.1, 0.02, 0.02, 0.1, 0.4], [1,-3, 0,0, 3,-1]),gate: t_gate
	);

	// two channels
	amp = SinOsc.kr({ExpRand(0.2,2.12)}!16).range(0,0.9);
	// control rate applies its number of signals

	sig=SinOsc.ar({440*(2**((60+(12*Rand(-5,4))-69)/12))}!16);
	sig=sig*amp*env;

	// spread array of channels across stereo evenly
	sig = Splay.ar(sig)*0.25;
	// this is accidentally causing signal overlap
	//Out.ar([0,1],sig);
	// supercollider handles it
	Out.ar(0,sig);
}).add;
)


x = Synth.new(\customove, [\t_gate, 3, \fund, 40]);

y.free;
x.free;

s.freeAll;

{rrand(50,1200)}!4; // contents evaluated each channel

SuperDirt.start;

//iteration (tutorial 6)

// most basic is do
//    - does function N times where N=size(receiver)
//    - receiver.do{function};
[6, 4, 0.5, 7, 10].do{"hello".postln};

// print changed values and index
(
[6, 4, 0.5, 7, 10].do{
	arg item, count;
	[count, item.squared].postln;
};
)

// store changed values in x
(
x = Array.newClear(5);

[6, 4, 0.5, 7, 10].do{
	arg item, count;
	[count, item.squared].postln;
	x[count] = item.squared;
};
x.postln;
)


// collect does this in fewer lines
(
z = [3, 6, 0.3, 2, 50].collect{
	arg item, count;
	item.squared;
}
)

// and even better
z = [7, 32, 4, 0.34, 5].collect(_**2);

// iterate [0..4]
5.do;
5.collect(_**2);

// do with ugens

x = {VarSaw.ar(40!2, 0, 0.05)}.play;
x.free;

(
SynthDef.new(\iter, {
	arg freq=40;
	var temp, env, sum;
	sum = 0;
	env = EnvGen.kr(
		Env.perc(0.01, 5, 1, -2),
		doneAction:2
	);
	10.do{
		temp = VarSaw.ar(
			freq * {Rand(0.99,1.02)}!12,
			{Rand(0.0,1.0)}!12,
			{ExpRand(0.005,0.05)}!12
		);
		sum = sum + temp;
	};
	sum = sum * 0.05 * env;
	Out.ar(0,sum);
}).add;
)

Synth.new(\iter, [\freq, 440]);
Synth.new(\iter, [\freq, 550]);
Synth.new(\iter, [\freq, 660]);
Synth.new(\iter, [\freq, 750]);
Synth.new(\iter, [\freq, 880]);

// this is not recommended, but gives a chord
(
[53, 59, 63, 68].do{
	arg midinote;
	Synth.new(\iter, [\freq, midinote.midicps]);
}
)


SuperDirt.start;

// synthdef that uses iter block to create partials

(
SynthDef.new(\iter2, {
	arg freq=40;
	var temp, env, sum;
	sum = 0;
	env = EnvGen.kr(
		Env.perc(0.01, 5, 1, -2),
		doneAction:2
	);
	10.do{
		arg count;
		temp = SinOsc.ar(
			freq * (count+1),
			0,
			0.05
		);
		sum = sum + temp;
	};
	sum = sum * 0.05 * env;
	Out.ar(0,sum);

}).add;
)

x = Synth.new(\iter2, [\freq, 60.midicps]);

// as above plus more weirdness on partials
(
SynthDef.new(\iter3, {
	arg freq=40;
	var temp, env, sum;
	sum = 0;
	env = EnvGen.kr(
		Env.perc(0.01, 5, 1, -2),
		doneAction:2
	);
	10.do{
		arg count;
		temp = SinOsc.ar(
			freq *
			(count+1) *
			LFNoise1.kr({Rand(0.05, 0.2)}!2).range(0.98, 1.02)
		);
		temp = temp * LFNoise1.kr({Rand(0.5, 8)}!2).range(0.01, 1);
		sum = sum + temp;
	};
	sum = sum * 0.05 * env;
	Out.ar(0,sum);

}).add;
)

Synth.new(\iter3, [\freq, 330]);

// iter4 is iter plus range of freq modulation is arg
(
SynthDef.new(\iter4, {
	arg freq=40, dev = 1.02;
	var temp, env, sum;
	sum = 0;
	env = EnvGen.kr(
		Env.perc(0.01, 5, 1, -2),
		doneAction:2
	);
	10.do{
		arg count;
		temp = SinOsc.ar(
			freq *
			(count+1) *
			LFNoise1.kr({Rand(0.05, 0.2)}!2).range(dev.reciprocal, dev)
		);
		temp = temp * LFNoise1.kr({Rand(0.5, 8)}!2).range(0.01, 1);
		sum = sum + temp;
	};
	sum = sum * 0.05 * env;
	Out.ar(0,sum);

}).add;
)

Synth.new(\iter4, [\freq, 330,\dev, 4.6]);

// inputs that are hard to enter, like partials number
// args are Control class, not an integer
// can't do this! need to manually change it
(
SynthDef.new(\iter5, {
	arg freq=40, dev = 1.02; //partials=10;
	var temp, env, sum, idx;
	sum = 0;
	env = EnvGen.kr(
		Env.perc(0.01, 5, 1, -2),
		doneAction:2
	);
	//partials.do will not do anything, just treated as a single value
	10.do{
		arg count;
		temp = SinOsc.ar(
			freq *
			(count+1) *
			LFNoise1.kr({Rand(0.05, 0.2)}!2).range(dev.reciprocal, dev)
		);
		temp = temp * LFNoise1.kr({Rand(0.5, 8)}!2).range(0.01, 1);
		sum = sum + temp;
	};
	sum = sum * 0.05 * env;
	Out.ar(0,sum);

}).add;
)

Synth.new(\iter5, [\freq, 330,\dev, 1.02]);

var x;
Rand(0,40).round(10).range(0,10).asInteger.postln;

// Nodes, Buffers, OrderofOperations tutorial 8

// arg out

(
SynthDef.new(\blp, {
	arg out;
	var freq, trig, sig;
	freq = LFNoise0.kr(3).exprange(300,1200).round(300);
	sig = SinOsc.ar(freq)*0.25;
	trig = Dust.kr(2);
	sig = sig * EnvGen(Env.perc(0.01,0.2),trig);
	Out.ar(out,sig)
}).add;

SynthDef.new(\reverb, {
	arg in,out=0;
	var sig;
	sig = In.ar(in,1);
	sig = FreeVerb.ar(sig,0.5,0.8,0.2)!2;
	Out.ar(out,sig);
}).add;
)

// change number of out and in bus channels
s.options.numAudioBusChannels;
s.options.numOutputBusChannels = 4; // set with =
s.options.numInputBusChannels = 2; // set with =

// reboot to take effect
s.reboot;
s.boot;
// now our meter has 4 outs
s.meter;


// in for one = out for another to pass signals
y = Synth.new(\reverb, [\in, 60]);
x = Synth.new(\blp, [\out, 60]);

y.free;
x.free;


// multichannel server messages

(
SynthDef.new(\blp3, {
	arg out;
	var freq, trig, sig;
	freq = LFNoise0.kr(3).exprange(300,1200).round(300);
	sig = SinOsc.ar(freq)*0.25;
	trig = Dust.kr(2);
	sig = sig * EnvGen(Env.perc(0.01,0.2),trig);
	sig = Pan2.ar(sig, LFNoise1.kr(10));
	Out.ar(out,sig)
}).add;

SynthDef.new(\reverb3, {
	arg in,out=0;
	var sig;
	sig = In.ar(in,1);
	sig = FreeVerb.ar(sig,0.5,0.8,0.2);
	Out.ar(out,sig);
}).add;
)

// change number of out and in bus channels
s.options.numAudioBusChannels;
s.options.numOutputBusChannels = 4; // set with =
s.options.numInputBusChannels = 2; // set with =

// reboot to take effect
s.reboot;
s.boot;
// now our meter has 4 outs
s.meter;

// let sc handle bus alloc
~reverbBus = Bus.audio(s,1);
~reverbBus2 = Bus.audio(s,2);

// in for one = out for another to pass signals
// order of operations requires inputs after outputs
y = Synth.new(\reverb3, [\in, ~reverbBus], x, \addAfter); //.index implied
x = Synth.new(\blp3, [\out, ~reverbBus]);

s.freeAll;

x.free;

//can also do this with groups
~srcGrp = Group.new;
~efxGrp = Group.after(~srcGrp);
~efxGrp.free;

w = Synth.new(\reverb3, [\in, ~reverbBus], ~efxGrp); //.index implied
z = Synth.new(\blp3, [\out, ~reverbBus], ~srcGrp);
z.free;
w.free;

// now we can generate a bunch of synths in the same group automatically
(
8.do{
	Synth.new(
		\blp3,
		[
			\out, ~reverbBus2,
			\fund, exprand(60, 300).round(30)
		],
		~srcGrp
	);
}
)
~srcGrp.set(\decay, 1.2);
~srcGrp.set(\dens, 0.25);

~srcGrp.freeAll;

y.free;
x.free;
s.freeAll;


s.freeAll;

// buffer objects tutorial ??

s.reboot;

~sndfile01 = Buffer.read(s, "C:/Users/kouck/Music/freesounds/592023__c-v__sword-drawn.wav");

~sndfile01.play;

// removes file, keeps alloc
~sndfile01.zero;



// puts it back
~sndfile01.read("C:/Users/kouck/Music/freesounds/592023__c-v__sword-drawn.wav");

// deallocs buffer
~sndfile01.free;


// read in all the other sound files
~sndfile02 =  Buffer.read(s, "C:/Users/kouck/Music/freesounds/607440__bennathanras__soda-open.wav");
~sndfile03 = Buffer.read(s, "C:/Users/kouck/Music/freesounds/542792__erickbloem-200250__stretch-and-pop.wav");

// get number of frames
~sndfile01.numFrames;
~sndfile02.numFrames;
~sndfile03.numFrames;

// channels
~sndfile01.numChannels;
~sndfile02.numChannels;
~sndfile03.numChannels;

// the number of possible samples is equal to
// numSamples = numFrames * numChannels;

// get a buffer with set channel num
~sndfile04 = Buffer.readChannel(s, "C:/Users/kouck/Music/freesounds/592023__c-v__sword-drawn.wav", channels:[1]);

s.meter;

// outputs to two chanesl
~sndfile01.play;

// outputs to one channel
~sndfile04.play;


// buffer numbers (bufnums)
// these are the indices of trhe buffers
~sndfile01.bufnum;
~sndfile02.bufnum;
~sndfile03.bufnum;
~sndfile04.bufnum;


// buffer samples rate
~sndfile01.sampleRate;
// is different from
s.sampleRate;

// summary
~sndfile01.query;

// split
~sndfile01_split0 = Buffer.read(s, "C:/Users/kouck/Music/freesounds/592023__c-v__sword-drawn.wav", 0, s.sampleRate/2);
~sndfile01_split0.play;



~sndfile01_split1 = Buffer.read(s, "C:/Users/kouck/Music/freesounds/592023__c-v__sword-drawn.wav", 223555, ~sndfile01.numFrames-223556);

~sndfile01_split1.play;

// can also do this as a folder array and contained files
~sndfiles = Array.new;
~folder = PathName.new("C:/Users/kouck/Music/freesounds/metal");

~folder.entries;

(
~folder.entries.do({
	arg path;
	~sndfiles = ~sndfiles.add(Buffer.read(s,path.fullPath));
});
)

~sndfiles;

~sndfiles.at(1).play;
// equals
~sndfiles[1].play;

s.options.numBuffers;


(
SynthDef.new(\playbuf_test, {
	arg amp=1, out=0, buf, rate=1, start=0,loop=0, da=2, t_trig;
	var sig;
	sig = PlayBuf.ar(2, buf, BufRateScale.kr(buf) * rate,t_trig,start,loop,doneAction:da);
	sig = sig**2;
	Out.ar(out,sig);
}).add;
)

Synth.new(\playbuf_test, [\buf, ~sndfiles[0].bufnum, \rate, 1]);
Synth.new(\playbuf_test, [\buf, ~sndfiles[0].bufnum, \rate, -1, \start, ~sndfiles[1].numFrames-2]);
x = Synth.new(\playbuf_test, [\buf, ~sndfiles[0].bufnum, \start, s.sampleRate/2, \da, 0]);

Synth.new(\playbuf_test, [\buf, ~sndfiles[2], \loop, 1]);

y.set(\t_trig, 1);
x.set(\t_trig, 1, \buf, ~sndfiles[2]);
x.free;
y.free;


s.freeAll;

//groups and buffers

g = Group.new;

(
w = Synth.new(\playbuf_test, [\buf, ~sndfiles[2], \loop, 1, \rate, 1.3, \amp, 0.5], g);
x = Synth.new(\playbuf_test, [\buf, ~sndfiles[2], \loop, 1, \rate, 0.7, \amp, 0.5], g);
y = Synth.new(\playbuf_test, [\buf, ~sndfiles[2], \loop, 1, \rate, 1.9, \amp, 0.3], g);
z = Synth.new(\playbuf_test, [\buf, ~sndfiles[2], \loop, 1, \rate, 2.3, \amp, 0.5], g);
)


g.set(\buf, ~sndfiles[2]);

z.set(\rate, exprand(0.2,20.23));

g.freeAll;

g.free;




// BufRd - buffer read
(
SynthDef.new(\bufrd_test, {
	arg amp=1, out=0, buf, start=0, end;//, rate=1, start=0,loop=0, da=2, t_trig;
	var sig,ptr;
	ptr = Line.ar(start, end, BufDur.kr(buf), doneAction:2);
	sig = BufRd.ar(2, buf, ptr);
	sig = sig**2;
	Out.ar(out,sig);
}).add;
)

//backwards
Synth.new(\bufrd_test, [\buf, ~sndfiles[2], \end, 0, \start, ~sndfiles[2].numFrames]);
// forward
Synth.new(\bufrd_test, [\buf, ~sndfiles[2], \end, ~sndfiles[2].numFrames,\start, 0]);



// Buffer Read plus phasor

(
SynthDef.new(\bufrd_test, {
	arg amp=1, out=0, buf, start=0, end, rate=1;//, start=0,loop=0, da=2, t_trig;
	var sig,ptr;
	ptr = Phasor.ar(0, BufRateScale.kr(buf) * rate, start, end, doneAction:2);
	sig = BufRd.ar(2, buf, ptr);
	sig = sig**2;
	Out.ar(out,sig);
}).add;
)

//backwards
x = Synth.new(\bufrd_test, [\buf, ~sndfiles[2], \end, 0, \start, ~sndfiles[2].numFrames, \rate, -7.midiratio]);
// forward
Synth.new(\bufrd_test, [\buf, ~sndfiles[2], \end, ~sndfiles[2].numFrames,\start, 0]);

x.set(\buf, ~sndfiles[0], \end, ~sndfiles[0].numFrames*0.90, \start, ~sndfiles[0].numFrames*0.66, \rate, 8);

x.free;

s.freeAll;

// Buffer Read plus Loop

(
SynthDef.new(\bufrd_test, {
arg amp=1, out=0, buf, start=0, end, rate=1, freq=220;//, start=0,loop=0, da=2, t_trig;
	var sig,ptr;
	ptr = SinOsc.ar(freq, 3pi/2).range(start,end);
	sig = BufRd.ar(2, buf, ptr);
	sig = sig**2;
	Out.ar(out,sig);
}).add;
)

//backwards
x = Synth.new(\bufrd_test, [\buf, ~sndfiles[2], \end, 0, \start, ~sndfiles[2].numFrames*0.20, \rate, 7.midiratio]);
// forward
Synth.new(\bufrd_test, [\buf, ~sndfiles[2], \end, ~sndfiles[2].numFrames,\start, 0]);

x.set(\buf, ~sndfiles[2], \end, ~sndfiles[2].numFrames*0.90, \start, 0, \rate, -1, \freq, 440);

x.free;

s.freeAll

// Buffer Read into osc

(
SynthDef.new();
)

// Buffered noise
(
~sndfiles = Array.new;
~folder = PathName.new("C:/Users/kouck/Music/freesounds");

~folder.entries;

(
~folder.entries.do({
	arg path;
	~sndfiles = ~sndfiles.add(Buffer.read(s,path.fullPath));
});
)
)

~sndfiles;


~sndfiles[3].bufnum;

(
SynthDef.new(\bufnoise, {
	arg amp=1, out=0, buf, start, end, freq;
	var sig, needle;
	needle = LFNoise2.ar(freq).range(start,end);
	sig = BufRd.ar(2,buf,needle);
	sig = sig * amp;
	Out.ar(out,[sig, sig]);
}).add;
)

g = Group.new;

~sndfiles[3].numFrames;

w.free;


w = Synth.new(\bufnoise,[\buf, ~sndfiles[3], \start, 0, \end, ~sndfiles[3].numFrames-1,\freq, 2.5, \amp, 0.4], g);
x = Synth.new(\bufnoise,[\buf, ~sndfiles[2], \start, 0, \end, ~sndfiles[2].numFrames-1,\freq, 2.5, \amp, 0.7], g);
y = Synth.new(\bufnoise,[\buf, ~sndfiles[1], \start, 0, \end, ~sndfiles[1].numFrames-1,\freq, 2.5, \amp, 0.2], g);
z = Synth.new(\bufnoise,[\buf, ~sndfiles[0], \start, 0, \end, ~sndfiles[0].numFrames-1,\freq, 2.5, \amp, 0.9], g);


y.set(\freq, 0.4);
w.set(\freq, 1.5, \start, ~sndfiles[3].numFrames*0.1, \end, 0);
w.free;

g.freeAll;

s.freeAll;

// now add channels


(
SynthDef.new(\bufnoise, {
	arg amp=1, out=0, buf, start, end, freq;
	var sig, needle;
	needle = LFNoise2.ar({Rand(freq.reciprocal,freq)}!8).range(start,end);
	sig = BufRd.ar(2,buf,needle);
	sig = Splay.ar(sig * amp);
	Out.ar(out,sig);
}).add;
)

g = Group.new;

~sndfiles[3].numFrames;

w.free;

s.reboot;

(
w = Synth.new(\bufnoise,[\buf, ~sndfiles[3], \start, 0, \end, ~sndfiles[3].numFrames-1,\freq, 5.1, \amp, 0.1], g);
x = Synth.new(\bufnoise,[\buf, ~sndfiles[2], \start, 0, \end, ~sndfiles[2].numFrames-1,\freq, 1.5, \amp, 0.7], g);
y = Synth.new(\bufnoise,[\buf, ~sndfiles[1], \start, 0, \end, ~sndfiles[1].numFrames-1,\freq, 2.3, \amp, 0.5], g);
z = Synth.new(\bufnoise,[\buf, ~sndfiles[0], \start, 0, \end, ~sndfiles[0].numFrames-1,\freq, 0.7, \amp, 0.9], g);
)

g.free;

w.set(\freq, 0.4);
w.set(\freq, 1.5, \start, ~sndfiles[3].numFrames*0.1, \end, 0);

/// return to tutorial 7 server architecture

(
SynthDef.new(\blipp, {
	arg out;
	var freq, trig, sig;
	freq = LFNoise0.kr(3).exprange(300,1200).round(300);
	sig = SinOsc.ar(freq) * 0.25;
	trig = Dust.kr(2); // generates random numbers between 0 and 1 at densite 2hz
	sig = sig * EnvGen.kr(Env.perc(0.01,0.2),trig);
	Out.ar(out,sig);
}).add;

SynthDef(\rverb, {
	arg in, out=0;
	var sig;
	sig = In.ar(in,1);
	sig = FreeVerb.ar(sig, 0.5, 0.8, 0.2)!2;
	Out.ar(out,sig);
}).add;
)

s.options.numAudioBusChannels;

s.meter;

y = Synth.new(\rverb, [\in, 6]);
x = Synth.new(\blipp, [\out, 6]);

//can also do this with groups and globals
~reverbBus = Bus.audio(s, 1);
~srcGrp = Group.new;
~efxGrp = Group.after(~srcGrp);
w = Synth.new(\rverb, [\in, ~reverbBus], ~efxGrp); //.index implied
z = Synth.new(\blipp, [\out, ~reverbBus], ~srcGrp);
z.free;
w.free;
~efxGrp.free;
~srcGrp.free;

// MIDI tutorial 9

//linexp is a mapping function from linear range to exponential range
rrand(0,127).linexp(0,127,30,880);


(
SynthDef.new(\tone, {
	arg freq=440, amp=0.3, gate=0, bend=0;
	var sig, env;
	sig = LFTri.ar(freq * bend.midiratio)!2;
	env = EnvGen.kr(Env.adsr, gate, doneAction:2);
	sig = sig * env * amp;
	Out.ar(0,sig);
}).add;
)

~bendd = rrand(0,30).linlin(0,30,2,19);

x = Synth.new(\tone, [\gate, 1, \bend, (rrand(0,30).linlin(0,30,0.1,0.9))!2;]);

x.free;


// Patterns tutorial 10


// Streams-Patterns-Events

(
SynthDef.new(\spe, {
	arg freq=440, atk=0.005, rel=0.3, amp=1, pan=0;
	var sig, env;
	sig = SinOsc.ar(freq);
	env = EnvGen.kr(Env.new([0,1,0],[atk,rel],[1,-1]), doneAction:2);

	sig = Pan2.ar(sig,pan,amp);
	sig = sig * env;
	Out.ar(0,sig);
}).add;
)

x = Synth.new(\spe, [\freq, 220]);

//Pbind

(
p = Pbind(
	//\type, \note,
	\instrument, \spe,
	\dur, Pwhite(0.05,0.5,inf),
	\freq, Pexprand(50,2000, inf).trace,
	\atk, Pwhite(0.05, 2.3, inf),
	\rel, Pwhite(0.9, 2.4, inf),
	\amp, Pexprand(0.01,0.3,inf),
	\pan, Pwhite(-0.9,0.9),
).play
)

p.stop;

// fix annoying squeals
(
Pdef(
	\sinepat,
    Pbind(
	    //\type, \note,
	    \instrument, \spe,
	    \dur, Pwhite(0.05,0.5,inf),
	    \midinote, Pseq([60], inf),
	    \harmonic, Pexprand(1,20,inf).round.trace,
	    \atk, Pwhite(0.005, 2.3, inf),
	    \rel, Pwhite(0.9, 5.6, inf),
	    \amp, Pkey(\harmonic).reciprocal * 0.3,
	    \pan, Pwhite(-0.9,0.9),
    );
).stop;
)

q.stop;

// do a bunch together

//dictionary of samples
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
)

// check loading correct
d[\k].choose.play;


// customized by adding needle and using bufrd
(
SynthDef.new(\bufplay, {

arg buf=0, rate=1, amp=1, start=0, end=1;
	var sig;
	sig = PlayBuf.ar(2,buf,BufRateScale.ir(buf) * amp);
	//sig = BufRd(2, buf, needle);
	Out.ar(0,sig);
}).add;
)

p = d[\m].choose;

/// test playback
t = Synth.new(\bufplay, [\buf, p])

t.free;

s.freeAll;

(
Pdef(
	\rhythm,
	Pbind(
		\instrument, \bufplay,
		\dur, Pseq([1/4],inf),
		\stretch, 0.24,
		// plus plus concatenates
		// Prand flat random from array
		// Pxrand exclusive rand from array
		// Pwrand weighted random from arrays
		//\bufPxrand(d[\k]++d[\l]++d[\w]++d[\m],inf),
		//\buf, Pwrand([d[\k][0],d[\l][0],d[\w][0],d[\m][0]],[2,4,1,26].normalizeSum,inf),
		// patternes:
		\buf, Pseq(
			[
				Prand(d[\l], 1),
				Prand(d[\w]++d[\m], 7),
				Prand(d[\k], 1),
				Prand(d[\m]++d[\l],2)
			], inf
		),
		\rate, Pexprand(0.4,0.5,inf),
		\amp, Pseq([0.8, Pexprand(0.005,0.2,7)],inf),
	)
).play;
)

PlayBuf
// fix annoying squeals
(
Pdef(
	\sinepat,
    Pbind(
	    //\type, \note,
	    \instrument, \spe,
		\dur, Pseq([1/16],inf),
	    //\midinote, Pseq([60], inf),
		\stretch, 1.875,
		\note, Pxrand([0,5,6,9,10,12],inf),
		\gtranspose, -7,
	    //\harmonic, Pexprand(1,20,inf).round.trace,
	    \atk, Pwhite(0.005, 2.3, inf),
	    \rel, Pwhite(0.9, 5.6, inf),
	    \amp, Pkey(\harmonic).reciprocal * 0.3,
	    \pan, Pwhite(-0.9,0.9),
    );
).play;
)

Pdef(\sinepat).stop;


s.reboot;

// OSC tutorial 11

// touchOSC is $10 on app store



(
OSCdef.new(
	\padnew,
	{
		arg msg, time, addr, port;
		[msg, time, addr, port].postln;
	},
	'/syntien/touchpad/1/touchpad1',
);
)

// this needs windows firewall disabled

NetAddr.langPort;



// FM Synthesis tutorial 20

s.reboot;

// no FM
y = {SinOsc.ar(440) * 0.2!2}.play;
y.free;

// static modulation at 4hz per second
x = {SinOsc.ar(440 + SinOsc.ar(1, mul:4)) * 0.2!2}.play;

x.free;

// static modulation at 4hz per 1/9 second
x = {SinOsc.ar(440 + SinOsc.ar(9, mul:4)) * 0.2!2}.play;

x.free;

// dynamic modulation at 40hz per 1/(MouseX) second
x = {SinOsc.ar(MouseY.kr(30,800,1) + SinOsc.ar(MouseX.kr(1,2000,1).poll, mul:400* SinOsc.kr(EnvGen.kr(Env.new(2*[0.01, 0.25, 0.5,0.9,0.5,0.25, 0.01],[0.4, 0.1, 0.02, 0.02, 0.1, 0.4], [1,-3, 0,0, 3,-1]))))) * 0.2!2}.play;

x.free;

// use these in synthDef
(
SynthDef.new(\fmod_percus, {
	arg carrierHz=440, modHz=100, modAmp=200, atk=0.01, rel=1,amp=0.2,pan=0;
	var car, mod, env;
	env = EnvGen.kr(
		Env.perc(attackTime:atk, releaseTime:rel),
		doneAction:2
	);
	mod = SinOsc.ar(modHz, mul:modAmp);
	car = SinOsc.ar(carrierHz + mod) * env * amp;
	car = Pan2.ar(car, pan);
	Out.ar(0,car);
}).add;
)

y = Synth.new(\fmod_percus, [\carrierHz, 220, \amp, 0.6]);

y.free;


// rubber=y synth
(
Synth(\fmod_percus, [
	\carrierHz, rand(1,127).midicps,
	\modHz, exprand(2,50),
	\modAmp, exprand(1000,10000),
	\amp, exprand(0.1,0.9),
	\atk, exprand(0.001,0.05),
	\rel, exprand(0.5, 2.0),
	\pan, rrand(-0.9, 0.9)
]);
)

// rubbery sequencer
// since we are using pbind, need patter rands not math rands
(
p = Pbind(
	\instrument, \fmod_percus,
	\dur, 1/9,
	\carrierHz, Pwhite(1, 127).round(1).midicps,
	\modHz, Pexprand(2,50),
	\modAmp, Pexprand(1000,10000),
	\amp, Pexprand(0.1,0.9),
	\atk, Pexprand(0.001,0.05),
	\rel, Pexprand(0.5, 2.0),
	\pan, Pwhite(-0.9, 0.9)
).play;
)

p.stop;

s.freeAll;


// FM tutorial 22

// sidebands are the modulations that come from FM


// mouseY = number of sideband pairs
x = {SinOsc.ar(440 + SinOsc.ar(200, mul:MouseY.kr(0,400))) * 0.2!2}.play;

x.free;

//


// the interval at which sidebands appear is equal to the modulator freq

x = {SinOsc.ar(440 + SinOsc.ar(MouseX.kr(-400,400), mul:MouseY.kr(-400,400))) * 0.2!2}.play;


x.free;

// carrier modulator ratio is more useful than defining each outright

(
SynthDef(\fm_rat, {
	arg freq=440, mRatio=1, cRatio=1, modAmp=220,
	amp=0.2, atk=0.01, rel=3, pan=0;
	var car, mod, env;
	env = EnvGen.kr(Env.perc(atk,rel),doneAction:2);
	mod = SinOsc.ar(freq * mRatio, mul:modAmp);
	car = SinOsc.ar(freq * cRatio + mod) * env * amp;
	car = Pan2.ar(car,pan);
	Out.ar(0,car);
}).add;
)

x = Synth.new(\fm_rat, [\freq, 40.midicps, \mRatio, 9, \cRatio, 6]);

(
p = Pbind(
	\instrument, \fm_rat,
	\dur, 1/4,
	\freq, Pseq(#[35,36,37,38],inf).midicps,
	\cRatio, Pwhite(2, 256).round(1),
	\mRatio, Pexprand(2,256).round(1),
	\modAmp, Pexprand(100,1000),
	\amp, Pexprand(0.1,0.9),
	\atk, Pexprand(0.001,0.05),
	\rel, Pexprand(0.5, 2.0),
	\pan, Pwhite(-0.9, 0.9)
).play;
)

p.stop;

// index = modAmp/modHz;

(
SynthDef(\fm_idx, {
	arg freq=440, mRatio=1, cRatio=1, modAmp=220,
	amp=0.2, atk=0.01, rel=3, pan=0, index=1;
	var car, mod, env;
	env = EnvGen.kr(Env.perc(atk,rel),doneAction:2);
	mod = SinOsc.ar(freq * mRatio, mul:freq * mRatio *index);
	car = SinOsc.ar(freq * cRatio + mod) * env * amp;
	car = Pan2.ar(car,pan);
	Out.ar(0,car);
}).add;
)

y = Synth(\fm_idx, [\freq, 66.midicps, \index, 2.5, \rel, 1]);

// index envelope shapes the note on its way
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
y = Synth(\fm_idxenv, [\freq, 20.midicps,
	\index, 20, \mRatio, 32,\cRatio, 48, \iScale,0.05, \cAtk, 4, \cRel, (-4),
	\rel, 1]);
)

(
p = Pbind(
	\instrument, \fm_idxenv,
	\dur, 1/9,
	\freq, Pseq(#[35,36,37,38],inf).midicps,
	//\cRatio, Pwhite(2, 256).round(1),
	//\mRatio, Pexprand(2,256).round(1),
	\index, Pwhite(1,15),
	\cRel, Pwhite (-10, -22),
	\iScale, Pwhite(0.05, 20),
	//\modAmp, Pexprand(100,1000),
	\amp, Pexprand(0.1,0.9),
	\atk, Pexprand(0.001,0.05),
	\rel, Pexprand(0.5, 2.0),
	\pan, Pwhite(-0.9, 0.9)
).play;
)
p.stop;

// calmer version
y = Synth(\fm_idxenv, [\freq, 30.midicps, \rel, 1, \iScale, 20, \cRel, -10]);


//PMOsc is a litte different

// a pseudo ugen, which implements sin osc within sinosc to do
// FM a little more abstractedly and with syntactic sugar
y = {PMOsc.ar(440, 4, 10) * 0.2!2}.play;

y.free;

s.freeAll;

s.boot;

// PMOsc does everything we have implemented on our own, but cant do this
(
SynthDef(\fm_saw, {
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
	mod = VarSaw.ar(freq * mRatio, mul:freq * mRatio * ienv);
	car = SinOsc.ar(freq * cRatio.log(14) + mod) * env * amp;
	car = Pan2.ar(car,pan);
	Out.ar(0,car);
}).add;
)

(
p = Pbind(
	\instrument, \fm_saw,
	\dur, 1/9,
	\freq, Pseq(#[35,36,37,38],inf).midicps,
	//\cRatio, Pwhite(2, 256).round(1),
	//\mRatio, Pexprand(2,256).round(1),
	\index, Pwhite(1,15),
	\cRel, Pwhite (-10, -22),
	\iScale, Pwhite(0.05, 15),
	//\modAmp, Pexprand(100,1000),
	\amp, Pexprand(0.1,0.9),
	\atk, Pexprand(0.001,0.05),
	\rel, Pexprand(0.5, 2.0),
	\pan, Pwhite(-0.9, 0.9)
).play;
)


p.stop;


// Wavetiable synthesis tutorial 23

// Osc is an oscillator with a custom wavetable, not just
//  sin wave

// Signal is an ordered collection

~sig = Signal.sineFill(1024, [1], [0]);
~sig.plot;

// collections must be changes to wavetables to be useful

~wt = ~sig.asWavetable;
~wt.plot("wt");

~sig.size;
~wt.size; // twize as big

~wt.collect({arg n; n}).plot("wavetable"); // contains linear interpolation
~sig.collect({arg n; n}).plot("sine");


// need to hold wavetable in a buffer for osc
b = Buffer.alloc(s, 2048);

b.loadCollection(~wt);
b.plot;

y = {Osc.ar(b, MouseX.kr(110,1000,1),mul:0.2!2)}.play;

y.free;

// now add harmonics to our wavetable

(
~sig = Signal.sineFill(1024,
	[1, 1/4, 1/6, 1/2],
	0!4);
~sig.plot;

// collections must be changes to wavetables to be useful

~wt = ~sig.asWavetable;
~wt.plot("wt");

~sig.size;
~wt.size; // twize as big

~wt.collect({arg n; n}).plot("wavetable"); // contains linear interpolation
~sig.collect({arg n; n}).plot("sine");


// need to hold wavetable in a buffer for osc
b = Buffer.alloc(s, 2048);

b.loadCollection(~wt);
b.plot;
)

y = {Osc.ar(b, MouseX.kr(110,1000,1),mul:0.2!2)}.play;

y.free;


// now lets add custom amps to harmonics "additive sybth"

(
~amps = [1] ++ ({[0, exprand(0.05,0.5)].choose}!31);
~sig = Signal.sineFill(1024,
	~amps,
	0!32);
//~sig.plot;

// collections must be changes to wavetables to be useful

~wt = ~sig.asWavetable;
//~wt.plot("wt");

~sig.size;
//~wt.size; // twize as big

~wt.collect({arg n; n}).plot("wavetable"); // contains linear interpolation
~sig.collect({arg n; n}).plot("sine");


// need to hold wavetable in a buffer for osc
b = Buffer.alloc(s, 2048);

b.loadCollection(~wt);
b.plot;
)

y = {Osc.ar(b, MouseX.kr(110,1000,1),mul:0.2!2)}.play;

y.free;

// using sine3 to generate discontinuity

b.sine3([1.25,3], [1,1], [0.4,-0.6]);

y = {Osc.ar(b, MouseX.kr(110,1000,1),mul:0.2!2)}.play;

y.free;

// can do randon sine3 stuff to make weirder harmonics

(
b.sine3(
	({exprand(0.75, 20)}!16).sort,
	({exprand(0.05, 0.9)}!16).sort.reverse,
	({rrand(0,2pi)}!16));
)

y = {Osc.ar(b, MouseX.kr(110,1000,1)*[1,1.66],mul:0.2!2)}.play;

y.free;

(
var env, sig, wt;
env = Env([0,0.6,-0.9,0.3,0],[4,3,2,1],\sin);
sig = env.asSignal(1024);
wt = sig.asWavetable;
b.loadCollection(wt);
b.plot;
)

y = {Osc.ar(b, MouseX.kr(110,1000,1)*[1,1.583],mul:0.2!2)}.play;

y.free;

// randomized env

(
b.sine3(
	({exprand(0.75, 20)}!16).sort,
	({exprand(0.05, 0.9)}!16).sort.reverse,
	({rrand(0,2pi)}!16));
)

y = {Osc.ar(b, MouseX.kr(110,1000,1)*[1,1.66],mul:0.2!2)}.play;

y.free;

(
var env, sig, wt, numSegs;
numSegs = rrand(4,16);
env = Env(
	// [-1,1] scramble ensures no all-positive or all-neg
	({rrand(-0.9,0.9)}!(numSegs+1) * [-1,1]).scramble,
	{exprand(1,20)}!numSegs,
	{rrand(-19,19)}!numSegs);
sig = env.asSignal(1024);
wt = sig.asWavetable;
b.loadCollection(wt);
b.plot;
)

y = {Osc.ar(b, MouseX.kr(110,1000,1)*[1,1.583],mul:0.2!2)}.play;

y.free;

// LeakDC recenters the waveform if there is bias


// signal as array, filled iteratively

b = Buffer.alloc(s, 2048);

(
// sine wave that "tightens" as it progresses
var sig, wt;
sig = Signal.newClear(1024);
sig.waveFill({
	arg x, old, i;
	var out;
	out = sin(x.pow(1.5));
}, 0, 2pi);
sig.plot;
wt = sig.asWavetable;
b.loadCollection(wt);
)

(
// some kind of wave that "tightens" as it progresses
var sig, wt;
sig = Signal.newClear(1024);
sig.waveFill({
	arg x, old, i;
	var out;
	out = sin(x.pow(1.5));
	// changes:
	out = out * 1.5;
	out = out.fold(-1,1);
}, 0, 2pi);
sig.plot;
wt = sig.asWavetable;
b.loadCollection(wt);
)

(
// as above but cubed
var sig, wt;
sig = Signal.newClear(1024);
sig.waveFill({
	arg x, old, i;
	var out;
	out = sin(x.pow(1.5));
	// changes:
	out = out * 1.5;
	out = out.fold(-1,1);
	out = out.pow(3);
}, 0, 2pi);
sig.plot;
wt = sig.asWavetable;
b.loadCollection(wt);
)
b.plot;


y = {Osc.ar(b, MouseX.kr(110,1000,1)*[1,1.66],mul:0.2!2)}.play;

y.free;

/*
Signal.sineFill
b.sine1/2/3
Env().asSignal
Signal.waveFill
*/



// multi wavetable with vosc tutorial 24




(
~wt0 = Signal.sineFill(
	1024,
	1/(1..8),
	0!8
).asWavetable;

~wt1 = Signal.sineFill(
	1024,
	[1,0,1/2,1,1/4],
	[0,0,pi,0,pi]
).asWavetable;

)

~wt0.plot;
~wt1.plot;



(
~b0 = Buffer.loadCollection(s,~wt0);
~b1 = Buffer.loadCollection(s,~wt1);
)

(
SynthDef.new(\vosc, {
	arg out=0, freq;
	var sig,bufpos;
	bufpos = MouseX.kr(0,1);
	sig = VOsc.ar(bufpos,freq:freq,mul:0.2!2);
	Out.ar(out,sig);
}).add;
)

x = Synth(\vosc, [\freq, 500]);

x.free;

// better synthdef

(
SynthDef.new(\vosc, {
	arg out=0, freq, bufhead=0, numbufs;
	var sig,bufpos;
	bufpos = bufhead + MouseX.kr(0,numbufs-1);
	sig = VOsc.ar(bufpos,freq:freq,mul:0.2!2);
	Out.ar(out,sig);
}).add;
)

x = Synth(\vosc, [\freq, 500]);

x.free;


// consecutive buffers

(
~wt = Array.fill(4, {
	var numSegs = rrand(4,20);
	Env(
	// [-1,1] scramble ensures no all-positive or all-neg
	    ({rrand(-0.9,0.9)}!(numSegs+1) * [-1,1]).scramble,
	    {exprand(1,20)}!numSegs,
	    {rrand(-19,19)}!numSegs
	).asSignal(1024).asWavetable;
});
)

~buf.clear;

~buf = Buffer.allocConsecutive(4, s, 2048);

(
~buf.do({
	arg buf, iter;
	buf.loadCollection(~wt[iter])
});
)

~wt.do({arg n,i; n.plot(~buf[i].bufnum.asString)});

(
SynthDef.new(\vosc, {
	arg out=0, freq, bufhead=0, numbufs;
	var sig,bufpos;
	bufpos = bufhead + MouseX.kr(0,numbufs-1);
	sig = VOsc.ar(bufpos.poll,freq:freq,mul:0.2!2);
	Out.ar(out,sig);
}).add;
)

x = Synth(\vosc, [\freq, 220, \bufhead, ~buf[0].bufnum, \numbufs, 4]);

x.free;

s.reboot;

/// now try it with some cool noise and detune

(
SynthDef.new(\voscnoise, {
	arg out=0, freq=220, bufhead=0, numbufs, amp=0.2;
	var sig,bufpos, detuneSig;
	detuneSig = LFNoise1.kr(0.2!8).bipolar(0.2).midiratio;
	bufpos = bufhead + LFNoise1.kr(0.5).range(0,numbufs-1);
	sig = VOsc.ar(bufpos.poll,freq:freq*detuneSig,mul:0.2!2);
	sig = Splay.ar(sig);
	sig = LeakDC.ar(sig) * amp;
	Out.ar(out,sig);
}).add;
)

x = Synth(\voscnoise, [\freq, 69.midicps, \bufhead, ~buf[0].bufnum, \numbufs, 4]);

x.free;

s.freeAll;

// waveshaping

s.reboot;

// signal and transfer function
// mapping from input to output along a function

// all audio signals in an analog system are transfer
// functions of the sine wave


// need to add an extra value to the env and
// use asWaveTableNoWrap

(
// needed for Shaper
~tf = Env([-0.8, 0, 0.8], [1,1]).asSignal(1025);
~tf = ~tf.asWavetableNoWrap;
)

(
// needed for VOsc, Osc, others..
~tf = Env([-0.8, 0, 0.8], [1,1]).asSignal(102);
~tf = ~tf.asWavetable;
)

// still a power of two
~tf.size;

// simple square wave
(
~tf = Env([-0.8, 0, 0.8], [1,1], [8,-8]).asSignal(1025);
~tf = ~tf.asWavetableNoWrap;
~tfBuf = Buffer.loadCollection(s,~tf);
)


// square wave is y
y = {Shaper.ar(~tfBuf,SinOsc.ar(220))*0.2!2}.play;

y.free;

// function on a wave

// simple square wave
(
// identity function
~tf = Env([-1,1], [1], [0]).asSignal(1025);
// edit identity iwth sinefill
~tf = ~tf + (
	Signal.sineFill(
		size: 1025,
		amplitudes: (0!3) ++ [0.0,0.1,1,1].scramble,
		phases: {rrand(0,2pi)}!9
	)/4;
);
~tf = ~tf.normalize;
~tf.plot;
~tf = ~tf.asWavetableNoWrap;
~tfBuf = Buffer.loadCollection(s,~tf);
)


// different kind of wave
y = {Shaper.ar(~tfBuf,SinOsc.ar(220))*0.2!2}.play;

// same but with line taking us through all the shapes along the trransfer function
(
y = {
	var sig, input;
	input = SinOsc.ar(120) * Line.kr(0,1,7);
	sig = Shaper.ar(~tfBuf,input);
	sig = sig * 0.3!2;
}.play;
)

y.free;

//as above but with random cycle of transfer function
(
y = {
	var sig, input;
	input = SinOsc.ar(120) * LFNoise1.kr(0.5).range(0.01,1);
	sig = Shaper.ar(~tfBuf,input);
	sig = sig * 0.3!2;
}.play;
)

y.free;


//as above with additonal channels and differe noise
(
y = {
	var sig, input;
	input = SinOsc.ar({120 * Rand(-0.1,0.1).midiratio}!8);
	input = input * BrownNoise.kr(0.5!8).range(0.1,1);
	sig = Shaper.ar(~tfBuf,input);

	sig = Splay.ar(sig) * 0.3;
}.play;
)


y.free;

{LFTri.ar(250)}.plot;

// the LF series gives us a whole lot of wave shapes



{LFPar.ar(250)}.plot;


// Granular Synthesis tutorial 25


// only works with mono audio

//dictionary of samples
(
d = Dictionary.new;
d.add(\m ->
	PathName("C:/Users/kouck/Music/freesounds/metal").entries.collect({
		arg sf;
		Buffer.readChannel(s,sf.fullPath, channels:[0]);
	});
);
d.add(\w ->
	PathName("C:/Users/kouck/Music/freesounds/water").entries.collect({
		arg sf;
	Buffer.readChannel(s,sf.fullPath, channels:[0]);
	});
);
d.add(\l ->
	PathName("C:/Users/kouck/Music/freesounds/solid").entries.collect({
		arg sf;
		Buffer.readChannel(s,sf.fullPath, channels:[0]);
	});
);
d.add(\k ->
	PathName("C:/Users/kouck/Music/freesounds/drinking").entries.collect({
		arg sf;
		Buffer.readChannel(s,sf.fullPath, channels:[0]);
	});
);
)

// check loading correct
d[\k][3].play;
d[\m][0].numChannels;


// GrainBuf should be enough

s.reboot;
(
s.meter;
s.plotTree;
s.scope;
)

(
y = {
	var sig;
	sig = GrainBuf.ar(
		numChannels: 1,
		trigger: Impulse.ar({ExpRand(2,200)}!12),
		dur: LFNoise0.kr(1.3!12).range(0.1,2.5),
		sndbuf: d[\l][0].bufnum,
		rate:1,
		pos:LFNoise0.ar(500).range(0,1),// normalized to len
		interp: 2,
		pan: -0.3,
		envbufnum: -1,
		maxGrains:512,
		mul:1,
		add:0
	);
	sig = Splay.ar(sig);
}.play;
)

// make it a synthdef
(
SynthDef.new(\grains, {
	arg bufno=0, amp= 0.5, itp=2, genv=(-1);
	var sig;
	sig = GrainBuf.ar(
		numChannels: 2,
		//trigger: Impulse.ar({ExpRand(2,200)}!12),
		//trigger: Impulse.ar(100!12),
		trigger: Dust.ar(100),
		//dur: LFNoise0.kr(0.3!12).range(0.1,2.5),
		dur: 0.2,
		sndbuf: bufno,
		//rate:1, // normal rate with not weirdness
		//rate:0.5, // lower tone
		//rate: 1.3, // higher tone
		rate: MouseX.kr(0.5,1.9),
		//pos:LFNoise0.ar(500).range(0,1),// normalized to len
		//pos: Line.ar(0,1,BufDur.ir(b),doneAction:2),
		/*
		// play whole sample with lfsaw
		pos: (
			(LFSaw.ar(1/BufDur.ir(b)).range(0,BufSamples.ir(b))
			+LFNoise0.ar(100).bipolar(0.01*SampleRate.ir))
			/ BufSamples.ir(b)
		),
		*/
		/* // play whole sample with sweep
		pos: (

			Sweep.ar(
				Impulse.ar(1/BufDur.ir(b)),
				0.2*BufRateScale.ir(b))
			*SampleRate.ir
			+LFNoise0.ar(100).bipolar(0.01*SampleRate.ir)
			/ BufSamples.ir(b)
		),
		*/
		pos: (

			Phasor.ar(0,1*BufRateScale.ir(b), 0, BufSamples.ir(b)-1)
			+LFNoise0.ar(100).bipolar(0.01*SampleRate.ir)
			/ BufSamples.ir(b)
		),
		interp: itp,
		pan: 0,
		envbufnum: genv,
		maxGrains:512,
		mul:1,
		add:0
	);
	sig = Splay.ar(sig) *amp;
	Out.ar(0,sig);
}).add;
)

y = Synth(\grains, [\bufno, d[\m][0].bufnum, \amp, 0.7, \itp, 3]);

y.free;

x = Synth(\grains, [\bufno, d[\k][3].bufnum, \amp, 0.7, \itp, 3]);

x.free;

//add grain envelope

(
var grainenv;
e = Env.new(2*[0.01, 0.25, 0.5,0.9,0.5,0.25, 0.01],[0.4, 0.1, 0.02, 0.02, 0.1, 0.4], [1,-3, 0,0, 3,-1]);
grainenv = Buffer.sendCollection(s, e.discretize(8192));
z = Synth(\grains, [\bufno, d[\m][0].bufnum, \amp, 0.7, \itp, 3, \genv, grainenv.bufnum]);
)

z.free;

s.freeAll;


// ar vs kr
// ar is for high rates
// kr is for low rates
//



// Granular Synthesis tutorial 26

// for live audio

ServerOptions.devices;

(
s.options.inDevice_("External Microphone");
s.options.outDevice_("Internal AUX Jack");
s.boot;
s.meter;
)

(
x = {
	var sig;
	sig = SoundIn.ar(0!2);
	sig = sig + CombN.ar(sig, decayTime:3, mul:0.5);
}.play;
)

x.free;


b = Buffer.alloc(s, s.sampleRate*5, 1);

(
~micBus = Bus.audio(s,1);
~ptrBus = Bus.audio(s,1);
)

(
SynthDef.new(\mic, {
	arg in=0, out=0, amp=1;
	var sig;
	sig=SoundIn.ar(in)*amp;
	Out.ar(out, sig);
}).add;

SynthDef.new(\ptr, {
	arg out=0, buf=0;
	var sig;
	sig = Phasor.ar(0, BufRateScale.kr(buf),0,BufFrames.kr(buf));
	Out.ar(out,sig);
}).add;

SynthDef.new(\rec, {
	arg ptrIn=0, micIn=0, buf=0;
	var ptr, sig;
	ptr = In.ar(ptrIn, 1);
	sig = In.ar(micIn, 1);
	BufWr.ar(sig,buf,ptr);
}).add;

SynthDef.new(\gran, {
	arg amp=0.5, buf=0, out=0,
	atk=1, rel=1, gate=1,
	sync=1, dens=40,
	baseDur=0.05, durRand=1,
	rate=1, rateRand=1,
	pan=0, panRand=0,
	grainEnv=(-1), ptrBus=0, ptrSampleDelay=20000,
	ptrRandSamples=5000, minPtrDelay=1000;

	var sig, env, densCtrl, durCtrl, rateCtrl, panCtrl,
	ptr, ptrRand, totalDelay, maxGrainDur;

	env=EnvGen.kr(Env.asr(atk,1,rel),gate,doneAction:2);
	densCtrl = Select.ar(sync,[Dust.ar(dens),Impulse.ar(dens)]);
	durCtrl = baseDur * LFNoise1.ar(100).exprange(1/durRand,durRand);
	rateCtrl = rate * LFNoise1.ar(100).exprange(1/rateRand,rateRand);
	panCtrl = pan + LFNoise1.kr(100).bipolar(panRand);

	ptrRand = LFNoise1.ar(100).bipolar(ptrRandSamples);
	totalDelay = max(ptrSampleDelay - ptrRand, minPtrDelay);

	ptr = In.ar(ptrBus, 1);
	ptr = ptr - ptrSampleDelay;
	ptr = ptr / BufFrames.kr(buf);
	ptr = ptr % 1; // might not be necessary

	//maxGrainDur = totalDelay / SampleRate.ir;
	//durCtrl = min(durCtrl,maxGrainDur);

	maxGrainDur = (totalDelay / rateCtrl) / SampleRate.ir;
	durCtrl = min(durCtrl,maxGrainDur);

	sig = GrainBuf.ar(
		2,
		densCtrl,
		durCtrl,
		buf,
		rateCtrl,
		ptr,
		2,
		panCtrl,
		grainEnv
	);

	sig = sig * env * amp;
	Out.ar(out,sig);
}).add;
)

s.plotTree;
// line up your synth
(
~micGrp = Group.new;
~ptrGrp = Group.after(~micGrp);
~recGrp = Group.after(~ptrGrp);
~granGrp = Group.after(~recGrp);
)

(
m = Synth(\mic,
	[\in, 0, \out, ~micBus],
	~micGrp);
p = Synth(\ptr,
	[\buf, b, \out, ~ptrBus],
	~ptrGrp);
r = Synth(\rec,
	[\ptrIn, ~ptrBus, \micIn, ~micBuf, \buf, b],
	~recGrp);
)


//21:29
(
b.zero;
g = Synth(\gran,
	[
		\

	],
	~granGrp);
)


m.free;
p.free;
r.free;

// Classes tutorial

Object.browse;

VerbEF.browse;

//dictionary of samples
(
d = Dictionary.new;
d.add(\m ->
	PathName("C:/Users/kouck/Music/freesounds/metal").entries.collect({
		arg sf;
		Buffer.readChannel(s,sf.fullPath, channels:[0]);
	});
);
d.add(\w ->
	PathName("C:/Users/kouck/Music/freesounds/water").entries.collect({
		arg sf;
	Buffer.readChannel(s,sf.fullPath, channels:[0]);
	});
);
d.add(\l ->
	PathName("C:/Users/kouck/Music/freesounds/solid").entries.collect({
		arg sf;
		Buffer.readChannel(s,sf.fullPath, channels:[0]);
	});
);
d.add(\k ->
	PathName("C:/Users/kouck/Music/freesounds/drinking").entries.collect({
		arg sf;
		Buffer.readChannel(s,sf.fullPath, channels:[0]);
	});
);
)

// check loading correct
d[\k][3].asWavetable.plot;
d[\m][0].numChannels;

VerbEF.browse;

s.boot;

(
SynthDef.new(\verbed, {
	arg out=0, freq, bufhead=0, numbufs;
	var sig, env;
	env = EnvGen.ar(Env.perc(0.01,2.0), doneAction:2);
	sig = SinOsc.ar(freq);
	sig = sig * env;
	sig = VerbEF.ar(sig);
	Out.ar(out,sig);
}).add;
)

d[\k][0].bufnum;

y = Synth.new(\verbed, [\freq, 220]);

y.free;

s.freeAll;



