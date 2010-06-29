--------------------------------------------------------------------------------
--     This file is owned and controlled by Xilinx and must be used           --
--     solely for design, simulation, implementation and creation of          --
--     design files limited to Xilinx devices or technologies. Use            --
--     with non-Xilinx devices or technologies is expressly prohibited        --
--     and immediately terminates your license.                               --
--                                                                            --
--     XILINX IS PROVIDING THIS DESIGN, CODE, OR INFORMATION "AS IS"          --
--     SOLELY FOR USE IN DEVELOPING PROGRAMS AND SOLUTIONS FOR                --
--     XILINX DEVICES.  BY PROVIDING THIS DESIGN, CODE, OR INFORMATION        --
--     AS ONE POSSIBLE IMPLEMENTATION OF THIS FEATURE, APPLICATION            --
--     OR STANDARD, XILINX IS MAKING NO REPRESENTATION THAT THIS              --
--     IMPLEMENTATION IS FREE FROM ANY CLAIMS OF INFRINGEMENT,                --
--     AND YOU ARE RESPONSIBLE FOR OBTAINING ANY RIGHTS YOU MAY REQUIRE       --
--     FOR YOUR IMPLEMENTATION.  XILINX EXPRESSLY DISCLAIMS ANY               --
--     WARRANTY WHATSOEVER WITH RESPECT TO THE ADEQUACY OF THE                --
--     IMPLEMENTATION, INCLUDING BUT NOT LIMITED TO ANY WARRANTIES OR         --
--     REPRESENTATIONS THAT THIS IMPLEMENTATION IS FREE FROM CLAIMS OF        --
--     INFRINGEMENT, IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS        --
--     FOR A PARTICULAR PURPOSE.                                              --
--                                                                            --
--     Xilinx products are not intended for use in life support               --
--     appliances, devices, or systems. Use in such applications are          --
--     expressly prohibited.                                                  --
--                                                                            --
--     (c) Copyright 1995-2007 Xilinx, Inc.                                   --
--     All rights reserved.                                                   --
--------------------------------------------------------------------------------
-- You must compile the wrapper file multiplier2.vhd when simulating
-- the core, multiplier2. When compiling the wrapper file, be sure to
-- reference the XilinxCoreLib VHDL simulation library. For detailed
-- instructions, please refer to the "CORE Generator Help".

-- The synthesis directives "translate_off/translate_on" specified
-- below are supported by Xilinx, Mentor Graphics and Synplicity
-- synthesis tools. Ensure they are correct for your synthesis tool(s).

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
-- synthesis translate_off
Library XilinxCoreLib;
-- synthesis translate_on
ENTITY multiplier2 IS
	port (
	clk: IN std_logic;
	a: IN std_logic_VECTOR(19 downto 0);
	b: IN std_logic_VECTOR(19 downto 0);
	p: OUT std_logic_VECTOR(39 downto 0));
END multiplier2;

ARCHITECTURE multiplier2_a OF multiplier2 IS
-- synthesis translate_off
component wrapped_multiplier2
	port (
	clk: IN std_logic;
	a: IN std_logic_VECTOR(19 downto 0);
	b: IN std_logic_VECTOR(19 downto 0);
	p: OUT std_logic_VECTOR(39 downto 0));
end component;

-- Configuration specification 
	for all : wrapped_multiplier2 use entity XilinxCoreLib.mult_gen_v10_0(behavioral)
		generic map(
			c_a_width => 20,
			c_b_type => 0,
			c_ce_overrides_sclr => 0,
			c_opt_goal => 1,
			c_has_sclr => 0,
			c_round_pt => 0,
			c_out_high => 39,
			c_mult_type => 1,
			c_ccm_imp => 0,
			c_has_load_done => 0,
			c_pipe_stages => 5,
			c_has_ce => 0,
			c_has_zero_detect => 0,
			c_round_output => 0,
			c_use_p_cascade_out => 0,
			c_mem_init_prefix => "mgv10",
			c_xdevicefamily => "spartan3e",
			c_a_type => 0,
			c_out_low => 0,
			c_b_width => 20,
			c_b_value => "10000001");
-- synthesis translate_on
BEGIN
-- synthesis translate_off
U0 : wrapped_multiplier2
		port map (
			clk => clk,
			a => a,
			b => b,
			p => p);
-- synthesis translate_on

END multiplier2_a;

