module lab_6
    (
        CLOCK_50,                        //    On Board 50 MHz
        // Your inputs and outputs here
        KEY,
        SW,
        // The ports below are for the VGA output.  Do not change.
        VGA_CLK,                           //    VGA Clock
        VGA_HS,                            //    VGA H_SYNC
        VGA_VS,                            //    VGA V_SYNC
        VGA_BLANK_N,                        //    VGA BLANK
        VGA_SYNC_N,                        //    VGA SYNC
        VGA_R,                           //    VGA Red[9:0]
        VGA_G,                             //    VGA Green[9:0]
        VGA_B,                           //    VGA Blue[9:0]
        HEX0,
        HEX1
    );
    input            CLOCK_50;                //    50 MHz
    input   [9:0]   SW;
    input   [3:0]   KEY;
    output   [6:0] HEX0;
    output   [6:0] HEX1;
    // Declare your inputs and outputs here
    // Do not change the following outputs
    output            VGA_CLK;                   //    VGA Clock
    output            VGA_HS;                    //    VGA H_SYNC
    output            VGA_VS;                    //    VGA V_SYNC26'b10000000000000000000000000
    output            VGA_BLANK_N;                //    VGA BLANK
    output            VGA_SYNC_N;                //    VGA SYNC
    output    [9:0]    VGA_R;                   //    VGA Red[9:0]
    output    [9:0]    VGA_G;                     //    VGA Green[9:0]
    output    [9:0]    VGA_B;                   //    VGA Blue[9:0]
   
    wire resetn;
    assign resetn = alwaysOne ;
   
    // Create the colour, x, y and writeEn wires that are inputs to the controller.
   reg [2:0] colour;// notice they were originally wire ,  I made them reg     edit:Mar20, 2:30am
    reg [6:0] x;
    reg [6:0] y;
    reg  writeEn;
   

    // Create an Instance of a VGA controller - there can be only one!
    // Define the number of colours as well as the initial background
    // image file (.MIF) for the controller.
    vga_adapter VGA(
            .resetn(resetn),
            .clock(CLOCK_50),
            .colour(colour),
            .x(x),
            .y(y),
            .plot(writeEn),
            /* Signals for the DAC to drive the monitor. */
            .VGA_R(VGA_R),
            .VGA_G(VGA_G),
            .VGA_B(VGA_B),
            .VGA_HS(VGA_HS),
            .VGA_VS(VGA_VS),
            .VGA_BLANK(VGA_BLANK_N),
            .VGA_SYNC(VGA_SYNC_N),
            .VGA_CLK(VGA_CLK));
    defparam VGA.RESOLUTION = "160x120";
    defparam VGA.MONOCHROME = "FALSE";
    defparam VGA.BITS_PER_COLOUR_CHANNEL = 1;
    defparam VGA.BACKGROUND_IMAGE = "black.mif";
   
    // Put your code here. Your code should produce signals x,y,colour and writeEn/plot
    // for the VGA controller, in addition to any other functionality your design may require.
    reg alwaysOne = 1'b1;
    reg alwaysZero = 1'b0;
	 reg speed1 = 2'b00;
	 reg speed2 = 2'b01;
	 reg speed3 = 2'b10;
   
    wire ld_x, ld_y;
    wire [3:0] stateNum;
    reg  [7:0] init_player_coord = 8'b00000010; // this is x coord
    wire [2:0] colour_player;
    wire [6:0] x_player;
    wire [6:0] y_player;
    wire writeEn_player;
    reg [25:0] counter_for_player = 26'b00000000000000000000000000;
    reg [6:0] init_y_p = 7'b1110000;
    reg [2:0] acolour_p = 3'b100;
    // Instansiate datapath                             
    datapath d0(.clk(CLOCK_50), .ld_x(ld_x), .ld_y(ld_y), .in(  init_player_coord), .reset_n(resetn), .x(x_player), .y(y_player), .colour(colour_player), .write(writeEn_player), .stateNum(stateNum), .init_y(init_y_p), .acolour(acolour_p));
   
    // Instansiate FSM control
    control c0(.clk(CLOCK_50), .move_r(~KEY[0]), .move_l(~KEY[3]), .move_d(~KEY[1]), .move_u(~KEY[2]), .reset_n(resetn), .ld_x(ld_x), .ld_y(ld_y), .stateNum(stateNum), .reset_game(reset_game), .dingding(counter_for_player), .how_fast(speed1));
   
     
    // --------------------------------------car movement starts here, for all cars----------------------------------------------------------
   
    wire ld_x_car0, ld_y_car0;
    wire [3:0] stateNum_car0;
    reg  [6:0] car0_coord = 7'b0101111;
    wire [2:0] colour_car0;
    wire [6:0] x_car0;
    wire [6:0] y_car0;
    wire writeEn_car0;
    reg [25:0] counter_for_car0 = 26'b00000000000000000000000001;
    reg [6:0] init_y_c0 = 7'b0101010;
    reg [2:0] acolour_c0 = 3'b100;
    // Instansiate datapath                                
    datapath car_0_d(.clk(CLOCK_50), .ld_x(ld_x_car0), .ld_y(ld_y_car0), .in(  car0_coord), .reset_n(resetn), .x(x_car0), .y(y_car0), .colour(colour_car0), .write(writeEn_car0), .stateNum(stateNum_car0),  .init_y(init_y_c0), .acolour(acolour_c0));
   
    // Instansiate FSM control
    control car_0_c(.clk(CLOCK_50), .move_r(alwaysOne), .move_l(~KEY[2]), .move_d(~KEY[3]),  .move_u(~KEY[0]), .reset_n(resetn), .ld_x(ld_x_car0), .ld_y(ld_y_car0), .stateNum(stateNum_car0), .reset_game(alwaysZero), .dingding(counter_for_car0), .how_fast(speed2));
    //The outputs are: x_car0, y_car0, colour_car0, writeEn_car0
    //car0 movement ends here----------------------------------------------------------------------------------------------------


    wire [9:0] score;
    wire reset_game;
    scoreCounter player_and_car0(x_player, y_player, x_car0, y_car0, x_car1, y_car1, x_car2, y_car2, x_car3, y_car3, x_car4, y_car4, x_car5, y_car5, x_car6, y_car6, x_car7, y_car7, x_car8, y_car8, x_car9, y_car9, x_car10, y_car10, x_car11, y_car11, x_car12, y_car12, score, reset_game);
    hex_display first_digit(score, HEX1[6:0], HEX0[6:0]); //notice score is displayed in hexadecimal
     
    //The following for processing player movement and car movement (make sure that only one of play or the car can move on the same clock cycle)
    // If player is moving ,then link the vga to the player, if the car is moving, than link the vga to the car
    // If both of them are moving in the same clock cycle (very unlikely), then move the player
    // edited: mar 20, 5pmreset_n
    // Notice: writeEn_player is write Enable for player; writeEn_car0 is write enable for car_0
    // The following is for choosing to print the player movement or to print the car movement
   
    always @(posedge CLOCK_50)
    begin
        if(writeEn_player) 
            begin
                writeEn <= writeEn_player;   //  Do I use   <=   or   =   ????? writeEn, x, y and colour are originally type wire, but I need to make them type reg???  ????????????????????????????????
                x <= x_player;       
                y <= y_player;
                colour = colour_player; // Notice: I made the following variable type reg: writeEn, x, y, colour
            end
        else if (writeEn_car0)    // if player isnt moving, then let the car move
            begin
                writeEn <= writeEn_car0;    
                x <= x_car0;                       
                y <= y_car0;
                colour <= colour_car0;
            end   
    end
       
