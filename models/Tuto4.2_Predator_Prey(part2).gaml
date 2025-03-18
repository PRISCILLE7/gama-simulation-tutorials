/**
* Name: Tuto42EbwalaEbwalettepriscille
* Based on the internal empty template. 
* Author: Dell
* Tags: 
*/


model Tuto42EbwalaEbwalettepriscille

/* Insert your model definition here */


global{//definir le nombre initial des herbes
	int taille_environnement <- 80 parameter: 'Width and Height' category: 'Environnment';
	int nbre_herbes <- 300 parameter:'nombre initieale des herbes'category:'herbes' min:300 max:1000;//creer les herbes aleatoire sur le terain
	int nbre_agneau <- 40 parameter: 'Nombre de agneau' category: 'Agneau' min:1 max:50;
	int nbre_loup <- 5 parameter: 'Nombre de loup' category: 'Loup' min:2 max:20;
	geometry shape <- envelope(square(taille_environnement));
	init {
		
		//creer les herbes aleatoire sur le terain
		create herbe number: nbre_herbes{
			//location <- {rnd(shape.width),rnd(shape.height)};
			set location <- {rnd(taille_environnement- 1.5*size)+size, rnd(taille_environnement-3*size)+ size};
		}
		
		//creer les agneau 
		create agneau number: nbre_agneau{
				set location <- {rnd(taille_environnement), rnd(taille_environnement)};
		} 
		//creer les loup  
		create loup number: nbre_loup{
			set location <- {rnd(taille_environnement), rnd(taille_environnement)};
		} 
	
	}
	reflex stop {
		//si les herbe sont grandis et prend toute la surface de erain,
		//if(count(herbes where(size>= taille_maximale)) = nombre_initial_herbes){
		list<point> total_herbe_area<-[];
		loop element over:(list(herbe))
		{
			
			total_herbe_area<-total_herbe_area+element.location;
			
		}
		if (length(total_herbe_area)>=(shape.width*shape.height)) {	
			//alors arreter la simmulation
			
			do pause;
		}	
	}

}

species name: herbe{
	float size <-rnd(2.0);//taille initiale de l'herbe
	rgb color <- #green;//la couleur #green ou vert
	float vitesse_grandir <- 0.3; //la vitesse de grandir(croissance) 
	float taille_neer_enfant  <- 5.0; //la taille a neer les enfants //comme la taille a etre manger par les agneaux egalement c'est la taille maximal
	int duree_neer_enfant <- 5; // je definie letemps avant qu'une nouvelle pousse(herbe) apparet
	int compteur <- 0; //compteur pour la reproduction
	float rayon_reproduction <- 1.0; // je definie ici le rayon de reproduction pour compter les voisin
	
	aspect basic{
		//dessiner sa forme avec la taille + la  couleurs
		draw square(size)color:color;
	}
	reflex grandir when: size < taille_neer_enfant//si la taille actuelle < la taille maximal
	{
		size <- size + vitesse_grandir;//augmenter la taille actuelle -> depend de la vitesse de grandir
		      
	}
	reflex neer_les_enfant when:size >= taille_neer_enfant //taille_neer_enfant //si la taille > la taille a neer_les_enfant
	{
		
		compteur <-compteur +1; //compteur le compte
		
		//si le compte >= duration a neer sun enfant ,alors:
		if(compteur >= duree_neer_enfant){
			write "naissance";
			list<herbe> voisin_proches <- (self neighbors_at (rayon_reproduction));
			write voisin_proches ;
			write length(voisin_proches);
			if( length(voisin_proches) < 8  ){
				create herbe number: 1{
						location<- location+1;
						//self.size<-0.5;
						self.size <-rnd(2.0);
			}

			}
			compteur <- 0;
		}
	}
}

