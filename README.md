# mips-verilog
This is a simplified MIPS processor that I built with Arthur Kam for a course at the University of Waterloo

# Processor
The processor is a fully-pipelined MIPS processor. It has no branch prediction. It has the standard MIPS bypass paths (M/X, W/M, W/X). Bubbles are generated on when a data element is used in the instruction immediately following a LW/LB instruction. 

# How does it work?
Programs are expressed in hex files and loaded into the data / code memory by the testbench. Then, the processor just starts grabbing words from the memory and begins the execuition flow. The processor was tested using a number of simple programs which tested the ability of the processor to perform recursive loops, pointer arithmetic, stack manipulation, and heap allocation. Examples include programs used to calculate numbers from the Fibbonaci sequence, perform Bubble Sort on mixed data, or swap elements in-place in the data cache.

# Caveats
This is not a full working MIPS processor: it implements a fully pipelined processor with a data and code cache. The data and code cache are seeded with the same initial contents, and the assumption is made that the code region is read-only (IE: the code and data cache are not synchonized). This processor does not implement the full MIPS instruction set: it was intended as a demonstration processor and is only built up enough to perform basic instructions.

# How can I run it?
The processor runs in ModelSim. 
