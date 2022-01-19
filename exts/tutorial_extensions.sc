+ Env {
	*rand {
		arg numSegs, dur=1,bipolar=true;
		var env, levels, times, curves, minLevel;
		levels = {rrand(-1.0,1.0)}!(numSegs+1);
		minLevel = bipolar.asInteger.neg;
		levels = levels.normalize(minLevel,1);
		times = {exprand(1,10)}!numSegs;
		times = times.normalizeSum * dur;
		curves = {rrand(-4.0,4.0)}!numSegs;
		env=this.new(levels,times,curves);
		^env;
	}
}

+ SimpleNumber {

	*playmidi {
		arg out=0;
		{
			var sig;
			sig = SinOsc.ar(this.midicps) * EnvGen(Env.perc(0.001,0.2),doneAction:2)*0.5!2;
			Out.ar(out,sig);
		}.play;
	}
}