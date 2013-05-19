require 'rdf'
require 'rdf-agraph'


URL_REPOSITORY="http://sembox:12!sembox@ec2-54-214-66-157.us-west-2.compute.amazonaws.com:10035/repositories/robino"
REPOSITORY=RDF::AllegroGraph::Repository.new(URL_REPOSITORY, :create => false)

#Fixation des schemas utilisés comme PREFIX
SCHEMA = RDF::Vocabulary.new("http://schema.org/")
SEMBOX = RDF::Vocabulary.new("http://sem-box.fr/")




#Requete qui ressort tous les ?s ayant comme ?p hasInstance, dans cette exemple on ressort tous les documents avec les items qui le compose
puts "Extraction des URI des documents et de leurs items correspondants"
@links=REPOSITORY.build_query do |q|
	q << [:document, SEMBOX.hasInstance, :item]
end.run.sort_by do |link|
	puts link.document+' |a pour item| '+link.item
end 

##########################################################################################
##########################################################################################
#On met dans des listes RDF séparées les items du document de la CFG en v1.0 et en V2.0
#On affiche les items qui sont communs, ajoutés, supprimés depuis entre la V2.0 et la V1.0

#definition des listes contenant les items
liste_items_V10=RDF::List.new
liste_items_V20=RDF::List.new

#Requete d'extraction pour la V1.0 de tous les items
puts 'Extraction des items de CFGMaquette en V1.0'
CFGMaquette10 = RDF::URI.new("http://sem-box.fr/doc/1.0/CFGMaquette")
@links=REPOSITORY.build_query do |q|
	q << [CFGMaquette10, SEMBOX.hasInstance, :item]
end.run.sort_by do |link|
	puts CFGMaquette10.to_s+' |a pour item| '+link.item
	liste_items_V10 << link.item
end 

#Requete d'extraction pour la V2.0 de tous les items
puts 'Extraction des items de CFGMaquette en V2.0'
CFGMaquette20 = RDF::URI.new("http://sem-box.fr/doc/2.0/CFGMaquette")
@links=REPOSITORY.build_query do |q|
	q << [CFGMaquette20, SEMBOX.hasInstance, :item]
end.run.sort_by do |link|
	puts CFGMaquette20.to_s+' |a pour item| '+link.item
	liste_items_V20 << link.item
end 


#Liste des items communs à V2.0 et V1.0

liste_comparaison=liste_items_V20 & liste_items_V10
puts 'Liste des items communs a V2.0 et V1.0'
liste_comparaison.each do |q| puts 'Communs'+' '+q.to_s end

#Liste des nouveaux items en V2.0 par rapport à la V1.0
liste_comparaison=liste_items_V20 - liste_items_V10
puts 'Liste des nouveaux items en V2.0 par rapport a la V1.0'
liste_comparaison.each do |q| puts 'Ajoutes'+' '+q.to_s end
#Liste des items supprimés en V2.0 par rapport à la V1.0
liste_comparaison=liste_items_V10 - liste_items_V20
puts 'Liste des items supprimes en V2.0 par rapport a la V1.0'
liste_comparaison.each do |q| puts 'Supprimes'+' '+q.to_s end


