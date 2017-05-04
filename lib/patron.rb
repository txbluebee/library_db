class Patron
  attr_accessor(:name, :id)

  def initialize(attributes)
    @name = attributes.fetch(:name)
    @id = attributes.fetch(:id)
  end

  def self.all
    patrons_in_database = DB.exec("SELECT * FROM patrons;")
    all_patrons = []
    patrons_in_database.each() do |patron|
      name = patron.fetch('name')
      id = patron.fetch('id').to_i()
      each_patron = Patron.new({:name => name, :id => id})
      all_patrons.push(each_patron)
    end
    all_patrons
  end


  def save
    result = DB.exec("INSERT INTO patrons (name) VALUES ('#{@name}') RETURNING id;")
    @id = result.first().fetch("id").to_i()
  end



  def ==(another_patron)
    (self.name() == another_patron.name()) && (self.id() == another_patron.id())
  end


  def self.find(id)
    found_patron = nil
    Patron.all().each() do |patron|
      if patron.id() == id
        found_patron = patron
      end
    end
    found_patron
  end

  def update(attributes)
    #This will update the patrons name in patrons table##
    @name = attributes.fetch(:name, @name)
    @id = self.id()
    DB.exec("UPDATE patrons SET name = '#{@name}' WHERE id = #{@id}; ")
    #THIS INSERT WILL add book_ids for that patron TO THE checkouts TABLE##
    attributes.fetch(:book_ids, []).each do |book_id|
      DB.exec("INSERT INTO checkouts (book_id, patron_id) VALUES (#{book_id}, #{self.id()});")
    end
  end

  def books
    book_ids_in_checkouts = DB.exec("SELECT * FROM checkouts WHERE patron_id = #{self.id()};")
    patron_books = []
    book_ids_in_checkouts.each() do |each_line|
     book_id_in_row = each_line.fetch('book_id').to_i()
     book = DB.exec("SELECT * FROM books WHERE id = #{book_id_in_row}")
     title = book.first.fetch('title')
     author = book.first.fetch('author')
     checkout_book = Book.new({:id => book_id_in_row, :title => title, :author => author})
     patron_books.push(checkout_book)
    end
    patron_books
  end

  def delete
    DB.exec("DELETE FROM patrons WHERE id = #{self.id};")
  end


end
