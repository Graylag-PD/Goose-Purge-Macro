# Goose Purge SW specification
V2  
31.10.2025  
By Graylag  

## Purpose and goals
The Goose Purge v1.#.# is the default control software for the Goose Belt Purger (GBP) and follows on the Goose Purge v0.#.# macro bundled with the GBP.  
The Goose Purge SW shall be designed as hardware independent to support any future versions of the GBP, but also any spin-offs of the GBP or independent belt based purgers  (namely, but not exclusively Scops Owl purger and xPlore purger). Implementation of any non-belt purge methods is optional.  

## Abbreviations and glossary
### Abbreviations
GBP – Goose Belt Purger  
GPSW – Goose Purge SW  

### Glossary
Klipper – 3D printer software designed to run as an app, typicaly on a embedded Linux machine  
Klipper macro – gcode macro (and associated definitions) defined according Klipper documentation. Uses Jinja2 templates for scripting. Typicaly stored within one of the *.cfg files within configuration folder  
Klipper module – A host module, python module loaded by Klipper. Stored in klippy/extras/ folder as a *.py file  
Klippy - App part of the Klipper running on the RPi. (This is what makes the Klipper "tick")
Moonraker - Web API for the Klipper. (Without this, Klipper/Klippy is just a terminal app, incapable talking with the world; This is the bridge between Klipper/Klippy and interfaces such as Mainsail)

## Organization
All main decisions shall be made by or together with the Project owner. The same applies to any kind of conflicts or issues.  
Project shall be stored and managed in the GitHub  
Default GitHub repository for the project is Goose-Purge-Software  
Default communication method for the development team is Discord, specifically dedicated thread within GOOSE Forge  
Default communication language for the project is English. All permanent documentation must be in English.  Temporary notes of personal nature may be made in Czech or in German  

