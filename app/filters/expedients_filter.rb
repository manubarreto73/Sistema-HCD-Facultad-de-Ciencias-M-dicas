class ExpedientsFilter
  attr_reader :scope, :params

  def initialize(scope, params)
    @scope  = scope
    @params = params
    puts 'PARAMS'
    puts @params
  end

  def call
    # Tipo de expediente
    result = scope
    result = result.where('file_number ILIKE ?', "%#{@params[:file_number]}%") if @params[:file_number].present?
    result = result.where(destination_id: @params[:destination_id]) if @params[:destination_id].present?
    result = result.where(subject_id: @params[:subject_id]) if @params[:subject_id].present?
    result = result.where('date >= ?', @params[:from_date]) if @params[:from_date].present?
    result = result.where('date <= ?', @params[:to_date]) if @params[:to_date].present?

    result
  end
end
