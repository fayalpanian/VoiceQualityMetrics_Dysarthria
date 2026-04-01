## Acoustic Analysis Scripts for the Nemours Dysarthric Speech Database

This repository provides Praat scripts for preprocessing and acoustic analysis of speech samples from the Nemours Database of Dysarthric Speech.

## Workflow

1. Access Nemours database 
1. **Access the Nemours database**  
   Copy the required speech files into the following directory:
   `Nemours\SPEECH\SENT`

2. TextGrid generation
Run `TextGridCreationForSegFiles.praat` to convert segmentation files into Praat TextGrid files.

3. Voice quality analysis
Run `VoiceQualityMetrics.praat` to extract the following acoustic and voice quality measures:

- Intensity
- Jitter
- Shimmer
- Harmonics-to-Noise Ratio (HNR)
- Mean F0
- SD F0

