-------------------------------------------------------------------[26-06-2013]
-- ultimate
-------------------------------------------------------------------------------
-- Engineer: 	MVV, shurik-ua
-- Description: 
--
-- Versions:

-- V1.3	08-05-2013:
--		Первый релиз
-- V1.2	06-05-2013:
--		Добавлен второй процессор T80CPU
--		Изменена карта памяти
-- V1.1	06-06-2013:
--		Initial release.
--
-------------------------------------------------------------------------------

library IEEE; 
use IEEE.std_logic_1164.all; 
use IEEE.std_logic_unsigned.all;
use IEEE.numeric_std.ALL;

entity ultimate is
port (
	-- Clock (50MHz)
	CLK_50MHZ	: in std_logic;
	-- SRAM (CY7C1049DV33-10)
	SRAM_A		: out std_logic_vector(19 downto 0);
	SRAM_D		: inout std_logic_vector(7 downto 0);
	SRAM_WE_n	: out std_logic;
	-- SDRAM (MT48LC32M8A2-75)
	DRAM_A		: out std_logic_vector(12 downto 0);
	DRAM_D		: inout std_logic_vector(7 downto 0);
	DRAM_BA		: out std_logic_vector(1 downto 0);
	DRAM_CLK	: out std_logic;
	DRAM_WE_n	: out std_logic;
	DRAM_CAS_n	: out std_logic;
	DRAM_RAS_n	: out std_logic;
	-- RTC (PCF8583)
	RTC_INT_n	: in std_logic;
	RTC_SCL		: inout std_logic;
	RTC_SDA		: inout std_logic;
	-- FLASH (M25P40)
	DATA0		: in std_logic;
	NCSO		: out std_logic;
	DCLK		: out std_logic;
	ASDO		: out std_logic;
	-- Audio Codec (VS1053B)
	VS_XCS		: out std_logic;
	VS_XDCS		: out std_logic;
	VS_DREQ		: in std_logic;
	-- VGA
	VGA_R		: out std_logic_vector(2 downto 0);
	VGA_G		: out std_logic_vector(2 downto 0);
	VGA_B		: out std_logic_vector(2 downto 0);
	VGA_VSYNC	: out std_logic;
	VGA_HSYNC	: out std_logic;
	-- External I/O
	RST_n		: in std_logic;
	GPI			: in std_logic;
	GPIO		: inout std_logic;
	-- PS/2 Keyboard
	PS2_KBCLK	: inout std_logic;
	PS2_KBDAT	: inout std_logic;		
	-- PS/2 Mouse
	PS2_MSCLK	: inout std_logic;
	PS2_MSDAT	: inout std_logic;		
	-- USB-UART (FT232RL)
	TXD			: in std_logic;
	RXD			: out std_logic;
	CBUS4		: in std_logic;
	-- SD/MMC Card
	SD_CLK		: out std_logic;
	SD_DAT0		: in std_logic;
	SD_DAT1		: in std_logic;
	SD_DAT2		: in std_logic;
	SD_DAT3		: out std_logic;
	SD_CMD		: out std_logic;
	SD_PROT		: in std_logic);
			
end ultimate;


architecture ultimate_arch of ultimate is

-- Глобальные сигналы
signal clk_vga			: std_logic;
signal reset			: std_logic;

-- X80CPU
signal x80cpu_clk		: std_logic;
signal x80cpu_addr		: std_logic_vector(15 downto 0);
signal x80cpu_do		: std_logic_vector(7 downto 0);
signal x80cpu_di		: std_logic_vector(7 downto 0);
signal x80cpu_mreq		: std_logic;
signal x80cpu_iorq		: std_logic;
signal x80cpu_wr		: std_logic;

-- T80CPU
signal t80cpu_clk		: std_logic;
signal t80cpu_addr		: std_logic_vector(15 downto 0);
signal t80cpu_do		: std_logic_vector(7 downto 0);
signal t80cpu_di		: std_logic_vector(7 downto 0);
signal t80cpu_mreq_n	: std_logic;
signal t80cpu_iorq_n	: std_logic;
signal t80cpu_rd_n		: std_logic;
signal t80cpu_wr_n		: std_logic;

