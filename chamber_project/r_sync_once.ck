// Test receiver for syncing time

1000 => int MAX_TEMPO;
100 => int MIN_TEMPO;
// deadzone
0 => float DEADZONE;
// which joystick
0 => int device;
// get from command line
if( me.args() ) me.arg(0) => Std.atoi => device;

// HID objects
Hid trak;
HidMsg msg;

// open joystick 0, exit on fail
if( !trak.openJoystick( device ) ) me.exit();

// print
<<< "joystick '" + trak.name() + "' ready", "" >>>;

// data structure for gametrak
class GameTrak
{
    // timestamps
    time lastTime;
    time currTime;
    
    // previous axis data
    float lastAxis[6];
    // current axis data
    float axis[6];
}

// gametrack
GameTrak gt;

// Array of file path for first voice
[
  "Droplets_tuned/Low_c.aif",
  "Droplets_tuned/d.aif",
  "Droplets_tuned/e.aif",
  "Droplets_tuned/f.aif",
  "Droplets_tuned/g.aif",
  "Droplets_tuned/a.aif", 
  "Droplets_tuned/b.aif",
  "Droplets_tuned/high_c.aif"
] @=> string files[];

// Boop Patch
SndBuf buf[files.size()] => Gain gain => Delay delay => NRev reverb => LPF lp => dac;
for (int i; i < files.size(); i++) {
  files[i] => buf[i].read;
  0.0 => buf[i].gain;
}
// Multiples for each buf's polyrhythm
[17, 13, 11, 9, 7, 5, 3, 2] @=> int d[];
// Switches for Droplets
0 => int foot_switch;

// Delay Settings
.75::second => delay.max => delay.delay;
// set universal gain
.5 => gain.gain;
// set effects mix
.75 => delay.gain;

// Rain Patch
SndBuf rainBuf[2];
Gain rainGain[2];
Dyno dynos[2];

for (int i; i < 2; i++)
{
  rainBuf[i] => rainGain[i] => dynos[i] => dac;
  dynos[i].compress();
  0.3 => rainGain[i].gain;
  "rain_thunder.wav" => rainBuf[i].read;
}

// Reverb Settings
0.1 => reverb.mix;

// Define the min and max frequencies for the filter
20.0 => float minFreq;
20000.0 => float maxFreq;

0 => int count;
1000 => int pulse;
100 => int holdLength;

// create our OSC receiver
OscIn oin;
// create our OSC message
OscMsg oscmsg;

if( me.args() ) 
{
  me.arg(0) => Std.atoi => oin.port;
} else {
  <<< "Error: must specify port." >>>;
}

// create an address in the receiver, expect an int
oin.addAddress( "/sync, i" );

fun void update() {
  while( true )
  {
    oin => now;

    while ( oin.recv(oscmsg) )
    {
      setPulse(oscmsg.getInt(0));
    }
  }
}

fun void soundLoop() {
  while( true )
  {
    for (int i; i < d.size(); i++)
    {
      if ( foot_switch > i && count % d[i] == 0)
      {
        spork ~ boop(i);
      }
    }

    pulse::ms => now;
    count + 1 => count;
  }
}

fun void boop(int i) {
    Math.random2f(0.3, 1) => buf[i].gain;
    buf[i].pos(0);
    buf[i].play();
    holdLength::ms => now;
    0.0 => buf[i].gain;
}

fun void rainLoop() {
  while( true )
  {
    spork ~ rain(0);
    9::second => now;
    spork ~ rain(1);
    14::second => now;
  }
}

fun void rain(int i) {
  rainBuf[i].pos(0);
  rainBuf[i].play();
}

fun void setPulse(int bpm)
{
  60000 / bpm => pulse;
}

// spork ~ update();
spork ~ rainLoop();
spork ~ gametrak();

// Wait for initial sync
oin => now;

if ( oin.recv(oscmsg) )
{
  // setPulse(oscmsg.getInt(0));
  spork ~ soundLoop();
}

// gametrack handling
fun void gametrak()
{
    while( true )
    {
      <<< "running" >>>;
        // wait on HidIn as event
        trak => now;
        
        // messages received
        while( trak.recv( msg ) )
        {
            // joystick axis motion
            if( msg.isAxisMotion() )
            {            
                // check which
                if( msg.which >= 0 && msg.which < 6 )
                {
                    // check if fresh
                    if( now > gt.currTime )
                    {
                        // time stamp
                        gt.currTime => gt.lastTime;
                        // set
                        now => gt.currTime;
                    }
                    // save last
                    gt.axis[msg.which] => gt.lastAxis[msg.which];
                    // the z axes map to [0,1], others map to [-1,1]
                    if( msg.which != 2 && msg.which != 5 )
                    { msg.axisPosition => gt.axis[msg.which]; }
                    else
                    {
                        1 - ((msg.axisPosition + 1) / 2) - DEADZONE => gt.axis[msg.which];
                        if( gt.axis[msg.which] < 0 ) 0 => gt.axis[msg.which];
                    }
                }
            }
            
            // joystick button down
            else if( msg.isButtonDown() )
            {
                foot_switch + 1 => foot_switch;
                d.size() % foot_switch => foot_switch; 
                <<< "button", msg.which, "down" >>>;
                
            }
            
            // joystick button up
            else if( msg.isButtonUp() )
            {
                <<< "button", msg.which, "up" >>>;
            }
            // print 6 continuous axes -- XYZ values for left and right
            <<< "axes:", gt.axis[0],gt.axis[1],gt.axis[2],
            gt.axis[3],gt.axis[4],gt.axis[5] >>>;
            
            // gametrak left horrizontal will handle cutoff frequency
            // Read the Gametrak axis value (0 to 1)
            (gt.axis[3] + 1) / 2 => float left_pull;
            
            // Map the left_pull value to the frequency range
            Std.ftoi(left_pull * (MAX_TEMPO - MIN_TEMPO) + MIN_TEMPO) => int intpull;
            setPulse(intpull);
            
            // gametrak right horrizontal will handle cutoff frequency
            (gt.axis[6] + 1) / 2 => float right_freq;
            // Map the left_pull value to the gain
            right_freq => gain.gain; 
            right_freq * (maxFreq - minFreq) + minFreq => lp.freq;
        }
    }
}

while( true ) 
  1::second => now;