# TAD Printer: TADP (Advanced Programming Techniques) - 2023 - 2C - TP Metaprogramming

This repository contains the final project for the TADP course (Advanced Programming Techniques) conducted in the second term of 2023. The project focuses on metaprogramming techniques implemented in Ruby to develop a framework for facilitating object rendering or serialization.

## Assignment Prompt

The assignment prompt can be found in the following document:
[TADP - 2023 C2 - TP Metaprogramación Grupal.pdf](https://github.com/SimonMirleni/TADPrinter/files/14813681/TADP.-.2023.C2.-.TP.Metaprogramacion.Grupal.pdf).
Please refer to this document for detailed instructions, requirements and various use cases for the project.

## Domain Description

The project aims to develop a framework in Ruby to facilitate the rendering (or serialization) of objects. Initially, the project extends the language syntax to support a DSL (Domain Specific Language) for declaratively describing XML. Subsequently, the process is automated to enable serialization of any object without detailing how, and finally, this automation is made customizable using metadata.

## Group Submission
This project was developed as a group submission for the TADP course. The development team consisted of Simón Pedro Mirleni and Gabriel Damian Montenegro.

## Project Objectives

The project aims to implement the following functionalities:

1. **DSL and Printing:** Develop the necessary code to support the definition of XML using a DSL. The XML consists of tags with labels and attributes, capable of containing child tags.

2. **Automatic Generation:** Automate the serialization process to provide a reasonable representation for any object. Rules are defined for converting an object into an XML document.

3. **Customization and Metadata:** Introduce annotations to customize the serialization process. Annotations are declared with special syntax and associated with class definitions to modify serialization behavior.

## Getting Started

To get started with the project, follow these steps:

### 1. Clone the Repository

Clone the repository to your local machine using Git:

```bash
git clone https://github.com/SimonMirleni/TADPrinter.git
```

### 2. Install Dependencies
Navigate to the project directory:
```bash
cd .\TADPrinter\ruby\
```
And Install the dependencies with bundle.

### 3. Open the Project in RubyMine
Launch RubyMine.
1. When the welcome screen appears, click on "Open."
2. Navigate to the directory where your project is located.
3. Select the TADPrinter directory, then click "Open" or "Choose" depending on your operating system.
4. RubyMine will now load the project.

## License

This project is licensed under the MIT License - see the [licence](LICENSE) file for details.

## Conclusion

Thank you for checking out our project! If you have any questions, feel free to contact us.
