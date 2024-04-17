// Test receiver for syncing time

// Array of file path for first voice
["Droplets_tuned/d.aif", "Droplets_tuned/a.aif", "Droplets_tuned/g.aif", "Droplets_tuned/high_c.aif"] @=> string files[];

// Patch
SndBuf buf => Gain feedback => Delay delay => NRev reverb => dac;
0.0 => buf.gain;


// Delay Settings
.75::second => delay.max => delay.delay;
// set feedback
.5 => feedback.gain;
// set effects mix
.75 => delay.gain;

// Reverb Settings
0.1 => reverb.mix;

1 => int d;
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

if( me.args() > 1 )
{
  me.arg(1) => Std.atoi => d;
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
    if ( count == d )
    {
      0 => count;
      spork ~ boop();
    }
    pulse::ms => now;
    count + 1 => count;
  }
}

fun void boop() {
    files[fileIndex] => buf.read;   // Load the current file
    1.0 => buf.gain;
    buf.pos(0);
    buf.play();
    holdLength::ms => now;
    0.0 => buf.gain;
    
    
    // Increment and wrap the index
    (fileIndex + 1) % files.size() => fileIndex;
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