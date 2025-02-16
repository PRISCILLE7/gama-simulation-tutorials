/**
* Name: tuto2EbwalaEbwalettePriscille
* Based on the internal empty template. 
* Author: Dell
* Tags: 
*/


model tuto2EbwalaEbwalettePriscille

/* Insert your model definition here */

global{// definir
    int taille_environement <- 100 parameter: 'longueur et largeur' category: 'Environnment';
	int N_nid <- 3 parameter: 'nombre de nids' min:1 max:5;// pour le nids je definie les nombre maximaum a 5
	int N_fourmis <- 100 parameter: 'nombre de fourmis' min:100 max:1000;
	int N_nourriture <- 3 parameter:'nombre de nourriture' min: 3 max:10;
	
	init{ 
		//creer les nids
		create nid number: N_nid{
			
		}
		
		loop i from: 1 to: N_fourmis{
			let tmpNid <- nid where true;
			write tmpNid;
			//creer les fourmis 
			create fourmis number:1 {////
				int j <- rnd(N_nid -1);
				nid tmpNid <- one_of(nid);
				set location <- tmpNid.location;
				set home <- tmpNid;
			}
		}
		
		// creer les nourritures
	
		create nouritures number: N_nourriture{
			
		}	
		
	}
	
	reflex conditionArrete{
			//s'il n'y'a plus de nouriture, alors:
	        if (length(list(nouritures))<=0){
	        	//arreter;
				do pause;
	        }
		}	
}
	
species name: nid{
	int size <- 5 + rnd(10);
	rgb color <- #gray;
	aspect basic {
		draw square(size) color: color;
	}
}
	
species name: marque{
	nouritures info <- nil;
	int size <- 0.2;
	rgb color <- #blue;
	int duration <- 50 +rnd(20);
	int count <- 0; //alors il est mort
	aspect basic {
		draw circle(size) color: color;
	}
	reflex vivant {
		//augmenter le compte 
		count <- count + 1;
		//si le compte >= duration;
		if(count>=duration){
			//alors: elle est morte
			do die;	
		}
	}
}

species name:nouritures {
	int size;// a revoir 
	rgb color <- #green ;
	int quantite <- 100 + rnd (100);
	
	aspect basic {
		size <- int(quantite/50);
		draw circle(int(quantite/50)) color: color;
	}
	reflex mort {
		//si quantite <=0 alors elle est mort
		if(quantite<=0){
			do die;
		}
	}
}
	
species name:fourmis skills:[moving]{
		int size <- 1 ;
		rgb color <- #red ;
		float speed <- 0.5+rnd(0.9); //change si possible
		float montant_amener <- 1 + rnd(5);
		float rayons_communication <- 1;
		float rayons_observation<- 1;
		nid home <- nil;
		nouritures but <- nil;
		bool change <- false; //false: main est vide ;true: avoir nourriture dans le main
		
		int creation_marque_duration <- 5;
		int creation_marque_count <- 0;
		
		 aspect basic {
		draw circle(size) color: color;
	}
		
		reflex chercheNouriture when : (but= nil){
			//deplacer par hasard
			do wander amplitude: speed;
			//observer les nouritures:
			let nourritures_proche <- first(list(nouritures)
					where(
						(self distance_to each) <=rayons_observation)
					sort_by (self distance_to each)
					);
				
			//s'il y'a des nourritures dans sa rayons_observation, alors :
			//mettre a jour le but pour cette nourriture;
			if(nourritures_proche!=nil)
			{
				self.but<-nourritures_proche;
				//changer de couleur
				if(self.location = self.but.location){
					self.color <- self.but.color;
				}
			}
			
			
		//observer les marques
		      let marque_proche <- 
		      first (list(marque) 
		        where(
		          (self distance_to each) <=rayons_observation)
		          sort_by (self distance_to each)
		      );
        	//s'il y'a des marques dans sa rayons_observation, alors:
          //mettre a jours le but par la marque infor;
          if(marque_proche!=nil)
          {
          	if(marque_proche.info!=nil)
          	{
          		self.but<-marque_proche.info;
          	}
            
            
          }
			//rencontre les autre
			let fourmis_proche value: 
			first (list(fourmis) 
				where(
					(self distance_to each) <=rayons_communication) where (each.but!=nil)
					sort_by (self distance_to each)
			);
			//s'il y'a des fourmis dans sa rayon d'observation, alors:
			//mettre a jour le but par le but de rencontre
			if(fourmis_proche!=nil)
			{
				self.but<-fourmis_proche.but;
			}
			
		}
		reflex amenerNouriture  when : (but!=nil){
			//laisse les marques:
			//augmenter creation_marque_count
			creation_marque_count <-  creation_marque_count +1;
				
				//si creation_marque_count >= creation_marque_duration
			if(creation_marque_count >= creation_marque_duration){
				//creer une marque:
				//de meme location avec lui
			    //de infor <- sa but
				create marque number:1{
					set location <- myself.location;
					set info <- myself.but; 
					}
			 
		        //re_initialiser la creation_marque_count
		         creation_marque_count <- 0;
			}
		
				
			//si le main est vide, alors;
			if(change=false){
				//aller vers le but;
				do goto target: self.but;
				//si le nouriture est dans sa region_observation, alors:
				if((self distance_to self.but)<= rayons_observation){
					self.color<-rgb ('green');
					//apport personnel diminue quantite de nouriture par son montant amener
					 if(!dead(but)){
					 	 but.quantite <- but.quantite - montant_amener;
					 }else{
					 	but<-nil;
					 	color<-#red;
					 }
					
					 
					 //changer etat de charge(la main n'est plus vide)
					 change<- true;
					 
				}	 	
			}
				
			// si la main n'est pas vide
			if(change= true){
				//alors: aller vers le home(nid)
				do goto target: home;
				//si le nid est dans sa region_observation, alors:
				if((self distance_to self.home)<= rayons_observation){
					//deposer la nouriture au nid
						self.color<-rgb ('red');
					//change l'etat de charge(les main est vide)
				       change<- false;
				}
					
			}
				
		}
		
		
	}
	
experiment name type: gui {

	output {
	display 'Fourmie' {
			//
				species fourmis aspect: basic;
				species nid aspect: basic;
				species nouritures aspect: basic;
				species marque aspect: basic;
			}

	}
}