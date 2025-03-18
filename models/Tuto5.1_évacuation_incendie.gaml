/**
* Name: Tuto5EbwalaEbwalettePriscille
* Based on the internal empty template. 
* Author: Dell
* Tags: 
*/


model Tuto5_1_EbwalaEbwalettePriscille

/* Insert your model definition here */
global {
	
	//declarer les meubles a partir de shapefile(couche meubles)
	file meubles_shapefile <- file("../includes/batiment.shp");
	geometry shape <- envelope(meubles_shapefile);
	//declarer l’envirronement a partir de shape file(couche plateform)
	int environnement <- 200 parameter: 'envirronement' category: 'Environement';
	//declarer le nombre de feu unitial
	 int nbre_feu <- 15 parameter: 'Nombre de feux' category: 'Feu' min:1 max:20;
	 
	
 	geometry free_space;
	 
	//liste de point de meuble
	
	 point porte_1 <- {379, 174};
	 point porte_2 <- {2, 173};
	 point porte_3 <- {140,250};
	 point fenetre_1 <- {140,350};
	 point fenetre_2 <- {1,255};
	
	 list<point> sorties <- [{378, 175}, {1, 175}, {140,250}, {140,350}];
	//{140,1},{278,250}
	 init { 
		  
		  free_space <- copy(shape);
		  //Creation of the buildinds
		  create Meuble from: meubles_shapefile {
		   //Creation of the free space by removing the shape of the different buildings existing
		   free_space <- free_space - (shape + 10);
		  }
		  //Simplification of the free_space to remove sharp edges
		  free_space <- free_space simplification(1.0);
		 	 
		
	     list<Meuble> meubles <- Meuble where true;
		
		 
		 create Feu number:  nbre_feu {
		 	 location <- any_location_in (one_of(meubles));
		 }
		 
		 
		} 
	//condition d’arret
	
	reflex stop {
		//si les herbe sont grandis et prend toute la surface de erain,
		//if(count(herbes where(size>= taille_maximale)) = nombre_initial_herbes){
		int compteur_black<-0;
		loop element over:(list(MorceauImeuble))
		{
			if(element.couleur=#black){
				compteur_black<-compteur_black+1;
			}
		}
		if (compteur_black>=100) {	
			//alors arreter la simmulation
			do pause;
		}	
	}
}

