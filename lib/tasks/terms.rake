namespace :terms do
  desc "extracts terms from sentiment lexicon and loads into terms table"
  task extract: :environment do
    IO.foreach("data/AFINN-111.txt") do |term| 
      columns = term.split("\t")
      Term.create(word:columns[0],score:columns[1])   
    end
  end

  desc "adds emoticons to terms"
  task add_emoticons: :environment do
    Term.create(word:":)",score:5)
    Term.create(word:":-)",score:5)
    Term.create(word:"(:",score:5)
    Term.create(word:";)",score:5)
    Term.create(word:"(;",score:5)
    
    Term.create(word:":(",score:-5)
    Term.create(word:":-(",score:-5)
    Term.create(word:":'(",score:-5)
    Term.create(word:"):",score:-5)
  end

  desc "adds slang to terms"
  task add_slang: :environment do
    Term.create(word:"smh",score:-3)
    Term.create(word:"fml",score:-5)
    Term.create(word:"<3",score:5)
    Term.create(word:"ugh",score:-5)
    Term.create(word:"yay",score:5)
  end

end
