// Some ideas:
// Variables to control: tremolo speed, fundamental freq,
// relative loudness of partials (each coming from a different channel)

// # of channels
2 => int CHANNELS;

// array of triangle oscillators
SinOsc oscs[CHANNELS];

// loop to connect them all
for( int i; i < CHANNELS; i++ )
{
    // connect
    oscs[i] => dac.chan(i);
    .15 => oscs[i].gain;
}

// infinite time loop
220 => int fund;
0.0 => float t;
while( true )
{
    // modulate
    for( int i; i < CHANNELS; i++ ) {
        // Set frequencies to integer multiples (harmonics) of fundamental
        fund * (i + 1) + ( Math.sin(t) + 1.0 ) * 10.0 => oscs[i].sfreq;
    }
    t + .04 => t;

    // advance time
    1::ms => now;
}