species name: MorceauImeuble{
	rgb couleur <- #green;//couleurs
	float size <-10.0;
	aspect basic{
		
		 draw square(size) color: couleur;
		}
}
species name:Meuble{
	//taille -. Shape file
	rgb color <- #green;//couleurs
	float seuil_brulure <- 15.0;//le seuil(dureer d’etre bruller)
	list<point> elements_imeuble_location<-list_with(100,{0,0});
	list<float> compteur_brulure <- list_with(50,1.0);//liste de compteur d’etre bruller(on compte la durer qu’il est bruiller avec il est mort)
	float seuil_propagation <- 10.0;//le seuil de propager le feux avec le voisin (apres cette dureer il creer les voisin ,ce seuil   doit etre plus petit que le compteur a bruiller si non il peu pas propager )
	list<float> compteur_propagation <- [{0,0},{0,0},{0,0},{0,0}];//liste de compteur de propagation
	
	init {
		loop i from: 0 to: 99{
			point current_location<-any_location_in (self);
			create MorceauImeuble number: 1 {
		        location <- current_location;
			 }
			 
			 elements_imeuble_location[i]<-current_location;
		}
	}
	aspect basic{
		 draw shape color: color;
		}
	
	reflex bruller {
		//s’il y’a au moins un element dans la liste de compteur bruiller ayant valeur >0
		loop i over: compteur_brulure{
			
			int current_index<-compteur_brulure index_of i;
			if (i>0){
				compteur_brulure[current_index]<-compteur_brulure[current_index]+1;
				write compteur_brulure[current_index];
				
				if (compteur_brulure[current_index]>seuil_propagation){
					
					// Créer un feu dans une zone voisine
		            	MorceauImeuble imeuble_proche <- MorceauImeuble closest_to elements_imeuble_location[current_index];
				    	if(imeuble_proche!=nil){
				    		write imeuble_proche.couleur;
				    		if(imeuble_proche.couleur=#green)
				    		{
				    			create Feu number:1 {
							        location<-imeuble_proche.location;
							    }	
				    		}
				    		 
				    	}
				    	
					}
				
				if (compteur_brulure[current_index]>=seuil_brulure-1){
					
					MorceauImeuble imeuble_proche <- MorceauImeuble closest_to elements_imeuble_location[current_index];
					
					//MorceauImeuble agent_trouve <- first(agents_at( elements_imeuble_location[(compteur_brulure index_of i)]));
					
					if(imeuble_proche!=nil){
						Feu feu_proche <- Feu closest_to  elements_imeuble_location[current_index];
						
						if (feu_proche!=nil){
							
							ask feu_proche{
								self.couleur<-#black;
								do die;
								
							}
						}
						
						ask imeuble_proche{
							self.couleur<-#black;
							
						}
						
					}
					compteur_brulure[current_index]<--1;
					
				}
				
				
			}
			
		}

	}
}

species name:Feu {
	float taille <- 3.0;//taille;
	float rayon_propagation <- 15.0;//rayons_propagation
	float seuil_propagation <- 4.0;//seuil_propagation
	float compteur_propagation <- 0.0;//compteur_propagation
	rgb couleur <- #red;//seuil_creer_fume
	float compteur_creer_fume <- 0.0;//compteur_creer_fumee
	float seuil_creer_fume<- 3.0;
	float size<-1.5;
	
	aspect basic{
		draw circle(size) color: couleur;
	}
	
	reflex vivant{
		//augmenter le compteur de propagation
		compteur_propagation <- compteur_propagation + 1;
		 // Si cette valeur atteint le seuil de propagation
        if (compteur_propagation >= seuil_propagation) {
            // Recalculer le rayon de propagation (exemple : augmentation progressive)
            rayon_propagation <- rayon_propagation + 2.0;
            // Créer un feu dans une zone voisine
             agent proche <- one_of(agents_at_distance(rayon_propagation));
			 if(proche!=nil){
			 	
		    	 create Feu number:1 {
			        location<-proche.location;
			        size<-1.5;
			    }
		    }
            // Réinitialiser le compteur de propagation
            compteur_propagation <- 0;
        }
        
			// Augmenter le compteur de création de fumée
        	compteur_creer_fume <- compteur_creer_fume + 1;
        
			// Si cette valeur atteint le seuil de création de fumée
        	 if (compteur_creer_fume >= seuil_creer_fume) {
            	// Créer une fumée à sa position
            	create Fume number:5{
            		location<-myself.location;
            	}
            	// Réinitialiser le compteur de création de fumée
            	compteur_creer_fume <- 0;
        }
    }
    
   
}

species name: Fume skills:[moving] {
	float taille <- 3.0;//taille
	rgb color <- #gray;//couleur
	float vitesse <- 2.0;//vitesse de deplacement 
	float size<-0.5;
	
	aspect basic{
		draw circle(size) color: color;
	}
	
	reflex vivant{
		//deplacer par hasard
		do move;
		//direction priorite: le moins d’intansite de fume (pour y aller, evaculer ) 
//		if (location in shape) {
//		//il est mort quand il est hors de batiment
//			do die;
//		}
	}


}

experiment name type: gui {

	 float minimum_cycle_duration <- 0.04; 
	 output {
	  display map type: opengl {
	   species Meuble refresh: false;
	   species MorceauImeuble aspect: basic;
	   species Feu aspect: basic;
	   species Fume aspect: basic;
	   graphics "exit" refresh: false {
			    draw square(25) at: porte_1 color: #yellow; 
			    draw square(25) at: porte_2 color: #yellow;
			    draw square(25) at: porte_3 color: #yellow; 
			    draw square(15) at: fenetre_1 color: #yellow; 
			    draw square(15) at: fenetre_2 color: #yellow; 
			}
		}		
	}		
}
		


