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
    
    --- need a led signal ---
    cm0_led : OUT std_logic
);
END;


ARCHITECTURE structure of cm0_wrapper IS

  --declare a component for CORTEXM0DS
  COMPONENT CORTEXM0DS 
	  PORT(
    -- CLOCK AND RESETS ------------------
    --input  wire        HCLK,              -- Clock
    --input  wire        HRESETn,           -- Asynchronous reset
    HCLK : IN std_logic;              -- Clock
    HRESETn : IN std_logic;           -- Asynchronous reset

    -- AHB-LITE MASTER PORT --------------
    --output wire [31:0] HADDR,             -- AHB transaction address
    --output wire [ 2:0] HBURST,            -- AHB burst: tied to single
    --output wire        HMASTLOCK,         -- AHB locked transfer (always zero)
    --output wire [ 3:0] HPROT,             -- AHB protection: priv; data or inst
    --output wire [ 2:0] HSIZE,             -- AHB size: byte, half-word or word
    --output wire [ 1:0] HTRANS,            -- AHB transfer: non-sequential only
    --output wire [31:0] HWDATA,            -- AHB write-data
    --output wire        HWRITE,            -- AHB write control
    --input  wire [31:0] HRDATA,            -- AHB read-data
    --input  wire        HREADY,            -- AHB stall signal
    --input  wire        HRESP,             -- AHB error response
    HADDR : OUT std_logic_vector (31 downto 0);             -- AHB transaction address
    HBURST : OUT std_logic_vector (2 downto 0);            -- AHB burst: tied to single
    HMASTLOCK : OUT std_logic;         -- AHB locked transfer (always zero)
    HPROT : OUT std_logic_vector (3 downto 0);              -- AHB protection: priv; data or inst
    HSIZE : OUT std_logic_vector (2 downto 0);             -- AHB size: byte, half-word or word
    HTRANS : OUT std_logic_vector (1 downto 0);            -- AHB transfer: non-sequential only
    HWDATA : OUT std_logic_vector (31 downto 0);             -- AHB write-data
    HWRITE : OUT std_logic;            -- AHB write control
    HRDATA : IN std_logic_vector (31 downto 0);            -- AHB read-data
    HREADY : IN std_logic;            -- AHB stall signal
    
    HRESP : IN std_logic;             -- AHB error response

    -- MISCELLANEOUS ---------------------
    --input  wire        NMI,               -- Non-maskable interrupt input
    --input  wire [15:0] IRQ,               -- Interrupt request inputs
    --output wire        TXEV,              -- Event output (SEV executed)
    --input  wire        RXEV,              -- Event input
    --output wire        LOCKUP,            -- Core is locked-up
    --output wire        SYSRESETREQ,       -- System reset request
    NMI : IN std_logic;               -- Non-maskable interrupt input
    IRQ : IN std_logic_vector (15 downto 0);               -- Interrupt request inputs
    --TXEV : OUT std_logic;              -- Event output (SEV executed)
    RXEV : IN std_logic             -- Event input
    --LOCKUP : OUT std_logic;            -- Core is locked-up
    --SYSRESETREQ : OUT std_logic;       -- System reset request

    -- POWER MANAGEMENT ------------------
    --output wire        SLEEPING           -- Core and NVIC sleeping
    --SLEEPING : OUT std_logic          -- Core and NVIC sleeping
  );
  END COMPONENT;

  SIGNAL dummy1 : std_logic;
  SIGNAL dummy2 : std_logic;
  SIGNAL dummy3 : std_logic;
  SIGNAL dummy4 : STD_LOGIC_VECTOR (15 downto 0);

  signal dummy : STD_LOGIC_VECTOR (2 downto 0);
  signal HRData : std_logic_vector (31 downto 0);
  signal HWData : std_logic_vector (31 downto 0);
  signal HADDR : std_logic_vector (31 downto 0);
  signal HBurst : std_logic_vector (2 downto 0);
  signal HProt : std_logic_vector (3 downto 0);
  signal HSize : std_logic_vector (2 downto 0);
  signal HTrans : std_logic_vector (1 downto 0);
  signal HWrite : std_logic;
  signal HREADY : std_logic;
  
  
  signal none : std_logic_vector (1 downto 0);
  signal led_value:std_logic;
  signal reset_rom: std_logic;
  signal SyncResetPulse : std_logic;


  --declare a component for AHB bridge
  COMPONENT AHB_bridge IS
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
  END COMPONENT;
  
  
  --declare a component for DetectorBus
  component DetectorBus is
    Port ( Clock : in  STD_LOGIC;
           DataBus : in  STD_LOGIC_VECTOR (31 downto 0);
           Detector : out  STD_LOGIC);
  end component;
  
  
BEGIN
  dummy1 <= '0';
  dummy2 <= '0';
  dummy3 <= '0';
  dummy4 <= "0000000000000000";
  
  cm0_led <= led_value;
  
  --instantiate CORTEXM0 component and make the connections
  A0: DetectorBus 
    Port map ( Clock => clkm,
           DataBus => HRData,
           Detector => led_value
  );
  
  
  --instantiate CORTEXM0 component and make the connections
  A1: CORTEXM0DS
  PORT MAP(
    HADDR => HADDR,
    HSIZE => HSIZE,
    HTRANS => HTRANS,
    HWDATA => HWDATA,
    HWRITE => HWRITE,
    HRDATA => HRDATA,
    HREADY => HREADY,
    
    HCLK => clkm,
    HRESETn => rstn,
    
    HRESP => dummy1,
    NMI => dummy2,
    IRQ => dummy4,
    RXEV => dummy3
  );


  --instantiate AHB_Bridge component and make the connections
  A2: AHB_bridge
  PORT MAP(
    HADDR => HADDR,
    HSIZE => HSIZE,
    HTRANS => HTRANS,
    HWDATA => HWDATA,
    HWRITE => HWRITE,
    HRDATA => HRDATA,
    HREADY => HREADY,
    
    clkm => clkm,
    rstn => rstn,
    
    ahbmi => ahbmi,
    ahbmo => ahbmo
  );

END structure;