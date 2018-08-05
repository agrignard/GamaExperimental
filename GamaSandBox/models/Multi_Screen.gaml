model multiscreen

global {
 init{
 	create people number:100;
 }
}

species people{
	
	reflex t {location <- any_location_in(world);}
	aspect base{
		draw circle(1);
	}
}

experiment onescreen type:gui virtual:true{
	output{
		display CityScope type:opengl background:#black draw_env:false virtual:true{
        	species people aspect: base;
    	}	
	}
}
experiment multiscreen type: gui parent:onescreen{
	output {			
        display CityScopeScreen type:opengl parent:CityScope{}
		display CityScopeTable   type:opengl background:#black fullscreen:1 synchronized:true rotate:180{
			species people aspect: base;
		}
	}
}