-- VGA
signal txt_rgb			: std_logic_vector(5 downto 0);
signal txt_font_di		: std_logic_vector(7 downto 0);
signal txt_font_addr	: std_logic_vector(11 downto 0);
signal txt_char_di		: std_logic_vector(15 downto 0);
signal txt0_char_di		: std_logic_vector(15 downto 0);
signal txt1_char_di		: std_logic_vector(15 downto 0);
signal txt_char_addr	: std_logic_vector(11 downto 0);
signal txt0_char_addr	: std_logic_vector(13 downto 0);
signal txt1_char_addr	: std_logic_vector(13 downto 0);
signal txt0_addr1		: std_logic_vector(7 downto 0) := X"00";
signal txt0_addr2		: std_logic_vector(7 downto 0) := X"14";
signal txt1_addr1		: std_logic_vector(7 downto 0) := X"00";
signal txt1_addr2		: std_logic_vector(7 downto 0) := X"14";
--
signal reg0_fe			: std_logic_vector(7 downto 0);
signal reg0_fd			: std_logic_vector(7 downto 0)	:= X"04";	-- Версия IP-Core
signal ram0_wr			: std_logic;
signal ram0_do			: std_logic_vector(7 downto 0);
signal ram1_wr			: std_logic;
signal ram1_do			: std_logic_vector(7 downto 0);

-- MULT
signal mult0_data1		: std_logic_vector(7 downto 0) := X"00";
signal mult0_data2		: std_logic_vector(7 downto 0) := X"00";
signal mult0_result		: std_logic_vector(15 downto 0);
signal mult1_data1		: std_logic_vector(7 downto 0) := X"00";
signal mult1_data2		: std_logic_vector(7 downto 0) := X"00";
signal mult1_result		: std_logic_vector(15 downto 0);

-- UART
signal uart_do			: std_logic_vector(7 downto 0);
signal uart_wr			: std_logic;
signal uart_rd			: std_logic;
signal uart_tx_busy		: std_logic;
signal uart_rx_avail	: std_logic;
signal uart_rx_error	: std_logic;

-- DRAM
signal dram_clk100		: std_logic;
signal dram_do			: std_logic_vector(7 downto 0);
signal dram_addr		: std_logic_vector(24 downto 0);
signal dram_wr			: std_logic;
signal dram_rd			: std_logic;
signal dram_idle		: std_logic;

signal wr				: std_logic;
signal rd				: std_logic;

begin
	
-- PLL
pll: entity work.altpll0
port map (
	inclk0		=> CLK_50MHz,
	c0			=> clk_vga,			-- 25.0 MHz
	c1			=> x80cpu_clk,		-- 50.0 MHz
	c2			=> t80cpu_clk);		-- 100.0 MHz
	
-- X80CPU
cpu0: entity work.x80
port map(
	CLK			=> not x80cpu_clk,
	ENA			=> '1',
	RESET		=> reset,
	NMI			=> '0',
	INT			=> '0',
	DI			=> x80cpu_di,
	DO			=> x80cpu_do,
	ADDR		=> x80cpu_addr,
	WR			=> x80cpu_wr,
	MREQ		=> x80cpu_mreq,
	IORQ		=> x80cpu_iorq,
	HALT		=> open,
	M1			=> open);

-- Text Mode 80x30 (640x480 60Hz) 4800 bytes, Font 8x16 4096 bytes
vga: entity work.txt
port map(
	CLK			=> clk_vga,
	CHAR_DI		=> txt_char_di,
	FONT_DI		=> txt_font_di,
	CHAR_ADDR	=> txt_char_addr,
	FONT_ADDR	=> txt_font_addr,
	RGB			=> txt_rgb,
	HS			=> VGA_HSYNC,
	VS			=> VGA_VSYNC);
	
-- RAM 16K
ram0: entity work.altram0
port map(
	address_a	=> x80cpu_addr(13 downto 0),
	address_b	=> txt0_char_addr(12 downto 0),
	clock_a	 	=> x80cpu_clk,
	clock_b	 	=> clk_vga,
	data_a	 	=> x80cpu_do,
	data_b	 	=> (others => '0'),
	wren_a	 	=> ram0_wr,
	wren_b	 	=> '0',
	q_a	 		=> ram0_do,
	q_b	 		=> txt0_char_di);

