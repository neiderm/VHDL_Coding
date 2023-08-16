----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 08/16/2023 05:51:47 AM
-- Design Name: 
-- Module Name: mux - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- RB: copy mux source from 
--     https://www.chegg.com/homework-help/questions-and-answers/tell-writing-code-vhdl-code-4-1-multiplexor-esd-book-figure-25-weijun-zhang-04-2001-multip-q9066873
----------------------------------------------------------------------------------

--VHDL code for 4:1 multiplexor
-- (ESD book figure 2.5)
-- by Weijun Zhang, 04/2001
-- Multiplexor is a device to select different
-- inputs to outputs. we use 3 bits vector to 
-- describe its I/O ports 
--
-- RB: make IO bus widths generic

library ieee;
use ieee.std_logic_1164.all;

entity Mux is
    generic (
        RGB_SIGW : integer := 12 - 1); -- input bus width
    port(
        I3:     in std_logic_vector(RGB_SIGW downto 0);
        I2:     in std_logic_vector(RGB_SIGW downto 0);
        I1:     in std_logic_vector(RGB_SIGW downto 0);
        I0:     in std_logic_vector(RGB_SIGW downto 0);
        S:      in std_logic_vector(1 downto 0);
        O:      out std_logic_vector(RGB_SIGW downto 0)
);
end Mux;  

architecture behv1 of Mux is
begin
    process(I3,I2,I1,I0,S)
    begin
    
        -- use case statement
        case S is
            when "00" =>     O <= I0;
            when "01" =>     O <= I1;
            when "10" =>     O <= I2;
            when "11" =>     O <= I3;
            when others =>   O <= (others => 'Z');
        end case;

    end process;
end behv1;

architecture behv2 of Mux is
begin

    -- use when.. else statement
    O <=        I0 when S="00" else
                I1 when S="01" else
                I2 when S="10" else
                I3 when S="11" else
                (others => 'Z');

end behv2;

