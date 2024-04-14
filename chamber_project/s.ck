// Test sender for syncing time

// patch
SinOsc s => JCRev r => dac;
.0 => s.gain;
.1 => r.mix;
220 => s.sfreq;
// ms between pulses
200 => int period;


// destination host name
"localhost" => string hostname;
// destination port number
6449 => int port;

// sender object
OscOut xmit;

// aim the transmitter at destination
xmit.dest( hostname, port );

// infinite time loop
while( true )
{
    // start the message...
    xmit.start( "/time" );
    period => xmit.add;
    xmit.send();

    0.5 => s.gain;
    period::ms => now;
    0.0 => s.gain;
    period::ms => now;
}