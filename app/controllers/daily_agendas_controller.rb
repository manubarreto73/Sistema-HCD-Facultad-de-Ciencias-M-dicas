class DailyAgendasController < ApplicationController
  before_action :set_daily_agenda, only: %i[edit update resolve show]

  def index
    @year  = params[:year]&.to_i || Date.today.year
    @month = params[:month]&.to_i || Date.today.month

    date = Date.new(@year, @month)

    @prev_month = (date - 1.month).month
    @prev_year  = (date - 1.month).year

    @next_month = (date + 1.month).month
    @next_year  = (date + 1.month).year

    @daily_agendas = DailyAgenda.where(date: date.beginning_of_month..date.end_of_month).index_by(&:date)
    @days_agenda = build_calendar(date)
  end

  def today
    @daily_agenda = DailyAgenda.find_or_create_by(date: Date.today)
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
    redirect_to today_daily_agendas_path
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

    redirect_to today_daily_agendas_path
  end

  def update_params
    params.require(:daily_agenda).permit(:date)
  end

  private

  def set_daily_agenda
    @daily_agenda = DailyAgenda.find(params[:id])
  end

  def build_calendar(date)
    start_date = date.beginning_of_month.beginning_of_week(:monday)
    end_date = date.end_of_month.end_of_week(:monday)

    (start_date..end_date).to_a
  end
end
