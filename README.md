# wfc-font
Generate fonts using wave function collapse

# About  
This sketch utilizes the wave function collapse algorithm (or rather my interpretation of it) to generate images.  
This may be used for various things, including, but not limited to:
- generating fonts (my primary goal)  
- alternative to grayscaling images  
- generating nice patterns..  

# Usage  
This sketch requires [processing](https://processing.org) to be installed. Open wfc_font.pde with processing.  
The first few lines may be changed to your desire and affect horizontal and vertical cell count, as well as the cell's size.  
Important:  
- As of now, width and height need to be in a 1:1 ratio!  
- If the grid does not fit on your screen, reduce the cell size. This will **not** affect the image quality, when exporting!

Use the following keys:  
- p : paint the screen with your mouse/trackpad/trackpoint  
- s : solve the wave function  
- i : load an image as a mask and solve the wave function  
- c : cleanup, this will add end-caps to paths leading to nowhere  
- f : save image (time of day is used as a file name) to the working directory  

# Changing the textures  
All used textures are in "files_0". You can put your own tiles in it, but:  
- they should have a 1:1 ratio  
- they must be named by their connectivity in binary. 1 for connection, 0 for no connection. The cycle is up, right, bottom, left.  
- they must end in .png  

# TODO  
- make different tiles accessible from within the prrogram  
- user should not have to restart the sketch when creating a new image  
- fix a weird screen-ration bug...  
