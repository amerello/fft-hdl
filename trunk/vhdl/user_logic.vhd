------------------------------------------------------------------------------
-- user_logic.vhd - entity/architecture pair
------------------------------------------------------------------------------
--
-- ***************************************************************************
-- ** Copyright (c) 1995-2008 Xilinx, Inc.  All rights reserved.            **
-- **                                                                       **
-- ** Xilinx, Inc.                                                          **
-- ** XILINX IS PROVIDING THIS DESIGN, CODE, OR INFORMATION "AS IS"         **
-- ** AS A COURTESY TO YOU, SOLELY FOR USE IN DEVELOPING PROGRAMS AND       **
-- ** SOLUTIONS FOR XILINX DEVICES.  BY PROVIDING THIS DESIGN, CODE,        **
-- ** OR INFORMATION AS ONE POSSIBLE IMPLEMENTATION OF THIS FEATURE,        **
-- ** APPLICATION OR STANDARD, XILINX IS MAKING NO REPRESENTATION           **
-- ** THAT THIS IMPLEMENTATION IS FREE FROM ANY CLAIMS OF INFRINGEMENT,     **
-- ** AND YOU ARE RESPONSIBLE FOR OBTAINING ANY RIGHTS YOU MAY REQUIRE      **
-- ** FOR YOUR IMPLEMENTATION.  XILINX EXPRESSLY DISCLAIMS ANY              **
-- ** WARRANTY WHATSOEVER WITH RESPECT TO THE ADEQUACY OF THE               **
-- ** IMPLEMENTATION, INCLUDING BUT NOT LIMITED TO ANY WARRANTIES OR        **
-- ** REPRESENTATIONS THAT THIS IMPLEMENTATION IS FREE FROM CLAIMS OF       **
-- ** INFRINGEMENT, IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS       **
-- ** FOR A PARTICULAR PURPOSE.                                             **
-- **                                                                       **
-- ***************************************************************************
--
------------------------------------------------------------------------------
-- Filename:          user_logic.vhd
-- Version:           1.00.a
-- Description:       User logic.
-- Date:              Mon May 31 12:24:44 2010 (by Create and Import Peripheral Wizard)
-- VHDL Standard:     VHDL'93
------------------------------------------------------------------------------
-- Naming Conventions:
--   active low signals:                    "*_n"
--   clock signals:                         "clk", "clk_div#", "clk_#x"
--   reset signals:                         "rst", "rst_n"
--   generics:                              "C_*"
--   user defined types:                    "*_TYPE"
--   state machine next state:              "*_ns"
--   state machine current state:           "*_cs"
--   combinatorial signals:                 "*_com"
--   pipelined or register delay signals:   "*_d#"
--   counter signals:                       "*cnt*"
--   clock enable signals:                  "*_ce"
--   internal version of output port:       "*_i"
--   device pins:                           "*_pin"
--   ports:                                 "- Names begin with Uppercase"
--   processes:                             "*_PROCESS"
--   component instantiations:              "<ENTITY_>I_<#|FUNC>"
------------------------------------------------------------------------------

-- DO NOT EDIT BELOW THIS LINE --------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

library proc_common_v2_00_a;
use proc_common_v2_00_a.proc_common_pkg.all;

-- DO NOT EDIT ABOVE THIS LINE --------------------

--USER libraries added here
--library fft_core;
--use fft_core.cf_fft_256_8;
------------------------------------------------------------------------------
-- Entity section
------------------------------------------------------------------------------
-- Definition of Generics:
--   C_SLV_DWIDTH                 -- Slave interface data bus width
--   C_NUM_REG                    -- Number of software accessible registers
--
-- Definition of Ports:
--   Bus2IP_Clk                   -- Bus to IP clock
--   Bus2IP_Reset                 -- Bus to IP reset
--   Bus2IP_Data                  -- Bus to IP data bus
--   Bus2IP_BE                    -- Bus to IP byte enables
--   Bus2IP_RdCE                  -- Bus to IP read chip enable
--   Bus2IP_WrCE                  -- Bus to IP write chip enable
--   IP2Bus_Data                  -- IP to Bus data bus
--   IP2Bus_RdAck                 -- IP to Bus read transfer acknowledgement
--   IP2Bus_WrAck                 -- IP to Bus write transfer acknowledgement
--   IP2Bus_Error                 -- IP to Bus error response
------------------------------------------------------------------------------

