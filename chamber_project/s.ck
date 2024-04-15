// Test sender for syncing time

// patch
SinOsc s => dac;
.0 => s.gain;
220 => s.sfreq;
// ms between pulses
100 => int pulse;


// destination host name
"localhost" => string hostname;
// destination port number
4444 => int port;

// sender object
OscOut xmit;

// aim the transmitter at destination
xmit.dest( hostname, port );

fun void sendPulse()
{
  while( true )
  {
    xmit.start( "/pulse" );
    pulse => xmit.add;
    xmit.send();
    pulse::ms => now;
  }
}

fun void boop()
{
  while( true )
  { 
    0.5 => s.gain;
    pulse::ms => now;
    0.1 => s.gain;
    pulse::ms => now;
  }
}

spork ~ sendPulse();
spork ~ boop();
   
// infinite time loop - to keep child shreds around
while( true )
      1::second => now;