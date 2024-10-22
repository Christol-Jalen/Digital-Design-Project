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
  
BEGIN 
  -----------------------------------------------------
  Change: PROCESS(curState, HTRANS, dmao)
  BEGIN
    CASE curState IS
      WHEN idle =>
        hready <= '1';
        dmai.start <= '0';
        IF HTRANS = "10" THEN
          dmai.start <= '1';
          nextState <= instr_fetch;
        ELSE
          nextState <= curState;
        END IF;
        
      WHEN instr_fetch =>
        hready <= '0';
        dmai.start <= '0';
        IF dmao.ready = '1' THEN
          hready <= '1';
          nextState <= idle;
        ELSE
          nextState <= curState;
        END IF;
    END CASE;
  END PROCESS;
  -----------------------------------------------------
  data_process: PROCESS (HADDR, HSIZE, HWDATA, HWRITE)
  BEGIN
    dmai.address <= HADDR;
    dmai.size <= HSIZE;
    dmai.wdata <= HWDATA;
    dmai.write <= HWRITE;
    dmai.burst <= '0';
    dmai.busy <= '0';
    dmai.irq <= '0';
  END PROCESS;
-----------------------------------------------------
  seq_state: PROCESS (clkm, rstn)
  BEGIN
    IF rstn = '1' THEN
      curState <= idle;
    ELSIF rising_edge(clkm) THEN
      curState <= nextState;
    END IF;
  END PROCESS;
-----------------------------------------------------
END structure;