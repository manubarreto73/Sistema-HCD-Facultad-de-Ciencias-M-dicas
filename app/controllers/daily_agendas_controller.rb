class DailyAgendasController < ApplicationController
  before_action :set_daily_agenda, only: %i[edit update resolve show download_pdf mark_as_treated_modal mark_expedient_as_treated modal_list]

  def index
    @year  = params[:year]&.to_i || Date.today.year
    @month = params[:month]&.to_i || Date.today.month

    date = Date.new(@year, @month)

    @prev_month = (date - 1.month).month
    @prev_year  = (date - 1.month).year

    @next_month = (date + 1.month).month
    @next_year  = (date + 1.month).year

    @daily_agendas = DailyAgenda.where(date: date.beginning_of_month..date.end_of_month).select(&:treated?).group_by(&:date)

    @days_agenda = build_calendar(date)
  end

  def today
    @daily_agenda = DailyAgenda.next_daily_agenda
    @daily_count = DailyAgenda.where(date: Date.today).count

    index_params = filter_params
    @expedients = ExpedientsFilter.new(@daily_agenda.expedients.includes(:destination, :subject), index_params).call

    @treated_count = @expedients.treated.count
    @no_treated_count = @expedients.no_treated.count

    @expedients =
      params[:treated].to_s == 'true' ? @expedients.treated.order(sort_order) : @expedients.no_treated.order(sort_order)

    paginator = Paginator.new(@expedients, page: params[:page])
    @daily_agenda_expedients = paginator.paginated
    @page = paginator.page
    @total_pages = paginator.total_pages
  end

  def edit
    render layout: false
  end

  def update
    if @daily_agenda.update(update_params)
      redirect_to today_daily_agendas_path
    else
      respond_to do |format|
        format.turbo_stream { render :error_update }
        format.html { redirect_to today_path }
      end
    end
  end

  def show
    render layout: false
  end

  def resolve
    @daily_agenda.solve
    flash[:notice] = 'La orden del día fue marcada como tratada correctamente'
    @daily_agenda = DailyAgenda.next_daily_agenda
    @daily_count = DailyAgenda.where(date: Date.today).count

    paginator = Paginator.new(@daily_agenda.expedients, page: params[:page])
    @daily_agenda_expedients = paginator.paginated
    @page = paginator.page
    @total_pages = paginator.total_pages
    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to today_path }
    end
  end

  def add_expedients
    @daily_agenda = DailyAgenda.find(params[:id])
    @expedients = Expedient.for_daily_agenda
    render layout: false
  end

  def attach_expedient
    @daily_agenda = DailyAgenda.find(params[:id])
    @expedients = Expedient.where(id: params[:expedient_ids])
    @daily_agenda.expedients << @expedients
    @expedients.update_all(daily_agenda_id: @daily_agenda.id)
    @treated_count = @daily_agenda.expedients.treated.count
    @no_treated_count = @daily_agenda.expedients.no_treated.count
    paginator = Paginator.new(@daily_agenda.expedients, page: params[:page])
    @daily_agenda_expedients = paginator.paginated
    @page = paginator.page
    @total_pages = paginator.total_pages
    respond_to do |format|
      flash[:notice] = "#{@expedients.count} expedientes agregado(s) correctamente"
      format.turbo_stream
      format.html { redirect_to today_daily_agendas_path }
    end
  end

  def download_pdf
    title = "Orden del día #{@daily_agenda.date}"
    respond_to do |format|
      format.pdf do
        render pdf: title, template: 'daily_agendas/daily_agenda_pdf'
      end
    end
  end

  def mark_as_treated_modal
    render layout: false
  end

  def mark_expedient_as_treated
    expedient = Expedient.find(params[:expedient_id])
    expedient.treated!
    expedient.update(treat_date: Date.today)

    flash[:notice] = "Expediente #{expedient.file_number} marcado como tratado"
    @expedients = @daily_agenda.expedients
    @treated_count = @expedients.treated.count
    @no_treated_count = @expedients.no_treated.count

    @expedients =
      params[:treated].to_s == 'true' ? @expedients.treated.order(sort_order) : @expedients.no_treated.order(sort_order)

    paginator = Paginator.new(@expedients, page: params[:page])
    @daily_agenda_expedients = paginator.paginated
    @page = paginator.page
    @total_pages = paginator.total_pages
    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to today_daily_agendas_path }
    end
  end

  def modal_list
    @daily_agendas = DailyAgenda.where(date: params[:date])
    render layout: false
  end

  private

  def update_params
    params.require(:daily_agenda).permit(:date)
  end

  def set_daily_agenda
    @daily_agenda = DailyAgenda.find(params[:id])
  end

  def build_calendar(date)
    start_date = date.beginning_of_month.beginning_of_week(:monday)
    end_date = date.end_of_month.end_of_week(:monday)

    (start_date..end_date).to_a
  end

  def filter_params
    params.permit(:file_number, :subject_id, :destination_id, :from_date, :to_date, :treated, :sort, :direction)
  end

  def sort_order
    column = params[:sort].presence || 'file_number'
    direction = params[:direction].presence || 'asc'
    "#{column} #{direction}"
  end
end