entity user_logic is
  generic
  (
    -- ADD USER GENERICS BELOW THIS LINE ---------------
    --USER generics added here
    -- ADD USER GENERICS ABOVE THIS LINE ---------------

    -- DO NOT EDIT BELOW THIS LINE ---------------------
    -- Bus protocol parameters, do not add to or delete
    C_SLV_DWIDTH                   : integer              := 32;
    C_NUM_REG                      : integer              := 3
    -- DO NOT EDIT ABOVE THIS LINE ---------------------
  );
  port
  (
    -- ADD USER PORTS BELOW THIS LINE ------------------
    -- ADD USER PORTS ABOVE THIS LINE ------------------

    -- DO NOT EDIT BELOW THIS LINE ---------------------
    -- Bus protocol ports, do not add to or delete
    Bus2IP_Clk                     : in  std_logic;
    Bus2IP_Reset                   : in  std_logic;
    Bus2IP_Data                    : in  std_logic_vector(0 to C_SLV_DWIDTH-1);
    Bus2IP_BE                      : in  std_logic_vector(0 to C_SLV_DWIDTH/8-1);
    Bus2IP_RdCE                    : in  std_logic_vector(0 to C_NUM_REG-1);
    Bus2IP_WrCE                    : in  std_logic_vector(0 to C_NUM_REG-1);
    IP2Bus_Data                    : out std_logic_vector(0 to C_SLV_DWIDTH-1);
    IP2Bus_RdAck                   : out std_logic;
    IP2Bus_WrAck                   : out std_logic;
    IP2Bus_Error                   : out std_logic
    -- DO NOT EDIT ABOVE THIS LINE ---------------------
  );

  attribute SIGIS : string;
  attribute SIGIS of Bus2IP_Clk    : signal is "CLK";
  attribute SIGIS of Bus2IP_Reset  : signal is "RST";

end entity user_logic;

------------------------------------------------------------------------------
-- Architecture section
------------------------------------------------------------------------------

