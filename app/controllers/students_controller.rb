# frozen_string_literal: true

class StudentsController < ClassesController
  before_action :set_student

  def show; end

  private

  def set_student
    @student = @classe.students.find_by(ine: params[:id])
  end

  def set_classe
    @classe = Classe.find_by(id: params[:class_id])
  end
end
