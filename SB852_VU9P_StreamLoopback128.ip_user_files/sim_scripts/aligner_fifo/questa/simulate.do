onbreak {quit -f}
onerror {quit -f}

vsim -t 1ps -lib xil_defaultlib aligner_fifo_opt

do {wave.do}

view wave
view structure
view signals

do {aligner_fifo.udo}

run -all

quit -force
