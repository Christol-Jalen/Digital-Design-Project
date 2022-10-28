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

ENTITY state_machine IS
    PORT(
      HADDR : IN std_logic_vector (31 downto 0);
      HSIZE : IN std_logic_vector (2 downto 0);
      HTRANS : IN std_logic_vector (1 downto 0);
      HWDATA : IN std_logic_vector (31 downto 0);
      HWRITE : IN std_logic;
      HREADY : OUT std_logic;
      dmai : OUT ahb_dma_in_type;
      dmao : IN ahb_dma_out_type; 
      clkm : IN std_logic;
      rstn : IN std_logic
    );
END;



ARCHITECTURE structure of state_machine IS
  -- State declaration
  TYPE state_type IS (idle, instr_fetch);  	
  SIGNAL curState, nextState: state_type;
  SIGNAL sig_HADDR, sig_HWDATA: std_logic_vector (31 downto 0);
  SIGNAL sig_HSIZE: std_logic_vector (2 downto 0);
  SIGNAL sig_HWRITE: std_logic;
  SIGNAL sig_HTRANS : std_logic_vector (1 downto 0);
  SIGNAL sig_dmao : ahb_dma_out_type;
  SIGNAL sig_dmai : ahb_dma_in_type;
  SIGNAl sig_clkm : std_logic;
  SIGNAL sig_rstn : std_logic;
  
BEGIN 
  A0: entity state_machine IS
  port map(
    HADDR => sig_HADDR,
    HSIZE => sig_HSIZE,
    HTRANS => sig_HTRANS,
    HWDATA => sig_HWDATA,
    HWRITE => sig_HWRITE,
    HREADY => sig_HREADY,
    dmai => sig_dmai,
    dmao => sig_dmao
  );
-----------------------------------------------------
  Change: PROCESS(curState, sig_HTRANS, sig_dmao)
  BEGIN
    CASE curState IS
      WHEN idle =>
        IF sig_HTRANS = '10' THEN 
          nextState <= instr_fetch;
        ELSE
          nextState <= curState;
        END IF;
        
      WHEN instr_fetch =>
        IF sig_dmao.ready ='1' THEN
          nextState <= idle;
        ELSE
          nextState <= curState;
        END IF;
    END CASE;
  END PROCESS; -- NextState
  -----------------------------------------------------
  States: PROCESS (curState, sig_HADDR, sig_HSIZE, sig_HWDATA, sig_HWRITE, sig_dmai)
  BEGIN
    IF curState = idle THEN
      hready <= '1';
      sig_dmai.start <= '0';
      
    ELSIF curState = instr_fetch THEN
      hready <= '0';
      sig_dmai.start <= '0';
      sig_dmai.address <= sig_HADDR;
      sig_dmai.size <= sig_HSIZE;
      sig_dmai.wdata <= sig_HWDATA;
      sig_dmai.write <= sig_HWRITE;
    END IF;
  END PROCESS;
-----------------------------------------------------

-----------------------------------------------------
END structure;