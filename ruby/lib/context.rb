✨Label✨("estudiante")
class Alumno

  attr_reader :nombre, :legajo, :telefono
  ✨Label✨("situacion")   #TODO: IGNORE ANTES DE LABEL, NO ANDA(SIGUE MOSTRANDO EL ATRIBUTO)
  attr_reader :estado

  def initialize(nombre, legajo, telefono, estado)
    @nombre = nombre
    @legajo = legajo
    @telefono = telefono
    @estado = estado
  end

end

# ✨Custom✨ do |estado|
#   regular { estado.es_regular }
#   pendientes { estado.materias_aprobadas - estado.finales_rendidos }
# end

class Estado
  attr_reader :finales_rendidos, :materias_aprobadas, :es_regular
  def initialize(finales_rendidos, materias_aprobadas, es_regular)
    @finales_rendidos = finales_rendidos
    @es_regular = es_regular
    @materias_aprobadas = materias_aprobadas
  end
end