### Version naming
Project shall use SemVer convention  
The major version number shall be 1 (i.e. 1.#.#)  
All versions not intended for the public release shall be identified by appending a hyphen and adding the identifier (e.g. 1.0.0-dev.1)  
Following identifiers shall be used:
-	dev
    - version with incomplete features, which is not expected to run
-	exp
    -	experimental, used to identify version with experimental features which are not planned to be implemented into the main line
-	alpha
    -	version with completed features, which may need further refinement. Is generally expected to run, but may have multiple errors preventing the run from completing
-	beta
    -	version with completed features, which are considered finished, but may need testing and possibly bugfixing. Is expected to run without major errors, but may contain bugs preventing it from completing or correct operation in specific cases.

Developers are permitted in justified cases to use their own customized identifiers.  
Identifier shall be appended by a dot followed a number. Several dot separated numbers may be used to signal minor changes to a previously submited code.  

### GitHub branches
Following four branches have been created within GitHub:
-	main
    - Intended for public released versions
-	beta
    -	For Alpha and Beta releases
-	dev
    -	For .dev versions
-	experimental
    -	For .exp versions

### GitHub file structure
The GPSW is split in between following files:
-	goose_purge.cfg
    -	Read only file
    -	Included from printer.cfg
    -	Contains the main GOOSE_PURGE macro and the state machine
-	goose_purge_core.cfg
    - Read only file
    -	Included from goose_purge.cfg
    -	Contains core macros referenced by the state machine
-	goose_purge_custom_macros.cfg
    -	R/W file
    -	Included from goose_purge.cfg
    -	Intended for user defined macros, shall have only basic structure by default
-	goose_purge_extra.cfg
    -	Read only file
    -	Included from goose_purge.cfg
    -	Contains macros referenced by the state machine, which are not strictly tied to GBP, e.g. brushing macro
-	goose_purge_hardware.cfg
    -	R/W file
    -	Included from goose_purge.cfg
    -	Contains definitions of hardware
-	goose_purge_config_default.cfg
	-	Read only file
 	-	Included from goose_purge.cfg (note: must be included BEFORE goose_purge_config.cfg)
  	-	Copies the goose_purge_config.cfg and serves as a fall back solution if some parameter is not included or is commented in user configurable config file.
-	goose_purge_config.cfg
    -	R/W file
    -	Included from goose_purge.cfg
    -	Contains user accessible (public) configuration parameters, used to tune the behaviour

Presented file structure is only an initial proposal and can be changed during the development.

### Naming conventions
All GPSW related files, macros or modules shall contain the „goose_purge“ in their name.  
All macros intended to be visible by the user shall be prefixed as „GOOSE_PURGE_...“  
All macros intended for internal use only shall be prefixed as „_GOOSE_PURGE“ (with underscore in front)  
All macros shall be named in upper case leters (i.e. GOOSE_PURGE and not goose_purge)  
All variables shall be named in lower case letters (i.e. belt_speed) note: this is formal requirement, klipper does not allow upper case variables  

## Interfaces
### System interface
The GPSW shall be designed as a Klipper macro distributed by means of *.cfg files.  
The newest version of the Klipper shall always be targeted as a target platform.  
Klipper based derivatives (namely but not exclusively Kalico) shall be supported when possible. In case any imcompatibilities are identified, it shall be documented and appropriate measures taken.  
The GPSW shall be designed as a standalone macro (i.e. without associated Klipper module).  
The GPSW shall be designed with possibility of later extension through Klipper module. Any features which might take benefit from being handled by a module shall be identified and documented  
The GPSW shall interface physical devices (motors, sensors) exclusively through default Klipper modules. Usage of any external modules is not alowed.  
The GPSW shall access selected system variables through `printer` pseudo variables  

### Interfaces to multimaterial printing modules
The GPSW shall be capable of interfacing with the AFC and HappyHare modules  
The GPSW shall not access any variables of other modules unless specified. I.e. all variables have to be self contained or accessible through `printer.` even if suitable value exists in those modules. This is to comply with the design requirements of the Klipper and to prevent the dependency issues.  
Exception of this rule is interfacing with the HH, where the GPSW shall read xxx variable as described in HappyHare documentation. This creates possible vulnerability, however is currently the only way to get preprocessed purge volumes from HappyHare.  
The GPSW shall be able to interface with the modules without use of any module specific wrappers. Use of customized parameters passing the information, that the call comes from multimaterial printing module is possible.  

### Interface with the user
The GPSW is only supposed to be accessible through terminal commands. No other means of interfacing with the user are planned, as the GPSW is supposed under normal condition to be called from other tools.  
Default call from the terminal shall be GOOSE_PURGE, with or without additional parameters.  
Input parameters which have to be implemented are PURGE_LENGTH and PURGE_VOLUME.  
Input parameters LENGTH and VOLUME which were present in v0 line shall NOT be implemented.
The GPSW shall have three levels of diagnostic messages.  
Prefered level of the diagnostic feedback shall be configurable by users via variables configuration.  
Levels of diagnostics are as follows:
- none - this means no diagnostic messages are sent, not even in the case of a critical failure. 
- basic - GPSW shall inform user about the fact, that it purges and how much. It shall also report critical failures. This generaly corresponds to the diagnostics in v0 line.
- extended - GPSW shall send diagnostic message about entering each phase. It shall also report any kind of errors.

### Interface with the hardware
The GPSW shall support at least following hardware interfaces:
- Output pin (for DC motor)
- Stepper motor
- Servo motor for motorized mount

Additional hardware interfaces are permitted. Examples of those are:
- Servo motor for additional tasks (e.g. motorized bucket)
- 360° servo as a belt drive
- Bus based smart motor drivers

Servo for this purpose means modelcraft servo controlled by time signal of 1000-2000 us  
The GPSW may support input signals, such as:
- Belt encoder for precise control
- Endstops for motorized mount or bucket

All servos shall have defined initial position, which is considered safe and which the printer sets during the initialization.  
All servos shall have automatic cutoff when not in use. to limit the load of its electronics. This can be achieved for example by a delayed macro.  

## Klipper/Moonraker integration
The default distribution model of the GPSW is by cloning GitHub repo to dedicated host folder (other than klipper configuration folder).  
Updates of the GPSW shall be handled automaticaly by Moonraker Update manager.  
Read-only files shall stay in default cloned folder and be symlinked into klipper configuration folder. This ensures they will be automaticaly updated.  
R/W files shall be copied to klipper configuration folder. This means they will not be automaticaly updated and user is responsible for keeping them up to date.  
Bash script shall be provided, that will manage the symlinking and copying.  
Detailed instruction for instalation for users shall be provided. Language used shall be simple and straightforward.  
Script for automated update of R/W files is optional and may be added in the future.  


## Architecture
### Overal concept
The GPSW v1 shall be composed of small, modular macro blocks. Maximum modularity and granularity shall be achieved for maximum transparency and extendability.  
The GPSW shall conceptually be agnostic in regards to purging methodology. That means the basic architecture shall not be locked to the idea of belt purging and shall allow extensions for any generalised purging method.  
	note: this does not mean any other purging method shall be built in, just that it should be possible without conceptual redesign.  
The GPSW may reuse portions of code from Blobifier, either conceptually or literally, taking in mind rules of GPL-3.



### Variables and memory
All user accessible parameters shall be stored in user defined config section `[goose_purge_config]`, located in goose_purge_config.cfg and goose_purge_config.cfg files.  
This arrangement means klipper loads all default values from default file and then overwrites them with user defined ones if they are available. All such parameters are considered static and cannot be changed on runtime.
All internal variables which are to be persistent and accessible by several macros shall be stored in `_GOOSE_PURGE_INTERNAL_VARIABLES` macro, located in goose_purge.cfg.  
Local variables used exclusively within the same macro may be stored localy within said macro.  
No macro shall be accessing other macro variables (except above mentioned "variables" containter macros).  
Every macro shall start by loading external variables into internal variables. No external variables shall be accessed from the middle of the macro.  
Write to external variables shall be done only on the end of each macro.  

### Flow of the program
#### High level overview
Program gets initiated by calling the `GOOSE_PURGE` macro, with or without parameters.  
->  
`GOOSE_PURGE` macro attempts to read the input parameters and saves them as internal variables. It does not evaluate them or manipulate them in any way, only attempts to read them and store them.  
->  
If the parameters reading succeeded, macro shall call state machine macro `_GOOSE_PURGE_STATE_MACHINE`.  
	note1: this means everything beyond this point runs within the GOOSE_PURGE macro  
	note2: if the parameters are sufficiently filtered (e.g. PARAMETER|default(0)|float ), then it is not strictly necessary to test input validity within the code.  
->  
`_GOOSEPURGE_STATE_MACHINE` macro starts and enters the Phase 0  
##### Init Phase (Phase 0)
Initialization phase. Nothing within the printer moves, only internal evaluations are performed.  
During init phase are performed following actions:  
1. Evaluation of the input parameters. If multiple parameters are provided, it will proritize them based on a set hierarchy. If no parameters are given, it will attempt to get value based on multimaterial module configuration (e.g. to fetch value from HappyHare if its configured to interface with HH). If there is still no valid value, it shall fall back for default value.  
2. Fetch and store any useful information from the printer. This can be for example filament diameter, toolhead position, homing status.
3. Sanity check of all available variables for validity and plausability
4. Calculation of any missing values (e.g. conversion of volume to length)
5. Calculation of extrusion segments 
6. Post Phase 0 user configured macro - executes macro in goose_purge_custom_macros.cfg, empty by default
  
Any errors that happen during Phase 0 get logged (simple boolean flag should be sufficient) and if any are observed, `_GOOSEPURGE_STATE_MACHINE` stops its execution.  
If no errors are recorded, `_GOOSEPURGE_STATE_MACHINE` enters the Phase 1  

##### Staging phase (Phase 1)
Phase, where things start moving in printer, but we are still not preparing for the purging.  
Depending on configuration, some steps of this stage can be skipped.  
Following actions are to be performed:  
1. Stop any running delayed gcodes
2. Store the printer state
3. Set absolute coordinates (G90) and relative extrusion (M83)
4. Pre Phase 1 user configured macro
5. Z movement. Z has to be moved before anything else to ensure we will not collide with anything during next steps. Exact character of the Z movement is user configurable.
6. Servo(s) movement. Servos shall be moved to set purging position
7. XY movement to set staging position
8. Post Phase 1 user configured macro
  
Phase 1 is always followed by Phase 2  

##### Pre-purge (Phase 2)
Phase, where we do actions immediately preceeding purging  
Following actions are to be performed:
1. Placeholder (user configured macro ommited, because Phase 2 always follows phase 1)
2. Activate the drive (i.e. belt motor)
3. Perform Fan logic (activate or deactivate depending on configuration)
4. Move the toolhead to purging position
5. Post Phase 2 user configured macro
  
Phase 2 is always followed by Phase 3a  

##### Purging action (Phase 3a)
Phase, where we deposit the purge material  
Following actions are to be performed:
1. Placeholder (user configured macro ommited, because Phase 3a always follows phase 2 or phase 3b)
2. Extrude single purge segment of the material (XYZ movements are optional)
3. Post Phase 3a user configured macro
  
Phase 3a has to be followed by check of remaining material to be extruded. If nothing is left, Phase 4 follows. If there is still material to be purged, Phase 3 follows.  

##### Inter-Purge action (Phase 3b)
Phase in between purging actions. In case of belt purgers this is effectively dwell time. In case of other systems, this can be other mechanism.
Following actions are to be performed:
1. Pre Phase 3b user configured macro
2. Filament retraction
3. Inter-purge mechanism activation (accelerate the belt for belt purger)
4. Dwell time
5. Inter-purge mechanism deactivation (deccelerate the belt for belt purger. May require additional dwell to stabilize the parameters)
6. Filament deretraction
7. Post Phase 3b user configured macro
  
Phase 3b is allways followed by Phase 3a.  
Phases 3a and 3b may be combined within the single recursive macro. Individual actions should however still be containerized into internal macros. Should this combined recursive macro be used, prefered location would be within the parent state machine macro.  

##### Post purge action (Phase 4)
Phase after the purge where we do finishing moves. This is mainly purger and nozzle cleaning  
Following actions are to be performed:
1. Pre Phase 4 user configured macro
2. Filament retraction
3. Coasting. This means keeping the nozzle in the purge position for predefined time to wipe any oozing material. Usually skipped
4. XYZ movement back to the staging position
5. Purger cleaning action (to set the delayed action for the belt to clean any debris still present)
6. Nozzle brushing
7. XY movement into inital/parking position
8. Servo(s) movement back to stowed position
9. Z movement - Z axis shall be restored to initial condition
10. Post Phase 4 user configured macro
11. Restore initial printer state
