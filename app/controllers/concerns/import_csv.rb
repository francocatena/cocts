module ImportCsv
  require 'csv'

  def csv_import_questions
    if params[:dump_questions] && File.extname(params[:dump_questions][:file].original_filename).downcase == '.csv'
      uploaded_file = params[:dump_questions][:file]

      parse_file uploaded_file

      import_questions
    else
      flash[:alert] = t 'questions.error_file_extension'
    end
    respond_to do |format|
      format.html { redirect_to(questions_path) }
    end
  end

  def csv_import_answers
    if params[:dump_answers] && File.extname(params[:dump_answers][:file].original_filename).downcase == '.csv'
      uploaded_file = params[:dump_answers][:file]

      parse_file uploaded_file

      import_answers
    else
      flash[:alert] = t 'questions.error_file_extension'
    end
    respond_to do |format|
      format.html { redirect_to(questions_path) }
    end
  end

  private

    def parse_file file
      file_name = file.path.to_s
      text = File.read(
        file_name,
        { encoding: 'UTF-8',
          delimiter: ';'
        }
      )

      @parsed_file=CSV.parse(text, col_sep: ';')
    end

    def import_answers
      n=0
      @parsed_file.each do |row|
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

      flash[:notice] = t('questions.answers.csv_import', count: n)
    end

    def import_questions
      n=0
      @parsed_file.each do |row|
        q = Question.new
        q.dimension = row[0].to_i
        q.code = row[1]
        q.question = row[2]
        if q.save
          n+=1
        end
      end

      flash[:notice] = t('questions.csv_import', count: n)
    end
end
