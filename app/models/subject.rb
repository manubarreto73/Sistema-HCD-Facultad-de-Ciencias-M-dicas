class Subject < ApplicationRecord
  validates :name, uniqueness: { message: 'El nombre ya existe' }
  validates :name, presence: { message: 'El nombre no puede estar vacío' }
  validates :name, length: { maximum: 30, message: 'El nombre del tema muy largo (máximo 30 carácteres)' }

  has_many :expedients, dependent: :nullify

  scope :actives, -> { where(active: true) }

  def logic_delete
    expedients.update_all(subject_id: nil)
    update(active: false)
    update(name: "#{name}* [DELETED]")
  end
end
