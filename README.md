# An interactive tool to analyze data from protein-ligand binding experiments 
Interactive Matlab tool to analyze phosphorimager images from DRaCALA experiments.

ADD MORE TO SUMMARY

ADD BASIC WORKFLOW

ADD EXPLANATION ON FUNCTIONS
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


NOTES ON IMAGE TYPES 
Sample images are stored in Quantum Level (QL) pixel scaling data, which is a log-transformed, non-linear pixel scaling performed by standard phosphoimager instruments. The function ql2psl() [in ql2psl.m] performs a log-to-linear transformation on each pixel in a grayscale 2D image to convert it to a Photo Stimulated Luminescence (PSL) value. The PSL value is the true measure of fluorescence from the radio-labelled ligand.

If images are already PSL-converted, then the QL2PSL algorithm will not run [IN-PROGRESS] and data will be analyzed as is. Images in neither QL or PSL format will not yield accurate data, although the trends in pixel intensity appear to correlate with PSL-converted images.  


NOTES ON IN-PROGRESS FUNCTIONALITY
- addData_spotAnalyzer
- deleteData_spotAnalyzer
- autoSegment (.fig)
- psl2ql
- Data analysis and figure creation GUI (.m and .fig)

BUGS AND LIMITATIONS 
Known Bugs:
- Text boxes can sometimes pre-load with information from the previous session. This doesn't affect loading of the next image, but it can be annoying to see.
- Single-spot window can sometimes pre-load with an image from the previous session. The "Reset" button loads the default image. 

Limitations
- Spots are not yet moveable
- Individual spots are not resizeable, and thus the user must work with circle radii of the same sizes for all spots. 
