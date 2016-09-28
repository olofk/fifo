proc dual_clock_fifo_false_paths { inst } {
    set_false_path -from [get_registers $inst\|wr_addr_gray\[*\]] -to [get_registers $inst\|wr_addr_gray_rd\[*\]]
    set_false_path -from [get_registers $inst\|wr_addr\[*\]]      -to [get_registers $inst\|wr_addr_gray_rd\[*\]]
    set_false_path -from [get_registers $inst\|rd_addr_gray\[*\]] -to [get_registers $inst\|rd_addr_gray_wr\[*\]]
    set_false_path -from [get_registers $inst\|rd_addr\[*\]]      -to [get_registers $inst\|rd_addr_gray_wr\[*\]]
}
