gui_open_window Wave
gui_sg_create mmcm_test_group
gui_list_add_group -id Wave.1 {mmcm_test_group}
gui_sg_addsignal -group mmcm_test_group {mmcm_test_tb.test_phase}
gui_set_radix -radix {ascii} -signals {mmcm_test_tb.test_phase}
gui_sg_addsignal -group mmcm_test_group {{Input_clocks}} -divider
gui_sg_addsignal -group mmcm_test_group {mmcm_test_tb.CLK_IN1}
gui_sg_addsignal -group mmcm_test_group {{mmcm_test_tb.CLK_IN2} {mmcm_test_tb.CLK_IN_SEL}}
gui_sg_addsignal -group mmcm_test_group {{Output_clocks}} -divider
gui_sg_addsignal -group mmcm_test_group {mmcm_test_tb.dut.clk}
gui_list_expand -id Wave.1 mmcm_test_tb.dut.clk
gui_sg_addsignal -group mmcm_test_group {{Status_control}} -divider
gui_sg_addsignal -group mmcm_test_group {mmcm_test_tb.RESET}
gui_sg_addsignal -group mmcm_test_group {mmcm_test_tb.LOCKED}
gui_sg_addsignal -group mmcm_test_group {{Counters}} -divider
gui_sg_addsignal -group mmcm_test_group {mmcm_test_tb.COUNT}
gui_sg_addsignal -group mmcm_test_group {mmcm_test_tb.dut.counter}
gui_list_expand -id Wave.1 mmcm_test_tb.dut.counter
gui_zoom -window Wave.1 -full