species name: animal skills:[moving]{
	float size <- rnd(2.0);//taille initial
	float vitesse_deplacement <-1.0;//vitesse de deplacement 
	float vitesse_croissance <- 0.1;//vitesse croissance
	float vitesse_reproduction <-0.2;//vitesse de cree des enfants
	float rayon_observation <-5.0;//rayon d'observation
	float rayon_manger <-3.5;//rayons manger
	float rayon_alerte <-6.0;//rayon entendue pour entendre le son de ;l'alerte
	int age_actuel <- 0;//age actuel
	int age_maximal <-50;//age maximal
	int age_reproduction <-10;//age minimum pour creer des enfant
	float seuil_faim <- 50.0; // Seuil de faim (besoin énergétique)
	float etat_sante <- 20.0; // Santé initiale (%)
	float duree_faim <- 10.0; // Durée avant perte de santé due à la faim
	int compteur_reproduction<-0;
	float duree_reproduction<-5.0;//duree de creer enfant
	
	reflex vivant when:(age_actuel<age_maximal){
		age_actuel <-age_actuel +1;//augmente age_actuel,il vieilli
		//si age_actuel > age_maximal: mort
		if(age_actuel>age_maximal){
			do die;
		}
		etat_sante <- etat_sante -0.2;//la perte de sante progressif
		
		//diminuer la puissance //si la puissance < 0 :mort
		if(etat_sante <=0 ){
			do die;
		}
		//deplacer par hasard 
		do move;	
	}
		
	reflex creer_enfant when:(age_actuel >= age_reproduction) {	
			//augmenter le compteur
			compteur_reproduction <-compteur_reproduction + 1;
			//si le compteur >=duree_creer-enfant
			if(compteur_reproduction>= duree_reproduction){
				//creer un enfant  dont location a cote
				create self number: 1 {
					location <-myself.location +{1,1};
					size <-1;//la taille initial du nouveau-né
				}
					
				compteur_reproduction <- 0;//reinitialisation du compteutr
			}
		
	} 
	 
}

species name: agneau parent:animal{
	float taille_manger <- 5.0; // Taille minimale d'une herbe pour être mangée
	float gain_sante_manger <- 7.0; // Santé gagnée en mangeant
	float perte_sante_faim <- 2.0; // Perte de santé si faim
	float rayon_fuite <- 6.0; // Distance pour fuir un loup
	int montant_mangeable<-5;
	int size<-1;
	aspect basic {
		draw circle(size) color: #yellow; // L’agneau est représenté en jaune
	}
	
	reflex chercher_manger when:(etat_sante < seuil_faim) {
    	do wander amplitude: 400 speed: rnd(2.0);

    	// Chercher des herbes mangeables dans le rayon de manger
    	list<herbe> herbes_mangeables <- herbe where ((each distance_to self) <= rayon_manger);
		//	>= taille_manger
    	// Vérifier s'il y a des herbes disponibles
    	if (length(herbes_mangeables) > 0) {
    		
        	int compteur_herbe_manger <- 0;

        	loop  cible over: herbes_mangeables {
            	if (compteur_herbe_manger >= montant_mangeable) {
                	break;
            	}

	            // Manger l'herbe
	            cible.size <- cible.size - taille_manger;
	            self.size<-self.size+taille_manger/10;
	            etat_sante <- etat_sante + gain_sante_manger;
	            write "manger ==================================================";
	            write etat_sante;
	
	            // Si l’herbe est totalement mangée, elle disparaît
	            ask cible{
	            	if (self.size <= 0) {
	                	do die;
	            	}
	            }
	            compteur_herbe_manger <- compteur_herbe_manger + 1;
	        }
	   	 } else {
	       	 	// Aucune herbe mangeable, chercher une herbe proche
	        	write "Aucune herbe mangeable trouvée, déplacement vers une herbe";
	
	        	list<herbe> herbes_visibles <- herbe where (
	            	(self distance_to each) <= rayon_observation);
	
	       	 	if (length(herbes_visibles) > 0) {
	           		herbe herbe_cible <- first(sort_by(herbes_visibles, self distance_to each));
	
	            	if (herbe_cible != nil) {
	                	do goto target: herbe_cible;
	            }
	        } else {
	            	write "Aucune herbe visible dans le rayon d'observation, perte d'énergie.";
	        }
	
	        // L’agneau perd de la santé s’il ne trouve rien
	        etat_sante <- etat_sante - perte_sante_faim;
	        if(etat_sante<0){
	        	do die;
	        }
    	}
	}
	
			

    reflex eviter_alerter {
        // Détecter les loups dans le rayon d'observation
        let loups_proches <- (
				list(loup) 
					where(
						(self distance_to each) <=rayon_observation
						)
					
					sort_by (self distance_to each)
					);
        
        if (length(loups_proches) > 0) {
            write "Loup détecté ! Alerte envoyée !";

            // Alerter les autres agneaux proches
            // Vérifier s'il y a d'autres agneaux proches
	        let agneaux_proches <- (
					list(agneau) 
						where(
							(self distance_to each) <=rayon_alerte
							)
						
						sort_by (self distance_to each)
						);
	        
	        if (length(agneaux_proches) > 0) {
	            // Aller vers le groupe d’agneaux
	            let agneau_proche<-first(agneaux_proches);
	            do goto target: agneau_proche.location;
	        } else {
	            // Fuir dans la direction opposée à l’alerte (loin du loup)
	            do goto target:first(loups_proches).location+{rnd(5),rnd(5)} ;
	        }
            
        }
    }


}
	
