/// formants

// Formant
// a Ugen

// fundfreq : the fundamental
// formfreq : the formant frequency
// bwfreq   : the pulse width, a kr
(
SynthDef(\formo, {
	arg fund=220, ff1=360, ff2=640, bw=280;
	var form1, form2, sig, bw2, env;
	bw2 = 0-bw;
	env = EnvGen.ar(Env.adsr(0.1, 0.8,0.3,0.4,0.7,curve:4));
	form1 = Formant.ar(fund, ff1, bw) * env;
	form2 = Formant.ar(fund, ff2, bw2) * env;
	sig = Splay.ar([form1,form2],2);
	DetectSilence.ar(sig,doneAction:2);
	Out.ar(0, sig);
}).add;
)

y = Synth(\formo);
y.set(\form1, 700, \form2, 760, \bw, 60);

y.free;

s.boot;

// voice synthesis from composerprogrammer

(

SynthDef(\voicesound6,{|voiced=1 freq= 440 amp=0.1 resonancescaling=5|

var formantfreqs, formantamps, formantbandwidths; //data for formants

var periodicsource, aperiodicsource, source, output;

var vibrato;

var vibratonoise= LFNoise1.kr(10);


formantfreqs= [280,2250,2890,3900,4950]; //centre frequencies of formants

formantamps= ([0 ,-6,-32,-20,-50]-6).dbamp; //peaks of formants

formantbandwidths=[80,90,120,130,140];  //bandwidths


//with vibrato up to quartertone, rate of vibrato around 6+-1 Hz

//calculate vibrato in midi note (log frequency) domain; final .midicps takes it back to frequency

//line generator delays onset of vibrato like a real singer

vibrato= ((freq.cpsmidi)+(Line.kr(0.0,1.0,2.5)*SinOsc.kr(6+(1.0*vibratonoise),0,0.5))).midicps;


// low pass filter on Impulse to avoid high harmonics making it too bright

periodicsource= LPF.ar(Impulse.ar(vibrato),5000);


//pink noise drops off as frequency increases at -dB per octave,

aperiodicsource= PinkNoise.ar(0.7);


//take now as mixture of periodic and aperiodic

source= (voiced*periodicsource)+((1.0-voiced)*aperiodicsource);


//the decaytime of the formlet is the filter's resonant decay time; a small bandwidth corresponds to a long decay (a 'ringing' filter). So I take the reciprocal of the formant bandwidth as an estimate of decaytime here, multiplied by a scaling factor for degree of resonance

output= Mix(Formlet.ar(source, formantfreqs, 0.001, resonancescaling*formantbandwidths.reciprocal, formantamps))*10*amp;

Out.ar(0,output.dup)

}).add;

)
a= Synth(\voicesound6, [\freq, 220])


//can now set to intermediate mixes of vowel and consonant

a.set(\voiced, 1)

a.set(\freq, 110)

a.set(\resonancescaling,5)

a.set(\resonancescaling, 2)

a.free;


// make voice-sound a little more natural

