###############################################################
### Measure intensity, jitter, shimmer, HNR, mean F0, sd F0 ###
###############################################################

form Analyze one Nemours speaker
    word: "Base_directory", "."
    word: "Speaker_code", "BB"
    word: "Wave_dir_name", "WAV"
    integer: "Tier_number", "1"
    real: "Trim_fraction_each_side", "0.25"
    sentence: "Result_file", "IJSHF.csv"
endform

clearinfo

#############################################
### Start fresh CSV
#############################################
if fileReadable (result_file$)
    deleteFile: result_file$
endif

header$ = "Speaker,File,Interval,Label,MidStart_s,MidEnd_s,MeanIntensity_dB,Jitter_local,Shimmer_local, hnr, meanF0, sdF0"
appendFileLine: result_file$, header$

#############################################
### Build paths
#############################################
wavdir$ = base_directory$ + "/" + speaker_code$ + "/" + wave_dir_name$

#############################################
### Get WAV files
#############################################
wavFiles$# = fileNames$#: wavdir$ + "/*.WAV"
appendInfoLine: wavFiles$#[1]
nFiles = size(wavFiles$#)

if nFiles = 0
    exitScript: "No WAV files found."
endif

#############################################
### Loop over WAV files
#############################################
for f from 1 to nFiles

    filename$ = wavFiles$#[f]
    soundpath$ = wavdir$ + "/" + filename$

    appendInfoLine: "Processing: ", filename$

    #########################################
    ### Read Sound
    #########################################
    sound = Read from file: soundpath$
    soundname$ = selected$ ("Sound")

    #########################################
    ### Read TextGrid
    #########################################
    gridfile$ = wavdir$ + "/" + soundname$ + ".TextGrid"
    tg = Read from file: gridfile$

    #########################################
    ### Create analysis objects (once per file)
    #########################################
    selectObject: sound
    intensity = To Intensity: 75, 0.1, 1

    selectObject: sound
    pp = To PointProcess (periodic, cc): 75, 400

    selectObject: sound
    h = To Harmonicity (cc): 0.01, 75, 0.1, 1

    selectObject: sound
    pitch = To Pitch (filtered autocorrelation): 0, 50, 800, 15, "no", 0.03, 0.09, 0.5, 0.055, 0.35, 0.14
    #########################################
    ### Loop intervals
    #########################################
    selectObject: tg
    nIntervals = Get number of intervals: tier_number

    for i from 1 to nIntervals

        selectObject: tg
        label$ = Get label of interval: tier_number, i
        start = Get starting point: tier_number, i
        end   = Get end point: tier_number, i
        dur   = end - start

        #####################################
        ### Mid-section window
        #####################################
        midStart = start + trim_fraction_each_side * dur
        midEnd   = end   - trim_fraction_each_side * dur

        #####################################
        ### Intensity
        #####################################
        selectObject: intensity
        meanIntensity = Get mean: midStart, midEnd, "energy"

        #####################################
        ### Jitter
        #####################################
        jitterLocal = undefined

        if (midEnd - midStart) >= 0.10
            selectObject: pp
            jitterLocal  = Get jitter (local): midStart, midEnd, 0.0001, 0.02, 1.3
        endif
	#####################################
        ### shimmer
        #####################################
	shimmerLocal = undefined

 	if (midEnd - midStart) >= 0.10
            selectObject: sound
            plusObject: pp
            shimmerLocal = Get shimmer (local): midStart, midEnd, 0.0001, 0.02, 1.3, 1.6
        endif
	#####################################
        ### HNR
        #####################################
	hnr = undefined

	if (midEnd - midStart) >= 0.10
            selectObject: h
            hnr = Get mean: midStart, midEnd 
	endif
        #####################################
        ### mean F0 
        #####################################
        meanF0 = undefined

        if (midEnd - midStart) >= 0.10
            selectObject: pitch
            meanF0 = Get mean: midStart, midEnd, "Hertz"
        endif
 	#####################################
        ### SD F0
        #####################################
        sdF0 = undefined

        if (midEnd - midStart) >= 0.10
	    selectObject: pitch
	    sdF0 = Get standard deviation: midStart, midEnd, "Hertz"
        endif
        #####################################
        ### Write CSV row
        #####################################
        row$ = speaker_code$ + "," + soundname$ + "," + string$(i) + "," + label$ + ","
        row$ = row$ + fixed$(midStart,4) + "," + fixed$(midEnd,4) + ","
        row$ = row$ + fixed$(meanIntensity,2) + "," + fixed$(jitterLocal,5) + "," + fixed$(shimmerLocal,6) + "," + fixed$(hnr,2) + "," + fixed$(meanF0,2) + "," + fixed$(sdF0,2)

        appendFileLine: result_file$, row$

    endfor

    #########################################
    ### Cleanup per file
    #########################################
    removeObject: tg, intensity, pp, sound, pitch

endfor

writeInfoLine: "DONE. Results saved to ", result_file$