###############################################################################
##  Nasal for dual control of the Cap10B over the multiplayer network.
##
##  Copyright (C) 2007 - 2008  Anders Gidenstam  (anders(at)gidenstam.org)
##  This file is licensed under the GPL license version 2 or later.
##
##  Modified by David Van Mosselbeen for Rans S-6S
##
###############################################################################

## Renaming (almost :)
var DCT = dual_control_tools;

## Pilot/copilot aircraft identifiers. Used by dual_control.
var pilot_type   = "Aircraft/Rans_S-6S/Models/rans_s-6s.xml";
var copilot_type = "Aircraft/Rans_S-6S/Models/rans_s-6s-copilot.xml";

############################ PROPERTIES MP ###########################
#####
# pilot properties
##
var flaps            = "surface-positions/flap-pos-norm";
var rudder           = "surface-positions/rudder-pos-norm";
var copilot_rudder   = "sim/multiplay/generic/float[15]";
var elevator         = "surface-positions/elevator-pos-norm";
var copilot_elevator = "sim/multiplay/generic/float[14]";
var aileron          = "surface-positions/left-aileron-pos-norm";
var copilot_aileron  = "sim/multiplay/generic/float[16]";
var rpm              = "engines/engine[0]/rpm";
var elevator_trim    = "sim/multiplay/generic/float[3]";
var throttle         = "sim/multiplay/generic/float[10]";
var mixture          = "sim/multiplay/generic/float[11]";
var brake            = ["sim/multiplay/generic/float[12]", "sim/multiplay/generic/float[13]"];
var switch_mpp       = "sim/multiplay/generic/int[0]";
var lights_mpp       = "sim/multiplay/generic/int[9]";
var TDM_mpp          = "sim/multiplay/generic/string[0]";

######################################################################
# Useful instrument related property paths.

# Flight controls
var elevator_cmd      = "controls/flight/elevator";
var rudder_cmd        = "controls/flight/rudder";
var aileron_cmd       = "controls/flight/aileron";
var flaps_cmd         = "controls/flight/flaps";
var elevator_trim_cmd = "controls/flight/elevator-trim";

# Engine controls
var throttle_cmd      = "controls/engines/engine[0]/throttle";
var mixture_cmd       = "controls/engines/engine[0]/mixture";
var magnetos_cmd      = "controls/engines/engine[0]/magnetos";
var rpm_cmd           = "engines/engine[0]/rpm";

# Other controls
var fuel_cmd          = "controls/fuel/selected-tank";
var brake_cmd         = ["controls/gear/brake-left", "controls/gear/brake-right"];
var fuel_qte          = ["consumables/fuel/tank[0]/level-gal_us-pos","consumables/fuel/tank[1]/level-gal_us-pos"];
var airspeed          = "instrumentation/airspeed-indicator/indicated-speed-kt";
var forceg            = "fdm/jsbsim/accelerations/Nz";
var mposi             = "engines/engine/mp-osi";
var fuel_flow         = "fdm/jsbsim/propulsion/engine/fuel-flow-rate-gph";
var oil_press         = "fdm/jsbsim/propulsion/engine/oil-pressure-psi";
var oil_temp          = "fdm/jsbsim/propulsion/engine/oil-temperature-degF";
var altitude_agl      = "position/altitude-agl-ft";

# Switch controls
var battery_switch          = "controls/electric/battery-switch";
var starter_switch          = "controls/engines/engine/starter_cmd";
var landing_lights          = "controls/lighting/landing-lights";
var pitot_heat              = "controls/anti-ice/pitot-heat";
var prop_heat               = "controls/anti-ice/prop-heat";
var nav_lights              = "controls/lighting/nav-lights";
var strobe_lights           = "controls/lighting/strobe-lights";
var ai_switch               = "controls/switches/ai-switch";
var hi_switch               = "controls/switches/hi-switch";
var smoke_switch            = "controls/switches/smoke";

# Boolean properties
var running        = "engines/engine[0]/running";
var cranking       = "engines/engine[0]/cranking";
var brake_parking  = "controls/gear/brake-parking";
var gear_wow       = ["gear/gear[0]/wow", "gear/gear[1]/wow", "gear/gear[2]/wow"];

