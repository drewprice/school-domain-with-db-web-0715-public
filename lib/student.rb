class Student
  def self.create_table
    create = <<-SQL
              CREATE TABLE students (
                id INTEGER PRIMARY KEY,
                name TEXT,
                tagline TEXT,
                github TEXT,
                twitter TEXT,
                blog_url TEXT,
                image_url TEXT,
                biography TEXT
              );
            SQL

    DB[:conn].execute(create)
  end

  def self.drop_table
    drop = <<-SQL
              DROP TABLE students;
            SQL

    DB[:conn].execute(drop)
  end

  def self.db_row_to_hash(row)
    DB[:conn].results_as_hash = true

    results = all_from_row_by_id(row)

    DB[:conn].results_as_hash = false

    results
  end

  def self.all_from_row_by_id(row)
    select_statement = <<-SQL
                         SELECT *
                         FROM students
                         WHERE id = ?;
                       SQL

    DB[:conn].execute(select_statement, row)
  end

  def self.new_from_db(row)
    new.tap do |student|
      student.id        = row[0]
      student.name      = row[1]
      student.tagline   = row[2]
      student.github    = row[3]
      student.twitter   = row[4]
      student.blog_url  = row[5]
      student.image_url = row[6]
      student.biography = row[7]
    end
  end

  def self.return_row_where_name_is(name)
    sql = <<-SQL
          SELECT *
          FROM students
          WHERE name = ?;
          SQL

    DB[:conn].execute(sql, name).flatten
  end

  def self.find_by_name(name)
    row = return_row_where_name_is(name)

    new_from_db(row) unless row.empty?
  end

  def self.find_by_id(id)
    sql = <<-SQL
          SELECT *
          FROM students
          WHERE id = ?;
          SQL

    DB[:conn].execute(sql, id).flatten
  end

  attr_accessor :id, :name, :tagline, :github, :twitter,
                :blog_url, :image_url, :biography

  def insert
    insert = <<-SQL
               INSERT INTO students (
                 name,
                 tagline,
                 github,
                 twitter,
                 blog_url,
                 image_url,
                 biography
               )
               VALUES (
                 ?, ?, ?, ?, ?, ?, ?
               );
             SQL

    DB[:conn].execute(insert,
                      name,
                      tagline,
                      github,
                      twitter,
                      blog_url,
                      image_url,
                      biography)

    update_instance_id
  end

  def update
    sql = <<-SQL
            UPDATE students
            SET
            name = ?,
            tagline = ?,
            github = ?,
            twitter = ?,
            blog_url = ?,
            image_url = ?,
            biography = ?
            WHERE id = ?;
          SQL

    DB[:conn].execute(sql, name, tagline, github, twitter,
                      blog_url, image_url, biography, id)
  end

  def save
    if student_exists?
      update
    else
      insert
    end
  end

  private

  def student_exists?
    !(Student.find_by_id(id).empty?)
  end

  def update_instance_id
    last_insert_id = <<-SQL
                         SELECT LAST_INSERT_ROWID()
                         FROM students;
                       SQL
    self.id = DB[:conn].execute(last_insert_id).flatten.first
  end
end
