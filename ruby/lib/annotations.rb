class Anotacion
  def initialize(*args, &block)
    @args = args
    @block = block
    @prioridad = 2
  end
  def args
    @args
  end
  def definir_getter(objeto,simbolo,value)
    objeto.class.define_method(simbolo) do
      value
    end
  end
end

class Label < Anotacion
  def initialize(*args, &block)
    validate_args(args,&block)
    super
  end
  def ejecutar_annotation_clase(objeto)
    #Si el label esta en la clase
    objeto.class.set_nombre_clase(args.first)
    objeto
  end

  def ejecutar_annotation_metodo(objeto, firma_metodo)
    objeto.instance_variables.each do |var|
        if var.to_s[1..-1] == firma_metodo

          objeto.instance_variable_set("@#{@args.first}",  objeto.instance_variable_get(var))
          objeto.instance_variable_set(var,nil)

          objeto.class.define_method(@args.first.to_s) do
            instance_variable_get("@#{@args.first}")
          end
        end
      end

    objeto
  end
  private
  def validate_args(argumentos, &block)
    if argumentos.size != 1 || !block.nil?
      raise NotImplementedError, "Label precisa un argumento y no hay que pasarle un bloque"
    end
  end
end


class Ignore < Anotacion    #TODO cuando el estado esta dentro de alumno, le pone a alumno un tag estado
  def initialize(*args, &block)
    validate_args(args,&block)
    super
  end

  def ejecutar_annotation_clase(objeto)
    nil
  end

  def ejecutar_annotation_metodo(objeto,firma_metodo)
    puts objeto.to_s
    puts firma_metodo.to_s
    eliminar_atributo(objeto,firma_metodo)
  end

  private
  def eliminar_atributo(objeto,atributo)
    objeto.instance_variable_set("@#{atributo}", nil)
  end

  def validate_args(argumentos,&block)
    if !argumentos.empty? || !block.nil?
      raise NotImplementedError, "Ignore precisa no tener argumentos y no hay que pasarle un bloque"
    end
  end
end

class Inline < Anotacion
  def initialize (*args, &block)
    validate_args(args,&block)
    @args = args
    @block = block
    @prioridad = 3
  end

  def ejecutar_annotation_clase(objeto)
    raise "No se puede poner una annotation del tipo Inline en una clase."
  end

  def ejecutar_annotation_metodo(objeto, firma_metodo)
    valor = objeto.send(firma_metodo)
    nuevo_valor = @block.call(valor)
    unless [String, Numeric, TrueClass, FalseClass, NilClass].include?(nuevo_valor.class)
      raise "El valor retornado por el bloque en la anotación Inline no es representable como un atributo"
    end
    objeto.instance_variable_set("@#{firma_metodo}", nuevo_valor)
  end

  private
  def validate_args(argumentos,&block)
    if argumentos.size != 0 || block.nil?
      raise NotImplementedError, "Inline precisa no tener argumentos y hay que pasarle un bloque"
    end
  end
end


class AtributoCustom
end


class Custom < Anotacion

  def initialize (*args, &block)
    validate_args(args,&block)
    @args = args
    @block = block
    @prioridad = 1
    @custom_mappings = {}
    @objeto_guardado = nil
  end

  def ejecutar_annotation_clase(objeto)
    @objeto_guardado = objeto

    @ejecutar_method_missing = true
    instance_exec(objeto,&@block)
    @ejecutar_method_missing = false

    vaciar_objeto(objeto)
    @custom_mappings.each do |k,v|
      anotacion_atributo = AtributoCustom.new
      anotacion_atributo.instance_variable_set("@#{k}",v)
      definir_getter(anotacion_atributo, k,v)
      objeto.instance_variable_set("@#{k}", anotacion_atributo)
      definir_getter(objeto, k,v)
    end
    objeto
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

    @custom_mappings[name.to_s] = block.call(@objeto_guardado)
  end

  def vaciar_objeto(object)
    object.instance_variables.each do |v|
      object.instance_variable_set(v,nil)
    end
  end

  def validate_args(argumentos,&block)
    if !argumentos.first.empty? || block.nil?
      raise NotImplementedError, "Custom precisa no tener argumentos y hay que pasarle un bloque"
    end
  end
end

