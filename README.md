# An interactive tool to analyze data from protein-ligand binding experiments 
Interactive Matlab tool to analyze phosphorimager scans from DRaCALA experiments. Differential Radial Capillary Action of Ligand Assay (DRaCALA) is a biochemical technique to measure the binding of a protein (purified or from cell lysate) to a radio-labelled small molecule. Data are in the form of small "spots" of protein/lysate with the labelled molecule. Strong binding inhibits the ability for the small molecule to diffuse through the spot, and produces a localized signal (in the form of a smaller/inner "spot") within the larger spot.

This tool was designed to process and analyze data from high-throughput methods, where DRaCALA is performed in a 96-well plate. These are a pain to analyze manually (as I have had the misfortune of witnessing), and so I developed (am developing) this tool to automate this analysis. 

ADD MORE TO SUMMARY

## BASIC WORKFLOW
- Do this
- Then do that
- Try to avoid breaking things
- Publish! 

## Main Functions
- QuantDRaCALA (.m and .fig)
- spotAnalyzer 
- getSpotData
- maskOnCircles
- singleSpot
- autoSegment
- spotReIndex
- ql2psl
- saveSpots
- changeRadii (.m and .fig)
 

## NOTES ON IMAGE TYPES (IMPORTANT!)
Sample images are stored as Quantum Level (QL) pixel scaling data, which is a log-transformed, non-linear pixel scaling method performed by standard phosphoimager instruments. The function ql2psl() [in ql2psl.m] performs a log-to-linear transformation on each pixel of an 8-bit or 16-bit grayscale 2D image to convert it to a Photo Stimulated Luminescence (PSL) value. The PSL value is the true measure of fluorescence from the radio-labelled ligand.

If images are already PSL-converted, then the QL2PSL algorithm will not run [function IN-PROGRESS] and data will be analyzed as is. Images in neither QL nor PSL format will not yield accurate data; however the trends in pixel intensity appear to correlate generally well with PSL-converted images, except in spots with low Fraction Bound values (FB < 0.05).


## IN-PROGRESS FUNCTIONALITY
- addData_spotAnalyzer
- deleteData_spotAnalyzer
- autoSegment (.fig)
- psl2ql
- Data analysis and figure creation GUI (.m and .fig)

## BUGS AND LIMITATIONS 
Known Bugs:
- Text boxes can sometimes pre-load with information from the previous session. This doesn't affect loading of the next image, but it can be annoying to see.
- Single-spot window can sometimes pre-load with an image from the previous session. The "Reset" button loads the default image. 

Limitations
- Spots are not yet moveable
- Individual spots are not resizeable, and thus the user must work with circle radii of the same sizes for all spots. 
