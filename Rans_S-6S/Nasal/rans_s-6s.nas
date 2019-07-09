
#
# Heavily inspired of the cap10b-copilot.nas (Paf team creation 
# http://equipe-flightgear.forumactif.com
#

# FIXME: starter is defined in the electrical system. However, making use of
# the electrical system fails at this stage (The starter won't run)
props.globals.initNode("/systems/electrical/outputs/starter", 0, "INT");

var config_dlg = gui.Dialog.new("/sim/gui/dialogs/config/dialog", getprop("/sim/aircraft-dir")~"/Dialogs/config.xml");

### horameter ################################################################
props.globals.initNode("/instrumentation/horameter/elapsed-time", 0, "INT");
var horameter = aircraft.timer.new("/instrumentation/horameter/elapsed-time", 1, 1);

setlistener("/instrumentation/horameter/running", func(running){
  if(running.getBoolValue()){
    horameter.start();
  }else{
    horameter.stop();
  }
});

##############################################
######### AUTOSTART / AUTOSHUTDOWN ###########
##############################################

setlistener("/sim/model/start-idling", func(idle){
    var run= idle.getBoolValue();
    if(run){
    Startup();
    }else{
    Shutdown();
    }
},0,0);

var Startup = func {
    setprop("controls/fuel/selected-tank", 1);
    setprop("controls/engines/engine[0]/master-alt",1);
    setprop("/controls/engines/engine[0]/magnetos",3);
    setprop("controls/engines/engine[0]/mixture",1);
    setprop("/controls/gear/brake-parking",1);
    setprop("controls/electric/battery-switch",1);
    setprop("controls/fuel/switch-position",1);
    setprop("controls/electric/avionics-switch",1);

    setprop("sim/messages/copilot", "Now press \"s\" to start engine");
}
var Shutdown = func{
    setprop("controls/fuel/selected-tank", 0);
    setprop("controls/engines/engine[0]/master-alt",0);
    setprop("/controls/engines/engine[0]/magnetos",0);
    setprop("controls/engines/engine[0]/mixture",1);
    setprop("/engines/engine[0]/running",0);
    setprop("/controls/gear/brake-parking",1);
    setprop("controls/electric/battery-switch",0);
    setprop("controls/fuel/switch-position",0);
    setprop("controls/electric/avionics-switch",0);

    setprop("sim/messages/copilot", "Engine is stopped");
}

############################################
# Global loop function
# If you need to run nasal as loop, add it in this function
############################################
global_system = func{

  if(getprop("/systems/electrical/outputs/starter") > 18){
    setprop("/controls/engines/engine[0]/starter",1);
  }else{
    setprop("/controls/engines/engine[0]/starter",0);
  }

    if(
        getprop("/systems/electrical/volts") > 3){
        setprop("/instrumentation/horameter/running", 1);
    }
    else{
        setprop("/instrumentation/horameter/running", 0);
    }

    settimer(global_system, 0);
}

##########################################
# SetListerner must be at the end of this file
##########################################
setlistener("/sim/signals/fdm-initialized", func{
    setprop("/controls/lighting/nav-lights", 0);
    setprop("/controls/lighting/landing-lights", 0);
    setprop("/controls/electric/battery-switch", 0);
    setprop("/instrumentation/vertical-speed-indicator/indicated-speed-fpm", 0);

    if(getprop("sim/rendering/rembrandt/enabled") == nil){
        props.globals.initNode("sim/rendering/rembrandt/enabled", 0, "BOOL");
        print("Rembrandt no available");
    }

});

var nasalInit = setlistener("/sim/signals/fdm-initialized", func{
  settimer(global_system, 2);
  removelistener(nasalInit);
});
