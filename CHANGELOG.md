## Changelog

### v4.13.1 (2025-06-25)
#### Changed
- Visual stim: increase time out on TCP draw command

---

### v4.13 (2024-08-05)
#### Fixed
- expose masker level as sequence variable when masker is active
#### Changed
- apply cos2 ramp to masker when it changes level

---

### v4.12.4 (2024-07-25)
#### Fixed
- bug testing masker in previous version

---

### v4.12.3 (2024-07-25)
#### Fixed
- faster syntax to retrieve computer name for file header. Starts faster and avoids timeout error waiting for DI filename.
- continuous masker had rising ramp on every frame

---

### v4.12.2 (2024-04-30)
#### Fixed
- disabled status request in visual display thread to circumvent as yet unknown error

---

### v4.12.1 (2024-04-18)
#### Fixed
- more robust handling of MATLAB command window/sequence order script

---

### v4.12 (2024-04-17)
#### Added
- Arbitrary sequence order

---

### v4.11 (2024-04-08)
#### Added
- signal gate: exposed repeat rate and duration properties

#### Fixed
- change to TCP-controlled device start command was not sticking
- changes to TTL device setup propagated to editor, current parameters

---

### v4.10.1 (2024-01-29)
#### Fixed
- accumulator logic now works for latency > 0
- installer now creates shortcut to previous version only when asked

---

### v4.10 (2024-01-02)
#### Added
- TCP-controlled devices

---

### v4.9.4 (2023-12-18)
#### Fixed
- signal synthesis error was not killing AO thread
- fixed calibration error using USB board (epl-vi-lib, epl-cal-vi-lib)
- do not read past end of .f64 file (epl-vi-lib) to avoid error (loop or zero-pad as required)
- error in v4.9.1 associated with updating TTL spec was causing TTL threads not to initiate (no TTL outputs!)

---

### ~v4.9.3 (2023-11-30)~ *DO NOT USE*
#### Fixed
- flatten-to-string error when saving gate with shape=OFF and duration > 0
- visual stim now opens correctly from the Connections dialog
- visual stim now functions correctly during run

---

### ~v4.9.2 (2023-11-20)~ *DO NOT USE*

#### Fixed
- AO/AI sync error on 4461 board (epl-vi-lib) 

---

### ~v4.9.1 (2023-10-13)~ *DO NOT USE*

#### Fixed
- made read of TTL output specification backward compatible
- fixed bug saving parameters after changing noise weighting to white

---

### v4.9 (2023-10-11)

#### Added

- allow "Volts" as user file reference

#### Changed

- simplified device setup dialog

---

### v4.8.2 (2023-09-08)

#### Fixed
- bug reading calibration files

---

### v4.8.1 (2023-09-05)

#### Added
- User file searches for dB Vrms reference when applicable
- User file option to loop (rather than zero-pad) when the file is not an integer number of audio frames long
  
#### Changed
- Uses general purpose freefield calibration

---

### v4.8 (2023-08-31)
  
#### Added
- pink noise option
 
---

### v4.7.0.3543 (2023-08-04)

#### Fixed
- removed dependency on ToscaControls.dll
- connection manager only prompts to save if something has been changed
- automatically set timeout to -1 (no timeout) when timeout links nowhere and there is another way out of the state (i.e. an event)  

#### Changed
- clearing the flowchart automatically brings up the editor  

---

### Older
Summary of pre-GitHub changes

| Version | Date | Description |
| --- | --- | --- |












