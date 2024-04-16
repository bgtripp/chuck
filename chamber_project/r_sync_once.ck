// Test receiver for syncing time

// patch
SinOsc s => dac;
.0 => s.gain;
440 => s.sfreq;

2 => int d;

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
oin.addAddress( "/sync" );

oin => now;

if ( oin.recv(msg) )
{
  boop(d);
}

fun void boop(int d) {
  while( true )
  {
    0.5 => s.gain;
    100::ms => now;
    0.0 => s.gain;
    ((d - 1) * 100)::ms => now;
  }
}