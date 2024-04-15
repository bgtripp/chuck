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
  <<< "Error: command line args invalid" >>>;
}

3 => int subdiv;

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
      msg.getInt(0) => int pulse;
      0.5 => s.gain;
      pulse::ms => now;
      0.1 => s.gain;
      pulse::ms * ( subdiv + 1 ) => now;
    }
}