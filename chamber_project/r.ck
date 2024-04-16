// Test receiver for syncing time

// patch
SinOsc s => dac;
.0 => s.gain;
440 => s.sfreq;

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

// create an address in the receiver, expect an int
oin.addAddress( "/pulse, i" );

// infinite event loop
while( true )
{
    // wait for event to arrive
    oin => now;

    // grab the next message from the queue. 
    while( oin.recv(msg) )
    {
      0.5 => s.gain;
      100::ms => now;
      0.0 => s.gain;
      100::ms => now;
    }
}