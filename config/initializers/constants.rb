require 'prawn/measurement_extensions'

# Cantidad de filas a mostrar en los paginados
APP_LINES_PER_PAGE = 10
# Ruta a la carpeta pública
PUBLIC_PATH = File.join(Rails.root, 'public')
# Opciones por defecto para los PDFs
PDF_OPTIONS = {
  :page_size => 'A4',
  :page_layout => :portrait,
  # Margen T, R, B, L
  :margin => [20.mm, 15.mm, 20.mm, 20.mm]
}
# Tamaño de fuente normal en los PDFs
PDF_FONT_SIZE = 11
# Paises disponibles en el formulario
COUNTRIES = [
  :argentina,
  :brazil,
  :colombia,
  :spain,
  :mexico,
  :portugal,
  :panama,
  :other
]
# Titulación o grado académico más alto
DEGREES = [
  :doctor,
  :mastery,
  :university_degree,
  :short_cicle_university,
  :baccalaureate,
  :other
]
# Grado en la escuela
DEGREES_SCHOOL = [
  :first_year,
  :second_year,
  :third_year,
  :fourth_year,
  :fifth_year,
  :sixth_year,
  :seventh_year,
  :eighth_year,
  :ninth_year,
  :tenth_year,
  :eleventh_year,
  :twelfth_year,
  :thirteenth_year,
  :fourteenth_year,
  :fifteenth_year  
]
# Grado en la univesidad
DEGREES_UNIVERSITY = [
  :first_year,
  :second_year,
  :third_year,
  :fourth_year,
  :fifth_year,
  :sixth_year,
  :graduate,
  :master,
  :other  
]
# Géneros disponibles en el formulario
GENRES = [:male, :female]

# Tipos de grupos
GROUP_TYPES = [
  :control, 
  :experimental, 
  :test
]

# Profesiones disponibles en el formulario
PROFESSIONS = [:arts, :humanities, :social, :engineering, :science, :mix, :none]
# Estados del estudiante disponibles en el formulario
STUDENT_STATUSES = [
  :pre_university,
  :start_university,
  :end_university,
  :no_study
]
# Elección de materias de ciencias o tecnología
STUDY_SUBJECTS_CHOOSE = [
  :nothing_choose,
  :choose_study,
  :choose_part,
  :choose_all
]
# Estados del profesor disponibles en el formulario
TEACHER_STATUSES = [:in_training, :in_exercise, :not_a_teacher]
# Niveles de profesores disponibles en el formulario
TEACHER_LEVELS = [
  :primary,
  :junior_high,
  :job_training,
  :baccalaureate,
  :university,
  :other
]
# Adaptador de base de datos
DB_ADAPTER = ActiveRecord::Base.connection.adapter_name

URL_HOST = (
  Rails.env.development? ? 'localhost:3000' : 'mawida.com.ar'
).freeze