# -*- coding: utf-8 -*-
class QuestionsController < ApplicationController
  before_action :auth
  before_action :admin, :except => [:index, :show]
  require 'csv'

  layout proc{ |controller| controller.request.xhr? ? false : 'application' }

  # * GET /questions
  # * GET /questions.xml
  def index
    @title = t :'questions.index_title'
    @questions = Question.search(params[:search], params[:page])

    respond_to do |format|
      format.html # index.html.erb
      format.js
      format.xml  { render :xml => @questions }
    end
  end

  # * GET /questions/1
  # * GET /questions/1.xml
  def show
    @title = t :'questions.show_title'
    @question = Question.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @question }
    end
  end

  # * GET /questions/new
  # * GET /questions/new.xml
  def new
    @title = t :'questions.new_title'
    @question = Question.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @question }
    end
  end

  # * GET /questions/1/edit
  def edit
    @title = t :'questions.edit_title'
    @question = Question.find(params[:id])
  end

  # POST /questions
  # POST /questions.xml
  def create
    @title = t :'questions.new_title'
    @question = Question.new(question_params)

    respond_to do |format|
      if @question.save
        flash[:notice] = t :'questions.correctly_created'
        format.html { redirect_to(questions_path) }
        format.xml  { render :xml => @question, :status => :created, :location => @question }
      else
        format.html { render :action => :new }
        format.xml  { render :xml => @question.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /questions/1
  # PUT /questions/1.xml
  def update
    @title = t :'questions.edit_title'
    @question = Question.find(params[:id])

    respond_to do |format|
      if @question.update_attributes(question_params)
        flash[:notice] = t :'questions.correctly_updated'
        format.html { redirect_to(questions_path) }
        format.xml  { head :ok }
      else
        format.html { render :action => :edit }
        format.xml  { render :xml => @question.errors, :status => :unprocessable_entity }
      end
    end

  rescue ActiveRecord::StaleObjectError
    flash[:alert] = t :'questions.stale_object_error'
    redirect_to edit_question_path(@question)
  end

  # DELETE /questions/1
  # DELETE /questions/1.xml
  def destroy
    @question = Question.find(params[:id])
    unless @question.destroy
      flash[:alert] = t :'questions.project_error'
    end
    respond_to do |format|
      format.html { redirect_to(questions_url) }
      format.xml  { head :ok }
    end
  end

  def import_csv
  end

  def admin
    unless @auth_user.admin?
      flash[:alert] = t :'users.admin_error'
      redirect_to questions_path
    end
  end

  def csv_import_questions
    if params[:dump_questions] && File.extname(params[:dump_questions][:file].original_filename).downcase == '.csv'
      uploaded_file = params[:dump_questions][:file]
      file_name = uploaded_file.path.to_s
      text = File.read(
        file_name,
        { :encoding => 'UTF-8',
          :delimiter => ';'
        }
      )

      @parsed_file=CSV.parse(text, :col_sep => ';')
      n=0
      @parsed_file.each  do |row|
        q = Question.new
        q.dimension = row[0].to_i
        q.code = row[1]
        q.question = row[2]
        if q.save
          n+=1
        end
      end
      flash[:notice] = t(:'questions.csv_import', :count => n)
    else
      flash[:alert] = t :'questions.error_file_extension'
    end
    respond_to do |format|
      format.html { redirect_to(questions_path) }
    end
  end

  def csv_import_answers
    if params[:dump_answers] && File.extname(params[:dump_answers][:file].original_filename).downcase == '.csv'
      uploaded_file = params[:dump_answers][:file]
      file_name = uploaded_file.path.to_s
      text = File.read(
        file_name,
        { :encoding => 'UTF-8',
          :delimiter => ';'
        }
      )

      @parsed_file=CSV.parse(text, :col_sep => ';')
      n=0
      @parsed_file.each  do |row|
        a = Answer.new
        category = row[1]
        if category == 'A'
          category = 2
        elsif category == 'P'
          category = 1
        elsif category == 'I'
          category = 0
        end
        a.category = category
        a.order = row[2].to_i
        a.clarification = row[4]
        a.answer = row[5]
        question = Question.find_by_code(row[0])
        unless question.blank?
          a.question_id = question.id
        end
        if a.save
          n+=1
        end
        unless question.blank?
          question.answers << a
        end
      end
      flash[:notice] = t(:'questions.answers.csv_import', :count => n)
    else
      flash[:alert] = t :'questions.error_file_extension'
    end
    respond_to do |format|
      format.html { redirect_to(questions_path) }
    end
  end

  private

  def question_params
    params.require(:question).permit(
      :dimension, :code, :question, :lock_version, answers_attributes: [
        :id, :category, :order, :clarification, :answer, :lock_version, :_destroy
      ]
    )
  end
end
