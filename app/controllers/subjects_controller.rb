class SubjectsController < ApplicationController
  before_action :set_subject, only: %i[edit update destroy]

  def index
    @subjects = Subject.order(:name)
  end

  def new
    @subject = Subject.new
    render layout: false
  end

  def edit
    render layout: false
  end

  def create
    subject = Subject.new(subject_params)

    if subject.save
      @subjects = Subject.all.order(:name) # FIXME: podemos cambiar el criterio
      respond_to do |format|
        flash.now[:notice] = 'Tema creado correctamente'
        format.turbo_stream
        format.html { redirect_to subjects_path }
      end
    else
      render :new, layout: false, status: :unprocessable_entity
    end
  end

  def update
    respond_to do |format|
      if @subject.update(subject_params)
        format.turbo_stream
        format.html { redirect_to subjects_path, notice: 'Tema actualizado con éxito.' }
      else
        render :new, layout: false, status: :unprocessable_entity
      end
    end
  end

  def destroy
    @subject.destroy
    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to subjects_path, notice: 'Tema eliminado con éxito.' }
    end
  end

  private

  def set_subject
    @subject = Subject.find(params[:id])
  end

  def subject_params
    params.require(:subject).permit(:name, :priority)
  end
end
