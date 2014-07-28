class QuestionsController < ApplicationController
  include ImportCsv

  respond_to :html

  before_action :auth
  before_action :admin, except:  [:index, :show]
  before_action :set_title, only: [:index, :edit, :new, :show, :import_csv]
  before_action :set_question, only: [:show, :edit, :update, :destroy]

  layout proc{ |controller| controller.request.xhr? ? false : 'application' }

  # * GET /questions
  def index
    @questions = Question.search(params[:search], params[:page])
  end

  # * GET /questions/1
  def show
  end

  # * GET /questions/new
  def new
    @question = Question.new
  end

  # * GET /questions/1/edit
  def edit
  end

  # POST /questions
  def create
    @question = Question.new question_params
    @question.save
    respond_with @question, location: questions_url
  end

  # PUT /questions/1
  def update
    update_resource @question, question_params

    respond_with @question, location: questions_url
  end

  # DELETE /questions/1
  def destroy
    flash[:alert] = t 'questions.project_error' unless @question.destroy

    respond_with @question, location: questions_url
  end

  def import_csv
  end

  def admin
    unless @auth_user.admin?
      flash[:alert] = t 'users.admin_error'
      redirect_to questions_path
    end
  end

  private

    def set_question
      @question = Question.find(params[:id])
    end

    def question_params
      params.require(:question).permit(
        :dimension, :code, :question, :lock_version, answers_attributes: [
          :id, :category, :order, :clarification, :answer, :lock_version, :_destroy
        ]
      )
    end
  end
