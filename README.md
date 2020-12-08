# System-Level-Design-of-MIPS-Processor

In this project, I:

• Designed a single-cycle non-pipelined MIPS processor using Verilog.

• Implemented capability for module to execute 32-bit MIPS machine code.

• Used Quartus to synthesize and EDA Playground to testbench the implementation.

To run the program, visit https://www.edaplayground.com/ and copy the code from testbench.v and mips.v into the left (testbench.sv) and right (design.sv) panel, respectively. Next, set the "Testbench + Design" dropdown menu to "SystemVerilog/Verilog" and the "Tools & Simulators" dropdown menu to "Icarus Verilog 0.9.7". Finally, click on run (you may have to log in / create an account). 

The simulation will first fill in the lower bits from 0 to F and then from F to 0. Lastly, it will fill in the higher bits to FFFF8XXX and repeat the previous process. The purpose of this was to test the word-level addressing property along with basic functionality through various instructions of the MIPS processor.

If you have any more questions, feel free to message me!
