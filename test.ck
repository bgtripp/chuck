// Some ideas:
// Variables to control: fundamental freq,
// relative loudness of partials (each coming from a different channel)

// # of channels
6 => int CHANNELS;
// which mouse
0 => int device;

TriOsc oscs[CHANNELS];
Envelope envs[CHANNELS];

for( int i; i < CHANNELS; i++ )
{
    // connect
    oscs[i] => envs[i] => dac.chan(i);
    0.0 => oscs[i].gain;
    // attack
    10::ms => envs[i].duration;
    .5 => envs[i].gain;
}
// Initialize fundamental gain
0.5 => oscs[0].gain;

// HID input and HID message
Hid hi;
HidMsg msg;

// try
if( !hi.openMouse( device ) ) me.exit();
<<< "mouse '" + hi.name() + "' ready...", "" >>>;

0.0 => float x;
0.0 => float y;
0.0 => float t;
while( true )
{
    // wait on event
    hi => now;
    
    // loop over messages
    while( hi.recv( msg ) )
    {
        if( msg.isMouseMotion() )
        {
            msg.deltaX * .001 + x => x;
            msg.deltaY * .001 + y => y;
            set( x, y );

        }
        else if( msg.isButtonDown() )
        {
            for( int i; i < CHANNELS; i++ )
            {
                envs[i].keyOn();
            }
        }

        else if( msg.isButtonUp() )
        {
            for( int i; i < CHANNELS; i++ )
            {
                envs[i].keyOff();
            }
        }
    }
}

fun void set( float x, float y )
{
    for( int i; i < CHANNELS; i++ ) 
    {
        // Set frequencies to integer multiples (harmonics) of fundamental determined by mouse x
        Math.max((220 + (x * 1000)) * (i + 1), 0) => oscs[i].freq;
        if( i > 0)
        {
            Math.min(Math.max(0.15 + y * 10, 0), 0.5) => oscs[i].gain;
        }
    }
    <<< "fundamental: " + oscs[0].freq()  + "hz, harmonics gain: " + oscs[1].gain() >>>;
}