# class Object
#   # def eliminar_todos_los_atributos
#   #   atributos = self.obtener_atributos
#   #
#   #   atributos.each do |unAtributo|
#   #     self.eliminar_atributo(unAtributo)
#   #   end
#   # end
# end

module Anotable
  def method_missing(name, *args, &block)
    if name.to_s =~ /^✨(.*)✨$/
      # Captura el contenido entre las estrellas
      # No ponemos respond to missing porque ya filtramos los errores con que el name tenga que ser el de una de las clases anotaciones
      nombre_clase = $1
      if Object.const_defined?(nombre_clase)
        anotacion = Object.const_get(nombre_clase)
        anotacion_instancia = anotacion.new(*args, &block)
        $registro_annotations << anotacion_instancia
      end
    else
      super
    end
  end
end

include Anotable
class Class
  include Anotable
  def method_added(method_name)
    if $registro_annotations != []
      variable_name = "@#{method_name}_annotations".to_sym
      self.instance_variable_set(variable_name,$registro_annotations)
      $registro_annotations = []
    end
    super
  end
  def inherited(subclass)
    variable_name = "@#{subclass.name}_annotations".to_sym
    subclass.instance_variable_set("@nombre_de_clase".to_sym, subclass.name)
    unless $registro_annotations.empty?
      subclass.instance_variable_set(variable_name, $registro_annotations)
      $registro_annotations = []
    end
  end
  def get_nombre_clase
    @nombre_de_clase
  end
  def set_nombre_clase(texto)
    @nombre_de_clase = texto
  end
end