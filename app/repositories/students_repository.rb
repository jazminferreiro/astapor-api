require_relative 'base_repository'
class StudentsRepository < BaseRepository
  self.table_name = :student
  self.model_class = 'Student'

  def find_by_user_name(user_name)
    row = dataset.first(user_name: user_name)
    load_object(row) unless row.nil?
  end

  def exist_already(user_name)
    !dataset.first(user_name: user_name).nil?
  end

  def find_or_create(data)
    find_by_user_name(data[:user_name]) || Student.new(data)
  end

  def load_registers(a_record)
    registers = RegisterRepository.new.find_by_student_username(a_record[:user_name])
    inscription_registers, grades_registers = registers.partition do |register|
      register.grade.nil?
    end
    inscriptions = inscription_registers.map(&:code)
    grades = Hash.new([])
    grades_registers.each do |register|
      grades[register.code] = grades[register.code].push(register.grade)
    end
    [inscriptions, grades]
  end

  def load_object(a_record)
    inscriptions, grades = load_registers(a_record)
    params = {
      name: a_record[:name],
      user_name: a_record[:user_name],
      inscriptions: inscriptions,
      grades: grades,
      created_on: a_record[:created_on],
      updated_on: a_record[:updated_on]
    }
    Student.new(params)
  end

  def save_register(register)
    RegisterRepository.new.save(register)
  end

  protected

  def changeset(student)
    student.inscriptions
           .map { |code| Register.new(code: code, student_username: student.user_name) }
           .each { |inscription| RegisterRepository.new.save(inscription) }

    student.grades.each do |code, values|
      values.each do |grade|
        grade_register = Register.new(code: code, student_username: student.user_name, grade: grade)
        RegisterRepository.new.save(grade_register)
      end
    end
    {
      name: student.name,
      user_name: student.user_name
    }
  end
end
