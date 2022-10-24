library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library grlib;
use grlib.amba.all;
use grlib.stdlib.all;
use grlib.devices.all;
library gaisler;
use gaisler.misc.all;
library UNISIM;
use UNISIM.VComponents.all;

ENTITY cm0_wrapper IS
  PORT(
    -- Clock and Reset -----------------
    clkm : IN std_logic;
    rstn : IN std_logic;
    -- AHB Master records --------------
    ahbmi : IN ahb_mst_in_type;
    ahbmo : OUT ahb_mst_out_type;
