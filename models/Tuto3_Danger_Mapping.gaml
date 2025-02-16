/**
* Name: Tuto3EbwalaEbwalettePriscille
* Based on the internal empty template. 
* Author: Dell
* Tags: 
*/


model Tuto3EbwalaEbwalettePriscille

/* Insert your model definition here */

global{//definir
	geometry background <- rectangle (100,100) ;
	int nbr_centre <-2 parameter:'nombre des centres de controle'category:'Centre de controle' min:1 max: 3;// les nombre de centre_control max 3 et min 1
	int nbr_point <- 10 parameter: 'nombre des points dangereux' category:'Point dangereux' min:10 max: 30;// nombre des point dangereux
	int nbr_robot <- 5 parameter: 'nombre de robots' category: 'Robot' min:1 max:10; // nombre des robots
	
	init {
		create centre_control  number: nbr_centre { //creer le centre de control
		
		}
	
		create point_danger number: nbr_point{//creer les point dangereux
		
		}
		
		create robot number: nbr_robot {//creer les robots
		    set location <- one_of (centre_control);
			set home <- one_of (centre_control);
			set zonevisited <- {0,0};
		}
	}
	
	reflex stop{
		//si le zonevisited de centre de control >= le zone de background:
		//arreter le system
		bool simulation_terminee <- true;
	    loop element over:(list(centre_control))
		{
			if(element.zonevisited!=nil)
			{
				if (element.zonevisited.area>=background.area) {
		            simulation_terminee <- false;
		            break;
		        }		
			}
			
		}
	    // Arrêter la simulation si aucun point central ne change
	    if (simulation_terminee) {
	        do pause;
	    }
	}
}

species name:centre_control{
	int size <- 4; // taille du centre de contrôle (modifiable selon le besoin)
	rgb color <- #green;
	geometry zonevisited <-[]; // Zone visitée du centre
	list<point_danger> listDanger <-[];// Liste des points dangereux du centre
	
	aspect basic{
		draw circle(size) color:color;
	}
}

species  name:point_danger{
	int size <- 5; // taille du point dangereux
	int danger_level <-3+rnd(5) ; // niveau de danger
	rgb color <- #yellow; 
	 
	// Définition des couleurs en fonction du niveau de danger,par defaut j'utilise yellow
    init {
        if (danger_level = 5) { color <- #red; }
        else if (danger_level = 4) { color <- #orange; }
        else if (danger_level = 3) { color <- #yellow; }
        else if (danger_level = 2) { color <- #blue; }
        else { color <- #gray; }
    }
	aspect basic{
		//5:red;4:orange;3:yellow 2:...
		draw square(size) color: color;
	}
}

species name:robot skills:[moving] {
	
	centre_control home <- nil;
	rgb color <- #blue;
	int size <- 3; //taille du robot
	float rayon_observation <- 20.0 + rnd(3); 
	float rayon_communication <- rayon_observation + rnd(10); 
	float speed <- 1+rnd(3.0);
	geometry zonevisited <- {0,0}; // Zone visitée par le robot
	list<point_danger> listDanger <-[];// Liste des points dangereux détectés
	
	aspect basic{
		draw triangle(size) color:color;
		draw zonevisited color: #gray;//draw les zones visitees avec la couleurs #gray;
	}
	
	reflex visiter when:(zonevisited.area< background.area){
		//activite 1
		//detecter les point non_visiter le plus proche de lui
		let point_disponibles <- background points_on rayon_observation;
		write point_disponibles;
		let point_non_visite_proche<-first(
				point_disponibles  
				where !in(each,listDanger )
				 sort_by (self distance_to each)
					);

		write point_non_visite_proche;
		do goto target: point_non_visite_proche;
		//activite 2
		//mettre a jour le zone visiter:
		zonevisited <- zonevisited + point_non_visite_proche ;
	
		//activite 3
		//s'il ya des point dangereux dans sa rayon_observation:
		let point_danger_proche <- first(
				list(point_danger) 
					where(
						(self distance_to each) <=rayon_observation
						)
					where !in(each,listDanger )  
					sort_by (self distance_to each)
					);
		
		if(point_danger_proche!=nil){
			//les ajouter dans la listDanger;
			listDanger <- listDanger + point_danger_proche;
		}
	
		//activite4
		//rencontrer les autres robots:
		let robot_proche <- 
			first (list(robot) 
				where(
					(self distance_to each) <=rayon_communication)
					sort_by (self distance_to each)
			);
		//s'il ya des robots dans sa rayon_observation
		if (robot_proche!=nil){
			//mettre a jour son zonevisited;
			zonevisited <- zonevisited + robot_proche.zonevisited;
			//mettre a jour son listDanger ;
			listDanger <- listDanger +robot_proche.listDanger;
		}
		
		//activite 5
		//communiquer au centre de control
		//si son centre de control est dans sa rayon_communication
		if(home != nil and (self distance_to home)<=rayon_communication){
			ask home{
				//mettre a jour le zonevisited et listDanger de centre de control
				zonevisited<-zonevisited+myself.zonevisited;
				listDanger <- listDanger +myself.listDanger;
			}
		}
				
	}
}

	
experiment name type: gui {

	output {
	display 'robot' {
			//
				species centre_control  aspect: basic;
				species point_danger aspect: basic;
				species robot aspect: basic;
				
			}

	}
}
	




