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
  :uruguay,
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
# Géneros disponibles en el formulario
GENRES = [:male, :female]
# Profesiones disponibles en el formulario
PROFESSIONS = [:arts, :humanities, :social, :engineering, :science, :mix, :none]
# Estados del estudiante disponibles en el formulario
STUDENT_STATUSES = [
  :pre_university,
  :start_university,
  :end_university,
  :no_study
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