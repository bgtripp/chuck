// Test receiver for syncing time

// Array of file path for first voice
[
  "Droplets_tuned/d.aif", 
  "Droplets_tuned/a.aif", 
  "Droplets_tuned/g.aif", 
  "Droplets_tuned/high_c.aif"
] @=> string files[];

// Patch
SndBuf buf[files.size()] => Gain feedback => Delay delay => NRev reverb => dac;
for (int i; i < files.size(); i++) {
  0.0 => buf[i].gain;
}

// Delay Settings
.75::second => delay.max => delay.delay;
// set feedback
.5 => feedback.gain;
// set effects mix
.75 => delay.gain;

// Reverb Settings
0.1 => reverb.mix;

[2, 3, 5, 7] @=> int d[];
0 => int count;
1000 => int pulse;
100 => int holdLength;

// create our OSC receiver
OscIn oin;
// create our OSC message
OscMsg msg;

if( me.args() ) 
{
  me.arg(0) => Std.atoi => oin.port;
} else {
  <<< "Error: must specify port." >>>;
}

// create an address in the receiver, expect an int
oin.addAddress( "/sync, i" );

fun void update() {
  while( true )
  {
    oin => now;

    while ( oin.recv(msg) )
    {
      setPulse(msg.getInt(0));
    }
  }
}

fun void soundLoop() {
  while( true )
  {
    for (int i; i < d.size(); i++)
    {
      if ( count % d[i] == 0)
      {
        spork ~ boop(i);
        <<< "played " + i >>>;
      }
    }

    pulse::ms => now;
    count + 1 => count;
  }
}

fun void boop(int i) {
    files[i] => buf[i].read;   // Load the current file
    1.0 => buf[i].gain;
    buf[i].pos(0);
    buf[i].play();
    holdLength::ms => now;
    0.0 => buf[i].gain;
}

fun void setPulse(int bpm)
{
  60000 / bpm => pulse;
}

spork ~ update();

// Wait for initial sync
oin => now;

if ( oin.recv(msg) )
{
  setPulse(msg.getInt(0));
  spork ~ soundLoop();
}

while( true )
  1::second => now;