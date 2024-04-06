// Some ideas:
// Variables to control: fundamental freq,
// relative loudness of partials (each coming from a different channel)

// # of channels
2 => int CHANNELS;
// which mouse
1 => int device;

SinOsc oscs[CHANNELS];
Envelope envs[CHANNELS];

for( int i; i < CHANNELS; i++ )
{
    // connect
    oscs[i] => envs[i] => dac.chan(i);
    .15 => oscs[i].gain;
    // attack
    10::ms => envs[i].duration;
    .5 => envs[i].gain;
}

// HID input and HID message
Hid hi;
HidMsg msg;

// try
if( !hi.openMouse( device ) ) me.exit();
<<< "mouse '" + hi.name() + "' ready...", "" >>>;

220 => int fund;
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
            //msg.deltaY * .001 + y => y;
            set( x );

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

fun void set( float x )
{
    for( int i; i < CHANNELS; i++ ) 
    {
        // Set frequencies to integer multiples (harmonics) of fundamental determined by mouse x
        (220 + (x * 1000)) * (i + 1) => oscs[i].sfreq;
    }
}

// Next: have y modify gain on partials. At 0 delta they should be silent, then louder and louder with increase y