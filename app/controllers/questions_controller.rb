# -*- coding: utf-8 -*-
class QuestionsController < ApplicationController
  before_filter :auth
  require 'csv'
  
  # * GET /questions
  # * GET /questions.xml
  def index
    @title = t :'questions.index_title'
    
    @questions = Question.order(
    [
      "#{Question.table_name}.dimension ASC",
      "#{Question.table_name}.code ASC"
    ].join(', ')
    ).paginate(
      :page => params[:page],
      :per_page => APP_LINES_PER_PAGE
    )
   
    respond_to do |format|
      format.html # index.html.erb
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
    @question = Question.new(params[:question])

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
      if @question.update_attributes(params[:question])
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

  def csv_import_questions
    if File.extname(params[:dump_questions][:file].original_filename).downcase == '.csv'
      @parsed_file=CSV::Reader.parse(params[:dump_questions][:file], delimiter = ';')
      n=0
      @parsed_file.each  do |row|
        q = Question.new
        q.dimension = row[0]
        q.code = row[1]
        q.question = row[2]
        if q.save
        n+=1
        end
      end
      flash.alert = t(:'questions.csv_import', :count => n)
    else
      flash.alert = t :'questions.error_file_extension'
    end
    respond_to do |format|
      format.html { redirect_to(questions_path) }
    end
  end

  def csv_import_answers
    if File.extname(params[:dump_answers][:file].original_filename).downcase == '.csv'    
      @parsed_file=CSV::Reader.parse(params[:dump_answers][:file], delimiter = ';')
      n=0
      @parsed_file.each  do |row|
        a = Answer.new
        a.category = row[1]
        a.order = row[2].to_i
        a.clarification = row[3].to_s
        a.answer = row[4]
        question = Question.find_by_code(row[0].to_s)      
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
      flash.alert = t(:'questions.answers.csv_import', :count => n)
    else
      flash.alert = t :'questions.error_file_extension'
    end
    respond_to do |format|
      format.html { redirect_to(questions_path) }
    end
  end


end
