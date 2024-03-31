describe Document do
  context 'Punto 1' do
    it 'DLS correcto' do
      documento = Document.new do
        alumno nombre: "Matias", legajo: "123456-7" do
          telefono { "1234567890" }
          estado es_regular: true do
            finales_rendidos { 3 }
            materias_aprobadas { 5 }
          end
        end
      end
      tag = Tag.with_label('alumno')
               .with_attribute('nombre', 'Matias')
               .with_attribute('legajo', '123456-7')
               .with_child(
                 Tag.with_label('telefono')
                    .with_child('1234567890')
               )
               .with_child(
                 Tag.with_label('estado')
                    .with_attribute('es_regular', true)
                    .with_child(
                      Tag.with_label('finales_rendidos')
                         .with_child(3)
                    )
                    .with_child(
                      Tag.with_label('materias_aprobadas')
                         .with_child(5)
                    )
               )
      expect(documento.xml).to eq(tag.xml)
    end

    it 'DLS correcto 2' do
      documento = Document.new do
        alumno nombre: "Matias", legajo: "123456-7" do
          telefono numero: "123456"
          estado do
            finales_rendidos { 3 }
            materias_aprobadas { 5 }
          end
        end
      end

      tag = Tag.with_label('alumno')
               .with_attribute("nombre", "Matias")
               .with_attribute("legajo", "123456-7")
               .with_child(
                 Tag.with_label("telefono")
                    .with_attribute("numero", "123456")
               )
               .with_child(
                 Tag.with_label("estado")
                    .with_child(
                      Tag.with_label("finales_rendidos")
                         .with_child(3)
                    )
                    .with_child(
                      Tag.with_label("materias_aprobadas")
                         .with_child(5)
                    )
               )
      expect(documento.xml).to eq(tag.xml)
    end
  end
  context 'Punto 2' do
    describe 'Serialización manual vs automática de Alumno' do
      class AlumnoTest
        attr_reader :nombre, :legajo, :telefono
        attr_reader :estado

        def initialize(nombre, legajo, telefono, estado)
          @nombre = nombre
          @legajo = legajo
          @telefono = telefono
          @estado = estado
        end

      end
      class EstadoTest
        attr_reader :finales_rendidos, :materias_aprobadas, :es_regular
        def initialize(finales_rendidos, materias_aprobadas, es_regular)
          @finales_rendidos = finales_rendidos
          @es_regular = es_regular
          @materias_aprobadas = materias_aprobadas
        end
      end

      it 'Serialización manual vs automática de Alumno' do
        unEstado = EstadoTest.new(3, 5, true)
        unAlumno = AlumnoTest.new("Matias", "123456-8", "1234567890", unEstado)

        documento_manual = Document.new do
          alumnotest nombre: unAlumno.nombre, legajo: unAlumno.legajo, telefono: unAlumno.telefono do
            estado finales_rendidos: unAlumno.estado.finales_rendidos,
                   es_regular: unAlumno.estado.es_regular,
                   materias_aprobadas: unAlumno.estado.materias_aprobadas
          end
        end

        documento_automatico = Document.serialize(unAlumno)

        expect(documento_manual.xml).to eq(documento_automatico.xml)
      end
      it 'XML generado cumple el formato esperado' do
        unEstado = EstadoTest.new(3, 5, true)
        unAlumno = AlumnoTest.new("Matias", "123456-7", "1234567890", unEstado)
        documento = Document.serialize(unAlumno)

        xml_esperado = [
          '<alumnotest nombre="Matias" legajo="123456-7" telefono="1234567890">',
          "\t<estado finales_rendidos=3 es_regular=true materias_aprobadas=5/>",
          '</alumnotest>'
        ].join("\n")


        expect(documento.xml).to eq(xml_esperado)
      end
    end
  end
  context 'Punto 3' do
    describe '#ignore' do
      class AnnotationTestIgnore
        ✨Ignore✨
        attr_reader :with_reader
        attr_reader :normal, :delegated_ignore
        def initialize(with_reader, normal, without_reader, delegated_ignore)
          @with_reader = with_reader
          @without_reader = without_reader
          @private_attribute = "NO"
          @normal = normal
          @delegated_ignore = delegated_ignore
        end

        ✨Ignore✨
        def without_reader
          @without_reader
        end

      end

      ✨Ignore✨
      class AnnotationTestIgnore2
        attr_reader :normal
        def initialize(normal)
          @normal = normal
        end
      end

      it 'ignored elements should not be serialized' do
        type_test = AnnotationTestIgnore.new('with_reader', 'normal', 'without_reader',
                                             AnnotationTestIgnore2.new('normal_composed'))
        puts "Nombre clase: "+ type_test.class.name.to_s
        puts "Atributo simple con reader: "+ type_test.with_reader.to_s
        puts "Atributo complejo con reader: "+ type_test.delegated_ignore.to_s
        puts "Atributo complejo - atributo simple: "+ type_test.delegated_ignore.normal.to_s

        expect(Document.serialize(type_test).xml)
          .to eq "<annotationtestignore normal=\"normal\"/>"
      end
    end
    describe '#inline' do
      ✨Label✨("type")
      class ElementTop
        attr_reader :normal
        def initialize(normal, composite)
          @normal = normal
          @composite = composite
        end

        ✨Inline✨ { |elem| elem.word }
        def composite
          @composite
        end
      end

      ✨Label✨("composite")
      class ElementComposite
        attr_reader :word
        def initialize(normal)
          @word = normal
        end
      end

      it 'inline elements should be serialized as attributes' do
        type_test = ElementTop.new('normal', ElementComposite.new('papa'))
        expect(Document.serialize(type_test).xml)
          .to eq "<type normal=\"normal\" composite=\"papa\"/>"
      end
    end
    describe 'Serializacion arrays' do
      class DocumentTestArray2
        attr_reader :nombre, :hola, :chau

        def initialize(nombre)
          @nombre = nombre
          @hola = 3
          @chau = 3
        end
      end

      class DocumentTestArray
        attr_reader :edad, :hijos, :primogenito

        def initialize(edad, hijos = [])
          @primogenito = hijos.empty? ? nil : hijos[0]
          @edad = edad
          @hijos = hijos
        end
      end
      it 'Serializacion de arrays' do
        padre_new = DocumentTestArray.new(3, [DocumentTestArray2.new("Marcos"), DocumentTestArray2.new("Lucas"), DocumentTestArray2.new("Santiago")])
        document_serialize = Document.serialize(padre_new)
        expect(document_serialize.xml)
          .to eq "<documenttestarray edad=3>
                    <primogenito nombre=\"Marcos\" hola=3 chau=3/>
                    <documenttestarray2 nombre=\"Marcos\" hola=3 chau=3/>
                    <documenttestarray2 nombre=\"Lucas\" hola=3 chau=3/>
                    <documenttestarray2 nombre=\"Santiago\" hola=3 chau=3/>
                  </documenttestarray>"
      end
    end
  end
end
