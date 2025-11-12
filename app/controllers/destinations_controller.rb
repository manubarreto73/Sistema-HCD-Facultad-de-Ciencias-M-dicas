class DestinationsController < ApplicationController
  before_action :set_destination, only: %i[edit update destroy]

  def index
    @destinations = Destination.order(:name)
  end

  def new
    @destination = Destination.new
    render layout: false
  end

  def edit
    render layout: false
  end

  def create
    @destination = Destination.new(destination_params)

    if @destination.save
      @destinations = Destination.all.order(:name) # FIXME: podemos cambiar el criterio
      respond_to do |format|
        flash.now[:notice] = 'Destino creado correctamente'
        format.turbo_stream
        format.html { redirect_to destinations_path }
      end
    else
      render :new, layout: false, status: :unprocessable_entity
    end
  end

  def update
    respond_to do |format|
      if @destination.update(destination_params)
        format.turbo_stream
        format.html { redirect_to destinations_path, notice: 'Destino actualizado con éxito.' }
      else
        render :new, layout: false, status: :unprocessable_entity
      end
    end
  end

  def destroy
    @destination.destroy
    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to destinations_path, notice: 'Destino eliminado con éxito.' }
    end
  end

  private

  def set_destination
    @destination = Destination.find(params[:id])
  end

  def destination_params
    params.require(:destination).permit(:name, :is_commission)
  end
end
