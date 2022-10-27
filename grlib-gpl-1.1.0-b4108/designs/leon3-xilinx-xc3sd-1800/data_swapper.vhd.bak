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


Entity data_swapper IS
  PORT(
      dmao : IN ahb_dma_out_type;
      HRDATA : OUT std_logic_vector (31 downto 0); 
    );
END;