module ApplicationHelper
  # Ordena un array que será utilizado en un select por el valor de los campos
  # que serán mostrados
  #
  # * _options_array_:: Arreglo con las opciones que se quieren ordenar
  def sort_options_array(options_array)
    options_array.sort { |o_1, o_2| o_1.first <=> o_2.first }
  end

  # Aplica la función textilize pero le quita el párrafo que la misma introduce
  def textilize_without_paragraph(text)
    textiled = textilize(text)
    textiled = textiled[3..-1] if textiled[0..2] == '<p>'
    textiled = textiled[0..-5] if textiled[-4..-1] == '</p>'

    textiled.html_safe
  end
end
