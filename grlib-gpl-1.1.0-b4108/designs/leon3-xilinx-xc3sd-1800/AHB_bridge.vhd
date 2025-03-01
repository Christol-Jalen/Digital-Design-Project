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

ENTITY AHB_bridge IS
  PORT(
    -- Clock and Reset -----------------
    clkm : IN std_logic;
    rstn : IN std_logic;
    -- AHB Master records --------------
    ahbmi : IN ahb_mst_in_type;
    ahbmo : OUT ahb_mst_out_type;
    -- ARM Cortex-M0 AHB-Lite signals -- 
    HADDR : IN std_logic_vector (31 downto 0); -- AHB transaction address
    HSIZE : IN std_logic_vector (2 downto 0); -- AHB size: byte, half-word or word
    HTRANS : IN std_logic_vector (1 downto 0); -- AHB transfer: non-sequential only
    HWDATA : IN std_logic_vector (31 downto 0); -- AHB write-data
    HWRITE : IN std_logic; -- AHB write control
    HRDATA : OUT std_logic_vector (31 downto 0); -- AHB read-data
    HREADY : OUT std_logic -- AHB stall signal
  );
END;

ARCHITECTURE structural OF AHB_bridge IS
  --declare a component for state_machine
  
  COMPONENT state_machine IS
    PORT(
      HADDR : IN std_logic_vector (31 downto 0);
      HSIZE : IN std_logic_vector (2 downto 0);
      HTRANS : IN std_logic_vector (1 downto 0);
      HWDATA : IN std_logic_vector (31 downto 0);
      HWRITE : IN std_logic;
      HREADY : OUT std_logic;
      dmai : OUT ahb_dma_in_type;
      dmao : IN ahb_dma_out_type; 
      clkm : IN  std_logic;
      rstn : IN std_logic
    );
  END COMPONENT;  
  
  
  
  --declare a component for ahbmstclkm
  COMPONENT ahbmst IS
    PORT(
      ahbo : OUT ahb_mst_out_type;
      ahbi : IN ahb_mst_in_type;
      dmai : IN ahb_dma_in_type;
      dmao : OUT ahb_dma_out_type;
      clk : IN  std_logic;
      rst : IN std_logic
    );
  END COMPONENT; 
  
  
  
  --declare a component for data_swapper
  COMPONENT data_swapper IS
    PORT(
      dmao : IN ahb_dma_out_type;
      HRDATA : OUT std_logic_vector (31 downto 0)
    );
  END COMPONENT; 


  SIGNAL sig_dmai : ahb_dma_in_type;
  SIGNAL sig_dmao : ahb_dma_out_type;
  


BEGIN
-----------------------------------------------------  
  
  A1: state_machine
  port map(
    HADDR => HADDR,
    HSIZE => HSIZE,
    HTRANS => HTRANS,
    HWDATA => HWDATA,
    HWRITE => HWRITE,
    HREADY => HREADY,
    
    dmai => sig_dmai,
    dmao => sig_dmao,
    
    clkm => clkm,
    rstn => rstn
  ); 
--instantiate state_machine component and make the connections

  A2: ahbmst
  port map(
    ahbo => ahbmo,
    ahbi => ahbmi,
    
    dmai => sig_dmai,
    dmao => sig_dmao,
    
    clk => clkm,
    rst => rstn
  );
    
--instantiate the ahbmst component and make the connections 

  A3: data_swapper
  port map(
    dmao => sig_dmao,
    HRDATA => HRDATA
  );

--instantiate the data_swapper component and make the connections

END structural;
