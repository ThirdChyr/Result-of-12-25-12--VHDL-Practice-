library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;
Entity RxSerial Is
Port(
	RstB		: in	std_logic;
	Clk			: in	std_logic;
	
	SerDataIn	: in	std_logic;
	
	RxFfFull	: in	std_logic;
	RxFfWrData	: out	std_logic_vector( 7 downto 0 );
	RxFfWrEn	: out	std_logic
);
End Entity RxSerial;

Architecture rtl Of RxSerial Is
	
	Constant cbuadCnt : integer := 868;
	Constant ccbuadCnt : integer := 433;
----------------------------------------------------------------------------------
-- Constant declaration
----------------------------------------------------------------------------------
	
----------------------------------------------------------------------------------
-- Signal declaration
----------------------------------------------------------------------------------
	type SerStateType Is
					(
					stStand,
					stCnt,
					stRead,
					stblank
					);
	signal rState : SerStateType;
	signal rSerDataIn	: std_logic;
	signal toggle : std_logic := '0';

	signal rDataCnt		:	std_logic_vector(3 downto 0) := "0000";
	signal rSerData		:	std_logic_vector(9 downto 0) ;
	signal rrSerData		:	std_logic_vector(9 downto 0) ;
	signal rBuadCnt		:	std_logic_vector(9 downto 0);
	signal rrBuadCnt		:	std_logic_vector(9 downto 0);
	
	signal rRxFfData 	:	std_logic_vector(7 downto 0) := "00000000";
	signal rBuadEnd		:	std_logic;
	Signal rRxFfWrEn	: 	std_logic; 
	Signal rRxFfFull	:	std_logic;
	Signal rrRxFfFull	:	std_logic;
	
Begin

----------------------------------------------------------------------------------
-- Output assignment
----------------------------------------------------------------------------------
	RxFfWrEn <= rRxFfWrEn;
	rrRxFfFull <= rRxFfFull;
----------------------------------------------------------------------------------
--------------- Signal communicate to UART Gennarator-----------------------------
u_rBuadCnt	:	Process(Clk) Is
	Begin
		if(rising_edge(Clk)) then
			if(RstB = '0') then
				rBuadCnt <= conv_std_logic_vector(cbuadCnt,10);
			else
				if(rBuadCnt = 1) then
					rBuadCnt <= conv_std_logic_vector(cbuadCnt,10);
				elsif(rState = stStand and rSerDataIn = '0') then
					 rBuadCnt <= conv_std_logic_vector(cbuadCnt,10);
				else
					rBuadCnt <= rBuadCnt - 1;
				end if;
			end if;
		end if;
	end process u_rBuadCnt;

u_rBuadEnd	:	process(clk) Is
	Begin
		if(rising_edge(clk)) then
			if(RstB = '0')  then
				rBuadEnd <= '0';
			else
				 if( rBuadCnt = 433) then
					rBuadEnd <= '1';
				else
					rBuadEnd <= '0';
				end if;
			end if;
		end if;
	end process u_rBuadEnd;
-----------------------------------End-------------------------------------------

---Reload UART TRANSACTION to LOADER----------------------------------
	 u_rRxFfWrEn : Process(clk) Is
	 Begin
		 if(rising_edge(clk)) then
			 if(RstB = '0') then
				 rSerData <= (others => '0');
			 else
				 if(rBuadEnd = '1') then
						if(rState = stCnt) then
							rSerData(9) <= rSerDataIn;
							rSerData(8) <= rSerData(9);
							rSerData(7) <= rSerData(8);
							rSerData(6) <= rSerData(7);
							rSerData(5) <= rSerData(6);
							rSerData(4) <= rSerData(5);
							rSerData(3) <= rSerData(4);
							rSerData(2) <= rSerData(3);
							rSerData(1) <= rSerData(2);
							rSerData(0) <= rSerData(1);
						elsif (rstate = stStand) then
							rSerData <= (others => '0');
						end if;
				 end if;
			 end if;
		 end if;
		 end process u_rRxFfWrEn;

----------------------------------------------------------------------------------
----------------------------------------------------------------------------------
-- DFF 
----------------------------------------------------------------------------------
	r_state : Process(Clk) Is
	Begin
		if(rising_edge(clk)) then
			if (RstB = '0') then
				rState <= stStand;
			else
				--if(rBuadEnd = '1') then
					if(rState = stStand) then
						if(rState = stStand and rSerDataIn = '0') then
							rDataCnt <= (others => '0');
						end if;
						if(rSerDataIn = '0' ) then
							rRxFfFull <= '1';
							rRxFfWrEn <= '0';
							rState <= stcnt;
						else
							rState <= stStand;
						end if;
					elsif(rState = stCnt) then
						if(rBuadEnd = '1') then
							rDataCnt <= rDataCnt + 1;
						else
							rDataCnt <= rDataCnt;
						end if;
						if(rDataCnt = 10 ) then
							rRxFfFull <= '0';
							rDataCnt <= (others => '0');
							if(rSerData(9) = '1') then
								rRxFfWrEn <= '1';
							else
								rRxFfWrEn <= '0';
							end if;
								rState <= stRead;
						end if;
					elsif(rState = stRead) then
						if(rRxFfFull = '0') then
							rState<= stStand;
							rRxFfFull <= '1';
							rRxFfWrEn<= '0';
						end if;
					end if;
				end if;
			end if;
		--end if;
	end process r_state;
	
	
	u_rSerDataIn : Process (Clk) Is
	Begin
		if ( rising_edge(Clk) ) then
			rSerDataIn		<= SerDataIn;
		end if;
	End Process u_rSerDataIn; 
	
	u_RxFfWrData : process(Clk) Is
	Begin
		if(rRxFfWrEn = '1' and rState = stRead) then
			RxFfWrData <= rSerData(8 downto 1);
		end if;
	end process u_RxFfWrData;
	
End Architecture rtl;