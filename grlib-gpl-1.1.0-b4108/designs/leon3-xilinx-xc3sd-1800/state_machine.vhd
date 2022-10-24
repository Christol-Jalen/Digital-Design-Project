





ARCHITECTURE ............
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