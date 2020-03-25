# TJames CMS scouting firmware repo


Summary of components:

All inside Pico framework

scout_top // UserModule, top level for scouting project - 2x picostream_64 out, clk & rst in

  global_reset // resets I2Cs resister and/or MGTs
  inputs // MGTs, data unpacking, link configuration, 8x 10Gbps links in w/ CERN L1T protocol
  gap_cleaner // removes header/trailer frames
  aligner // aligning BXs & concatenating
  zero_suppression // removes packets with no muons
  fifo_filler // fill AXI FIFOs 
