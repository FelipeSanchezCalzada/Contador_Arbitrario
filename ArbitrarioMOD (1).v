/*
Fecha de ultima modificacion: 7/1/2017 (Version 1)
Autor: Felipe Sanchez Calzada y Victor Rodriguez Mesonero

Aplicacion: Se trata de un contador hecho con Biestables JK que realiza una cuenta arbitraria: 8 2 11 7 14 1 4 8 4 15.

 
     Puertas:                 Precio aprox:
  9---AND dos entradas        3x 74LS21 = 3x 0.30 = 0.90€
  3---AND tres entradas       1x 74LS11 = 1x 0.34 = 0.34€
  6---OR dos entradas         2x 74LS32 = 2x 0.75 = 1.50€
  2---OR tres entradas        1x 74LS32 = 1x 0.75 = 0.75€
  4----JK                     2x 74LS112 = 2x 0.64 = 1.28€
-----------------------
  20 Puertas y 4 JK	            --- 4.77 € ---

Como las puertas de tres entradas existen en los circuitos integrados de la serie 74LSxxx, han sido contados como una puerta y no 1.5 puertas
*/

//-------------------------------------------------------------------------------------------------------------
//Modulo del biestable JK
module JKdown(output reg Q, output wire NQ, input wire J, input wire K,   input wire C);
  not(NQ,Q);

  initial
  begin
    Q=0;
  end    

  always @(posedge C)
    case ({J,K})
      2'b10: Q=1;
      2'b01: Q=0;
      2'b11: Q=~Q;
    endcase
endmodule

//-----------------------------------------------------------------
//Modulo del contador
module contador (output wire [3:0] Out, input wire C);

  wire [3:0] nQ;
  wire [3:0] Q;

//Cables de union de los OR a los JK
wire wJ0, wK0,wK1, wJ3;

//Cables de union de las AND a los OR
wire wq1nq0, wq2q3, wnq3q1, wq0nq2nq3;

//Cables de union de las AND a las OR en el circuito de cambio
wire wni2ni1ni0, wi1i0ni3, wi1ni0, wi2i1, wi3i1, wi0ni1, wi0i2, wi3i0;

//J del JK0
and q1nq0 (wq1nq0, Q[1], nQ[0]);
or J0 (wJ0, Q[2],  wq1nq0);

//K del JK1
and q2q3 (wq2q3, Q[2], Q[3]);
and q0nq2nq3 (wq0nq2nq3, Q[0], nQ[2], nQ[3]);
or K1 (wK1, wq2q3, wq0nq2nq3);

//K del JK0
and nq3q1 ( wnq3q1, nQ[3], Q[1]);
or K0 (wK0, Q[2], wnq3q1);

//J del JK3
or J3 (wJ3,  Q[1],  Q[2]);


//Los cuatro JK usados:
//JKdown(output reg Q, output wire NQ, input wire J, input wire K,  input wire C);
  JKdown jk0 (Q[0], nQ[0], wJ0  , wK0 , C);
  JKdown jk1 (Q[1], nQ[1], nQ[3], wK1 , C);
  JKdown jk2 (Q[2], nQ[2], Q[3] , Q[3], C);
  JKdown jk3 (Q[3], nQ[3], wJ3  , 1'b1, C);



//Circuito que cambia el 0 por el 8 y el 3 por el 4
//Out 3
and ni2ni1ni0 (wni2ni1ni0, nQ[2], nQ[1], nQ[0]);
or q3 (Out[3], Q[3], wni2ni1ni0);

//Out 2
and i1i0ni3 (wi1i0ni3, Q[1], Q[0], nQ[3]); 
or q2 (Out[2], wi1i0ni3, Q[2]);

//Out 1
and i1ni0 (wi1ni0, Q[1], nQ[0]);
and i2i1  (wi2i1,  Q[2], Q[1]);
and i3i1  (wi3i1,  Q[3], Q[1]);
or q1 (Out[1], wi1ni0, wi2i1, wi3i1);

//Out 0
and i0ni1 (wi0ni1, Q[0], nQ[1]);
and i0i2 (wi0i2, Q[0], Q[2]);
and i3i0 (wi3i0, Q[0], Q[3]);
or q0 (Out[0], wi0ni1, wi0i2, wi3i0);
//Final del circuito cambiador


endmodule

//--------------------------------------------------------------------------------------------
//Modulo de pruebas con GTKwave
module testGTKwave;
  reg C;
  wire [3:0] Q;
  contador contador01 (Q,C);

  always 
  begin
    #10 C=~C;
  end

  initial
  begin
    $dumpfile("prueba2.dmp");
    $dumpvars(2, contador01, Q);   
    C=0;
    #500 $finish;
  end
endmodule

//----------------------------------------------------------------------------------------------
//Modulo del test sin GTKwave
module test;
  reg C;
  wire [3:0] Q;
  contador contador01 (Q,C);

   always #10 C=~C;
  
  initial
    begin 
      $monitor($time,"		%d", Q);
	C=1;
	#10;


      #400 $finish;
    end

endmodule