(

SynthDef(\voicesound6,{

	arg freq= 220, voiced=1, amp=0.1, resScale=5,
	form1hz=280, form2hz=2250, form3hz=2890, form4hz=3900, form5hz=4950,
	vibLev = 6;

	var formAmp, formBW; //data for formants

	var periodicsource, aperiodicsource, source, output;

	var vibrato, form1, form2, form3, form4, form5, sig;

	var vibratonoise= SinOsc.ar(5,0,EnvGen.kr(Env([0,2],[0.2],4),1));

	//formantfreqs= [280,2250,2890,3900,4950]; //centre frequencies of formants

	formAmp= ([0 ,-6,-32,-20,-50]-6).dbamp; //peaks of formants

	formBW=[80,90,120,130,140];  //bandwidths

	// midicps makes math easier
	vibrato= (
		(freq.cpsmidi)
		+(Line.kr(0.0,1.0,2.5)
			*SinOsc.kr(vibLev+(1.0*vibratonoise),0,0.5)
	     )
	).midicps;

	// filter relies on vibrato
	//periodicsource = LPF.ar(Impulse.ar(vibrato),5000);
	periodicsource= LPF.ar(Pulse.ar(vibrato,LFNoise2.kr(LFNoise1.kr(1,0.25,0.5),0.1,0.5)),5000);

	// aperiodic source provides "breathiness" when voiced
	aperiodicsource= PinkNoise.ar(0.7);
	source = (voiced*periodicsource)+((1.0-voiced)*aperiodicsource);


	//the decaytime of the formlet is the filter's resonant decay time;
	// a small bandwidth corresponds to a long decay (a 'ringing' filter).
	// So I take the reciprocal of the formant bandwidth as an estimate of
	// decaytime here, multiplied by a scaling factor for degree of resonance

	form1 = amp * 10 * Formlet.ar(
		in: source,
		freq: form1hz,
		attacktime: 0.001,
		decaytime: resScale * formBW[0].reciprocal,
		mul: formAmp[0]
	);

	form2 = amp * 10 * Formlet.ar(
		in: source,
		freq: form2hz,
		attacktime: 0.001,
		decaytime: resScale * formBW[1].reciprocal,
		mul: formAmp[1]
	);

	form3 = amp * 10 * Formlet.ar(
		in: source,
		freq: form3hz,
		attacktime: 0.001,
		decaytime: resScale * formBW[2].reciprocal,
		mul: formAmp[2]
	);

	form4 = amp * 10 * Formlet.ar(
		in: source,
		freq: form4hz,
		attacktime: 0.001,
		decaytime: resScale * formBW[3].reciprocal,
		mul: formAmp[3]
	);

	form5 = amp * 10 * Formlet.ar(
		in: source,
		freq: form5hz,
		attacktime: 0.001,
		decaytime: resScale * formBW[4].reciprocal,
		mul: formAmp[4]
	);

	sig = [form1, form2, form3, form4, form5];

	sig = BPF.ar(source, sig,(formBW+LFNoise2.kr(LFNoise1.kr(1,0.5,4),10))/sig,formAmp);

	output = Splay.ar(sig,4);

	Out.ar(0,output!2)

}).add;

)


y = Synth(\voicesound6, [\freq, 220])

y.set(\voiced, 1, \freq, 220,\resScale, 50)

y.free;

s.freeAll;

//// try to incorporate the two

(
SynthDef(\formo, {
	arg fund=220, form1hz=280, form2hz=2250, form3hz=2890, form4hz=3900, form5hz=4950, bw=280;
	var form1, form2,form3,form4,form5, sig, bw2, env;
	bw2 = 0-bw;
	env = EnvGen.ar(Env.adsr(
		attackTime: 0.1,
		decayTime:0.7,
		sustainLevel:0.5,
		releaseTime:1.0,
		curve:-4
	));
	form1 = Formant.ar(fund, form1hz);
	form2 = Formant.ar(fund, form2hz);
	form3 = Formant.ar(fund, form3hz);
	form4 = Formant.ar(fund, form4hz);
	//form5 = Formant.ar(fund, form5hz, bw2) * env;
	sig = [form1,form2,form3,form4];
	sig = sig * env;
	sig = Splay.ar(sig,2);
	DetectSilence.ar(sig,doneAction:2);
	Out.ar(0, sig);
}).add;
)

y = Synth(\formo);
y.set(\form1, 700, \form2, 760, \bw, 60);

y.free;

s.boot;

// hmm, what avout that russian guy

///////////////////////////////////// grainsin
// to create formants
// from alikthename on github

