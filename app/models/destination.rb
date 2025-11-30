class Destination < ApplicationRecord
  validates :name, uniqueness: { message: 'El nombre ya existe' }
  validates :name, presence: { message: 'El nombre no puede estar vacío' }
  validates :name, length: { maximum: 30, message: 'El nombre del destino muy largo (máximo 30 carácteres)' }

  scope :active_first, -> { order(active: :desc) }
  scope :actives, -> { where(active: true) }

  has_many :expedients, dependent: :nullify


  def logic_delete
    expedients.update_all(destination_id: nil)
    update(active: false)
    update(name: "#{name}* [DELETED]")
  end
end