endmodule


//You need to extend the parameter of this module such that all cood. of all cars are inputed into this module
//outputs are score and reset,
//if reset is 1, this means the play crashed into a car and game should be reset
module scoreCounter(x_player, y_player,
x_car0, y_car0, x_car1, y_car1, x_car2, y_car2, x_car3, y_car3, x_car4, y_car4, x_car5, y_car5, x_car6, y_car6,
x_car7, y_car7, x_car8, y_car8, x_car9, y_car9, x_car10, y_car10, x_car11, y_car11, x_car12, y_car12,
score, reset_game);
    input [6:0] x_player;
    input [6:0] y_player;
    input [6:0] x_car0;
    input [6:0] y_car0;
    input [6:0] x_car1;
    input [6:0] y_car1;
    input [6:0] x_car2;
    input [6:0] y_car2;
    input [6:0] x_car3;
    input [6:0] y_car3;
    input [6:0] x_car4;
    input [6:0] y_car4;
    input [6:0] x_car5;
    input [6:0] y_car5;
    input [6:0] x_car6;
    input [6:0] y_car6;
    input [6:0] x_car7;
    input [6:0] y_car7;
    input [6:0] x_car8;
    input [6:0] y_car8;
    input [6:0] x_car9;
    input [6:0] y_car9;
    input [6:0] x_car10;
    input [6:0] y_car10;
    input [6:0] x_car11;
    input [6:0] y_car11;
    input [6:0] x_car12;
    input [6:0] y_car12;
    output reg [9:0] score;
    output reg reset_game;
    
	
    always @(*) //Notice it is not positive edge
    begin
        if (y_player == 7'b0000011) // When player reaches the top of the screen
            begin // it is going into this state
                score = score + 1'b1;
                reset_game = 1'b1;
            end
//		  else if (y_player == 7'b1110001)   //Change this!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
//				begin
//			   reset_game = 1'b1;
//				score = score;
//				end
        else if ((x_player == x_car0 && y_player == y_car0) || (x_player == x_car1 && y_player == y_car1) ||
          (x_player == x_car2 && y_player == y_car2) || (x_player == x_car3 && y_player == y_car3) ||
          (x_player == x_car4 && y_player == y_car4) || (x_player == x_car5 && y_player == y_car5) ||
          (x_player == x_car6 && y_player == y_car6) || (x_player == x_car7 && y_player == y_car7) ||
          (x_player == x_car8 && y_player == y_car8) || (x_player == x_car9 && y_player == y_car9) ||
          (x_player == x_car10 && y_player == y_car10) || (x_player == x_car11 && y_player == y_car11) ||
          (x_player == x_car12 && y_player == y_car12) )  // player collide with car (any of the 13 cars)
            begin
                     reset_game = 1'b1;
                     score = 1'b0;
            end
			
        else
            reset_game = 1'b0;
    end

endmodule				  


module control(clk, move_r, move_l, move_d, move_u, reset_n, ld_x, ld_y, stateNum, reset_game, dingding, how_fast);
    input [25:0] dingding; // dingding is the counter! It counts like this: Ding!!! Ding!!! Ding!!! Ding!!! Ding!!!
    input reset_game;
    input clk, move_r, move_l, move_d, move_u, reset_n;
	 input [1:0] how_fast;
    output reg ld_y, ld_x;
    reg [3:0] curr, next;
    output reg [3:0] stateNum;
    localparam    S_CLEAR    = 4'b0000;
    localparam S_LOAD_X    = 4'b0001;
    localparam S_WAIT_Y    = 4'b0010;
    localparam S_LOAD_Y    = 4'b0011;
   
    localparam    wait_input    = 4'b0100;
    localparam    clear_all    = 4'b0101;
    localparam    print_right    = 4'b0110;
    localparam    print_left    = 4'b0111;
    localparam    print_down    = 4'b1000;
    localparam    print_up    = 4'b1001;
    localparam  temp_selecting_state = 4'b1010;
    localparam after_drawing = 4'b1011;
    localparam cleanUp = 4'b1100;
    wire [26:0] press_now;   
    wire [26:0] press_now_for_car;   
    wire result_press_now;
	 reg [25:0] speed;
    //wire result_for_car;
    
	 always @(*)
	 begin
		if (how_fast == 2'b00)
		   speed <= 26'b0101111101011110000100;

		else if (how_fast == 2'b01)
		   speed <= 26'b010111110101111000010;
	   else if (how_fast == 2'b10)
		   speed <= 26'b010111110101111000010;
		else
		   speed <= 26'b01011111010111100001;
	 end
	 RateDividerForCar player_counter1(clk, press_now, reset_n, speed);
	 
    assign result_press_now = (press_now == dingding) ? 1 : 0;
   
    always @(*)
    begin: state_table
        case (curr)
            S_CLEAR: next = S_LOAD_X ;
            S_LOAD_X: next = S_WAIT_Y;
            S_WAIT_Y: next = S_LOAD_Y;

            S_LOAD_Y: next = temp_selecting_state; // the next line is edited on Mar 27
            temp_selecting_state: next = reset_game ? cleanUp : ( ((move_r || move_l || move_d || move_u) && result_press_now) ? clear_all : S_LOAD_Y );
           
            clear_all:
                begin
                    if(move_r)  
                        next <= print_right;
                    else if (move_l)    // if player isnt moving, then let the car move
                        next <= print_left;
                    else if (move_d)   // if player isnt moving, then let the car move
                        next <= print_down;
                    else if (move_u)   // if player isnt moving, then let the car move
                        next <= print_up;
                end
            cleanUp: next = S_CLEAR;
            //
            print_right: next = reset_game ? S_LOAD_Y : after_drawing;
            print_left: next =  reset_game ? S_LOAD_Y : after_drawing;
            print_down: next = reset_game ? S_LOAD_Y : after_drawing;
            print_up: next = reset_game ? S_LOAD_Y : after_drawing;
            after_drawing: next= temp_selecting_state;
           
        default: next = S_CLEAR;
        endcase
    end

    always@(*)
    begin: enable_signals
        ld_x = 1'b0;
        ld_y = 1'b0;
        //write = 1'b0;
        stateNum = 4'b0000;
        case (curr)
            S_LOAD_X: begin
                ld_x = 1'b1;
                end
            S_LOAD_Y: begin
                ld_y = 1'b1;
                end
            cleanUp: begin // this IS suppose to be the same as clear all (edited on mar27)
                stateNum = 4'b0001;
                ld_y = 1'b0;
                //write = 1'b1;
                end
            clear_all: begin
                stateNum = 4'b0001;
                ld_y = 1'b0;
                //write = 1'b1;
                end
           
            print_right: begin
                stateNum = 4'b0100;
                ld_y = 1'b0;
                //write = 1'b1;
                end
           
            print_down: begin
                stateNum = 4'b0011;
                ld_y = 1'b0;
                //write = 1'b1;
                end				  
               
            print_left: begin
                stateNum = 4'b0010;
                ld_y = 1'b0;
   
                //write = 1'b1;
                end
               
            print_up: begin
                stateNum = 4'b1001;
                ld_y = 1'b0;
   
                //write = 1'b1;
                end
               
            after_drawing: begin
                stateNum = 4'b1000;
                end
           
           
        endcase
    end

    always @(posedge clk)
    begin: states
        if(!reset_n)
            curr <= S_LOAD_X;
        else
            curr <= next;
    end

endmodule

module datapath(clk, ld_x, ld_y, in, reset_n, x, y, colour, stateNum, write, init_y, acolour);
    input clk;
    input [7:0] in;
    input [6:0] init_y;
    input [2:0] acolour;
    input ld_x, ld_y;
    input reset_n;
    output reg [2:0] colour;
    output reg write;
    output reg [6:0] y;
    output reg [7:0] x;
    input [3:0] stateNum;

    always @(posedge clk)
    begin
        if(!reset_n)
        begin
            x <= 7'b0000000;
            y <= 6'b000000;
            colour <= 3'b000;
        end
        else
        begin
            if(ld_x)
                begin
                    x[7:0] <= in;
                    y <= init_y;
                    write <= 1'b0;
                end
            else if(ld_y)
                begin
                    write <= 1'b0;
                end
               
            // The following is for clearing
            else if(stateNum == 4'b0001)
                begin
                    colour <= 3'b000;
                    write <= 1'b1;
                end
               
            // The following is for moving right
            else if(stateNum == 4'b0100)   
                begin
               
                    x[7:0] <= x + 8'b00000001;
                    colour <= acolour;
                    write <= 1'b1;
                end
               
            // The following is for moving left
            else if(stateNum == 4'b0010)   
                begin
               
                    x[7:0] <= x - 8'b00000001;
                    colour <= acolour;
                    write <= 1'b1;
                end
               
            // The following is for moving down
            else if(stateNum == 4'b0011)
					 begin
						//	begin
//							if (y != 7'b1111000)
//								begin
						  
								  y[6:0] <= y + 6'b000001;
								  colour <= acolour;
								  write <= 1'b1;
//								end
//							else
//							      y[6:0] <= y;   
//									write <= 1'b0;
//							
//							end
                end
               
            else if(stateNum == 4'b1001)//for moving up
                begin
               
                    y[6:0] <= y - 7'b0000001;
                    colour <= acolour;
                    write <= 1'b1;
                end
               
            else if(stateNum == 4'b1000)//after drawing
                begin
                    write <= 1'b0;
                end
               
        end
    end
   
endmodule
   
   
module RateDividerForCar (clock, q, Clear_b, how_speedy);  // Note that car is 4 times faster than the player
    input [0:0] clock;
    input [0:0] Clear_b;
	 input [25:0] how_speedy;
    output reg [26:0] q; // declare q
    //wire [27:0] d; // declare d, not needed
    always@(posedge clock)   // triggered every time clock rises
    begin
    // else if (ParLoad == 1'b1) // Check if parallel load, not needed!!!!
    //        q <= d; // load d
        if (q == how_speedy) // when q is the maximum value for the counter, this number is 50 million - 1
            q <= 0; // q reset to 0
        else if (clock == 1'b1) // increment q only when Enable is 1
            q <= q + 1'b1;  // increment q
    //    q <= q - 1'b1;  // decrement q
    end
endmodule




// The hex display for showing the level of the player
module hex_display(IN, OUT1, OUT2);
   input [4:0] IN;
    output reg [7:0] OUT1, OUT2;
     always @(*)
     begin
        case(IN[4:0])
            5'b00000:
                begin
                    OUT1 = 7'b1000000;
                    OUT2 = 7'b1000000;
                end
            5'b00001:
                begin
                    OUT1 = 7'b1000000;
                    OUT2 = 7'b1111001;
                end
            5'b00010:
                begin
                    OUT1 = 7'b1000000;
                    OUT2 = 7'b0100100;
                end
            5'b00011:
                begin
                    OUT1 = 7'b1000000;
                    OUT2 = 7'b0110000;
                end
            5'b00100:
                begin
                    OUT1 = 7'b1000000;
                    OUT2 = 7'b0011001;
                end
            5'b00101:
                begin
                    OUT1 = 7'b1000000;
                    OUT2 = 7'b0010010;
                end
            5'b00110:
                begin
                    OUT1 = 7'b1000000;
                    OUT2 = 7'b0000010;
                end
            5'b00111:
                begin
                    OUT1 = 7'b1000000;
                    OUT2 = 7'b1111000;
                end
            5'b01000:
                begin
                    OUT1 = 7'b1000000;
                    OUT2 = 7'b0000000;
                end
            5'b01001:
                begin
                    OUT1 = 7'b1000000;
                    OUT2 = 7'b0011000;
                end
            5'b01010:
                begin
                    OUT1 = 7'b1111001;
                    OUT2 = 7'b1000000;
                end
            5'b01011:
                begin
                    OUT1 = 7'b1111001;
                    OUT2 = 7'b1111001;
                end
            5'b01100:
                begin
                    OUT1 = 7'b1111001;
                    OUT2 = 7'b0100100;
                end
            5'b01101:
                begin
                    OUT1 = 7'b1111001;
                    OUT2 = 7'b0110000;
                end
            5'b01110:
                begin
                    OUT1 = 7'b1111001;
                    OUT2 = 7'b0011001;
                end
            5'b01111:
                begin
                    OUT1 = 7'b1111001;
                    OUT2 = 7'b0010010;
                end
            5'b10000:
                begin
                    OUT1 = 7'b1111001;
                    OUT2 = 7'b0000010;
                end
            5'b10001:
                begin
                    OUT1 = 7'b1111001;
                    OUT2 = 7'b1111000;
                end
            5'b10010:
                begin
                    OUT1 = 7'b1111001;
                    OUT2 = 7'b0000000;
                end
            5'b10011:
                begin
                    OUT1 = 7'b1111001;
                    OUT2 = 7'b0011000;
                end
            5'b10100:
                begin
                    OUT1 = 7'b0100100;
                    OUT2 = 7'b1000000;
                end
            5'b10101:
                begin
                    OUT1 = 7'b0100100;
                    OUT2 = 7'b1111001;
                end
            5'b10110:
                begin
                    OUT1 = 7'b0100100;
                    OUT2 = 7'b0100100;
                end
            5'b10111:
                begin
                    OUT1 = 7'b0100100;
                    OUT2 = 7'b0110000;
                end
            5'b11000:
                begin
                    OUT1 = 7'b0100100;
                    OUT2 = 7'b0011001;
                end
            5'b11001:
                begin
                    OUT1 = 7'b0100100;
                    OUT2 = 7'b0010010;
                end
            5'b11010:
                begin
                    OUT1 = 7'b0100100;
                    OUT2 = 7'b0000010;
                end
            5'b11011:
                begin
                    OUT1 = 7'b0100100;
                    OUT2 = 7'b1111000;
                end
            5'b11100:
                begin
                    OUT1 = 7'b0100100;
                    OUT2 = 7'b0000000;
                end
            5'b11101:
                begin
                    OUT1 = 7'b0100100;
                    OUT2 = 7'b0011000;
                end
            5'b11110:
                begin
                    OUT1 = 7'b0110000;
                    OUT2 = 7'b1000000;
                end
            5'b11111:
                begin
                    OUT1 = 7'b0110000;
                    OUT2 = 7'b0100100;
                end
           
            default:
                begin
                    OUT1 = 7'b0110000;
                    OUT2 = 7'b1111111;
                end
        endcase

    end
endmodule



/* The following is the python code for testing generating random speeds  (edit mar 27) 
 
def testing(depth, A):
    if depth == 0:
        return A;
    else:
        A[1] = (A[0] + A[1])%3+1;
        A[2] = (A[1] + A[2])%3+1;
        A[3] = (A[2] + A[3])%3+1;
        A[4] = (A[3] + A[4])%3+1;
        A[5] = (A[4] + A[5])%3+1;
        A[6] = (A[5] + A[6])%3+1;
        A[7] = (A[6] + A[7])%3+1;
        A[8] = (A[7] + A[8])%3+1;
        A[9] = (A[8] + A[9])%3+1;
        A[10] = (A[9] + A[10])%3+1;
        A[11] = (A[10] + A[11])%3+1;
        A[12] = (A[11] + A[12])%3+1;
        return testing(depth - 1, A);
       
         
*/