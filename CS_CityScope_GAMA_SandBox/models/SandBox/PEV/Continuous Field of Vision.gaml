/**
* Name: fieldofvision
* Author: Arnaud Grignard
* Description: This model illustrate how to use the masked_by operator to compute the field of vision of an agent (with obtsacles)
* Tags: perception, spatial_computation, masked_by
*/

model fieldofvision

global {
	
	file obstacle_shapefile <- file("./MIT/Buildings.shp");
		
	//perception distance
	float perception_distance <- 40.0 parameter: true;
	
	//precision used for the masked_by operator (default value: 120): the higher the most accurate the perception will be, but it will require more computation
	int precision <- 120 parameter: true;
	
	int nb_pev <- 20 parameter: true;
	geometry shape <- envelope(obstacle_shapefile);
	
	//space where the agent can move.
	geometry free_space <- copy(shape);
	init {
		create obstacle from: obstacle_shapefile{//number:10{//
			free_space <- free_space - (shape + 2);
		}	
		create pev  number:nb_pev {
			location <- any_location_in(free_space);
		}
	}
}

species obstacle {
	aspect default {
		draw shape color: #gray border: #gray depth:15#m;
	}
}
species pev skills: [moving]{
	//zone of perception
	geometry perceived_area;
	
	//the target it wants to reach
	point target ;
	
	reflex move {
		if (target = nil ) {
			if (perceived_area = nil) {
				//if the agent has no target and if the perceived area is empty, it moves randomly inside the free_space
				do wander bounds: free_space;
			} else {
				//otherwise, it computes a new target inside the perceived_area (we intersect with the free_space to limit its proximity to obstacles).
				target <- any_location_in(perceived_area inter free_space);
			}
		} else {
			//if it has a target, it moves towards this target
			do goto target: target;
			
			//if it reaches its target, it sets it to nil (to choose a new target)
			if (location = target) {
				target <- nil;
			}
		}
	}
	//computation of the perceived area
	reflex update_perception {
		//the agent perceived a cone (with an amplitude of 60°) at a distance of  perception_distance (the intersection with the world shape is just to limit the perception to the world)
		perceived_area <- (cone(heading-30,heading+30) intersection world.shape) intersection circle(perception_distance); 
		
		//if the perceived area is not nil, we use the masked_by operator to compute the visible area from the perceived area according to the obstacles
		if (perceived_area != nil) {
			perceived_area <- perceived_area masked_by (obstacle,precision);
		}
	}
	
	aspect body {
		//draw triangle(10) rotate:90 + heading color: #black;
		draw obj_file("./MIT/pev.obj",-90::{1,0,0})  color:#gray size:10 rotate:heading;
	}
	aspect perception {
		if (perceived_area != nil) {
			draw perceived_area color: #gray;
			draw circle(1) at: target color: #darkgray;
		}
	}
}

experiment fieldofvision type: gui {
	float minimum_cycle_duration <- 0.05;
	output {
		display view type:opengl background:#black{
			species obstacle;
			//species pev aspect: perception transparency: 0.5;
			species pev aspect: body;
		}
		
		display FirstPerson  type:opengl camera_interaction:false camera_pos:{int(first(pev).location.x),int(first(pev).location.y),10} 
			camera_look_pos:{cos(first(pev).heading)*first(pev).speed+int(first(pev).location.x),
			sin(first(pev).heading)*first(pev).speed+int(first(pev).location.y),10} {
			species obstacle;
			//species pev aspect: perception transparency: 0.5;
			species pev aspect: body;
				
		}
		
		display ThirdPersonn  type:opengl camera_interaction:false camera_pos:{int(first(pev).location.x),int(first(pev).location.y),250} 
		camera_look_pos:{int(first(pev).location.x),(first(pev).location.y),0} camera_up_vector:{0.0,-1.0,0.0} {
			species obstacle;
			//species pev aspect: perception transparency: 0.5;
			species pev aspect: body;	
		}
		
		
	}
}
