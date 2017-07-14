# An interactive tool to analyze data from protein-ligand binding experiments 
Interactive Matlab tool to analyze phosphorimager scans from DRaCALA experiments. Differential Radial Capillary Action of Ligand Assay (DRaCALA) is a biochemical technique to measure the binding of a protein (purified or from cell lysate) to a radio-labelled small molecule. Data are in the form of small "spots" of protein or lysate with the labelled molecule. Strong binding inhibits the ability for the small molecule to diffuse throughout the spot, and produces a localized signal in the form of a smaller inner "spot" within the larger spot. 

QuantDRaCALA provides an intuitive interface with a simple design that allows the user to load a phosphorimager-scanned file from their DRaCALA experiment, very quickly identify and pre-process each spot, create inner and outer circles over these spots, then analyze and save their data. Images with QL-value pixels are automatically converted to PSL-values, so the user can directly load their raw scanned images (although directly loading .img/.inf files is still in-progress). This tool was designed for more high-throughput experiments, where DRaCALA is performed in a 96-well plate. Manually analyzing these data can be time-consuming and repetitive (as I have had the misfortune of witnessing), and so I started developing this tool to automate this analysis. 

Screenshots of the GUI windows and sample images are shown below. 

## BASIC WORKFLOW
- Installation and Set-up

    Download all files and folders from this GitHub page and place into desired directory. Then either: 
    
        1) Set Path to this directory
            Execute program by typing "QuantDRaCALA" in the console
            
        2) Use Matlab's Package App tool to package the program as an executable Matlab app  
            Start the program by clicking on the QuantDRaCALA app icon

- Pre-processing and Loading Images

    Read "Notes on Image Types" section below before using this program. 
    
    
- Adjusting and Processing of Spots

    asdf 

- Analyzing and Saving Data

    asdf 

- Data Formats

    asdf 

## Main Functions
- QuantDRaCALA (.m and .fig)
- changeRadii (.m and .fig)
- splitFullPlate
- autoSegment
- ql2psl
- spotAnalyzer 
- spotReIndex
- getSpotProps
- getSpotData
- singleSpot
- saveSpots

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
- Draggable and Resizeable spots overload the image axis and make panning and zooming very slow. I haven't found a way to optimize dealing with the large number of objects.  

## Sample 