-- RAM 16K
ram1: entity work.altram1
port map(
	address_a	=> t80cpu_addr(13 downto 0),
	address_b	=> txt1_char_addr(12 downto 0),
	clock_a	 	=> t80cpu_clk,
	clock_b	 	=> clk_vga,
	data_a	 	=> t80cpu_do,
	data_b	 	=> (others => '0'),
	wren_a	 	=> ram1_wr,
	wren_b	 	=> '0',
	q_a	 		=> ram1_do,
	q_b	 		=> txt1_char_di);
	
	
-- FONT 4K
font: entity work.altrom1
port map(
	address		=> txt_font_addr,
	clock		=> not clk_vga,
	q			=> txt_font_di);

-- UART
ft232r: entity work.uart
generic map (
	-- divisor = 35MHz / 115200 Baud = 303
	divisor		=> 303)
port map (
	CLK			=> x80cpu_clk,
	RESET		=> reset,
	WR			=> uart_wr,
	RD			=> uart_rd,
	DI			=> x80cpu_do,
	DO			=> uart_do,
	TXBUSY		=> uart_tx_busy,
	RXAVAIL		=> uart_rx_avail,
	RXERROR		=> uart_rx_error,
	RXD			=> TXD,
	TXD			=> RXD);

-- T80CPU	
cpu1: entity work.t80se
generic map (
	Mode		=> 0,	-- 0 => Z80, 1 => Fast Z80, 2 => 8080, 3 => GB
	T2Write		=> 1,	-- 0 => WR_n active in T3, 1 => WR_n active in T2
	IOWait		=> 1)	-- 0 => Single cycle I/O, 1 => Std I/O cycle
port map(
	RESET_n		=> not reset,
	CLK_n		=> not t80cpu_clk,
	CLKEN		=> '1',
	WAIT_n		=> '1',
	INT_n		=> '1',
	NMI_n		=> '1',
	BUSRQ_n		=> '1',
	M1_n		=> open,
	MREQ_n		=> t80cpu_mreq_n,
	IORQ_n		=> t80cpu_iorq_n,
	RD_n		=> t80cpu_rd_n,
	WR_n		=> t80cpu_wr_n,
	RFSH_n		=> open,
	HALT_n		=> open,
	BUSAK_n		=> open,
	A			=> t80cpu_addr,
	DI			=> t80cpu_di,
	DO			=> t80cpu_do);

-------------------------------------------------------------------------------
-- Карта памяти X80v1 CPU
-------------------------------------------------------------------------------
-- A15 A14 A13
-- 0   0   x	0000-3FFF (16384) RAM
-- 0   0   x			  ( 4800) текстовый буфер (символ, цвет, символ...)
-- 0   1   x	4000-7FFF ( 8192) пусто 
-- 1   x   x	8000-FFFF (32768) SRAM страница (0..15)

-- A15 A14 A14 A13 A12 A11 A10 A9 A8 | A7 A6 A5 A4 A3 A2 A1 A0
-- x   x   x   x   x   x   x   x  x    x  x  x  x  x  x  x  0	#FE	R/W:b3..0 номер страницы SRAM, подключенной в верхние 32КБ памяти (с адреса #8000)
-- x   x   x   x   x   x   x   x  x    x  x  x  x  x  x  0  x	#FD	R:	b7..0 версия Soft-Core
-- x   x   x   x   x   x   x   x  x    x  x  x  x  x  0  x  x	#FB	W:	mult0_data1,	R:	mult0_result(7..0) 	Mult Result = mult_data1*mault_data2
-- x   x   x   x   x   x   x   x  x    x  x  x  x  0  x  x  x	#F7	W:	mult0_data2,	R:	mult0_result(15..8)
-- x   x   x   x   x   x   x   x  x    x  x  x  0  x  x  x  x	#EF W/R:uart_data(7..0)
-- x   x   x   x   x   x   x   x  x    x  x  0  x  x  x  x  x	#DF	R:	b7= uart_tx_busy, b6= CBUS4, b5..2= 1111, b1= uart_rx_error, b0= uart_rx_avail
-- x   x   x   x   x   x   x   x  x    x  0  x  x  x  x  x  x	#BF W/R:txt0_addr1 мл.адрес начала текстового видео буфера
-- x   x   x   x   x   x   x   x  x    0  x  x  x  x  x  x  x	#7F W/R:txt0_addr2 ст.адрес начала текстового видео буфера

