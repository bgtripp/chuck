// Some ideas:
// Variables to control: fundamental freq,
// relative loudness of partials (each coming from a different channel)

// # of channels
6 => int CHANNELS;
// # of oscillators
12 => int OSCILLATORS;
// which mouse
0 => int device;

SinOsc oscs[OSCILLATORS];
Envelope envs[OSCILLATORS];

for( int i; i < OSCILLATORS; i++ )
{
    // connect
    oscs[i] => envs[i] => dac.chan(i % CHANNELS);
    0.0 => oscs[i].gain;
    // attack
    150::ms => envs[i].duration;
    .5 => envs[i].gain;
}
// Initialize fundamental gain
1.0 => oscs[0].gain;
0 => int loudHarm;

// HID input and HID message
Hid hi;
HidMsg msg;

// try
if( !hi.openMouse( device ) ) me.exit();
<<< "mouse '" + hi.name() + "' ready...", "" >>>;

while( true )
{
    // wait on event
    hi => now;
    
    // loop over messages
    while( hi.recv( msg ) )
    {
        if( msg.isMouseMotion() )
        {
            set( msg.scaledCursorX, msg.scaledCursorY );

        }
        else if( msg.isButtonDown() )
        {
            for( int i; i < OSCILLATORS; i++ )
            {
                envs[i].target(1);
            }
        }

        else if( msg.isWheelMotion() )
        {
            msg.deltaY + loudHarm => loudHarm;
        }

        else if( msg.isButtonUp() )
        {
            for( int i; i < OSCILLATORS; i++ )
            {
                envs[i].target(0);
            }
        }
    }
}

fun void set( float x, float y )
{
    for( int i; i < OSCILLATORS; i++ ) 
    {
        // Set frequencies to integer multiples (harmonics) of fundamental determined by mouse x
        Math.max(((x * 500)) * (i + 1), 0) => oscs[i].freq;
        if( i != 0 && i != loudHarm )
        {
            Math.min(y * 2, 1.0) => oscs[i].gain;
        }
        1 => oscs[loudHarm % OSCILLATORS].gain;
    }
    <<< "fundamental: " + oscs[0].freq()  + "hz, harmonics gain: " + oscs[1].gain() >>>;
}