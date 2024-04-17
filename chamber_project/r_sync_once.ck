// Test receiver for syncing time

// patch
SinOsc s => dac;
.0 => s.gain;
440 => s.sfreq;

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
  me.arg(1) => Std.atoi => s.sfreq;
}

if( me.args() > 2 )
{
  me.arg(2) => Std.atoi => d;
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
  0.5 => s.gain;
  holdLength::ms => now;
  0.0 => s.gain;
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