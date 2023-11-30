## Changelog

### v4.9.3 (2023-11-30)
#### Fixed
- flatten-to-string error when saving gate with shape=OFF and duration > 0
- visual stim now opens correctly from the Connections dialog
- visual stim now functions correctly during run

### v4.9.2 (2023-11-20)

#### Fixed
- AO/AI sync error on 4461 board (epl-vi-lib) 

---

### v4.9.1

#### Fixed
- made read of TTL output specification backward compatible
- fixed bug saving parameters after changing noise weighting to white

---

### v4.9

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