(

SynthDef.new(\gsin, {
	arg grainrate=1,
	level=0.3, freq = 440,
	trigg, formA=2, formB=6, formC=8,
	overA=2, overB=2, overC=2, gate=1;

	var sig, ef, ef_, fone, ftwo, fthree, three,
	four, five, six, fund;

	ef = freq;

	ef_ = ef.clip.(50,1500);

	five = EnvGen.kr(
		Env.perc(
			attackTime: (ef_.linlin(50,1500,0.1,0.2)),
			releaseTime: Rand(1,7)
		),
		gate: gate
	);

	// add some pinknoise for naturalism
	five = five * PinkNoise.ar(1!2).range( 0.1, 1 ).lag(0.02) ;

	fund = GrainSin.ar(
		numChannels:1,
		trigger: Impulse.ar(ef),
		dur: Rand(0.5, 2) * (1.05 - five.pow(1.1))
		* VarSaw.ar(five * 3, {Rand(0,6.28)}.dup).range(0.87,1.15) / ef,

		freq: ef,
		//* SinOsc.ar(five * 3, {Rand(0,6.28)}.dup).range(0.9,1.5),

		pan: PinkNoise.ar(0.5!2)
	);

	// one and two are formants, same but with dif multipliers
	// and two more rdm
	fone = GrainSin.ar(
		numChannels:1,
		trigger: Impulse.ar(ef + Rand(-3,3)),
		dur: overA * (1.05-five.pow(1.5))
		* SinOsc.ar(five * 4, {Rand(0,6.28)}.dup).range(0.87, 1.15) / ef,
		freq: ef * (formA
			* SinOsc.ar(five * 4, {Rand(0,6.28)}.dup).range(0.9,1.1)),
		pan: PinkNoise.ar(0.5!2)
	);
	ftwo = GrainSin.ar(
		numChannels:1,
		trigger: Impulse.ar(ef + Rand(-3,3)),
		dur: overB * (1.05-five.pow(2.5))
		* SinOsc.ar(five * 6, {Rand(0,6.28)}.dup).range(0.87, 1.15) / ef,
		freq: ef * (formB
			* VarSaw.ar(five * 5, {Rand(0,6.28)}.dup).range(0.9,Rand(1,1.5))),
		pan: PinkNoise.ar(0.5!2)
	);
	fthree = GrainSin.ar(
		numChannels:1,
		trigger: Impulse.ar(ef + Rand(-3,3)),
		dur: overC * (1.05-five.pow(2.1))
		* SinOsc.ar(five * 6, {Rand(0,6.28)}.dup).range(0.87, 1.15) / ef,
		freq: ef * (formC
			* VarSaw.ar(five * 5, {Rand(0,6.28)}.dup).range(0.9,Rand(1,1.5))),
		pan: PinkNoise.ar(0.5!2)
	);


	three = Splay.ar([
		fund * (level * five).pow(0.7),
		fone * (level * five).pow(ef_.linlin(50,1500,1.1,1.5)),
		ftwo * (level * five).pow(ef_.linlin(50,1500,1.1,2.5)),
		fthree * (level * five).pow(ef_.linlin(50,1500,1.1,2.1))
	],2);

	three = LeakDC.ar(three);

	four = three;

	4.do({
		arg i;
		four = AllpassC.ar(
			in: four,
			delaytime: LFNoise1.kr(0.2!2).range(0.01,0.02)
		);
		//four = LPF.ar(four, 2000);
	} * 0.05);

	four = three * Rand(0.1,0.9) + four;

	DetectSilence.ar(four,doneAction:2);
	/*
	sig = GrainSin.ar(
		numChannels: 1,
		trigger: Impulse.kr(1),
		dur: 1,
		freq: fund
	);
	sig = Splay.ar(sig,2);
	*/

	Out.ar(0,four);

}).add;

)

s.boot;
(
y = Synth(\gsin, [\freq,220,
	\formB, 690, \formA, 1660, \formC, 2490
]);
)

y.set(\fund, 340);
y.set(\grainrate, 660);
y.free;

s.options.memSize;

s.reboot;

s.freeAll;

Pbind(
	\instrument \gsin
)




