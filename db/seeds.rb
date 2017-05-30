sarah = User.find_or_create_by(name:"sarah")
jp = User.find_or_create_by(name:"jp")
pradeep = User.find_or_create_by(name:"pradeep")
pat = User.find_or_create_by(name:"pat")

fiction = Category.find_or_create_by(name:"fiction")
non_fiction = Category.find_or_create_by(name:"non-fiction")

# fiction_books = ["Harry Potter", "Lord of the Rings 1", "Lord of the Rings 2"]
# non_fiction_books = ["Intro to C++", "Intro to Ruby", "Intro to Join Tables"]
#
# fiction_books.each do |book|
#   Book.find_or_create_by(title:book, category:fiction)
# end

author1 = Author.find_or_create_by(name:"jk rowling")
author2 = Author.find_or_create_by(name:"ada lovelace")
author3 = Author.find_or_create_by(name:"jrr tolkien")

fiction_book1 = Book.find_or_create_by(title:"harry potter", author:author1, category: fiction)
fiction_book2 = Book.find_or_create_by(title:"lord of the rings", author:author3, category: fiction)
fiction_book3 = Book.find_or_create_by(title:"lord of the rings 2", author:author3, category: fiction)

non_fiction_book1 = Book.find_or_create_by(title:"intro to c++", author:author2, category: non_fiction)
non_fiction_book2 = Book.find_or_create_by(title:"intro to ruby", author:author2, category: non_fiction)
non_fiction_book2 = Book.find_or_create_by(title:"intro to join tables", author:author2, category: non_fiction)