var l_dual_control    = "dual-control/active";

######################################################################
###### Used by dual_control to set up the mappings for the pilot #####
######################## PILOT TO COPILOT ############################
######################################################################

var pilot_connect_copilot = func (copilot) {
  # Make sure dual-control is activated in the FDM FCS.
  print("Pilot section");
  setprop(l_dual_control, 1);

  return [
      ##################################################
      # Map copilot properties to buffer properties

      DCT.MostRecentSelector.new
        (copilot.getNode(copilot_rudder), props.globals.getNode(rudder_cmd), props.globals.getNode(rudder_cmd), 0.0001),
      DCT.MostRecentSelector.new
        (copilot.getNode(copilot_aileron), props.globals.getNode(aileron_cmd), props.globals.getNode(aileron_cmd), 0.0001),
      DCT.MostRecentSelector.new
        (copilot.getNode(copilot_elevator), props.globals.getNode(elevator_cmd), props.globals.getNode(elevator_cmd), 0.0001),

      DCT.MostRecentSelector.new
        (copilot.getNode(throttle), props.globals.getNode(throttle_cmd), props.globals.getNode(throttle_cmd), 0.0001),
      DCT.MostRecentSelector.new
        (copilot.getNode(mixture), props.globals.getNode(mixture_cmd), props.globals.getNode(mixture_cmd), 0.0001),

      DCT.StableTrigger.new(copilot.getNode(elevator_trim), func(v){props.globals.getNode(elevator_trim_cmd, 1).setValue(v);}),
      DCT.StableTrigger.new(copilot.getNode(brake[0]), func(v){props.globals.getNode(brake_cmd[0], 1).setValue(v);}),
      DCT.StableTrigger.new(copilot.getNode(brake[1]), func(v){props.globals.getNode(brake_cmd[1], 1).setValue(v);}),

      ##################################################
      # Switch Encoder
      DCT.TDMEncoder.new
        ([
          props.globals.getNode(magnetos_cmd),
          props.globals.getNode(fuel_cmd),
          props.globals.getNode(flaps_cmd),
          props.globals.getNode(fuel_qte[0]),
          props.globals.getNode(fuel_qte[1]),
          props.globals.getNode(airspeed),
          props.globals.getNode(forceg),
          props.globals.getNode(mposi),
          props.globals.getNode(fuel_flow),
          props.globals.getNode(oil_press),
          props.globals.getNode(oil_temp),
          props.globals.getNode(altitude_agl)
         ], props.globals.getNode(TDM_mpp)),
      DCT.SwitchEncoder.new
        ([
          props.globals.getNode(battery_switch),
          props.globals.getNode(starter_switch),
          props.globals.getNode(running),
          props.globals.getNode(cranking),
          props.globals.getNode(brake_parking),
          props.globals.getNode(ai_switch),
          props.globals.getNode(hi_switch),
          props.globals.getNode(smoke_switch),
          props.globals.getNode(gear_wow[0]),
          props.globals.getNode(gear_wow[1]),
          props.globals.getNode(gear_wow[2])
         ], props.globals.getNode(switch_mpp)),
      DCT.SwitchEncoder.new
        ([
          props.globals.getNode(landing_lights),
          props.globals.getNode(nav_lights),
          props.globals.getNode(strobe_lights)
         ], props.globals.getNode(lights_mpp)),

      ##################################################
      # Switch decoder
      DCT.TDMDecoder.new
        (copilot.getNode(TDM_mpp), 
        [func(v){props.globals.getNode("dual-control/copilot/"~magnetos_cmd, 1).setValue(v);},
         func(v){props.globals.getNode("dual-control/copilot/"~fuel_cmd, 1).setValue(v);},
         func(v){props.globals.getNode("dual-control/copilot/"~flaps_cmd, 1).setValue(v);}
        ]),

      DCT.SwitchDecoder.new
        (copilot.getNode(switch_mpp),
        [func(b){props.globals.getNode("dual-control/copilot/"~battery_switch, 1).setValue(b);},
         func(b){props.globals.getNode("dual-control/copilot/"~starter_switch, 1).setValue(b);},
         func(b){props.globals.getNode("dual-control/copilot/"~running, 1).setValue(b);},
         func(b){props.globals.getNode("dual-control/copilot/"~cranking, 1).setValue(b);},
         func(b){props.globals.getNode("dual-control/copilot/"~brake_parking, 1).setValue(b);},
         func(b){props.globals.getNode("dual-control/copilot/"~ai_switch, 1).setValue(b);},
         func(b){props.globals.getNode("dual-control/copilot/"~hi_switch, 1).setValue(b);},
         func(b){props.globals.getNode("dual-control/copilot/"~smoke_switch, 1).setValue(b);}
        ]),

      DCT.SwitchDecoder.new
        (copilot.getNode(lights_mpp),
        [func(b){props.globals.getNode("dual-control/copilot/"~landing_lights, 1).setValue(b);},
         func(b){props.globals.getNode("dual-control/copilot/"~nav_lights, 1).setValue(b);},
         func(b){props.globals.getNode("dual-control/copilot/"~strobe_lights, 1).setValue(b);}
        ]),

      ##################################################      
      # Map the most recent value between pilot and copilot to pilot properties

      ##### BOOLEAN PROPERTIES #####
      DCT.MostRecentSelector.new
        (props.globals.getNode("dual-control/copilot/"~battery_switch, 1), props.globals.getNode(battery_switch), props.globals.getNode(battery_switch), 0.1),
      DCT.MostRecentSelector.new
        (props.globals.getNode("dual-control/copilot/"~starter_switch, 1), props.globals.getNode(starter_switch), props.globals.getNode(starter_switch), 0.1),
      DCT.MostRecentSelector.new
        (props.globals.getNode("dual-control/copilot/"~running, 1), props.globals.getNode(running), props.globals.getNode(running), 0.1),
      DCT.MostRecentSelector.new
        (props.globals.getNode("dual-control/copilot/"~cranking, 1), props.globals.getNode(cranking), props.globals.getNode(cranking), 0.1),
      DCT.MostRecentSelector.new
        (props.globals.getNode("dual-control/copilot/"~brake_parking, 1), props.globals.getNode(brake_parking), props.globals.getNode(brake_parking), 0.1),
      DCT.MostRecentSelector.new
        (props.globals.getNode("dual-control/copilot/"~ai_switch, 1), props.globals.getNode(ai_switch), props.globals.getNode(ai_switch), 0.1),
      DCT.MostRecentSelector.new
        (props.globals.getNode("dual-control/copilot/"~hi_switch, 1), props.globals.getNode(hi_switch), props.globals.getNode(hi_switch), 0.1),
      DCT.MostRecentSelector.new
        (props.globals.getNode("dual-control/copilot/"~smoke_switch, 1), props.globals.getNode(smoke_switch), props.globals.getNode(smoke_switch), 0.1),


      ##### OTHERS #####
      DCT.MostRecentSelector.new
        (props.globals.getNode("dual-control/copilot/"~magnetos_cmd, 1), props.globals.getNode(magnetos_cmd), props.globals.getNode(magnetos_cmd), 0.1),
      DCT.MostRecentSelector.new
        (props.globals.getNode("dual-control/copilot/"~fuel_cmd, 1), props.globals.getNode(fuel_cmd), props.globals.getNode(fuel_cmd), 0.1),
      DCT.MostRecentSelector.new
        (props.globals.getNode("dual-control/copilot/"~brake_cmd[0], 1), props.globals.getNode(brake_cmd[0]), props.globals.getNode(brake_cmd[0]), 0.000001),
      DCT.MostRecentSelector.new
        (props.globals.getNode("dual-control/copilot/"~brake_cmd[1], 1), props.globals.getNode(brake_cmd[1]), props.globals.getNode(brake_cmd[1]), 0.000001),
      DCT.MostRecentSelector.new
        (props.globals.getNode("dual-control/copilot/"~flaps_cmd, 1), props.globals.getNode(flaps_cmd), props.globals.getNode(flaps_cmd), 0.1),


      ##### LIGHTING #####
      DCT.MostRecentSelector.new
        (props.globals.getNode("dual-control/copilot/"~landing_lights, 1), props.globals.getNode(landing_lights), props.globals.getNode(landing_lights), 0.1),
      DCT.MostRecentSelector.new
        (props.globals.getNode("dual-control/copilot/"~nav_lights, 1), props.globals.getNode(nav_lights), props.globals.getNode(nav_lights), 0.1),
      DCT.MostRecentSelector.new
        (props.globals.getNode("dual-control/copilot/"~strobe_lights, 1), props.globals.getNode(strobe_lights), props.globals.getNode(strobe_lights), 0.1),

  ];
}

