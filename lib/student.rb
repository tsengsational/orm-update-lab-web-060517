require_relative "../config/environment.rb"
require 'pry'

class Student
  attr_accessor :name, :grade
  attr_reader :id
  # Remember, you can access your database connection anywhere in this class
  #  with DB[:conn]

  def initialize(name, grade, id=nil)
    self.name = name
    self.grade = grade
    @id = id
  end

  def self.create_table
    sql = <<-SQL
    CREATE TABLE IF NOT EXISTS students (
      id INTEGER PRIMARY KEY,
      name TEXT,
      grade INTEGER
      )
      SQL

    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = <<-SQL
    DROP TABLE students;
    )
    SQL

  DB[:conn].execute(sql)
  end

  def save
    # binding.pry
    if self.id == nil
      id_query = "SELECT COUNT(*) FROM students;"
      @id = DB[:conn].execute(id_query).flatten[0] + 1
      sql = "INSERT INTO students (name, grade) VALUES (?, ?)"
      arr = DB[:conn].execute(sql, [self.name, self.grade])
    else
      self.update
    end
  end

  def self.create(name, grade)
    new_student = self.new(name, grade)
    new_student.save
    new_student
  end

  def self.new_from_db(row)
    student = self.new(row[1], row[2], row[0])
    student
  end

  def self.find_by_name(name)
    sql = <<-SQL
      SELECT * FROM students WHERE name = ?
    SQL

    row =  DB[:conn].execute(sql, name).first
    student = self.new_from_db(row)
    student
    # binding.pry
  end

  def update
    sql = <<-SQL
      UPDATE students SET name = ?, grade = ? WHERE id = ?
    SQL

    DB[:conn].execute(sql, self.name, self.grade, self.id)
  end

end

def values
  column_names.map do |attribute|
    self.send(attribute)
  end.join(", ")
end
