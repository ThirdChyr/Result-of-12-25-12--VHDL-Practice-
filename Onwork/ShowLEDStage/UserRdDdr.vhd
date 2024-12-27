library IEEE;
use IEEE.std_logic_1164.ALL;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

Entity UserRdDdr Is
    Port (
        -- Clock and Reset
        RstB         : in  std_logic;                         -- Active low reset
        Clk          : in  std_logic;                         -- System clock (100 MHz)
        
        -- User Interface
        DipSwitch    : in  std_logic_vector(1 downto 0);     -- Base address selection
        
        -- HDMI Interface
        HDMIReq      : out std_logic;                        -- HDMI request
        HDMIBusy     : in  std_logic;                        -- HDMI busy status
        
        -- Memory Controller Interface
        MemInitDone  : in  std_logic;                        -- Memory initialization status
        MtDdrRdReq   : out std_logic;                        -- Memory read request
        MtDdrRdBusy  : in  std_logic;                        -- Memory read busy status
        MtDdrRdAddr  : out std_logic_vector(28 downto 7);    -- Memory read address
        
        -- Read FIFO Interface
        D2URdFfWrEn    : in  std_logic;                      -- Write enable from DDR
        D2URdFfWrData  : in  std_logic_vector(63 downto 0);  -- Write data from DDR
        D2URdFfWrCnt   : out std_logic_vector(15 downto 0);  -- Write count
        
        -- HDMI FIFO Interface
        URd2HFfWrEn    : out std_logic;                      -- Write enable to HDMI
        URd2HFfWrData  : out std_logic_vector(63 downto 0);  -- Write data to HDMI
        URd2HFfWrCnt   : in  std_logic_vector(15 downto 0)   -- Write count from HDMI
    );
End Entity UserRdDdr;

Architecture rtl Of UserRdDdr Is
    -- State Machine Definition
    type StateType is (
        st_stand,    
        st_reading,  
        st_toff      
    );
    
    -- Internal Signals
    signal rState         : StateType;
    signal rMtDdrRdAddr  : std_logic_vector(28 downto 7) := (others =>'0');
    signal rMtDdrRdReq   : std_logic;
    signal rMemInitDone  : std_logic_vector(1 downto 0);
    signal rHDMIReq      : std_logic;
    signal rBaseAddr     : std_logic_vector(28 downto 7) := (others =>'0');
    signal rD2URdFfWrCnt : std_logic_vector(15 downto 0);

Begin

    -- Output Assignments
    HDMIReq      <= rHDMIReq;
    MtDdrRdReq   <= rMtDdrRdReq;
    MtDdrRdAddr  <= rMtDdrRdAddr;
    D2URdFfWrCnt <= URd2HFfWrCnt;
    URd2HFfWrEn  <= D2URdFfWrEn;
    URd2HFfWrData <= D2URdFfWrData;

    -- State Machine Process
    u_rState: Process(Clk)
    Begin
        if rising_edge(Clk) then
            if RstB = '0' then
                rState <= st_stand;
            else
                case rState is
                    when st_stand =>
                        if rMemInitDone(1) = '1' and MtDdrRdBusy = '0' then
                            rState <= st_reading;
							rMtDdrRdReq <= '1';
                        end if;

                    when st_reading =>
                        if MtDdrRdBusy = '1' then
							rMtDdrRdReq <= '0';
                            rState <= st_toff;
                        end if;

                    when st_toff =>
                        if MtDdrRdBusy = '0' then
                            rState <= st_stand;
                        end if;

                    when others =>
                        rState <= st_stand;
                end case;
            end if;
        end if;
    End Process u_rState;

    -- Address Handling Process
    u_rMtDdrRdAddr: Process(Clk)
    Begin
        if rising_edge(Clk) then
            if RstB = '0' then
                rMtDdrRdAddr <= (others => '0');
            else
                case DipSwitch is
                    when "00" => rMtDdrRdAddr(28 downto 27) <= "00";
                    when "01" => rMtDdrRdAddr(28 downto 27) <= "01";
                    when "10" => rMtDdrRdAddr(28 downto 27) <= "10";
                    when "11" => rMtDdrRdAddr(28 downto 27) <= "11";
                    when others => rMtDdrRdAddr(28 downto 27) <= "00";
                end case;

                if rState = st_reading then
                    rMtDdrRdAddr(26 downto 7) <= rMtDdrRdAddr(26 downto 7) + 1;
                end if;

                if rMtDdrRdAddr(26 downto 7) = 24576 then
                    rMtDdrRdAddr(26 downto 7) <= (others => '0');
                end if;
            end if;
        end if;
    End Process u_rMtDdrRdAddr;

    -- Memory Initialization Synchronizer
    p_mem_init_sync: Process(Clk)
    Begin
        if rising_edge(Clk) then
            if RstB = '0' then
                rMemInitDone <= "00";
            else
                rMemInitDone <= rMemInitDone(0) & MemInitDone;
            end if;
        end if;
    End Process p_mem_init_sync;

    -- HDMI Request Control
    p_hdmi_req_ctrl: Process(Clk)
    Begin
        if rising_edge(Clk) then
            if RstB = '0' then
                rHDMIReq <= '0';
            else
                if HDMIBusy = '0' and rMemInitDone(1) = '1' then
                    rHDMIReq <= '1';
                elsif HDMIBusy = '1' then
                    rHDMIReq <= '0';
                end if;
            end if;
        end if;
    End Process p_hdmi_req_ctrl;

End Architecture rtl;