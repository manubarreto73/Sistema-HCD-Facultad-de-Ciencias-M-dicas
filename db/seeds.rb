# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end
Expedient.delete_all
DailyAgenda.delete_all
Subject.delete_all
Destination.delete_all

subjects_import = (1..30).map { |i| { name: "Tema #{i}", priority: rand(20) } }
Subject.create(subjects_import)

hcd = Destination.create(name: 'Honorable Consejo Directivo')
destinations_import = (1..30).map { |i| { name: "Destino #{i}", is_commission: [true, false].sample } }
Destination.create(destinations_import)

responsibles = ['Responsable 1', 'Responsable 2', 'Responsable 3', 'Responsable 4', 'Responsable 5']
details = ['Detalle ejemplo 1', 'Detalle ejemplo 2', 'Detalle ejemplo 3', 'Detalle ejemplo 4', 'Detalle ejemplo 5']
opinions = ['Dictamen 1', 'Dictamen 2', 'Dictamen 3', 'Dictamen 4', 'Dictamen 5']

expedients_import = (1..50).map do |i|
  random_past_date = (Time.now - rand(0..20).days).to_date
  {
    file_number: i,
    responsible: responsibles.sample,
    opinion: opinions.sample,
    detail: details.sample,
    creation_date: random_past_date,
    subject: Subject.all.sample,
    destination: Destination.all.sample
  }
end

Expedient.create(expedients_import)
Expedient.all.sample(10).each { |e| e.update(destination: hcd) }