architecture IMP of user_logic is

  --USER signal declarations added here, as needed for user logic
  --XFFT_V6_0
  signal fwd_inv_we       : std_logic := '0'; --Write enable for FWD_INV (Active High) Low on operation.
  signal rfd              : std_logic;        --Ready for data (Active High): RFD is High during the load operation.
  signal start            : std_logic := '1'; --FFT start signal (Active High): START is asserted to begin the data loading and transform calculation.
  signal fwd_inv          : std_logic := '1'; --ForwardFFT='1'  InverseFFT='0'
  signal dv               : std_logic;        --Data valid (Active High): This signal is High when valid data is presented at the output.
  signal unload           : std_logic := '1'; --Result unloading (Active High): For the Burst I/O architectures, UNLOAD starts the unloading of the results in natural order.
  signal done             : std_logic;        --FFT complete strobe (Active High): DONE transitions High for one clock cycle when the transform calculation has completed.
  signal clk              : std_logic; 
  signal busy             : std_logic;        --Core activity indicator (Active High): This signal goes High while the core is computing the transform.
  signal edone            : std_logic;        --Ignorar
  signal xn_re            : std_logic_vector(7 downto 0); 
  signal xk_im            : std_logic_vector(16 downto 0); 
  signal xn_index         : std_logic_vector(7 downto 0); 
  signal xk_re            : std_logic_vector(16 downto 0); 
  signal xn_im            : std_logic_vector(7 downto 0); 
  signal xk_index         : std_logic_vector(7 downto 0);

  type estados_fft is(inicio, carga, descarga);
  signal state : estados_fft := inicio;

  --MULTIPLICADORES
  signal p1               : std_logic_VECTOR(33 downto 0);
  signal p2               : std_logic_VECTOR(33 downto 0);
  signal p3               : std_logic_VECTOR(33 downto 0);

  --MODULO
  signal rdy              : std_logic;
  signal x_in             : std_logic_vector(33 downto 0);
  signal x_out            : std_logic_vector(17 downto 0);
  
  --SENO
  signal i          : integer range 0 to 1000:=0;
  type memory_type is array (0 to 255) of integer range -128 to 127; --ROM for storing the sine values generated by sine.c
  --signal sine       : memory_type :=(0,0,1,2,3,4,4,5,6,7,8,8,9,10,11,12,12,13,14,15,16,16,17,18,19,20,20,21,22,23,23,24,25,26,27,27,28,29,30,31,31,32,33,34,34,35,36,37,38,38,39,40,41,41,42,43,44,44,45,46,47,47,48,49,50,50,51,52,53,53,54,55,55,56,57,58,58,59,60,60,61,62,63,63,64,65,65,66,67,67,68,69,69,70,71,71,72,73,73,74,75,75,76,77,77,78,79,79,80,80,81,82,82,83,84,84,85,85,86,87,87,88,88,89,89,90,91,91,92,92,93,93,94,94,95,96,96,97,97,98,98,99,99,100,100,101,101,102,102,103,103,104,104,104,105,105,106,106,107,107,108,108,108,109,109,110,110,110,111,111,112,112,112,113,113,114,114,114,115,115,115,116,116,116,117,117,117,118,118,118,119,119,119,119,120,120,120,120,121,121,121,121,122,122,122,122,123,123,123,123,123,124,124,124,124,124,125,125,125,125,125,125,126,126,126,126,126,126,126,126,126,127,127,127,127,127,127,127,127,127,127,127,127,127,127,127,127,127,127,127,127,127,127,127,127,127,127,127,127,127,127,127,127,127,127,127,127,127,127,127,126,126,126,126,126,126,126,126,126,125,125,125,125,125,125,124,124,124,124,124,123,123,123,123,123,122,122,122,122,121,121,121,121,120,120,120,120,119,119,119,119,118,118,118,117,117,117,116,116,116,115,115,115,114,114,114,113,113,112,112,112,111,111,110,110,110,109,109,108,108,108,107,107,106,106,105,105,104,104,104,103,103,102,102,101,101,100,100,99,99,98,98,97,97,96,96,95,94,94,93,93,92,92,91,91,90,89,89,88,88,87,87,86,85,85,84,84,83,82,82,81,80,80,79,79,78,77,77,76,75,75,74,73,73,72,71,71,70,69,69,68,67,67,66,65,65,64,63,63,62,61,60,60,59,58,58,57,56,55,55,54,53,53,52,51,50,50,49,48,47,47,46,45,44,44,43,42,41,41,40,39,38,38,37,36,35,34,34,33,32,31,31,30,29,28,27,27,26,25,24,23,23,22,21,20,20,19,18,17,16,16,15,14,13,12,12,11,10,9,8,8,7,6,5,4,4,3,2,1,0,0,0,-1,-2,-3,-4,-4,-5,-6,-7,-8,-8,-9,-10,-11,-12,-12,-13,-14,-15,-16,-16,-17,-18,-19,-20,-20,-21,-22,-23,-23,-24,-25,-26,-27,-27,-28,-29,-30,-31,-31,-32,-33,-34,-34,-35,-36,-37,-38,-38,-39,-40,-41,-41,-42,-43,-44,-44,-45,-46,-47,-47,-48,-49,-50,-50,-51,-52,-53,-53,-54,-55,-55,-56,-57,-58,-58,-59,-60,-60,-61,-62,-63,-63,-64,-65,-65,-66,-67,-67,-68,-69,-69,-70,-71,-71,-72,-73,-73,-74,-75,-75,-76,-77,-77,-78,-79,-79,-80,-80,-81,-82,-82,-83,-84,-84,-85,-85,-86,-87,-87,-88,-88,-89,-89,-90,-91,-91,-92,-92,-93,-93,-94,-94,-95,-96,-96,-97,-97,-98,-98,-99,-99,-100,-100,-101,-101,-102,-102,-103,-103,-104,-104,-104,-105,-105,-106,-106,-107,-107,-108,-108,-108,-109,-109,-110,-110,-110,-111,-111,-112,-112,-112,-113,-113,-114,-114,-114,-115,-115,-115,-116,-116,-116,-117,-117,-117,-118,-118,-118,-119,-119,-119,-119,-120,-120,-120,-120,-121,-121,-121,-121,-122,-122,-122,-122,-123,-123,-123,-123,-123,-124,-124,-124,-124,-124,-125,-125,-125,-125,-125,-125,-126,-126,-126,-126,-126,-126,-126,-126,-126,-127,-127,-127,-127,-127,-127,-127,-127,-127,-127,-127,-127,-127,-127,-127,-127,-127,-127,-127,-128,-127,-127,-127,-127,-127,-127,-127,-127,-127,-127,-127,-127,-127,-127,-127,-127,-127,-127,-127,-126,-126,-126,-126,-126,-126,-126,-126,-126,-125,-125,-125,-125,-125,-125,-124,-124,-124,-124,-124,-123,-123,-123,-123,-123,-122,-122,-122,-122,-121,-121,-121,-121,-120,-120,-120,-120,-119,-119,-119,-119,-118,-118,-118,-117,-117,-117,-116,-116,-116,-115,-115,-115,-114,-114,-114,-113,-113,-112,-112,-112,-111,-111,-110,-110,-110,-109,-109,-108,-108,-108,-107,-107,-106,-106,-105,-105,-104,-104,-104,-103,-103,-102,-102,-101,-101,-100,-100,-99,-99,-98,-98,-97,-97,-96,-96,-95,-94,-94,-93,-93,-92,-92,-91,-91,-90,-89,-89,-88,-88,-87,-87,-86,-85,-85,-84,-84,-83,-82,-82,-81,-80,-80,-79,-79,-78,-77,-77,-76,-75,-75,-74,-73,-73,-72,-71,-71,-70,-69,-69,-68,-67,-67,-66,-65,-65,-64,-63,-63,-62,-61,-60,-60,-59,-58,-58,-57,-56,-55,-55,-54,-53,-53,-52,-51,-50,-50,-49,-48,-47,-47,-46,-45,-44,-44,-43,-42,-41,-41,-40,-39,-38,-38,-37,-36,-35,-34,-34,-33,-32,-31,-31,-30,-29,-28,-27,-27,-26,-25,-24,-23,-23,-22,-21,-20,-20,-19,-18,-17,-16,-16,-15,-14,-13,-12,-12,-11,-10,-9,-8,-8,-7,-6,-5,-4,-4,-3,-2,-1,0);
  --(2alt + cont)signal sine       : memory_type :=(15,19,24,28,33,38,42,46,51,55,59,63,67,71,75,79,82,86,89,92,95,98,101,103,106,108,110,112,113,115,116,118,119,119,120,120,121,121,121,121,120,120,119,118,117,116,114,113,111,109,107,105,103,101,98,96,93,91,88,85,82,79,76,73,70,67,64,60,57,54,51,48,45,41,38,35,32,29,26,24,21,18,16,13,11,8,6,4,2,0,-1,-3,-5,-6,-7,-8,-9,-10,-11,-12,-12,-13,-13,-13,-13,-13,-13,-13,-12,-12,-11,-10,-10,-9,-8,-7,-6,-4,-3,-2,0,1,2,4,5,7,8,10,12,13,15,16,18,19,20,22,23,24,26,27,28,29,30,30,31,32,32,33,33,33,33,33,33,33,32,32,31,30,29,28,27,26,25,23,21,20,18,16,14,12,9,7,4,2,-1,-4,-6,-9,-12,-15,-18,-21,-25,-28,-31,-34,-37,-40,-44,-47,-50,-53,-56,-59,-62,-65,-68,-71,-73,-76,-78,-81,-83,-85,-87,-89,-91,-93,-94,-96,-97,-98,-99,-100,-100,-101,-101,-101,-101,-100,-100,-99,-99,-98,-96,-95,-93,-92,-90,-88,-86,-83,-81,-78,-75,-72,-69,-66,-62,-59,-55,-51,-47,-43,-39,-35,-31,-26,-22,-18,-13,-8,-4,1,5,10);
  signal sine       : memory_type :=(1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0);
  ------------------------------------------
  -- Signals for user logic slave model s/w accessible register example
  ------------------------------------------
  signal slv_reg0                       : std_logic_vector(0 to C_SLV_DWIDTH-1);
  signal slv_reg1                       : std_logic_vector(0 to C_SLV_DWIDTH-1);
  signal slv_reg2                       : std_logic_vector(0 to C_SLV_DWIDTH-1);
  signal slv_reg_write_sel              : std_logic_vector(0 to 2);
  signal slv_reg_read_sel               : std_logic_vector(0 to 2);
  signal slv_ip2bus_data                : std_logic_vector(0 to C_SLV_DWIDTH-1);
  signal slv_read_ack                   : std_logic;
  signal slv_write_ack                  : std_logic;

