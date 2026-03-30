# Notes from i2c_pkg.sv

### FIFOs used in I2C:
Controller:
    FMT FIFO : controller writes commands / data into this (13 bits)
    RX FIFO : controller stores bytes read from the bus (8 bit)

Target:
    TX FIFO : target prepares bytes to send when masters reads (8 bit)
    ACQ FIFO : target stores everything it received from the bus (11 bit)


### FMT FIFO
FMT FIFO has width of 13 bits where 8 bit is for the data and the remaining 5 bit is for the signal. The signals are: 
    
    1. START - issue START before transmitting
    2. STOP - issue STOP after transmitting
    3. READB - 1 = read N bytes, 0 = write 
    4. RCONT - don't NACK the last read byte, keep going
    5. NAKOK - don't halt if this byte gets NACKED

The FMT FIFO is a queue of instructions firmware writes to drive the controller. Each entry says "here's a byte, and here's what to do around it."


# Notes from i2c_reg_pkg.sv
This file defines two data types: `reg2hw` and `hw2reg`. As the name suggest, `reg2hw` carries values from software-written registers down to hardware, and `hw2reg` carries values from hardware back up to software-readable registers.

There are 5 key signals. `q` is the value software wrote, which hardware reads. `qe` pulses for one cycle when software writes a register - if `qe` is present, that register is a FIFO push, meaning firmware just pushed an entry for hardware to consume. `re` pulses for one cycle when software reads a register - if `re` is present, that register is a FIFO pop, meaning the act of firmware reading it automatically advances the FIFO. `d` is the value hardware drives into a register for firmware to read. `de` is present when hardware only updates that register conditionally - on an event, interrupt or counter increment - rather than every cycle.

# Notes from i2c_core.sv
Its a file that maps the sub modules and make a bridge between registers like reg2hw and hw2reg to communicate with sda and scl. it does so by using some submodules like i2c_fifos, i2c_bus_monitor, i2c_controller_fsm, i2c_target_fsm.