species name: loup parent:animal{
	float taille_manger <- 5.0; // Quantité d'énergie gagnée en mangeant un agneau
    float perte_sante_faim <- 2.0; // Perte de santé si le loup ne mange pas
    float rayon_chasse <- 7.0; // Distance pour détecter les agneaux
    float rayon_communication <- 10.0; // Distance pour alerter les autres loups
    float temps_sans_manger<-0;
    int compteur_agneau_manger<-0;
    int montant_mangeable<-2;
    int gain_sante_manger<-3;
   
	aspect basic{
        draw circle(1.5) color: #red; // Le loup est représenté en rouge
    }
	

		reflex chercher_manger when:(etat_sante < seuil_faim) {
	    	do wander amplitude: 600 speed: 6.0;
	
	    	// Chercher des agneaux mangeables dans le rayon de manger
	    	list<agneau> agneaux_mangeables <- agneau where ((each distance_to self) <= rayon_chasse);
			//	>= taille_manger
	    	// Vérifier s'il y a des agneaux disponibles
	    	if (length(agneaux_mangeables) > 0) {
	    		//alerter les loups dans on rayon de communication
	    		let loups_proches <- (
						list(loup) 
							where(
								(self distance_to each) <=rayon_communication
								)
							
							sort_by (self distance_to each)
							);
				
				if (length(loups_proches) > 0) {
					loop loup_actuel over: loups_proches {
						ask loup_actuel{
							do goto target: first(agneaux_mangeables).location;
						}
					}
				} 
	    		
	        	int compteur_agneau_manger <- 0;
	        	loop  cible over: agneaux_mangeables {
	            	if (compteur_agneau_manger >= montant_mangeable) {
	                	break;
	            	}
	
		            // Manger l'agneau
		            cible.size <- cible.size - taille_manger;
		            self.size<-self.size+taille_manger/10;
		            etat_sante <- etat_sante + gain_sante_manger;
		            write "manger agneau ==================================================";
		            write etat_sante;
		
		            // Si l'agneau est totalement mangée, elle disparaît
		            ask cible{
		            	if (self.size <= 0) {
		                	do die;
		            	}
		            }
		            compteur_agneau_manger <- compteur_agneau_manger + 1;
		        }
		   	 } else {
		       	 	// Aucun agneau mangeable, chercher un agneau proche
		        	write "Aucun agneau mangeable trouvée, déplacement vers une agneau";
		
		        	list<agneau> agneaux_visibles <- agneau where (
		            	(self distance_to each) <= rayon_observation);
		
		       	 	if (length(agneaux_visibles) > 0) {
		           		agneau agneau_cible <- first(sort_by(agneaux_visibles, self distance_to each));
		
		            	if (agneau_cible != nil) {
		                	do goto target: agneau_cible;
		            }
		        } else {
		            	write "Aucun agneau visible dans le rayon d'observation, perte d'énergie.";
		        }
		
		        // Le loup perd de la santé s’il ne trouve rien
		        etat_sante <- etat_sante - perte_sante_faim;
	    	}
		}
}
	
experiment name type: gui {

	output {
	display 'herbe' {
			//
				species herbe  aspect: basic;
				species agneau aspect: basic;
				species loup aspect: basic;
				}
			}	
	}
	