begin
  --USER logic implementation added here
    --Carga de valores del seno para simular entrada
    process(Bus2IP_Clk) is
    begin
    if(rising_edge(Bus2IP_Clk)) then
      xn_re(7 downto 0) <= conv_std_logic_vector(sine(i), 8);
      xn_im(7 downto 0) <= conv_std_logic_vector(0, 8);
      i <= i + 1;
      if(i = 255) then
        i <= 0;
      end if;
    end if;
  end process;

  --
  MAIN : process(Bus2IP_Clk)
	 -- --variable cnt    : integer range  0 to 40;
    begin
      if Bus2IP_Clk'event and Bus2IP_Clk = '0' then
        p3 <= p1 + p2;
  --        case state is
  --          when inicio =>
  --            fwd_inv_we <= '1';
  --            if(fwd_inv_we = '1') then
  --              state <= carga;
  --            end if;
  --          when carga =>
  --              fwd_inv_we <='0';
  --              start <= '1';
  --              unload <= '1';
  --          when descarga =>
  --              fwd_inv_we <='0';
  --         end case; 
      end if;
  end process MAIN;

   MODULO : entity work.modulo
    port map
    (
   	  x_in        => p3,
   	  --y_in        => xk_im,
	    x_out       => x_out,
	    rdy         => rdy,
	    clk         => Bus2IP_Clk
     );
 
    MULT1 : entity work.multiplier1
    port map
    (
      clk        => Bus2IP_Clk,
      a          => xk_re,
      b          => xk_re,
      p          => p1
     );
 
    MULT2 : entity work.multiplier2
    port map
    (
      clk        => Bus2IP_Clk,
      a          => xk_im,
      b          => xk_im,
      p          => p2
     );
  
  XFFT_V6_0 : entity work.xfft_v6_0
    port map
    (
   	  fwd_inv_we  => fwd_inv_we,
   	  rfd         => rfd,
 	    start       => start,
	    fwd_inv     => fwd_inv,
	    dv          => dv,
	    unload      => unload,
	    done        => done,
	    clk         => Bus2IP_Clk,
	    busy        => busy,
   	  edone       => edone,
   	  xn_re       => xn_re,
   	  xk_im       => xk_im,
   	  xn_index    => xn_index,
   	  xk_re       => xk_re,
   	  xn_im       => xn_im,
   	  xk_index    => xk_index
     );
  ------------------------------------------
  -- Example code to read/write user logic slave model s/w accessible registers
  -- 
  -- Note:
  -- The example code presented here is to show you one way of reading/writing
  -- software accessible registers implemented in the user logic slave model.
  -- Each bit of the Bus2IP_WrCE/Bus2IP_RdCE signals is configured to correspond
  -- to one software accessible register by the top level template. For example,
  -- if you have four 32 bit software accessible registers in the user logic,
  -- you are basically operating on the following memory mapped registers:
  -- 
  --    Bus2IP_WrCE/Bus2IP_RdCE   Memory Mapped Register
  --                     "1000"   C_BASEADDR + 0x0
  --                     "0100"   C_BASEADDR + 0x4
  --                     "0010"   C_BASEADDR + 0x8
  --                     "0001"   C_BASEADDR + 0xC
  -- 
  ------------------------------------------
  slv_reg_write_sel <= Bus2IP_WrCE(0 to 2);
  slv_reg_read_sel  <= Bus2IP_RdCE(0 to 2);
  slv_write_ack     <= Bus2IP_WrCE(0) or Bus2IP_WrCE(1) or Bus2IP_WrCE(2);
  slv_read_ack      <= Bus2IP_RdCE(0) or Bus2IP_RdCE(1) or Bus2IP_RdCE(2);

  -- implement slave model software accessible register(s)
  SLAVE_REG_WRITE_PROC : process( Bus2IP_Clk ) is
  begin

    if Bus2IP_Clk'event and Bus2IP_Clk = '1' then
      if Bus2IP_Reset = '1' then
        slv_reg0 <= (others => '0');
        slv_reg1 <= (others => '0');
      else
        case slv_reg_write_sel is
          when "100" =>
            for byte_index in 0 to (C_SLV_DWIDTH/8)-1 loop
              if ( Bus2IP_BE(byte_index) = '1' ) then
                slv_reg0(byte_index*8 to byte_index*8+7) <= Bus2IP_Data(byte_index*8 to byte_index*8+7);
              end if;
            end loop;
          when "010" =>
            for byte_index in 0 to (C_SLV_DWIDTH/8)-1 loop
              if ( Bus2IP_BE(byte_index) = '1' ) then
                slv_reg1(byte_index*8 to byte_index*8+7) <= Bus2IP_Data(byte_index*8 to byte_index*8+7);
              end if;
            end loop;
          when others => null;
        end case;
      end if;
    end if;

  end process SLAVE_REG_WRITE_PROC;

  -- implement slave model software accessible register(s) read mux
  SLAVE_REG_READ_PROC : process( slv_reg_read_sel, slv_reg0, slv_reg1, slv_reg2 ) is
  begin

    case slv_reg_read_sel is
      when "100" => slv_ip2bus_data <= slv_reg0;
      when "010" => slv_ip2bus_data <= slv_reg1;
      when "001" => slv_ip2bus_data <= slv_reg2;
      when others => slv_ip2bus_data <= (others => '0');
    end case;

  end process SLAVE_REG_READ_PROC;

  ------------------------------------------
  -- Example code to drive IP to Bus signals
  ------------------------------------------
  IP2Bus_Data  <= slv_ip2bus_data when slv_read_ack = '1' else
                  (others => '0');

  IP2Bus_WrAck <= slv_write_ack;
  IP2Bus_RdAck <= slv_read_ack;
  IP2Bus_Error <= '0';

end IMP;
