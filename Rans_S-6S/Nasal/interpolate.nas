##
##  Nasal for DR400-jsbSim
##
##  Clément de l'Hamaide - PAF Team - http://equipe-flightgear.forumactif.com
##  This file is licensed under the GPL license version 2 or later.
##
###############################################################################

setlistener("/controls/electric/battery-switch", func(v) {
  if(v.getValue()){
    interpolate("/controls/electric/battery-switch-pos", 1, 0.25);
  }else{
    interpolate("/controls/electric/battery-switch-pos", 0, 0.25);
  }
});

setlistener("/controls/switches/ai-switch", func(v) {
  if(v.getValue()){
    interpolate("/controls/switches/ai-switch-pos", 1, 0.25);
  }else{
    interpolate("/controls/switches/ai-switch-pos", 0, 0.25);
  }
});

setlistener("/controls/engines/engine/starter_cmd", func(v) {
  if(v.getValue()){
    interpolate("/controls/engines/engine/starter_cmd-pos", 1, 0.25);
  }else{
    interpolate("/controls/engines/engine/starter_cmd-pos", 0, 0.25);
  }
});

setlistener("/controls/lighting/landing-lights", func(v) {
  if(v.getValue()){
    interpolate("/controls/lighting/landing-lights-pos", 1, 0.25);
  }else{
    interpolate("/controls/lighting/landing-lights-pos", 0, 0.25);
  }
});

setlistener("/controls/lighting/strobe-lights", func(v) {
  if(v.getValue()){
    interpolate("/controls/lighting/strobe-lights-pos", 1, 0.25);
  }else{
    interpolate("/controls/lighting/strobe-lights-pos", 0, 0.25);
  }
});

setlistener("/controls/lighting/nav-lights", func(v) {
  if(v.getValue()){
    interpolate("/controls/lighting/nav-lights-pos", 1, 0.25);
  }else{
    interpolate("/controls/lighting/nav-lights-pos", 0, 0.25);
  }
});

setlistener("/controls/gear/brake-parking", func(v) {
  if(v.getValue()){
    interpolate("/controls/gear/brake-parking-pos", 1, 0.25);
  }else{
    interpolate("/controls/gear/brake-parking-pos", 0, 0.25);
  }
});

setlistener("/controls/fuel/selected-tank", func(v) {
  if(v.getValue() == 0){
    interpolate("/controls/fuel/selected-tank-pos", 0, 0.25);
    setprop("fdm/jsbsim/propulsion/tank[0]/priority", 0);
    setprop("fdm/jsbsim/propulsion/tank[1]/priority", 0);
  }elsif(v.getValue() == -1){
    interpolate("/controls/fuel/selected-tank-pos", -1, 0.25);
    setprop("fdm/jsbsim/propulsion/tank[0]/priority", 0);
    setprop("fdm/jsbsim/propulsion/tank[1]/priority", 1);
  }elsif(v.getValue() == 1){
    interpolate("/controls/fuel/selected-tank-pos", 1, 0.25);
    setprop("fdm/jsbsim/propulsion/tank[0]/priority", 1);
    setprop("fdm/jsbsim/propulsion/tank[1]/priority", 0);
  }
});

setlistener("/controls/switches/smoke", func(v) {
  if(v.getValue()){
    interpolate("/controls/switches/smoke-pos", 1, 0.25);
  }else{
    interpolate("/controls/switches/smoke-pos", 0, 0.25);
  }
});

setlistener("/controls/fuel/tank/boost-pump", func(v) {
  if(v.getValue()){
    interpolate("/controls/fuel/tank/boost-pump-pos", 1, 0.25);
  }else{
    interpolate("/controls/fuel/tank/boost-pump-pos", 0, 0.25);
  }
});

setlistener("/controls/switches/hi-switch", func(v) {
  if(v.getValue()){
    interpolate("/controls/switches/hi-switch-pos", 1, 0.25);
  }else{
    interpolate("/controls/switches/hi-switch-pos", 0, 0.25);
  }
});

setlistener("/controls/lighting/warning-test", func(v) {
  if(v.getValue()){
    interpolate("/controls/lighting/warning-test-pos", 1, 0.25);
  }else{
    interpolate("/controls/lighting/warning-test-pos", 0, 0.25);
  }
});

setlistener("/controls/engines/engine/magnetos", func(v) {
    interpolate("/controls/engines/engine/magnetos-pos", v.getValue(), 0.25);
});
