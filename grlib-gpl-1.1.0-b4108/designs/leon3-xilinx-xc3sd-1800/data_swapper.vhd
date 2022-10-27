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
    HRDATA : OUT std_logic_vector (31 downto 0)
  );
END;


ARCHITECTURE structure of data_swapper IS
BEGIN
-----------------------------------------------------
  swap_data: PROCESS(dmao)
  BEGIN
    HRDATA(31 downto 24) <= dmao.rdata(7 downto 0);
    HRDATA(23 downto 16) <= dmao.rdata(15 downto 8);
    HRDATA(15 downto 8) <= dmao.rdata(23 downto 16);
    HRDATA(7 downto 0) <= dmao.rdata(31 downto 24);
  END PROCESS;
-----------------------------------------------------
END structure;