##############
var pilot_disconnect_copilot = func {
  setprop(l_dual_control, 0);
}

######################################################################
##### Used by dual_control to set up the mappings for the copilot ####
######################## COPILOT TO PILOT ############################
######################################################################

var copilot_connect_pilot = func (pilot) {
  # Make sure dual-control is activated in the FDM FCS.
  print("Copilot section");
  setprop(l_dual_control, 1);

  return [
      ##################################################
      # Map pilot properties to buffer properties

      DCT.StableTrigger.new(pilot.getNode(elevator), func(v){v -=  pilot.getNode(elevator_trim).getValue(); props.globals.getNode(elevator_cmd, 1).setValue(v);}),
      DCT.StableTrigger.new(pilot.getNode(throttle), func(v){props.globals.getNode(throttle_cmd, 1).setValue(v);}),
      DCT.StableTrigger.new(pilot.getNode(mixture), func(v){props.globals.getNode(mixture_cmd, 1).setValue(v);}),


      DCT.StableTrigger.new(pilot.getNode(elevator_trim), func(v){props.globals.getNode(elevator_trim_cmd, 1).setValue(v);}),
      DCT.StableTrigger.new(pilot.getNode(brake[0]), func(v){props.globals.getNode(brake_cmd[0], 1).setValue(v);}),
      DCT.StableTrigger.new(pilot.getNode(brake[1]), func(v){props.globals.getNode(brake_cmd[1], 1).setValue(v);}),
      DCT.Translator.new(pilot.getNode(rpm), props.globals.getNode(rpm_cmd, 1)),



      ##################################################
      # Switch Encoder
      DCT.TDMEncoder.new
        ([
          props.globals.getNode(magnetos_cmd),
          props.globals.getNode(fuel_cmd),
          props.globals.getNode(flaps_cmd),
         ], props.globals.getNode(TDM_mpp)),
      DCT.SwitchEncoder.new
        ([
          props.globals.getNode(battery_switch),
          props.globals.getNode(starter_switch),
          props.globals.getNode(running),
          props.globals.getNode(cranking),
          props.globals.getNode(brake_parking),
          props.globals.getNode(ai_switch),
          props.globals.getNode(hi_switch),
          props.globals.getNode(smoke_switch)
         ], props.globals.getNode(switch_mpp)),
      DCT.SwitchEncoder.new
        ([
          props.globals.getNode(landing_lights),
          props.globals.getNode(nav_lights),
          props.globals.getNode(strobe_lights),
         ], props.globals.getNode(lights_mpp)),

      ##################################################
      # Switch decoder
      DCT.TDMDecoder.new
        (pilot.getNode(TDM_mpp), 
        [func(v){pilot.getNode(magnetos_cmd~"-pos", 1).setValue(v); props.globals.getNode("dual-control/pilot/"~magnetos_cmd, 1).setValue(v);},
         func(v){pilot.getNode(fuel_cmd~"-pos", 1).setValue(v); props.globals.getNode("dual-control/pilot/"~fuel_cmd, 1).setValue(v);},
         func(v){pilot.getNode(flaps_cmd, 1).setValue(v); props.globals.getNode("dual-control/pilot/"~flaps_cmd, 1).setValue(v);},
         func(v){pilot.getNode(fuel_qte[0], 1).setValue(v); props.globals.getNode("dual-control/pilot/"~fuel_qte[0], 1).setValue(v);},
         func(v){pilot.getNode(fuel_qte[1], 1).setValue(v); props.globals.getNode("dual-control/pilot/"~fuel_qte[1], 1).setValue(v);},
         func(v){pilot.getNode(airspeed, 1).setValue(v); props.globals.getNode("dual-control/pilot/"~airspeed, 1).setValue(v);},
         func(v){pilot.getNode(forceg, 1).setValue(v); props.globals.getNode("dual-control/pilot/"~forceg, 1).setValue(v);},
         func(v){pilot.getNode(mposi, 1).setValue(v); props.globals.getNode("dual-control/pilot/"~mposi, 1).setValue(v);},
         func(v){pilot.getNode(fuel_flow, 1).setValue(v); props.globals.getNode("dual-control/pilot/"~fuel_flow, 1).setValue(v);},
         func(v){pilot.getNode(oil_press, 1).setValue(v); props.globals.getNode("dual-control/pilot/"~oil_press, 1).setValue(v);},
         func(v){pilot.getNode(oil_temp, 1).setValue(v); props.globals.getNode("dual-control/pilot/"~oil_temp, 1).setValue(v);},
         func(v){pilot.getNode(altitude_agl, 1).setValue(v); props.globals.getNode(altitude_agl, 1).setValue(v);},
        ]),

      DCT.SwitchDecoder.new
        (pilot.getNode(switch_mpp),
        [func(b){props.globals.getNode(battery_switch).setValue(b);},
         func(b){props.globals.getNode(starter_switch).setValue(b);},
         func(b){props.globals.getNode(running).setValue(b);},
         func(b){props.globals.getNode(cranking).setValue(b);},
         func(b){props.globals.getNode(brake_parking).setValue(b);},
         func(b){props.globals.getNode(ai_switch).setValue(b);},
         func(b){props.globals.getNode(hi_switch).setValue(b);},
         func(b){props.globals.getNode(smoke_switch).setValue(b);},
         func(b){props.globals.getNode(gear_wow[0]).setValue(b);},
         func(b){props.globals.getNode(gear_wow[1]).setValue(b);},
         func(b){props.globals.getNode(gear_wow[2]).setValue(b);},
        ]),

      DCT.SwitchDecoder.new
        (pilot.getNode(lights_mpp),
        [func(b){props.globals.getNode(landing_lights).setValue(b);},
         func(b){props.globals.getNode(nav_lights).setValue(b);},
         func(b){props.globals.getNode(strobe_lights).setValue(b);},
        ]),

      ##################################################
      # Enable animation for copilot
      DCT.Translator.new(props.globals.getNode(rudder_cmd), pilot.getNode(rudder_cmd, 1)),
      DCT.Translator.new(props.globals.getNode(aileron_cmd), pilot.getNode(aileron_cmd, 1)),
      DCT.Translator.new(props.globals.getNode(elevator_cmd), pilot.getNode(elevator_cmd, 1)),
      DCT.Translator.new(props.globals.getNode(elevator_trim_cmd), pilot.getNode(elevator_trim_cmd, 1)),
      DCT.Translator.new(props.globals.getNode(throttle), pilot.getNode(throttle_cmd, 1)),
      DCT.Translator.new(props.globals.getNode(mixture), pilot.getNode(mixture_cmd, 1)),
      DCT.Translator.new(props.globals.getNode(battery_switch~"-pos", 1), pilot.getNode(battery_switch~"-pos", 1)),
      DCT.Translator.new(props.globals.getNode(starter_switch~"-pos", 1), pilot.getNode(starter_switch~"-pos", 1)),
      DCT.Translator.new(props.globals.getNode(landing_lights~"-pos", 1), pilot.getNode(landing_lights~"-pos", 1)),
      DCT.Translator.new(props.globals.getNode(nav_lights~"-pos", 1), pilot.getNode(nav_lights~"-pos", 1)),
      DCT.Translator.new(props.globals.getNode(strobe_lights~"-pos", 1), pilot.getNode(strobe_lights~"-pos", 1)),
      DCT.Translator.new(props.globals.getNode(brake_parking~"-pos", 1), pilot.getNode(brake_parking, 1)),
      DCT.Translator.new(props.globals.getNode(fuel_cmd~"-pos", 1), pilot.getNode(fuel_cmd~"-pos", 1)),
      DCT.Translator.new(props.globals.getNode(ai_switch~"-pos", 1), pilot.getNode(ai_switch~"-pos", 1)),
      DCT.Translator.new(props.globals.getNode(hi_switch~"-pos", 1), pilot.getNode(hi_switch~"-pos", 1)),
      DCT.Translator.new(props.globals.getNode(smoke_switch~"-pos", 1), pilot.getNode(smoke_switch~"-pos", 1)),
      DCT.Translator.new(props.globals.getNode("sim/model/config/glass-reflection"), pilot.getNode("sim/model/config/glass-reflection")),
      DCT.Translator.new(props.globals.getNode("instrumentation/altimeter/indicated-altitude-ft"), pilot.getNode("instrumentation/altimeter/indicated-altitude-ft", 1)),
      DCT.Translator.new(props.globals.getNode("instrumentation/attitude-indicator/indicated-roll-deg"), pilot.getNode("instrumentation/attitude-indicator/indicated-roll-deg", 1)),
      DCT.Translator.new(props.globals.getNode("instrumentation/vertical-speed-indicator/indicated-speed-fpm"), pilot.getNode("instrumentation/vertical-speed-indicator/indicated-speed-fpm", 1)),
      DCT.Translator.new(props.globals.getNode("instrumentation/heading-indicator/indicated-heading-deg"), pilot.getNode("instrumentation/heading-indicator/indicated-heading-deg", 1)),
      DCT.Translator.new(props.globals.getNode("orientation/heading-magnetic-deg"), pilot.getNode("orientation/heading-magnetic-deg", 1)),
      DCT.Translator.new(props.globals.getNode("orientation/heading-deg"), pilot.getNode("orientation/heading-deg", 1)),
      DCT.Translator.new(props.globals.getNode("dual-control/pilot/"~fuel_qte[0], 1), pilot.getNode(fuel_qte[0], 1)),
      DCT.Translator.new(props.globals.getNode("dual-control/pilot/"~fuel_qte[1], 1), pilot.getNode(fuel_qte[1], 1)),
      DCT.Translator.new(props.globals.getNode("dual-control/pilot/"~airspeed, 1), pilot.getNode(airspeed, 1)),
      DCT.Translator.new(props.globals.getNode("dual-control/pilot/"~forceg, 1), pilot.getNode(forceg, 1)),
      DCT.Translator.new(props.globals.getNode("dual-control/pilot/"~mposi, 1), pilot.getNode(mposi, 1)),
      DCT.Translator.new(props.globals.getNode("dual-control/pilot/"~fuel_flow, 1), pilot.getNode(fuel_flow, 1)),
      DCT.Translator.new(props.globals.getNode("dual-control/pilot/"~oil_press, 1), pilot.getNode(oil_press~"-pos", 1)),
      DCT.Translator.new(props.globals.getNode("dual-control/pilot/"~oil_temp, 1), pilot.getNode(oil_temp~"-pos", 1)),

      DCT.MostRecentSelector.new
        (props.globals.getNode("dual-control/pilot/"~magnetos_cmd, 1), props.globals.getNode(magnetos_cmd), props.globals.getNode(magnetos_cmd), 0.1),
      DCT.MostRecentSelector.new
        (props.globals.getNode("dual-control/pilot/"~fuel_cmd, 1), props.globals.getNode(fuel_cmd), props.globals.getNode(fuel_cmd), 0.1),
      DCT.MostRecentSelector.new
        (props.globals.getNode("dual-control/pilot/"~flaps_cmd, 1), props.globals.getNode(flaps_cmd), props.globals.getNode(flaps_cmd), 0.1),

  ];
}

var copilot_disconnect_pilot = func {
  setprop(l_dual_control, 0);
}
