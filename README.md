# retro_gpu
Are you looking to build a 68k retro computer from scratch?  One of the biggest challanges is bridging new tech with old.  So
this project looks to solve one of those challanges the graphics display.  We are looking to keep the external parts of the 
design as simple as possible.  

Project Goals:
* Serial interface for low speed work including text interfaces (helpful at startup)
* 68k style bus interface for higher speed interfacing and direct access to Graphics Memory
* Dedicated graphics memory for frame buffer and off-screen buffers (initially on FPGA, eventually external DDR)
* 2D Blitter copy operations
* Porter-Duff blitter operations
* (future) 68k DMA interface

My work is being done in the http://pipistrello.saanlima.com/index.php?title=Welcome_to_Pipistrello using a Xilinx Spartan 6 
LX45.  This is using Xilinx specific HW in the FPGA so parting to non-Xilinx FPGAs will take some work.  
Building a GPU for retro computer builds.  This GPU will interface to modern monitors (HDMI/DVI) but provide a bus interface 
compatible with 68k processors.  It will have dedicated GPU memory for simplicity of the computer architecture.

Want to Thank Mike Field @hamsternz for his work to create the initial source used to generate the DVI signal generation.  