-------------------------------------------------------------------------------
-- Карта памяти T80v3 CPU
-------------------------------------------------------------------------------
-- A15 A14 A13
-- 0   0   x	0000-3FFF (16384) RAM
-- 0   0   x		      ( 4800) текстовый буфер (символ, цвет, символ...)
-- 1   x   x	4000-FFFF (49152) пусто

-- A15 A14 A14 A13 A12 A11 A10 A9 A8 | A7 A6 A5 A4 A3 A2 A1 A0
-- x   x   x   x   x   x   x   x  x    x  x  x  x  x  x  x  0	#FE
-- x   x   x   x   x   x   x   x  x    x  x  x  x  x  x  0  x	#FD 
-- x   x   x   x   x   x   x   x  x    x  x  x  x  x  0  x  x	#FB	W:	mult1_data1,	R:	mult1_result(7..0) 	Mult Result = mult_data1*mault_data2
-- x   x   x   x   x   x   x   x  x    x  x  x  x  0  x  x  x	#F7	W:	mult1_data2,	R:	mult1_result(15..8)
-- x   x   x   x   x   x   x   x  x    x  x  x  0  x  x  x  x	#EF
-- x   x   x   x   x   x   x   x  x    x  x  0  x  x  x  x  x	#DF
-- x   x   x   x   x   x   x   x  x    x  0  x  x  x  x  x  x	#BF W/R:txt1_addr1 мл.адрес начала текстового видео буфера
-- x   x   x   x   x   x   x   x  x    0  x  x  x  x  x  x  x	#7F W/R:txt1_addr2 ст.адрес начала текстового видео буфера


-- GLOBAL
reset <= not RST_n;

-------------------------------------------------------------------------------
-- VGA
VGA_R <= txt_rgb(5 downto 4) & 'Z';
VGA_G <= txt_rgb(3 downto 2) & 'Z';
VGA_B <= txt_rgb(1 downto 0) & 'Z';

txt_char_di    <= txt0_char_di or txt1_char_di;
txt0_char_addr <= std_logic_vector (unsigned( '0' & txt_char_addr) + unsigned (txt0_addr2(5 downto 0) & txt0_addr1));	-- Адрес начала текстового буфера для x80CPU
txt1_char_addr <= std_logic_vector (unsigned( '0' & txt_char_addr) + unsigned (txt1_addr2(5 downto 0) & txt1_addr1));	-- Адрес начала текстового буфера для t80CPU

-------------------------------------------------------------------------------
-- X80CPU
x80cpu_di <=	ram0_do when (x80cpu_addr(15 downto 14) = "00" and x80cpu_mreq = '1' and x80cpu_wr = '0') else
				SRAM_D when (x80cpu_addr(15) = '1' and x80cpu_mreq = '1' and x80cpu_wr = '0') else

				reg0_fe when (x80cpu_addr(0) = '0' and x80cpu_iorq = '1' and x80cpu_wr = '0') else
				reg0_fd when (x80cpu_addr(1) = '0' and x80cpu_iorq = '1' and x80cpu_wr = '0') else
				uart_tx_busy & CBUS4 & "1111" & uart_rx_error & uart_rx_avail when (x80cpu_addr(5) = '0' and x80cpu_wr = '0' and x80cpu_iorq = '1') else	--UART
				uart_do when (x80cpu_addr(4) = '0' and x80cpu_wr = '0' and x80cpu_iorq = '0') else			
				mult0_result(7 downto 0) when (x80cpu_addr(2) = '0' and x80cpu_iorq = '1' and x80cpu_wr = '0') else
				mult0_result(15 downto 8) when (x80cpu_addr(3) = '0' and x80cpu_iorq = '1' and x80cpu_wr = '0') else
				txt0_addr1 when (x80cpu_addr(6) = '0' and x80cpu_iorq = '1' and x80cpu_wr = '0') else
				txt0_addr2 when (x80cpu_addr(7) = '0' and x80cpu_iorq = '1' and x80cpu_wr = '0') else
				(others => '1');

