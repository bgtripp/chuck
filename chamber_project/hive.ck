// HIVE dendrop

0 => int myId;

[
  "Droplets_tuned/Low_c.aif",
  "Droplets_tuned/d.aif",
  "Droplets_tuned/e.aif",
  "Droplets_tuned/f.aif",
  "Droplets_tuned/g.aif",
  "Droplets_tuned/a.aif", 
  "Droplets_tuned/b.aif",
  "Droplets_tuned/high_c.aif"
] @=> string files[];

// Droplet patch
Delay delays[files.size()];
NRev revs[files.size()];
LPF lp;
SndBuf buf[files.size()];
Gain dropGain;

for (int i; i < files.size(); i++) {
  buf[i] => dropGain => delays[i] => revs[i] => lp => dac;
  .75 => delays[i].gain;
  0.5 => dropGain.gain;
  .75::second => delays[i].max => delays[i].delay;
  files[i] => buf[i].read;
  0.0 => buf[i].gain;
  0.1 => revs[i].mix;
}

// Rain patch
SndBuf rainBuf[2];
Gain rainGain;
0.1 => rainGain.gain;

for (int i; i < 2; i++)
{
  rainBuf[i] => rainGain => dac;
  "rain.wav" => rainBuf[i].read;
}

// Thunder patch
SndBuf thunder;
Gain thunderGain;
0.0 => thunderGain.gain;
thunder => thunderGain => dac;
"thunder.wav" => thunder.read;

fun play( int i )
{
  if ( i == 100 )
  {
    0.8 => thunderGain.gain;
    thunder.pos(0);
    thunder.play();
    19::second => now;
  }
  else
  {
    0.5 => buf[i].gain;
    buf[i].pos(0);
    buf[i].play();
    100::ms => now;
    0.0 => buf[i].gain;
  }
}

fun void rainLoop() {
  while( true )
  {
    spork ~ rain(0);
    14::second => now;
    spork ~ rain(1);
    30::second => now;
  }
}

fun void rain(int i) {
  rainBuf[i].pos(0);
  rainBuf[i].play();
}

fun listenOrchestrate()
{
  OscIn oin;
  OscMsg msg;
  7777 => oin.port;
  oin.addAddress( "/orchestrate, i i" );

  while ( true )
  {
    oin => now;

    while ( oin.recv( msg ) )
    {
      if ( msg.getInt(0) == 0 || msg.getInt(0) == myId )
      {
        <<< "Playing ", msg.getInt(1) >>>;
        spork ~ play( msg.getInt(1) );
      }
    }
  }
}

fun listenSoundcraft()
{
  OscIn oin;
  OscMsg msg;
  7777 => oin.port;
  oin.addAddress( "/soundcraft, i i f" );

  while ( true )
  {
    oin => now;

    while ( oin.recv( msg ) )
    {
      if ( msg.getInt(0) == 0 || msg.getInt(0) == myId )
      {
        <<< "Setting ", msg.getInt(1),  " to ", msg.getFloat(2) >>>;
        if ( msg.getInt(1) == 0 ) 
        {
          msg.getInt(2) => dropGain.gain;
        }
        else if ( msg.getInt(1) == 1 )
        {
          msg.getFloat(2) => rainGain.gain;
        }
      }
    }
  }
}

spork ~ rainLoop();
spork ~ listenOrchestrate();
spork ~ listenSoundcraft();

while ( true )
  1::second => now;