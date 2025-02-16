/**
* Name: Tuto 1 Ebwalaebwalette Priscille
* Based on the internal empty template. 
* Author: ebwala priscille
* Tags: 
*/


model Tuto1EbwalaebwalettePriscille

/* Insert your model definition here */

global{
	//definition de la taille de l'enviromment.
	int taille_environment <- 100 parameter: 'Width and Height' category: 'Environnment';
	geometry shape <- envelope(square(taille_environment));
	//initialisation des parametres
	int N <- 10  parameter: 'point normaux' min:10 max:500;  //utiliser les parametre
	int K <- 2 parameter: 'points centraux' min:2 max:5;
	list couleurs <- [#red,#blue,#green,#yellow,#gray];
	
	init {
		loop i from: 0 to:( K -1){
			create point_central number: 1 {
				set color <- couleurs[i];
			}
		}
		create point_normal number: N {
			set central <- one_of (point_central);
		}
		
	}
	reflex arrete {
			// Vérifier si tous les points centraux ont cessé de changer
		    bool simulation_terminee <- true;
		    loop element over:(list(point_central))
			{
				if (element.change) {
		            simulation_terminee <- false;
		            break;
		        }	
			}
		    // Arrêter la simulation si aucun point central ne change
		    if (simulation_terminee) {
		        do pause;
		    }
		}
		
}	

experiment  tuto1 type: gui { 
		output{
			display "K_mean" {
				species point_central aspect: basic;
				species point_normal aspect: basic;
	     }
    }
  }


species point_normal {
	rgb color <- rgb('red');
	point_central central <- nil;
	int size <- 2;
	point_central centre<-nil;
	
	aspect basic{
		draw circle(size) color: color;
	}
	
   reflex Kmean {
	// Liste de tous les points centraux disponibles
    list<point_central> tous_les_centres <- list(point_central);

    //calculer les distances aux points centraux
    list<float> distances <- [];
    loop element over: tous_les_centres {
    		float distance_actuelle <- self.location distance_to element.location;
            distances <- distances + distance_actuelle;
        }
    //detecter le points central le plus proche
    int index_plus_proche<- index_of (distances ,first (distances sort_by (each)));
    point_central centre_proche <- tous_les_centres[index_plus_proche];
	
	//mettre a jour:
	if(centre_proche!=nil){
		 centre <- centre_proche; // Mise à jour du point central //cette point;
		 self.color <- centre_proche.color; // Mise à jour du point central // cette point. color;	   
	}
}

}
species point_central{
	rgb color<- rgb("blue") ;
	int size <-	 5;
	bool change <- true;
	
	aspect basic{
	draw square(size) color: color;
	}
	reflex kmean{
		//lister toutes les points  agent de meme couleurs avec lui
		list<point_normal> points_associes <- list(point_normal) where (each.color = self.color);
		//calculer la moyenne position de toutes
		int nombre_points_associes <- length(points_associes);
		point totalLocation<-{0,0};
		point moyenne_location ;
		
		loop element over:(points_associes)
		{
			totalLocation<-totalLocation+element.location;	
		}
		
		if(nombre_points_associes>0){
			moyenne_location <-(totalLocation/nombre_points_associes);
			
			//mettre a jours sa position vers cette possition
			if(self.location!=moyenne_location){
				self.location<-moyenne_location;
			}else{
				//si n'y a pas de changement :
				change <- false;
			}
		}
	  }
}