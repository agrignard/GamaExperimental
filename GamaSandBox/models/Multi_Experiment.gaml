/**
* Name: Basic model
* Author: Arnaud Grignard
* Tags:
*/

model Tuto3D

global {
  int nb_cells <-100;	
  init { 
    create cells number: nb_cells { 
      location <- {rnd(100), rnd(100), rnd(100)};       
    } 
  }  
} 
  
species cells{                      
  aspect default {
    draw sphere(1) color:#blue;   
  }
}

experiment exp1  type: gui virtual:true{
  output {
    display View1 type:opengl {
      species cells;
    }
  }
}

experiment exp2  type: gui parent:exp1{
  output {
    display View2 type:opengl parent:View1 {
      species cells;
    }
  }
}