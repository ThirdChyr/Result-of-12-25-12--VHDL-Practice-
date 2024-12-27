library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

Entity TxSerial Is
Port(
	RstB		: in	std_logic;
	Clk			: in	std_logic;
	
	TxFfEmpty	: in	std_logic;
	TxFfRdData	: in	std_logic_vector( 7 downto 0 );
	TxFfRdEn	: out	std_logic;
	
	SerDataOut	: out	std_logic
);
End Entity TxSerial;

Architecture rtl Of TxSerial Is

	Constant cbuadCnt : integer := 434;
----------------------------------------------------------------------------------
-- Constant declaration
----------------------------------------------------------------------------------
	signal rTxFfRdEn	:	std_logic_vector(1 downto 0);
	signal rSerData		:	std_logic_vector(9 downto 0);
	signal rBuadCnt		:	std_logic_vector( 9 downto 0);
	signal rBuadEnd		:	std_logic;
	signal rDataCnt		:	std_logic_vector(3 downto 0) := "0000";
----------------------------------------------------------------------------------
-- Signal declaration
----------------------------------------------------------------------------------
	type SerStateType Is
					(
						stIdle	,
						stRdReq	,
						stWtData,
						stWtEnd
					);
	
	signal rState 		: 	SerStateType;
Begin
		TxFfRdEn <= rTxFfRdEn(0);
		SerDataOut <= rSerData(0);
----------------------------------------------------------------------------------
-- Output assignment
----------------------------------------------------------------------------------
	----------------------- VHDL CODE 1 -------------------------------------------

	u_rBuadCnt	:	Process(Clk) Is
	Begin
		if(rising_edge(Clk)) then
			if(RstB = '0') then
				rBuadCnt <= conv_std_logic_vector(cbuadCnt,10);
			else
				if(rBuadCnt = 1) then
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
				if(rBuadCnt = 1) then
					rBuadEnd <= '1';
				else
					rBuadEnd <= '0';
				end if;
			end if;
		end if;
	end process u_rBuadEnd;
	----------------------- VHDL CODE 2 ------------------------------------------
	
	u_rSerData	:	Process(Clk) is 
	Begin
		if(rising_edge(clk)) then
			if(RstB = '0') then
				rSerData	<=	(others => '1');
			else
				if(rTxFfRdEn(1) = '1') then
					rSerData(9) <= '1';
					rSerData(8 downto 1) <= TxFfRdData;
					rSerData(0) <= '0';
				elsif(rBuadEnd = '1' ) then
					rSerData <= '1' & rSerData(9 downto 1);
				else
					rSerData	<= rSerData;
				end if;
			end if;
		end if;
	end process u_rSerData;
	----------------------- VHDL CODE 3-------------------------------------------
	u_rstate	:	process(clk) Is
	Begin
		if(rising_edge(clk)) then
			if(RstB = '0') then
				rDataCnt <= (others => '0');
				rState <=stIdle;
			else
				case (rState) is
					when stIdle		=>	
						rState <= stRdReq;
						if(TxFfEmpty = '0') then
							rState <= stRdReq;
						else
							rstate <= stIdle;
						end if;
					when stRdReq 	=>
						rState <= stWtData;
					when stWtData	=>
						if(rTxFfRdEn(1) = '1' or rTxFfRdEn(0) = '1')then
							rState <= stWtEnd;
						end if;
					when stWtEnd	=>
						if(rBuadEnd = '1') then
							rDataCnt <= rDataCnt +1;
						end if;
						if(rDataCnt = 10 ) then
							rDataCnt <= (others => '0');
							rState <= stIdle;
						end if;
				end case;
			end if;
		end if;
	end Process u_rstate;
	
	u_rTxFfRdEn	:	Process(clk) Is
	Begin
		if(rising_edge(clk)) then
			if(RstB ='0') then
				rTxFfRdEn <= "00";
			else
				rTxFfRdEn(1)	<= rTxFfRdEn(0);
				if(rState = stRdReq) then
					rTxFfRdEn(0) <= '1';
				else
					rTxFfRdEn(0) <= '0';
				end if;
			end if;
		end if;
	end process u_rTxFfRdEn;
----------------------------------------------------------------------------------
-- DFF 
----------------------------------------------------------------------------------

	
End Architecture rtl;