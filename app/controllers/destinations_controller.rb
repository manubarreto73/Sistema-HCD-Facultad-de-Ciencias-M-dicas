class DestinationsController < ApplicationController
  before_action :set_destination, only: %i[edit update destroy modal_delete]

  def index
    paginator = Paginator.new(Destination.actives.order(:name), page: params[:page])
    @destinations = paginator.paginated
    @page = paginator.page
    @total_pages = paginator.total_pages
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
      paginator = Paginator.new(Destination.actives.order(:name), page: params[:page])
      @destinations = paginator.paginated
      @page = paginator.page
      @total_pages = paginator.total_pages

      respond_to do |format|
        flash[:notice] = 'Destino creado correctamente'
        format.turbo_stream
        format.html { redirect_to destinations_path }
      end
    else
      respond_to do |format|
        format.turbo_stream { render :error_create }
        format.html { render :new, status: :unprocessable_entity }
      end
    end
  end

  def update
    if @destination.update(destination_params)
      respond_to do |format|
        flash[:notice] = 'Destino actualizado correctamente'
        format.turbo_stream
        format.html { redirect_to destinations_path }
      end
    else
      respond_to do |format|
        format.turbo_stream { render :error_update }
        format.html { render :new, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @destination.logic_delete

    flash.now[:info] = 'Destino eliminado correctamente'

    @page = params[:page].to_i
    paginator = Paginator.new(Destination.actives.order(:name), page: @page)

    @show_empty = Destination.actives.none?
    @destinations = paginator.paginated
    if @destinations.empty? && @page > 1
      @page -= 1
      paginator = Paginator.new(Destination.actives.order(:name), page: @page)
      @destinations = paginator.paginated
    end
    @page = paginator.page
    @total_pages = paginator.total_pages
    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to destinations_path(page: @current_page), status: :see_other }
    end
  end

  def modal_delete
    @expedients_count = @destination.expedients.count
    @page = params[:page].to_i
    render layout: false
  end

  private

  def set_destination
    @destination = Destination.find(params[:id])
  end

  def destination_params
    params.require(:destination).permit(:name, :is_commission)
  end
end
