require_relative 'anexo'
require_relative 'annotations'
require_relative 'ClassObjectAnotable'
require_relative 'context'

$registro_annotations = []

module Serializable
  module_function

  def serialize(objeto)
    objeto_mapeado = mapear_objeto(objeto)


    if objeto_mapeado.nil?
      tag = Tag.new("")
    else
      tag = Tag.new(objeto_mapeado.class.get_nombre_clase.downcase)
    end

    obtener_atributos(objeto_mapeado).each do |variable|
      procesar_variable(objeto_mapeado, variable, tag, objeto_mapeado)
    end
    tag
  end

  def mapear_objeto(object)
    cloned_object = object.clone

    procesar_annotations(cloned_object)
  end

  private

  def procesar_variable(objeto, variable, tag, objeto_padre)
    label = variable.to_s[1..-1]

    return unless objeto.class.method_defined?(label)

    valor = get_value_from_object(objeto, variable)

    case valor
    when Numeric, TrueClass, FalseClass, NilClass, String
      if objeto_padre.is_a?(AtributoCustom)
        tag.with_child(valor)
      else
        tag.with_attribute(label, valor)
      end

    when Array
      valor.each do |elemento|
        elemento.class.set_nombre_clase(elemento.class.name.to_s)
        procesar_objeto(elemento,tag,elemento.class.name.to_s)
      end
    else
      valor.class.set_nombre_clase(label)
      procesar_objeto(valor,tag,label)
    end
  end

  def procesar_annotations (object)
    object.class.instance_variables.each do |var|
      value = object.class.instance_variable_get(var)
      next unless value.is_a?(Array)  #Porque hay intancias que no son listas de annotations.rb
      lista_ordenada = sort_prioridad(value)
      if son_de_clase(var, object.class.name)
        lista_ordenada.each do |annotation|
          resultado = annotation.ejecutar_annotation_clase(object)
          (return nil) if resultado.nil?
        end
      else
        lista_ordenada.each do |annotation|
          nombre_metodo = obtener_nombre(var)
          annotation.ejecutar_annotation_metodo(object, nombre_metodo)
        end
      end
    end
    object
  end
  def obtener_atributos(object)
    atributos = []
    object.instance_variables.each do |variable|
      atributos << variable unless (object.instance_variable_get(variable)).nil?
    end
    atributos
  end
  def get_value_from_object(object, variable)
      object.instance_variable_get(variable)
  end

  def son_de_clase(nombreLista, nombreClase)
    # Comprobar si nombreLista tiene el formato correcto
    formato_esperado = "@#{nombreClase}_annotations"

    nombreLista.to_s == formato_esperado
  end

  def sort_prioridad(lista_annotations)
    lista_annotations.sort do |a, b|
      b.instance_variable_get("@prioridad") <=> a.instance_variable_get("@prioridad")
    end
  end

  def obtener_nombre(texto)
    pattern = /@([^@]+)_annotations/
    match = texto.match(pattern)
    if match
      match[1]
    end
  end
  def procesar_objeto(objeto,tag,label)
    child_tag = serialize(objeto)
    return if child_tag.label.empty?

    if child_tag.children.empty? && child_tag.attributes.empty?
      tag.with_child(Tag.new(label)).with_attribute(label, objeto.to_s) # Convertir a string sin comillas adicionales
    else
      tag.with_child(child_tag)
    end
  end
  module_function :mapear_objeto,:procesar_objeto,:obtener_atributos, :sort_prioridad, :get_value_from_object, :procesar_variable, :procesar_annotations, :son_de_clase, :obtener_nombre
end
class Document
  extend Serializable
  def initialize(&block)
    @current_tag = Tagger.new.crear_tag(&block)
  end

  def self.serialize(object)
    doc = Document.new
    root_tag = Serializable.serialize(object)
    doc.instance_variable_set(:@current_tag, root_tag)
    #TODO: MEJORAR IGNORE DE OBJETO VACIO
    if doc.instance_variable_get("@current_tag").label.empty?
      return ""
    end
    doc
  end

  def xml
    @current_tag.xml
  end
end

class Tagger
  def crear_tag(&block)
    @ejecutar_method_missing = true
    tag = instance_eval(&block) if block_given?
    @ejecutar_method_missing = false
    tag
  end
  private

  def respond_to_missing?(name, include_private = false)
    if @ejecutar_method_missing
      true  # Activa method_missing solo cuando estamos dentro del bloque
    else
      super  # Deja que el comportamiento predeterminado maneje otros casos
    end
  end

  def method_missing(name, *args, &block)
    super unless @ejecutar_method_missing
    tag = Tag.new(name)
    if args.first.is_a? Hash
      tag.with_attributes(args.first)
    end

    if @current_tag.nil?
      @root = tag
    else
      @current_tag.with_child(tag)
    end

    prev_tag, @current_tag = @current_tag, tag

    value = block_given? ? instance_eval(&block) : nil

    if value.is_a?(String)
      tag.with_child(value)
    elsif value.is_a?(Numeric)
      tag.with_child(value)
    end

    @current_tag = prev_tag
    tag
  end

end



