class ExpedientsController < ApplicationController
  before_action :set_expedient, only: %i[edit show update destroy treat_from_agenda delete_from_agenda mark_as_treated_modal modal_delete history]

  def index
    index_params = filter_params
    @expedients = ExpedientsFilter.new(Expedient.includes(:destination, :subject).all, index_params).call

    @treated_count = @expedients.treated.count
    @no_treated_count = @expedients.no_treated.count

    @expedients =
      params[:treated].to_s == 'true' ? @expedients.treated : @expedients.no_treated
    paginator = Paginator.new(@expedients.order(sort_order), page: params[:page])
    @expedients = paginator.paginated
    @page = paginator.page
    @total_pages = paginator.total_pages
  end

  def new
    @expedient = Expedient.new
    render layout: false
  end

  def show
    @expedient = Expedient.find(params[:id])
    render layout: false
  end

  def edit
    render layout: false
  end

  def create
    @expedient = Expedient.new(expedient_params)
    if @expedient.save
      @expedient.create_history(current_user)

      paginator = Paginator.new(Expedient.order(:file_number), page: params[:page])
      @expedients = paginator.paginated
      @page = paginator.page
      @total_pages = paginator.total_pages
      respond_to do |format|
        flash[:notice] = 'Expediente creado correctamente'
        format.turbo_stream
        format.html { redirect_to expedients_path }
      end
    else
      respond_to do |format|
        format.turbo_stream { render :error_create }
        format.html { render :new, status: :unprocessable_entity }
      end
    end
  end

  def update
    if @expedient.update(expedient_params)
      @expedient.modify_history(current_user)
      respond_to do |format|
        flash[:notice] = 'Expediente actualizado correctamente'
        format.turbo_stream
        format.html { redirect_to expedients_path }
      end
    else
      respond_to do |format|
        format.turbo_stream { render :error_update }
        format.html { render :new, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @expedient.deleted!
    @page = params[:page].to_i
    @expedient = nil
    flash.now[:info] = "Expediente eliminado correctamente"
    @expedients = ExpedientsFilter.new(Expedient.includes(:destination, :subject).all, filter_params).call

    @treated_count = @expedients.treated.count
    @no_treated_count = @expedients.no_treated.count

    @expedients =
      params[:treated].to_s == 'true' ? @expedients.treated : @expedients.no_treated
    paginator = Paginator.new(@expedients.order(sort_order), page: @page)
    @expedients = paginator.paginated
    if @expedients.empty? && @page > 1
      @page -= 1
      paginator = Paginator.new(@expedients.order(sort_order), page: @page)
      @expedients = paginator.paginated
    end
    @page = paginator.page
    @total_pages = paginator.total_pages
    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to expedients_path }
    end
  end

  def treat_from_agenda
    @expedient.treated!
    @expedient.update(treat_date: Date.today)

    flash.now[:notice] = "Expediente #{@expedient.file_number} marcado como tratado."
    index_params = filter_params
    @daily_agenda = @expedient.daily_agenda
    @expedients = ExpedientsFilter.new(@daily_agenda.expedients.includes(:destination, :subject), index_params).call

    @treated_count = @expedients.treated.count
    @no_treated_count = @expedients.no_treated.count

    @expedients =
      params[:treated].to_s == 'true' ? @expedients.treated.order(sort_order) : @expedients.no_treated.order(sort_order)
    paginator = Paginator.new(@expedients, page: params[:page])
    @daily_agenda_expedients = paginator.paginated
    @page = paginator.page
    @total_pages = paginator.total_pages
    puts "Expedientes despues del treat: #{@expedients}"
    respond_to do |format|
      format.turbo_stream
      format.html { render :new }
    end
  end

  def delete_from_agenda
    @expedient.update(daily_agenda_id: nil)
    flash.now[:notice] = "Expediente #{@expedient.file_number} eliminado de la orden del día."

    respond_to do |format|
      format.turbo_stream
      format.html { render :new }
    end
  end

  def modal_delete
    @page = params[:page]
    render layout: false
  end

  def download_pdf
    treated = params[:treated] == 'true'
    @expedients = Expedient.where(treated: treated)
    title = treated ? 'Expedientes tratados' : 'Expedientes no tratados'
    respond_to do |format|
      format.pdf do
        render pdf: title, template: 'expedients/expedients_pdf'
      end
    end
  end

  def mark_as_treated_modal
    render layout: false
  end

  def history
    puts 'hola?'
  end

  private

  def set_expedient
    @expedient = Expedient.find(params[:id])
  end

  def expedient_params
    p = params.require(:expedient).permit(:dependency, :file_digits, :file_year, :correspondence, :responsible, :detail, :opinion, :creation_date,:destination_id, :subject_id)
    p[:file_number] = "#{p.delete(:dependency)}-#{p.delete(:file_digits)}/#{p.delete(:file_year)}-#{p.delete(:correspondence)}"

    p
  end

  def filter_params
    params.permit(:file_number, :subject_id, :destination_id, :from_date, :to_date, :treated, :sort, :direction, :page)
  end

  def sort_order
    column = params[:sort].presence || 'file_number'
    direction = params[:direction].presence || 'asc'
    "#{column} #{direction}"
  end
end
