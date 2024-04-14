// Test receiver for syncing time

// patch
SinOsc s => JCRev r => dac;
.0 => s.gain;
.1 => r.mix;
440 => s.sfreq;

// create our OSC receiver
OscIn oin;
// create our OSC message
OscMsg msg;

// ms between largest period
600 => int period;
1 => int subdiv;

if( me.args() > 1 ) 
{
  me.arg(0) => Std.atoi => oin.port;
  me.arg(1) => Std.atoi => subdiv;
} else {
  <<< "Error: command line args invalid" >>>;
}

// create an address in the receiver, expect an int
oin.addAddress( "/pulse, i" );

0 => int counter;

// infinite event loop
while( true )
{
    // wait for event to arrive
    oin => now;

    // grab the next message from the queue. 
    while( oin.recv(msg) )
    { 
      counter + msg.getInt(0) => counter;

      if ( counter == period )
      {
        0 => counter;
      }

      if ( counter % ( period / subdiv ) == 0 )
      {
        0.5 => s.gain;
        100::ms => now;
        0.0 => s.gain;
        100::ms => now;
      }
    }
}