-------------------------------------------------------------------------------
-- T80CPU
t80cpu_di <=	ram1_do when (t80cpu_addr(15 downto 14) = "00" and t80cpu_mreq_n = '0' and t80cpu_rd_n = '0') else

				mult1_result(7 downto 0) when (t80cpu_addr(2) = '0' and t80cpu_iorq_n = '0' and t80cpu_rd_n = '0') else
				mult1_result(15 downto 8) when (t80cpu_addr(3) = '0' and t80cpu_iorq_n = '0' and t80cpu_rd_n = '0') else
				txt1_addr1 when (t80cpu_addr(6) = '0' and t80cpu_iorq_n = '0' and t80cpu_rd_n = '0') else
				txt1_addr2 when (t80cpu_addr(7) = '0' and t80cpu_iorq_n = '0' and t80cpu_rd_n = '0') else
				(others => '1');
				
-------------------------------------------------------------------------------
-- SRAM
SRAM_A <= reg0_fe(4 downto 0) & x80cpu_addr(14 downto 0);
SRAM_D <= x80cpu_do when (x80cpu_addr(15) = '1' and x80cpu_wr = '1' and x80cpu_mreq = '1') else "ZZZZZZZZ";
SRAM_WE_n <= not x80cpu_addr(15) or not x80cpu_mreq or not x80cpu_wr or not x80cpu_clk;

ram0_wr <= not x80cpu_addr(15) and not x80cpu_addr(14) and x80cpu_mreq and x80cpu_wr;
ram1_wr <= not t80cpu_addr(15) and not t80cpu_addr(14) and not t80cpu_mreq_n and not t80cpu_wr_n;

-------------------------------------------------------------------------------
-- X80CPU I/O
process (x80cpu_clk, reset, x80cpu_addr, x80cpu_iorq, x80cpu_mreq, x80cpu_wr)
begin
	if (reset = '1') then
		reg0_fe <= (others => '0');
	elsif (x80cpu_clk'event and x80cpu_clk = '1') then
		if (x80cpu_addr(0) = '0' and x80cpu_iorq = '1' and x80cpu_wr = '1') then reg0_fe <= x80cpu_do; end if;
		if (x80cpu_addr(2) = '0' and x80cpu_iorq = '1' and x80cpu_wr = '1') then mult0_data1 <= x80cpu_do; end if;
		if (x80cpu_addr(3) = '0' and x80cpu_iorq = '1' and x80cpu_wr = '1') then mult0_data2 <= x80cpu_do; end if;
		if (x80cpu_addr(6) = '0' and x80cpu_iorq = '1' and x80cpu_wr = '1') then txt0_addr1 <= x80cpu_do; end if;
		if (x80cpu_addr(7) = '0' and x80cpu_iorq = '1' and x80cpu_wr = '1') then txt0_addr2 <= x80cpu_do; end if;
	end if;
end process;

-------------------------------------------------------------------------------
-- T80CPU I/O
process (t80cpu_clk, reset, t80cpu_addr, t80cpu_iorq_n, t80cpu_mreq_n, t80cpu_wr_n)
begin
	if (t80cpu_clk'event and t80cpu_clk = '1') then
		if (t80cpu_addr(2) = '0' and t80cpu_iorq_n = '0' and t80cpu_wr_n = '0') then mult1_data1 <= t80cpu_do; end if;
		if (t80cpu_addr(3) = '0' and t80cpu_iorq_n = '0' and t80cpu_wr_n = '0') then mult1_data2 <= t80cpu_do; end if;
		if (t80cpu_addr(6) = '0' and t80cpu_iorq_n = '0' and t80cpu_wr_n = '0') then txt1_addr1 <= t80cpu_do; end if;
		if (t80cpu_addr(7) = '0' and t80cpu_iorq_n = '0' and t80cpu_wr_n = '0') then txt1_addr2 <= t80cpu_do; end if;
	end if;
end process;

-------------------------------------------------------------------------------
-- MULT
mult0_result <= mult0_data1 * mult0_data2;	-- Умножение для X80CPU
mult1_result <= mult1_data1 * mult1_data2;	-- Умножение для T80CPU

-------------------------------------------------------------------------------
-- UART
uart_wr <= '1' when (x80cpu_iorq = '1' and x80cpu_wr = '1' and x80cpu_addr(4) = '0') else '0';
uart_rd <= '1' when (x80cpu_iorq = '1' and x80cpu_wr = '0' and x80cpu_addr(4) = '0') else '0';


end ultimate_arch;