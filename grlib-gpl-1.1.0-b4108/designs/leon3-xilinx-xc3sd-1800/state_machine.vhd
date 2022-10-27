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
      rstn : IN std_logic;
    );
  );
END;



ARCHITECTURE structure of state_machine IS
  -- State declaration
  TYPE state_type IS (idle, instr_fetch);  	
  SIGNAL curState, nextState: state_type;
BEGIN
-----------------------------------------------------
  NextState: PROCESS(curState, htrans, dmao.ready)
  BEGIN
    CASE curState IS
      WHEN idle =>
        IF htrans ='10' THEN 
          nextState <= instr_fetch;
        ELSE
          nextState <= curState;
        END IF;
        
      WHEN instr_fetch =>
        IF dmao.ready ='1' THEN
          nextState <= idle;
        ELSE
          nextState <= curState;
        END IF;
    END CASE;
  END PROCESS; -- NextState
  -----------------------------------------------------
  States: PROCESS (curState)
  BEGIN
    IF curState = idle THEN
      hready <= '1';
      dmai.start <= '0';
      
    ELSIF curState = instr_fetch THEN
      hready <= '0';
      dmai.start <= '0';
    END IF;
  END PROCESS;
END structure;