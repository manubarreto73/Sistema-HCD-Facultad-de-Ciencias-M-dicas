class SubjectsController < ApplicationController
  before_action :set_subject, only: %i[edit update destroy modal_delete]

  def index
    paginator = Paginator.new(Subject.actives.order(:name), page: params[:page])
    @subjects = paginator.paginated
    @page = paginator.page
    @total_pages = paginator.total_pages
  end

  def new
    @subject = Subject.new
    render layout: false
  end

  def edit
    render layout: false
  end

  def create
    @subject = Subject.new(subject_params)

    if @subject.save
      paginator = Paginator.new(Subject.actives.order(:name), page: params[:page])
      @subjects = paginator.paginated
      @page = paginator.page
      @total_pages = paginator.total_pages
      respond_to do |format|
        flash[:notice] = 'Tema creado correctamente'
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
    if @subject.update(subject_params)
      respond_to do |format|
        flash[:notice] = 'Tema actualizado correctamente'
        format.turbo_stream
        format.html { redirect_to subjects_path, notice: 'Tema actualizado con éxito.' }
      end
    else
      respond_to do |format|
        format.turbo_stream { render :error_update }
        format.html { render :new, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @subject.logic_delete
    respond_to do |format|
      @page = params[:page].to_i
      paginator = Paginator.new(Subject.actives.order(:name), page: @page)
      @show_empty = Subject.actives.none?
      @subjects = paginator.paginated
      if @subjects.empty? && @page > 1
        @page -= 1
        paginator = Paginator.new(Subject.actives.order(:name), page: @page)
        @subjects = paginator.paginated
      end
      @page = paginator.page
      @total_pages = paginator.total_pages

      flash[:info] = 'Tema eliminado correctamente'
      format.turbo_stream
      format.html { redirect_to subjects_path, notice: 'Tema eliminado con éxito.' }
    end
  end

  def modal_delete
    @expedients_count = @subject.expedients.count
    @page = params[:page].to_i
    render layout: false
  end

  private

  def set_subject
    @subject = Subject.find(params[:id])
  end

  def subject_params
    params.require(:subject).permit(:name, :priority)
  end
end
