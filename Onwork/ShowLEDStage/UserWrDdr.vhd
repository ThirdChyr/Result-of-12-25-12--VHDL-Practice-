Library IEEE;
use IEEE.std_logic_1164.ALL;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

Entity UserWrDdr Is
	Port
	(
		RstB			: in	std_logic;							-- use push button Key0 (active low)
		Clk				: in	std_logic;							-- clock input 100 MHz
		DipSwitch    : in  std_logic_vector(1 downto 0);
		-- WrCtrl I/F
		MemInitDone		: in	std_logic;
		MtDdrWrReq		: out	std_logic;
		MtDdrWrBusy		: in	std_logic;
		MtDdrWrAddr		: out	std_logic_vector( 28 downto 7 );
		
		-- T2UWrFf I/F
		T2UWrFfRdEn		: out	std_logic;
		T2UWrFfRdData	: in	std_logic_vector( 63 downto 0 );
		T2UWrFfRdCnt	: in	std_logic_vector( 15 downto 0 );
		
		-- UWr2DFf I/F
		UWr2DFfRdEn		: in	std_logic;
		UWr2DFfRdData	: out	std_logic_vector( 63 downto 0 );
		UWr2DFfRdCnt	: out	std_logic_vector( 15 downto 0 )
	);
End Entity UserWrDdr;

Architecture rtl Of UserWrDdr Is

----------------------------------------------------------------------------------
-- Component declaration
----------------------------------------------------------------------------------
	type StateType is (
        st_stand,    
        st_reading,  
        st_toff      
    );
    
    -- Internal Signals
    signal rState         : StateType;
	
----------------------------------------------------------------------------------
-- Signal declaration
----------------------------------------------------------------------------------
	
	signal	rMemInitDone	: std_logic_vector( 1 downto 0 );
	signal  rMtDdrWrReq		: std_logic;
	signal  rMtDdrWrAddr		: std_logic_vector( 28 downto 7 );
Begin
----------------------------------------------------------------------------------
-- Output assignment
----------------------------------------------------------------------------------
	UWr2DFfRdData <= T2UWrFfRdData;
	UWr2DFfRdCnt <= T2UWrFfRdCnt;
	T2UWrFfRdEn <= UWr2DFfRdEn;
	MtDdrWrAddr	<= rMtDdrWrAddr;
	MtDdrWrReq <= rMtDdrWrReq;
----------------------------------------------------------------------------------
-- DFF 
----------------------------------------------------------------------------------
	 u_rState: Process(Clk)
    Begin
        if rising_edge(Clk) then
            if RstB = '0' then
                rState <= st_stand;
            else
                case rState is
                    when st_stand =>
                        if rMemInitDone(1) = '1' and MtDdrWrBusy = '0' then
							rMtDdrWrReq <= '1';
                            rState <= st_reading;
                        end if;

                    when st_reading =>
                        if MtDdrWrBusy = '1' then
							rMtDdrWrReq <= '0';
                            rState <= st_toff;
                        end if;

                    when st_toff =>
                        if MtDdrWrBusy = '0' then
                            rState <= st_stand;
                        end if;

                    when others =>
                        rState <= st_stand;
                end case;
            end if;
        end if;
    End Process u_rState;

    -- Address Handling Process
    U_rMtDdrWrAddr: Process(Clk)
    Begin
        if rising_edge(Clk) then
            if RstB = '0' then
                rMtDdrWrAddr <= (others => '0');
            else
				if (rState = st_stand) then
					 rMtDdrWrAddr(28 downto 27) <= DipSwitch;
				end if;
                if rState = st_reading then
                    rMtDdrWrAddr(26 downto 7) <= rMtDdrWrAddr(26 downto 7) + 1;
                end if;
                if rMtDdrWrAddr(26 downto 7) = 24576 then
                    rMtDdrWrAddr(26 downto 7) <= (others => '0');
                end if;
            end if;
        end if;
    End Process U_rMtDdrWrAddr;

	u_rMemInitDone : Process (Clk) Is
	Begin
		if ( rising_edge(Clk) ) then
			if ( RstB='0' ) then
				rMemInitDone	<= "00";
			else
				-- Use rMemInitDone(1) in your design
				rMemInitDone	<= rMemInitDone(0) & MemInitDone;
			end if;
		end if;
	End Process u_rMemInitDone;
	
End Architecture rtl;