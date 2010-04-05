class QuestionsController < ApplicationController
  before_filter :auth

  # * GET /questions
  # * GET /questions.xml
  def index
    @title = t :'questions.index_title'
    @questions = Question.paginate(
      :page => params[:page],
      :per_page => APP_LINES_PER_PAGE,
      :order => [
        "#{Question.table_name}.dimension ASC",
        "#{Question.table_name}.code ASC"
      ].join(', ')
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
    @question.destroy

    respond_to do |format|
      format.html { redirect_to(questions_url) }
      format.xml  { head :ok }
    end
  end
end