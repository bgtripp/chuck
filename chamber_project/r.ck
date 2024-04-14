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
// use port 6449 (or whatever)
6449 => oin.port;
// create an address in the receiver, expect an int
oin.addAddress( "/time, i" );

// infinite event loop
while( true )
{
    // wait for event to arrive
    oin => now;

    // grab the next message from the queue. 
    while( oin.recv(msg) )
    { 
      0.5 => s.gain;
      msg.getInt(0)::ms => now;
      0.0 => s.gain;
      msg.getInt(0)::ms => now;
    }
}