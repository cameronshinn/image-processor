% Image to Verilog converter
% 
% A JPEG image opened and converted to an array of RGB values.  (The imread 
% function can open other image formats as well; type "help imread" for more 
% information)
% The 2-D image array is linearized and the RGB values are written to a file
% as ROM modules in Verilog syntax.
% 
% This script calls two functions defined within this file. This script
% works on the machines in Kemper 2110, which run matlab release 2017a.
% If your version of matlab gives the error "Function definitions are not
% permitted in this context," you can work around this by moving the function
% definitions for read_image() and create_rom_from_pixels() into separate
% files named read_image.m and create_rom_from_pixels.m, respectively.
% 
% 2018/05/29  Rewrote to manually write selected pixels using function calls
% 2018/05/29  Image automatically split across a specified number of ROM modules
% 2018/05/29  Automatic image resizing removed
% 2018/05/27  Written. (Timothy Andreas)

%==============================================================================
%===== User options (specify these)  vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv

%Place the input image in the same directory with this MATLAB script, or
%specify the path to the image.
jpeg_file    = 'image.jpg';        % input image file name
verilog_file = 'roms.v';                % output verilog file name

%===== User options (specify these)  ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
%==============================================================================

% Non-user options.
global bit_depth fobj   %These vars are shared with other functions.
bit_depth    = 12;      %Number of bits per pixel, to be evenly split among 
                        %R, G, B channels.
% Open the JPEG file, store contents in three 2-D arrays containing
%the R, G, B values for each pixel.
%R, G, B values are 4 bits each.
[r, g, b] = read_image(jpeg_file);
[jpeg_height, jpeg_width] = size(r);

%Open the Verilog output file.
fobj = fopen(verilog_file, 'w');

%==============================================================================
%==== DESIGN YOUR ROM MODULES BELOW THIS LINE  vvvvvvvvvvvvvvvvvvvvvvvvvvvvv

%This function call creates a new ROM called rom_0 containing the Red values
%  of the pixels from rows 1-90 and columns 1-60.
%  Pixels are written to the ROM in row major order.
%Argument 0:3 specifies that all bits [3:0] of the 4-bit Red value are written.
%  Bits are written with the MSB on the left, as is typical in Verilog.
%  Do NOT put 3:0, MATLAB doesn't know how to handle it.
%    If the 0:3 reversal really bugs you, either of the following will
%    produce identical results.
%    [3, 2, 1, 0]
%    3:-1:0
create_rom_from_pixels('rom_0_r', r(1:32, 1:128), 0:3);
create_rom_from_pixels('rom_0_g', r(1:32, 1:128), 0:3);
create_rom_from_pixels('rom_0_b', r(1:32, 1:128), 0:3);

create_rom_from_pixels('rom_1_r', r(33:64, 1:128), 0:3);
create_rom_from_pixels('rom_1_g', r(33:64, 1:128), 0:3);
create_rom_from_pixels('rom_1_b', r(33:64, 1:128), 0:3);

create_rom_from_pixels('rom_2_r', r(65:96, 1:128), 0:3);
create_rom_from_pixels('rom_2_g', r(65:96, 1:128), 0:3);
create_rom_from_pixels('rom_2_b', r(65:96, 1:128), 0:3);

create_rom_from_pixels('rom_3_r', r(97:128, 1:128), 0:3);
create_rom_from_pixels('rom_3_g', r(97:128, 1:128), 0:3);
create_rom_from_pixels('rom_3_b', r(97:128, 1:128), 0:3);

%==== DESIGN YOUR ROM MODULES ABOVE THIS LINE ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
%==============================================================================

% Close the Verilog file.
fclose(fobj);

% jpeg_file: string specifying the file name/path.
function [r, g, b] = read_image(jpeg_file)
    global bit_depth

    rgb_array = imread(jpeg_file);
    %Get the JPEG properties, mainly to find out the native color depth.
    info = imfinfo(jpeg_file);
    native_bit_depth = info.BitDepth;

    %Scale RGB values from the native color depth to the desired color
    %depth to be stored in ROM.
    %Divide-by-3 factor comes from the three independent color channels.
    rgb_array = bitshift(rgb_array, (bit_depth - native_bit_depth)/3);
    
    r = rgb_array(:, :, 1);
    g = rgb_array(:, :, 2);
    b = rgb_array(:, :, 3);
end

% module_name: string.
% pixels: 2-D array of pixel values to be written to this ROM instance.
% bits: selects which bits of each pixel value will be written to the ROM.
function create_rom_from_pixels(module_name, pixels, bits)
    global fobj
    
    [rows, cols] = size(pixels);
    mem_words = rows * cols;
    address_bits = ceil(log2(mem_words));
    [~, data_bits] = size(bits);

    %Write the module ports and declarations.
    fprintf(fobj, 'module %s (\n\tinput clock,\n\tinput [%d:0] address,\n\toutput reg [%d:0] data_out\n);\n\n', module_name, address_bits - 1, data_bits - 1);
    fprintf(fobj, 'reg [%d:0] mem [0:%d];\n\n', data_bits - 1, 2^address_bits - 1);
    fprintf(fobj, 'always @(posedge clock) begin\n\tdata_out <= mem[address];\nend\n\n');

    %Print ROM contents inside an "initial begin" block.
    fprintf(fobj, 'initial begin\n');

    %Memory layout is row major.
    mem_address = 0;
    for row = 1:rows
        for col = 1:cols
            %Pull the pixel value from the array.
            p = pixels(row, col);
            
            %Shift and bitmask this value to access only the desired bits.
            q = 0;
            bits2 = bits;
            for i = 0:data_bits-1
                [a, b] = min(bits2);
                q = q + bitshift(bitand(bitshift(p, -a), 1), i);
                bits2(b) = NaN;
            end
            
            %Write this value to the output file in Verilog syntax.
            fprintf(fobj, '\tmem[%d] = %d''b%s;\n', mem_address, data_bits, dec2bin(q, data_bits));
            mem_address = mem_address + 1;
        end
    end

    %Fill up any remaining ROM addresses with zeros.
    %Quartus throws a warning if these are not specified.
    for mem_address = mem_words:2^address_bits - 1
        fprintf(fobj, '\tmem[%d] = %d''b%s;\n', mem_address, data_bits, dec2bin(0, data_bits));
    end

    %Terminate the inital begin block and module.
    fprintf(fobj, 'end\nendmodule\n\n');
end
